#!/bin/bash

# mkdir flashedwith
# find "$(pwd)" -maxdepth 1 ! -path "$(pwd)" | while read -r fullpath; do
#   if [ "$(basename "$fullpath")" != 'flashedwith' ]; then
#     mv "$fullpath" "flashedwith/$(basename "$fullpath")"
#   fi
# done

# fdroid="$(curl https://f-droid.org/api/v1/packages/org.fdroid.fdroid)"
# ver=$(jq -r '.suggestedVersionCode' <<<"${fdroid}")
# echo "${ver}"

# config="$(yq ./config.yaml)"
# echo "$config" | yq '.all_app_update | has("fdroid")'
# echo "$config" | yq '.all_app_update.apkmirror[]'
# echo "$config" | yq '.all_app_update.apkmirror[]'
# echo "$config" | yq '.remove[]'

# all_app_update() {
#   echo "all_app_update: $1"
# }

# oem() {
#   echo "oem: $1"
# }

# install() {
#   echo "install: $1"
# }

# remove() {
#   echo "remove: $1"
# }

# for_each() {
#   while read -r package; do
#     echo "$1 $package"
#   done < <(yq -r "$2" ./config.yaml)
# }

# is_null() {
#   result=$("$1")
#   if [ null == "$result" ]; then
#     return 1
#   else
#     return 0
#   fi
# }

# add_all_app_update() {
#   for app in $1; do
#     echo "add_all_app_update $app"
#   done
# }

# add_oem() {
#   for app in $1; do
#     echo "add_oem $app"
#   done
# }

function remove() {
  for app in $1; do
    echo "removing $app..."
  done
  echo ""
  return 0
}

function cache_fdroid() {
  package_name="$1"
  version_code="$2"

  is_cached 'fdroid' "$package_name" "$version_code"
  if [ 1 -ne $? ]; then
    cache_create 'fdroid' "$package_name"
    curl -o "$(cache_get_path 'fdroid' "$package_name" "$version_code")" "https://f-droid.org/repo/${package_name}_$version_code.apk"
  fi
  return 0
}

# function cache() {
#   source="$1"
#   package_name="$2"
#   version_code="$3"
#   fdroid_apk_url="$4"
#   if [ "$(type -t "cache_$source")" == function ]; then
#     "cache_$source" "$package_name" "$version_code" "$fdroid_apk_url"
#   fi
#   return 0
# }

function cache_create() {
  [ ! -d .cache ] && mkdir .cache

  source="$1"
  package_name="$2"

  if [ -n "$source" ]; then
    [ ! -d ".cache/$source" ] && mkdir ".cache/$source"
      if [ -n "$package_name" ]; then
        [ ! -d ".cache/$source/$package_name" ] && mkdir ".cache/$source/$package_name"
      fi
  fi
  return 0
}

function cache_get_path() {
  source="$1"
  package_name="$2"
  version_code="$3"

  echo ".cache/$source/$package_name/$version_code.apk"
  return 0
}

function is_cached() {
  source="$1"
  package_name="$2"
  version_code="$3"

  if [ -f "$(cache_get_path "$source" "$package_name" "$version_code")" ]; then
    return 1
  fi
  return 0
}

function get_version_code_from_local_apk() {
  apk_path="$1"

  # shellcheck disable=SC2005
  echo "$(cut -d'.' -f1 <<<"$(cut -d'/' -f2 <<<"$apk_path")")"
  return 0
}

function get_package_name_from_local_apk() {
  apk_path="$1"

  # shellcheck disable=SC2005
  echo "$(cut -d'/' -f1 <<<"$apk_path")"
  return 0
}

function get_fdroid_suggested_version_code () {
  package_name="$1"

  # shellcheck disable=SC2005
  echo "$(curl -s "https://f-droid.org/api/v1/packages/$package_name" | jq '.suggestedVersionCode')"
  return 0
}

function add_fdroid_all_app_update () {
  package_name="$1"
  version_code="$2"

  if [ -z "$version_code" ]; then
    version_code="$(get_fdroid_suggested_version_code "$package_name")"
    if [ 'null' == "$version_code" ]; then
      echo "unable to find suggested version of package with name: $package_name. does it exist on fdroid?"
      echo ""
      return 1
    fi
  fi

  cache_fdroid "$package_name" "$version_code"
  add_all_app_update 'fdroid' "$package_name" "$version_code" "$(cache_get_path 'fdroid' "$package_name" "$version_code")"
  return 0
}

function add_fdroids_all_app_update() {
  package_names="$1"

  for package_name in $package_names; do
    add_fdroid_all_app_update "$package_name"
  done
  return 0
}

function ask_yes_no () {
  question="$1"

  while true; do
      read -r -p "$question [y/n] " answer
      if [ "$answer" == "y" ];then
          break
      elif [ "$answer" == "n" ];then
          break
      else
          echo 'press y for yes or n for no, then press enter'
      fi
  done
  echo "$answer"
  return 0
}

function add_all_app_update() {
  source="$1"
  package_name="$2"
  version_code="$3"
  apk_path="$4"

  echo "adding $source package $package_name:$version_code to AllAppUpdate.bin/vital-app/"
  echo ""
  return 0
}

function add_all_app_update_local() {
  apk_paths="$1"

  for apk_path in $apk_paths; do
    version_code="$(get_version_code_from_local_apk "$apk_path")"
    package_name="$(get_package_name_from_local_apk "$apk_path")"
    fdroid_suggested_version_code="$(get_fdroid_suggested_version_code "$package_name")"
    if [ "$fdroid_suggested_version_code" -gt "$version_code" ]; then
      echo "fdroid has a newer version of $package_name: $fdroid_suggested_version_code. your local apk is version $version_code."
      use_newer_version=$(ask_yes_no 'do you want to use the newer version from fdroid?')
      if [ "$use_newer_version" == "y" ]; then
        add_fdroid_all_app_update "$package_name" "$version_code"
      else
        add_all_app_update 'local' "$package_name" "$version_code" "local/$apk_path"
      fi
    fi
  done
  return 0
}

function main() {
  [ -d .tmp ] && rm -rf .tmp
  mkdir .tmp

  config=$(yq . ./config.yaml)

  remove=$(echo "$config" | yq '.remove')
  if [ 'null' != "$remove" ]; then
    remove "$(echo "$remove" | yq -r '.[]')"
  fi

  add=$(echo "$config" | yq '.add')
  if [ 'null' != "$add" ]; then
    all_app_update=$(echo "$add" | yq -r '.all_app_update')
    if [ 'null' != "$all_app_update" ]; then
      local=$(echo "$all_app_update" | yq -r '.local')
      if [ 'null' != "$local" ]; then
        add_all_app_update_local "$(echo "$local" | yq -r '.[]')"
      fi
      fdroid=$(echo "$all_app_update" | yq -r '.fdroid')
      if [ 'null' != "$fdroid" ]; then
        add_fdroids_all_app_update "$(echo "$fdroid" | yq -r '.[]')"
      fi
    fi
  fi

  [ -d .tmp ] && rm -rf .tmp
  return 0
}

main
