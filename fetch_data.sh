# bin/bash

rm -rf data
wget https://github.com/arthur-schnitzler/schnitzler-bahr-data/archive/refs/heads/main.zip
unzip main

mv ./schnitzler-bahr-data-main/data .
rm -rf ./data/xslts
rm main.zip
rm -rf ./schnitzler-bahr-data-main

echo "delete schema reference"
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@<?xml-model href="../../schema/HBAS_diaries.odd.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>@@g'

echo "fixing entitiy ids"
find ./data/indices/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@<person xml:id="person__@<person xml:id="pmb@g'

echo "create calendar data"
python make_calendar_data.py

echo "add mentions to register-files"
python add_mentions.py
