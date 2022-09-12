#!/bin/bash

dir=

for opt in "$@"; do
  case ${opt} in
  --output-directory=*)
    dir=${opt#*=}
    ;;
  --help)
    display_help
    exit
    ;;
  *)
    display_help
    exit
    ;;
  esac
done

display_help() {
  echo "
Available options:
  --output-directory path of output directory
"
}

main() {
  rm -rf ./flasher && mkdir ./flasher

  cp ./factory/AllAppUpdate.bin ./flasher/AllAppUpdate.bin

  mkdir ./flasher/vital-app
  find AllAppUpdate_vital-app/ -type f -name '*.apk' | while read -r apk; do
    cp "$(realpath "$apk")" "./flasher/vital-app/$(basename "$apk")"
  done
  # mv ./AllAppUpdate_vital-app ./flasher/vital-app
  cd ./flasher || exit
  7z a -r -tzip -mx=0 -p048a02243bb74474b25233bda3cd02f8 ./AllAppUpdate.bin ./vital-app
  rm -rf ./vital-app
  7z d -r ./AllAppUpdate.bin app/190000004_com.syu.gallery
  # mv ./vital-app ../AllAppUpdate_vital-app
  cd ..
  cp -r ./lsec_updatesh ./flasher/
  cp ./factory/config.txt ./flasher/config.txt
  cp ./factory/updatecfg.txt ./flasher/updatecfg.txt
  cp ./factory/lsec6315update ./flasher/lsec6315update
  # cp -r ./oem_vital-app ./flasher/
  touch ./flasher/FLASH_WITH_THIS_ONE

  mkdir ./flasher/oem_vital-app
  find oem_vital-app/ -type f -name '*.apk' | while read -r apk; do
    apkname="$(basename "$apk")"
    cp "$(realpath "$apk")" "./flasher/oem_vital-app/$apkname"
    # shellcheck disable=SC2016
    subcmd='$(cat ./usbdir.txt)'
    cmd="cp \"$subcmd/oem_vital-app/$apkname\" /oem/vital-app/"
    sed -i "s|###REPLACE_TOKEN###|$cmd\n###REPLACE_TOKEN###|" ./flasher/lsec_updatesh/7862lsec.sh
  done

  # for app in ./flasher/oem_vital-app/*; do
  #   baseapp="$(basename "$app")"
  #   # shellcheck disable=SC2016
  #   subcmd='$(cat ./usbdir.txt)'
  #   cmd="cp \"$subcmd/oem_vital-app/$baseapp\" /oem/vital-app/"
  #   sed -i "s|###REPLACE_TOKEN###|$cmd\n###REPLACE_TOKEN###|" ./flasher/lsec_updatesh/7862lsec.sh
  # done

  cmd='chmod 644 /oem/vital-app/*'
  sed -i "s|###REPLACE_TOKEN###|$cmd|" ./flasher/lsec_updatesh/7862lsec.sh
}

if [ -z "$dir" ]; then
  main
else
  if [ ! -d "$dir" ]; then
    echo "$dir does not exist!"
  else
    if [ "$(ls -A $dir)" ]; then
      echo "$dir is not empty!"
    else
      main
      mv ./flasher/* "$dir/"
      rm -rf ./flasher
    fi
  fi
fi
