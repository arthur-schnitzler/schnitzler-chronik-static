import glob
import os
from typesense.api_call import ObjectNotFound
from acdh_cfts_pyutils import TYPESENSE_CLIENT as client
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm


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
            "title": f"{project}: {doc_id}",
            "full_text": full_text,
            "projects": project,
            "year": year,
            "project_link": project_link
        }
        records.append(item)

make_index = client.collections["schnitzler-chronik"].documents.import_(records)
print(make_index)
print("done with indexing schnitzler-chronik")

