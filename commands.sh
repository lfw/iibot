#!/bin/bash

# This script executes when a a message is recieved from a user that is prefixed by a '!'.
# This file should identify and execute the command requested. 

MYPID=$$

# Lower case it all to avoid confusion.
CHAN=${1,,}
M_NICK=${2,,}
M_MSG=${3,,}
nick=${M_NICK:1:${#M_NICK}-2}

[ -z "$CHAN" ] || [ -z "$M_NICK" ] || [ -z "$M_MSG" ] && \
    printf "Usage: %s [channel] [nick] [message]\n" "$0" >&2 && \
    exit 1

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ -f $SCRIPT_DIR/config ] && . $SCRIPT_DIR/config

function hasAccess {
    local _user=$($SCRIPT_DIR/getlogin.sh $nick 2> /dev/null)
    local _chan=$1
    local _role=$2

    [[ -z $_user ]] && exit 1
    [ ! -f ${SCRIPT_DIR}/uac.sh ] && return 1

    ${SCRIPT_DIR}/uac.sh "check" $_user $_chan $_role
    return $?
}

function grantAccess {
    local _user=$($SCRIPT_DIR/getlogin.sh $1 2> /dev/null)
    local _chan=$2
    local _role=$3

    [[ -z $_user ]] && printf "Could not find username.\n" && exit 1

    ## Fix this use login name, not nick
    ${SCRIPT_DIR}/uac.sh "add" $_user $_chan $_role
    return $?
}

function revokeAccess {
    local _user=$($SCRIPT_DIR/getlogin.sh $1 2> /dev/null)
    local _chan=$2
    local _role=$3

    [[ -z $_user ]] && exit 1

    ## Fix this use login name, not nick
    ${SCRIPT_DIR}/uac.sh "remove" $_user $_chan $_role
    return $?
}

function printAccess {
    local _chan=$1

    ${SCRIPT_DIR}/uac.sh "print" "null" $_chan "null"
    return $?
}

CommandList=(
    help
    ping
    talk
    slap
    time
    uptime
    dance
    echo
    inrole
    roles
    grant
    revoke
    join
    send
)

AUTH_FAIL="You dont have permission to run this command."

# All commands should be lower case.
case "${M_MSG%% *}" in
    help)
	printf -- "%s: %s\n" "${nick}" "${CommandList[*]}"
	;;
    ping)
	# Quick check to see if the bot is responding.
	printf -- "%s: pong\n" "${nick}"
	;;
    talk)
	# Check if we are already monitoring the fifo
	# If so then just pm them. otherwise, start a
	# new monitor, then pm them.
	if [ -f ${FS}/${HOST}/${nick}/out ]; then 
	    printf -- "You rang?\n" > $FS/$HOST/$nick/in
	else
	    ${SCRIPT_DIR}/join.sh "${nick}" &> /dev/null &
	    printf -- "/privmsg %s Yo\n" "$nick"
	fi
	;;
    slap)
	args=($M_MSG)
	[ ${args[1]} == ${NICK,,} ] && printf -- "%s: Slap yourself!\n" "$nick" && exit
	[ ${args[1]} == "java" ] && printf -- "Slaping Java is not enough. You must grind it to dust and boil its remains.\n" && exit	    
	printf -- "%s: Are you going to take that?\n" "${args[1]}"
	;;
    time)
	printf -- "%s\n" "$(date +%r)"
	;;
    uptime)
	printf -- "%s\n" "$(uptime)"
	;;
    dance)
	printf -- "I'm dancing the night away!\n"
	;;
    echo)
	printf -- "%s\n" "${M_MSG:5}"
	;;
    roles)
	args=($M_MSG)
	[ -z ${args[1]} ] && channel=$CHAN || channel=${args[1]}
	printAccess $channel
	;;
    inrole)
	args=($M_MSG)
	[ -z ${args[1]} ] && printf -- "Usage: !inrole <role name>\n" && exit

	if [[ $(hasAccess "$CHAN" "${args[1]}") == "True" ]]; then
	    printf -- "%s: You are a member of role: %s\n" "$nick" "${args[1]}"
	else
	    printf -- "%s: Nope, better luck next time\n" "$nick"
	fi
	;;
    grant)
	args=($M_MSG)
	login=${args[1]}
	role=${args[2]}
	[ ! -z ${args[3]} ] && channel=${args[3]} || channel=$CHAN

	[ -z $login ] || [ -z $role ] && printf -- "Usage: !grant <login> <role name> [channel]\n" && exit

	if [[ $(hasAccess "$channel" "operator") == "True" ]]; then 
	    grantAccess $login $channel $role
	    [ $? -eq 0 ] &&
		printf -- "%s: Added %s to %s (%s)\n" "$nick" "${args[1]}" "${args[2]}" "$CHAN" || \
		printf -- "%s: Something whent wrong here.\n" "$nick"
	else
	    printf -- "%s: %s\n" "$nick" "$AUTH_FAIL"
	fi
	;;
    revoke)
	args=($M_MSG)
	login=${args[1]}
	role=${args[2]}
	[ ! -z ${args[3]} ] && channel=${args[3]} || channel=$CHAN

	[ -z $login ] || [ -z $role ] && printf -- "Usage: !revoke <login> <role name> [channel]\n" && exit

	if [[ $(hasAccess "$channel" "operator") == "True" ]]; then 
	    revokeAccess $login $channel $role
	    [ $? -eq 0 ] &&
		printf -- "%s: Remove %s from %s (%s)\n" "$nick" "${args[1]}" "${args[2]}" "$CHAN" || \
		printf -- "%s: Something whent wrong here.\n" "$nick"
	else
	    printf -- "%s: %s\n" "$nick" "$AUTH_FAIL"
	fi
	;;
    send)
	args=($M_MSG)
	channel=${args[1]}

	# Validate input
	[ -z ${args[2]} ] || [ -z $channel ] && printf -- "Usage: !send <channel> <message>\n" && exit
	[[ $channel != \#* ]] && printf -- "%s: This does not look like a channel name.\n" "$nick" && exit

	# Check for access
	if [[ $(hasAccess $channel "operator") == "True" ]]; then
	    [ ! -f $FS/$HOST/${channel}/out ] && printf -- "%s: I am not in that channel.\n" "$nick" && exit
	    [[ $channel == $CHAN ]] && printf -- "%s: You might consider !echo in this instance.\n" "$nick" && exit
	    printf -- "%s\n" "${M_MSG:${#channel}+6}" > $FS/$HOST/${channel}/in
	else
	    printf -- "%s: %s\n" "$nick" "$AUTH_FAIL"
	fi
	;;
    join)
	args=($M_MSG)
	channel=${args[1]}
	# Validate input
	[ -z $channel ] && printf -- "Usage: !join <channel>\n" && exit
	[[ $channel != \#* ]] && printf -- "%s: This does not look like a channel name.\n" "$nick" && exit

	# Check for access
	if [[ $(hasAccess $channel "operator") == "True" ]]; then
	    [ -f $FS/$HOST/${channel}/out ] && printf -- "%s: I think i am already in that channel.\n" "$nick" && exit
	    ${SCRIPT_DIR}/join.sh "${channel}"
	else
	    printf -- "%s: %s\n" "$nick" "$AUTH_FAIL"
	fi
	;;
esac
