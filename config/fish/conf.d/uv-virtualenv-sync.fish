# Automatically sets UV_PROJECT_ENVIRONMENT when VIRTUAL_ENV changes

function __uv_sync_virtual_env --on-variable VIRTUAL_ENV
    if not status --is-interactive
        return
    end
    if status --is-command-substitution
        return
    end
    if set -q VIRTUAL_ENV
        set -gx UV_PROJECT_ENVIRONMENT $VIRTUAL_ENV
    else
        set -e UV_PROJECT_ENVIRONMENT
    end
end

# Run once on startup to sync current state
__uv_sync_virtual_env
