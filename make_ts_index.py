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
for x in tqdm(files, total=len(files)):
    doc = TeiReader(x)
    doc_id = os.path.split(x)[-1].replace("xml", "")
    body = doc.any_xpath(".//tei:body")[0]
    full_text = " ".join("".join(body.itertext()).split())
    title = doc.any_xpath(".//tei:title[@when-iso]/text()")[0]
    projects = [
        x.replace("-", " ").title() for x in doc.any_xpath(".//tei:idno[@type]/@type")
    ]
    item = {
        "id": doc_id,
        "rec_id": f"{resolver_url}{doc_id}.html",
        "title": title,
        "full_text": full_text,
        "projects": projects,
    }
    records.append(item)

make_index = client.collections["schnitzler-chronik"].documents.import_(records)
print(make_index)
print("done with indexing schnitzler-chronik")
