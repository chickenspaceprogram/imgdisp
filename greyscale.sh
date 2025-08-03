#!/bin/sh
FILNAME=bad-apple.mkv
FPS=30
OUT=yeet.yuv

ffmpeg -i $FILNAME -vf "scale=96:64,fps=$FPS" -pix_fmt gray $OUT
