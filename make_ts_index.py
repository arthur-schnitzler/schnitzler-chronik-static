import glob
import os
from typesense.api_call import ObjectNotFound
from acdh_cfts_pyutils import TYPESENSE_CLIENT as client
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm
from datetime import datetime

# Define a dictionary to map month numbers to German month names
german_months = {
    1: "Januar",
    2: "Februar",
    3: "März",
    4: "April",
    5: "Mai",
    6: "Juni",
    7: "Juli",
    8: "August",
    9: "September",
    10: "Oktober",
    11: "November",
    12: "Dezember",
}

# Get a list of XML files in the "./data/" directory
files = glob.glob("./data/*.xml")
resolver_url = "https://schnitzler-chronik.acdh.oeaw.ac.at/"


try:
    client.collections["schnitzler-chronik"].delete()
except ObjectNotFound:
    pass

current_schema = {
    "name": "schnitzler-chronik",
    "fields": [
        {"name": "id", "type": "string"},
        {"name": "rec_id", "type": "string"},
        {"name": "title", "type": "string"},
        {"name": "full_text", "type": "string"},
        {"name": "projects", "type": "string", "facet": True},
        {"name": "year", "type": "int32", "facet": True},
    ],
}

client.collections.create(current_schema)

records = []
counter = 0
for x in tqdm(files, total=len(files)):
    doc = TeiReader(x)
    nsmap = doc.nsmap
    doc_id = os.path.split(x)[-1].replace(".xml", "")
    doc_date = datetime.strptime(doc_id, "%Y-%m-%d")  # Assuming ISO date format
    formatted_date = f"{doc_date.day}. {german_months[doc_date.month]} {doc_date.year}"
    counter = 0
    for event in doc.any_xpath(".//tei:event"):
        counter += 1
        full_text = " ".join("".join(event.itertext()).split())
        project = event.xpath("./tei:idno[@type][1]/@type", namespaces=nsmap)[0]
        try:
            project_link = event.xpath("./tei:idno[@type][1]/text()", namespaces=nsmap)[0]
        except IndexError:
            project_link = ""
        event_id = f"{doc_id}__{counter}"
        year = int(f"{doc_id[:4]}")
        item = {
            "id": event_id,
            "rec_id": f"{doc_id}.html",
            "title": f"{project}: {formatted_date}",  # Use the formatted date in German
            "full_text": full_text,
            "projects": project,
            "year": year,
            "project_link": project_link
        }
        records.append(item)

make_index = client.collections["schnitzler-chronik"].documents.import_(records)
print(make_index)
print("done with indexing schnitzler-chronik")

