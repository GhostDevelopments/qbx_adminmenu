local config = require "config.server"

local function isTrue(value)
    return value == true or value == 1 or value == "1"
end

local function getAdminRole(playerId)
    for i = 1, #config.dashboard.adminRoles do
        local role = config.dashboard.adminRoles[i]
        if IsPlayerAceAllowed(playerId, role) then
            return role
        end
    end

    return nil
end

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

local function canUseAbility(playerId, ability)
    local permission = type(ability) == "string" and config.abilityPerms[ability]
    if not permission then
        return false, "That ability is not configured"
    end

    if not IsPlayerAceAllowed(playerId, permission) then
        return false, "You need the " .. permission .. " role"
    end

    if not exports.qbx_core:IsOptin(playerId) then
        return false, "You are not on admin duty"
    end

    return true
end

lib.callback.register("qbx_admin:server:canUseAbility", function(source, ability)
    local allowed, errorMessage = canUseAbility(source, ability)
    if not allowed then
        lib.print.warn(("Ability refused for %s: %s (%s)"):format(source, tostring(ability), errorMessage))
        return { ok = false, error = errorMessage }
    end

    return { ok = true }
end)

lib.callback.register("qbx_admin:server:getDashboard", function(source)
    if not IsPlayerAceAllowed(source, config.eventPerms.useMenu) then
        lib.print.warn(("Dashboard refused for %s: missing %s"):format(source, config.eventPerms.useMenu))
        return { ok = false, error = "You do not have permission to open the dashboard" }
    end

    if not exports.qbx_core:IsOptin(source) then
        return { ok = false, error = "You are not on admin duty" }
    end

    local balancesVisible = IsPlayerAceAllowed(source, config.abilityPerms.viewBalances)
    local adminsVisible = IsPlayerAceAllowed(source, config.abilityPerms.viewAdmins)
    local abilities = {}
    for ability, permission in pairs(config.abilityPerms) do
        abilities[ability] = IsPlayerAceAllowed(source, permission)
    end

    local players = {}
    local admins = {}

    for playerId, player in pairs(exports.qbx_core:GetQBPlayers()) do
        local playerData = player.PlayerData
        local id = tonumber(playerId) or playerId
        local charInfo = playerData.charinfo or {}
        local job = playerData.job or {}
        local adminRole = getAdminRole(id)
        local adminDuty = exports.qbx_core:IsOptin(id)
        local jobOnDuty = isTrue(job.onduty)

        players[#players + 1] = {
            id = id,
            name = (charInfo.firstname or "Unknown") .. " " .. (charInfo.lastname or "Player"),
            serverName = GetPlayerName(id) or "Unknown",
            job = job.label or job.name or "Unemployed",
            jobOnDuty = jobOnDuty,
            adminRole = adminsVisible and adminRole or nil,
            adminDuty = adminsVisible and adminRole and adminDuty or false,
            cash = balancesVisible and (playerData.money.cash or 0) or nil,
            bank = balancesVisible and (playerData.money.bank or 0) or nil,
            dirtyMoney = balancesVisible and getDirtyMoney(id) or nil,
        }

        if adminRole and adminsVisible then
            admins[#admins + 1] = {
                id = id,
                name = (charInfo.firstname or "Unknown") .. " " .. (charInfo.lastname or "Player"),
                role = adminRole,
                onDuty = adminDuty,
                job = job.label or job.name or "Unemployed",
                jobOnDuty = jobOnDuty,
            }
        end
    end

    table.sort(players, function(first, second)
        return first.id < second.id
    end)
    table.sort(admins, function(first, second)
        return first.id < second.id
    end)

    return {
        ok = true,
        data = {
            players = players,
            admins = admins,
            balancesVisible = balancesVisible,
            abilities = abilities,
            dirtyMoneyItems = config.dashboard.dirtyMoneyItems,
            generatedAt = os.date("%H:%M:%S"),
        }
    }
end)
