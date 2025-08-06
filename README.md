# Arthur Schnitzler Chronik

Eine statische Website, die chronologische Daten zu Arthur Schnitzlers Leben und Werk präsentiert.

## Übersicht

* **Website** basiert auf Daten aus dem Repository [schnitzler-chronik-data](https://github.com/arthur-schnitzler/schnitzler-chronik-data/)
* **Build-System** mit [DSE-Static-Cookiecutter](https://github.com/acdh-oeaw/dse-static-cookiecutter)
* **Output**: Statische HTML-Website im `./html` Ordner
* **Export-Plugin**: Zusätzliche Funktionalität im `./xslt/export/` Ordner

## Architektur

Das Repository generiert eine statische Website aus TEI-XML Quelldaten:

- **Quelldaten**: Werden von `schnitzler-chronik-data` in `./data/` heruntergeladen
- **XSLT-Transformationen**: Konvertieren XML zu HTML (siehe `./xslt/`)
- **Python-Scripts**: Generieren JavaScript-Datenfiles für interaktive Features
- **Ant Build-System**: Orchestriert den gesamten Build-Prozess

## Voraussetzungen

- **Java 11+** (für Saxon XSLT-Processor)
- **Ant** (Build-System)
- **Python 3.8+** mit Dependencies aus `requirements.txt`

## Build-Prozess

1. **Daten abrufen**:
   ```bash
   ./fetch_data.sh
   ```

2. **JavaScript-Daten generieren**:
   ```bash
   python make_calendar_data.py
   python make_ts_index.py
   ```

3. **Website bauen**:
   ```bash
   ant
   ```

4. **Lokalen Server starten** (optional):
   ```bash
   cd html && python -m http.server 8000
   ```

## Verzeichnisstruktur

```
├── data/           # Temporäre Quelldaten (nicht versioniert)
├── html/           # Generierte Website (nicht versioniert)
├── xslt/           # XSLT-Transformationen
│   ├── export/     # Export-Plugin
│   └── partials/   # Wiederverwendbare XSLT-Templates
├── build.xml       # Ant Build-Konfiguration
├── fetch_data.sh   # Script zum Abrufen der Quelldaten
└── make_*.py       # Python-Scripts für Datenverarbeitung
```

## Entwicklung

- **Lokale Entwicklung**: `./data/` wird für Debugging und lokale Tests verwendet
- **Website-Output**: `./html/` enthält die generierte Website
- **XSLT-Entwicklung**: Änderungen in `./xslt/` erfordern einen Rebuild mit `ant`

## Export-Plugin

Das `./xslt/export/` Verzeichnis stellt zusätzliche Transformationen für externe Systeme zur Verfügung.
