#!/bin/bash

# Replaces 3 white and 1 grey star to just 3 white stars
bettersignal() {
    echo "$1" \
        | sed -e "s:\[1;30m::g" \
        | sed -e "s:\[0m::g" \
        | sed -e "s:\*\x1b.*:\*:g" \
        | sed -e "s:\x1b::g"
}

dev=$(nmcli device status | awk '/connected/ {print $1}')

list=$(iwctl station $dev get-networks \
    | head -n -1 \
    | tail -n +5 \
    | sed "s/  */ /g" \
    | sed "s/^ //g")

cur_connected=$( bettersignal "$( echo "$list" | awk '/>/ {printf (" \t%20s\t%s\t%s\n", $4, $5, $6) }' )" )
not_connected=$( bettersignal "$( echo "$list" | grep -v ">" )" )


options="$cur_connected"

while read line; 
do
    options=$( echo -e "$options\n$(echo "$line"\
        | awk '{printf (" \t%20s\t%s\t%s\n", $1, $2, $3) }' )" )
done <<<$(echo "$not_connected")






select=`echo "$options" | rofi -dmenu -theme-str 'inputbar {enabled: false;}'`

[ -z "$select" ] && exit 0

if [[ "$cur_connected" == "$select" ]];
then
    echo "disconnect"
    iwctl station $dev disconnect

else
    ssid=$( echo "$select" | awk '{print $2}' )
    echo "connect to $ssid"
    iwctl station $dev disconnect 
    sleep 3

    maybe_pass=$(timeout 8 iwctl station $dev connect $ssid --dont-ask)  

    if [ -z "$maybe_pass" ];
    then 
        echo "connected" 
        exit 0
    else
        echo "need pass"
        #TODO






    fi
    
fi

