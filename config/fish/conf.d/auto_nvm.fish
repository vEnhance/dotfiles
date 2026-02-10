################
# Automatic NVM activation
# by Evan Chen
# Based on auto-activation.fish from virtualfish

function __nvmsupport_auto_activate --on-variable PWD
	if not status --is-interactive
		return
	end
	if status --is-command-substitution
		return
	end

	# search for .nvmrc
	set -l activation_root $PWD
	set -l new_nvm_name ""

	while test $activation_root != ""
		if test -f "$activation_root/.nvmrc"
			if test "$nvm_current_version" != (cat "$activation_root/.nvmrc")
				nvm use > /dev/null
			end
			return
		end
		if test -f "$activation_root/.git"
			break # don't keep searching beyond a .git repository
		end
		# this strips the last path component from the path.
		set activation_root (echo $activation_root | sed 's|/[^/]*$||')
	end
	if set -q nvm_current_version
	  nvm use system > /dev/null # deactivate
	end
end

__nvmsupport_auto_activate
