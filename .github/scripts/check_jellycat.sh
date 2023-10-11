#!/bin/bash

name=$1
item=$2
url=https://www.jellycat.com/us/$name/

report() {
    {
        echo "HAS_EMAIL=1"
        echo "EMAIL_TITLE=$1"
        echo "EMAIL_BODY=$2"
    } >> "$GITHUB_OUTPUT"
}

report_none() {
    {
        echo "HAS_EMAIL=0"
    } >> "$GITHUB_OUTPUT"
}

try_check() {
    local url=$1
    local item=$2
    local useragent='User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:109.0) Gecko/20100101 Firefox/116.0'

    local stock_levels=($(curl "$url" -H "$useragent" 2>/dev/null | sed -ne 's/.*stock_level['"'"'": ]*\([0-9]*\)[^0-9].*/\1/p'))

    if [[ ${#stock_levels[@]} = 0 ]]; then
        echo "Failed to check stock level" >&2
        return 1
    fi

    if [[ -n "$item" ]]; then
        stock_levels=(${stock_levels[$item]})
    fi

    for stock_level in "${stock_levels[@]}"; do
        if [[ $stock_level != 0 ]]; then
            echo "yes"
            return 0
        fi
    done

    echo "no"
    return 0
}

check_and_report() {
    mkdir -p ~/jellycat/
    local logfile=~/jellycat/"${name}:${item}"
    if [[ -f ~/jellycat/"${name}:${item}" ]]; then
        if [[ "$(cat ~/jellycat/"${name}:${item}")" = yes ]]; then
            return
        fi
    fi
    for ((i = 0; i < 10; i++)); do
        if res=$(try_check "$url" "$item"); then
            echo "$res" > ~/jellycat/"${name}:${item}"
            if [[ "$res" = yes ]]; then
                echo "${name}:${item} is now available!"
                report "Jellycat check result" "${name}:${item} is now available."
            else
                echo "${name}:${item} is still not available."
                report "Jellycat check result" "${name}:${item} is still not available."
                # report_none
            fi
            return
        fi
        sleep 100
    done
    echo "Jellycat check error"
    report "Jellycat check error" "${name}:${item}"
}

check_and_report
