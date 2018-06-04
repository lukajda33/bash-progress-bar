#!/bin/bash
trap interrupt INT
function interrupt() {
	tput cvvis
	if [ $progressCols -gt 8 ]
	then
		echo -e '  '"\r""$(tput setaf 1)**INTERRUPTED**$(tput sgr 0)"'  '$(tput el)
		exit 1
	else
		echo -e "\r""$(tput setaf 1)*SIGINT*$(tput sgr 0)"$(tput el)
		exit 1
	fi
}
 
function progressDraw () {
	percentage=$(( $progressDone * 100 / $progressMax ))
	if [ $progressCols -gt 8 ]
	then
		progressReal=$(( $progressCols * $percentage / 100 ))
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
		echo -ne ${progressColor}"$percentage"' %'"\r"${progressRst}
	fi
}

function progressInit(){
	progressMessageLength=$(( ${#progressMessage1} + ${#progressMessage2} ))
	if [ $progressMessageLength -ge $(( $(tput cols) -5 )) ]
	then
		echo Your message is too long.
		exit 3
	fi
	progressCols=$(( $(tput cols) - $progressMessageLength )) 
	progressColor=$(tput setaf "$progressColorValue")
	progressRst=$(tput sgr 0)								#resets color
	if [ ${#progressChar} -ne 1 ]
	then
		echo Variable progressChar must be one single character.
		exit 2
	fi
	if [ ${#progressLine} -ne 1 ]
	then
		echo Variable progressLine must be one single character.
		exit 2
	fi
	
}

#values
progressColorValue=2						# 0=black; 1=red; 2=green; 3=yellow; 4=blue; 5=magenta; 6=cyan; 7=white
progressDone=0
progressMax=100
progressChar='█'							# chars to copy: █ # 
progressLine='.'
progressMessage1=' Progress: '
progressMessage2=' '

#before launch
tput civis
progressInit

#loop
while [ $progressDone -lt $progressMax ]
do
	progressDone=$(( $progressDone + 1 ))
	progressDraw
done

#after finishing
echo
tput cvvis

exit 0
