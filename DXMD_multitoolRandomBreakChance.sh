#!/bin/bash

set -Eeu

: ${nResistCount:=0} #help
#: ${nSkillLvl:=0} #help required param
echo -n "type your hacking skill lvl: ";read -n 1 nSkillLvl;echo
while true;do
	echo -n "multitool break chance. your skill lvl is $nSkillLvl, type the lock lvl: ";read -n 1 nLockLvl;echo
	nDiff=$((nLockLvl-nSkillLvl))&&:
	if((nDiff<=0));then
		nBreakChance=5
	else
		nBreakChance=$((nDiff*20))&&:
	fi
	nRnd=$((RANDOM%100))&&:
	if((nRnd < nBreakChance));then
		echo "BREAK..."
	else
		echo "The multitool resisted well."
		((nResistCount++))&&:
	fi
	declare -p nSkillLvl nLockLvl nDiff nBreakChance nRnd nResistCount
	echo
done

