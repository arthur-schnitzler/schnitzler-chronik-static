# Entities-Layout: Zweispaltiges Layout mit Tabs

Dieses Verzeichnis (`xslt/export/` in `schnitzler-chronik-static`) ist die
kanonische Quelle fuer das Entities-Layout. Schwester-Projekte (z. B.
`schnitzler-briefe-static`) synchronisieren die Dateien von hier nach
GitHub-raw.

## Dateien

| Datei | Zweck | Ziel im Downstream-Projekt |
|---|---|---|
| `entities.xsl` | Haupt-Stylesheet fuer Entitaeten-Seiten | `xslt/partials/entities.xsl` |
| `entities-setup.xsl` | Lokale Variablen, Relations-Index, Vokabular | `xslt/partials/entities-setup.xsl` |
| `relations.json` | Vokabular fuer Relations-Labels | `xslt/partials/relations.json` |
| `entities.css` | CSS-Layout (Grid, Sidebar, Tabs) | `html/css/entities.css` |
| `entity-tabs.js` | Tab-Umschaltung (vanilla JS) | `html/js/entity-tabs.js` |
| `fetch_relations.py` | holt und filtert `relations.csv` von PMB | `xslt/export/fetch_relations.py` |
| `check_entities_xsl.py` | synchronisiert die ersten fuenf Dateien vom Upstream | `<projekt-root>/check_entities_xsl.py` |

## Installation

### Variante A: automatisch per `check_entities_xsl.py` (empfohlen)

`check_entities_xsl.py` liegt im Downstream-Projekt-Root und laedt die fuenf
oben genannten Asset-Dateien via GitHub-raw nach:

```
python3 check_entities_xsl.py
```

Das Script ist idempotent: es vergleicht SHA-256 und schreibt nur, wenn sich
etwas geaendert hat. Fuer `.xsl`-Dateien wird vor dem Ueberschreiben geprueft,
ob der Upstream wohlgeformt ist – bei Parse-Fehlern bleibt der lokale Stand
erhalten, der Build laeuft weiter.

Ablageorte sind im Script fix (`ASSETS`-Tupel). Fehlende Zielordner werden
automatisch angelegt. Konfiguration ist nur durch Editieren der Konstanten
`REMOTE_BASE` und `ASSETS` moeglich.

`fetch_relations.py` wird von `check_entities_xsl.py` **nicht** mitsynchronisiert
und muss einmalig manuell kopiert werden (siehe Variante B).

#### In den Ant-Build einhaengen

Damit jeder Build mit dem aktuellen Upstream laeuft, kann der Sync als Target
vor dem XSLT-Schritt laufen:

```xml
<target name="sync-entities">
    <exec executable="python3" failonerror="false">
        <arg value="check_entities_xsl.py"/>
    </exec>
</target>
```

`failonerror="false"` sorgt dafuer, dass Offline-Builds nicht scheitern.

### Variante B: manuelles Kopieren

```
cp entities.xsl          <projekt>/xslt/partials/entities.xsl
cp entities-setup.xsl    <projekt>/xslt/partials/entities-setup.xsl
cp relations.json        <projekt>/xslt/partials/relations.json
cp entities.css          <projekt>/html/css/entities.css
cp entity-tabs.js        <projekt>/html/js/entity-tabs.js
cp fetch_relations.py    <projekt>/xslt/export/fetch_relations.py
cp check_entities_xsl.py <projekt>/check_entities_xsl.py
```

## Einbindung in `html_head.xsl`

Nach `style.css`:

```xml
<link rel="stylesheet" href="css/entities.css" type="text/css"/>
```

Vor dem schliessenden `</xsl:template>`:

```xml
<script src="js/entity-tabs.js" defer="defer"></script>
```

## Relationen-CSV erzeugen (`fetch_relations.py`)

Vor jedem XSLT-Build muss `data/indices/relations.csv` aktualisiert werden.
Das Script laedt `relations.csv` von PMB und filtert sie auf Relationen,
bei denen mindestens eine Seite in den Projekt-Indizes vorkommt.

```
python3 xslt/export/fetch_relations.py
```

Standardmaessig werden diese Indexdateien durchsucht:

- `data/indices/listperson.xml`
- `data/indices/listplace.xml`
- `data/indices/listorg.xml`
- `data/indices/listwork.xml`
- `data/indices/listbibl.xml`
- `data/editions/listevent.xml`

Fehlt in einem Projekt eine dieser Dateien, wird sie stillschweigend
uebersprungen. Zusaetzliche Indizes lassen sich per `--index` anhaengen,
oder die Standardliste komplett mit `--only-index` ersetzen:

```
python3 xslt/export/fetch_relations.py \
    --output data/indices/relations.csv \
    --index data/indices/listbibl-extra.xml
```

### In den Ant-Build einhaengen

```xml
<target name="fetch-relations">
    <exec executable="python3" failonerror="true">
        <arg value="xslt/export/fetch_relations.py"/>
    </exec>
</target>
```

Das Haupt-Target macht man dann von `sync-entities` und `fetch-relations`
abhaengig (in dieser Reihenfolge).

## Voraussetzungen

- Bootstrap 5 (bereits vorhanden)
- Leaflet (nur fuer Ort-Entitaeten, wird im XSL geladen)
- Python 3 (fuer `fetch_relations.py` und `check_entities_xsl.py`, jeweils nur Standard-Lib)

## Verhalten

- Desktop (>992px): Zweispaltiges Grid -- Steckbrief links (sticky), Tabs rechts
- Mobil (<=992px): Einspaltig, Steckbrief oben, Tabs darunter
- Tabs: Relationen, Erwaehnungen, bei Orten zusaetzlich Karte
- Leaflet-Karte wird lazy initialisiert (erst beim Klick auf den Karte-Tab)
