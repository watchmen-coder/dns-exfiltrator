#!/bin/bash

start=$(date "+%s.%N")

# -------------------------- INFO --------------------------

function basic () {
	proceed=false
	echo "DNS Payload Extractor v1.0 ( github.com/ivan-sincek/dns-exfiltrator )"
	echo ""
	echo "Usage:   ./dns_payload_extractor.sh -f file"
	echo "Example: ./dns_payload_extractor.sh -f wireshark_tcp_stream.txt"
}

function advanced () {
	basic
	echo ""
	echo "DESCRIPTION"
	echo "    Extract DNS payload from Wireshark TCP stream"
	echo "FILE (required)"
	echo "    Specify a file with Wireshark TCP stream"
	echo "    -f <file> - wireshark_tcp_stream.txt | etc."
}

# -------------------- VALIDATION BEGIN --------------------

# my own validation algorithm

proceed=true

# $1 (required) - message
function echo_error () {
	echo "ERROR: ${1}"
}

# $1 (required) - message
# $2 (required) - help
function error () {
	proceed=false
	echo_error "${1}"
	if [[ $2 == true ]]; then
		echo "Use -h for basic and --help for advanced info"
	fi
}

declare -A args=([file]="")

# $1 (required) - key
# $2 (required) - value
function validate () {
	if ! [[ -z $2 ]]; then
		if [[ $1 == "-f" && -z ${args[file]} ]]; then
			args[file]=$2
			if   ! [[ -e ${args[file]} ]]; then
				error "File does not exists"
			elif ! [[ -r ${args[file]} ]]; then
				error "File does not have read permission"
			elif ! [[ -s ${args[file]} ]]; then
				error "File is empty"
			fi
		fi
	fi
}

# $1 (required) - argc
# $2 (required) - args
function check() {
	local argc=$1
	local -n args_ref=$2
	local count=0
	for key in ${!args_ref[@]}; do
		if [[ ${args_ref[$key]} != "" ]]; then
			count=$((count + 1))
		fi
	done
	echo $((argc - count == argc / 2))
}

if [[ $# == 0 ]]; then
	advanced
elif [[ $# == 1 ]]; then
	if   [[ $1 == "-h" ]]; then
		basic
	elif [[ $1 == "--help" ]]; then
		advanced
	else
		error "Incorrect usage" true
	fi
elif [[ $(($# % 2)) -eq 0 && $# -le 6 ]]; then
	for key in $(seq 1 2 $#); do
		val=$((key + 1))
		validate ${!key} ${!val}
	done
	if [[ ${args[file]} == "" || $(check $# args) -eq false ]]; then
		error "Missing a mandatory option (-f)" true
	fi
else
	error "Incorrect usage" true
fi

# --------------------- VALIDATION END ---------------------

# ----------------------- TASK BEGIN -----------------------

# $1 (required) - file
function extract () {
	# add "uniq" to remove duplicates - not "sort -u"
	local payload=$(cat $1 | grep -P -o "(\{(?:[^\{\}]+|(?-1))+\})" | jq -S ".responses|=sort_by(.time)" | grep -P -o "(?<=\"subDomain\"\:\ \")[^\s\.]+" | tr -d "[:space:] | ")
	if [[ -z $payload ]]; then
		error "Payload was not found"
	else
		# replace "plus" with "+"
		payload=${payload//plus/\+}
		# replace "slash" with "/"
		payload=${payload//slash/\/}
		# add padding "="
		local padding=${#payload}
		padding=$((4 - padding % 4))
		if [[ $padding -eq 3 ]]; then
			error "Base64 input is not valid"
		else
			if [[ $padding -eq 1 || $padding -eq 2 ]]; then
				for i in $(seq 1 $padding); do
					payload="${payload}="
				done
			fi
			payload=$(echo $payload | base64 -d 2>&1)
			if [[ $payload =~ "base64: invalid input" ]]; then
				error "Base64 input is not valid"
			else
				echo $payload
			fi
		fi
	fi
}

if [[ $proceed == true ]]; then
	echo "########################################################################"
	echo "#                                                                      #"
	echo "#                      DNS Payload Extractor v1.0                      #"
	echo "#                                       by Ivan Sincek                 #"
	echo "#                                                                      #"
	echo "# Extract DNS payload from Wireshark TCP stream.                       #"
	echo "# GitHub repository at github.com/ivan-sincek/dns-exfiltrator.         #"
	echo "# Feel free to donate bitcoin at 1BrZM6T7G9RN8vbabnfXu4M6Lpgztq6Y14.   #"
	echo "#                                                                      #"
	echo "########################################################################"
	extract ${args[file]}
fi

# ------------------------ TASK END ------------------------
