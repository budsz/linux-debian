#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2019, Studio Family Karaoke.
# All rights reserved.
#

DEST="/home/budsz/0/PSK058"
TMP="/tmp/$(basename $0 .sh).tmp"
TYPE="ML"

# Function.
UP() {
    awk '{print tolower($0)}' |\
    awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1' |\
    perl -pe 's/\(./uc($&)/e'
}

RC() {
    sed \
        -e 's/[ ]FT[ ]/ ft\. /g' \
        -e 's/[ ]Ft[ ]/ ft\. /g' \
        -e 's/[ ]ft[ ]/ ft\. /g' \
        -e 's/[ ]FEAT[ ]/ ft\. /g' \
        -e 's/[ ]Feat[ ]/ ft\. /g' \
        -e 's/[ ]feat[ ]/ ft\. /g' \
        -e 's/[ ]FT\.[ ]/ ft\. /g' \
        -e 's/[ ]Ft\.[ ]/ ft\. /g' \
        -e 's/[ ]FEAT\.[ ]/ ft\. /g' \
        -e 's/[ ]Feat\.[ ]/ ft\. /g' \
        -e 's/[ ]feat\.[ ]/ ft\. /g'
}


find $DEST -type f | grep '#' > $TMP

while read -r field
do
    SINGER="$(echo $field | awk -F '/' '{print $NF}' | awk -F '#' '{print $2}' | UP | RC)"
    TITLE="$(echo $field | awk -F '/' '{print $NF}' | awk -F '#' '{print $1}' | UP)"
    KATEGORI="$(echo $field | awk -F '/' '{print $NF}' | awk -F '#' '{print $3}')"
    tKATEGORI="$(echo $KATEGORI | grep 'DANGDUT')"
    if [ -n "$tKATEGORI" ]; then
        KATEGORI="INDONESIA"
    fi
    EXT="$(echo $field | awk -F '.' '{print $NF}')"
    REFOM="$(echo $SINGER - $TITLE - $KATEGORI - $TYPE.$EXT)"
    BASED="$(dirname "$field")"
    mv -f "$field" "$BASED/$REFOM"
done < $TMP

rm -f $TMP
