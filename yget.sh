#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2025, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
#WORKDIR="TMP"
BASEDIR="/home/`whoami`/$WORKDIR"
FFOPT="-hide_banner -loglevel error -y"
RANFN="$(tr -dc '0-9a-z' < /dev/urandom | head -c 7)"
YTOPT="--no-warnings --force-overwrites -4 --cookies-from-browser firefox:~/.mozilla/firefox/"
#YTOPT="--no-warnings --force-overwrites -4"
_tmpfile="/tmp/$(basename $0 .sh)-$RANFN.tmp"

# Include function.
. "$(dirname $0)/cc-function.sh"       # CC() function include file.

#IDX="$(echo "$1" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]')"
#IDX="$(echo "$1" | tr '[:upper:]' '[:lower:]' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1')"
IDX1="$(echo "$1" | iconv -f UTF-8 -t ASCII//TRANSLIT | CC | awk -F ' - ' '{print $1}')"
IDX2="$(echo "$1" | iconv -f UTF-8 -t ASCII//TRANSLIT | CC | awk -F ' - ' '{print $2}')"
IDX3="$(echo "$1" | CC | tr '[:lower:]' '[:upper:]' | awk -F ' - ' '{print $3}')"
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
yt-dlp $YTOPT -F "$URL" > $_tmpfile

# Grab audio format base on list.
awebmf="$(grep 'audio only' $_tmpfile | grep 'medium, webm_dash' | tail -n1 | awk '{print $1}')"
am4af="$(grep 'audio only' $_tmpfile | grep 'medium, m4a_dash' | tail -n1 | awk '{print $1}')"

# Grab video format base on list.
#vs480p="$(grep 'video only' $_tmpfile | grep -w '480.*, mp4_dash' | awk '{print $1}')"
vs360p="$(grep 'video only' $_tmpfile | grep -w '360.*, mp4_dash' | awk '{print $1}')"
vs240p="$(grep 'video only' $_tmpfile | grep -w '240.*, mp4_dash' | awk '{print $1}')"

#vs8xx="$(grep '8[0-9][0-9]x' $_tmpfile | grep -w 'mp4' | grep 'mp4a' | awk '{print $1}')"
vs6xx="$(grep '6[0-9][0-9]x' $_tmpfile | grep -w 'mp4' | grep 'mp4a' | awk '{print $1}')"
vs3xx="$(grep '3[0-9][0-9]x' $_tmpfile | grep -w 'mp4' | grep 'mp4a' | awk '{print $1}')"

# Audio function.
GETAUD() {
    if [ -z "$awebmf" -a -n "$am4af" ]; then
        yt-dlp $YTOPT -f $am4af -o "y-aud-$IDX.m4a" "$URL"
        cproc=$?
        if [ "$cproc" -eq 1 ]; then
            ccount=0
            until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
            do
                yt-dlp $YTOPT -f $am4af -o "y-aud-$IDX.m4a" "$URL"
                cproc=$?
                ccount=$((ccount + 1))
            done
        fi
    elif [ -n "$awebmf" -a -z "$am4af" ]; then
        yt-dlp $YTOPT -f $awebmf -o "y-aud-$IDX.webm" "$URL"
        cproc=$?
        if [ "$cproc" -eq 1 ]; then
            ccount=0
            until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
            do
                yt-dlp $YTOPT -f $awebmf -o "y-aud-$IDX.webm" "$URL"
                cproc=$?
                ccount=$((ccount + 1))
            done
        fi
    elif [ -n "$awebmf" -a -n "$am4af" ]; then
        yt-dlp $YTOPT -f "ba[ext=webm]" -o "y-aud-$IDX.webm" "$URL"
        cproc=$?
        if [ "$cproc" -eq 1 ]; then
            ccount=0
            until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
            do
                yt-dlp $YTOPT -f "ba[ext=webm]" -o "y-aud-$IDX.webm" "$URL"
                cproc=$?
                ccount=$((ccount + 1))
            done
        fi
    else
        yt-dlp $YTOPT -x --audio-format mp3 -o "y-aud-$IDX.mp3" "$URL"
        cproc=$?
        if [ "$cproc" -eq 1 ]; then
            ccount=0
            until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
            do
                yt-dlp $YTOPT -x --audio-format mp3 -o "y-aud-$IDX.mp3" "$URL"
                cproc=$?
                ccount=$((ccount + 1))
            done
        fi
    fi
}

# Download video clip.
## First choice menu.
read -p "Select video resolution            : " VR

## Validation input from user not NULL.
if [ -z "${VR}" ]; then
    echo "Input can't be NULL!"
    return 1
fi

## Selection video available resolution.
case ${VR} in
    1)
        ### 480p (854x480).
        if [ -n "$vs480p" -a -z "$vs8xx" ]; then
            echo "$vs480p" | tail -n 1 | while read -r dvs480p
            do
                GETAUD
                yt-dlp $YTOPT -f $dvs480p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dvs480p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        elif [ -n "$vs8xx" -a -z "$vs480p" ]; then
            echo "$vs8xx" | tail -n 1 | while read -r dv8xx
            do
                yt-dlp $YTOPT -f $dv8xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dv8xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -vn -acodec copy "y-aud-$IDX.m4a"
                echo "Creating y-aud-$IDX.m4a file has been successful."

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -c:v copy -an "y-vid-$IDX.mp4"
                echo "Creating y-vid-$IDX.mp4 file has been successful."
            done
        elif [ -n "$vs480p" -a -n "$vs8xx" ]; then
            echo "$vs480p" | tail -n 1 | while read -r dvs480p
            do
                GETAUD
                yt-dlp $YTOPT -f $dvs480p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dvs480p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        fi
        ;;
    2)
        ### 360p (640x360).
        if [ -n "$vs360p" -a -z "$vs6xx" ]; then
            echo "$vs360p" | tail -n 1 | while read -r dvs360p
            do
                GETAUD
                yt-dlp $YTOPT -f $dvs360p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dvs360p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        elif [ -n "$vs6xx" -a -z "$vs360p" ]; then
            echo "$vs6xx" | tail -n 1 | while read -r dv6xx
            do
                yt-dlp $YTOPT -f $dv6xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dv6xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -vn -acodec copy "y-aud-$IDX.m4a"
                echo "Creating y-aud-$IDX.m4a file has been successful."

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -c:v copy -an "y-vid-$IDX.mp4"
                echo "Creating y-vid-$IDX.mp4 file has been successful."
            done
        elif [ -n "$vs360p" -a -n "$vs6xx" ]; then
            echo "$vs360p" | tail -n 1 | while read -r dvs360p
            do
                GETAUD
                yt-dlp $YTOPT -f $dvs360p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dvs360p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        fi
        ;;
    3)
        ### 240p (384x288).
        if [ -n "$vs240p" -a -z "$vs3xx" ]; then
            echo "$vs240p" | tail -n 1 | while read -r dvs240p
            do
                GETAUD
                yt-dlp $YTOPT -f $dvs240p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dvs240p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        elif [ -n "$vs3xx" -a -z "$vs240p" ]; then
            echo "$vs3xx" | tail -n 1 | while read -r dv3xx
            do
                yt-dlp $YTOPT -f $dv3xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dv3xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -vn -acodec copy "y-aud-$IDX.m4a"
                echo "Creating y-aud-$IDX.m4a file has been successful."

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -c:v copy -an "y-vid-$IDX.mp4"
                echo "Creating y-vid-$IDX.mp4 file has been successful."
            done
        elif [ -n "$vs240p" -a -n "$vs3xx" ]; then
            echo "$vs240p" | tail -n 1 | while read -r dvs240p
            do
                GETAUD
                yt-dlp $YTOPT -f $dvs240p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $dvs240p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        fi
        ;;
    *)
        echo "Error: Please input 1 = 480p (854x480), 2 = 360p (640x360), 3 = 240p (384x288) from keyboard!"
        ;;
esac

# Remove ${_tmpfile}, y-aud+y-vid files.
rm -f ${_tmpfile} y-aud+y-vid-*

# CD current directory.
cd

# Line Separator.
echo " "
