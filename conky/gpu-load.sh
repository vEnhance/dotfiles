#!/usr/bin/env bash
# One-line GPU load readout for conky, portable across the Arch boxes sharing
# these dotfiles. Probes in order: AMD, NVIDIA, Intel i915, Intel xe. Prints
# "n/a" rather than failing when none match (VMs, unsupported drivers).
#
# Emits conky colour markup, so call it with execpi (not execi):
#   ${execpi 3 ~/dotfiles/conky/gpu-load.sh}
#
# Everything here reads sysfs or nvidia-smi as an ordinary user. Nothing needs
# root. (Real per-engine occupancy would need intel_gpu_top's perf counters,
# which want perf_event_paranoid <= 0 -- deliberately not used.)
#
# Intel exposes no utilisation counter, but it does expose a monotonic count of
# milliseconds spent in the GPU's sleep state. Diffing that against wall-clock
# between invocations gives "fraction of the interval the GPU was awake", which
# is an interval average rather than a point sample. Clock speed is NOT used:
# i915 boosts to max on brief bursts and lingers there, so act_freq reads "max"
# on a GPU that is ~85% asleep.
set -euo pipefail

# ${...} below are conky tokens, not shell expansions -- single quotes intended.
# shellcheck disable=SC2016
OK='${color7}'
# shellcheck disable=SC2016
HOT='${color ff9999}' # same alert colour as "[Muted!]" in star-bar.conf
# shellcheck disable=SC2016
NONE='${color0}'

STATE="${XDG_RUNTIME_DIR:-/tmp}/conky-gpu-load.$(id -u)"

# $1 = current, $2 = ceiling, $3 = text to print. Highlights at >=90% of ceiling.
emit() {
	local cur=$1 ceil=$2 text=$3 colour=$OK
	if [ "$ceil" -gt 0 ] 2>/dev/null && [ $((cur * 100 / ceil)) -ge 90 ] 2>/dev/null; then
		colour=$HOT
	fi
	printf '%s%s\n' "$colour" "$text"
	exit 0
}

# $1 = path to a monotonic "milliseconds spent asleep" counter.
# Echoes busy percent, or returns 1 when there is no usable baseline yet.
busy_from_idle_counter() {
	local file=$1 idle now prev_idle="" prev_t="" dt di busy
	idle=$(<"$file")
	now=$(date +%s%3N)

	if [ -r "$STATE" ]; then
		read -r prev_idle prev_t <"$STATE" || true
	fi
	printf '%s %s\n' "$idle" "$now" >"$STATE"

	[ -n "$prev_idle" ] && [ -n "$prev_t" ] || return 1

	dt=$((now - prev_t))
	di=$((idle - prev_idle))

	# Reject: no elapsed time, a stale cache (conky restarted, laptop resumed),
	# or a counter that went backwards (reboot, module reload). Re-baseline
	# silently instead of reporting a bogus average.
	[ "$dt" -gt 0 ] && [ "$dt" -le 60000 ] && [ "$di" -ge 0 ] || return 1

	busy=$(((dt - di) * 100 / dt))
	# The counter and the clock are sampled a hair apart, so clamp the ends.
	[ "$busy" -lt 0 ] && busy=0
	[ "$busy" -gt 100 ] && busy=100
	printf '%s' "$busy"
}

# --- AMD (amdgpu): real utilisation counter, no diffing needed ---
for f in /sys/class/drm/card*/device/gpu_busy_percent; do
	[ -r "$f" ] || continue
	pct=$(<"$f")
	emit "$pct" 100 "${pct}% busy"
done

# --- NVIDIA (proprietary driver) ---
if command -v nvidia-smi >/dev/null 2>&1; then
	pct=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
	if [ -n "$pct" ]; then
		emit "$pct" 100 "${pct}% busy"
	fi
fi

# --- Intel i915: RC6 is the render-side deep sleep state ---
for f in /sys/class/drm/card*/power/rc6_residency_ms; do
	[ -r "$f" ] || continue
	if pct=$(busy_from_idle_counter "$f"); then
		emit "$pct" 100 "${pct}% busy"
	fi
	printf '%s--\n' "$NONE" # first run: baseline recorded, no delta yet
	exit 0
done

# --- Intel xe (Arc, Meteor Lake and newer): same idea, different path ---
for f in /sys/class/drm/card*/device/tile*/gt*/gtidle/idle_residency_ms; do
	[ -r "$f" ] || continue
	if pct=$(busy_from_idle_counter "$f"); then
		emit "$pct" 100 "${pct}% busy"
	fi
	printf '%s--\n' "$NONE"
	exit 0
done

printf '%sn/a\n' "$NONE"
