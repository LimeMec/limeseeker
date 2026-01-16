# LimeSeeker | Linux & Network Vulnerability Scanner 
![Version](https://img.shields.io/badge/version-1.4.0-green)


LimeSeeker är ett modulbaserat skript för rekognisering och identifiering av kritiska sårbarheter och föråldrade tjänster i Linux-system och nätverk.

## Grundidé

Projektets mål är att ge en tydlig bild av systemets status, där fokus ligger på att identifiera säkerhetsbrister framför aktiv exploatering. 
LimeSeeker är utformat för att svara på frågan:
> *"Hur säkert är det här systemet egentligen?"*

## Förhandsvisning

**Demo video (YouTube):**  [LimeSeeker v1.4.O](https://youtu.be/Q4fT4tBuXBA?si=5pvbSf_j38Bp7CmL)

<a href="https://youtu.be/Q4fT4tBuXBA?si=5pvbSf_j38Bp7CmL">
  <img src="https://img.youtube.com/vi/Q4fT4tBuXBA/maxresdefault.jpg" width="1000">
</a>

 
## Projektstruktur
``` limeseeker/
├── limeseeker.sh
├── README.md
|
├── docs/
|      └── modules.md
|
├── lib/
│   ├── colors.sh
│   ├── flags.sh
│   ├── logging.sh
│   ├── menu.sh
│   ├── privileges.sh
│   ├── ui.sh
│   └── utils.sh
|
├── modules/
│   ├── local_inventory.sh
│   ├── local_security.sh
│   ├── network_vulnerability.sh
│   └── wifi_discovery.sh
└── reports/
```
## Flödesschema

<a href="https://github.com/LimeMec/limeseeker/tree/main/docs/execution-flow.png">
  <img src="https://raw.githubusercontent.com/LimeMec/limeseeker/main/docs/execution-flow.png" width="500">

## Funktion

LimeSeeker är avsett för att:

-  **Samla in** system- och hårdvaruinformation
-  Bedömning av säkerhetsstatus
-  Identifiera och analysera aktiva enheter
-  Analysera nätverksmiljöer inom tillåtna ramar
-  Logga resultat till rapportfil

## Designfilosofi

Skriptet är uppbyggt av självständiga moduler och är terminalbaserat för Linux. Det är designat med fokus på transparens, säker körning och spårbarhet.

*   **Transparens:** Alla kontroller som utförs är tydliga för användaren. Inga dolda handlingar, bakgrundsprocesser eller automatiska systemändringar förekommer.
*   **Medveten säkerhetsdesign:** Skriptet efterfrågar endast *sudo*-rättigheter när det är absolut nödvändigt och ser till att tillfälliga rättigheter stängs ner så fort momentet är klart.
*   **Robusthet och felhantering:** Förhindrar oavsiktlig privilegieeskalering och blockerar försök att pausa (`Ctrl+z`), avbryta (`Ctrl+c`) eller avsluta (`Ctrl+d`) på ett osäkert sätt. Ogiltiga val fångas upp och skriptet avslutas alltid säkert.
*   **Loggning och spårbarhet:** En central loggfil skapas per körning med

## Systemkrav

*   **OS:** Linux (testad på Debian/Kali-baserade system)
*   **Shell:** Bash 4+
*   **Rättigheter:** Sudo-behörighet krävs för vissa moduler.
*   **Verktyg som används:**
    *   `ip`, `ss`, `find`, `awk` (Standardverktyg)
    *   [nmap](nmap.org) (för nätverksmoduler)
    *   [searchsploit](www.exploit-db.com) (för CVE-kontroller)

## Installation

```bash
git clone https://github.com/LimeMec/limeseeker.git
cd limeseeker
chmod +x limeseeker.sh
```

## Användning

Starta verktyget som vanlig användare.
```
./limeseeker.sh
```
LimeSeeker kommer automatiskt be om sudo-lösenord.


## Flaggor

 -  -h, --help &emsp; &emsp; &emsp;  &emsp; &emsp; &ensp; Visa hjälpinformation och avsluta
-  -a, --about &emsp; &emsp; &emsp; &emsp; &emsp; &nbsp;Visa syfte och designfilosofi
-  -v, --version &emsp; &emsp; &emsp;  &emsp; &ensp; Visa version och författare
-  -l, --legal &emsp; &emsp; &emsp; &emsp;  &emsp;  &ensp; Visa juridisk information och användaransvar
-  -m, --modules &emsp; &emsp; &emsp;  &ensp; Lista tillgängliga moduler
-  -n,  --no-log &emsp; &emsp; &emsp;  &emsp; &ensp; Kör utan att skapa loggfil
 

## Moduler

- **Local Inventory:** Rekognisering av lokala systemresurser.
- **Local Security:** Kontroll av lokala sårbarheter och konfigurationer.
- **Network Vulnerability:** Identifiering av brister i nätverkstjänster.
- **WiFi Discovery:** Skanning av trådlösa nätverk.

Mer detaljerad beskrivning över modulerna finns i  [modules.md](https://github.com/LimeMec/limeseeker/tree/main/docs/modules.md)

## Loggning

Alla analyser loggas till en rapportfil som sparas i  mappen reports/ .
Mappen skapas  automatiskt när skriptet körts första gången.

Loggning kan inaktiveras med:
```
./limeseeker.sh -n 
``` 

## Säkerhet & juridik

LimeSeeker är **inte** ett exploateringsverktyg.

Det utför inga attacker, ingen privilegieeskalering och inga systemändringar.

Användaren är ensam ansvarig för att säkerställa att analyser endast utförs på  
system och nätverk som användaren äger eller har uttryckligt tillstånd att testa.



## Framtida utveckling 

<b>Planerade förbättringar:</b>
-  Rensa loggfil från ANSI-färgkoder och ej printbara tecken
-  Slå på/av loggning även inne i menyn
-  Möjlighet att köra skript utan *sudo* och i en anpassad miljö för detta

<b>Framtida funktioner:</b>
 -  Stöd för flera miljöer
 - Fördjupad analysmodul för trådlösa nätverk
 - Olika intensitetsnivåer för nätverksskanning för minimera brus.
 
---
Trevligt att just du kikad in här!  
//LimeMec, Markus Carlsson
