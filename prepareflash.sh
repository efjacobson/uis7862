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
  rm ./AllAppUpdate_vital-app/.gitkeep
  rm ./oem_vital-app/.gitkeep
  rm -rf ./flasher && mkdir ./flasher

  cp ./factory/AllAppUpdate.bin ./flasher/AllAppUpdate.bin
  mv ./AllAppUpdate_vital-app ./flasher/vital-app
  cd ./flasher || exit
  7z a -r -tzip -mx=0 -p048a02243bb74474b25233bda3cd02f8 ./AllAppUpdate.bin ./vital-app
  7z d -r ./AllAppUpdate.bin app/190000004_com.syu.gallery
  mv ./vital-app ../AllAppUpdate_vital-app
  cd ..
  cp -r ./lsec_updatesh ./flasher/
  cp ./factory/config.txt ./flasher/config.txt
  cp ./factory/updatecfg.txt ./flasher/updatecfg.txt
  cp ./factory/lsec6315update ./flasher/lsec6315update
  cp -r ./oem_vital-app ./flasher/
  touch ./flasher/FLASH_WITH_THIS_ONE

  for app in ./flasher/oem_vital-app/*; do
    baseapp="$(basename "$app")"
    # shellcheck disable=SC2016
    subcmd='$(cat ./usbdir.txt)'
    cmd="cp \"$subcmd/oem_vital-app/$baseapp\" /oem/vital-app/"
    sed -i "s|###REPLACE_TOKEN###|$cmd\n###REPLACE_TOKEN###|" ./flasher/lsec_updatesh/7862lsec.sh
  done

  cmd='chmod 644 /oem/vital-app/*'
  sed -i "s|###REPLACE_TOKEN###|$cmd|" ./flasher/lsec_updatesh/7862lsec.sh

  touch ./AllAppUpdate_vital-app/.gitkeep
  touch ./oem_vital-app/.gitkeep
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
