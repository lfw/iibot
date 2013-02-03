#!/usr/bin/env bash

# This script executes when a message from chanserv, user -!-, is recieved.
# The loose intension of this script is to set user status to execute some commands.

MYPID=$$

CHAN=${1,,}
M_MSG="${2,,}"

[ -z "$CHAN" ] || [ -z "$M_MSG" ] && \
    printf "Usage: %s [channel] [message]\n" "$0" >&2 && \
    exit 1

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ -f $SCRIPT_DIR/config ] && . $SCRIPT_DIR/config

# Greet users as they join.
[[ "$M_MSG" =~ joined ]] && [[ "${M_MSG,,}" =~ ${CHAN,,} ]] && \
    printf -- "Hello %s!\n" "${M_MSG%%(*}" && \
    printf -- "voice %s %s\n" "$CHAN" "${M_MSG%%(*}" > $FS/$HOST/chanserv/in
