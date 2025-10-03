/**
 * Simple, sustainable calendar implementation for Schnitzler Chronik
 * Based on SimpleCalendar from schnitzler-kultur project
 * Adapted for chronological data display
 */

class SimpleCalendar {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId);
    this.currentYear = options.startYear || 1900;
    this.currentMonth = new Date().getMonth();
    this.currentWeek = this.getWeekOfYear(new Date());
    this.events = options.dataSource || [];
    this.onDayClick = options.clickDay || (() => {});
    
    // View modes: 'year', 'month', 'week'
    this.currentView = 'year';
    
    // Event type categories and colors - will be loaded dynamically
    this.eventCategories = {};
    this.categoryLabels = {};
    
    // Track enabled categories
    this.enabledCategories = new Set();
    
    this.monthNames = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    
    this.dayNames = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    
    // Create initialization promise
    this.initialized = this.init();
  }
  
  async init() {
    this.container.innerHTML = '';
    this.loadStateFromURL();
    await this.loadCategoryColors();
    this.createCalendarStructure();
    this.render();
  }
  
  async loadCategoryColors() {
    try {
      const response = await fetch('js-data/categoryColors.json');
      const allCategories = await response.json();
      
      // Find all categories that actually exist in the data
      const usedCategories = new Set();
      this.events.forEach(event => {
        if (event.event_types) {
          event.event_types.forEach(type => usedCategories.add(type));
        }
      });
      
      // Only include categories that are actually used
      usedCategories.forEach(category => {
        if (allCategories[category]) {
          this.eventCategories[category] = allCategories[category].color;
          this.categoryLabels[category] = allCategories[category].caption;
        } else {
          // Fallback for unknown categories
          this.eventCategories[category] = '#999999';
          this.categoryLabels[category] = category;
        }
      });
      
      // Initialize enabled categories with all found categories
      this.enabledCategories = new Set(Object.keys(this.eventCategories));
      
    } catch (error) {
      console.warn('Failed to load category colors:', error);
      // Fallback: create basic categories from event data
      const usedCategories = new Set();
      this.events.forEach(event => {
        if (event.event_types) {
          event.event_types.forEach(type => usedCategories.add(type));
        }
      });
      
      usedCategories.forEach(category => {
        this.eventCategories[category] = '#008B8B'; // Default color
        this.categoryLabels[category] = category;
      });
      
      this.enabledCategories = new Set(Object.keys(this.eventCategories));
    }
  }
  
  createCalendarStructure() {
    this.container.innerHTML = `
      <div class="calendar">
        <div class="calendar-header">
          <button class="nav-btn prev" data-direction="-1">&lt;</button>
          <div class="current-period">
            <div class="period-navigation">
              <h2 class="period-title">${this.getPeriodTitle()}</h2>
              <div class="period-dropdowns" style="display: none;">
                <!-- Dropdowns will be added dynamically -->
              </div>
            </div>
          </div>
          <button class="nav-btn next" data-direction="1">&gt;</button>
        </div>
        <div class="calendar-grid"></div>
      </div>
    `;
    
    // Add CSS
    this.addStyles();
    
    // Add event listeners
    this.container.querySelectorAll('.nav-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const direction = parseInt(e.target.dataset.direction);
        this.navigatePeriod(direction);
      });
    });
    
    // Create dropdown navigation
    this.createDropdownNavigation();
    
    // Add outside click handler to close dropdowns (with debouncing)
    let outsideClickHandler = null;
    
    const addOutsideClickHandler = () => {
      if (outsideClickHandler) {
        document.removeEventListener('click', outsideClickHandler);
      }
      
      outsideClickHandler = (e) => {
        const dropdownContainer = this.container.querySelector('.period-dropdowns');
        const titleElement = this.container.querySelector('.period-title');
        
        if (dropdownContainer && 
            !dropdownContainer.contains(e.target) && 
            !titleElement.contains(e.target) &&
            dropdownContainer.style.display === 'flex') {
          dropdownContainer.style.display = 'none';
        }
      };
      
      // Add with slight delay to avoid immediate triggering
      setTimeout(() => {
        document.addEventListener('click', outsideClickHandler);
      }, 100);
    };
    
    addOutsideClickHandler();
  }
  
  addStyles() {
    if (!document.getElementById('calendar-styles')) {
      const style = document.createElement('style');
      style.id = 'calendar-styles';
      style.textContent = `
        .calendar {
          width: 100%;
          margin: 0 auto;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        
        .calendar-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 20px;
        }
        
        .current-period {
          flex: 1;
          text-align: center;
          position: relative;
        }
        
        .period-navigation {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 10px;
        }
        
        .period-dropdowns {
          display: none;
          gap: 15px;
          align-items: center;
          flex-wrap: wrap;
          justify-content: center;
          background: white;
          padding: 15px;
          border-radius: 8px;
          box-shadow: 0 4px 20px rgba(0,0,0,0.15);
          border: 2px solid #007bff;
          position: absolute;
          top: 100%;
          left: 50%;
          transform: translateX(-50%);
          z-index: 1000;
          min-width: 320px;
          margin-top: 5px;
        }
        
        .period-dropdown {
          padding: 6px 10px;
          border: 1px solid #dee2e6;
          border-radius: 4px;
          font-size: 14px;
          background: white;
          cursor: pointer;
          min-width: 120px;
        }
        
        .period-dropdown:focus {
          outline: none;
          border-color: #007bff;
          box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
        }
        
        .period-title:hover {
          color: #007bff;
          text-decoration: underline;
        }
        
        .period-title::after {
          content: ' ▼';
          font-size: 0.8em;
          color: #6c757d;
          margin-left: 5px;
        }
        
        .nav-btn {
          background: #f8f9fa;
          border: 1px solid #dee2e6;
          border-radius: 4px;
          padding: 8px 12px;
          cursor: pointer;
          font-size: 16px;
          min-width: 40px;
        }
        
        .nav-btn:hover {
          background: #e9ecef;
        }
        
        .period-title {
          margin: 0;
          font-size: 24px;
          font-weight: 600;
          color: #333;
        }
        
        .calendar-grid {
          display: grid;
          gap: 20px;
        }
        
        .calendar-grid.year-view {
          grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        }
        
        .calendar-grid.month-view {
          grid-template-columns: 1fr;
          overflow-x: auto;
        }
        
        .calendar-grid.week-view {
          grid-template-columns: 1fr;
        }
        
        .month {
          border: 1px solid #dee2e6;
          border-radius: 8px;
          overflow: hidden;
          background: white;
        }
        
        .month-header {
          background: #f8f9fa;
          padding: 12px;
          text-align: center;
          font-weight: 600;
          color: #495057;
          border-bottom: 1px solid #dee2e6;
        }
        
        .month-days {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
        }
        
        .day-header {
          background: #f8f9fa;
          padding: 8px 4px;
          text-align: center;
          font-size: 12px;
          font-weight: 500;
          color: #6c757d;
          border-bottom: 1px solid #dee2e6;
        }
        
        .day {
          position: relative;
          aspect-ratio: 1;
          border: 1px solid #f1f3f4;
          cursor: pointer;
          transition: background-color 0.2s;
          display: flex;
          flex-direction: column;
          justify-content: flex-start;
          align-items: center;
          padding: 2px;
          min-height: 40px;
        }
        
        .day:hover {
          background-color: #f8f9fa;
        }
        
        .day.other-month {
          color: #adb5bd;
          background-color: #fafbfc;
        }
        
        .day.has-events {
          font-weight: 600;
        }
        
        .day-number {
          font-size: 12px;
          line-height: 1;
          margin-bottom: 2px;
          z-index: 2;
        }
        
        .event-dots {
          display: flex;
          flex-wrap: wrap;
          justify-content: center;
          gap: 1px;
          max-width: 100%;
          overflow: hidden;
        }
        
        .event-dot {
          width: 6px;
          height: 6px;
          border-radius: 50%;
          flex-shrink: 0;
          border: 1px solid rgba(255,255,255,0.8);
        }
        
        .event-bars {
          position: absolute;
          bottom: 0;
          left: 0;
          right: 0;
          display: flex;
          flex-direction: column;
        }
        
        .event-bar {
          height: 2px;
          width: 100%;
        }
        
        .events-count {
          position: absolute;
          top: 2px;
          right: 2px;
          background: rgba(0,0,0,0.7);
          color: white;
          font-size: 8px;
          padding: 1px 3px;
          border-radius: 2px;
          line-height: 1;
          display: none;
        }
        
        .day.many-events .events-count {
          display: block;
        }

        /* Month view styles */
        .month-large {
          width: 100%;
          overflow-x: auto;
        }
        
        .month-days-large {
          display: grid;
          grid-template-columns: repeat(7, minmax(120px, 1fr));
          gap: 1px;
          background: #dee2e6;
          border: 1px solid #dee2e6;
          min-width: 840px;
        }
        
        .day-header-large {
          background: #f8f9fa;
          padding: 12px;
          text-align: center;
          font-weight: 600;
          color: #495057;
        }
        
        .day-large {
          min-height: 120px;
          background: white;
          padding: 4px;
          display: flex;
          flex-direction: column;
        }
        
        .day-number-large {
          font-weight: 600;
          margin-bottom: 4px;
        }
        
        .events-container-large {
          flex: 1;
          display: flex;
          flex-direction: column;
          gap: 1px;
          overflow: hidden;
        }
        
        .event-item-large {
          background: #007bff;
          color: white;
          padding: 1px 3px;
          border-radius: 2px;
          font-size: 9px;
          line-height: 1.1;
          cursor: pointer;
          white-space: normal;
          overflow: hidden;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          max-height: 20px;
          word-break: break-word;
        }
        
        .more-events-large {
          font-size: 10px;
          color: #6c757d;
          font-style: italic;
        }

        /* Week view styles */
        .week-view {
          width: 100%;
        }
        
        .week-days-header {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
          gap: 1px;
          background: #dee2e6;
          border: 1px solid #dee2e6;
          margin-bottom: 1px;
        }
        
        .week-day-header {
          background: #f8f9fa;
          padding: 12px;
          text-align: center;
        }
        
        .week-day-name {
          font-weight: 600;
          color: #495057;
        }
        
        .week-day-date {
          font-size: 12px;
          color: #6c757d;
        }
        
        .week-days-container {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
          gap: 1px;
          background: #dee2e6;
          border: 1px solid #dee2e6;
          min-height: 300px;
        }
        
        .week-day-column {
          background: white;
          padding: 8px;
          display: flex;
          flex-direction: column;
          gap: 4px;
        }
        
        .week-event {
          background: #007bff;
          color: white;
          padding: 4px 8px;
          border-radius: 4px;
          font-size: 12px;
          cursor: pointer;
          word-wrap: break-word;
          line-height: 1.3;
        }
        
        /* Responsive design */
        @media (max-width: 1400px) {
          .calendar-grid.year-view {
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
          }
        }
        
        @media (max-width: 900px) {
          .calendar-grid.year-view {
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
          }
        }
        
        @media (max-width: 600px) {
          .calendar-grid.year-view {
            grid-template-columns: 1fr;
          }
          
          .week-days-container {
            grid-template-columns: 1fr;
          }
          
          .week-day-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
          }
          
          .day-large {
            min-height: 80px;
          }
          
          .month-days-large {
            grid-template-columns: repeat(7, minmax(100px, 1fr));
            min-width: 700px;
          }
        }
      `;
      document.head.appendChild(style);
    }
  }
  
  createDropdownNavigation() {
    const dropdownContainer = this.container.querySelector('.period-dropdowns');
    const titleElement = this.container.querySelector('.period-title');
    
    // Clear existing dropdowns
    dropdownContainer.innerHTML = '';
    
    // Add click handler to title to toggle dropdowns
    titleElement.style.cursor = 'pointer';
    titleElement.title = 'Klicken für erweiterte Navigation';
    
    // Remove existing event listeners to avoid duplicates
    titleElement.replaceWith(titleElement.cloneNode(true));
    const newTitleElement = this.container.querySelector('.period-title');
    newTitleElement.style.cursor = 'pointer';
    newTitleElement.title = 'Klicken für erweiterte Navigation';
    
    newTitleElement.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      const isVisible = dropdownContainer.style.display === 'flex';
      dropdownContainer.style.display = isVisible ? 'none' : 'flex';
      console.log('Dropdown toggled:', dropdownContainer.style.display);
    });
    
    // Create dropdowns based on current view
    if (this.currentView === 'month') {
      this.createMonthDropdown(dropdownContainer);
    } else if (this.currentView === 'week') {
      this.createWeekDropdown(dropdownContainer);
    }
    
    // Year dropdown for all views
    this.createYearDropdown(dropdownContainer);
  }
  
  createMonthDropdown(container) {
    const monthSelect = document.createElement('select');
    monthSelect.className = 'period-dropdown month-dropdown';
    
    this.monthNames.forEach((monthName, index) => {
      const option = document.createElement('option');
      option.value = index;
      option.textContent = monthName;
      option.selected = index === this.currentMonth;
      monthSelect.appendChild(option);
    });
    
    monthSelect.addEventListener('change', (e) => {
      this.currentMonth = parseInt(e.target.value);
      this.updatePeriodTitle();
      this.renderCalendar();
      this.saveStateToURL();
      container.style.display = 'none';
    });
    
    container.appendChild(monthSelect);
  }
  
  createWeekDropdown(container) {
    const weekSelect = document.createElement('select');
    weekSelect.className = 'period-dropdown week-dropdown';
    
    // Generate week options for current year
    for (let week = 1; week <= 52; week++) {
      const weekStart = this.getWeekStart(this.currentYear, week);
      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekEnd.getDate() + 6);
      
      const option = document.createElement('option');
      option.value = week;
      
      if (weekStart.getMonth() === weekEnd.getMonth()) {
        option.textContent = `KW ${week}: ${weekStart.getDate()}.-${weekEnd.getDate()}. ${this.monthNames[weekStart.getMonth()]}`;
      } else {
        option.textContent = `KW ${week}: ${weekStart.getDate()}. ${this.monthNames[weekStart.getMonth()]} - ${weekEnd.getDate()}. ${this.monthNames[weekEnd.getMonth()]}`;
      }
      
      option.selected = week === this.currentWeek;
      weekSelect.appendChild(option);
    }
    
    weekSelect.addEventListener('change', (e) => {
      this.currentWeek = parseInt(e.target.value);
      this.updatePeriodTitle();
      this.renderCalendar();
      this.saveStateToURL();
      container.style.display = 'none';
    });
    
    container.appendChild(weekSelect);
  }
  
  createYearDropdown(container) {
    const yearSelect = document.createElement('select');
    yearSelect.className = 'period-dropdown year-dropdown';
    
    // Find year range based on available events
    let availableYears = [];
    if (this.events.length > 0) {
      availableYears = [...new Set(this.events.map(event => 
        new Date(event.startDate).getFullYear()
      ))].sort((a, b) => a - b);
    }
    
    // Generate year range - prioritize event years, but include some buffer
    let startYear, endYear;
    if (availableYears.length > 0) {
      startYear = Math.min(availableYears[0] - 5, this.currentYear - 10);
      endYear = Math.max(availableYears[availableYears.length - 1] + 5, this.currentYear + 10);
    } else {
      startYear = this.currentYear - 50;
      endYear = this.currentYear + 50;
    }
    
    for (let year = startYear; year <= endYear; year++) {
      const option = document.createElement('option');
      option.value = year;
      
      // Mark years with events
      const hasEvents = availableYears.includes(year);
      option.textContent = hasEvents ? `${year} ●` : year.toString();
      option.selected = year === this.currentYear;
      
      if (hasEvents) {
        option.style.fontWeight = 'bold';
      }
      
      yearSelect.appendChild(option);
    }
    
    yearSelect.addEventListener('change', (e) => {
      this.currentYear = parseInt(e.target.value);
      this.updatePeriodTitle();
      this.renderCalendar();
      this.saveStateToURL();
      container.style.display = 'none';
      
      // Recreate dropdowns with new year context
      this.createDropdownNavigation();
    });
    
    container.appendChild(yearSelect);
  }
  
  createSidebarControls() {
    // This method will be called externally to setup sidebar controls
    return {
      createViewControls: () => this.createViewControls(),
      createLegend: () => this.createLegendForSidebar()
    };
  }
  
  createViewControls() {
    const viewControls = document.createElement('div');
    viewControls.className = 'view-controls-sidebar';
    viewControls.innerHTML = `
      <h6 class="sidebar-title">Ansicht</h6>
      <div class="btn-group-vertical w-100" role="group">
        <button class="btn btn-outline-primary view-btn ${this.currentView === 'year' ? 'active' : ''}" data-view="year">
          Jahr
        </button>
        <button class="btn btn-outline-primary view-btn ${this.currentView === 'month' ? 'active' : ''}" data-view="month">
          Monat
        </button>
        <button class="btn btn-outline-primary view-btn ${this.currentView === 'week' ? 'active' : ''}" data-view="week">
          Woche
        </button>
      </div>
    `;
    
    // Add event listeners
    viewControls.querySelectorAll('.view-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const view = e.target.closest('.view-btn').dataset.view;
        this.changeView(view);
      });
    });
    
    return viewControls;
  }
  
  createLegendForSidebar() {
    const legendContainer = document.createElement('div');
    legendContainer.className = 'calendar-legend-sidebar';
    
    legendContainer.innerHTML = `
      <h6 class="sidebar-title">Kategorien</h6>
      <div class="legend-controls-sidebar">
        <button class="btn btn-sm btn-outline-secondary me-1" onclick="calendar.selectAllCategories()">Alle</button>
        <button class="btn btn-sm btn-outline-secondary" onclick="calendar.deselectAllCategories()">Keine</button>
      </div>
    `;
    
    const legendList = document.createElement('div');
    legendList.className = 'legend-items-sidebar';
    
    Object.entries(this.eventCategories).forEach(([category, color]) => {
      const item = document.createElement('div');
      item.className = 'legend-item legend-item-sidebar';
      item.dataset.category = category;
      item.style.setProperty('--category-color', color);
      item.innerHTML = `
        <div class="legend-toggle">
          <div class="legend-color" style="background-color: ${color}"></div>
          <span class="legend-label">${this.getCategoryLabel(category)}</span>
        </div>
      `;
      
      item.addEventListener('click', () => this.toggleCategory(category));
      legendList.appendChild(item);
    });
    
    legendContainer.appendChild(legendList);
    
    // Add CSS for sidebar components
    this.addSidebarStyles();
    
    return legendContainer;
  }
  
  getCategoryLabel(category) {
    return this.categoryLabels[category] || category;
  }
  
  toggleCategory(category) {
    if (this.enabledCategories.has(category)) {
      this.enabledCategories.delete(category);
    } else {
      this.enabledCategories.add(category);
    }
    
    this.updateLegendState();
    this.renderCalendar();
    this.saveStateToURL();
  }
  
  selectAllCategories() {
    this.enabledCategories = new Set(Object.keys(this.eventCategories));
    this.updateLegendState();
    this.renderCalendar();
    this.saveStateToURL();
  }
  
  deselectAllCategories() {
    this.enabledCategories.clear();
    this.updateLegendState();
    this.renderCalendar();
    this.saveStateToURL();
  }
  
  updateLegendState() {
    // Update legend items in both main container and sidebar
    document.querySelectorAll('.legend-item').forEach(item => {
      const category = item.dataset.category;
      if (this.enabledCategories.has(category)) {
        item.classList.remove('disabled');
      } else {
        item.classList.add('disabled');
      }
    });
  }
  
  getPeriodTitle() {
    switch(this.currentView) {
      case 'year':
        return this.currentYear.toString();
      case 'month':
        return `${this.monthNames[this.currentMonth]} ${this.currentYear}`;
      case 'week':
        return this.getWeekTitle();
      default:
        return this.currentYear.toString();
    }
  }
  
  getWeekTitle() {
    const weekStart = this.getWeekStart(this.currentYear, this.currentWeek);
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 6);
    
    if (weekStart.getMonth() === weekEnd.getMonth()) {
      return `${weekStart.getDate()}.-${weekEnd.getDate()}. ${this.monthNames[weekStart.getMonth()]} ${this.currentYear}`;
    } else {
      return `${weekStart.getDate()}. ${this.monthNames[weekStart.getMonth()]} - ${weekEnd.getDate()}. ${this.monthNames[weekEnd.getMonth()]} ${this.currentYear}`;
    }
  }
  
  getWeekStart(year, week) {
    const jan1 = new Date(year, 0, 1);
    const daysToAdd = (week - 1) * 7;
    const weekStart = new Date(jan1);
    weekStart.setDate(jan1.getDate() + daysToAdd - jan1.getDay());
    return weekStart;
  }
  
  getWeekOfYear(date) {
    const start = new Date(date.getFullYear(), 0, 1);
    const diff = date - start;
    const oneWeek = 1000 * 60 * 60 * 24 * 7;
    return Math.ceil(diff / oneWeek);
  }
  
  navigatePeriod(direction) {
    switch(this.currentView) {
      case 'year':
        this.currentYear += direction;
        break;
      case 'month':
        this.currentMonth += direction;
        if (this.currentMonth > 11) {
          this.currentMonth = 0;
          this.currentYear++;
        } else if (this.currentMonth < 0) {
          this.currentMonth = 11;
          this.currentYear--;
        }
        break;
      case 'week':
        this.currentWeek += direction;
        if (this.currentWeek > 52) {
          this.currentWeek = 1;
          this.currentYear++;
        } else if (this.currentWeek < 1) {
          this.currentWeek = 52;
          this.currentYear--;
        }
        break;
    }
    this.updatePeriodTitle();
    this.renderCalendar();
    this.createDropdownNavigation(); // Update dropdown navigation
    this.saveStateToURL();
  }
  
  changeView(newView) {
    const oldView = this.currentView;
    this.currentView = newView;
    
    // Smart view switching logic
    if (oldView === 'year' && newView === 'month') {
      // Jump to January of the current year
      this.currentMonth = 0;
    } else if (oldView === 'year' && newView === 'week') {
      // Jump to first week of current year
      this.currentWeek = 1;
    } else if (oldView === 'month' && newView === 'week') {
      // Find week that contains the 15th of current month
      const midMonth = new Date(this.currentYear, this.currentMonth, 15);
      this.currentWeek = this.getWeekOfYear(midMonth);
    }
    
    // Update view buttons (both in calendar and sidebar)
    document.querySelectorAll('.view-btn').forEach(btn => {
      btn.classList.remove('active');
      if (btn.dataset.view === newView) {
        btn.classList.add('active');
      }
    });
    
    this.updatePeriodTitle();
    this.renderCalendar();
    this.createDropdownNavigation(); // Update dropdown navigation
    this.saveStateToURL();
  }
  
  addSidebarStyles() {
    if (!document.getElementById('sidebar-calendar-styles')) {
      const style = document.createElement('style');
      style.id = 'sidebar-calendar-styles';
      style.textContent = `
        .sidebar-title {
          font-weight: 600;
          color: #495057;
          margin-bottom: 12px;
          margin-top: 20px;
          padding-bottom: 8px;
          border-bottom: 2px solid #e9ecef;
          font-size: 14px;
        }
        
        .sidebar-title:first-child {
          margin-top: 0;
        }
        
        .view-controls-sidebar {
          margin-bottom: 20px;
        }
        
        .view-controls-sidebar .btn {
          margin-bottom: 4px;
          text-align: left;
          border-radius: 6px;
          font-size: 14px;
          padding: 8px 12px;
          transition: all 0.2s ease;
        }
        
        .view-controls-sidebar .btn.active {
          background-color: #007bff;
          border-color: #007bff;
          color: white;
          box-shadow: 0 2px 4px rgba(0,123,255,0.3);
        }
        
        .legend-controls-sidebar {
          margin-bottom: 12px;
          text-align: center;
        }
        
        .legend-controls-sidebar .btn {
          font-size: 12px;
          padding: 4px 8px;
        }
        
        .legend-items-sidebar {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }
        
        .legend-item-sidebar {
          cursor: pointer;
          margin-bottom: 6px;
          transition: all 0.2s;
          font-size: 13px;
          border-radius: 6px;
          overflow: hidden;
        }
        
        .legend-toggle {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 8px 12px;
          transition: all 0.2s;
          border-radius: 6px;
          position: relative;
        }
        
        .legend-item-sidebar:hover .legend-toggle {
          transform: translateY(-1px);
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .legend-item-sidebar:not(.disabled) .legend-toggle {
          background: linear-gradient(135deg, var(--category-color, #007bff) 0%, var(--category-color, #007bff) 100%);
          color: white;
          font-weight: 500;
        }
        
        .legend-item-sidebar.disabled .legend-toggle {
          background: #f8f9fa;
          color: #6c757d;
          border: 2px dashed #dee2e6;
        }
        
        .legend-item-sidebar.disabled .legend-color {
          background-color: #ccc !important;
          opacity: 0.5;
        }
        
        .legend-item-sidebar .legend-color {
          width: 18px;
          height: 18px;
          border-radius: 50%;
          border: 2px solid rgba(255,255,255,0.8);
          flex-shrink: 0;
          box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        }
        
        .legend-item-sidebar .legend-label {
          flex: 1;
          line-height: 1.2;
          text-shadow: 0 1px 2px rgba(0,0,0,0.1);
        }
        
        .legend-item-sidebar.disabled .legend-label {
          text-shadow: none;
        }
      `;
      document.head.appendChild(style);
    }
  }
  
  updatePeriodTitle() {
    const titleElement = this.container.querySelector('.period-title');
    if (titleElement) {
      titleElement.textContent = this.getPeriodTitle();
    }
  }
  
  getEventCategory(event) {
    // Use event_types from the data structure
    if (event.event_types && event.event_types.length > 0) {
      return event.event_types[0]; // Use first event type as primary category
    }
    return 'schnitzler-chronik-manuell'; // fallback
  }
  
  getEventsForDate(year, month, day) {
    return this.events.filter(event => {
      const eventDate = new Date(event.startDate);
      const eventTypes = event.event_types || [];
      
      // Check if any of the event types are enabled
      const hasEnabledType = eventTypes.some(type => this.enabledCategories.has(type));
      
      return eventDate.getFullYear() === year &&
             eventDate.getMonth() === month &&
             eventDate.getDate() === day &&
             hasEnabledType;
    });
  }
  
  renderCalendar() {
    const grid = this.container.querySelector('.calendar-grid');
    grid.innerHTML = '';
    
    // Remove all view classes and add current view
    grid.className = `calendar-grid ${this.currentView}-view`;
    
    switch(this.currentView) {
      case 'year':
        this.renderYearView(grid);
        break;
      case 'month':
        this.renderMonthView(grid);
        break;
      case 'week':
        this.renderWeekView(grid);
        break;
    }
  }
  
  renderYearView(grid) {
    for (let month = 0; month < 12; month++) {
      const monthDiv = this.createMonth(month);
      grid.appendChild(monthDiv);
    }
  }
  
  renderMonthView(grid) {
    const monthDiv = this.createLargeMonth(this.currentMonth);
    grid.appendChild(monthDiv);
  }
  
  renderWeekView(grid) {
    const weekDiv = this.createWeekView();
    grid.appendChild(weekDiv);
  }
  
  createMonth(month) {
    const monthDiv = document.createElement('div');
    monthDiv.className = 'month';
    
    const header = document.createElement('div');
    header.className = 'month-header';
    header.textContent = this.monthNames[month];
    monthDiv.appendChild(header);
    
    const daysGrid = document.createElement('div');
    daysGrid.className = 'month-days';
    
    // Add day headers
    this.dayNames.forEach(dayName => {
      const dayHeader = document.createElement('div');
      dayHeader.className = 'day-header';
      dayHeader.textContent = dayName;
      daysGrid.appendChild(dayHeader);
    });
    
    // Get first day of month and number of days
    const firstDay = new Date(this.currentYear, month, 1);
    const lastDay = new Date(this.currentYear, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startDay = firstDay.getDay(); // 0 = Sunday
    
    // Add empty cells for days before month starts
    for (let i = 0; i < startDay; i++) {
      const emptyDay = document.createElement('div');
      emptyDay.className = 'day other-month';
      daysGrid.appendChild(emptyDay);
    }
    
    // Add days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      const dayDiv = this.createDay(this.currentYear, month, day);
      daysGrid.appendChild(dayDiv);
    }
    
    monthDiv.appendChild(daysGrid);
    return monthDiv;
  }
  
  createDay(year, month, day) {
    const dayDiv = document.createElement('div');
    dayDiv.className = 'day';
    
    const dayNumber = document.createElement('div');
    dayNumber.className = 'day-number';
    dayNumber.textContent = day;
    dayDiv.appendChild(dayNumber);
    
    const events = this.getEventsForDate(year, month, day);
    
    if (events.length > 0) {
      dayDiv.classList.add('has-events');
      
      // Create event visualization
      if (events.length <= 8) {
        // Show as dots for few events
        const dotsContainer = document.createElement('div');
        dotsContainer.className = 'event-dots';
        
        // Group events by type and create dots
        const eventTypeColors = new Map();
        events.forEach(event => {
          if (event.event_types && event.colors) {
            event.event_types.forEach((type, index) => {
              if (this.enabledCategories.has(type) && event.colors[index]) {
                if (!eventTypeColors.has(type)) {
                  eventTypeColors.set(type, { color: event.colors[index], count: 0, events: [] });
                }
                eventTypeColors.get(type).count++;
                eventTypeColors.get(type).events.push(event);
              }
            });
          }
        });
        
        eventTypeColors.forEach((info, type) => {
          const dot = document.createElement('div');
          dot.className = 'event-dot';
          dot.style.backgroundColor = info.color;
          dot.title = `${this.getCategoryLabel(type)}: ${info.count} Event${info.count > 1 ? 's' : ''}`;
          dotsContainer.appendChild(dot);
        });
        
        dayDiv.appendChild(dotsContainer);
      } else {
        // Show as bars for many events
        dayDiv.classList.add('many-events');
        
        const barsContainer = document.createElement('div');
        barsContainer.className = 'event-bars';
        
        // Group events by category and show up to 4 bars
        const categoryGroups = new Map();
        events.forEach(event => {
          if (event.event_types && event.colors) {
            event.event_types.forEach((type, index) => {
              if (this.enabledCategories.has(type) && event.colors[index]) {
                if (!categoryGroups.has(type)) {
                  categoryGroups.set(type, { count: 0, color: event.colors[index] });
                }
                categoryGroups.get(type).count++;
              }
            });
          }
        });
        
        let barCount = 0;
        categoryGroups.forEach((info, category) => {
          if (barCount < 4) {
            const bar = document.createElement('div');
            bar.className = 'event-bar';
            bar.style.backgroundColor = info.color;
            bar.title = `${this.getCategoryLabel(category)}: ${info.count} Event${info.count > 1 ? 's' : ''}`;
            barsContainer.appendChild(bar);
            barCount++;
          }
        });
        
        dayDiv.appendChild(barsContainer);
        
        // Add count indicator
        const countDiv = document.createElement('div');
        countDiv.className = 'events-count';
        countDiv.textContent = events.length;
        dayDiv.appendChild(countDiv);
      }
      
      // Add click handler
      dayDiv.addEventListener('click', () => {
        this.onDayClick({
          date: new Date(year, month, day),
          events: events
        });
      });
    }
    
    return dayDiv;
  }
  
  createLargeMonth(month) {
    const monthDiv = document.createElement('div');
    monthDiv.className = 'month month-large';
    
    const header = document.createElement('div');
    header.className = 'month-header';
    header.textContent = this.monthNames[month];
    monthDiv.appendChild(header);
    
    const daysGrid = document.createElement('div');
    daysGrid.className = 'month-days month-days-large';
    
    // Add day headers
    this.dayNames.forEach(dayName => {
      const dayHeader = document.createElement('div');
      dayHeader.className = 'day-header day-header-large';
      dayHeader.textContent = dayName;
      daysGrid.appendChild(dayHeader);
    });
    
    // Get first day of month and number of days
    const firstDay = new Date(this.currentYear, month, 1);
    const lastDay = new Date(this.currentYear, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startDay = firstDay.getDay();
    
    // Add empty cells for days before month starts
    for (let i = 0; i < startDay; i++) {
      const emptyDay = document.createElement('div');
      emptyDay.className = 'day day-large other-month';
      daysGrid.appendChild(emptyDay);
    }
    
    // Add days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      const dayDiv = this.createLargeDay(this.currentYear, month, day);
      daysGrid.appendChild(dayDiv);
    }
    
    monthDiv.appendChild(daysGrid);
    return monthDiv;
  }
  
  createLargeDay(year, month, day) {
    const dayDiv = document.createElement('div');
    dayDiv.className = 'day day-large';
    
    const dayNumber = document.createElement('div');
    dayNumber.className = 'day-number day-number-large';
    dayNumber.textContent = day;
    dayDiv.appendChild(dayNumber);
    
    const events = this.getEventsForDate(year, month, day);
    
    if (events.length > 0) {
      dayDiv.classList.add('has-events');
      
      // In large month view, show more events
      const eventsContainer = document.createElement('div');
      eventsContainer.className = 'events-container-large';
      
      events.slice(0, 5).forEach(event => {
        const eventDiv = document.createElement('div');
        eventDiv.className = 'event-item-large';
        
        // Use first color from event
        if (event.colors && event.colors[0]) {
          eventDiv.style.backgroundColor = event.colors[0];
        } else {
          eventDiv.style.backgroundColor = '#007bff';
        }
        
        eventDiv.title = `${event.name}\n${this.getCategoryLabel(event.event_types[0])}`;
        eventDiv.textContent = event.name;
        
        // Add click handler to individual events
        if (event.url) {
          eventDiv.style.cursor = 'pointer';
          eventDiv.addEventListener('click', (e) => {
            e.stopPropagation();
            window.open(event.url, '_blank');
          });
        }
        
        eventsContainer.appendChild(eventDiv);
      });
      
      if (events.length > 5) {
        const moreDiv = document.createElement('div');
        moreDiv.className = 'more-events-large';
        moreDiv.textContent = `+${events.length - 5} weitere`;
        eventsContainer.appendChild(moreDiv);
      }
      
      dayDiv.appendChild(eventsContainer);
      
      // Add click handler
      dayDiv.addEventListener('click', () => {
        this.onDayClick({
          date: new Date(year, month, day),
          events: events
        });
      });
    }
    
    return dayDiv;
  }
  
  setYear(year) {
    this.currentYear = year;
    this.updatePeriodTitle();
    this.renderCalendar();
    this.saveStateToURL();
  }
  
  createWeekView() {
    const weekDiv = document.createElement('div');
    weekDiv.className = 'week-view';
    
    // Get week start date
    const weekStart = this.getWeekStart(this.currentYear, this.currentWeek);
    
    // Create day headers
    const headerDiv = document.createElement('div');
    headerDiv.className = 'week-days-header';
    
    for (let i = 0; i < 7; i++) {
      const dayDate = new Date(weekStart);
      dayDate.setDate(weekStart.getDate() + i);
      
      const headerCell = document.createElement('div');
      headerCell.className = 'week-day-header';
      headerCell.innerHTML = `
        <div class="week-day-name">${this.dayNames[i]}</div>
        <div class="week-day-date">${dayDate.getDate()}. ${this.monthNames[dayDate.getMonth()]}</div>
      `;
      headerDiv.appendChild(headerCell);
    }
    weekDiv.appendChild(headerDiv);
    
    // Create day columns
    const columnsDiv = document.createElement('div');
    columnsDiv.className = 'week-days-container';
    
    for (let i = 0; i < 7; i++) {
      const dayDate = new Date(weekStart);
      dayDate.setDate(weekStart.getDate() + i);
      
      const columnDiv = document.createElement('div');
      columnDiv.className = 'week-day-column';
      
      // Get events for this day
      const events = this.getEventsForDate(dayDate.getFullYear(), dayDate.getMonth(), dayDate.getDate());
      
      events.forEach(event => {
        const eventDiv = document.createElement('div');
        eventDiv.className = 'week-event';
        
        // Use event color
        if (event.colors && event.colors[0]) {
          eventDiv.style.backgroundColor = event.colors[0];
        }
        
        eventDiv.title = `${event.name}\n${this.getCategoryLabel(event.event_types[0])}`;
        eventDiv.textContent = event.name;
        
        // Add click handler for external links
        if (event.url) {
          eventDiv.style.cursor = 'pointer';
          eventDiv.addEventListener('click', (e) => {
            e.stopPropagation();
            window.open(event.url, '_blank');
          });
        }
        
        columnDiv.appendChild(eventDiv);
      });
      
      // Add click handler for day navigation
      columnDiv.addEventListener('click', () => {
        this.onDayClick({
          date: dayDate,
          events: events
        });
      });
      
      columnsDiv.appendChild(columnDiv);
    }
    
    weekDiv.appendChild(columnsDiv);
    return weekDiv;
  }
  
  setDataSource(events) {
    this.events = events;
    this.renderCalendar();
  }
  
  render() {
    this.renderCalendar();
  }
  
  // URL state management methods
  loadStateFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    
    if (urlParams.has('year')) {
      this.currentYear = parseInt(urlParams.get('year')) || this.currentYear;
    }
    
    if (urlParams.has('month')) {
      this.currentMonth = parseInt(urlParams.get('month')) || this.currentMonth;
    }
    
    if (urlParams.has('view')) {
      const view = urlParams.get('view');
      if (['year', 'month', 'week'].includes(view)) {
        this.currentView = view;
      }
    }
    
    if (urlParams.has('week')) {
      this.currentWeek = parseInt(urlParams.get('week')) || this.currentWeek;
    }
    
    if (urlParams.has('categories')) {
      try {
        const categories = JSON.parse(decodeURIComponent(urlParams.get('categories')));
        if (Array.isArray(categories)) {
          this.enabledCategories = new Set(categories);
        }
      } catch (e) {
        console.warn('Failed to parse categories from URL:', e);
      }
    }
  }
  
  saveStateToURL() {
    const urlParams = new URLSearchParams();
    
    urlParams.set('year', this.currentYear.toString());
    urlParams.set('view', this.currentView);
    
    if (this.currentView === 'month') {
      urlParams.set('month', this.currentMonth.toString());
    }
    
    if (this.currentView === 'week') {
      urlParams.set('week', this.currentWeek.toString());
    }
    
    // Save enabled categories
    if (this.enabledCategories.size !== Object.keys(this.eventCategories).length) {
      urlParams.set('categories', encodeURIComponent(JSON.stringify(Array.from(this.enabledCategories))));
    }
    
    const newURL = window.location.pathname + '?' + urlParams.toString();
    window.history.replaceState({ path: newURL }, '', newURL);
  }
}

// Export for global use
window.SimpleCalendar = SimpleCalendar;

// Initialize calendar when the page loads
let calendar;
let years;

// Helper function for week calculation
function getWeekOfYear(date) {
  const start = new Date(date.getFullYear(), 0, 1);
  const diff = date - start;
  const oneWeek = 1000 * 60 * 60 * 24 * 7;
  return Math.ceil(diff / oneWeek);
}

async function initializeCalendar() {
  // Convert calendar data for new structure
  const events = calendarData.map(r => ({
    startDate: new Date(r.startDate),
    endDate: new Date(r.startDate),
    name: r.name,
    linkId: r.id,
    colors: r.colors || ['#008B8B'],
    event_types: r.event_types || []
  }));

  // Find the week of the first event to set as default
  let defaultWeek = 1;
  if (events.length > 0) {
    const firstEventDate = new Date(events[0].startDate);
    defaultWeek = getWeekOfYear(firstEventDate);
  }

  // Create calendar instance
  calendar = new SimpleCalendar('calendar', {
    startYear: 1900,
    dataSource: events,
    clickDay: function(e) {
      // Format date to YYYY-MM-DD format and navigate to the corresponding HTML file
      const clickedDate = e.date;
      const year = clickedDate.getFullYear();
      const month = String(clickedDate.getMonth() + 1).padStart(2, '0');
      const day = String(clickedDate.getDate()).padStart(2, '0');
      const dateString = `${year}-${month}-${day}`;
      const htmlFile = `${dateString}.html`;
      
      // Navigate to the HTML file
      window.location.href = htmlFile;
    }
  });

  // Set initial week if not already set from URL
  if (calendar.currentWeek === getWeekOfYear(new Date()) && defaultWeek > 1) {
    calendar.currentWeek = defaultWeek;
  } else if (calendar.currentWeek === getWeekOfYear(new Date())) {
    calendar.currentWeek = 1; // Default to week 1 for 1900
  }

  // Wait for calendar initialization to complete
  await calendar.initialized;

  // Set up years navigation
  years = Array.from(new Set(calendarData.map(r => r.startDate.split('-')[0]))).sort();
  const yearsTable = document.getElementById('years-table');
  if (yearsTable) {
    yearsTable.innerHTML = '';
    years.forEach(year => {
      const yearBtn = document.createElement('button');
      yearBtn.id = `ybtn${year}`;
      yearBtn.className = 'btn btn-light rounded-0 yearbtn';
      yearBtn.textContent = year;
      yearBtn.addEventListener('click', () => updateyear(year));
      
      const yearCell = document.createElement('div');
      yearCell.className = 'col-xs-6';
      yearCell.style.width = 'auto';
      yearCell.appendChild(yearBtn);
      
      yearsTable.appendChild(yearCell);
    });
  }

  // Set initial year focus - make sure 1900 is selected
  updateyear(1900);
  
  // Initialize sidebar controls if container exists
  const sidebarContainer = document.getElementById('sidebar-controls');
  if (sidebarContainer) {
    const controls = calendar.createSidebarControls();
    sidebarContainer.appendChild(controls.createViewControls());
    sidebarContainer.appendChild(controls.createLegend());
  }
}

function updateyear(year) {
  calendar.setYear(parseInt(year));
  
  // Update button focus
  const buttons = document.querySelectorAll(".yearbtn");
  buttons.forEach(btn => btn.classList.remove('focus'));
  
  const focusBtn = document.getElementById(`ybtn${year}`);
  if (focusBtn) {
    focusBtn.classList.add("focus");
  }
}

// Initialize when DOM is loaded
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    initializeCalendar().catch(console.error);
  });
} else {
  initializeCalendar().catch(console.error);
}