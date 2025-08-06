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
    item = {}
    head, tail = os.path.split(x)
    doc = TeiReader(x)
    item["name"] = doc.any_xpath('//tei:title[@level="a"]/text()')[0]
    try:
        item["startDate"] = doc.any_xpath('//tei:title[@level="a"]/@when-iso')[0]
    except:
        continue
    try:
        item["id"] = tail.replace(".xml", ".html")
        
        # Extract event types for this date
        event_types = []
        idno_elements = doc.any_xpath('//tei:idno[@type]')
        for idno in idno_elements:
            event_type = idno.get('type')
            if event_type and event_type in color_mapping:
                if event_type not in event_types:
                    event_types.append(event_type)
        
        item["event_types"] = event_types
        # Get colors for the event types
        item["colors"] = [color_mapping[et] for et in event_types if et in color_mapping]
        
        data.append(item)
    except:
        continue

print(f"writing calendar data to {out_file}")
with open(out_file, "w", encoding="utf8") as f:
    my_js_variable = f"var calendarData = {json.dumps(data, ensure_ascii=False)}"
    f.write(my_js_variable)
