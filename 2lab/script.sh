#!/bin/bash

if [[ -z $* ]]
then
    echo "No options found!" >&2
    exit 1
fi

while getopts :d:t:l: option
do
    case "${option}" in
        d)
            dateOpt="$OPTARG"
        ;;
        t)
            timeOpt="$OPTARG"
        ;;
        l)
            levelOpt="$OPTARG"
        ;;
        *)
            echo "Invalid args" >&2
            echo "Usage: $0 -d <date>.<date>. ... -t <time>. ... -l <log_level>. ... <file_name>" >&2
            exit 1
        ;;
    esac
done
shift $((OPTIND - 1))
filename=$1

IFS='.'
read -ra dateArr <<< "$dateOpt"
read -ra timeArr <<< "$timeOpt"
read -ra levelArr <<< "$levelOpt"

if [[ ! -e $filename || ! -r $filename ]]
then
    echo "Can't access file: $1" >&2
    exit 1
fi

levels=("INFO" "WARN" "ERROR")

if [ -n "$levelOpt" ]; then
    for level in "${levelArr[@]}"; do
        if [[ ! " ${levels[@]} " =~ " ${level} " ]]; then
            echo "Log level is invalid: $level" >&2
            exit 1
        fi
    done
fi

function get_sign {
    local option=$1
    local c=${option:0:1}
    if [[ "$c" != "+" ]] && [[ "$c" != "-" ]]; then
        c=""
    fi
    echo $c
}

function find_later {
    local logDate=$1
    local dateToCompare=$2
    local value=0
    if [ "$logDate" \> "$dateToCompare" ]; then
        value=1
    else
        value=0
    fi
    echo $value
}

function find_earlier {
    local logDate=$1
    local dateToCompare=$2
    local value=0
    if [ "$logDate" \< "$dateToCompare" ]; then
        value=1
    else
        value=0
    fi
    echo $value
}

function find_same {
    local logDate=$1
    local dateToCompare=$2
    local value=0
    if [ "$logDate" = "$dateToCompare" ]; then
        value=1
    else
        value=0
    fi
    echo $value
}

function check_date {
    local value=0
    if [ -z "$2" ]; then
        value=1
        elif [[ "$c_d" = "+" ]]; then
        value=$(find_later $1 $2)
        elif [[ "$c_d" = "-" ]]; then
        value=$(find_earlier $1 $2)
        elif [ -z "$c_d"]; then
        value=$(find_same $1 $2)
    fi
    echo $value
}

function check_time {
    local value=0
    if [ -z "$2" ]; then
        value=1
        elif [[ "$c_t" = "+" ]]; then
        value=$(find_later "$1" "$2")
        elif [[ "$c_t" = "-" ]]; then
        value=$(find_earlier "$1" "$2")
        elif [ -z "$c_t" ]; then
        value=$(find_same "$1" "$2")
    fi
    echo $value
}

function check_level {
    local logLevel=$1
    local levelToCompare=$2
    local value=0
    if [ -z "$levelToCompare" ]; then
        value=1
        elif [ "$logLevel" = "$levelToCompare" ]; then
        value=1
    else
        value=0
    fi
    echo $value
}

while read line; do
    currDate=`echo ${line} | awk '{print $1}'`
    currTime=`echo ${line} | awk '{print $2}'`
    currLevel=`echo ${line} | awk '{print $4}'`

    check_d=0
    if [ -z "$dateOpt" ]; then
        check_d=1
    else
        for d in "${dateArr[@]}"; do
            date=""
            c_d=$(get_sign "$d")
            if [ "$c_d" != "" ]; then
                date=${d:1:${#d}}
            else
                date=$d
            fi
            curr_check_d=$(check_date "$currDate" "$date")
            check_d=$(( $check_d + $curr_check_d ))
        done
    fi
    if (( check_d > 0 )); then
        check_d=1
    else
        check_d=0
    fi

    check_t=0
    if [ -z "$timeOpt" ]; then
        check_t=1
    else
        for t in "${timeArr[@]}"; do
            time=""
            c_t=$(get_sign "$t")
            if [ "$c_t" != "" ]; then
                time=${t:1:${#t}}
            else
                time=$t
            fi
            curr_check_t=$(check_time "$currTime" "$time")
            check_t=$(( $check_t + $curr_check_t ))
        done
    fi
    if (( check_t > 0 )); then
        check_t=1
    else
        check_t=0
    fi

    check_l=0
    if [ -z "$levelOpt" ]; then
        check_l=1
    else
        for l in "${levelArr[@]}"; do
            curr_check_l=$(check_level "$currLevel" "$l")
            check_l=$(( $check_l + $curr_check_l ))
        done
    fi
    if (( check_l > 0 )); then
        check_l=1
    else
        check_l=0
    fi

    check=$(( check_t * check_d * check_l ))
    if (( check == 1 )); then
        echo "$line"
    fi
done < "$filename"