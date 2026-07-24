#!/bin/dash
rdate="$(date --date="yesterday" +"%d-%m-%Y")"
rserv="rsync://10.20.30.1"

for folder in backup-db backup-gam
do
    for xkey in $rdate mysql
    do
        rsync --list-only $rserv/$folder | \
        awk -v skey="$xkey" '{if ($5 ~ skey) print $5}' | \
        rsync -avPt --delete --files-from=- $rserv/$folder/ ~/$folder/
    done
done
