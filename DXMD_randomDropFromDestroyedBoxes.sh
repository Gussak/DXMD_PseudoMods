#!/bin/bash

astrItemList=(
	Beer_Beekmans_Brown_Ale
	Beer_Changuch_Pale_Ale
	Beer_Dait_Taga
	Beer_Mramor_Pilsner
	Beer_Svobody
	BioCell
	HYPO_STIMJECTOR
	PainKiller
	Shot_Nyes_Rye
	Shot_Surly_Welshmans
	Shot_Tensons_Sense
)
declare -A astrFound
while true;do
	echo -n "how many boxes you destroyed? ";read nCount
	for str in "${astrItemList[@]}";do
		astrFound[$str]=0
	done
	for((i=0;i<nCount;i++));do
		if((RANDOM%100 < 5));then
			((astrFound[${astrItemList[$((RANDOM % ${#astrItemList[*]}))]}]++))&&:
		fi
	done
	#for str in "${astrFound[@]}";do
		#echo "$str" |egrep -v "=0"
	#done
	echo
	declare -p astrFound |tr '[' '\n' |tr -d '[]"()' |egrep -v "=0" |tail -n +2
	echo
done

