#!/usr/bin/env bash

_ACTION=${1,,}
_USER=${2,,}
_CHANNEL=${3,,}
_ROLE=${4,,}
_RET=1

[[ "$_ACTION" == help ]] && \
    printf "Manage user roles for irc bot control and other access levels.\n" && \
    printf "Usage: %s [help | check | add | remove] <user> <channel> <role>\n\n" "$0" && \
    printf "Available Actions:\n" && \
    printf "check  - Check if a user is a member of a role for in a specific channel.\n" && \
    printf "add    - Add a user to a role in a specific channel.\n" && \
    printf "remove - Remove a user from a role in a specific channel.\n" && \
    exit 0

[[ -z "$_ACTION" ]] || [[ -z "$_USER" ]] || [[ -z "$_CHANNEL" ]] || [[ -z "$_ROLE" ]] && \
    printf -- "Usage: %s [help | check | add | remove] <user> <channel> <role>\n" "$0" 1>&2 && \
    exit 1

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ ! -f $SCRIPT_DIR/auth ] && printf -- "ERROR: auth file not found. Please fix this and try again.\n" 1>&2 && exit

lockfile=${SCRIPT_DIR}/auth.lock
trap 'rm -f "$lockfile"; exit $_RET' INT TERM EXIT
exec 200> $lockfile

# Check if a user is in a role as identified in ./auth
# return 0 on success.
function isInRole {
    local user=${1,,}
    local chan=${2,,}
    local role=${3,,}
    local channel_name=
    local ret=1

    flock -x 200 
    while read line; do
	local line=${line,,}
	[[ "$line" =~ ^## ]] || [[ -z "$line" ]] && continue;
	[[ "$line" =~ ^% ]] && channel_name= && continue;
	[[ "$line" =~ ^# ]] && channel_name=${line,,} && continue;
	
	if [[ "${line%:*}" == ${role} ]] && [[ "$channel_name" == $chan ]] && [[ ${line/*:} =~ ${user} ]]; then
	    local users_in_role=(${line/*:})
	    for user_in_role in "${users_in_role[@]}"; do
		[[ $user_in_role == $user ]] && \
		    ret=0 && continue;
	    done
	fi
    done < ${SCRIPT_DIR}/auth
    flock -u 200

    return $ret;
}

function addToRole {
    local user=${1,,}
    local chan=${2,,}
    local role=${3,,}
    local channel_name=
    local ret=1
    local lineNumber=0

    flock -x 200
    while read line; do
	local line=${line,,}
	local lineNumber=$[$lineNumber + 1]

	[[ "$line" =~ ^## ]] || [[ -z "$line" ]] && continue;
	[[ "$line" =~ ^% ]] && channel_name= && continue;
	[[ "$line" =~ ^# ]] && channel_name=${line,,} && continue;

	if [[ "${line%:*}" == $role ]] && [[ "$channel_name" == $chan ]] && [[ ! ${line/*:} =~ $user ]]; then
	    ret=0
	    sed -i "${lineNumber}s/.*/${line} ${user}/" ${SCRIPT_DIR}/auth
	    break;
	fi
	
    done < ${SCRIPT_DIR}/auth
    flock -u 200

    [[ ! $ret -eq 0 ]] && \
	printf "ERROR: Failed to add %s to %s->%s role.\n" "$user" "$chan" "$role" 1>&2 && \
	printf "Make sure the both the Channel and the Group exist in the auth file.\n" 1>&2

    return $ret
}

function remFromRole {    
    local user=${1,,}
    local chan=${2,,}
    local role=${3,,}
    local channel_name=
    local lineNumber=0

    flock -x 200
    while read line; do
	local line=${line,,}
	local lineNumber=$[$lineNumber + 1]

	[[ "$line" =~ ^## ]] || [[ -z "$line" ]] && continue;
	[[ "$line" =~ ^% ]] && channel_name= && continue;
	[[ "$line" =~ ^# ]] && channel_name=${line,,} && continue;

	if [[ "${line%:*}" == $role ]] && [[ "$channel_name" == $chan ]] && [[ ${line/*:} =~ $user ]]; then
	    local users_in_role=(${line/*:})
	    for user_in_role in "${users_in_role[@]}"; do
		[[ $user_in_role != $user ]] && \
		    local new_users_in_role="$new_users_in_role $user_in_role"
	    done
	    sed -i "${lineNumber}s/.*/${role}: ${new_users_in_role}/" ${SCRIPT_DIR}/auth
	    break;
	fi
	
    done < ${SCRIPT_DIR}/auth
    flock -u 200

    return 0
}

function printRecord {
    local chan=${1,,}
    local channel_name=

    flock -x 200
    while read line; do	

	[[ "$line" =~ ^## ]] || [[ -z "$line" ]] && continue;
	[[ "$line" =~ ^% ]] && channel_name= && continue;
	[[ "$line" =~ ^# ]] && channel_name=${line,,} && continue;

	if [[ $channel_name == $chan ]]; then
	    printf "%s\n" "${line}"
	fi
	
    done < ${SCRIPT_DIR}/auth
    flock -u 200
    return 0
}

case "$1" in 
    check)
	isInRole  $_USER $_CHANNEL $_ROLE && _RET=$?
	[ $_RET == 0 ] && printf "True\n" || printf "False\n"
	;;
    add)
	addToRole $_USER $_CHANNEL $_ROLE && _RET=$?
	;;
    remove)
	remFromRole $_USER $_CHANNEL $_ROLE && _RET=$? ;;
    print)
	printRecord  $_CHANNEL && _RET=$?
	;;
esac
exit $_RET
