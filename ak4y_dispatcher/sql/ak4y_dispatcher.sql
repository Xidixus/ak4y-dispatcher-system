# AK4Y Dispatcher ESX

Pokročilý dispečerský systém pro FiveM ESX v češtině.

## Funkce
- MDT řídicí panel
- Live seznam upozornění
- Priorita a stav incidentu
- Zálohování a panický tlačítko
- Blokování oblasti pro nová upozornění
- Záznam historie a protokolů
- Nastavení waypointu na lokaci incidentu
- Přístup přes ESX job nebo item

## Instalace
1. Vložte složku `ak4y_dispatcher` do adresáře `resources`.
2. Importujte SQL soubor do databáze.
3. Ujistěte se, že máte nainstalovaný ESX framework.
4. Spusťte server.
5. Otevřete MDT pomocí:
   - `/dispatcher`
   - `F7`

## Povolení přístupu
Pro přístup k panelu musí mít hráč buď:
- pracovní náplň `police`, `sheriff`, `ambulance` nebo `fib`
- nebo item `dispatch_card`
- nebo item `mdt_access`

## Itemy
- `dispatch_card` — Policejní MDT karta
- `mdt_access` — Přístup k dispečerskému systému

## Poznámka
Tento balíček je navržen jako pokročilý základ pro policejní dispečerský systém v FiveM ESX. Můžete jej dále rozšiřovat o 911 hovory, mapové markery, GPS waypointy, databázové záznamy a podrobnější MDT rozhraní.
