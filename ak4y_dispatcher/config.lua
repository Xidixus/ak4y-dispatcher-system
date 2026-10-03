Config = {}

Config.DispatchJobs = {
    police = true,
    sheriff = true,
    ambulance = true
}

Config.RequiredItem = 'dispatch_card'
Config.RequiredItemBackup = 'mdt_access'
Config.DispatchKey = 'F7'
Config.UseCommand = true
Config.ShowNotifications = true

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

Config.Priorities = {
    low = 'Nízká',
    medium = 'Střední',
    high = 'Vysoká'
}

Config.IncidentStatuses = {
    open = 'Otevřeno',
    inprogress = 'Řeší se',
    closed = 'Uzavřeno',
    solved = 'Vyřešeno'
}

Config.BlockedAreas = {}
