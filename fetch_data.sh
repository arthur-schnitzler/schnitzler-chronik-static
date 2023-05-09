# bin/bash

rm -rf data
wget https://github.com/arthur-schnitzler/schnitzler-chronik-data/archive/refs/heads/main.zip
unzip main

mv ./schnitzler-chronik-data-main/editions/data .
rm -rf ./data/xslts
rm main.zip
rm -rf ./schnitzler-chronik-data-main

