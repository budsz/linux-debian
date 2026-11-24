#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2026, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
BASEDIR="/home/`whoami`/$WORKDIR"
FINSDIR="$BASEDIR/Finished"
LOGODIR="$BASEDIR/logos"
LOGONAME="xpf"
FFBIN="/usr/local/ffmpeg/bin/ffmpeg"
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
IFL="$(find * -type f -name "*_\(Instrumental\).*" | sort -V)"
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
    dfofiles="$(echo $dftfiles - MR | sed 's/  */ /g')"

    ## Build list audio/video files except instrument files.
    dfafiles="$(find * -type f \( -name "d-aud*$dfsfiles*" -or -name "f-aud*$dfsfiles*" \) \! -iname "*_(Instrumental)*")"
    dfvfiles="$(find * -type f \( -name "d-vid*$dfsfiles*" -or -name "f-vid*$dfsfiles*" \) )"

    ## Random logo files.
    if [ -n "$(echo "$dfafiles" | grep 'f-aud-')" ]; then
        ranlogos="$(find $LOGODIR -maxdepth 1 -type f -name "fin-*.svg" | shuf -n 1)"
    else
        ranlogos="$(find $LOGODIR -maxdepth 1 -type f -name "$LOGONAME-*.svg" | shuf -n 1)"
    fi

    ## Output directory.
    if [ -n "$(echo "$dfafiles" | grep 'f-aud-')" ]; then
        if [ ! -d "$FINSDIR/FIN" ]; then
            mkdir "$FINSDIR/FIN"
        fi

        FFINSDIR="$FINSDIR/FIN"
    else
        FFINSDIR="$FINSDIR"
    fi

    ## Rendering audio + video + logo.
    #if [ -n "$dfafiles" ] && [ -n "$dfvfiles" ] && [ ! -f $FINSDIR/"$dfofiles".mpg ]; then
    if [ -n "$dfafiles" ] && [ -n "$dfvfiles" ]; then
        ## Checking width video files.
        wvfiles="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 -i "$dfvfiles" | grep -Eo '[0-9]+')"

        if [ "$wvfiles" -ge 1280 ]; then
            $FFBIN $FFOPT -i "$dfafiles" -i "$difiles" -i "$dfvfiles" -loop 1 -i "$ranlogos" \
            -filter_complex "[0:a]pan=mono|c0=0.5*c0+0.5*c1[a0]; \
                             [1:a]pan=mono|c0=0.5*c0+0.5*c1[a1]; \
                             [a0][a1]join=inputs=2:channel_layout=stereo[audio]; \
                             [2:v]scale=-2:720,format=yuv420p[video]; \
                             [3:v]scale=70:70,format=rgba,split=2[l1][l2]; \
                             [l2]geq=r=255:g=255:b=255:a='alpha(X,Y)*if(lt(mod(T,4),0.8),exp(-pow((X+Y-mod(T,4)*200)/12,2))*0.8,0)'[shimmer]; \
                             [l1][shimmer]overlay=0:0[logo_eff]; \
                             [video][logo_eff]overlay=x=main_w-overlay_w-40:y=40:format=yuv420:shortest=1[outv]" \
            -map "[outv]" -c:v mpeg2video -pix_fmt yuv420p -b:v 4000k -maxrate 6000k -bufsize 1835k -mbd 2 -trellis 2 \
            -map "[audio]" -c:a mp2 -b:a 224k -ar 48000 -muxrate 10080k "$FFINSDIR/$dfofiles.mpg"
        elif [ "$wvfiles" -ge 854 ] && [ "$wvfiles" -lt 1280 ]; then
            $FFBIN $FFOPT -i "$dfafiles" -i "$difiles" -i "$dfvfiles" -loop 1 -i "$ranlogos" \
            -filter_complex "[0:a]pan=mono|c0=0.5*c0+0.5*c1[a0]; \
                             [1:a]pan=mono|c0=0.5*c0+0.5*c1[a1]; \
                             [a0][a1]join=inputs=2:channel_layout=stereo[audio]; \
                             [2:v]scale=-2:720,format=yuv420p[video]; \
                             [3:v]scale=60:60,format=rgba,split=2[l1][l2]; \
                             [l2]geq=r=255:g=255:b=255:a='alpha(X,Y)*if(lt(mod(T,4),0.8),exp(-pow((X+Y-mod(T,4)*200)/12,2))*0.8,0)'[shimmer]; \
                             [l1][shimmer]overlay=0:0[logo_eff]; \
                             [video][logo_eff]overlay=x=main_w-overlay_w-40:y=40:format=yuv420:shortest=1[outv]" \
            -map "[outv]" -c:v mpeg2video -pix_fmt yuv420p -b:v 4000k -maxrate 6000k -bufsize 1835k -mbd 2 -trellis 2 \
            -map "[audio]" -c:a mp2 -b:a 224k -ar 48000 -muxrate 10080k "$FFINSDIR/$dfofiles.mpg"
        elif [ "$wvfiles" -lt 854 ]; then
            $FFBIN $FFOPT -i "$dfafiles" -i "$difiles" -i "$dfvfiles" -loop 1 -i "$ranlogos" \
            -filter_complex "[0:a]pan=mono|c0=0.5*c0+0.5*c1[a0]; \
                             [1:a]pan=mono|c0=0.5*c0+0.5*c1[a1]; \
                             [a0][a1]join=inputs=2:channel_layout=stereo[audio]; \
                             [2:v]scale=-2:720,format=yuv420p[video]; \
                             [3:v]scale=50:50,format=rgba,split=2[l1][l2]; \
                             [l2]geq=r=255:g=255:b=255:a='alpha(X,Y)*if(lt(mod(T,4),0.8),exp(-pow((X+Y-mod(T,4)*200)/12,2))*0.8,0)'[shimmer]; \
                             [l1][shimmer]overlay=0:0[logo_eff]; \
                             [video][logo_eff]overlay=x=main_w-overlay_w-40:y=40:format=yuv420:shortest=1[outv]" \
            -map "[outv]" -c:v mpeg2video -pix_fmt yuv420p -b:v 4000k -maxrate 6000k -bufsize 1835k -mbd 2 -trellis 2 \
            -map "[audio]" -c:a mp2 -b:a 224k -ar 48000 -muxrate 10080k "$FFINSDIR/$dfofiles.mpg"
        fi
    else
        echo "$dfsfiles: Audio/video/logo files: NULL -OR- target file already exists."
    fi
done

# CD current directory.
cd
