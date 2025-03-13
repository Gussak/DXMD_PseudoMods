#!/bin/bash

: ${bDebug:=false} #help
: ${nClipLim:=25} #help
: ${nSlowDownLimMult:=3} #help
: ${nMultSoft:=10} #help multiply the found software final amount to compensate how many you spent to make the effort worth it. So if you have high hacking skills better set this to 1

echo "This script will randomize softwares you could have found in game if it could be modded properly ;)"
echo "This script is a mini-game on it-self also."
echo "USAGE: you can set options running like this: nFunWayMaxTimeoutPerLevel=3 strFunJackPotRegexMatch=\"FUNNY|CYBER\" ./$(basename "$0")"
echo "TIP: I think it may work best with guake"
echo "MINIGAME:Passwords: while decripting the database, select something from it and try to type it. If you miss a key you will fail. The more you type w/o missing, up to $nClipLim chars, will increase the good luck chance of finding best software. Completing the password will earn 2x it's value and retry good luck many times after it, more often if it was a big password. Tip: move the mose to slow down (max is node level * $nSlowDownLimMult) the processing so you can select something."
echo "SELFNOTE:TODO:FIX:ISSUE: typing the password too fast may fail by not reading some typed key :("
echo
echo "VARIABLE OPTIONS:"
egrep "[#]help" $0
# if some day a proper mod can be implemented, feel free to implement this idea, and please tell me to I can use your mod too :D

function FUNCdbg() {
	if $bDebug;then
		declare -p strClipboard strTryType strFunProgress strTryTypeFIXEDREGEX
		declare -p nLuckChk nGoodLuck nLuckAdd nLuck nLuckSetOnNextLoop strLuck strDbgPassC
	fi
}

trap 'echo -e "$_strEscEnd";FUNCdbg;exit' INT

function FUNCfixRegex() {
	echo "$@" |sed -r -e 's@.@[&]@g'
}

astrSoftwareList=( #this is the order found in debug menu mod
	Reveal    #0
	Stealth   #1
	Nuke      #2
	Overclock #3
	Datascan  #4
	Stop      #5
);

declare -A aKey #TODO may be selecting a password beggining with the letter below, will prefer rewarding related software
aKey[Reveal]=R
aKey[Stealth]=S
aKey[Nuke]=N
aKey[Overclock]=O
aKey[Datascan]=D
aKey[Stop]=T

_strEscGreenLight="\E[92m"
_strEscGreen="\E[32m"
_strEscDim="\E[2m"
_strEscEnd="\E[0m"
_strEscBkgGreenLight="\E[102m"
_strEscBlink="\E[5m"

strEscGreenDim="${_strEscEnd}${_strEscGreen}${_strEscDim}"
strEscGreen="${_strEscEnd}${_strEscGreen}"
strEscGreenLight="${_strEscEnd}${_strEscGreenLight}"
strEscGreenAlert="${_strEscEnd}${_strEscBkgGreenLight}${_strEscGreen}${_strEscDim}${_strEscBlink}"

: ${bColored:=true} #help false to disable coloring
if ! $bColored;then
	strEscGreenDim=""
	strEscGreen=""
	strEscGreenLight=""
fi

function FUNCclearBuffer() { 
	while read -n 1 -t 0.01;do :;done #clear key buffer
}

function FUNCrandomSoftwares() {
	clear
	echo
	
	strFUNCrandomSoftwares=""
	
	declare -A aMatches
	aMatches[Reveal]=0
	aMatches[Stealth]=0
	aMatches[Nuke]=0
	aMatches[Overclock]=0
	aMatches[Datascan]=0
	aMatches[Stop]=0
	
	for((i=1; i <= ${nLvl} ; i++));do
		if((i==1));then
			strFUNCrandomSoftwares+="${strEscGreenDim}$((i)): (YOU ALREADY GOT IT IN GAME)${_strEscEnd}\n";
			continue
		else
			if((  nLuck ==  1));then
				nRnd=1; # 1=Stealth is the most powerful software
			elif((nLuck == -1));then
				nRnd=0; # 0=Reveal is the least powerful software
			else
				nRnd=$((RANDOM%${#astrSoftwareList[@]}));
			fi
			strFUNCrandomSoftwares+="${strEscGreen}$((i)): ${astrSoftwareList[nRnd]}${_strEscEnd}\n";
		fi
		((aMatches[${astrSoftwareList[nRnd]}]++))&&:
	done;
	echo -e "${strEscGreen}$strFUNCrandomSoftwares${_strEscEnd}"
	echo -e "${strEscGreen}Easier to click:${_strEscEnd}"
	for strSoft in ${astrSoftwareList[@]};do
		#nMatchCount="$(echo -e "$strFUNCrandomSoftwares" |egrep -ic "$strSoft")" #grep is slow
		#if((nMatchCount>0));then
		if((${aMatches[$strSoft]}>0));then
			echo -e "${strEscGreen} $strSoft: ${strEscGreenLight}$(( ${aMatches[$strSoft]}*((RANDOM%nMultSoft)+1) ))${_strEscEnd}"
		else
			echo -e "${strEscGreenDim} [***]${_strEscEnd}"
		fi
	done
	echo
}

function FUNCluckCheck() {
	FUNCluckCheck_OUT_nLuckTmp=0
	if((nLuck==0));then
		nLuckChk=$((RANDOM%100)) # 5% chance per request of critical or fumble
		if [[ "${1-}" != --noBadLuck ]];then
			if(( nLuckChk < 5 ));then FUNCluckCheck_OUT_nLuckTmp=-1;fi
		fi
		if(( nLuckChk >= (nGoodLuck-nLuckAdd) ));then FUNCluckCheck_OUT_nLuckTmp=1;fi
		((nLuckRollCount++))&&:
	fi
}

: ${strFunJackPotRegexMatch="HACK|1337|DEUSEX|DX01|DXIW|DXHR|DXTF|DXGO|DXMD|GODLIKE|GODLY|STEALTH|LUCK|CYBER"} #help big words will probably never happen, but every letter happening more than once will increase it's chances to form smaller words ;). Better use 4 chars or more. Removed: GOD|DX1|DX2|DX3|DX4
: ${strFunChars:="${strFunJackPotRegexMatch}"'abcdefghijklmnopqrstuvwxyz 0123456789~!@#$%^&*()_+-={}<>[],./?'} #help
strFunJackPotRegexMatchFIXEDREGEX="$(FUNCfixRegex "$strFunJackPotRegexMatch")"

strSessionStartTime=$(date +'%Y/%m/%d-%H:%M:%S')
nSessionRequest=1
: ${bDebugTestLuck:=false} #help
echo -e "$strEscGreen"
bFirstLoopIsBugged=true
while true;do
	nLuck=0
	
	FUNCclearBuffer
	
	echo
	#help node levels can be 023456789. '0' means lvl 10. '1' is already given by the game always. I saw once lvl 6, after a transfer node, but I guess such transfer may result in 10 at most. Btw, minimum is 2 because one software the game already always give you!
	nLvl=-1
	if $bDebugTestLuck;then
		nLvl=$((RANDOM%10 + 1));if((nLvl==1));then nLvl=2;fi
	else
		echo -e "${_strEscEnd}";FUNCdbg
		echo -en "\r";
		strQ="${strEscGreen}Type hacked node level [${strEscGreenLight}023456789${strEscGreen}] ('${strEscGreenLight}0${strEscGreen}' means lvl ${strEscGreen}10${strEscGreen}. '${strEscGreenLight}1${strEscGreen}' is already given by the game always):${_strEscEnd}"; #to get size should skip all color formating chars tho, too much trouble..
		echo -e "$(printf %$(tput cols)s ' ' |tr ' ' '_')";
		echo -e "${strEscGreenDim}[CONNECTED]"
		echo -e "$strQ";
		echo -e "${strEscGreenLight}";read -n 1 nLvl
	fi
	if [[ "$nLvl" == "&" ]];then
		nLvl=$((RANDOM%10 + 1));if((nLvl==1));then nLvl=2;fi
		nLuck="$(if((RANDOM%2==0));then echo -1;else echo 1;fi)"
	else
		if [[ -z "$nLvl" ]] || ! [[ "$nLvl" =~ ^[023456789]*$ ]];then echo -ne "${strEscGreenLight}!!!INVALID!!!${_strEscEnd}";continue;fi # not a number
	fi
	if((nLvl==0));then nLvl=10;fi
	echo
	
	: ${nFunWayMaxTimeoutPerLevel:=3} #help the longer you can stand waiting, the higher chances for a jack pot!
	
	#nFunHalfOfMaxTimeout=$(( (nFunWayMaxTimeoutPerLevel * nLvl) / 2 ))
	#if((nFunHalfOfMaxTimeout<1));then nFunHalfOfMaxTimeout=1;fi # when nFunWayMaxTimeoutPerLevel == 1
	#nFunWayTimeout=$(( nFunHalfOfMaxTimeout + (RANDOM % nFunHalfOfMaxTimeout) + 1 )); # +1 to compensate % that result never is nFunHalfOfMaxTimeout
	#if((nLvl>=2));then nFunHalfOfMaxTimeout+=1;fi # when nFunWayMaxTimeoutPerLevel == 1 to make lvl 2 on make sense
	
	#nFunWayTimeoutTmp=$((nFunWayMaxTimeoutPerLevel*nLvl))
	#nFunWayTimeoutHalfTmp=$((nFunWayTimeoutTmp/2))
	#nFunWayTimeout=$((nFunWayTimeoutHalfTmp + RANDOM%nFunWayTimeoutHalfTmp + 1))
	#declare -p nFunWayTimeoutTmp nFunWayTimeoutHalfTmp nFunWayTimeout
	
	nFunWayTimeoutTmp=$(( (nFunWayMaxTimeoutPerLevel*nLvl) + 1))
	nFunWayTimeout=$(( nFunWayTimeoutTmp - (RANDOM%((nFunWayTimeoutTmp+1)/2)) ))
	
	FUNCluckCheck;nLuck=$FUNCluckCheck_OUT_nLuckTmp
	
	nSeconds=$SECONDS
	strFunProgress=""
	strSessionInfo="SESSION:[$strSessionStartTime][$((nSessionRequest++))] at $(date +'%Y/%m/%d-%H:%M:%S')"
	nLuckSetOnNextLoop=0
	strLuck=""
	nLuckAdd=0
	strTryType=""
	strCursorPos=""
	strCursorPosPrevious=""
	nReadInputLoopInterval=10
	nReadInputCountUp=0
	nSysSlowDownDelay=3
	nGoodLuck=95
	nSlowDownCount=0
	nSlowDownLim=$((nLvl*nSlowDownLimMult))
	bApplyLuckOnce=false
	strClipboard=""
	bPasswordCompleted=false
	bPasswordWrong=false
	nLuckRollCount=0
	nLuckTot=0
	strDbgPassC=""
	while true;do
		if(( SECONDS < ( nSeconds + nFunWayTimeout ) ));then
			:
		else
			break;
		fi
		
		if((nLuckSetOnNextLoop!=0));then
			nLuck=$nLuckSetOnNextLoop;
		fi
		if((nLuck==1));then
			strLuck="${strEscGreenAlert} !!!JackPot!!! ${_strEscEnd}";
		elif((nLuck==-1));then
			strLuck="${strEscGreenAlert}OUCH!${_strEscEnd}";
		fi
		
		FUNCrandomSoftwares
		
		if [[ -n "$strTryTypeChars" ]];then
			strTryType+="$strTryTypeChars";
			strTryTypeFIXEDREGEX="$(FUNCfixRegex "$strTryType")"
			strTryTypeChars="" #consume
			bApplyLuckOnce=true #enables check below
		fi
		if [[ "$strClipboard" =~ ^${strTryTypeFIXEDREGEX}.* ]] && $bApplyLuckOnce && [[ "$strFunProgress" =~ .*${strClipboardFIXEDREGEX}.* ]];then # typed equal to selected, selected was from progress text. then check luck once
			nLuckAdd=${#strTryType}
			if [[ "${strTryType}" == "${strClipboard}" ]];then
				((nLuckAdd*=2))&&:; #completing the password will be worth 2x it's value
				bPasswordCompleted=true
			fi
			#there is no point on limiting if completion will earn 2x: if((nLuckAdd > nClipLim));then nLuckAdd=nClipLim;fi
			FUNCluckCheck --noBadLuck;nLuckSetOnNextLoop=$FUNCluckCheck_OUT_nLuckTmp
			bApplyLuckOnce=false
		fi
		if [[ -n "$strClipboard" ]] && [[ -n "${strTryType}" ]] && [[ ! "$strClipboard" =~ ^${strTryTypeFIXEDREGEX}.* ]];then
			strPasswordStatus=" ${strEscGreenAlert}!!!WRONG!!!"
			nSlowDownCount=$nSlowDownLim # prevent new slowdowns
			bPasswordWrong=true
		else
			strPasswordStatus=" (OK$(if $bPasswordCompleted;then echo "!!!";fi))"
		fi
		
		strFunCurrentChar="${strFunChars:$((RANDOM%${#strFunChars})):1}"
		strFunProgress+="$strFunCurrentChar"
		echo -e "${strEscGreen}PASSWORD[${nLuckAdd}/${#strClipboard}]: '${strClipboard}' ${strEscGreenLight}${strTryType}${strPasswordStatus}"
		echo -e "${strEscGreen}DECRIPTING DATABASE [timeout:$((SECONDS-nSeconds+1))s/${nFunWayTimeout}s][slowdowns:$nSlowDownCount/$nSlowDownLim]:${strEscGreen} [${#strFunProgress}]='${strFunCurrentChar}' ${strEscGreenDim}$strFunProgress${_strEscEnd}";
		
		if [[ "$strFunProgress" =~ (${strFunJackPotRegexMatch}) ]];then
			echo -e "${strEscGreenAlert} !!!YEAH:$(echo "$strFunProgress" |egrep -o "$strFunJackPotRegexMatch")!!!${_strEscEnd}";
			nLuckSetOnNextLoop=1;
			if $bDebugTestLuck;then echo -e "${strEscGreenAlert} !!! :) :D xD XDDM DXMD !!! ${_strEscEnd}";read;fi
		fi
		echo
		echo -en "${strEscGreen}$strSessionInfo: "
		echo -en "${strEscGreenLight}LVL=$nLvl${strEscGreen}; "
		echo -e  "Luck=$nLuck LuckRoll[$nLuckRollCount/$nLuckTot]=$nLuckChk/${strEscGreenLight}$((nGoodLuck-nLuckAdd))${strEscGreenDim}/100 ${strLuck}"
		#echo "[<${strFunChars:$((RANDOM%${#strFunChars})):1}>]"
		
		###########################   - - - - - =>
		 ## LAST ##      #
		  #######        #
		
		if ((nReadInputCountUp >= nReadInputLoopInterval));then
			if ! $bPasswordCompleted && ! $bPasswordWrong;then
				echo -n .;read -n 1 -t 0.001 strTryTypeChars >/dev/null;FUNCclearBuffer # will read the first char from the buffer!!! Must be the last thing to not break the above fast text printing. the user must type it and not paste so clear the buffer ;)
				if(( nSlowDownCount < nSlowDownLim ));then
					bSkipMouseMove=false
					if [[ -z "$strCursorPos" ]];then bSkipMouseMove=true;fi #first only
					strCursorPosPrevious="${strCursorPos}"
					strCursorPos="$(xdotool getmouselocation)"
					if ! $bSkipMouseMove && [[ "$strCursorPos" != "$strCursorPosPrevious" ]];then
						echo -e "${strEscGreen}[Mouse Moved] System slow down..."
						read -n 1 -t $nSysSlowDownDelay strTryTypeCharOnSlowDown;FUNCclearBuffer
						if [[ -n "$strTryTypeCharOnSlowDown" ]];then
							strTryTypeChars+="$strTryTypeCharOnSlowDown"
						fi
						((nSlowDownCount++))&&:
						((nFunWayTimeout+=nSysSlowDownDelay))&&:
					fi
				fi
				# the player will be selecting text if the mouse move above
				strClipboard="$(xclip -selection primary -o 2>/dev/null |tr -d '\n\r\t')" # selected by mouse cursor
				strClipboard="${strClipboard:0:$nClipLim}"
				strClipboardFIXEDREGEX="$(FUNCfixRegex "$strClipboard")"
			fi
			
			if $bPasswordCompleted;then # completing the password will bring more luck
				: ${nMultClipLim:=4} #help min 1. A bigger value will make it more difficult to have increased luck after completing typing the password
				nChkPassC=$(( RANDOM%(nClipLim*nMultClipLim) ))
				strDbgPassC+="$nChkPassC "
				if((nChkPassC < ${#strTryType}));then # the bigger the password typed, higher chances to reroll dice
					FUNCluckCheck --noBadLuck;nLuckSetOnNextLoop=$FUNCluckCheck_OUT_nLuckTmp
				fi
				((nLuckTot++))&&: # skipped = nLuckTot-nLuckRollCount
			fi
			
			nReadInputCountUp=0
		fi
		
		((nReadInputCountUp++))&&:
		
		if $bFirstLoopIsBugged;then clear;echo -e "${strEscGreen}[ERROR: SYSTEM CRASH, FIRST LOOP BUG]";bFirstLoopIsBugged=false;fi #help:TODO: remove this when first loop bug of always jackpot is fixed :/. A real bug that became thematic! xD
		
		if((nLuck!=0));then break;fi
	done
	echo -en "${strEscGreenDim}[DISCONNECTED]"
	if ! $bDebugTestLuck;then
		sleep 1;echo -n . # so user have a chance to stop typing challenge
		sleep 1;echo -n .
		sleep 1;echo -n .
	fi
	echo -en "$strSessionInfo:\n$strFUNCrandomSoftwares\n" >>"$(basename "${0}.log")"
done

