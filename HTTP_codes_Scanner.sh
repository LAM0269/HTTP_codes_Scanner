#!/bin/bash
clear
printf "[+] HTTP response code scanner.\n"
printf "[+] Version 1.0\n\n"

#------------------------------------------------------------Checking inputs
if [ $# -ge 1 ];then

	#--------------------------------------------------------User settings
	followR=A #Tell if we must follow HTTP redirection
	while [[ $followR != 'y' && $followR != 'n' ]]
	do
		read -p "Follow redirections ? (y/n) " -n 1 followR
		echo ""
	done

	ChoiHTTP=A #Tell if we must check for https and http
	while [[ $ChoiHTTP != '0' && $ChoiHTTP != '1' && $ChoiHTTP != '2' ]]
	do
		read -p "Check HTTP only : 0, HTTPS only : 1; HTTP and HTTPS : 2 ? " -n 1 ChoiHTTP
		echo ""
	done
	
	insecure=A
	if [[ $ChoiHTTP -eq 1 || $ChoiHTTP -eq 2 ]]; then
		while [[ $insecure != 'y' && $insecure != 'n' ]]
		do
			read -p "Skip certificate validation ? (y/n) " -n 1 insecure
			echo ""
		done
	fi
	
	echo ""

	#--------------------------------------------------------Settings
	case $ChoiHTTP in
			"0")
					tabHTTP[0]='HTTP://'
					;;
			"1")
					tabHTTP[1]='HTTPS://'
					;;
			"2")
					tabHTTP[0]='HTTP://'
					tabHTTP[1]='HTTPS://'
					;;
	esac

	if test $insecure = 'y'; then
		insecure="-k"
	else
		insecure=""
	fi


	if test $followR  = 'y'; then
		followR="-L"
	else
		followR=""
	fi

	#--------------------------------------------------------Displaying
	hosts=$(sed "s/^https\?:\/\///" $1)
	long=$(echo $hosts | sed 's/ /\n/g' | sort | uniq | awk '{print length}' | sort -nr | head -n 1) #Longest URL length
	let "long = $long + 10" #Add protocole length

	for protocole in "${tabHTTP[@]}";do
			
		for host in $hosts;do
			ret=$(curl "$protocole$host" -w "%{http_code}" -s -o /dev/null $followR $insecure)
			l=$(echo $ret | cut -c1) #First letter of code

			if test $l = '2'; then #Green
				color=$'\e[1;32m'
			elif test $l = '4' -o $l = '0' -o $l = '5';then #Ree
				color=$'\e[1;31m'
			else #Orange
				color=$'\e[1;33m'
			fi	
				
			end=$'\e[0m'

			printf "%-${long}s $color[%s]$end\n" $protocole$host $ret
		done
	done
else
	printf "[+] Exemple : HTTP_codes_Scanner.sh hosts.txt.\n"
	printf "[+] hosts file must have one host per line.\n\n"
fi