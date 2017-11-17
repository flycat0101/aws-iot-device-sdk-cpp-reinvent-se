#!/bin/bash

# A71CH Key provisioning script
#
# Preconditions
# - A71CH with Debug Mode attached (script can be adapted to work without Debug Mode
#   relevant key slots must then be available for writing, SCP03 must be off)
#
# Postconditions
# - A complete set of key files (*.pem) created (existing ones overwritten)
# - ECC Keys that can be provisioned in the A70CI have been injected

# TODO:
# - Create a (persistent?) reference to the Ephemeral Key Pair

# GLOBAL VARIABLES
# ----------------
A71CH_PROVISIONING_SCRIPT="0.8"

# ECC keys to be stored in A71CH
# ------------------------------
ecc_key_kp_0="key/iot-ecckey.key"
ecc_key_kp_0_ref="key/iot-ref.key"

# UTILITY FUNCTIONS
# -----------------
# execCommand will stop script execution when the program executed did not return OK (i.e. 0) to the shell
execCommand () {
	local command="$*"
	echo ">> ${command}"
	${command}
	local nRetProc="$?"
	if [ ${nRetProc} -ne 0 ]
	then
		echo "\"${command}\" failed to run successfully, returned ${nRetProc}"
		exit 2
	fi
	echo ""
}  

# testCommand will trigger program execution, but not exit the shell when program returns 
# non zero status
testCommand () {
	local command="$*"
	echo ">> ** TEST ** ${command}"
	${command}
	local nRetProc="$?"
	if [ ${nRetProc} -ne 0 ]
	then
		echo "\"${command}\" failed to run successfully, returned ${nRetProc}"
		echo ">> ** TEST ** FAILED"
	fi
	echo ""
	# sleep 1
}

# --------------------------------------------------------------
# Start of program - Ensure an A71CH is connected to your system.
# --------------------------------------------------------------
echo "A71CH Key provisioning script (Rev.${A71CH_PROVISIONING_SCRIPT})."
echo "Executing this script will create new keys and insert these keys"
echo "in the attached A71CH secure element."

read -r -p "Are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Continuing"
else
    echo "Halting script execution. Key files not touched. Secure Element not provisioned!"
	exit 1
fi

# Check whether IP:PORT was passed as argument
if [ -z "$1" ]; then 
    ipPortVar=""
else
	ipPortVar="$1"
fi

# Evaluate the platform we're running on and set exec path and
# command line argumemts to match platform
# This 'heuristic' can be overruled by setting the probeExec variable upfront
# 
# probeExec="sudo ../../../../linux/a71chConfig_iicbird_native"
#
if [ -z "$probeExec" ]; then
	platformVar=$(uname -o)
	echo ${platformVar}
	if [ "${platformVar}" = "Cygwin" ]; then
		echo "Running on Cygwin"
		if [ "${ipPortVar}" = "" ]; then
			# When not providing an IP:PORT parameter, we will invoke VisualStudio built exe
			# and assumme the card server is running on localhost.
			echo "Selecting Visual Studio build exe."		
			probeExec="../../../../win32/a71chConfig/Debug/a71chConfig.exe 127.0.0.1:8050"
		else
			probeExec="../../../../linux/a71chConfig_socket_native.exe ${ipPortVar}"
		fi	
	else
		echo "Assume we run on Linux"
		if [ "${ipPortVar}" = "" ]; then
			probeExec="./a71chConfig_i2c_ls"
		else		
			probeExec="../../../../linux/a71chConfig_socket_native ${ipPortVar}"			
		fi
	fi
fi

# Sanity check on existence probeExec
stringarray=($probeExec)
if [ "${stringarray[0]}" = "sudo" ]; then
	if [ ! -e ${stringarray[1]} ]; then
		echo "Can't find program executable ${stringarray[1]}"
		exit 3
	fi
else
	if [ ! -e ${stringarray[0]} ]; then
		echo "Can't find program executable ${stringarray[0]}"
		exit 3
	fi
fi

# Connect with A71CH, debug reset A71CH and insert keys
# -----------------------------------------------------
execCommand "${probeExec} debug reset"
execCommand "${probeExec} set pair -x 0 -k ${ecc_key_kp_0}"
execCommand "${probeExec} refpem -c 10 -x 0 -k ${ecc_key_kp_0} -r ${ecc_key_kp_0_ref}"

execCommand "${probeExec} info pair"
