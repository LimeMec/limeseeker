# LimeSeeker – Moduler

Detta dokument beskriver de moduler som ingår i LimeSeeker samt vad varje modul gör.  

---

## Local Inventory

Local Inventory samlar in detaljerad information om det lokala systemet för att skapa en tydlig överblick.

### Innehåll

- BIOS / Firmware
- Operativsystem 
- Kernel-version
- CPU
- GPU
- Minne
- Lagring

### Syfte

Syftet med Local Inventory är att ge en helhetsbild av systemets tillstånd samt hjälpa till att identifiera oväntade, okända eller föråldrade komponenter.

---

## Local Security

Local Security utför vanliga säkerhetsrelaterade kontroller på det lokala systemet.

### Innehåll

- Kontroll av paketuppdateringsstatus
- Identifiering av avvikande fil- och katalogrättigheter
- Sökning efter SUID/SGID-binaries
- Identifiering av världsskrivbara filer och kataloger
- Upptäckt av vanliga lokala felkonfigurationer

### Syfte

Syftet är att identifiera lokala svagheter som potentiellt kan utnyttjas för privilegieeskalering, lateral rörelse eller persistens på systemet.

---

## Network Vulnerability

Network Vulnerability analyserar nätverksrelaterad exponering och identifierar potentiella sårbarheter.

### Innehåll

- Identifiering av öppna portar
- Upptäckt av lyssnande tjänster
- Grundläggande nätverksanalys
- Identifiering av onödigt exponerade tjänster

### Syfte

Syftet är att ge en överblick över systemets nätverksexponering och upptäcka tjänster som kan utgöra en säkerhetsrisk.

---

## Wireless Discovery

Wireless Discovery identifierar och analyserar trådlösa nätverk i närheten av systemet.

### Innehåll

- Upptäckt av synliga WiFi-nätverk
- Identifiering av krypteringstyper
- Signalstyrka och närhetsbedömning
- Grundläggande riskindikationer

### Syfte

Syftet är att ge en överblick över den trådlösa miljön och hjälpa till att identifiera osäkra eller potentiellt riskfyllda trådlösa nätverk.

---

## Allmänt om moduler

- Moduler kan köras enskilt eller i kombination
- Vissa moduler kräver sudo-behörighet
- Alla resultat kan loggas till rapportfiler
- Inga moduler gör automatiska ändringar i systemet

Sudo-behörighet begärs och rensas automatiskt vid avslut.

---
//LimeMec, Markus Carlsson
