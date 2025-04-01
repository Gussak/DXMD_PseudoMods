#!/bin/bash

set -Eeu

: ${nResistCount:=0} #help
#: ${nSkillLvl:=0} #help required param
echo -n "type your hacking skill lvl: ";read -n 1 nSkillLvl;echo
nLvlStepPerc=20
while true;do
	echo -n "multitool break chance. your skill lvl is $nSkillLvl, type the lock lvl: ";read -n 1 nLockLvl;echo
	nDiff=$((nLockLvl-nSkillLvl))&&:
	if((nDiff<=0));then
		nBreakChance=5
	else
		nBreakChance=$((nDiff*nLvlStepPerc))&&:
	fi
	if((nBreakChance>95));then nBreakChance=95;fi
	
	nResistCount=0
	nRepeat=$nDiff
	nBreakCount=0
	strLog=""
	if((nRepeat<1));then nRepeat=1;fi
	for((i=0;i<nRepeat;i++));do 
		nRnd=$((RANDOM%100))&&:
		#declare -p nRnd nBreakChance #DEBUG
		if((nRnd < nBreakChance));then
			strLog+="0.BROKEN.[$((i+1))]\n"
			((nBreakChance-=nLvlStepPerc))&&:
			((nBreakCount++))&&:
		else
			strLog+="1.The LAST multitool resisted well.[$((i+1))]\n"
			((nResistCount++))&&:
		fi
	done
	
	#declare -p nSkillLvl nLockLvl nDiff nResistCount  #DEBUG
	
	echo -e "$strLog" |sort -n
	
	#echo "((( REFUND: $nResistCount )))"
	nExtraBroken=0
	if((nBreakCount>1));then
		nExtraBroken=$((nBreakCount-1))
		#echo "((( no extra multitools broken )))"
	fi
	echo "<<< EXTRA BROKEN MULTITOOLS (as one always break in-game): $nExtraBroken >>>"
	if((nBreakCount==0));then
		echo "!!! REFUND MULTITOOL: 1 !!!"
	fi
	
	echo
done

