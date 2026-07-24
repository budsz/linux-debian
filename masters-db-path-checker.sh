#!/usr/bin/env dash
# IT Support & Development.
# Copyright (c) 2020, Studio Family Karaoke.
# All rights reserved.
#

_dbname="vsong"
_tblname="masters"
_BPATH="/mnt/data/vsong"
_SQLUP="-uroot -pbandung"
_tmpfile="/tmp/$(basename $0 .sh).tmp"

mysql $_SQLUP -Bs --raw -e "SELECT PATH FROM $_dbname.$_tblname;" > $_tmpfile
sed -i 's/\\/\//g' $_tmpfile
while read path; do test -f "$_BPATH"/"$path"; echo $? $path; done < $_tmpfile | awk '$1 == 1'
rm -f $_tmpfile
