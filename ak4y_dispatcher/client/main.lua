ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local incidents = {}
local blockedAreas = {}
local history = {}

local function getPlayerName(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer and xPlayer.getName then
        return xPlayer.getName()
    end
    return 'Neznámý důstojník'
end

local function isDispatchAllowed(playerId)
    if not playerId then
        return false
    end

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

local function pushHistory(text)
    table.insert(history, {
        time = os.date('%d.%m.%Y %H:%M:%S'),
        text = text
    })

    while #history > Config.MaxHistoryEntries do
        table.remove(history, 1)
    end
end

local function syncDispatch(target)
    TriggerClientEvent('ak4y_dispatcher:syncIncidents', target, {
        incidents = incidents,
        history = history,
        blockedAreas = blockedAreas
    })
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
        local dx = coords.x - area.x
        local dy = coords.y - area.y
        local dz = coords.z - area.z
        local distance = math.sqrt((dx * dx) + (dy * dy) + (dz * dz))

        if distance <= area.radius then
            return true
        end
    end

    return false
end

local function addResponderToIncident(id, responderName)
    for _, incident in ipairs(incidents) do
        if incident.id == id then
            local exists = false
            for _, existing in ipairs(incident.responders) do
                if existing == responderName then
                    exists = true
                    break
                end
            end

            if not exists then
                table.insert(incident.responders, responderName)
                incident.updatedAt = os.date('%d.%m.%Y %H:%M:%S')
            end
            return
        end
    end
end

RegisterCommand('dispatcher', function(source)
    if not isDispatchAllowed(source) then
        TriggerClientEvent('esx:showNotification', source, 'Nemáš přístup k dispečerskému systému.')
        return
    end

    TriggerClientEvent('ak4y_dispatcher:openMdtClient', source)
end, false)

RegisterNetEvent('ak4y_dispatcher:openMdt', function()
    local src = source
    if not isDispatchAllowed(src) then
        TriggerClientEvent('esx:showNotification', src, 'Nemáš oprávnění pro MDT.')
        return
    end

    TriggerClientEvent('ak4y_dispatcher:openMdtClient', src)
end)

RegisterNetEvent('ak4y_dispatcher:requestSync', function()
    local src = source
    if not isDispatchAllowed(src) then
        return
    end
    syncDispatch(src)
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
        coords = {
            x = tonumber(coords.x) or 0.0,
            y = tonumber(coords.y) or 0.0,
            z = tonumber(coords.z) or 0.0
        },
        responders = {},
        notes = tostring(data.notes or ''),
        backupRequested = false,
        emergency = data.emergency or false,
        updatedAt = os.date('%d.%m.%Y %H:%M:%S')
    }

    table.insert(incidents, incident)
    pushHistory(('Vytvořeno nové upozornění: %s | by %s'):format(incident.title, incident.createdBy))

    notifyAll(('Přijato nové upozornění: %s'):format(incident.title))
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 140, 0},
        multiline = false,
        args = {'[DISPATCH]', ('Přijato nové upozornění: %s'):format(incident.title)}
    })

    syncDispatch(-1)
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
            pushHistory(('Upozornění %s změněno na %s | by %s'):format(incident.title, incident.status, getPlayerName(src)))
            break
        end
    end

    syncDispatch(-1)
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
            pushHistory(('Priorita upozornění %s změněna na %s | by %s'):format(incident.title, incident.priority, getPlayerName(src)))
            break
        end
    end

    syncDispatch(-1)
end)

RegisterNetEvent('ak4y_dispatcher:registerResponder', function(id)
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    addResponderToIncident(id, getPlayerName(src))
    pushHistory(('Důstojník %s se přidal k upozornění %s'):format(getPlayerName(src), id))
    syncDispatch(-1)
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
            pushHistory(('Žádost o zálohu pro %s: %s | by %s'):format(incident.title, incident.backupType, getPlayerName(src)))
            break
        end
    end

    notifyAll('Byla vyžádána záloha pro aktivní incident.')
    syncDispatch(-1)
end)

RegisterNetEvent('ak4y_dispatcher:panicButton', function()
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    local name = getPlayerName(src)
    local message = ('Nouzové varování: %s aktivoval panický tlačítko.'):format(name)
    pushHistory(message)
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
        x = tonumber(coords.x) or 0.0,
        y = tonumber(coords.y) or 0.0,
        z = tonumber(coords.z) or 0.0,
        radius = tonumber(radius) or 100.0,
        createdBy = getPlayerName(src)
    }

    table.insert(blockedAreas, area)
    pushHistory(('Oblast zablokována pro nové upozornění: %s m | by %s'):format(area.radius, getPlayerName(src)))
    TriggerClientEvent('esx:showNotification', src, 'Oblast byla zablokována pro nové události.')
    syncDispatch(-1)
end)

RegisterNetEvent('ak4y_dispatcher:clearHistory', function()
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    incidents = {}
    blockedAreas = {}
    history = {}
    pushHistory(('Historie protokolů byla vymazána důstojníkem %s'):format(getPlayerName(src)))
    TriggerClientEvent('esx:showNotification', src, 'Historie protokolů byla vymazána.')
    syncDispatch(-1)
end)

RegisterNetEvent('ak4y_dispatcher:removeIncident', function(id)
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    for i = #incidents, 1, -1 do
        if incidents[i].id == id then
            table.remove(incidents, i)
            pushHistory(('Upozornění %s bylo odstraněno | by %s'):format(id, getPlayerName(src)))
            break
        end
    end

    syncDispatch(-1)
end)

RegisterNetEvent('ak4y_dispatcher:waypointIncident', function(id)
    local src = source
    if not isDispatchAllowed(src) then
        return
    end

    for _, incident in ipairs(incidents) do
        if incident.id == id then
            TriggerClientEvent('ak4y_dispatcher:setWaypoint', src, incident.coords)
            break
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        syncDispatch(-1)
    end
end)
