# AK4Y Dispatcher ESX

Kompletní dispečerský systém pro FiveM ESX v češtině.

## Co obsahuje
- MDT panel s live upozorněními
- Správa priorit a stavů incidentů
- Záložní požadavky a panické tlačítko
- Blokování oblastí pro nová upozornění
- Logování historie a vymazání protokolů
- ESX itemy
- Přístup přes job nebo item

## Instalace
1. Vložte složku `ak4y_dispatcher` do adresáře `resources`.
2. Importujte SQL soubor:
   - `ak4y_dispatcher/sql/ak4y_dispatcher.sql`
3. Ujistěte se, že máte nainstalovaný ESX framework.
4. Spusťte server a do hry použijte:
   - `F7` nebo příkaz `/dispatcher`
5. Pro přístup k panelu musí mít hráč:
   - policejní práci (`police` / `sheriff`), nebo
   - item `dispatch_card` nebo `mdt_access`

## Itemy
- `dispatch_card` = Policejní MDT karta
- `mdt_access` = Přístup k dispečerskému systému

## Poznámka
Jedná se o plně funkční základ dispečerského systému s UI a server-side logikou. Pokud chceš, můžu v dalším kroku rozšířit script o:
- přesný mapový marker a GPS waypoint
- nové policejní kanály a oznámení
- přesné záznamy do databáze
- integraci s policejními MDT funkcemi a 911 hovory
