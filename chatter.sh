#!/bin/bash

# This script executes when a message is recieved from a user that is not prefixed with a '!'.
# This script is intended to reconize key words and react to them accordingly.

MYPID=$$

# Make it all lower case to avoid confusion.
CHAN="${1,,}"
M_NICK="${2,,}"
M_MSG="${3,,}"

nick=${M_NICK:1:${#M_NICK} - 2}

[ -z "$CHAN" ] || [ -z "$M_NICK" ] || [ -z "$M_MSG" ] && \
    printf "Usage: %s [channel] [nick] [message]\n" "$0" >&2 && \
    exit 1

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ -f $SCRIPT_DIR/config ] && . $SCRIPT_DIR/config

# Respond to any instance of the word help, Help, or HELP.
[[ "${M_MSG}" =~ " help" ]] || \
    [[ "${M_MSG}" =~ "help " ]] || \
    [[ "${M_MSG}" =~ " help " ]] && \
    printf -- "%s: We all need help, some more than others.\n" "$nick" && \
    exit

# Respond to java
[[ "${M_MSG}" =~ " java " ]] || \
    [[ "${M_MSG}" =~ " java" ]] || \
    [[ "${M_MSG}" =~ "java " ]] && \
    printf -- "You know what my favorite Java feature is?\nRemote code execution.\n" && \
    exit


# Respond to dream
[[ "${M_MSG}" =~ " dream " ]] || \
    [[ "${M_MSG}" =~ " dream" ]] || \
    [[ "${M_MSG}" =~ "dream " ]] && \
    printf -- "Some people live to dream, and some people live to crush those dreams!\n" && \
    exit

# Respond to right
[[ "${M_MSG}" =~ " right " ]] || \
    [[ "${M_MSG}" =~ " right" ]] || \
    [[ "${M_MSG}" =~ "right " ]] && \
    printf -- "Yep, that's right. You know it!\n" && \
    exit

# Respond to marco
[[ "${M_MSG}" =~ "marco" ]] && \
    printf -- "Have you seen Polo? I've been searching for him all day.\n" && \
    exit

# Respond to polo
[[ "${M_MSG}" =~ "polo" ]] && \
    printf -- "Have you seen Marco?! He owes me money!\n" && \
    exit

# Respond to waldo
[[ "${M_MSG}" =~ "where is waldo" ]] || \
    [[ "${M_MSG}" =~ "where's waldo" ]] || \
    [[ "${M_MSG}" =~ "wheres waldo" ]] && \
    printf -- "Where is Waldo? Why are you asking me?\n" && \
    exit

[[ "${M_MSG}" =~ "shutup ${NICK,,}" ]] || \
    [[ "${M_MSG}" =~ "shut up ${NICK,,}" ]] || \
    [[ "${M_MSG}" =~ "shut-up ${NICK,,}" ]] && \
    printf -- "Okay Okay, Calm down.\n" && \
    exit

