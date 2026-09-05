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

    # Referencing `nvm` autoloads functions/nvm.fish, which also defines the
    # _nvm_* helpers used below.
    if not functions --query nvm _nvm_version_match
        return
    end

    # search for .nvmrc
    set -l activation_root $PWD

    while test $activation_root != ""
        if test -f "$activation_root/.nvmrc"
            # $nvm_current_version is the global nvm.fish sets on activation, so
            # it's fully qualified ("v20.20.2") while .nvmrc usually holds a
            # loose version ("20"). Resolve the latter the way `nvm use` does.
            read -l requested <"$activation_root/.nvmrc"
            if not string match --quiet --regex -- (_nvm_version_match $requested) "$nvm_current_version"
                nvm use >/dev/null
            end
            return
        end
        if test -e "$activation_root/.git"
            break # don't keep searching beyond a .git repository
        end
        # this strips the last path component from the path.
        set activation_root (echo $activation_root | sed 's|/[^/]*$||')
    end
    if set -q nvm_current_version
        nvm use system >/dev/null # deactivate
    end
end

# Wait until the first prompt to trigger
# (as auto_nvm.fish will run before nvm.fish)
function __nvmsupport_auto_activate_startup --on-event fish_prompt
    functions --erase __nvmsupport_auto_activate_startup
    __nvmsupport_auto_activate
end
