#!/bin/sh
 
#export LANG=ru_RU.KOI8-R; 
gnome-terminal --disable-factory -e "/home/snvm/StudioProjects/flutter_atol/ingenico_driver/sb_pilot $1 $2 $3 $4" --hide-menubar -t "SB-Pilot" --working-directory=. --profile=sbpilot

#export LANG=ru_RU.KOI8-R; export LC_ALL=ru_RU.KOI8-R; xterm -T SbPilot -fn -misc-*-*-*-*-*-13-*-*-*-*-*-koi8-r -e "/home/snvm/~/StudioProjects/flutter_atol/ingenico_driver/sb_pilot $1 $2 $3 $4"
