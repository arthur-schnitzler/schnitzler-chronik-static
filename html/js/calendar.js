function getYear(item) {
  return item['startDate'].split('-')[0]
}

function createyearcell(val) {
  return (val !== undefined) ? `<div class="col-xs-6" style="width: auto;">\
  <button id="ybtn${val}" class="btn btn-light rounded-0 yearbtn" value="${val}" onclick="updateyear(this.value)">${val}</button>\
</div>` : '';
}

var data = calendarData.map(r =>
({
  startDate: new Date(r.startDate),
  endDate: new Date(r.startDate),
  name: r.name,
  linkId: r.id,
  colors: r.colors || ['#C67F53'],  // Use multiple colors or fallback to default
  event_types: r.event_types || []
})).filter(r => r.startDate.getFullYear() === 1900);




years = Array.from(new Set(calendarData.map(getYear))).sort();
var yearsTable = document.getElementById('years-table');
for (var i = 0; i <= years.length; i++) {
  yearsTable.insertAdjacentHTML('beforeend', createyearcell(years[i]));
}

// Create legend/filter component
createLegendFilter();

// Filter state - all event types enabled by default
var eventTypeFilters = {};

// Create legend/filter component
function createLegendFilter() {
  const yearsTable = document.getElementById('years-table');
  if (!yearsTable) return;
  
  // Get all unique event types and their colors from calendar data
  const eventTypeMap = new Map();
  calendarData.forEach(item => {
    if (item.event_types && item.colors) {
      item.event_types.forEach((type, index) => {
        if (!eventTypeMap.has(type) && item.colors[index]) {
          eventTypeMap.set(type, item.colors[index]);
        }
      });
    }
  });
  
  // Initialize all filters as enabled
  eventTypeMap.forEach((color, type) => {
    eventTypeFilters[type] = true;
  });
  
  // Event type labels mapping (can be customized)
  const eventTypeLabels = {
    'schnitzler-briefe': 'Briefe mit Autorinnen und Autoren',
    'schnitzler-tagebuch': 'Tagebuch',
    'schnitzler-lektueren': 'Leseliste',
    'schnitzler-interviews': 'Interviews, Meinungen, Proteste',
    'schnitzler-mikrofilme-daten': 'Mikroverfilmung des Nachlasses',
    'wienerschnitzler': 'Wiener Schnitzler',
    'schnitzler-events': 'Ereignisse in der PMB',
    'schnitzler-kultur': 'Kulturveranstaltungen',
    'schnitzler-zeitungen': 'Zeitungsausschnitte',
    'schnitzler-traeume': 'Traumtagebuch',
    'schnitzler-kino-buch': 'Kino',
    'schnitzler-kempny-buch': 'Kempny Tagebuch',
    'schnitzler-bahr': 'Schnitzler/Bahr',
    'schnitzler-orte': 'Aufenthaltsorte',
    'pollaczek': 'Pollaczek: Schnitzler und ich',
    'schnitzler-chronik': 'Chronik',
    'Arthur-Schnitzler-digital': 'Arthur Schnitzler digital (Werke 1905–1931)',
    'kalliope-verbund': 'Kalliope Verbundkatalog',
    'fackel': 'Fackel',
    'legalkraus': 'Rechtsakten',
    'dritte-walpurgisnacht': 'Dritte Walpurgisnacht',
    'bahr-textverzeichnis': 'Bahr Textverzeichnis',
    'bahr-tsn': 'Bahr Tagebücher',
    'zweig-digital': 'Zweig digital',
    'hanslick': 'Hanslick online',
    'thun-korrespondenz': 'Thun-Korrespondenz',
    'brenner': 'Der Brenner',
    'schoenbach': 'Schönbach',
    'briefe_i': 'Briefe 1875–1912',
    'briefe_ii': 'Briefe 1913–1931',
    'jugend-in-wien': 'Jugend in Wien',
    'auden-musulin-papers': 'Auden-Musulin',
    'schaubuehne': 'Die Schaubühne',
    'wiengeschichtewiki': 'Wien Geschichte Wiki',
    'oebl': 'ÖBL',
    'wikipedia': 'Wikipedia',
    'wikidata': 'Wikidata',
    'pmb': 'PMB',
    'gnd': 'GND',
    'geonames': 'geoNames',
    'schnitzler-cmif': 'Gedruckte Briefwechsel',
    'schnitzler-chronik-manuell': 'Ergänzungen'
  };
  
  // Create legend container
  const legendContainer = document.createElement('div');
  legendContainer.id = 'legend-filter';
  legendContainer.style.cssText = 'margin-top: 15px; text-align: center; padding: 10px; border-top: 1px solid #e0e0e0; max-height: 200px; overflow-y: auto;';
  
  // Create legend items
  const sortedEventTypes = Array.from(eventTypeMap.entries()).sort((a, b) => {
    const labelA = eventTypeLabels[a[0]] || a[0];
    const labelB = eventTypeLabels[b[0]] || b[0];
    return labelA.localeCompare(labelB);
  });
  
  sortedEventTypes.forEach(([eventType, color]) => {
    const label = eventTypeLabels[eventType] || eventType;
    const legendItem = document.createElement('div');
    legendItem.style.cssText = 'display: inline-block; margin: 5px 10px; cursor: pointer; user-select: none; font-size: 12px;';
    legendItem.innerHTML = `
      <input type="checkbox" id="filter-${eventType}" checked style="margin-right: 6px;" aria-describedby="legend-desc-${eventType}">
      <span style="display: inline-block; width: 10px; height: 10px; background-color: ${color}; margin-right: 4px; vertical-align: middle; border-radius: 2px;" aria-hidden="true"></span>
      <label for="filter-${eventType}" style="cursor: pointer; font-size: 12px; color: #333;" id="legend-desc-${eventType}">${label}</label>
    `;
    
    // Add click handler for the entire item
    legendItem.addEventListener('click', function(e) {
      if (e.target.type !== 'checkbox') {
        const checkbox = legendItem.querySelector('input[type="checkbox"]');
        checkbox.checked = !checkbox.checked;
      }
      toggleEventTypeFilter(eventType);
    });
    
    // Add keyboard support
    legendItem.addEventListener('keydown', function(e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        const checkbox = legendItem.querySelector('input[type="checkbox"]');
        checkbox.checked = !checkbox.checked;
        toggleEventTypeFilter(eventType);
      }
    });
    
    // Make focusable
    legendItem.setAttribute('tabindex', '0');
    legendItem.setAttribute('role', 'checkbox');
    legendItem.setAttribute('aria-checked', 'true');
    
    legendContainer.appendChild(legendItem);
  });
  
  // Insert legend after years table
  yearsTable.parentNode.insertBefore(legendContainer, yearsTable.nextSibling);
}

// Toggle event type filter and refresh calendar
function toggleEventTypeFilter(eventType) {
  eventTypeFilters[eventType] = !eventTypeFilters[eventType];
  
  // Update the checkbox state
  const checkbox = document.getElementById(`filter-${eventType}`);
  if (checkbox) {
    checkbox.checked = eventTypeFilters[eventType];
  }
  
  // Refresh the calendar with current filters
  const currentYear = calendar.getYear();
  setTimeout(() => {
    applyEventStacking(currentYear);
  }, 100);
}

//document.getElementById("ybtn1900").classList.add("focus");

const calendar = new Calendar('#calendar', {
  startYear: 1900,
  language: "de",
  dataSource: data,
  displayHeader: false,
  renderEnd: function (e) {
    const buttons = document.querySelectorAll(".yearbtn");
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].classList.remove('focus');
    }
    document.getElementById(`ybtn${e.currentYear}`).classList.add("focus");
    
    // Apply custom stacking after calendar renders
    setTimeout(() => {
      applyEventStacking(e.currentYear);
    }, 200);
  },
  clickDay: function (e) {
    //window.location = e.events[0].linkId;

    var entries = []
    $.each(e.events, function (key, entry) {
      entries.push(entry)
    });
    //window.location = ids.join();
    if (entries.length > 1) {
      let html = "<div class='modal' id='dialogForLinks' tabindex='-1' role='dialog' aria-labelledby='modalLabel' aria-hidden='true'>";
      html += "<div class='modal-dialog' role='document'>";
      html += "<div class='modal-content'>";
      html += "<div class='modal-header'>";
      html += "<h3 class='modal-title' id='modalLabel'>Links</h3>";
      html += "<button type='button' class='close' data-dismiss='modal' aria-label='Close'>";
      html += "<span aria-hidden='true'>&times;</span>";
      html += "</button></div>";
      html += "<div class='modal-body'>";
      let numbersTitlesAndIds = new Array();
      for (let i = 0; i < entries.length; i++) {
        let linkTitle = entries[i].name;
        let linkId = entries[i].linkId;
        let numberInSeriesOfLetters = 1;
        numbersTitlesAndIds.push({ 'i': i, 'position': numberInSeriesOfLetters, 'linkTitle': linkTitle, 'id': linkId });
      }

      numbersTitlesAndIds.sort(function (a, b) {
        let positionOne = parseInt(a.position);
        let positionTwo = parseInt(b.position);
        if (positionOne < positionTwo) {
          return -1;
        }
        if (positionOne > positionTwo) {
          return 1;
        }
        return 0;
      });
      for (let k = 0; k < numbersTitlesAndIds.length; k++) {
        html += "<div class='indent'><a href='" + numbersTitlesAndIds[k].id + "'>" + numbersTitlesAndIds[k].linkTitle + "</a></div>";
      }
      html += "</div>";
      html += "<div class='modal-footer'>";
      html += "<button type='button' class='btn btn-secondary' data-dismiss='modal'>X</button>";
      html += "</div></div></div></div>";
      $('#dialogForLinks').remove();
      $('#loadModal').append(html);
      $('#dialogForLinks').modal('show');

    }
    else { window.location = entries.map(entry => entry.linkId).join(); }
  }
});

// Function to apply custom event stacking for multiple event types per day
function applyEventStacking(year) {
  const currentYear = year || calendar.getYear();
  const calendarElement = document.querySelector('#calendar');
  if (!calendarElement) return;
  
  // Add CSS styles for stacked events
  if (!document.getElementById('event-stacking-styles')) {
    const style = document.createElement('style');
    style.id = 'event-stacking-styles';
    style.textContent = `
      /* Improve day cell styling */
      .calendar table td.day {
        position: relative !important;
        vertical-align: top !important;
        padding: 2px !important;
        min-height: 30px !important;
      }
      
      /* Ensure day content appears above event bars */
      .calendar .day-content {
        position: relative !important;
        z-index: 10 !important;
      }
      
      /* Custom event bars container */
      .custom-event-bars {
        position: absolute !important;
        bottom: 0 !important;
        left: 0 !important;
        right: 0 !important;
        z-index: 1 !important;
        display: flex !important;
        flex-direction: column !important;
        gap: 0 !important;
        pointer-events: auto !important;
      }
      
      .custom-event-bars .custom-event-bar {
        height: 2px !important;
        width: 100% !important;
        display: block !important;
        margin: 0 !important;
        border: none !important;
      }
      
      /* Hide original events completely */
      .calendar .event {
        display: none !important;
      }
      
      /* Improve hover effect */
      .calendar table td.day:hover {
        box-shadow: inset 0 0 0 1px rgba(0,0,0,0.2) !important;
      }
    `;
    document.head.appendChild(style);
  }
  
  // Create custom event bars after calendar renders
  setTimeout(() => {
    // Create our own data source from calendarData
    const dataSource = calendarData.map(r => ({
      startDate: new Date(r.startDate),
      endDate: new Date(r.startDate),
      name: r.name,
      linkId: r.id,
      event_types: r.event_types || [],
      colors: r.colors || ['#C67F53']
    })).filter(r => r.startDate.getFullYear() === currentYear);
    
    // Process each day cell
    const dayElements = calendarElement.querySelectorAll('td.day');
    
    dayElements.forEach((dayEl) => {
      let eventsForDay = [];
      
      // Try to extract date from day element
      const dayContentEl = dayEl.querySelector('.day-content');
      if (!dayContentEl) return;
      
      const dayText = dayContentEl.textContent.trim();
      const dayNumber = parseInt(dayText);
      
      if (dayNumber && dayNumber >= 1 && dayNumber <= 31) {
        // Find the month container this day belongs to
        let currentMonth = -1;
        const monthContainers = calendarElement.querySelectorAll('.month-container');
        for (let i = 0; i < monthContainers.length; i++) {
          const container = monthContainers[i];
          if (container.contains(dayEl)) {
            currentMonth = i;
            break;
          }
        }
        
        if (currentMonth >= 0) {
          // Find events that match this exact day, month and year
          eventsForDay = dataSource.filter(event => {
            const eventDate = event.startDate.getDate();
            const eventMonth = event.startDate.getMonth();
            const eventYear = event.startDate.getFullYear();
            return eventDate === dayNumber && 
                   eventMonth === currentMonth && 
                   eventYear === currentYear;
          });
        }
      }
      
      // Remove existing custom bars
      const existingBars = dayEl.querySelector('.custom-event-bars');
      if (existingBars) {
        existingBars.remove();
      }
      
      if (eventsForDay.length > 0 && eventsForDay[0].colors) {
        // Create container for custom event bars
        const barsContainer = document.createElement('div');
        barsContainer.className = 'custom-event-bars';
        
        let hasVisibleBars = false;
        
        // Create individual bars for each event type - stacked vertically
        // Only show bars for enabled event types
        eventsForDay[0].colors.forEach((color, index) => {
          const eventType = eventsForDay[0].event_types[index];
          if (eventType && eventTypeFilters[eventType]) {
            const bar = document.createElement('div');
            bar.className = 'custom-event-bar';
            bar.style.backgroundColor = color;
            bar.style.height = '2px';
            bar.style.width = '100%';
            bar.style.display = 'block';
            bar.title = eventType || 'Event type';
            barsContainer.appendChild(bar);
            hasVisibleBars = true;
          }
        });
        
        // Only append container if there are visible bars
        if (hasVisibleBars) {
          dayEl.appendChild(barsContainer);
        }
      }
    });
  }, 300);
}

function updateyear(year) {
  calendar.setYear(year);
  const dataSource = calendarData.map(r =>
  ({
    startDate: new Date(r.startDate),
    endDate: new Date(r.startDate),
    name: r.name,
    linkId: r.id,
    colors: r.colors || ['#C67F53'],  // Use multiple colors or fallback to default
    event_types: r.event_types || []
  })).filter(r => r.startDate.getFullYear() === parseInt(year));
  
  // Update global data variable
  data = dataSource;
  calendar.setDataSource(dataSource);
  
  // Apply custom stacking after year change
  setTimeout(() => {
    applyEventStacking(parseInt(year));
  }, 200);
}