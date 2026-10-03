Config = {}

Config.DispatchJobs = {
    police = true,
    sheriff = true,
    ambulance = true,
    fib = true
}

Config.DispatchKey = 'F7'
Config.RequiredItem = 'dispatch_card'
Config.RequiredItemBackup = 'mdt_access'
Config.EnableCommand = true
Config.ShowNotifications = true
Config.MaxHistoryEntries = 200

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

Config.EmergencyServices = {
    ambulance = 'Záchranná služba',
    mechanic = 'Odtah',
    sheriff = 'Sheriff',
    police = 'Police',
    backup = 'Záloha'
}

Config.BlockedAreas = {}
