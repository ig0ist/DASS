#!/bin/sh

echo "remount_ro..."
sync
/fs/rwdata/dev/remount_ro.sh
sync
echo "sleep..."
sleep 1
sync
echo "reboot..."
/fs/rwdata/dev/utserviceutility reboot