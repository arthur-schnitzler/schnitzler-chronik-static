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
        {"name": "projects", "type": "string[]", "facet": True, "optional": True},
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
        event_id = f"{doc_id}__{counter}"
        # projects = [
        #     x.replace("-", " ").title().replace("ae", "ä") for x in doc.any_xpath(".//tei:idno[@type]/@type")
        # ]
        item = {
            "id": event_id,
            "rec_id": f"{doc_id}.html",
            "title": f"{project}: {doc_id}",
            "full_text": full_text,
            "projects": [project]
        }
        records.append(item)

make_index = client.collections["schnitzler-chronik"].documents.import_(records)
print(make_index)
print("done with indexing schnitzler-chronik")

