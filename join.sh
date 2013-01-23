#!/bin/bash

# This Script monitors a specific 'in' file in the ii file system.
# It is assumed this function is thread independent and re-entrent.

[ -z $1 ] && printf "Usage: %s [Channel]\n" "$0" && exit 1

MYPID=$$
CHAN="${1}"

# This function will fork processing to diffrent subscripts bassed on user
# ARGUMENTS:
#   $1   Nick    - the nick that sent the message
#   $2   Message - the content of the message
function process {

    ## Skip messages from self
    [[ "${1:1:${#1}-2}" == "$NICK" ]] && return

    if [[ "${1}" == '-!-' ]]; then
	exec ${SCRIPT_DIR}/chanserv.sh "$CHAN" "$1" "$2" | fold -w 255 1> $FS/$HOST/$CHAN/in
    else 
	if [[ "$2" =~ ^! ]]; then
	    exec ${SCRIPT_DIR}/commands.sh "$CHAN" "$1" "${2#\!}" | fold -w 255 1> $FS/$HOST/$CHAN/in
	else
	    exec ${SCRIPT_DIR}/chatter.sh "$CHAN" "$1" "$2" | fold -w 255 1> $FS/$HOST/$CHAN/in
	fi
    fi	
}

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ -f $SCRIPT_DIR/config ] && . $SCRIPT_DIR/config

# If we are alrady in the channel then we DONOT want to rejoin. That would be bad.
[ -f $FS/$HOST/$CHAN/out ] && printf "ERROR: I think i am already in that channel.\n" && exit 1

# Make sure we are running and account for new process
[ ! -f $PIDFILE ] && printf "ERROR: iibot does not apears to be running.\n" && exit 1
printf "%s " "$MYPID" >> $PIDFILE

# Join channel
printf "/j %s\n" "${CHAN}" > $FS/$HOST/in
while [ ! -f $FS/$HOST/$CHAN/out ]; do
    sleep 1
done

while [ -f $PIDFILE ]; do
    tailf -n 1 $FS/$HOST/$1/out | \
    if read -r date time nick msg; then
	process "${nick}" "${msg}" 2> /dev/null & 
	printf "%s: %s %s %s %s\n" "${CHAN}" "${date}" "${time}" "${nick}" "${msg}" | tee -a $LOG &
    fi
done


