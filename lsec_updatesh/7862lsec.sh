#!/system/bin/sh

rm -rf /storage/sdcard1/flashreport
mkdir -p /storage/sdcard1/flashreport

ls -lR /data/ >/storage/sdcard1/flashreport/data_listing.txt
ls -lR /dev/ >/storage/sdcard1/flashreport/dev_listing.txt
ls -lR /system/ >/storage/sdcard1/flashreport/system_listing.txt
ls -lR /sys/ >/storage/sdcard1/flashreport/sys_listing.txt
ls -lR /oem/ >/storage/sdcard1/flashreport/oem_listing.txt
ls -lR /vendor/ >/storage/sdcard1/flashreport/vendor_listing.txt
ls -lR /sbin/ >/storage/sdcard1/flashreport/sbin_listing.txt

# rm -rf /oem/app/190000000_com.android.calculator2
# pm install /storage/sdcard1/flashfiles/totalcommander.apk

find / -name "*calculator*" >/storage/sdcard1/flashreport/find1.txt
find /data/ -name "*calculator*" >/storage/sdcard1/flashreport/find2.txt

echo "$PATH" >/storage/sdcard1/flashreport/path.txt

mount -o remount,rw /data
ls -lR /data/ >/storage/sdcard1/flashreport/data_listing2.txt
find /data/ -name "*calculator*" >/storage/sdcard1/flashreport/find3.txt

# /oem/app/190000000_com.android.calculator2
# /oem/app/190000000_com.android.calculator2/190000000_com.android.calculator2.apk
# /storage/sdcard1/SPELUNK/find_calculator.txt

# FYT apps
# rm -rf /oem/app/190000000_com.android.calculator2
# rm -f /data/dalvik-cache/x86_64/oem@app@190000000_com.android.calculator2*
# rm -rf /data/data/com.android.calculator2
# rm -rf /data/system/package_cache/1/190000000_com.android.calculator2*
