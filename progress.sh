#!/bin/bash

# variables: 
# calculations: progressCols, progressPercentage, progressDone, progressMax, progressRemaining, progressReal
# customizing: progressMessage1, progressMessage2, progressChar, progressLine, progressColor,
# other: progressMessageLength, progressRst

# functions: progressInit, progressDraw, progressInterrupt 

trap progressInterrupt INT
function progressInterrupt() {
	tput cvvis
	if [[ $progressCols -gt 8 ]]
	then
		echo -e '  '"\r""$(tput setaf 1)**INTERRUPTED**$(tput sgr 0)"'  '$(tput el)
		exit 1
	else
		echo -e "\r""$(tput setaf 1)*SIGINT*$(tput sgr 0)"$(tput el)
		exit 1
	fi
}
 
function progressDraw () {
	progressPercentage=$(( $progressDone * 100 / $progressMax ))
	if [[ $progressCols -gt 8 ]]
	then
		progressReal=$(( $progressCols * $progressPercentage / 100 ))
		progressRemaining=$(( $progressCols - $progressReal ))
		echo -n "$progressMessage1"
		for i in $(seq $progressReal)
		do
			 echo -n ${progressColor}"$progressChar"${progressRst}
		done
		for i in $(seq $progressRemaining)
		do
			echo -n ${progressColor}"$progressLine"${progressRst}
		done
		echo -ne "$progressMessage2""\r"
	else
		echo -ne ${progressColor}"$progressPercentage"' %'"\r"${progressRst}
	fi
}

function progressInit(){
	#values
	progressColorValue=2				# 0=black; 1=red; 2=green; 3=yellow; 4=blue; 5=magenta; 6=cyan; 7=white
	progressDone=0
	progressMax=1
	progressChar='#'					# chars to copy: █ # 
	progressLine='.'
	progressMessage1=' Progress: | '
	progressMessage2=' | '
	
	if [[ $progressDone -gt $progressMax ]]
	then 
		echo "Variable 'progressDone' must exceed value of 'progressMax'."
		exit 7
	fi

	progressMessageLength=$(( ${#progressMessage1} + ${#progressMessage2} ))
	if [[ $progressMessageLength -ge $(( $(tput cols) -5 )) ]]
	then
		echo "Your message is too long."
		exit 3
	fi
	progressCols=$(( $(tput cols) - $progressMessageLength ))
 
	if [[ ${#progressChar} -ne 1 ]]
	then
		echo "Variable 'progressChar' must be one single character."
		exit 2
	fi
	if [[ ${#progressLine} -ne 1 ]]
	then
		echo "Variable 'progressLine' must be one single character."
		exit 2
	fi
	
	case $progressDone in
    ''|*[!0-9]*) echo "Variable 'progressDone' must be a number." ; exit 4 ;;
    *) ;;
	esac
	
	case $progressMax in
    ''|*[!0-9]*) echo "Variable 'progressMax' must be a number." ; exit 4 ;;
    *) ;;
	esac

	case $progressColorValue in
	''|*[!0-9]*) echo "Variable 'progressColorValue' must be a number." ; exit 5 ;;
	*) 
		if [[ $progressColorValue -gt $(tput colors) ]]
		then 
			echo "Variable 'progressColorValue' is too high, max is: $(tput colors)."
			exit 5
		fi
	;;
	esac
	
	progressColor=$(tput setaf "$progressColorValue")
	progressRst=$(tput sgr 0)								#resets color
}

#main function
tput civis
progressInit
while [[ $progressDone -lt $progressMax ]]
do
	progressDone=$(( $progressDone + 1 ))
	progressDraw
done
echo
tput cvvis

exit 0
