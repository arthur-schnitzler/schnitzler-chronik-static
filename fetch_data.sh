# bin/bash

rm -rf data
wget https://github.com/arthur-schnitzler/schnitzler-tage/archive/refs/heads/main.zip
unzip main

mv ./schnitzler-tage-main/editions/data .
rm -rf ./data/xslts
rm main.zip
rm -rf ./schnitzler-tage-main

echo "delete schema reference"
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@xsi:schemaLocation="http://www.tei-c.org/ns/1.0 ../meta/asbwschema.xsd"@@g'
