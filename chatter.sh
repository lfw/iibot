#!/bin/bash

# This script executes when a message is recieved from a user that is not prefixed with a '!'.
# This script is intended to reconize key words and react to them accordingly.

MYPID=$$

CHAN=$1
M_NICK=$2
M_MSG=$3

nick=${M_NICK:1:${#M_NICK} - 2}

[ -z $CHAN ] || [ -z $M_NICK ] || [ -z "$M_MSG" ] && \
    printf "Usage: %s [channel] [nick] [message]\n" "$0" >&2 && \
    exit 1

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ -f $SCRIPT_DIR/config ] && . $SCRIPT_DIR/config

# Respond to any instance of the word help, Help, or HELP.
[[ "${M_MSG,,}" =~ help ]] && printf -- "%s: We all need help, some more than others.\n" "$nick"

[[ "${M_MSG,,}" =~ " java " ]] && \
printf -- "You know what my favorite Java feature is?\nNothing.\n"
