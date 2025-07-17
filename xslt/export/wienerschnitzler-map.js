window.initWienerschnitzlerMap = function () {
    const mapElement = document.getElementById("wienerschnitzler-map");
    if (!mapElement) {
        console.error("Map-Element nicht gefunden!");
        return;
    }
    
    const datum = mapElement.getAttribute("data-datum");
    const geojsonUrl = `https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/main/data/editions/geojson/${datum}.geojson`;
    
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
    
    // GeoJSON laden
    fetch(geojsonUrl)
        .then((response) => response.json())
        .then((data) => {
            const layer = L.geoJSON(data, {
                onEachFeature: function (feature, layer) {
                    if (feature.properties && feature.properties.name) {
                        layer.bindPopup(feature.properties.name);
                    }
                },
            }).addTo(map);
            
            map.fitBounds(layer.getBounds());
            // Nochmals invalidateSize nach dem Laden der Daten
            setTimeout(() => map.invalidateSize(), 100);
        })
        .catch((err) => console.error("Fehler beim Laden der GeoJSON-Datei:", err));
};