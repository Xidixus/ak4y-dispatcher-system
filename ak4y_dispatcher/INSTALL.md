# AK4Y Dispatcher ESX - Kompletní Install Guide

## 1. Stažení a Instalace

### Krok 1: Klonuj repozitář
```bash
cd resources
git clone https://github.com/Xidixus/ak4y-dispatcher-system.git ak4y_dispatcher
```

Nebo ručně:
1. Stáhni ZIP z repozitáře
2. Rozbal do `resources/ak4y_dispatcher`

### Krok 2: Přidej do server.cfg
```cfg
ensure ak4y_dispatcher
```

### Krok 3: Importuj SQL
Otevři phpMyAdmin nebo MySQL klient a spusť:
```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('dispatch_card', 'Policejní MDT karta', 0, 0, 1),
('mdt_access', 'Přístup k dispečerskému systému', 0, 0, 1);

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES
('police', 'Policejní složka', 0),
('sheriff', 'Sheriff', 0),
('ambulance', 'Záchranná služba', 0),
('fib', 'FBI', 0);
```

### Krok 4: Spusť server
```bash
# Windows
run.cmd

# Linux
./run.sh
```

## 2. Použití v Hře

### Otevření MDT
- Klávesa: `F7`
- Příkaz: `/dispatcher`

### Kdo má přístup
- Hráči s jobem: `police`, `sheriff`, `ambulance`, `fib`
- Hráči s itemem: `dispatch_card` nebo `mdt_access`
- Admini

### Hlavní Funkce
1. **Nové Upozornění** - Vytvoř nový incident
2. **Přiřaď si** - Připoj se k incidentu
3. **Změň Prioritu** - Nízká/Střední/Vysoká
4. **Změň Stav** - Otevřeno/Řeší se/Uzavřeno/Vyřešeno
5. **Waypoint** - Nastav GPS do místa incidentu
6. **Zálohování** - Vyžádej si zálohu
7. **Panické Tlačítko** - Nouzové varování

## 3. Konfiguruje pro Svůj Server

### Soubor: `config.lua`

```lua
-- Změň typy incidentů podle tvého serveru
Config.IncidentTypes = {
    'Přestupková událost',
    'Bojový incident',
    'Autonehoda',
    'Přepadení',
    'Drogová aktivita',
    'Násilný trestný čin',
    'Ochrana civilistů',
    'Ostatní'
}

-- Přidej nové joby (police, sheriff, ambulance, fib)
Config.DispatchJobs = {
    police = true,      -- Zapnout/Vypnout
    sheriff = true,
    ambulance = true,
    fib = true,
    -- police_chief = true,  -- Pokud máš custom joby
}

-- Změň klávesar
Config.DispatchKey = 'F7'  -- F1-F12, PAGEUP, PAGEDOWN, atd.

-- Změň itemy (pokud máš vlastní)
Config.RequiredItem = 'dispatch_card'      -- Item pro přístup
Config.RequiredItemBackup = 'mdt_access'   -- Backup item
```

### Přidej Custom Joby

Jestli máš např. `police_chief`, `detective`, atd., přidej je do `config.lua`:

```lua
Config.DispatchJobs = {
    police = true,
    police_chief = true,
    detective = true,
    sheriff = true,
    fib = true,
    ambulance = true,
    mechanic = false  -- Vypnuto
}
```

A do SQL:
```sql
INSERT INTO `jobs` VALUES ('police_chief', 'Náčelník Policie', 0);
INSERT INTO `jobs` VALUES ('detective', 'Detektiv', 0);
```

## 4. 911 Systém (Volá do Dispatcheru)

### Pokud máš existující 911 script

Pridej do tvého 911 scriptu callback:

```lua
-- V tvojém emergency/911 scriptu
TriggerEvent('ak4y_dispatcher:emergency911', {
    title = 'Volání 911',
    type = '911',
    priority = 'high',
    coords = coordsFromCaller,
    notes = messageFromCaller,
    emergency = true
})
```

### Jednoduchý 911 příkaz

Přidej do `client/main.lua`:

```lua
RegisterCommand('911', function(source, args, rawCommand)
    local coords = getPlayerCoords()
    local message = table.concat(args, ' ')

    TriggerServerEvent('ak4y_dispatcher:create911Call', {
        title = 'Volání 911',
        type = '911',
        priority = 'high',
        coords = coords,
        notes = message or 'Nouzové volání',
        emergency = true
    })

    showNotification('Volání 911 odesláno dispečerům!')
end, false)
```

A do `server/main.lua`:

```lua
RegisterNetEvent('ak4y_dispatcher:create911Call', function(data)
    -- Ověř, že to není admin zneužívající
    local coords = GetEntityCoords(GetPlayerPed(source))
    
    -- Vytvoř incident z volání
    TriggerEvent('ak4y_dispatcher:createIncident', source, data)
end)
```

## 5. GPS/Waypoint

### Automaticky po Kliknutí

Když klikneš na "Waypoint" v MDT panelu:
- Vypočítá se vzdálenost
- Nastavi se GPS do místa
- Zobrazí se notifikace

### Manuální Nastavení

```lua
-- Někde v tvojím scriptu
local coords = {x = 425.5, y = -981.2, z = 29.4}
SetNewWaypoint(coords.x, coords.y)
```

## 6. Mapové Markery

Přidej do `client/main.lua`:

```lua
local markers = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isOpen then
            for _, incident in ipairs(dispatchData.incidents or {}) do
                if incident.coords then
                    DrawMarker(
                        1,  -- Marker typ (1 = čtverec)
                        incident.coords.x,
                        incident.coords.y,
                        incident.coords.z,
                        0, 0, 0,  -- Rotace
                        0, 0, 0,  -- Směr
                        2.0, 2.0, 2.0,  -- Velikost
                        255, 0, 0, 200,  -- Barva RGB (červená)
                        false, false, 2, false, nil, nil, false
                    )
                    
                    -- Přidej text
                    DrawText3D(
                        incident.coords.x,
                        incident.coords.y,
                        incident.coords.z + 1.0,
                        incident.title
                    )
                end
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        BeginTextCommandDisplayText('STRING')
        AddTextComponentString(text)
        SetTextScale(0.35, 0.35)
        DrawText(_x - GetTextWidth(text) / 2, _y)
        EndTextCommandDisplayText(0, 0)
    end
end
```

## 7. Databázové Uložení Incidentů

Přidej do `server/main.lua`:

```lua
local function saveIncidentToDatabase(incident)
    MySQL.Async.execute(
        'INSERT INTO ak4y_incidents (id, title, type, priority, coords, created_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {incident.id, incident.title, incident.type, incident.priority, json.encode(incident.coords), incident.createdBy, incident.createdAt},
        function(rowsChanged)
            print('^2[Dispatcher] Incident uložen do databáze: ' .. incident.id .. '^7')
        end
    )
end

-- V RegisterNetEvent('ak4y_dispatcher:createIncident'...
-- Přidej:
saveIncidentToDatabase(incident)
```

A vytvoř SQL tabulku:

```sql
CREATE TABLE `ak4y_incidents` (
    `id` VARCHAR(50) PRIMARY KEY,
    `title` VARCHAR(255),
    `type` VARCHAR(50),
    `priority` VARCHAR(20),
    `status` VARCHAR(20),
    `coords` LONGTEXT,
    `created_by` VARCHAR(255),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 8. Restart Scriptu

```bash
# V konzoli serveru
refresh ak4y_dispatcher
# nebo
restart ak4y_dispatcher
```

## 9. Řešení Problémů

### MDT se Neotevírá
- Zkontroluj, že máš job: `police`, `sheriff`, `ambulance`, `fib`
- Nebo měj item: `dispatch_card`
- Zkontroluj console na errory: `npm run watch` nebo `tail -f console.log`

### Incidenty se Neukládají
- Zkontroluj SQL import
- Zkontroluj MySQL connection v `server.cfg`

### NUI Panel je Černý/Prázdný
- Restartuj resource: `/restart ak4y_dispatcher`
- Zkontroluj `html/` soubory

### Waypoint se Nenastavuje
- Zkontroluj, že máš správné souřadnice
- Zkontroluj chat na errory

## 10. Dodatečné Nastavení

### Změň Barvy Priorit

V `html/style.css`:

```css
.priority-low { background: rgba(90, 210, 120, 0.18); color: #98edb0; }    /* Zelená */
.priority-medium { background: rgba(255, 198, 73, 0.18); color: #ffd66d; } /* Žlutá */
.priority-high { background: rgba(255, 95, 95, 0.18); color: #ffafaf; }   /* Červená */
```

### Přidej Zvuky Notifikacím

V `client/main.lua`:

```lua
local function playNotificationSound()
    PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
end

-- V RegisterNetEvent('ak4y_dispatcher:openMdtClient'...
playNotificationSound()
```

## 11. Bezpečnost

- Admini vždy mají přístup
- Kontroluj permissions v config.lua
- Logguj veškeré akce (v history)
- Enkryptuj citlivá data v databázi

## 12. Hotový Balíček

Vše je již připraveno v:
```
resources/ak4y_dispatcher/
├── fxmanifest.lua
├── config.lua
├── client/main.lua
├── server/main.lua
├── html/
│   ├── index.html
│   ├── style.css
│   └── app.js
└── sql/ak4y_dispatcher.sql
```

**Stačí:** Klonuj, importuj SQL, přidej do server.cfg, restartuj.

---

**Máš-li otázky, napiš do GitHub issues nebo se obrať přímo.**
