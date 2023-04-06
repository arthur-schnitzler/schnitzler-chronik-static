# bin/bash

rm -rf data
wget https://github.com/arthur-schnitzler/schnitzler-tage/archive/refs/heads/main.zip
unzip main

mv ./schnitzler-tage-main/data .
rm -rf ./data/xslts
rm main.zip
rm -rf ./schnitzler-tage-main
