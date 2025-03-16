#!/bin/bash

function FUNCcheckIfGameIsRunning() {
	pgrep -fa "retail/DXMD.exe -benchmark" >/dev/null
}

cd "$HOME/Documents/My Games/Deus Ex Mankind Divided/Saves"
strPrefix="DXNGsavegame";
strPrevStat=""
strNewStat=""
strLast="$(ls -1tr "DXNGsavegame"*.dat |egrep -v "0000|0001|0002|0003" |tail -n 1)";declare -p strLast;
nLast="$(basename "$(echo "$strLast")" |sed -r -e "s@${strPrefix}(....).dat@\1@g")";declare -p nLast;
while true;do
	strNewStat="$(ls -l "${strPrefix}0000.dat")"
	if [[ "$strPrevStat" != "${strNewStat}" ]];then
		echoc -w -t 5 # wait luckly complete the save
		nNew="$((10#${nLast}+1))";
		strNew="${strPrefix}$(printf %04d ${nNew}).dat";declare -p strNew;
		cp -v "${strPrefix}0000.dat" "$strNew"
		ls -l "$strNew"
		nLast=$nNew
		strPrevStat="${strNewStat}"
	fi
	
	#echoc -n -w -t 5 "\r$(date)"
	: ${nDelay:=5} #help
	echo -en "\r$(date)";read -n 1 -t $nDelay
	
	: ${bExitWithGame:=false} #help keep off if you restart it often for any reason
	if $bExitWithGame && ! FUNCcheckIfGameIsRunning;then break;fi
done
