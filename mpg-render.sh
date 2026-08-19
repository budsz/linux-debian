#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2026, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
BASEDIR="/home/`whoami`/$WORKDIR"
FINSDIR="$BASEDIR/Finished"
LOGODIR="$BASEDIR/logos"
LOGONAME="otp"
FFOPT="-hide_banner -nostdin -y"

# Move to basedir.
if [ ! -d "$BASEDIR" ]; then
    mkdir $BASEDIR
    cd $BASEDIR
else
    cd $BASEDIR
fi

# Check logo directory.
if [ ! -d "$LOGODIR" ]; then
    mkdir $LOGODIR
fi

# Built list base on instrument files.
IFL="$(find * -type f -name "*_\(Instrumental\).*")"
if [ -z "$IFL" ]; then
    echo "Instrument files doesn't exists!"
    return 1
fi

# Main process.
echo "${IFL}" | while read -r difiles
do
    ## Get layout SINGER - TITLE format from instrument files.
    dfsfiles="$(echo $difiles | awk -F ' - ' '{print $1, "-", $2}' | sed 's/\(.*\)d-aud-//;s/\(.*\)f-aud-//')"
    dftfiles="$(echo $difiles | cut -d '-' -f 3,4,5 | sed 's/_(Instrumental).wav//')"
    dfofiles="$(echo $dftfiles - MR)"

    ## Build list audio/video files except instrument files.
    dfafiles="$(find * -type f \( -name "d-aud*$dfsfiles*" -or -name "f-aud*$dfsfiles*" \) \! -iname "*_(Instrumental)*")"
    dfvfiles="$(find * -type f \( -name "d-vid*$dfsfiles*" -or -name "f-vid*$dfsfiles*" \) )"

    ## Random logo files.
    ranlogos="$(find $LOGODIR -maxdepth 1 -type f -name "$LOGONAME-*.svg" | shuf -n 1)"

    ## Rendering audio + video + logo.
    #if [ -n "$dfafiles" ] && [ -n "$dfvfiles" ] && [ ! -f $FINSDIR/"$dfofiles".mpg ]; then
    if [ -n "$dfafiles" ] && [ -n "$dfvfiles" ]; then
        ## Checking width video files.
        wvfiles="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 -i "$dfvfiles")"

        if [ "$wvfiles" -ge 1280 ]; then
            ffmpeg $FFOPT -i "$dfafiles" -i "$difiles" -i "$dfvfiles" -i "$ranlogos" \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0]; \
                                 [1:a]aformat=channel_layouts=stereo[a1]; \
                                 [a0][a1]amerge=inputs=2, \
                                 pan=stereo|c0=c0|c1=c2[audio], \
                                 [2:v]scale=-2:720[video]; \
                                 [3:v]scale=50:50[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -q:v 12 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$dfofiles".mpg
        elif [ "$wvfiles" -ge 854 ] && [ "$wvfiles" -lt 1280 ]; then
            ffmpeg $FFOPT -i "$dfafiles" -i "$difiles" -i "$dfvfiles" -i "$ranlogos" \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0]; \
                                 [1:a]aformat=channel_layouts=stereo[a1]; \
                                 [a0][a1]amerge=inputs=2, \
                                 pan=stereo|c0=c0|c1=c2[audio], \
                                 [2:v]scale=-2:720[video]; \
                                 [3:v]scale=45:45[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -q:v 12 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$dfofiles".mpg
        elif [ "$wvfiles" -lt 854 ]; then
            ffmpeg $FFOPT -i "$dfafiles" -i "$difiles" -i "$dfvfiles" -i "$ranlogos" \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0]; \
                                 [1:a]aformat=channel_layouts=stereo[a1]; \
                                 [a0][a1]amerge=inputs=2, \
                                 pan=stereo|c0=c0|c1=c2[audio], \
                                 [2:v]scale=-2:720[video]; \
                                 [3:v]scale=40:40[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -q:v 12 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$dfofiles".mpg
        fi
    else
        echo "$dfsfiles: Audio/video/logo files: NULL -OR- target file already exists."
    fi
done

# CD current directory.
cd
