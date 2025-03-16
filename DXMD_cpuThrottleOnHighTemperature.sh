#!/bin/bash

egrep "[#]help" "$0"

function FUNCcheckIfGameIsRunning() {
	pgrep -fa "retail/DXMD.exe -benchmark" >/dev/null
}
function FUNCecho() {
	echo "EXEC: $@"
	"$@"
}

fMinFreqDetected=$(cpupower frequency-info |grep limits |awk '{print $3}')
declare -p fMinFreqDetected
: ${fMinFreq:=${fMinFreqDetected}} #help your cpu minimum frequency (auto detected, but must be configured with visudo)
while true;do
	nTmpr=$(sensors |grep Tctl |awk '{print $2}' |cut -d. -f1);
	: ${nTmprLim:=76} #help temperature limit to throttle CPU down
	if((nTmpr >= nTmprLim));then
		date
		declare -p nTmpr
		set -x
		FUNCecho \
			sudo cpupower frequency-set --min ${fMinFreq}GHz --max ${fMinFreq}GHz #help this is the command you must set with visudo
		set +x 
	fi
	
	#echoc -w -t 3 -n "\r$(date)"
	: ${nDelay:=2} #help
	echo -en "\r$(date)";read -n 1 -t $nDelay
	
	: ${bExitWithGame:=false} #help
	if $bExitWithGame && ! FUNCcheckIfGameIsRunning;then break;fi
done

