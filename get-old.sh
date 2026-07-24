#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2025, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
#WORKDIR="TMP"
BASEDIR="/home/`whoami`/$WORKDIR"
#RANFN="$(date "+%s" | md5sum | cut -c 1-7)"
RANFN="$(tr -dc '0-9a-z' < /dev/urandom | head -c 7)"
YTOPT="--no-warnings --force-overwrites -4 --cookies-from-browser firefox:~/.mozilla/firefox/"
RANDE="1-2"
_tmpfile="/tmp/$(basename $0 .sh)-$RANFN.tmp"

# Include function.
. "$(dirname $0)/cc-function.sh"       # CC() function include file.

#IDX="$(echo "$1" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]')"
#IDX="$(echo "$1" | tr '[:upper:]' '[:lower:]' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1')"
IDX1="$(echo "$1" | awk -F ' - ' '{print $1}' | CC)"
IDX2="$(echo "$1" | awk -F ' - ' '{print $2}' | CC)"
IDX3="$(echo "$1" | awk -F ' - ' '{print $3}' | CC | tr '[:lower:]' '[:upper:]')"
IDX="$(echo "${IDX1} - ${IDX2} - ${IDX3}" | sed 's/  */ /g')"

URL="$2"

# Move to basedir.
if [ ! -d "$BASEDIR" ]; then
    mkdir $BASEDIR
    cd $BASEDIR
else
    cd $BASEDIR
fi

# Grab all available list of audio/video format.
yt-dlp $YTOPT -F $URL > $_tmpfile

# Grab audio format base on list.
awebm="$(grep 'audio only' $_tmpfile | grep -v 'Untested' | grep 'webm' | awk '{print $1}')"
am4a="$(grep 'audio only' $_tmpfile | grep -v 'Untested' | grep 'm4a' | awk '{print $1}')"
amp4="$(grep 'audio only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | awk '{print $1}')"

# Make sure one of audio format already exists in filelist.
c=0
while [ -z "$awebm" -a -z "$am4a" -a -z "$amp4" ] && [ "$c" -le "5" ];
do
    yt-dlp $YTOPT -F $URL > $_tmpfile
    awebm="$(grep 'audio only' $_tmpfile | grep -v 'Untested' | grep 'webm' | awk '{print $1}')"
    am4a="$(grep 'audio only' $_tmpfile | grep -v 'Untested' | grep 'm4a' | awk '{print $1}')"
    amp4="$(grep 'audio only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | awk '{print $1}')"
    c=$((c + 1))
done

# Download audio clip.
## Priority base on audio quality.
if [ -n "$awebm" ]; then
    echo "$awebm" | tail -n 1 | while read -r awebm
    do
        yt-dlp $YTOPT -f $awebm -o "aud-$IDX.webm" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $awebm -o "aud-$IDX.webm" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$am4a" ]; then
    echo "$am4a" | tail -n 1 | while read -r am4a
    do
        yt-dlp $YTOPT -f $am4a -o "aud-$IDX.m4a" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $am4a -o "aud-$IDX.m4a" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$amp4" ]; then
    echo "$amp4" | tail -n 1 | while read -r amp4
    do
        yt-dlp $YTOPT -f $amp4 -o "aud-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $amp4 -o "aud-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
else
    yt-dlp $YTOPT -x --audio-format mp3 --audio-quality 0 -o "aud-$IDX.mp3" $URL
fi

# Grab video format base on list.
vs12xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '12[0-9][0-9]x' | awk '{print $1}')"
vs10xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '10[0-9][0-9]x' | awk '{print $1}')"
vs8xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '8[0-9][0-9]x' | awk '{print $1}')"
vs7xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '7[0-9][0-9]x' | awk '{print $1}')"
vs6xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '6[0-9][0-9]x' | awk '{print $1}')"
vs5xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '5[0-9][0-9]x' | awk '{print $1}')"
vs4xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '4[0-9][0-9]x' | awk '{print $1}')"
vs3xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '3[0-9][0-9]x' | awk '{print $1}')"

# Make sure one of video format already exists in filelist.
c=0
while [ -z "$vs12xx" -a -z "$vs10xx" -a -z "$vs8xx" -a -z "$vs7xx" -a -z "$vs6xx" -a -z "$vs5xx" -a -z "$vs4xx" -a -z "$vs3xx" ] && [ "$c" -le "5" ];
do
    yt-dlp $YTOPT -F $URL > $_tmpfile
    vs12xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '12[0-9][0-9]x' | awk '{print $1}')"
    vs10xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '10[0-9][0-9]x' | awk '{print $1}')"
    vs8xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '8[0-9][0-9]x' | awk '{print $1}')"
    vs7xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '7[0-9][0-9]x' | awk '{print $1}')"
    vs6xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '6[0-9][0-9]x' | awk '{print $1}')"
    vs5xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '5[0-9][0-9]x' | awk '{print $1}')"
    vs4xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '4[0-9][0-9]x' | awk '{print $1}')"
    vs3xx="$(grep 'video only' $_tmpfile | grep -v 'Untested' | grep 'mp4' | egrep -v 'vp[0-9][0-9]?' | grep '3[0-9][0-9]x' | awk '{print $1}')"
    c=$((c + 1))
done

# Download video clip.
## Priority base on video size.
if [ -n "$vs12xx" ]; then
    echo "$vs12xx" | tail -n 1 | while read -r dv12xx
    do
        yt-dlp $YTOPT -f $dv12xx -o "vid-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $dv12xx -o "vid-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$vs10xx" ]; then
    echo "$vs10xx" | tail -n 1 | while read -r dv10xx
    do
        yt-dlp $YTOPT -f $dv10xx -o "vid-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $dv10xx -o "vid-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$vs8xx" ]; then
    echo "$vs8xx" | tail -n 1 | while read -r dv8xx
    do
        yt-dlp $YTOPT -f $dv8xx -o "vid-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $dv8xx -o "vid-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$vs7xx" ]; then
    echo "$vs7xx" | tail -n 1 | while read -r dv7xx
    do
        yt-dlp $YTOPT -f $dv7xx -o "vid-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $dv7xx -o "vid-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$vs6xx" ]; then
    echo "$vs6xx" | tail -n 1 | while read -r dv6xx
    do
        yt-dlp $YTOPT -f $dv6xx -o "vid-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $dv6xx -o "vid-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$vs5xx" ]; then
    echo "$vs5xx" | tail -n 1 | while read -r dv5xx
    do
        yt-dlp $YTOPT -f $dv5xx -o "vid-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $dv5xx -o "vid-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$vs4xx" ]; then
    echo "$vs4xx" | tail -n 1 | while read -r dv4xx
    do
        yt-dlp $YTOPT -f $dv4xx -o "vid-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $dv4xx -o "vid-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
elif [ -n "$vs3xx" ]; then
    echo "$vs3xx" | tail -n 1 | while read -r dv3xx
    do
        yt-dlp $YTOPT -f $dv3xx -o "vid-$IDX.mp4" $URL

        cproc="$(echo $?)"
        if [ $cproc -eq "1" ]; then
            until [ $cproc -eq "0" ]
            do
                yt-dlp $YTOPT -f $dv3xx -o "vid-$IDX.mp4" $URL
                sleep `shuf -i $RANDE -n 1`
                cproc="$(echo $?)"
            done
        fi
    done
else
    echo "Video format not available!"
fi

## Last choise.
#if [ $? -ne "0" ]; then
#	yt-dlp $YTOPT -f 18 -o "vid-$IDX.mp4" $URL
#	ffmpeg -hide_banner -y -i "vid-$IDX.mp4" -c copy -an "t-vid-$IDX.mp4"
#	mv -f "t-vid-$IDX.mp4" "vid-$IDX.mp4"
#fi

# Remove ${_tmpfile}.
rm -f ${_tmpfile}

# CD current directory.
cd

# Line Separator.
echo " "
