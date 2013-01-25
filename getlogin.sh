#!/bin/bash

_NICK="${1,,}"

[ -z "$_NICK" ] && printf "Usage: %s <nick>\n" "$0" && exit 1

# Load resources
SCRIPT_DIR=$(readlink -f $(dirname $0))
[ -f $SCRIPT_DIR/config ] && . $SCRIPT_DIR/config

# Make sure we are running and account for new process
[ ! -f $PIDFILE ] && printf "ERROR: iibot does not apears to be running.\n" && exit 1

printf -- "/whois %s\n" "$_NICK" > $FS/$HOST/in
STAT_DT="$(stat -c %y $FS/$HOST/out | cut -d' ' -f2)"

while [[ "$STAT_DT" == "$(stat -c %y $FS/$HOST/out | cut -d' ' -f2)" ]]; do
    sleep 3
done

tail -n 10 $FS/$HOST/out | grep -i "is logged in as" |
while read -r date time nick user garbage; do
    [[ "$_NICK" == "${nick,,}" ]] && echo "${user,,}"
done | tail -n1
