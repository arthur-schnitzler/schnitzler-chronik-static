/**
 * SimpleCalendar – Kalender der Schnitzler-Chronik
 *
 * Ansichten: Leben (Heatmap über die gesamte Laufzeit), Jahr, Monat, Woche.
 * Tagesdetails öffnen sich in einem seitlichen Drawer mit Links auf die
 * jeweiligen Quellen und die Tagesseite. Kategorien (Farben und Beschriftungen)
 * kommen aus js-data/categoryColors.json und bleiben unverändert.
 */

class SimpleCalendar {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId);
    this.events = options.dataSource || [];

    this.eventCategories = {};   // category -> color (aus categoryColors.json)
    this.categoryLabels = {};    // category -> caption
    this.categoryOrder = [];     // Reihenfolge wie in categoryColors.json
    this.enabledCategories = new Set();

    this.monthNames = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
    this.dayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    this.dayNamesLong = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag'];

    this.currentView = 'year';
    this.currentYear = options.startYear || 1900;
    this.currentMonth = 0;
    this.currentWeek = 1;
    this.selectedKey = null;
    this.drawerOpen = false;

    this.initialized = this.init();
  }

  async init() {
    this.buildIndexes();
    await this.loadCategoryColors();
    this.loadStateFromURL();
    this.addStyles();
    this.createStructure();
    this.render();
  }

  buildIndexes() {
    this.byDate = new Map();
    this.monthAgg = new Map();
    const years = new Set();
    this.events.forEach((e) => {
      const key = e.startDate;
      if (!key) return;
      if (!this.byDate.has(key)) this.byDate.set(key, []);
      this.byDate.get(key).push(e);
      const mk = key.slice(0, 7);
      let agg = this.monthAgg.get(mk);
      if (!agg) { agg = {}; this.monthAgg.set(mk, agg); }
      (e.event_types || []).forEach((t) => { agg[t] = (agg[t] || 0) + 1; });
      years.add(parseInt(key.slice(0, 4), 10));
    });
    this.availableYears = [...years].sort((a, b) => a - b);
    this.minYear = this.availableYears[0] || 1862;
    this.maxYear = this.availableYears[this.availableYears.length - 1] || 1931;
  }

  async loadCategoryColors() {
    // Kategorien, die in den Daten tatsächlich vorkommen
    const used = new Set();
    this.events.forEach((e) => (e.event_types || []).forEach((t) => used.add(t)));

    let all = {};
    try {
      const response = await fetch('js-data/categoryColors.json');
      all = await response.json();
    } catch (error) {
      console.warn('Failed to load category colors:', error);
    }
    // Reihenfolge der JSON-Datei beibehalten, unbekannte Kategorien hinten anfügen
    Object.keys(all).forEach((cat) => {
      if (!used.has(cat)) return;
      this.eventCategories[cat] = all[cat].color;
      this.categoryLabels[cat] = all[cat].caption;
      this.categoryOrder.push(cat);
    });
    used.forEach((cat) => {
      if (this.eventCategories[cat]) return;
      this.eventCategories[cat] = '#999999';
      this.categoryLabels[cat] = cat;
      this.categoryOrder.push(cat);
    });
    this.enabledCategories = new Set(this.categoryOrder);
  }

  /* ---------- Helfer ---------- */

  h(tag, attrs = {}, ...children) {
    const node = document.createElement(tag);
    Object.keys(attrs).forEach((k) => {
      const v = attrs[k];
      if (v == null) return;
      if (k === 'class') node.className = v;
      else if (k === 'style') node.style.cssText = v;
      else if (k === 'onclick') node.addEventListener('click', v);
      else node.setAttribute(k, v);
    });
    children.flat().forEach((c) => {
      if (c == null) return;
      node.appendChild(typeof c === 'string' ? document.createTextNode(c) : c);
    });
    return node;
  }

  pad(n) { return n < 10 ? '0' + n : '' + n; }
  keyOf(d) { return d.getFullYear() + '-' + this.pad(d.getMonth() + 1) + '-' + this.pad(d.getDate()); }
  parseKey(k) { const p = k.split('-').map(Number); return new Date(p[0], p[1] - 1, p[2]); }
  monday(d) { const off = (d.getDay() + 6) % 7; const m = new Date(d); m.setDate(d.getDate() - off); return m; }
  clampDate(d) {
    const lo = new Date(this.minYear, 0, 1);
    const hi = new Date(this.maxYear, 11, 31);
    if (d < lo) return lo;
    if (d > hi) return hi;
    return d;
  }
  weekStart(year, week) {
    const base = this.monday(new Date(year, 0, 1));
    const d = new Date(base);
    d.setDate(base.getDate() + (week - 1) * 7);
    return d;
  }
  weekRef(date) {
    const m = this.monday(date);
    const y = m.getFullYear();
    const base = this.monday(new Date(y, 0, 1));
    const w = Math.round((m - base) / (7 * 86400000)) + 1;
    return { year: y, week: w };
  }

  dayList(key) { return this.byDate.get(key) || []; }
  isEventVisible(event) {
    return (event.event_types || []).some((t) => this.enabledCategories.has(t));
  }
  activeList(key) { return this.dayList(key).filter((e) => this.isEventVisible(e)); }
  color(cat) { return this.eventCategories[cat] || '#999'; }
  primaryType(event) {
    const types = event.event_types || [];
    return types.find((t) => this.enabledCategories.has(t)) || types[0];
  }
  dayPage(key) { return key + '.html'; }

  parseColor(c) {
    if (c.indexOf('rgb') === 0) {
      const m = c.match(/\d+/g);
      return { r: +m[0], g: +m[1], b: +m[2] };
    }
    const n = parseInt(c.slice(1), 16);
    return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255 };
  }
  colorA(cat, a) {
    const c = this.parseColor(this.color(cat));
    return 'rgba(' + c.r + ',' + c.g + ',' + c.b + ',' + a + ')';
  }
  mixWhite(c, t) {
    return {
      r: Math.round(c.r + (255 - c.r) * t),
      g: Math.round(c.g + (255 - c.g) * t),
      b: Math.round(c.b + (255 - c.b) * t)
    };
  }
  // Multiplikative Mischung der Kategoriefarben eines Tages (weiß = keine Einträge)
  heatColor(tally) {
    let r = 1, g = 1, b = 1, any = false;
    for (const cat in tally) {
      const count = tally[cat];
      if (!count) continue;
      any = true;
      const col = this.parseColor(this.color(cat));
      const s = Math.min(0.80, 0.30 + (count - 1) * 0.13);
      r *= 1 - s * (1 - col.r / 255);
      g *= 1 - s * (1 - col.g / 255);
      b *= 1 - s * (1 - col.b / 255);
    }
    if (!any) return null;
    return { r: Math.round(r * 255), g: Math.round(g * 255), b: Math.round(b * 255) };
  }
  dayTally(events) {
    const tally = {};
    events.forEach((e) => (e.event_types || []).forEach((t) => {
      if (this.enabledCategories.has(t)) tally[t] = (tally[t] || 0) + 1;
    }));
    return tally;
  }
  orderedTypes(tally) {
    return this.categoryOrder.filter((c) => tally[c]);
  }
  countLabel(n, zero) {
    if (n === 0) return zero || 'keine Einträge';
    return n + (n === 1 ? ' Eintrag' : ' Einträge');
  }

  /* ---------- Grundgerüst und Styles ---------- */

  createStructure() {
    this.container.innerHTML = '';
    this.container.classList.add('sc-root');

    this.toolbarEl = this.h('div', { class: 'sc-toolbar' },
      this.h('div', { class: 'sc-views', role: 'group', 'aria-label': 'Ansicht wählen' },
        ...['life', 'year', 'month', 'week'].map((view, i) =>
          this.h('button', {
            class: 'sc-view-btn', type: 'button', 'data-view': view,
            onclick: () => this.changeView(view)
          }, ['Leben', 'Jahr', 'Monat', 'Woche'][i]))
      ),
      this.h('div', { class: 'sc-nav' },
        this.h('button', {
          class: 'sc-nav-btn', type: 'button', 'aria-label': 'Zurück',
          onclick: () => this.navigatePeriod(-1)
        }, '‹'),
        this.h('button', {
          class: 'sc-period', type: 'button', title: 'Zur Jahresübersicht',
          onclick: () => this.changeView('year')
        }),
        this.h('button', {
          class: 'sc-nav-btn', type: 'button', 'aria-label': 'Weiter',
          onclick: () => this.navigatePeriod(1)
        }, '›')
      )
    );
    this.filtersEl = this.h('div', { class: 'sc-filters' });
    this.bodyEl = this.h('div', { class: 'sc-body' });
    this.drawerEl = this.h('div', { class: 'sc-drawer-backdrop', hidden: 'hidden' });

    this.container.appendChild(this.toolbarEl);
    this.container.appendChild(this.filtersEl);
    this.container.appendChild(this.bodyEl);
    this.container.appendChild(this.drawerEl);

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.drawerOpen) this.closeDrawer();
    });
  }

  addStyles() {
    if (document.getElementById('calendar-styles')) return;
    const style = document.createElement('style');
    style.id = 'calendar-styles';
    style.textContent = `
      .sc-root { color: #2a2722; }
      .sc-root button { font-family: inherit; }

      /* Toolbar */
      .sc-toolbar {
        display: flex; align-items: center; justify-content: space-between;
        flex-wrap: wrap; gap: 14px; margin-bottom: 18px;
      }
      .sc-views {
        display: inline-flex; border: 1px solid #d8d4ca; border-radius: 7px;
        overflow: hidden; background: #fff;
      }
      .sc-view-btn {
        padding: 8px 16px; font-size: 13.5px; font-weight: 600; cursor: pointer;
        border: none; border-right: 1px solid #e2ded4; background: #fff; color: #6f6b62;
      }
      .sc-view-btn:last-child { border-right: none; }
      .sc-view-btn.active { background: #26241f; color: #fff; }
      .sc-nav { display: inline-flex; align-items: center; gap: 6px; }
      .sc-nav-btn {
        width: 34px; height: 34px; display: grid; place-items: center;
        border: 1px solid #d8d4ca; background: #fff; border-radius: 7px;
        cursor: pointer; color: #403c34; font-size: 16px;
      }
      .sc-nav-btn:disabled { opacity: .35; cursor: default; }
      .sc-period {
        min-width: 188px; text-align: center; font-size: 18px; font-weight: 600;
        color: #26241f; background: none; border: none; cursor: pointer;
        padding: 4px 12px; border-radius: 6px;
      }
      .sc-period:hover { background: #f3f1e9; }

      /* Filterleiste */
      .sc-filters {
        display: flex; align-items: center; flex-wrap: wrap; gap: 8px;
        margin-bottom: 20px; padding-bottom: 20px; border-bottom: 1px solid #ddd9cf;
      }
      .sc-filters-label {
        font-size: 11px; letter-spacing: .12em; text-transform: uppercase;
        color: #9a9488; margin-right: 4px;
      }
      .sc-chip {
        display: inline-flex; align-items: center; gap: 7px;
        padding: 5px 11px 5px 9px; border-radius: 20px; cursor: pointer;
        font-size: 12.5px; font-weight: 500;
        border: 1px solid #e2ded4; background: #f0eee7; color: #a8a294;
      }
      .sc-chip.active { border-color: #cfcabf; background: #fff; color: #2a2722; }
      .sc-chip-swatch {
        width: 10px; height: 10px; border-radius: 50%; flex: none;
        background: transparent; border: 1px solid #c4bfb2;
      }
      .sc-chip-count { font-size: 11px; font-variant-numeric: tabular-nums; color: #bdb8ab; }
      .sc-chip.active .sc-chip-count { color: #9a9488; }
      .sc-filters-spacer { flex: 1; }
      .sc-link-btn {
        font-size: 12px; color: #6f6b62; background: none; border: none; cursor: pointer;
        text-decoration: underline; text-underline-offset: 2px; padding: 2px 4px;
      }

      /* Monatsansicht */
      .sc-month {
        background: #fff; border: 1px solid #ddd9cf; border-radius: 8px;
        overflow: hidden; box-shadow: 0 1px 2px rgba(40,36,30,.04);
      }
      .sc-month-weekdays {
        display: grid; grid-template-columns: repeat(7, 1fr);
        background: #f6f4ee; border-bottom: 1px solid #e7e4dc;
      }
      .sc-month-weekdays div {
        padding: 9px 10px; font-size: 11px; font-weight: 600;
        letter-spacing: .08em; text-transform: uppercase; color: #9a9488;
      }
      .sc-month-grid { display: grid; grid-template-columns: repeat(7, 1fr); }
      .sc-day {
        position: relative; min-height: 98px; padding: 8px 9px; background: #fff;
        border-right: 1px solid #ece8df; border-bottom: 1px solid #ece8df;
        cursor: pointer; display: flex; flex-direction: column; gap: 6px;
        text-align: left; font: inherit;
      }
      .sc-day:hover { filter: brightness(.96); }
      .sc-day:nth-child(7n) { border-right: none; }
      .sc-day:nth-child(n+36) { border-bottom: none; }
      .sc-day.other-month { background: #faf9f5; }
      .sc-day.selected { box-shadow: inset 0 0 0 2px #26241f; }
      .sc-day-num {
        font-size: 13px; font-variant-numeric: tabular-nums; font-weight: 500; color: #33302a;
      }
      .sc-day.weekend .sc-day-num { color: #7a766c; }
      .sc-day.other-month .sc-day-num { color: #bdb8ab; }
      .sc-day.dark .sc-day-num { color: rgba(255,255,255,.96); font-weight: 600; }
      .sc-day.selected .sc-day-num { font-weight: 700; }
      .sc-day-markers {
        display: flex; flex-wrap: wrap; gap: 5px; align-items: center; margin-top: auto;
      }
      .sc-day-marker {
        width: 13px; height: 13px; border-radius: 3px; flex: none;
        box-shadow: inset 0 0 0 1px rgba(255,255,255,.4);
      }
      .sc-day-more { font-size: 11px; font-weight: 600; color: #6f6b62; margin-left: 1px; }
      .sc-day.dark .sc-day-more { color: rgba(255,255,255,.85); }

      /* Wochenansicht */
      .sc-week { display: grid; grid-template-columns: repeat(7, 1fr); gap: 10px; }
      .sc-week-col {
        background: #fff; border: 1px solid #ddd9cf; border-radius: 6px;
        display: flex; flex-direction: column; min-height: 380px; overflow: hidden;
      }
      .sc-week-col.selected { border-color: #26241f; }
      .sc-week-head {
        padding: 10px 11px; border-bottom: 1px solid #ece8df; cursor: pointer;
        display: flex; flex-direction: column; gap: 2px; background: #fff;
        text-align: left; font: inherit; border-left: none; border-right: none; border-top: none;
      }
      .sc-week-head.weekend { background: #f6f4ee; }
      .sc-week-head .sc-week-wd {
        font-size: 11px; font-weight: 600; letter-spacing: .06em;
        text-transform: uppercase; color: #9a9488;
      }
      .sc-week-head .sc-week-date { font-size: 17px; font-weight: 600; color: #403c34; }
      .sc-week-list {
        padding: 8px; display: flex; flex-direction: column; gap: 6px;
        overflow: auto; max-height: 460px;
      }
      .sc-week-entry {
        display: flex; gap: 8px; text-align: left; background: #faf9f5;
        border: 1px solid #ece8df; border-radius: 5px; padding: 7px 8px;
        cursor: pointer; width: 100%; text-decoration: none; font: inherit;
      }
      .sc-week-entry:hover { background: #f3f1e9; }
      .sc-week-entry .sc-bar {
        width: 3px; flex: none; border-radius: 2px; align-self: stretch;
      }
      .sc-week-entry .sc-week-entry-title {
        display: block; font-size: 13px; line-height: 1.25; color: #2a2722;
      }
      .sc-week-entry .sc-week-entry-src {
        display: block; font-size: 10.5px; letter-spacing: .04em;
        text-transform: uppercase; color: #9a9488; margin-top: 2px;
      }
      .sc-week-empty { font-size: 13px; color: #b8b3a6; text-align: center; padding: 14px 0; }

      /* Jahresansicht */
      .sc-year {
        display: grid; grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); gap: 16px;
      }
      .sc-year-month {
        background: #fff; border: 1px solid #ddd9cf; border-radius: 7px;
        padding: 13px 13px 15px; box-shadow: 0 1px 2px rgba(40,36,30,.04);
      }
      .sc-year-month-name {
        font-size: 15px; font-weight: 600; color: #26241f; background: none;
        border: none; cursor: pointer; padding: 0 0 9px; display: block;
      }
      .sc-year-month-name:hover { color: #6f5106; }
      .sc-year-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 3px; }
      .sc-year-day { width: 100%; padding-top: 100%; background: #f1efe8; border-radius: 2px; }
      .sc-year-day.blank { background: transparent; }
      .sc-year-day.has-events { cursor: pointer; }
      .sc-year-day.has-events:hover { box-shadow: inset 0 0 0 1px #26241f; }

      /* Lebensansicht (Heatmap) */
      .sc-life {
        background: #fff; border: 1px solid #ddd9cf; border-radius: 8px;
        padding: 22px 24px 18px; box-shadow: 0 1px 2px rgba(40,36,30,.04);
      }
      .sc-life-head {
        display: flex; justify-content: space-between; align-items: baseline;
        flex-wrap: wrap; gap: 12px; margin-bottom: 16px;
      }
      .sc-life-title { font-size: 16px; color: #403c34; }
      .sc-life-legend { display: flex; align-items: center; gap: 6px; font-size: 11px; color: #9a9488; }
      .sc-life-legend span.sw { width: 13px; height: 13px; border-radius: 2px; display: inline-block; }
      .sc-life-scroll { overflow-x: auto; padding-bottom: 4px; }
      .sc-life-inner { min-width: 760px; }
      .sc-life-row { display: grid; gap: 2px; align-items: center; margin-bottom: 2px; }
      .sc-life-rowlabel { font-size: 10px; color: #9a9488; text-align: right; padding-right: 7px; }
      .sc-life-cell { height: 14px; border-radius: 2px; background: #f1efe8; }
      .sc-life-cell.has-events { cursor: pointer; }
      .sc-life-cell.has-events:hover { box-shadow: inset 0 0 0 1px #26241f; }
      .sc-life-ticks { display: grid; gap: 2px; margin-top: 7px; }
      .sc-life-tick {
        font-size: 10px; color: #9a9488; white-space: nowrap; overflow: visible;
        text-align: center; height: 12px;
      }
      .sc-life-note { margin: 16px 0 0; font-size: 12px; color: #9a9488; max-width: 74ch; }

      /* Drawer */
      .sc-drawer-backdrop {
        position: fixed; inset: 0; background: rgba(28,24,18,.34); z-index: 1050;
        animation: sc-fade .18s ease;
      }
      .sc-drawer {
        position: fixed; top: 0; right: 0; bottom: 0; width: 420px; max-width: 92vw;
        background: #fbfaf6; box-shadow: -12px 0 36px rgba(28,24,18,.18);
        overflow: auto; display: flex; flex-direction: column;
        animation: sc-slide .22s cubic-bezier(.2,.7,.3,1);
      }
      @keyframes sc-fade { from { opacity: 0; } to { opacity: 1; } }
      @keyframes sc-slide { from { transform: translateX(24px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
      .sc-drawer-head {
        position: sticky; top: 0; z-index: 1; background: #fbfaf6;
        border-bottom: 1px solid #e7e4dc; padding: 20px 24px 16px;
        display: flex; align-items: flex-start; justify-content: space-between; gap: 12px;
      }
      .sc-drawer-wd {
        font-size: 11px; letter-spacing: .14em; text-transform: uppercase;
        color: #9a9488; margin-bottom: 4px;
      }
      .sc-drawer-date { font-size: 23px; font-weight: 600; color: #26241f; line-height: 1.1; }
      .sc-drawer-count { font-size: 12.5px; color: #6f6b62; margin-top: 5px; }
      .sc-drawer-daylink {
        display: inline-block; font-size: 12.5px; color: #26241f; margin-top: 7px;
        text-decoration: underline; text-underline-offset: 2px;
      }
      .sc-drawer-close {
        width: 32px; height: 32px; flex: none; display: grid; place-items: center;
        border: 1px solid #ddd9cf; background: #fff; border-radius: 7px;
        cursor: pointer; color: #6f6b62; font-size: 17px;
      }
      .sc-drawer-list {
        padding: 14px 24px 24px; display: flex; flex-direction: column; gap: 0; flex: 1;
      }
      .sc-entry { display: flex; gap: 12px; padding: 13px 0; border-bottom: 1px solid #ece8df; }
      .sc-entry .sc-bar { width: 3px; flex: none; border-radius: 2px; align-self: stretch; }
      .sc-entry-main { min-width: 0; }
      .sc-entry-tag {
        font-size: 10.5px; letter-spacing: .06em; text-transform: uppercase; font-weight: 600;
      }
      .sc-entry-title { font-size: 15px; line-height: 1.35; color: #2a2722; margin: 3px 0 2px; }
      .sc-entry-link { font-size: 12px; text-decoration: none; }
      .sc-entry-link:hover { text-decoration: underline; }
      .sc-drawer-empty { color: #b8b3a6; font-size: 14px; padding: 20px 0; text-align: center; }
      .sc-drawer-hidden { font-size: 12px; color: #9a9488; font-style: italic; padding-top: 8px; }
      .sc-drawer-foot {
        position: sticky; bottom: 0; background: #fbfaf6; border-top: 1px solid #e7e4dc;
        padding: 12px 24px; display: flex; justify-content: space-between;
      }
      .sc-drawer-foot button {
        font-size: 13px; color: #403c34; background: #fff; border: 1px solid #ddd9cf;
        border-radius: 7px; padding: 7px 13px; cursor: pointer;
      }
      .sc-drawer-foot button:hover { background: #f3f1e9; }

      /* Responsiv */
      @media (max-width: 900px) {
        .sc-week { grid-template-columns: 1fr; }
        .sc-week-col { min-height: 0; }
        .sc-year { grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); }
      }
      @media (max-width: 768px) {
        .sc-day { min-height: 64px; padding: 5px 6px; }
        .sc-day-marker { width: 9px; height: 9px; }
        .sc-period { min-width: 0; }
      }
    `;
    document.head.appendChild(style);
  }

  /* ---------- Navigation und Zustand ---------- */

  changeView(view) {
    const prev = this.currentView;
    if (view === 'week' && prev !== 'week') {
      const base = this.selectedKey
        ? this.parseKey(this.selectedKey)
        : new Date(this.currentYear, this.currentMonth, 15);
      const ref = this.weekRef(this.clampDate(base));
      this.currentYear = ref.year;
      this.currentWeek = ref.week;
    }
    this.currentView = view;
    this.render();
    this.saveStateToURL();
  }

  navigatePeriod(direction) {
    const v = this.currentView;
    if (v === 'life') return;
    if (v === 'year') {
      const y = this.currentYear + direction;
      if (y < this.minYear || y > this.maxYear) return;
      this.currentYear = y;
    } else if (v === 'month') {
      let y = this.currentYear, m = this.currentMonth + direction;
      if (m > 11) { m = 0; y++; }
      if (m < 0) { m = 11; y--; }
      if (y < this.minYear || y > this.maxYear) return;
      this.currentYear = y;
      this.currentMonth = m;
    } else if (v === 'week') {
      const ws = this.weekStart(this.currentYear, this.currentWeek);
      ws.setDate(ws.getDate() + direction * 7);
      const ref = this.weekRef(this.clampDate(ws));
      this.currentYear = ref.year;
      this.currentWeek = ref.week;
    }
    this.render();
    this.saveStateToURL();
  }

  openDay(key) {
    const d = this.parseKey(key);
    this.selectedKey = key;
    this.drawerOpen = true;
    this.currentYear = d.getFullYear();
    this.currentMonth = d.getMonth();
    const ref = this.weekRef(d);
    this.currentWeek = ref.week;
    if (this.currentView === 'week') this.currentYear = ref.year;
    this.render();
    this.saveStateToURL();
  }

  openMonth(year, month) {
    this.currentView = 'month';
    this.currentYear = year;
    this.currentMonth = month;
    this.render();
    this.saveStateToURL();
  }

  closeDrawer() {
    this.drawerOpen = false;
    this.render();
  }

  drawerStep(delta) {
    const d = this.parseKey(this.selectedKey);
    d.setDate(d.getDate() + delta);
    this.openDay(this.keyOf(this.clampDate(d)));
  }

  toggleCategory(category) {
    if (this.enabledCategories.has(category)) this.enabledCategories.delete(category);
    else this.enabledCategories.add(category);
    this.render();
    this.saveStateToURL();
  }

  selectAllCategories() {
    this.enabledCategories = new Set(this.categoryOrder);
    this.render();
    this.saveStateToURL();
  }

  deselectAllCategories() {
    this.enabledCategories.clear();
    this.render();
    this.saveStateToURL();
  }

  /* ---------- Rendering ---------- */

  render() {
    this.toolbarEl.querySelectorAll('.sc-view-btn').forEach((btn) => {
      const active = btn.dataset.view === this.currentView;
      btn.classList.toggle('active', active);
      btn.setAttribute('aria-pressed', active ? 'true' : 'false');
    });
    this.toolbarEl.querySelector('.sc-period').textContent = this.periodTitle();
    this.toolbarEl.querySelectorAll('.sc-nav-btn').forEach((btn) => {
      btn.disabled = this.currentView === 'life';
    });

    this.renderFilters();

    this.bodyEl.innerHTML = '';
    if (this.currentView === 'life') this.bodyEl.appendChild(this.buildLifeView());
    else if (this.currentView === 'year') this.bodyEl.appendChild(this.buildYearView());
    else if (this.currentView === 'month') this.bodyEl.appendChild(this.buildMonthView());
    else this.bodyEl.appendChild(this.buildWeekView());

    this.renderDrawer();
  }

  periodTitle() {
    const v = this.currentView;
    if (v === 'life') return this.minYear + ' – ' + this.maxYear;
    if (v === 'year') return String(this.currentYear);
    if (v === 'month') return this.monthNames[this.currentMonth] + ' ' + this.currentYear;
    const ws = this.weekStart(this.currentYear, this.currentWeek);
    const we = new Date(ws); we.setDate(ws.getDate() + 6);
    if (ws.getMonth() === we.getMonth()) {
      return ws.getDate() + '.–' + we.getDate() + '. ' + this.monthNames[ws.getMonth()] + ' ' + we.getFullYear();
    }
    const y1 = ws.getFullYear() !== we.getFullYear() ? ' ' + ws.getFullYear() : '';
    return ws.getDate() + '. ' + this.monthNames[ws.getMonth()].slice(0, 3) + '.' + y1
      + ' – ' + we.getDate() + '. ' + this.monthNames[we.getMonth()].slice(0, 3) + '. ' + we.getFullYear();
  }

  /* Anzahl der Einträge einer Kategorie im aktuell sichtbaren Zeitraum */
  periodCount(category) {
    const v = this.currentView;
    let sum = 0;
    if (v === 'life') {
      this.monthAgg.forEach((agg) => { sum += agg[category] || 0; });
      return sum;
    }
    if (v === 'year') {
      for (let m = 0; m < 12; m++) {
        const agg = this.monthAgg.get(this.currentYear + '-' + this.pad(m + 1));
        if (agg) sum += agg[category] || 0;
      }
      return sum;
    }
    if (v === 'month') {
      const agg = this.monthAgg.get(this.currentYear + '-' + this.pad(this.currentMonth + 1));
      return agg ? (agg[category] || 0) : 0;
    }
    const ws = this.weekStart(this.currentYear, this.currentWeek);
    for (let i = 0; i < 7; i++) {
      const d = new Date(ws); d.setDate(ws.getDate() + i);
      this.dayList(this.keyOf(d)).forEach((e) => {
        if ((e.event_types || []).includes(category)) sum++;
      });
    }
    return sum;
  }

  renderFilters() {
    this.filtersEl.innerHTML = '';
    this.filtersEl.appendChild(this.h('span', { class: 'sc-filters-label' }, 'Quellen'));
    this.categoryOrder.forEach((cat) => {
      const active = this.enabledCategories.has(cat);
      const swatch = this.h('span', { class: 'sc-chip-swatch', 'aria-hidden': 'true' });
      if (active) {
        swatch.style.background = this.color(cat);
        swatch.style.borderColor = this.color(cat);
      }
      this.filtersEl.appendChild(this.h('button', {
        class: 'sc-chip' + (active ? ' active' : ''),
        type: 'button',
        'data-category': cat,
        'aria-pressed': active ? 'true' : 'false',
        onclick: () => this.toggleCategory(cat)
      },
      swatch,
      this.h('span', {}, this.categoryLabels[cat] || cat),
      this.h('span', { class: 'sc-chip-count' }, String(this.periodCount(cat)))
      ));
    });
    this.filtersEl.appendChild(this.h('span', { class: 'sc-filters-spacer' }));
    this.filtersEl.appendChild(this.h('button', {
      class: 'sc-link-btn', type: 'button', onclick: () => this.selectAllCategories()
    }, 'alle'));
    this.filtersEl.appendChild(this.h('button', {
      class: 'sc-link-btn', type: 'button', onclick: () => this.deselectAllCategories()
    }, 'keine'));
  }

  /* ----- Monatsansicht ----- */

  buildMonthView() {
    const weekdays = this.h('div', { class: 'sc-month-weekdays' },
      ...this.dayNames.map((wd) => this.h('div', {}, wd)));
    const grid = this.h('div', { class: 'sc-month-grid' });

    const first = new Date(this.currentYear, this.currentMonth, 1);
    const off = (first.getDay() + 6) % 7;
    const start = new Date(this.currentYear, this.currentMonth, 1 - off);

    for (let i = 0; i < 42; i++) {
      const d = new Date(start); d.setDate(start.getDate() + i);
      const inMonth = d.getMonth() === this.currentMonth;
      const key = this.keyOf(d);
      const events = this.activeList(key);
      const tally = this.dayTally(events);
      const types = this.orderedTypes(tally);

      const cell = this.h('div', {
        class: 'sc-day'
          + (inMonth ? '' : ' other-month')
          + ((d.getDay() === 0 || d.getDay() === 6) ? ' weekend' : '')
          + (key === this.selectedKey ? ' selected' : ''),
        role: 'button', tabindex: '0',
        title: d.getDate() + '. ' + this.monthNames[d.getMonth()] + ' ' + d.getFullYear()
          + ' · ' + this.countLabel(events.length),
        onclick: () => this.openDay(key)
      });
      cell.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); this.openDay(key); }
      });

      let heat = this.heatColor(tally);
      if (heat && !inMonth) heat = this.mixWhite(heat, 0.62);
      if (heat) {
        cell.style.background = 'rgb(' + heat.r + ',' + heat.g + ',' + heat.b + ')';
        const lum = 0.299 * heat.r + 0.587 * heat.g + 0.114 * heat.b;
        if (lum < 145) cell.classList.add('dark');
      }

      cell.appendChild(this.h('span', { class: 'sc-day-num' }, String(d.getDate())));

      const markers = this.h('div', { class: 'sc-day-markers' });
      types.slice(0, 6).forEach((cat) => {
        const m = this.h('span', { class: 'sc-day-marker', title: this.categoryLabels[cat] || cat });
        m.style.background = this.color(cat);
        markers.appendChild(m);
      });
      if (types.length > 6) {
        markers.appendChild(this.h('span', { class: 'sc-day-more' }, '+' + (types.length - 6)));
      }
      cell.appendChild(markers);
      grid.appendChild(cell);
    }

    return this.h('section', { class: 'sc-month' }, weekdays, grid);
  }

  /* ----- Wochenansicht ----- */

  buildWeekView() {
    const section = this.h('section', { class: 'sc-week' });
    const ws = this.weekStart(this.currentYear, this.currentWeek);

    for (let i = 0; i < 7; i++) {
      const d = new Date(ws); d.setDate(ws.getDate() + i);
      const key = this.keyOf(d);
      const events = this.activeList(key);
      const weekend = (d.getDay() === 0 || d.getDay() === 6);

      const head = this.h('button', {
        class: 'sc-week-head' + (weekend ? ' weekend' : ''), type: 'button',
        title: 'Tagesansicht öffnen',
        onclick: () => this.openDay(key)
      },
      this.h('span', { class: 'sc-week-wd' }, this.dayNamesLong[i]),
      this.h('span', { class: 'sc-week-date' },
        d.getDate() + '. ' + this.monthNames[d.getMonth()].slice(0, 3) + '.')
      );

      const list = this.h('div', { class: 'sc-week-list' });
      events.forEach((event) => {
        const cat = this.primaryType(event);
        const bar = this.h('span', { class: 'sc-bar', 'aria-hidden': 'true' });
        bar.style.background = this.color(cat);
        const content = this.h('span', {},
          this.h('span', { class: 'sc-week-entry-title' }, event.name),
          this.h('span', { class: 'sc-week-entry-src' }, this.categoryLabels[cat] || cat)
        );
        if (event.url) {
          list.appendChild(this.h('a', {
            class: 'sc-week-entry', href: event.url, target: '_blank', rel: 'noopener'
          }, bar, content));
        } else {
          list.appendChild(this.h('button', {
            class: 'sc-week-entry', type: 'button',
            onclick: () => this.openDay(key)
          }, bar, content));
        }
      });
      if (!events.length) {
        list.appendChild(this.h('div', { class: 'sc-week-empty' }, '–'));
      }

      section.appendChild(this.h('div', {
        class: 'sc-week-col' + (key === this.selectedKey ? ' selected' : '')
      }, head, list));
    }
    return section;
  }

  /* ----- Jahresansicht ----- */

  buildYearView() {
    const section = this.h('section', { class: 'sc-year' });
    for (let mi = 0; mi < 12; mi++) {
      const grid = this.h('div', { class: 'sc-year-grid' });
      const first = new Date(this.currentYear, mi, 1);
      const off = (first.getDay() + 6) % 7;
      const dim = new Date(this.currentYear, mi + 1, 0).getDate();

      for (let i = 0; i < off; i++) {
        grid.appendChild(this.h('div', { class: 'sc-year-day blank' }));
      }
      for (let day = 1; day <= dim; day++) {
        const d = new Date(this.currentYear, mi, day);
        const key = this.keyOf(d);
        const events = this.activeList(key);
        const count = events.length;
        const cell = this.h('div', {
          class: 'sc-year-day' + (count ? ' has-events' : ''),
          title: day + '. ' + this.monthNames[mi] + ' · ' + this.countLabel(count)
        });
        if (count) {
          const tally = this.dayTally(events);
          let dom = null, best = 0;
          for (const cat in tally) { if (tally[cat] > best) { best = tally[cat]; dom = cat; } }
          const alpha = Math.min(0.85, 0.22 + count * 0.15);
          cell.style.background = this.colorA(dom, alpha);
          cell.setAttribute('role', 'button');
          cell.setAttribute('tabindex', '0');
          cell.addEventListener('click', () => { this.currentMonth = mi; this.openDay(key); });
          cell.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); this.currentMonth = mi; this.openDay(key); }
          });
        }
        grid.appendChild(cell);
      }

      section.appendChild(this.h('div', { class: 'sc-year-month' },
        this.h('button', {
          class: 'sc-year-month-name', type: 'button',
          title: 'Zu ' + this.monthNames[mi] + ' ' + this.currentYear + ' wechseln',
          onclick: () => this.openMonth(this.currentYear, mi)
        }, this.monthNames[mi]),
        grid
      ));
    }
    return section;
  }

  /* ----- Lebensansicht (Heatmap über alle Jahre) ----- */

  buildLifeView() {
    const years = [];
    for (let y = this.minYear; y <= this.maxYear; y++) years.push(y);
    const n = years.length;
    const cols = '30px repeat(' + n + ', 1fr)';

    let max = 1;
    const cellData = [];
    for (let m = 0; m < 12; m++) {
      cellData.push(years.map((y) => {
        const agg = this.monthAgg.get(y + '-' + this.pad(m + 1));
        let count = 0, dom = null, best = 0;
        if (agg) {
          this.categoryOrder.forEach((cat) => {
            if (!this.enabledCategories.has(cat)) return;
            const c = agg[cat] || 0;
            count += c;
            if (c > best) { best = c; dom = cat; }
          });
        }
        if (count > max) max = count;
        return { y: y, count: count, dom: dom };
      }));
    }

    const inner = this.h('div', { class: 'sc-life-inner' });
    for (let m = 0; m < 12; m++) {
      const row = this.h('div', { class: 'sc-life-row' });
      row.style.gridTemplateColumns = cols;
      row.appendChild(this.h('div', { class: 'sc-life-rowlabel' }, this.monthNames[m].slice(0, 3)));
      cellData[m].forEach((c) => {
        const cell = this.h('div', {
          class: 'sc-life-cell' + (c.count ? ' has-events' : ''),
          title: this.monthNames[m] + ' ' + c.y + ' · ' + this.countLabel(c.count)
        });
        if (c.count) {
          const alpha = Math.min(0.92, 0.16 + (c.count / max) * 0.8);
          cell.style.background = this.colorA(c.dom, alpha);
          cell.setAttribute('role', 'button');
          cell.setAttribute('tabindex', '0');
          cell.addEventListener('click', () => this.openMonth(c.y, m));
          cell.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); this.openMonth(c.y, m); }
          });
        }
        row.appendChild(cell);
      });
      inner.appendChild(row);
    }
    const ticks = this.h('div', { class: 'sc-life-ticks' });
    ticks.style.gridTemplateColumns = cols;
    ticks.appendChild(this.h('div', {}));
    years.forEach((y, i) => {
      ticks.appendChild(this.h('div', { class: 'sc-life-tick' },
        (y % 10 === 0 || i === 0) ? String(y) : ''));
    });
    inner.appendChild(ticks);

    const legend = this.h('div', { class: 'sc-life-legend' },
      this.h('span', {}, 'weniger'),
      ...[0, 0.3, 0.58, 0.9].map((a) => {
        const sw = this.h('span', { class: 'sw' });
        sw.style.background = a === 0 ? '#f1efe8' : 'rgba(3,122,51,' + a + ')';
        return sw;
      }),
      this.h('span', {}, 'mehr')
    );

    return this.h('section', { class: 'sc-life' },
      this.h('div', { class: 'sc-life-head' },
        this.h('div', { class: 'sc-life-title' }, 'Einträge pro Monat über die Lebensspanne'),
        legend
      ),
      this.h('div', { class: 'sc-life-scroll' }, inner),
      this.h('p', { class: 'sc-life-note' },
        'Ein Feld je Monat (' + this.minYear + '–' + this.maxYear + '); die Färbung folgt '
        + 'der Anzahl der – nach den aktiven Quellen gefilterten – Einträge, '
        + 'in der Farbe der häufigsten Quelle. Ein Klick öffnet den jeweiligen Monat.')
    );
  }

  /* ----- Tages-Drawer ----- */

  renderDrawer() {
    this.drawerEl.innerHTML = '';
    if (!this.drawerOpen || !this.selectedKey) {
      this.drawerEl.hidden = true;
      return;
    }
    this.drawerEl.hidden = false;

    const key = this.selectedKey;
    const d = this.parseKey(key);
    const all = this.dayList(key);
    const active = all.filter((e) => this.isEventVisible(e));
    const hidden = all.length - active.length;

    const list = this.h('div', { class: 'sc-drawer-list' });
    active.forEach((event) => {
      const cat = this.primaryType(event);
      const bar = this.h('span', { class: 'sc-bar', 'aria-hidden': 'true' });
      bar.style.background = this.color(cat);
      const tag = this.h('div', { class: 'sc-entry-tag' }, this.categoryLabels[cat] || cat);
      tag.style.color = this.color(cat);

      const main = this.h('div', { class: 'sc-entry-main' },
        tag,
        this.h('div', { class: 'sc-entry-title' }, event.name)
      );
      if (event.url) {
        const link = this.h('a', {
          class: 'sc-entry-link', href: event.url, target: '_blank', rel: 'noopener'
        }, 'Zum Eintrag →');
        link.style.color = this.color(cat);
        main.appendChild(link);
      }
      list.appendChild(this.h('div', { class: 'sc-entry' }, bar, main));
    });
    if (!active.length) {
      list.appendChild(this.h('div', { class: 'sc-drawer-empty' },
        'Keine sichtbaren Einträge an diesem Tag.'));
    }
    if (hidden > 0) {
      list.appendChild(this.h('div', { class: 'sc-drawer-hidden' },
        hidden + (hidden === 1 ? ' Eintrag ist' : ' Einträge sind') + ' durch den Filter ausgeblendet.'));
    }

    const drawer = this.h('aside', {
      class: 'sc-drawer', role: 'dialog', 'aria-modal': 'true',
      'aria-label': 'Einträge des Tages',
      onclick: (e) => e.stopPropagation()
    },
    this.h('div', { class: 'sc-drawer-head' },
      this.h('div', {},
        this.h('div', { class: 'sc-drawer-wd' }, this.dayNamesLong[(d.getDay() + 6) % 7]),
        this.h('div', { class: 'sc-drawer-date' },
          d.getDate() + '. ' + this.monthNames[d.getMonth()] + ' ' + d.getFullYear()),
        this.h('div', { class: 'sc-drawer-count' },
          this.countLabel(active.length, 'keine sichtbaren Einträge')),
        all.length
          ? this.h('a', { class: 'sc-drawer-daylink', href: this.dayPage(key) }, 'Zur Tagesseite →')
          : null
      ),
      this.h('button', {
        class: 'sc-drawer-close', type: 'button', 'aria-label': 'Schließen',
        onclick: () => this.closeDrawer()
      }, '×')
    ),
    list,
    this.h('div', { class: 'sc-drawer-foot' },
      this.h('button', { type: 'button', onclick: () => this.drawerStep(-1) }, '‹ Vortag'),
      this.h('button', { type: 'button', onclick: () => this.drawerStep(1) }, 'Folgetag ›')
    ));

    const backdrop = this.drawerEl;
    backdrop.onclick = () => this.closeDrawer();
    backdrop.appendChild(drawer);
    drawer.querySelector('.sc-drawer-close').focus();
  }

  /* ---------- URL-Zustand ---------- */

  loadStateFromURL() {
    const params = new URLSearchParams(window.location.search);
    if (params.has('year')) {
      const y = parseInt(params.get('year'), 10);
      if (y >= this.minYear && y <= this.maxYear) this.currentYear = y;
    }
    if (params.has('month')) {
      // 0-basiert (Kompatibilität mit bisherigen Chronik-URLs)
      const m = parseInt(params.get('month'), 10);
      if (m >= 0 && m <= 11) this.currentMonth = m;
    }
    if (params.has('week')) {
      const w = parseInt(params.get('week'), 10);
      if (w >= 1 && w <= 54) this.currentWeek = w;
    }
    if (params.has('view')) {
      const v = params.get('view');
      if (['life', 'year', 'month', 'week'].includes(v)) this.currentView = v;
    }
    if (params.has('categories')) {
      try {
        const categories = JSON.parse(decodeURIComponent(params.get('categories')));
        if (Array.isArray(categories)) {
          this.enabledCategories = new Set(
            categories.filter((c) => this.categoryOrder.includes(c)));
        }
      } catch (e) {
        console.warn('Failed to parse categories from URL:', e);
      }
    }
  }

  saveStateToURL() {
    const params = new URLSearchParams();
    params.set('view', this.currentView);
    if (this.currentView !== 'life') {
      params.set('year', this.currentYear.toString());
      if (this.currentView === 'month') params.set('month', this.currentMonth.toString());
      if (this.currentView === 'week') params.set('week', this.currentWeek.toString());
    }
    if (this.enabledCategories.size !== this.categoryOrder.length) {
      params.set('categories',
        encodeURIComponent(JSON.stringify(Array.from(this.enabledCategories))));
    }
    const newURL = window.location.pathname + '?' + params.toString();
    window.history.replaceState({ path: newURL }, '', newURL);
  }

  /* ---------- Öffentliche API ---------- */

  setYear(year) {
    this.currentYear = year;
    this.render();
    this.saveStateToURL();
  }

  setDataSource(events) {
    this.events = events || [];
    this.buildIndexes();
    this.render();
  }
}

// Export for global use
window.SimpleCalendar = SimpleCalendar;

let calendar;

async function initializeCalendar() {
  calendar = new SimpleCalendar('calendar', {
    startYear: 1900,
    dataSource: calendarData
  });
  await calendar.initialized;
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    initializeCalendar().catch(console.error);
  });
} else {
  initializeCalendar().catch(console.error);
}
