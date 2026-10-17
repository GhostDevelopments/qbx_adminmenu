local VEHICLES_HASH = exports.qbx_core:GetVehiclesByHash()

lib.callback.register('qbx_admin:client:SaveCarDialog', function()
    local response = lib.alertDialog({
        header = 'Save Car',
        content = 'This vehicle is already owned, do you want to override the current owner?',
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Yes',
            cancel = 'No'
        }
    })
    return response == 'confirm'
end)

lib.callback.register('qbx_admin:client:GetVehicleInfo', function()
    return VEHICLES_HASH[GetEntityModel(cache.vehicle)].model, lib.getVehicleProperties(cache.vehicle)
end)
