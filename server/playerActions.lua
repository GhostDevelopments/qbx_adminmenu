local config = require "config.server"
local frozenPlayers = {}

local function getTargetPlayer(playerId)
    if type(playerId) ~= "number" or playerId < 1 or playerId ~= math.floor(playerId) then
        return nil
    end

    return exports.qbx_core:GetPlayer(playerId)
end

local function movePlayer(source, targetId, bring)
    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(targetId)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetCoords = GetEntityCoords(targetPed)

    if GetPlayerRoutingBucket(source) ~= GetPlayerRoutingBucket(targetId) then
        SetPlayerRoutingBucket(bring and source or targetId, GetPlayerRoutingBucket(bring and targetId or source))
    end

    local destination = bring and targetCoords or sourceCoords
    local destinationPed = bring and sourcePed or targetPed
    SetEntityCoords(destinationPed, destination.x, destination.y, destination.z, false, false, false, false)
end

--- Execute a server-authorized action against an online player.
--- @param source number The administrator server ID
--- @param playerId number The target server ID
--- @param action string The requested action
--- @return table result A server-confirmed action result
function QbxAdmin.ExecutePlayerAction(source, playerId, action)
    local allowed, errorMessage = QbxAdmin.CanUseAbility(source, "playerActions")
    if not allowed then
        lib.print.warn(("Player action refused for %s: %s"):format(source, errorMessage))
        return { ok = false, error = errorMessage }
    end

    if type(action) ~= "string" then
        return { ok = false, error = "Invalid player action" }
    end

    local target = getTargetPlayer(tonumber(playerId))
    if not target then
        return { ok = false, error = "That player is no longer online" }
    end

    playerId = target.PlayerData.source
    if action == "bring" then
        movePlayer(source, playerId, true)
    elseif action == "freeze" then
        frozenPlayers[playerId] = not frozenPlayers[playerId]
        FreezeEntityPosition(GetPlayerPed(playerId), frozenPlayers[playerId])
    elseif action == "kill" then
        TriggerClientEvent("qbx_admin:client:killPlayer", playerId)
    elseif action == "fire" then
        TriggerClientEvent("qbx_admin:client:setPlayerOnFire", playerId)
    else
        return { ok = false, error = "Unknown player action" }
    end

    local balancesVisible = IsPlayerAceAllowed(source, config.abilityPerms.viewBalances)
    return {
        ok = true,
        action = action,
        frozen = frozenPlayers[playerId] or false,
        data = QbxAdmin.BuildPlayerDetails(playerId, balancesVisible),
    }
end

lib.callback.register("qbx_admin:server:playerAction", function(source, playerId, action)
    return QbxAdmin.ExecutePlayerAction(source, playerId, action)
end)
