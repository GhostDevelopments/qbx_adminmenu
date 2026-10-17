local optionInvisible = false
local godmode = false
local infiniteAmmo = false
local vehicleGodmode = false

local options = {
    function() QbxAdmin.WithAbility("noclip", function() QbxAdmin.ToggleNoClipMode() end) end,
    function() TriggerServerEvent('qbx_admin:server:playerOptionsGeneral', 2, {id = cache.serverId}) end,
    function()
        QbxAdmin.WithAbility("invisible", function()
        optionInvisible = not optionInvisible
        if not optionInvisible then return end
        while optionInvisible do Wait(0)
            SetEntityVisible(cache.ped, false, false)
        end

        SetEntityVisible(cache.ped, true, false)
        end)
    end,
    function()
        QbxAdmin.WithAbility("godmode", function()
        godmode = not godmode
        if godmode then SetPlayerInvincible(cache.playerId, true) else SetPlayerInvincible(cache.playerId, false) end
        end)
    end,
    function() QbxAdmin.WithAbility("names", function() QbxAdmin.TogglePlayerNames() end) end,
    function() QbxAdmin.WithAbility("blips", function() QbxAdmin.TogglePlayerBlips() end) end,
    function()
        QbxAdmin.WithAbility("vehicleGodmode", function()
        vehicleGodmode = not vehicleGodmode
        if vehicleGodmode then
            while vehicleGodmode do
                SetEntityInvincible(cache.vehicle, true)
                SetEntityCanBeDamaged(cache.vehicle, false)
                SetVehicleBodyHealth(cache.vehicle, 1000.0)
                SetVehicleFixed(cache.vehicle)
                SetVehicleEngineHealth(cache.vehicle, 1000.0)
                Wait(250)
            end
        else
            SetEntityInvincible(cache.vehicle, false)
            SetEntityCanBeDamaged(cache.vehicle, true)
        end
        end)
    end,
    function(switch)
        QbxAdmin.WithAbility("setModel", function()
        if switch == 1 then
            local input = lib.inputDialog(locale('admin_options.value8_1'), {locale('admin_options.input8label')})
            if not input then return end
            ExecuteCommand('setmodel ' .. input)
        else
            ExecuteCommand('refreshskin')
        end
        end)
    end,
    function()
        QbxAdmin.WithAbility("infiniteAmmo", function()
        infiniteAmmo = not infiniteAmmo
        local weapon = GetSelectedPedWeapon(cache.ped)
        if infiniteAmmo then
            if GetAmmoInPedWeapon(cache.ped, weapon) < 6 then SetAmmoInClip(cache.ped, weapon, 10) Wait(50) end
            while infiniteAmmo do
                weapon = GetSelectedPedWeapon(cache.ped)
                SetPedInfiniteAmmo(cache.ped, true, weapon)
                RefillAmmoInstantly(cache.ped)
                Wait(250)
            end
        else
            SetPedInfiniteAmmo(cache.ped, false, weapon)
        end
        end)
    end,
    function(weaponType) QbxAdmin.WithAbility("giveWeapons", function() TriggerServerEvent('qbx_admin:server:giveAllWeapons', weaponType) end) end,
    function() QbxAdmin.WithAbility("playerActions", function() TriggerEvent('police:client:GetCuffed', cache.serverId, true) end) end,
}

lib.registerMenu({
    id = 'qbx_adminmenu_admin_menu',
    title = locale('title.admin_menu'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qbx_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes.qbx_adminmenu_admin_menu = selected
    end,
    options = {
        {label = locale('admin_options.label1'), description = locale('admin_options.desc1'), icon = 'fab fa-fly', close = false},
        {label = locale('admin_options.label2'), description = locale('admin_options.desc2'), icon = 'fas fa-hospital', close = false},
        {label = locale('admin_options.label3'), description = locale('admin_options.desc3'), icon = 'fas fa-ghost', close = false},
        {label = locale('admin_options.label4'), description = locale('admin_options.desc4'), icon = 'fas fa-bolt', close = false},
        {label = locale('admin_options.label5'), description = locale('admin_options.desc5'), icon = 'fas fa-clipboard-list', close = false},
        {label = locale('admin_options.label6'), description = locale('admin_options.desc6'), icon = 'fas fa-map-pin', close = false},
        {label = locale('admin_options.label7'), description = locale('admin_options.desc7'), icon = 'fas fa-car-on', close = false},
        {label = locale('admin_options.label8'), description = locale('admin_options.desc8'), icon = 'fas fa-person-half-dress', values = {locale('admin_options.value8_1'), locale('admin_options.value8_2')}},
        {label = locale('admin_options.label9'), description = locale('admin_options.desc9'), icon = 'fas fa-bullseye', close = false},
        {label = locale('admin_options.label10'), description = locale('admin_options.desc10'), icon = 'fas fa-gun', values = {locale('admin_options.value10_1'), locale('admin_options.value10_2'), locale('admin_options.value10_3'), locale('admin_options.value10_4'), locale('admin_options.value10_5'), locale('admin_options.value10_6'), locale('admin_options.value10_7')}, args = {'pistol', 'smg', 'shotgun', 'assault', 'lmg', 'sniper', 'heavy'}, close = false},
        {label = locale('admin_options.label11'), description = locale('admin_options.desc11'), icon = 'fas fa-handcuffs', close = false},
    }
}, function(selected, scrollIndex, args)
    if selected == 10 then
        ---@diagnostic disable-next-line: redundant-parameter
        options[selected](args[scrollIndex])
    else
        ---@diagnostic disable-next-line: redundant-parameter
        options[selected](scrollIndex)
    end
end)
