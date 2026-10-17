
local noclipEnabled = false
local ent
local invisible = nil
local noclipCam = nil
local speed = 1.0
local maxSpeed = 32.0
local minY, maxY = -150.0, 160.0
local inputRotEnabled = false
local disableControls = { 32, 33, 34, 35, 36, 12, 13, 14, 15, 16, 17 }

local function toggleNoclip()
    CreateThread(function()
        local inVehicle = false

        if cache.vehicle then
            inVehicle = true
            ent = cache.vehicle
        else
            ent = cache.ped
        end

        local pos = GetEntityCoords(ent)
        local rot = GetEntityRotation(ent)
        noclipCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, rot.z, 75.0, true, 2)
        AttachCamToEntity(noclipCam, ent, 0.0, 0.0, 0.0, true)
        RenderScriptCams(true, false, 3000, true, false)
        FreezeEntityPosition(ent, true)
        SetEntityCollision(ent, false, false)
        SetEntityAlpha(ent, 0, false)
        SetPedCanRagdoll(cache.ped, false)
        SetEntityVisible(ent, false, false)

        if not inVehicle then
            ClearPedTasksImmediately(cache.ped)
        end

        if inVehicle then
            FreezeEntityPosition(cache.ped, true)
            SetEntityCollision(cache.ped, false, false)
            SetEntityAlpha(cache.ped, 0, false)
            SetEntityVisible(cache.ped, false, false)
        end

        while noclipEnabled do
            Wait(0)
            local _, fv = GetCamMatrix(noclipCam)
            if IsDisabledControlPressed(2, 17) then -- Scroll Wheel Up
                speed = math.min(speed + 0.1, maxSpeed)
            elseif IsDisabledControlPressed(2, 16) then -- Scroll Wheel Down
                speed = math.max(0.1, speed - 0.1)
            end

            local multiplier = 1.0
            if IsDisabledControlPressed(2, 209) then -- Left Shift
                multiplier = 2.0
            elseif IsDisabledControlPressed(2, 19) then -- Left Alt
                multiplier = 4.0
            elseif IsDisabledControlPressed(2, 36) then -- Left CTRL
                multiplier = 0.25
            end

            if IsDisabledControlPressed(2, 32) then -- W
                local setPos = GetEntityCoords(ent) + fv * (speed * multiplier)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 33) then -- S
                local setPos = GetEntityCoords(ent) - fv * (speed * multiplier)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            if IsDisabledControlPressed(2, 34) then -- A
                local setPos = GetOffsetFromEntityInWorldCoords(ent, -speed * multiplier, 0.0, 0.0)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 35) then -- D
                local setPos = GetOffsetFromEntityInWorldCoords(ent, speed * multiplier, 0.0, 0.0)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            if IsDisabledControlPressed(2, 51) then -- E
                local setPos = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.0, multiplier * speed / 2)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 52) then -- Q
                local setPos = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.0, multiplier * -speed / 2)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            local camRot = GetCamRot(noclipCam, 2)
            SetEntityHeading(ent, (360 + camRot.z) % 360)
            SetEntityVisible(ent, false, false)

            if inVehicle then
                SetEntityVisible(cache.ped, false, false)
            end

            for i = 1, #disableControls do
                DisableControlAction(2, disableControls[i], true)
            end

            DisablePlayerFiring(cache.playerId, true)
        end

        DestroyCam(noclipCam, false)
        noclipCam = nil
        RenderScriptCams(false, false, 3000, true, false)
        FreezeEntityPosition(ent, false)
        SetEntityCollision(ent, true, true)
        ResetEntityAlpha(ent)
        SetPedCanRagdoll(cache.ped, true)
        SetEntityVisible(ent, not invisible, false)
        ClearPedTasksImmediately(cache.ped)
        if inVehicle then
            FreezeEntityPosition(cache.ped, false)
            SetEntityCollision(cache.ped, true, true)
            ResetEntityAlpha(cache.ped)
            SetEntityVisible(cache.ped, true, false)
            SetPedIntoVehicle(cache.ped, ent, -1)
        end
    end)
end

local function checkInputRotation()
    CreateThread(function()
        while inputRotEnabled do
            while not noclipCam or IsPauseMenuActive() do Wait(0) end
            local axisX = GetDisabledControlNormal(0, 1)
            local axisY = GetDisabledControlNormal(0, 2)
            local sensitivity = GetProfileSetting(14) * 2

            if GetProfileSetting(15) == 0 then -- Invert controls
                sensitivity = -sensitivity
            end

            if math.abs(axisX) > 0 or math.abs(axisY) > 0 then
                local rotation = GetCamRot(noclipCam, 2)
                local rotz = rotation.z + (axisX * sensitivity)
                local yValue = axisY * sensitivity
                local rotx = rotation.x
                if rotx + yValue > minY and rotx + yValue < maxY then
                    rotx = rotation.x + yValue
                end

                SetCamRot(noclipCam, rotx, rotation.y, rotz, 2)
            end
            Wait(0)
        end
    end)
end

function QbxAdmin.ToggleNoClipMode(forceMode)
    if forceMode ~= nil then
        noclipEnabled = forceMode
        inputRotEnabled = noclipEnabled
    else
        noclipEnabled = not noclipEnabled
        inputRotEnabled = noclipEnabled
    end

    if noclipEnabled and inputRotEnabled then
        toggleNoclip()
        checkInputRotation()
    end

    return noclipEnabled
end

RegisterNetEvent('qbx_admin:client:ToggleNoClip', function()
    if GetInvokingResource() then return end
    QbxAdmin.WithAbility("noclip", function()
        QbxAdmin.ToggleNoClipMode()
    end)
end)
