#!/bin/bash

rm -rf flasher && mkdir flasher

cp ./factory/AllAppUpdate.bin ./flasher/AllAppUpdate.bin
mv ./vital-app ./flasher/
cd ./flasher || exit
# 7z a AllAppUpdate.bin ./vital-app
7z a -r -tzip -mx=0 -p048a02243bb74474b25233bda3cd02f8 ./AllAppUpdate.bin ./vital-app
mv ./vital-app ../
cd ..
cp -r ./lsec_updatesh ./flasher/
cp ./factory/config.txt ./flasher/config.txt
cp ./factory/updatecfg.txt ./flasher/updatecfg.txt
cp ./factory/lsec6315update ./flasher/lsec6315update

# unzip -P 048a02243bb74474b25233bda3cd02f8 -d AllAppUpdate AllAppUpdate.zip
# rm ./AllAppUpdate.zip

# while read -r app; do
#   cp "./add/$app.apk" "./AllAppUpdate/$app.apk"
# done < <(jq -r '.add[]' ./flashconfig.json)

# cd ./add || exit
# for app in *; do
#   cp "./$app" "../AllAppUpdate/vital-app/$app"
# done

# /storage/sdcard1/7zzs a -r -tzip -mx=0 -p048a02243bb74474b25233bda3cd02f8 /storage/sdcard1/BACKUP/AllAppUpdate.bin /oem/app /oem/vital-app /oem/priv-app /oem/res /oem/Ver
# /usr/bin/7z

# jq -cr '.add[]' flashconfig.json
