import glob
import os
import json
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm
import xml.etree.ElementTree as ET

# Load color mapping from list-of-relevant-uris.xml
def load_color_mapping():
    color_map = {}
    tree = ET.parse('./xslt/export/list-of-relevant-uris.xml')
    root = tree.getroot()
    for item in root.findall('item'):
        abbr = item.find('abbr')
        color = item.find('color')
        if abbr is not None and color is not None:
            color_map[abbr.text] = color.text
    return color_map

color_mapping = load_color_mapping()
files = sorted(glob.glob("./data/*.xml"))
out_file = "./html/js-data/calendarData.js"
data = []

for x in tqdm(files, total=len(files)):
    head, tail = os.path.split(x)
    doc = TeiReader(x)
    
    # Get the date from the title
    try:
        file_date = doc.any_xpath('//tei:title[@level="a"]/@when-iso')[0]
        day_name = doc.any_xpath('//tei:title[@level="a"]/text()')[0]
    except:
        continue
    
    # Extract all individual events from the listEvent
    events = doc.any_xpath('//tei:listEvent/tei:event')
    
    for event_element in events:
        try:
            # Get event details
            event_date = event_element.get('when-iso') or file_date
            
            # Try different XPath approaches for head
            event_heads = event_element.xpath('.//tei:head/text()', namespaces=doc.nsmap) 
            if not event_heads:
                event_heads = event_element.xpath('.//head/text()')
            if not event_heads:
                event_heads = event_element.xpath('.//*[local-name()="head"]/text()')
            
            event_head = event_heads[0] if event_heads else "Event"
            
            # Get the event type from idno - try different approaches
            idno_elements = event_element.xpath('.//tei:idno[@type]', namespaces=doc.nsmap)
            if not idno_elements:
                idno_elements = event_element.xpath('.//idno[@type]')
            if not idno_elements:
                idno_elements = event_element.xpath('.//*[local-name()="idno"][@type]')
                
            if idno_elements:
                idno_element = idno_elements[0]
                event_type = idno_element.get('type')
                event_url = idno_element.text or idno_element.get('href', '')
                
                if event_type and event_type in color_mapping:
                    item = {
                        "name": event_head,
                        "startDate": event_date,
                        "id": tail.replace(".xml", ".html"),  # Link to the day page
                        "event_types": [event_type],
                        "colors": [color_mapping[event_type]],
                        "url": event_url.strip() if event_url else None,
                        "day_name": day_name
                    }
                    data.append(item)
        except:
            continue

print(f"writing calendar data to {out_file}")
with open(out_file, "w", encoding="utf8") as f:
    my_js_variable = f"var calendarData = {json.dumps(data, ensure_ascii=False)}"
    f.write(my_js_variable)
