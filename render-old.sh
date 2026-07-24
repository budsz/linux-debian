#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2026, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
BASEDIR="/home/`whoami`/$WORKDIR"
FINSDIR="$BASEDIR/Finished"
LOGODIR="$BASEDIR/logos"
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

# Rendering function.
RENDER() {
    #ffmpeg -y -i voc-audio.webm -i inst-audio.wav -i video.mp4 -i cn.png -filter_complex "[0:a]aformat=channel_layouts=stereo[a0];[1:a]aformat=channel_layouts=stereo[a1];[a0][a1]amerge=inputs=2,pan=stereo|c0=c0|c1=c2[merged_audio],[2:v]scale=1280:720[scaled_video],[2:v]overlay=x=main_w-overlay_w-(main_w*0.04):y=main_h*0.07" -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[merged_audio]" -map 2:v -map "[scaled_video]" -c:v mpeg2video -q:v 12 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k output.mpg
    #ffmpeg -y -i voc-audio.webm -i inst-audio.wav -i video.mp4 -i cn.png -filter_complex "[0:a][1:a]amerge=inputs=2,pan=stereo|c0=c0|c1=c2[aout],[2:v]scale=1280:720[scaled_video],[2:v]overlay=x=main_w-overlay_w-(main_w*0.04):y=main_h*0.07" -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[aout]" -map 2:v -map "[scaled_video]" -c:v mpeg2video -q:v 12 -r 25 output.mpg
    #ffmpeg -y -i voc-audio.webm -i inst-audio.wav -i video.mp4 -i cn.png -filter_complex "[0:a][1:a]amerge=inputs=2,pan=stereo|c0=c0|c1=c2[aout]" -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[aout]" -map 2:v -c:v mpeg2video -q:v 12 -vf "scale=1280:720" -r 25 output.mpg
    #ffmpeg -i output.mpg -i "cn.png" -filter_complex "overlay=x=main_w-overlay_w-(main_w*0.04):y=main_h*0.07" -q:v 12 -q:a 3 outputlogo.mpg

    for slist in \
                 "1280x720 10 100x100" \
                 "1280x718 10 100x100" \
                 "1280x714 10 100x100" \
                 "1280x708 10 100x100" \
                 "1280x704 10 100x100" \
                 "1280x676 10 100x100" \
                 "1280x640 10 100x100" \
                 "1278x720 10 100x100" \
                 "1250x720 10 100x100" \
                 "1152x720 9 85x85" \
                 "1088x720 8 80x80" \
                 "1080x720 8 80x80" \
                 "960x720 7 70x70" \
                 "854x480 6 60x60" \
                 "854x474 6 60x60" \
                 "854x470 6 60x60" \
                 "720x1280 5 55x55" \
                 "640x480 2 50x50" \
                 "640x360 2 50x50" \
                 "640x352 2 50x50"
    do
        sflist="$(echo "$slist" | awk '{print $1}')"
        sfqvid="$(echo "$slist" | awk '{print $2}')"
        sflogo="$(echo "$slist" | awk '{print $3}')"

        if [ "$crdafiles" = "$sflist" ]; then
            ## Resize logo base on list.
            xw="$(echo $sflogo | cut -d x -f1)"
            xh="$(echo $sflogo | cut -d x -f2)"
            #sed 's/width=.*/width='"\"$xw"'mm\"/;s/height=.*/height='"\"$xh"'mm\"/' "$LOGODIR"/tcl.svg > "$LOGODIR"/$sflogo.svg

            ### Need installing imagemagick7 -OR- librsvg2-bin!
            rsvg-convert --width=$xw --height=$xh --keep-aspect-ratio "$LOGODIR"/tcl.svg -o "$LOGODIR"/$sflogo.png
            #magick -quality 92 -resize $sflogo "$LOGODIR"/tcl.png "$LOGODIR"/$sflogo.png
            #magick "$LOGODIR"/tcl.svg -background none -scale $sflogo $sflogo "$LOGODIR"/$sflogo.png
            #magick -background none "$LOGODIR"/tcl.svg -resize "$sflogo!" "$LOGODIR"/$sflogo.png

            # Create *.mpg files.
            ffmpeg $FFOPT -i "$dafiles" -i "$difiles" -i "$dvfiles" -i "$LOGODIR"/$sflogo.png \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0];\
                                 [1:a]aformat=channel_layouts=stereo[a1];\
                                 [a0][a1]amerge=inputs=2,\
                                 pan=stereo|c0=c0|c1=c2[merged_audio],\
                                 [2:v]scale=$sflist[scaled_video];\
                                 [3:v]scale=-1:-1[scaled_logo];\
                                 [scaled_video][scaled_logo]overlay=x=main_w-overlay_w-(main_w*0.02):y=main_h*0.04[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[merged_audio]" \
            -map "[outv]" -c:v mpeg2video -q:v $sfqvid -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$dofiles".mpg
        else
            echo "$dvfiles: No match video resolution on the list -OR- No detected video resolution."
        fi
    done
}

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
    dsfiles="$(echo $difiles | awk -F ' - ' '{print $1, "-", $2}' | sed 's/\(.*\)d-aud-//;s/\(.*\)f-aud-//')"
    dtfiles="$(echo $difiles | cut -d '-' -f 3,4,5 | sed 's/_(Instrumental).wav//')"
    dofiles="$(echo $dtfiles - MR)"

    ## Build list audio/video files except instrument files.
    dafiles="$(find * -type f -name "d-aud*$dsfiles*" \! -iname "*_(Instrumental)*")"
    dvfiles="$(find * -type f -name "d-vid*$dsfiles*")"

    ## Get resolution video size.
    ## crdafiles="$(ffprobe -i "$dvfiles" 2>&1 | grep '640x480')"
    crdafiles="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 -i "$dvfiles")"

    ## Check all stuff.
    if [ -n "$dafiles" ] && [ -n "$dvfiles" ] && [ ! -f $FINSDIR/"$dofiles".mpg ]; then
        RENDER
    else
        echo "Audio/video files NULL -OR- target file already exists."
    fi
done

# Stats files.
echo " "
echo "Summary statistic files:"
echo "difiles : $(find * -type f -name "*_\(Instrumental\).*" | awk 'END {print NR}') files"
echo "dafiles : $(find * -type f -name "d-aud*$dsfiles*" \! -iname "*_(Instrumental)*" | awk 'END {print NR}') files"
echo "dvfiles : $(find * -type f -name "d-vid*$dsfiles*" | awk 'END {print NR}') files"
echo "dofiles : $(find $FINSDIR -type f | awk 'END {print NR}') files"

# CD current directory.
cd
