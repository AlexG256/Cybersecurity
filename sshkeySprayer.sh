#!/bin/bash


print_error_message(){
        echo "Usage: $0 (ip) (users.txt)"
        echo
        echo "A script used to spray an ssh key against multiple users"
        echo
        echo "options:"
        echo "  -h, --help"
        echo "  Shows this error message and exits"
        exit 1
}

if [[ $# -lt 2 ]]; then
	print_error_message
fi

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			print_error_message
			;;
		*)
			shift
			;;
	esac
done


while IFS= read -r user; do 
	ssh -T -o BatchMode=yes -i id_rsa $user@$ip
done < {userFile}
