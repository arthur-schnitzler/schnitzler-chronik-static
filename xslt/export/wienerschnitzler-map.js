// wienerschnitzler-map.js
window.initWienerschnitzlerMap = function () {
  const mapElement = document.getElementById("wienerschnitzler-map");
  if (!mapElement) return;

  const datum = mapElement.getAttribute("data-datum");
  const geojsonUrl = `https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/main/data/editions/geojson/${datum}.geojson`;

  const map = L.map("wienerschnitzler-map").setView([48.2082, 16.3738], 6);
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 18,
    attribution:
      '© <a href="https://www.openstreetmap.org/">OpenStreetMap</a> | Quelle: <a href="https://www.wienerschnitzler.org/tag.html#' +
      encodeURIComponent(datum) +
      '" target="_blank">wienerschnitzler.org</a>',
  }).addTo(map);

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
    })
    .catch((err) => console.error("Fehler beim Laden der GeoJSON-Datei:", err));

  setTimeout(() => map.invalidateSize(), 200);
};
