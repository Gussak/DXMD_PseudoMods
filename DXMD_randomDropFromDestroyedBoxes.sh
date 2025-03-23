#!/bin/bash

astrItemListA=(
	BioCell
	HYPO_STIMJECTOR
	PainKillerX3kit
	Multitool
)
astrItemListB=(
	Absinthe
	Whiskey__Nyes_Rye
	Whiskey__Surly_Welshmans
	Spirit_AKuma
	Spirit_Prestige
	Wine_Lavende
)
astrItemListC=(
	Beer_Beekmans_Brown_Ale
	Beer_Changuch_Pale_Ale
	Beer_Dait_Taga
	Beer_Mramor_Pilsner
	Beer_Svobody
)
declare -A astrFound
while true;do
	echo -n "how many boxes you destroyed? ";read nCount
	for str in "${astrItemList[@]}";do
		astrFound[$str]=0
	done
	for((i=0;i<nCount;i++));do
		nRnd=$((RANDOM%100))&&:
		declare -p nRnd
		if((nRnd < 5));then
			((astrFound[${astrItemListA[$((RANDOM % ${#astrItemListA[*]}))]}]++))&&:
		elif((nRnd < 10));then
			((astrFound[${astrItemListB[$((RANDOM % ${#astrItemListB[*]}))]}]++))&&:
		elif((nRnd < 15));then
			((astrFound[${astrItemListC[$((RANDOM % ${#astrItemListC[*]}))]}]++))&&:
		fi
	done
	#for str in "${astrFound[@]}";do
		#echo "$str" |egrep -v "=0"
	#done
	echo
	declare -p astrFound |tr '[' '\n' |tr -d '[]"()' |egrep -v "=0" |tail -n +2
	echo
done

