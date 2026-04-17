/* entity-tabs.js – Tab-Umschaltung auf Entitätsseiten */
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.entity-tabs').forEach(function (nav) {
        nav.addEventListener('click', function (e) {
            var btn = e.target.closest('.entity-tab-btn');
            if (!btn) return;
            var tabId = btn.getAttribute('data-tab');
            var container = nav.parentElement;
            // Buttons
            nav.querySelectorAll('.entity-tab-btn').forEach(function (b) {
                b.classList.remove('active');
            });
            btn.classList.add('active');
            // Panels
            container.querySelectorAll('.entity-tab-panel').forEach(function (p) {
                p.classList.remove('active');
            });
            var panel = container.querySelector('#' + tabId);
            if (panel) panel.classList.add('active');
            // Leaflet-Karte: lazy init + invalidateSize
            if (tabId === 'tab-karte') {
                if (typeof window.initEntityMap === 'function') {
                    window.initEntityMap();
                }
                if (window.mymap) {
                    setTimeout(function () { window.mymap.invalidateSize(); }, 150);
                }
            }
        });
    });
});
