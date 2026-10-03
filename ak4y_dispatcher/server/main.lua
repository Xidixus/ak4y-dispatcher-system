ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local incidents = {}
local blockedAreas = {}

local function getPlayerName(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        return xPlayer.getName()
    end
    return 'Neznámý důstojník'
end

local function isDispatchAllowed(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        return false
    end

    if xPlayer.getGroup and xPlayer.getGroup() == 'admin' then
        return true
    end

    if xPlayer.job and Config.DispatchJobs[xPlayer.job.name] then
        return true
    end

    local item = xPlayer.getInventoryItem(Config.RequiredItem)
    if item and item.count > 0 then
        return true
    end

    local backupItem = xPlayer.getInventoryItem(Config.RequiredItemBackup)
    if backupItem and backupItem.count > 0 then
        return true
    end

    return false
end

local function syncAllClients()
    TriggerClientEvent('ak4y_dispatcher:syncIncidents', -1, incidents)
end

local function notifyAll(message)
    TriggerClientEvent('esx:showAdvancedNotification', -1, 'AK4Y', 'Dispatch', message, 'CHAR_CALL911', 9)
end

local function createId()
    return 'AK4Y-' .. tostring(os.time()) .. '-' .. tostring(math.random(1000, 9999))
end

local function checkBlockedArea(coords)
    if not coords then
        return false
    end

    for _, area in ipairs(blockedAreas) do
        local distance = math.sqrt(
            ((coords.x - area.x) ^ 2) +
            ((coords.y - area.y) ^ 2) +
            ((coords.z - area.z) ^ 2)
        )

        if distance <= area.radius then
            return true
        end
    end

    return false
end

RegisterCommand('dispatcher', function(source, args, rawCommand)
    if not isDispatchAllowed(source) then
        TriggerClientEvent('esx:showNotification', source, 'Nemáš přístup k dispečerskému systému.')
        return
    end

    TriggerClientEvent('ak4y_dispatcher:openMdtClient', source)
end, false)

RegisterNetEvent('ak4y_dispatcher:openMdt', function()
    if not isDispatchAllowed(source) then
        TriggerClientEvent('esx:showNotification', source, 'Nemáš oprávnění pro MDT.')
        return
    end

    TriggerClientEvent('ak4y_dispatcher:openMdtClient', source)
end)

RegisterNetEvent('ak4y_dispatcher:requestSync', function()
    if not isDispatchAllowed(source) then
        return
    end

    TriggerClientEvent('ak4y_dispatcher:syncIncidents', source, incidents)
end)

RegisterNetEvent('ak4y_dispatcher:createIncident', function(data)
    local src = source
    if not isDispatchAllowed(src) then
        TriggerClientEvent('esx:showNotification', src, 'Nemáš oprávnění vytvořit upozornění.')
        return
    end

    if not data or not data.title then
        TriggerClientEvent('esx:showNotification', src, 'Některé údaje jsou neplatné.')
        return
    end

    local coords = data.coords or { x = 0.0, y = 0.0, z = 0.0 }
    if checkBlockedArea(coords) then
        TriggerClientEvent('esx:showNotification', src, 'Tato oblast je zablokována pro nová upozornění.')
        return
    end

    local incident = {
        id = createId(),
        title = tostring(data.title),
        type = tostring(data.type or 'Ostatní'),
        priority = tostring(data.priority or 'medium'),
        status = 'open',
        createdAt = os.date('%d.%m.%Y %H:%M:%S'),
        createdBy = getPlayerName(src),
        coords = coords,
        responders = {},
        calls = {},
        backupRequested = false,
        emergency = data.emergency or false,
        notes = tostring(data.notes or '')
    }

    table.insert(incidents, incident)

    local message = string.format('Přijato nové upozornění: %s', incident.title)
    notifyAll(message)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 140, 0},
        multiline = false,
        args = {'[DISPATCH]', message}
    })

    syncAllClients()
end)

RegisterNetEvent('ak4y_dispatcher:setStatus', function(id, status)
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    for _, incident in ipairs(incidents) do
        if incident.id == id then
            incident.status = tostring(status or 'open')
            incident.updatedBy = getPlayerName(src)
            incident.updatedAt = os.date('%d.%m.%Y %H:%M:%S')
            break
        end
    end

    syncAllClients()
end)

RegisterNetEvent('ak4y_dispatcher:setPriority', function(id, priority)
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    for _, incident in ipairs(incidents) do
        if incident.id == id then
            incident.priority = tostring(priority or 'medium')
            incident.updatedBy = getPlayerName(src)
            incident.updatedAt = os.date('%d.%m.%Y %H:%M:%S')
            break
        end
    end

    syncAllClients()
end)

RegisterNetEvent('ak4y_dispatcher:requestBackup', function(id, backupType)
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    for _, incident in ipairs(incidents) do
        if incident.id == id then
            incident.backupRequested = true
            incident.backupType = tostring(backupType or 'Záloha')
            incident.updatedBy = getPlayerName(src)
            incident.updatedAt = os.date('%d.%m.%Y %H:%M:%S')
            table.insert(incident.calls, {
                type = 'backup',
                message = tostring(backupType or 'Záloha'),
                time = os.date('%d.%m.%Y %H:%M:%S'),
                by = getPlayerName(src)
            })
            break
        end
    end

    notifyAll('Byla vyžádána záloha pro aktivní incident.')
    syncAllClients()
end)

RegisterNetEvent('ak4y_dispatcher:panicButton', function()
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    local message = string.format('Nouzové varování: %s aktivoval panický tlačítko.', getPlayerName(src))
    notifyAll(message)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 0, 0},
        multiline = false,
        args = {'[PANIC]', message}
    })
end)

RegisterNetEvent('ak4y_dispatcher:blockArea', function(coords, radius)
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    if not coords then
        return
    end

    local area = {
        x = tonumber(coords.x) or 0,
        y = tonumber(coords.y) or 0,
        z = tonumber(coords.z) or 0,
        radius = tonumber(radius) or 100.0,
        createdBy = getPlayerName(src)
    }

    table.insert(blockedAreas, area)
    TriggerClientEvent('esx:showNotification', src, 'Oblast byla zablokována pro nové události.')
end)

RegisterNetEvent('ak4y_dispatcher:clearHistory', function()
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    incidents = {}
    blockedAreas = {}
    syncAllClients()
    TriggerClientEvent('esx:showNotification', src, 'Historie protokolů byla vymazána.')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for _, incident in ipairs(incidents) do
            if incident.status == 'open' then
                incident.age = os.date('%H:%M:%S')
            end
        end
    end
end)
