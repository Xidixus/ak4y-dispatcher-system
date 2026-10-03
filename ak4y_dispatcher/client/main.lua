ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
end)

local isOpen = false
local currentIncidents = {}

local function showNotification(msg)
    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(msg)
    else
        TriggerEvent('esx:showNotification', msg)
    end
end

local function getPlayerCoords()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }
end

RegisterCommand('dispatcher', function()
    TriggerServerEvent('ak4y_dispatcher:openMdt')
end, false)

RegisterKeyMapping('dispatcher', 'Open AK4Y MDT', 'keyboard', Config.DispatchKey)

RegisterNetEvent('ak4y_dispatcher:openMdtClient', function()
    SetNuiFocus(true, true)
    isOpen = true
    SendNUIMessage({
        type = 'open'
    })
    TriggerServerEvent('ak4y_dispatcher:requestSync')
end)

RegisterNetEvent('ak4y_dispatcher:syncIncidents', function(data)
    currentIncidents = data or {}
    SendNUIMessage({
        type = 'sync',
        incidents = currentIncidents
    })
end)

RegisterNetEvent('ak4y_dispatcher:notify', function(msg)
    showNotification(msg)
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    isOpen = false
    cb('ok')
end)

RegisterNUICallback('requestSync', function(data, cb)
    TriggerServerEvent('ak4y_dispatcher:requestSync')
    cb('ok')
end)

RegisterNUICallback('createIncident', function(data, cb)
    local payload = data or {}
    local coords = getPlayerCoords()

    TriggerServerEvent('ak4y_dispatcher:createIncident', {
        title = payload.title or 'Neznámé upozornění',
        type = payload.type or 'Ostatní',
        priority = payload.priority or 'medium',
        notes = payload.notes or '',
        emergency = payload.emergency or false,
        coords = coords
    })

    cb('ok')
end)

RegisterNUICallback('setStatus', function(data, cb)
    if not data or not data.id then
        cb('error')
        return
    end

    TriggerServerEvent('ak4y_dispatcher:setStatus', data.id, data.status)
    cb('ok')
end)

RegisterNUICallback('setPriority', function(data, cb)
    if not data or not data.id then
        cb('error')
        return
    end

    TriggerServerEvent('ak4y_dispatcher:setPriority', data.id, data.priority)
    cb('ok')
end)

RegisterNUICallback('requestBackup', function(data, cb)
    if not data or not data.id then
        cb('error')
        return
    end

    TriggerServerEvent('ak4y_dispatcher:requestBackup', data.id, data.backupType or 'Záloha')
    cb('ok')
end)

RegisterNUICallback('panicButton', function(data, cb)
    TriggerServerEvent('ak4y_dispatcher:panicButton')
    cb('ok')
end)

RegisterNUICallback('blockArea', function(data, cb)
    local coords = getPlayerCoords()
    TriggerServerEvent('ak4y_dispatcher:blockArea', coords, data and data.radius or 100.0)
    cb('ok')
end)

RegisterNUICallback('clearHistory', function(data, cb)
    TriggerServerEvent('ak4y_dispatcher:clearHistory')
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if isOpen then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
        end
    end
end)
