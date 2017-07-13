#!/bin/bash
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

if pgrep zynaddsubfx
then
echo Zynaddsubfx is already singing
else
zynaddsubfx -U -A=0 -a -o 512 -r 96000 -b 512 -I alsa -O alsa -P 7777 -L "/usr/local/share/zynaddsubfx/banks/Choir and Voice/0034-Slow Morph_Choir.xiz" &
sleep 4
	if pgrep zynaddsubfx
	then
	echo Zyn is singing
	else
	echo Zyn blorked. Epic Fail.
	fi
fi

mini=$(aconnect -o | grep "MINILAB")
mpk=$(aconnect -o | grep "MPKmini2")
mio=$(aconnect -o | grep "mio")

if [[ $mini ]]
then
aconnect 'Arturia MINILAB':0 'ZynAddSubFX':0
echo Connected to MINIlab
elif [[ $mpk ]]
then
aconnect 'MPKmini2':0 'ZynAddSubFX':0
echo Connected to MPKmini
elif [[ $mio ]]
then
aconnect 'mio':0 'ZynAddSubFX':0
echo Connected to Mio
else
echo No known midi devices available. Try aconnect -l
fi

exit

