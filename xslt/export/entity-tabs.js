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
        });
    });
    // Relationen-Subnavigation (Typ-Tabs: Personen/Werke/Orte/…)
    document.querySelectorAll('.rel-subnav').forEach(function (subnav) {
        var container = subnav.parentElement;
        subnav.addEventListener('click', function (e) {
            var btn = e.target.closest('.rel-subnav-btn');
            if (!btn) return;
            var type = btn.getAttribute('data-rel-type');
            subnav.querySelectorAll('.rel-subnav-btn').forEach(function (b) {
                b.classList.remove('active');
            });
            btn.classList.add('active');
            container.querySelectorAll('.rel-section').forEach(function (s) {
                s.classList.toggle('active', s.getAttribute('data-rel-type') === type);
            });
        });
    });
    // Leaflet-Karte in der Sidebar sofort initialisieren
    if (typeof window.initEntityMap === 'function') {
        window.initEntityMap();
    }
    // Mentions-Chart: Vollbild-Umschaltung
    document.querySelectorAll('#mentions-chart').forEach(function (chart) {
        function toggle(on) {
            var active = typeof on === 'boolean'
                ? on
                : !chart.classList.contains('is-fullscreen');
            chart.classList.toggle('is-fullscreen', active);
            document.body.classList.toggle('mentions-chart-fs-open', active);
        }
        chart.addEventListener('click', function (e) {
            if (e.target.closest('.mentions-chart-fs-btn') ||
                e.target.closest('svg')) {
                toggle();
            }
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && chart.classList.contains('is-fullscreen')) {
                toggle(false);
            }
        });
    });
});
