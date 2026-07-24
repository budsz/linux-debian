#!/usr/bin/env dash
# IT Support & Development.
# Copyright (c) 2020, Studio Family Karaoke.
# All rights reserved.
#

# Debug mode.
#set -x

_dbname="vsong"
_tblname="masters"
_BPATH="/mnt/data/vsong"
_dirdest="*"
#_inputfile="/root/input.txt"    # Please input PATH from FS (File System) without /mnt/data/vsong.
_tmpfile="/tmp/$(basename $0 .sh).tmp"
_IDMUSIC="0"                    # Auto-increment.
_VCD="xVCD-SFK-MS"
_DISC="eDISC-SFK-MS"
_FLAG="Y"                       # Y/N to display in room playlist.
_VOL="70"                       # Adjust maximum volume.
_HOLD="0"
_CHTIME="1"
_INPUTBY="IT"
_STATFILE="ADA"

# SQL function.
SQL() {
    mysql -uroot -pbandung -e "INSERT INTO ${_dbname}.${_tblname} (
        IDMUSIC,
        VCD,
        TITLE,
        SINGER,
        DISC,
        PATH,
        ANALOG,
        TYPE,
        WORD,
        TIME,
        FLAG,
        VOL,
        ISHOUSE,
        HOLD,
        CHUSR,
        CHTIME,
        PROD,
        INPUTBY,
        statfile
    ) VALUES (
        '${_IDMUSIC}',
        '${_VCD}',
        '${_TITLE}',
        '${_SINGER}',
        '${_DISC}',
        '${_PATH}',
        '${_ANALOG}',
        '${_TYPE}',
        NULL,
        '${_TIME}',
        '${_FLAG}',
        '${_VOL}',
        NULL,
        '${_HOLD}',
        NULL,
        '${_CHTIME}',
        NULL,
        '${_INPUTBY}',
        '${_STATFILE}'
    );"
}

# Reformating output function.
UP() {
    awk '{print tolower($0)}' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1' | perl -pe 's/\(./uc($&)/e'
    #sed -e "s/\b./\u\0/g"
}

RF() {
    #sed 's/\.[^.]*$//g'
    #sed 's/^ //g; s/ $//g; s/( /(/g; s/ )/)/g; s/\.//g'
    sed -E \
        -e 's/^[ ]//g' \
        -e 's/[ ]$//g' \
        -e 's/[(][ ]/(/g' \
        -e 's/[ ][)]/)/g' \
        -e 's/[ ]+/ /g' \
        -e 's/_/-/g' \
        -e 's/'\''/\\'\''/g'
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

# Generate filelist.
find ${_BPATH}/${_dirdest}/ -type f | sed -e 's/\/mnt\/data\/vsong\///' > ${_tmpfile}

# Split field.
while read -r field
do
    if [ -n "${field}" ]; then

        # SINGER.
        #_SINGER="$(echo "${field}" | awk -F '/' '{print $NF}' | awk -F '#\|-' '{print $1}' | UP | RF | RC)"
        _SINGER="$(echo "${field}" | awk -F '/' '{print $NF}' | awk -F '#|-' '{print $1}' | RF | RC)"

        # TITLE.
        #_TITLE="$(echo "${field}" | awk -F '/' '{print $NF}' | awk -F '#\|-' '{print $2}' | UP | RF)"
        _TITLE="$(echo "${field}" | awk -F '/' '{print $NF}' | awk -F '#|-' '{print $2}' | RF | RC)"

        # ANALOG.
        _ANALOG="$(echo "${field}" | awk -F '/' '{print $NF}' | awk -F '#|-' '{print $4}' | cut -d '.' -f 1 | RF)"
        _cANALOG="$(echo ${#_ANALOG})"

        if [ -z "${_ANALOG}" ] || [ "${_cANALOG}" -gt "2" ]; then
            _ANALOG="ML"
        fi

        # PATH.
        _PATH="$(echo "${field}" | sed 's/\//\\\\/g;s/'\''/\\'\''/g')"  # We need double escape backslash to write backslash Windows path separator.

        # TYPE.
        # 0 = UNDEFINED, 1 = INDONESIA, 2 = BARAT,  3 = MANDARIN,  4 = ANAK,    5 = MALAYSIA,
        # 6 = INDIA,     7 = DAERAH,    8 = JEPANG, 9 = KOREA,    10 = ROHANI, 11 = HOUSE.
        _TYPEV="$(echo "${field}" | awk -F '/' '{print $NF}' | awk -F '#|-' '{print $3}' | sed 's/^[ ]//g; s/[ ]$//g')"
        _TYPEID="$(echo "${field}" | grep "/INDONESIA/")"
        _TYPEBT="$(echo "${field}" | grep "/BARAT/")"
        _TYPECN="$(echo "${field}" | grep "/MANDARIN/")"
        _TYPEAK="$(echo "${field}" | grep "/ANAK/")"
        _TYPEMY="$(echo "${field}" | grep "/MALAYSIA/")"
        _TYPEIN="$(echo "${field}" | grep "/INDIA/")"
        _TYPEDH="$(echo "${field}" | grep "/DAERAH/")"
        _TYPEJP="$(echo "${field}" | egrep "/JEPANG/|/JAPAN/")"
        _TYPEKR="$(echo "${field}" | grep "/KOREA/")"
        _TYPERI="$(echo "${field}" | grep "/ROHANI/")"
        _TYPEHS="$(echo "${field}" | grep "/HOUSE/")"

        if [ "${_TYPEV}" = "INDONESIA" ] || [ -n "${_TYPEID}" ]; then
            _TYPE="1"
        elif [ "${_TYPEV}" = "BARAT" ] || [ -n "${_TYPEBT}" ]; then
            _TYPE="2"
        elif [ "${_TYPEV}" = "MANDARIN" ] || [ -n "${_TYPECN}" ]; then
            _TYPE="3"
        elif [ "${_TYPEV}" = "ANAK" ] || [ -n "${_TYPEAK}" ]; then
            _TYPE="4"
        elif [ "${_TYPEV}" = "MALAYSIA" ] || [ -n "${_TYPEMY}" ]; then
            _TYPE="5"
        elif [ "${_TYPEV}" = "INDIA" ] || [ -n "${_TYPEIN}" ]; then
            _TYPE="6"
        elif [ "${_TYPEV}" = "DAERAH" ] || [ -n "${_TYPEDH}" ]; then
            _TYPE="7"
        elif [ "${_TYPEV}" = "JEPANG" ] || [ -n "${_TYPEJP}" ]; then
            _TYPE="8"
        elif [ "${_TYPEV}" = "KOREA" ] || [ -n "${_TYPEKR}" ]; then
            _TYPE="9"
        elif [ "${_TYPEV}" = "ROHANI" ] || [ -n "${_TYPERI}" ]; then
            _TYPE="10"
        elif [ "${_TYPEV}" = "HOUSE" ] || [ -n "${_TYPEHS}" ]; then
            _TYPE="11"
        else
            _TYPE="0"
        fi

        # TIME.
        _TIME="1970-01-01"

        # Test for exist database entry.
        _PATHx="$(mysql -uroot -pbandung -e "SELECT PATH FROM ${_dbname}.${_tblname} WHERE PATH = '${_PATH}' LIMIT 1;")"

        if [ -z "${_PATHx}" ]; then
            SQL
        else
            continue
        fi
    else
        continue
    fi
done < ${_tmpfile}

# Create new masters table.
#/bin/sh /root/x/mysql-dump-masters-table.sh > /dev/null

# Remove $_tmpfile.
rm -f ${_tmpfile}
