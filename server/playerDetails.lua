local config = require "config.server"

local function getDirtyMoney(playerId)
    local total = 0

    for i = 1, #config.dashboard.dirtyMoneyItems do
        local itemName = config.dashboard.dirtyMoneyItems[i]
        local ok, count = pcall(function()
            return exports.ox_inventory:GetItemCount(playerId, itemName)
        end)

        if ok and type(count) == "number" then
            total = total + count
        end
    end

    return total
end

local function queryOwnedVehicles(citizenid)
    local ok, vehicles = pcall(function()
        return MySQL.query.await(
            "SELECT vehicle, plate, garage, state FROM player_vehicles WHERE citizenid = ?",
            { citizenid }
        )
    end)

    if not ok then
        lib.print.warn(("Player vehicle lookup failed for %s"):format(citizenid))
        return {}
    end

    return vehicles or {}
end

local function queryOwnedProperties(citizenid)
    local ok, properties = pcall(function()
        return MySQL.query.await(
            "SELECT id, property_name FROM properties WHERE owner = ?",
            { citizenid }
        )
    end)

    if not ok then
        lib.print.warn(("Player property lookup failed for %s"):format(citizenid))
        return {}
    end

    return properties or {}
end

--- Build the complete online player record used by classic and NUI lookups.
--- @param playerId number The online server ID to inspect
--- @param balancesVisible boolean Whether money and dirty money may be returned
--- @return table|nil player The player record, or nil when the player is unavailable
function QbxAdmin.BuildPlayerDetails(playerId, balancesVisible)
    local target = exports.qbx_core:GetPlayer(playerId)
    if not target then return nil end

    local playerData = target.PlayerData
    local charInfo = playerData.charinfo or {}
    local job = playerData.job or {}
    local gang = playerData.gang or {}
    local money = playerData.money or {}
    local citizenid = playerData.citizenid
    local dirtyMoney = balancesVisible and getDirtyMoney(playerId) or nil
    local details = {
        id = playerId,
        cid = citizenid,
        name = (charInfo.firstname or "Unknown") .. " " .. (charInfo.lastname or "Player") .. " | (" .. (GetPlayerName(playerId) or "Unknown") .. ")",
        serverName = GetPlayerName(playerId) or "Unknown",
        food = Player(playerId).state.hunger,
        water = Player(playerId).state.thirst,
        stress = playerData.metadata and playerData.metadata.stress,
        armor = playerData.metadata and playerData.metadata.armor,
        phone = charInfo.phone,
        craftingrep = playerData.metadata and playerData.metadata.craftingrep,
        dealerrep = playerData.metadata and playerData.metadata.dealerrep,
        cash = balancesVisible and (money.cash or 0) or nil,
        bank = balancesVisible and (money.bank or 0) or nil,
        blackMoney = dirtyMoney,
        dirtyMoney = dirtyMoney,
        job = (job.label or job.name or "Unemployed") .. " | " .. tostring(job.grade and job.grade.level or 0),
        gang = gang.label or gang.name or "None",
        radio = Player(playerId).state.radioChannel,
        license = playerData.license or GetPlayerIdentifierByType(playerId, "license") or "Unknown",
        discord = GetPlayerIdentifierByType(playerId, "discord") or "Not Linked",
        steam = GetPlayerIdentifierByType(playerId, "steam") or "Not Linked",
        vehicles = queryOwnedVehicles(citizenid),
        properties = queryOwnedProperties(citizenid),
    }

    return details
end

lib.callback.register("qbx_admin:server:getPlayerDetails", function(source, playerId)
    local allowed, errorMessage = QbxAdmin.CanUseAbility(source, "viewPlayerDetails")
    if not allowed then
        lib.print.warn(("Player lookup refused for %s: %s"):format(source, errorMessage))
        return { ok = false, error = errorMessage }
    end

    playerId = tonumber(playerId)
    if not playerId or playerId < 1 or playerId ~= math.floor(playerId) then
        return { ok = false, error = "Invalid player ID" }
    end

    local balancesVisible = IsPlayerAceAllowed(source, config.abilityPerms.viewBalances)
    local player = QbxAdmin.BuildPlayerDetails(playerId, balancesVisible)
    if not player then
        return { ok = false, error = "That player is no longer online" }
    end

    return { ok = true, data = player }
end)
