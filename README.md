
# Study Scripts: IT- och Cybersecurity @ Frans Schartus Handelsinstitut:

Min samling av skript som jag skapat under min utbildning "IT- och Cybersäkerhet".



## Innehåll:

Repo


## Kodbeskrivning:

**lime-scanner.sh**  
Ett skript som inventerar och sammanställer datorns specifikationer, både hårdvara och mjukvara. 
Inventeringen utförs endast av de standardpaket som redan finns förinstallerade på de allra flesta Linux-distributioner.
Skriptet tar även hänsyn till användare och kan utföra sin inventering  utan förhöjda privilegier, inget *sudo*-kommando behövs. 

Följande scannas:
- Operativsystem
- Grafikkort
- Processor
- RAM-minne
- Lagring
- Nätverk



## Användning:

För att köra skripten (.sh-fil) navigera till mappen.

**Få skriptet körbart (för .sh-filer):**
```bash
chmod +x skript_namn.sh
```
**Köra skriptet:**
```bash
./skript_namn.sh
```


## Krav:
- [Python 3.x](www.python.org)
- Bash (finns inbyggt i Linux/macOS, Windows kan använda WSL eller Git Bash)



Trevligt att just du kikad in här!
//LimeMec, Markus Carlsson
