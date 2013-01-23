#!/bin/bash

# This script executes when a message from chanserv, user -!-, is recieved.
# The loose intension of this script is to set user status to execute some commands.

MYPID=$$

CHAN=$1
M_NICK=$2
M_MSG=$3

[ -z $CHAN ] || [ -z $M_NICK ] || [ -z "$M_MSG" ] && \
    printf "Usage: %s [channel] [nick] [message]\n" "$0" >&2 && \
    exit 1

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ -f $SCRIPT_DIR/config ] && . $SCRIPT_DIR/config

function code2val {
    [ -z $2 ] && ret=0 || ret=$2

    case "$1" in
	+v)
	    ret=$[1 | $ret] ;;
	+o)
	    ret=$[2 | $ret] ;;
	-v)
	    ret=$[2 & $ret] ;;
	-o)
	    ret=$[1 & $ret] ;;
    esac

    printf "%s" "$ret"
}

# Log users op/voice status into the irc_passwd file.
if [[ "${M_MSG,,}" =~ "mode/${CHAN}" ]]; then
    MODE=${M_MSG/*->}
    USER=${MODE/* }
    MODE=${MODE% *}

    [ ${USER,,} == ${NICK,,} ] && exit 0

    # Channel:User:INT
    CurrentValue=$(grep ^${CHAN,,}:${USER,,}: ${SCRIPT_DIR}/irc_passwd | cut -d":" -f3)
    NewValue=$(code2val $MODE $CurrentValue)

    if [ -z $CurrentValue ]; then
	printf "%s:%s:%s\n" "${CHAN,,}" "${USER,,}" "$NewValue" >> ${SCRIPT_DIR}/irc_passwd
    else
	if [ $CurrentValue != NewValue ]; then
	    sed -i ",,s/{$CHAN}:${USER,,}:$CurrentValue/${CHAN,,}:${USER,,}:$NewValue/" ${SCRIPT_DIR}/irc_passwd
	fi
    fi
fi

# Greet users as they join.
[[ "$M_MSG" =~ joined ]] && [[ "${M_MSG,,}" =~ ${CHAN,,} ]] && \
    printf -- "Hello %s!\n" "${M_MSG%%(*}" && \
    printf -- "voice %s %s\n" "$CHAN" "${M_MSG%%(*}" > $FS/$HOST/chanserv/in
