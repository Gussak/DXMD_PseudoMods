#!/bin/bash

function FUNCcheckIfGameIsRunning() {
	pgrep -fa "retail/DXMD.exe -benchmark" >/dev/null
}

while true;do
	nTmpr=$(sensors |grep Tctl |awk '{print $2}' |cut -d. -f1);
	if((nTmpr > 72));then
		date
		declare -p nTmpr
		set -x;sudo cpupower frequency-set --min 1.55GHz --max 1.55GHz;set +x
	fi
	echoc -w -t 3 -n "\r$(date)"
	if ! FUNCcheckIfGameIsRunning;then break;fi
done

