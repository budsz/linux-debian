#!/usr/bin/dash

while read row
do
    folder="$(dirname "$row")"
    mkdir -p "$folder"; echo "$folder" &&
    touch "$row"; echo "$row"
done < /home/budsz/listfile.txt
