local uiOpen = false

local function closeDashboard()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close", data = {} })
end

local function openDashboard()
    local dashboard = lib.callback.await("qbx_admin:server:getDashboard", false)
    if not dashboard or not dashboard.ok then
        lib.notify({
            title = "Admin dashboard",
            description = dashboard and dashboard.error or "Unable to load the dashboard",
            type = "error",
        })
        return
    end

    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open", data = dashboard.data })
end

RegisterNetEvent("qbx_admin:client:openDashboard", openDashboard)

RegisterNUICallback("close", function(_, callback)
    closeDashboard()
    callback({ ok = true })
end)

RegisterNUICallback("action", function(data, callback)
    local action = type(data) == "table" and data.name
    if type(action) ~= "string" then
        callback({ ok = false, error = "Invalid dashboard action" })
        return
    end

    if action == "refresh" then
        local dashboard = lib.callback.await("qbx_admin:server:getDashboard", false)
        callback(dashboard or { ok = false, error = "Unable to refresh the dashboard" })
        return
    end

    if action == "legacyMenu" then
        closeDashboard()
        lib.showMenu("qbx_adminmenu_main_menu", MenuIndexes.qbx_adminmenu_main_menu)
        callback({ ok = true })
        return
    end

    if action == "lookupPlayer" then
        local result = lib.callback.await("qbx_admin:server:getPlayerDetails", false, data.playerId)
        callback(result or { ok = false, error = "Unable to look up that player" })
        return
    end

    if action == "playerAction" then
        local result = lib.callback.await(
            "qbx_admin:server:playerAction",
            false,
            data.playerId,
            data.playerAction
        )
        callback(result or { ok = false, error = "Unable to complete that player action" })
        return
    end

    local result = lib.callback.await("qbx_admin:server:canUseAbility", false, action)
    if not result or not result.ok then
        callback(result or { ok = false, error = "Permission denied" })
        return
    end

    local enabled
    if action == "noclip" then
        enabled = QbxAdmin.ToggleNoClipMode()
    elseif action == "names" then
        enabled = QbxAdmin.TogglePlayerNames()
    elseif action == "blips" then
        enabled = QbxAdmin.TogglePlayerBlips()
    elseif action == "entityView" then
        enabled = QbxAdmin.ToggleEntityViewMode()
    else
        callback({ ok = false, error = "Unknown dashboard action" })
        return
    end

    callback({ ok = true, enabled = enabled })
end)

RegisterNUICallback("setFocus", function(data, callback)
    if type(data) ~= "table" or type(data.focus) ~= "boolean" then
        callback({ ok = false, error = "Invalid focus state" })
        return
    end

    SetNuiFocus(data.focus, data.focus)
    callback({ ok = true })
end)

CreateThread(function()
    while true do
        Wait(0)
        if uiOpen and IsControlJustReleased(0, 322) then
            closeDashboard()
        end
    end
end)
