#!/bin/bash

source view/console-formatter.sh

output(){
	input="${1}"
	printf "${yopen}${input}${yclose}\n"
}

success_message(){
	printf "${gopen}Done!${gclose}\n"
}

create_swapfile(){
	swapfile="${1}"
	# Creates a 2.0GB swapfile
	printf "${mopen}Creating a 2.0GB swapfile${mclose}\n"
	dd if=/dev/zero of=${swapfile} bs=2048000 count=1000 && success_message

	# Changing the owner to root
	printf "${yopen}Change Owner of swapfile${yclose}\n"
	chown root:root ${swapfile} && success_message

	# Changing the permission
	printf "${mopen}Secure swapfile${mclose}\n"
	chmod 0600 ${swapfile} && success_message

	# Activate swapfile
	printf "${yopen}Activate swapfile${yclose}\n"
	mkswap ${swapfile} && success_message

	_fstab_check="$(egrep ${swapfile} /etc/fstab)"
	if [ -z "${_fstab_check}" ];
	then
		echo "${swapfile} none swap sw 0 0" >> /etc/fstab && success_message
	fi
	swapon ${swapfile}
}

help_menu(){
	printf "${gopen}Initialize Swapfile Wrapper${gclose}\n"
	printf "${mopen}Set Action\t${copen}[ --action=EXEC_ACTION ]${cclose}\n"
	printf "${mopen}Set Name\t${copen}[ --name=SWAP_NAME ]${cclose}\n"
	printf "${yopen}Usage${yclose}\n"
	printf "$(echo $0 | sed 's/^\.\///g') --action=create --name=swapfile1\n"
	exit 0
}

for args in $@
do
	case $args in
		--action=*)
		_action=$(echo $args | cut -d'=' -f2)
		output "${_action}"
		;;
		--name=*)
		_name=$(echo $args | cut -d'=' -f2)
		output "${_name}"
		;;
		-h|-help|--help) help_menu;;
	esac
done

case $_action in
	create|create-swap)
	[ ! -z "${_name}" ] && create_swapfile ${_name} || create_swapfile '/swapfile'
	;;
	*) output "No action was taken";;
esac




