#!/bin/bash


printing_all=false

print_error_message() {
	echo "Usage: $0 (base64_string_or_file) (number_of_decodes) [OPTIONS]"
	echo ""
	echo "A script used to decode a nested base64 string"
	echo ""
	echo "options:"
	echo "  -a, --all"
	echo "	Shows the string at every step of being decoded"
	echo "  -h, --help"
	echo "	Shows this error message and exits"
	exit 1
}

if [ $# -lt 2 ]; then
	print_error_message
fi

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			print_error_message
			;;
		-a|--all)
			printing_all=true
			shift
			;;
		-*)
			print_error_message
			;;
		*)
			file_or_string=$1
			if [[ -z $2 ]]; then
				print_error_message
			fi
			number_of_decodes=$2
			shift 2
			;;
	esac
done

#Every iteration adds one layer of base64 -d
cmdString=" | base64 -d"
tempString=""

#Begins the final executed command with "cat" if the provided argument is a file or "echo" if its a string
if [[ -f "$file_or_string" ]]; then
	tempString="cat $file_or_string"
else
	tempString="echo $file_or_string"
fi

#for loop using the second argument as the size of the loop
for ((i = 0; i < $number_of_decodes; i++)); do 
	if $printing_all; then
		echo "Iteration $i"
		bash -c "$tempString"
		echo ""
	fi
	tempString+="$cmdString"
done	

if $printing_all; then
	echo "Final iteration"
else
	echo "Final Result:"
fi

#Final statement that executes tempString
bash -c "$tempString"
