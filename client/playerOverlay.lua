

local showBlips = false
local showNames = false
local netCheck1 = false
local netCheck2 = false

RegisterNetEvent('qbx_admin:client:blips', function()
    if not showBlips then
        showBlips = true
        netCheck1 = true
        exports.qbx_core:Notify(locale('success.blips_activated'), 'success')
    else
        showBlips = false
        exports.qbx_core:Notify(locale('error.blips_deactivated'), 'error')
    end
end)

RegisterNetEvent('qbx_admin:client:names', function()
    if not showNames then
        showNames = true
        netCheck2 = true
        exports.qbx_core:Notify(locale('success.names_activated'), 'success')
    else
        showNames = false
        exports.qbx_core:Notify(locale('error.names_deactivated'), 'error')
    end
end)

RegisterNetEvent('qbx_admin:client:Show', function()
    local players = lib.callback.await('qbx_admin:server:getPlayers', false)
    for _, player in pairs(players) do
        local playerId = GetPlayerFromServerId(player.id)
        local ped = GetPlayerPed(playerId)
        local blip = GetBlipFromEntity(ped)
        local name = 'ID: '..player.id..' | '..player.name

        local tag = CreateFakeMpGamerTag(ped, name, false, false, '', 0)
        SetMpGamerTagAlpha(tag, 0, 255) -- Sets 'MP_TAG_GAMER_NAME' bar alpha to 100% (not needed just as a fail safe)
        SetMpGamerTagAlpha(tag, 2, 255) -- Sets 'MP_TAG_HEALTH_ARMOUR' bar alpha to 100%
        SetMpGamerTagAlpha(tag, 4, 255) -- Sets 'MP_TAG_AUDIO_ICON' bar alpha to 100%
        SetMpGamerTagAlpha(tag, 6, 255) -- Sets 'MP_TAG_PASSIVE_MODE' bar alpha to 100%
        SetMpGamerTagHealthBarColour(tag, 25)  --https://wiki.rage.mp/index.php?title=Fonts_and_Colors

        if showNames then
            SetMpGamerTagVisibility(tag, 0, true) -- Activates the player ID Char name and FiveM name
            SetMpGamerTagVisibility(tag, 2, true) -- Activates the health (and armor if they have it on) bar below the player names
            if NetworkIsPlayerTalking(playerId) then
                SetMpGamerTagVisibility(tag, 4, true) -- If player is talking a voice icon will show up on the left side of the name
            else
                SetMpGamerTagVisibility(tag, 4, false)
            end
            if GetPlayerInvincible(playerId) then
                SetMpGamerTagVisibility(tag, 6, true) -- If player is in godmode a circle with a line through it will show up
            else
                SetMpGamerTagVisibility(tag, 6, false)
            end
        else
            SetMpGamerTagVisibility(tag, 0, false)
            SetMpGamerTagVisibility(tag, 2, false)
            SetMpGamerTagVisibility(tag, 4, false)
            SetMpGamerTagVisibility(tag, 6, false)
            RemoveMpGamerTag(tag) -- Unloads the tags till you activate it again
            netCheck2 = false
        end

        -- Blips Logic
        if showBlips then
            if not DoesBlipExist(blip) then
                blip = AddBlipForEntity(ped)
                SetBlipSprite(blip, 1)
                ShowHeadingIndicatorOnBlip(blip, true)
            else
                local blipSprite = GetBlipSprite(blip)
                --Payer Death
                if not GetEntityHealth(ped) then
                    if blipSprite ~= 274 then
                        SetBlipSprite(blip, 274)            --Dead icon
                        ShowHeadingIndicatorOnBlip(blip, false)
                    end
                --Player in Vehicle
                elseif cache.vehicle ~= 0 then
                    local classVeh = GetVehicleClass(cache.vehicle)
                    local modelVeh = GetEntityModel(cache.vehicle)
                    --MotorCycles (8) or Cycles (13)
                    if classVeh == 8  or classVeh == 13 then
                        if blipSprite ~= 226 then
                            SetBlipSprite(blip, 226)        --Motorcycle icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --OffRoad (9)
                    elseif classVeh == 9 then
                        if blipSprite ~= 757 then
                            SetBlipSprite(blip, 757)        --OffRoad icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Industrial (10)
                    elseif classVeh == 10 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Utility (11)
                    elseif classVeh == 11 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon despite finding better one
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Vans (12)
                    elseif classVeh == 12 then
                        if blipSprite ~= 67 then
                            SetBlipSprite(blip, 67)         --Van icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Boats (14)
                    elseif classVeh == 14 then
                        if blipSprite ~= 427 then
                            SetBlipSprite(blip, 427)        --Boat icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Helicopters (15)
                    elseif classVeh == 15 then
                        if blipSprite ~= 422 then
                            SetBlipSprite(blip, 422)        --Moving helicopter icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Planes (16)
                    elseif classVeh == 16 then
                        if modelVeh == 'besra' or modelVeh == 'hydra' or modelVeh == 'lazer' then
                            if blipSprite ~= 424 then
                                SetBlipSprite(blip, 424)    --Jet icon
                                ShowHeadingIndicatorOnBlip(blip, false)
                            end
                        elseif blipSprite ~= 423 then
                            SetBlipSprite(blip, 423)        --Plane icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Service (17)
                    elseif classVeh == 17 then
                        if blipSprite ~= 198 then
                            SetBlipSprite(blip, 198)        --Taxi icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Emergency (18)
                    elseif classVeh == 18 then
                        if blipSprite ~= 56 then
                            SetBlipSprite(blip, 56)        --Cop icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Military (19)
                    elseif classVeh == 19 then
                        if modelVeh == 'rhino' then
                            if blipSprite ~= 421 then
                                SetBlipSprite(blip, 421)    --Tank icon
                                ShowHeadingIndicatorOnBlip(blip, false)
                            end
                        elseif blipSprite ~= 750 then
                            SetBlipSprite(blip, 750)        --Military truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Commercial (20)
                    elseif classVeh == 20 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Every car (0, 1, 2, 3, 4, 5, 6, 7)
                    else
                        if modelVeh == 'insurgent' or modelVeh == 'insurgent2' or modelVeh == 'limo2' then
                            if blipSprite ~= 426 then
                                SetBlipSprite(blip, 426)    --Armed car icon
                                ShowHeadingIndicatorOnBlip(blip, false)
                            end
                        elseif blipSprite ~= 225 then
                            SetBlipSprite(blip, 225)        --Car icon
                            ShowHeadingIndicatorOnBlip(blip, true)
                        end
                    end
                    -- Show number in case of passangers
                    local passengers = GetVehicleNumberOfPassengers(cache.vehicle)
                    if passengers then
                        if not IsVehicleSeatFree(cache.vehicle, -1) then
                            passengers = passengers + 1
                        end
                        ShowNumberOnBlip(blip, passengers)
                    else
                        HideNumberOnBlip(blip)
                    end
                --Player on Foot
                else
                    HideNumberOnBlip(blip)
                    if blipSprite ~= 1 then
                        SetBlipSprite(blip, 1)
                        ShowHeadingIndicatorOnBlip(blip, true)
                    end
                end

                SetBlipRotation(blip, math.ceil(GetEntityHeading(cache.vehicle)))
                SetBlipNameToPlayerName(blip, playerId)
                SetBlipScale(blip, 0.85)

                if IsPauseMenuActive() then
                    SetBlipAlpha(blip, 255)
                else
                    local x1, y1 = table.unpack(GetEntityCoords(cache.ped, true))
                    local x2, y2 = table.unpack(GetEntityCoords(ped, true))
                    local distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                    distance = distance < 0 and 0 or distance > 255 and 255 or distance
                    SetBlipAlpha(blip, distance)
                end
            end
        else
            RemoveBlip(blip)
            netCheck1 = false
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        if netCheck1 or netCheck2 then
            TriggerEvent('qbx_admin:client:Show')
        end
    end
end)
