#!/bin/bash

tmp=$(mktemp)
trap 'rm -f "${tmp}"' EXIT
if ! test "$1"
then
	echo $0 URL
	exit
fi
site="$1"

urlencode() {
    # urlencode <string>

    local LANG=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;; 
        esac
    done
}

e=$(urlencode $site)

test -d $e || { echo New site $site; mkdir $e; }

code=$(curl -s -o $tmp -w "%{http_code}" "$site")
#cat $tmp
hash=$(cat $tmp | sha1sum | awk '{print $1}')

last=$(ls -t $e | head -1)

fn=$e/$(date -Iminutes)_$code

if ! test -f "$e/$last"
then
	echo $hash > $fn
else
	if test "$(cat $e/$last)" != "$hash"
	then
		echo Hash differ \'"$hash"\' != \'"$(cat $e/$last)"\'
		echo $hash > $fn
	else
		echo Hash are the same
	fi
fi
