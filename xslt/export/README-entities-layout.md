# Entities-Layout: Zweispaltiges Layout mit Tabs

## Dateien

| Datei | Zweck | Ziel im Projekt |
|---|---|---|
| `entities.css` | CSS-Layout (Grid, Sidebar, Tabs) | `html/css/entities.css` |
| `entity-tabs.js` | Tab-Umschaltung (vanilla JS) | `html/js/entity-tabs.js` |

## Einbindung

### 1. Dateien kopieren

```
cp entities.css   <projekt>/html/css/entities.css
cp entity-tabs.js <projekt>/html/js/entity-tabs.js
```

### 2. Im `<head>` einbinden

In der `html_head.xsl` des Projekts (nach `style.css`):

```xml
<link rel="stylesheet" href="css/entities.css" type="text/css"/>
```

Und vor dem schliessenden `</xsl:template>`:

```xml
<script src="js/entity-tabs.js" defer="defer"></script>
```

### 3. Voraussetzungen

- Bootstrap 5 (bereits vorhanden)
- Leaflet (nur fuer Ort-Entitaeten, wird im XSL geladen)

## Verhalten

- Desktop (>992px): Zweispaltiges Grid -- Steckbrief links (sticky), Tabs rechts
- Mobil (<=992px): Einspaltig, Steckbrief oben, Tabs darunter
- Tabs: Relationen, Erwaehnungen, bei Orten zusaetzlich Karte
- Leaflet-Karte wird lazy initialisiert (erst beim Klick auf den Karte-Tab)
