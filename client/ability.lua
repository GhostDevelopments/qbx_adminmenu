QbxAdmin = QbxAdmin or {}

--- Run a client ability after the server confirms the configured ACE permission.
--- @param ability string The configured ability key
--- @param callback function The action to run after authorization
function QbxAdmin.WithAbility(ability, callback)
    local result = lib.callback.await("qbx_admin:server:canUseAbility", false, ability)
    if not result or not result.ok then
        lib.notify({
            title = "Admin tools",
            description = result and result.error or "You are not allowed to use this ability",
            type = "error",
        })
        return false
    end

    callback()
    return true
end
