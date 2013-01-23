#!/bin/bash

# This script executes when a a message is recieved from a user that is prefixed by a '!'.
# This file should identify and execute the command requested. 

MYPID=$$

CHAN=$1
M_NICK=$2
M_MSG=$3

CMD=${M_MSG%% *}
nick=${M_NICK:1:${#M_NICK}-2}

[ -z "$CHAN" ] || [ -z "$M_NICK" ] || [ -z "$M_MSG" ] && \
    printf "Usage: %s [channel] [nick] [message]\n" "$0" >&2 && \
    exit 1

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ -f $SCRIPT_DIR/config ] && . $SCRIPT_DIR/config
[ -f $SCRIPT_DIR/passwords ] && . $SCRIPT_DIR/passwords

function userAccess {
    # channel:user:INT
    ret=$(grep -i ^$CHAN:$nick: ${SCRIPT_DIR}/irc_passwd | cut -d":" -f3)
    [ -z $ret ] && ret=0
    printf "%s" "$ret"
}

CommandList=(
    ping
    talk
    help
    os
    give
    time
    uptime
    ipaddr
    slap
)
# All commands should be lower case.
case "${CMD,,}" in
    help)
	printf -- "%s: %s\n" "${nick}" "${CommandList[*]}"
	;;
    ping)
	printf -- "%s: pong\n" "${nick}"
	;;
    talk)
	if [ -f ${FS}/${HOST}/${nick}/out ]; then 
	    printf -- "You rang?\n" > $FS/$HOST/$nick/in
	else
	    ${SCRIPT_DIR}/join.sh "${nick}" &> /dev/null &
	    printf -- "/privmsg %s Yo\n" "$nick"
	fi
	;;
    os)
	printf -- "%s: %s\n" "${nick}" "$(uname -orm)"
	;;
    give)
	if [ $[$(userAccess) & 2] == 2 ]; then
	    args=($M_MSG)
	    [[ -z ${args[1]} ]] && printf -- "Usage: !give [user] [flag]\n" && exit
	    [[ -z ${args[2]} ]] && printf -- "Usage: !give [user] [flag]\n" && exit

	    if [ ${args[1],,} == ${NICK,,} ]; then
		printf -- "I will not do that to myself!\n"
	    else
     		printf -- "%s %s %s\n" "${args[2]}" "$CHAN" "${args[1]}" > $FS/$HOST/chanserv/in
	    fi
	else
	    printf -- "%s: You do not have permission to run this command\n" "$nick"
	fi
	;;
    slap)
	args=($M_MSG)
	[ ${args[1],,} == ${NICK,,} ] && printf -- "%s: Slap yourself!\n" "$nick" && exit
	[ ${args[1],,} == "java" ] && printf -- "Beat java with stick untill it cannot steal your computer resources anymore!\n" && exit	    
	printf -- "%s: Are you going to take that?\n" "${args[1]}"
	;;
    time)
	printf -- "%s\n" "$(date +%r)"
	;;
    uptime)
	printf -- "%s\n" "$(uptime)"
	;;
    ipaddr)
	printf -- "%s\n" "$(ip addr | grep inet | grep eth0)"
	;;
    dance)
	printf -- "I'm dancing the night away!\n"
	;;
    google)
        printf -- "You better check yourself, before you  wreck yourself, fool!\n"
        ;;
    echo)
	printf -- "%s\n" "${M_MSG:${#CMD}+1}"
	;;
    send)
	args=($M_MSG)
	[ $[$(userAccess) & 2] != 2 ] && printf -- "%s: You donot have permission to run this comand\n" "$nick" && exit
	[ -z ${args[1]} ] && printf -- "Usage: !send <channel> message\n" && exit
	[[ ${args[1]} != \#* ]] && printf -- "%s: I can only send to channels.\n" "$nick" && exit
	[ ! -f $FS/$HOST/${args[1],,}/out ] && printf -- "%s: I am not in that channel.\n" "$nick" && exit
	printf -- "%s\n" "${M_MSG:${#CMD}+${#args[1]}+2}" > $FS/$HOST/${args[1],,}/in
	;;
    join)
	args=($M_MSG)
	[ $[$(userAccess) & 2] != 2 ] && printf -- "%s: You donot have permission to run this comand\n" "$nick" && exit
	[ -z ${args[1]} ] && printf -- "Usage: !join <channel>\n" && exit
	[[ ${args[1]} != \#* ]] && printf -- "%s: I can only join channels.\n" "$nick" && exit
	[ -f $FS/$HOST/${args[1],,}/out ] && printf -- "%s: I think i am already in that channel.\n" "$nick" && exit
	${SCRIPT_DIR}/join.sh "${args[1],,}" 2> /dev/null
	;;    
    wiki)
	args=($M_MSG)
	if [[ "${args[1]}" == '!stats' ]]; then
	     mysql -u ${WIKI_P%:*} -p${WIKI_P/*:} -e "select cat_pages, cat_title from mediawiki.mw_category"
	fi
	;;
esac
