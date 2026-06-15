window.initWienerschnitzlerMap = function () {
    const mapElement = document.getElementById("wienerschnitzler-map");
    if (!mapElement) {
        console.error("Map-Element nicht gefunden!");
        return;
    }
    
    const datum = mapElement.getAttribute("data-datum");
    // Daten liegen seit Juni 2026 auf dem Branch "data" und sind nach
    // Jahresbündeln gruppiert: geojson/days/<jahr>.json enthält ein Objekt
    // mit einer FeatureCollection pro belegtem Tag (Schlüssel = "YYYY-MM-DD").
    const jahr = datum.slice(0, 4);
    const geojsonUrl = `https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/data/data/editions/geojson/days/${jahr}.json`;

    // Map initialisieren
    const map = L.map("wienerschnitzler-map").setView([48.2082, 16.3738], 6);
    
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom: 18,
        attribution: '© <a href="https://www.openstreetmap.org/">OpenStreetMap</a> | Quelle: <a href="https://www.wienerschnitzler.org/tag.html#' +
            encodeURIComponent(datum) + '" target="_blank">wienerschnitzler.org</a>',
    }).addTo(map);
    
    // Mehrfache invalidateSize() Aufrufe für bessere Kompatibilität
    setTimeout(() => {
        map.invalidateSize();
        console.log('Map invalidateSize() aufgerufen');
    }, 100);
    
    setTimeout(() => {
        map.invalidateSize();
    }, 300);
    
    // GeoJSON laden: Jahresbündel holen und die FeatureCollection des Tages herauslösen
    fetch(geojsonUrl)
        .then((response) => response.json())
        .then((bundle) => {
            const data = bundle[datum];
            if (!data || !data.features || data.features.length === 0) {
                console.warn("Keine Aufenthaltsdaten für", datum);
                return;
            }
            const layer = L.geoJSON(data, {
                onEachFeature: function (feature, layer) {
                    const props = feature.properties || {};
                    const label = props.title || props.name;
                    if (label) {
                        layer.bindPopup(label);
                    }
                },
            }).addTo(map);

            map.fitBounds(layer.getBounds());
            // Nochmals invalidateSize nach dem Laden der Daten
            setTimeout(() => map.invalidateSize(), 100);
        })
        .catch((err) => console.error("Fehler beim Laden der GeoJSON-Datei:", err));
};