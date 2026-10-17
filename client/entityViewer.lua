local entityViewEnabled = false

local function rotationToDirection(rotation)
    local adjustedRotation = vec3(
        math.rad(rotation.x),
        math.rad(rotation.y),
        math.rad(rotation.z)
    )
    local cosX = math.abs(math.cos(adjustedRotation.x))

    return vec3(
        -math.sin(adjustedRotation.z) * cosX,
        math.cos(adjustedRotation.z) * cosX,
        math.sin(adjustedRotation.x)
    )
end

local function drawEntityText(text, x, y, scale)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function getLookedAtEntity()
    local cameraCoords = GetGameplayCamCoord()
    local direction = rotationToDirection(GetGameplayCamRot(2))
    local destination = cameraCoords + direction * 1000.0
    local ray = StartShapeTestRay(
        cameraCoords.x,
        cameraCoords.y,
        cameraCoords.z,
        destination.x,
        destination.y,
        destination.z,
        -1,
        cache.ped,
        0
    )
    local _, hit, endCoords, _, entity = GetShapeTestResult(ray)

    return hit == 1 and entity or 0, endCoords
end

local function drawEntityDetails(entity, coords)
    local entityType = GetEntityType(entity)
    local model = GetEntityModel(entity)
    local networkId = NetworkGetNetworkIdFromEntity(entity)
    local health = GetEntityHealth(entity)
    local heading = GetEntityHeading(entity)
    local kind = entityType == 1 and "Ped" or entityType == 2 and "Vehicle" or entityType == 3 and "Object" or "Entity"

    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.35, 255, 145, 55, 180, false, false, 2, false, nil, nil, false)
    drawEntityText(("~o~%s~w~ | Model: %s | Net: %s"):format(kind, model, networkId), 0.015, 0.72, 0.35)
    drawEntityText(("Health: %s | Heading: %s | Mission: %s"):format(health, math.floor(heading), tostring(IsEntityAMissionEntity(entity))), 0.015, 0.745, 0.35)
end

--- Toggle the developer entity inspector and return its confirmed local state.
--- @return boolean enabled Whether entity view mode is active
function QbxAdmin.ToggleEntityViewMode()
    entityViewEnabled = not entityViewEnabled
    return entityViewEnabled
end

RegisterNetEvent("qbx_admin:client:entityView", function()
    QbxAdmin.WithAbility("entityView", function()
        QbxAdmin.ToggleEntityViewMode()
    end)
end)

CreateThread(function()
    while true do
        if not entityViewEnabled then
            Wait(500)
        else
            Wait(0)
            if IsControlJustReleased(0, 322) then
                entityViewEnabled = false
            end

            local entity, coords = getLookedAtEntity()
            local cameraCoords = GetGameplayCamCoord()
            DrawLine(cameraCoords.x, cameraCoords.y, cameraCoords.z, coords.x, coords.y, coords.z, 255, 145, 55, 130)
            drawEntityText("ENTITY VIEW  |  ESC or dashboard toggle to stop", 0.015, 0.68, 0.35)

            if entity ~= 0 and DoesEntityExist(entity) then
                drawEntityDetails(entity, coords)
            else
                drawEntityText("No entity under crosshair", 0.015, 0.72, 0.35)
            end
        end
    end
end)
