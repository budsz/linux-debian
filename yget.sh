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
vs720p="$(grep 'video only' $_tmpfile | grep -w '720.*, mp4_dash' | awk '{print $1}')"
vs480p="$(grep 'video only' $_tmpfile | grep -w '480.*, mp4_dash' | awk '{print $1}')"
vs360p="$(grep 'video only' $_tmpfile | grep -w '360.*, mp4_dash' | awk '{print $1}')"
vs240p="$(grep 'video only' $_tmpfile | grep -w '240.*, mp4_dash' | awk '{print $1}')"

vs12xx="$(grep '12[0-9][0-9]x' $_tmpfile | grep -w 'mp4' | grep 'https' | awk '{print $1}')"
vs8xx="$(grep '8[0-9][0-9]x' $_tmpfile | grep -w 'mp4' | grep 'https' | awk '{print $1}')"
vs6xx="$(grep '6[0-9][0-9]x' $_tmpfile | grep -w 'mp4' | grep 'https' | awk '{print $1}')"
vs4xx="$(grep '4[0-9][0-9]x' $_tmpfile | grep -w 'mp4' | grep 'https' | awk '{print $1}')"

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
        ### 720p (1280x720).
        if [ -n "$vs720p" -a -z "$vs12xx" ]; then
            echo "$vs720p" | tail -n 1 | while read -r vr720p
            do
                GETAUD
                yt-dlp $YTOPT -f $vr720p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr720p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        elif [ -n "$vs12xx" -a -z "$vs720p" ]; then
            echo "$vs12xx" | tail -n 1 | while read -r vr12xx
            do
                yt-dlp $YTOPT -f $vr12xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr12xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -vn -acodec copy "y-aud-$IDX.m4a"
                echo "Creating y-aud-$IDX.m4a file has been successful."

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -c:v copy -an "y-vid-$IDX.mp4"
                echo "Creating y-vid-$IDX.mp4 file has been successful."
            done
        elif [ -n "$vs720p" -a -n "$vs12xx" ]; then
            echo "$vs720p" | tail -n 1 | while read -r vr720p
            do
                GETAUD
                yt-dlp $YTOPT -f $vr720p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr720p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        else
            echo "720p (1280x720) resolution screen size not available!"
        fi
        ;;
    2)
        ### 480p (854x480).
        if [ -n "$vs480p" -a -z "$vs8xx" ]; then
            echo "$vs480p" | tail -n 1 | while read -r vr480p
            do
                GETAUD
                yt-dlp $YTOPT -f $vr480p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr480p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        elif [ -n "$vs8xx" -a -z "$vs480p" ]; then
            echo "$vs8xx" | tail -n 1 | while read -r vr8xx
            do
                yt-dlp $YTOPT -f $vr8xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr8xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
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
            echo "$vs480p" | tail -n 1 | while read -r vr480p
            do
                GETAUD
                yt-dlp $YTOPT -f $vr480p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr480p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        else
            echo "480p (854x480) resolution screen size not available!"
        fi
        ;;
    3)
        ### 360p (640x360).
        if [ -n "$vs360p" -a -z "$vs6xx" ]; then
            echo "$vs360p" | tail -n 1 | while read -r vr360p
            do
                GETAUD
                yt-dlp $YTOPT -f $vr360p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr360p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        elif [ -n "$vs6xx" -a -z "$vs360p" ]; then
            echo "$vs6xx" | tail -n 1 | while read -r vr6xx
            do
                yt-dlp $YTOPT -f $vr6xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr6xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
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
            echo "$vs360p" | tail -n 1 | while read -r vr360p
            do
                GETAUD
                yt-dlp $YTOPT -f $vr360p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr360p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        else
            echo "360p (640x360) resolution screen size not available!"
        fi
        ;;
    4)
        ### 240p (426×240).
        if [ -n "$vs240p" -a -z "$vs4xx" ]; then
            echo "$vs240p" | tail -n 1 | while read -r vr240p
            do
                GETAUD
                yt-dlp $YTOPT -f $vr240p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr240p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        elif [ -n "$vs4xx" -a -z "$vs240p" ]; then
            echo "$vs4xx" | tail -n 1 | while read -r vr3xx
            do
                yt-dlp $YTOPT -f $vr3xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr3xx -o "y-aud+y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -vn -acodec copy "y-aud-$IDX.m4a"
                echo "Creating y-aud-$IDX.m4a file has been successful."

                ffmpeg $FFOPT -i "y-aud+y-vid-$IDX.mp4" -c:v copy -an "y-vid-$IDX.mp4"
                echo "Creating y-vid-$IDX.mp4 file has been successful."
            done
        elif [ -n "$vs240p" -a -n "$vs4xx" ]; then
            echo "$vs240p" | tail -n 1 | while read -r vr240p
            do
                GETAUD
                yt-dlp $YTOPT -f $vr240p -o "y-vid-$IDX.mp4" "$URL"
                cproc=$?
                if [ "$cproc" -eq 1 ]; then
                    ccount=0
                    until [ "$cproc" -eq 0 ] || [ "$ccount" -eq 2 ]
                    do
                        yt-dlp $YTOPT -f $vr240p -o "y-vid-$IDX.mp4" "$URL"
                        cproc=$?
                        ccount=$((ccount + 1))
                    done
                fi
            done
        else
            echo "240p (384x288) resolution screen size not available!"
        fi
        ;;
    5)
        ### Default format ID = 18.
        yt-dlp -f 18 -o "$IDX - ST.mp4" "$URL"
        ;;
    6)
        ### MP3 (Audio only).
        yt-dlp -x --audio-format mp3 -o "$IDX - ST.mp3" "$URL"
        ;;
    *)
        echo "Error: Please input 1 = 720p (1280x720), 2 = 480p (854x480), 3 = 360p (640x360), 4 = 240p (384x288), 5 = ID=18/360p (640x358), 6 = MP3 (Audio only) from keyboard!"
        exit 1
        ;;
esac

# Remove ${_tmpfile}, y-aud+y-vid files.
rm -f ${_tmpfile} y-aud+y-vid-*

# CD current directory.
cd

# Line Separator.
echo " "
