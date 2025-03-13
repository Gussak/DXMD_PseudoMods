#!/bin/bash

echo "FAIL: xdotool wont click faster than a mouse with turbo LMB button 100ms/click, it actually clicks very slowly... :/"

set -eEu

while true;do
	read -p "press Enter to do it now"
	windowId=`xdotool search --name "Deus Ex: Mankind Divided"`&&:;declare -p windowId;
	if [[ -z "$windowId" ]];then echo "ERROR: DXMD is not running?";continue;fi
	nCredits=$(yad --center --on-top --title "DXMD: type credits to receive" --text "You need to have Debug Menu installed and position the mouse over 100 credits.\n(Debug menu shows 100 credits but it gives only 10)" --entry);
	nClicks=$((nCredits/10));declare -p nClicks;
	xdotool click --delay 100 --window $windowId --repeat $nClicks 1
done
