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
        
        // Create individual bars for each event type - stacked vertically
        eventsForDay[0].colors.forEach((color, index) => {
          const bar = document.createElement('div');
          bar.className = 'custom-event-bar';
          bar.style.backgroundColor = color;
          bar.style.height = '2px';
          bar.style.width = '100%';
          bar.style.display = 'block';
          bar.title = eventsForDay[0].event_types[index] || 'Event type';
          barsContainer.appendChild(bar);
        });
        
        dayEl.appendChild(barsContainer);
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