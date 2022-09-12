#!/system/bin/sh

# variables are not allowed, so jank something up using text in files
find / -name "*FLASH_WITH_THIS_ONE*" >./usbdir.txt
sed -i 's|/FLASH_WITH_THIS_ONE||' ./usbdir.txt
rm "$(cat ./usbdir.txt)/FLASH_WITH_THIS_ONE"

date +%s >./resultsfolder.txt # this is likely redundant
echo "$(cat ./usbdir.txt)/$(cat ./resultsfolder.txt)" >./resultsdir.txt
mkdir -p "$(cat ./resultsdir.txt)"
# end "variable" jank

###REPLACE_TOKEN###
# see if you can get a loop working properly instead of this jank ^^

ls -laR /data/ >"$(cat ./resultsdir.txt)/data_listing.txt"
ls -laR /dev/ >"$(cat ./resultsdir.txt)/dev_listing.txt"
ls -laR /system/ >"$(cat ./resultsdir.txt)/system_listing.txt"
ls -laR /sys/ >"$(cat ./resultsdir.txt)/sys_listing.txt"
ls -laR /oem/ >"$(cat ./resultsdir.txt)/oem_listing.txt"
ls -laR /vendor/ >"$(cat ./resultsdir.txt)/vendor_listing.txt"
ls -laR /sbin/ >"$(cat ./resultsdir.txt)/sbin_listing.txt"
ls -laR /storage/ >"$(cat ./resultsdir.txt)/storage_listing.txt"
ls -laR /cache/ >"$(cat ./resultsdir.txt)/cache_listing.txt"

find / -type d -name "*190000000_com.android.calculator2" -exec rm -rf {} \;

echo "$PATH" >"$(cat ./resultsdir.txt)/path.txt"
pwd >"$(cat ./resultsdir.txt)/pwd.txt"

mkdir -p "$(cat ./resultsdir.txt)/flashedwith"
find "$(pwd)" -maxdepth 1 ! -path "$(pwd)" | while read -r fullpath; do
  if [ "$(basename "$fullpath")" != 'flashedwith' ]; then
    mv "$fullpath" "$(cat ./resultsdir.txt)/flashedwith/$(basename "$fullpath")"
  fi
done

# mkdir -p "$(cat ./resultsdir.txt)/flasher"
# mv "$(cat ./usbdir.txt)/AllAppUpdate.bin" "$(cat ./resultsdir.txt)/flasher/"
# mv "$(cat ./usbdir.txt)/config.txt" "$(cat ./resultsdir.txt)/flasher/"
# mv "$(cat ./usbdir.txt)/lsec6315update" "$(cat ./resultsdir.txt)/flasher/"
# mv "$(cat ./usbdir.txt)/updatecfg.txt" "$(cat ./resultsdir.txt)/flasher/"
# mv "$(cat ./usbdir.txt)/lsec_updatesh" "$(cat ./resultsdir.txt)/flasher/"
# mv "$(cat ./usbdir.txt)/oem_vital-app" "$(cat ./resultsdir.txt)/flasher/"

# clean up "variable" jank
rm ./resultsfolder.txt
rm ./resultsdir.txt
rm ./usbdir.txt
