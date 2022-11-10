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
            level="$OPTARG"
        ;;
        *)
            echo "Invalid args" >&2
            echo "Usage: $0 -d <date> -t <time> -l <log_level> <file_name>" >&2
            exit 1
        ;;
    esac
done
shift $((OPTIND - 1))
filename=$1

if [[ ! -e $filename || ! -r $filename ]]
then
    echo "Can't access file: $1" >&2
    exit 1
fi

levels=("INFO" "WARN" "ERROR")

if [[ -n $level ]]
then
    if [[ ! " ${levels[@]} " =~ " ${level} " ]]; then
        echo "Log level is invalid: $level" >&2
        exit 1
    fi
fi

function get_sign {
    local option=$1
    local c=${option:0:1}
    if [[ "$c" != "+" ]] && [[ "$c" != "-" ]]; then
        c=""
    fi
    echo $c
}

date=""
time=""

c_d=$(get_sign $dateOpt)
c_t=$(get_sign $timeOpt)

if [ "$c_d" != "" ]; then
    date=${dateOpt:1:${#dateOpt}}
else
    date=$dateOpt
fi

if [ "$c_t" != "" ]; then
    time=${timeOpt:1:${#timeOpt}}
else
    time=$timeOpt
fi

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
    if [ -z "$date" ]; then
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

function extract_time {
    echo "$1"|sed -r "s/[^0-9]//g"
}

function check_time {
    local value=0
    if [ -z "$time" ]; then
        value=1
        elif [[ "$c_t" = "+" ]]; then
        value=$(find_later "$1" "$2")
        elif [[ "$c_t" = "-" ]]; then
        value=$(find_earlier "$1" "$timeToCom2pare")
        elif [ -z "$c_t" ]; then
        value=$(find_same "$1" "$2")
    fi
    echo $value
}

function check_level {
    local logLevel=$1
    local levelToCompare=$2
    local value=0
    if [ -z "$level" ]; then
        value=1
        elif [ "$logLevel" = "$levelToCompare" ]; then
        value=1
    else
        value=0
    fi
    echo $value
}

# echo "dateOpt=$dateOpt"
# echo "timeOpt=$timeOpt"
# echo "c_d=$c_d"
# echo "c_t=$c_t"
# echo "date=$date"
# echo "time=$time"
# echo " "

while read line; do
    currDate=`echo ${line} | awk '{print $1}'`
    currTime=`echo ${line} | awk '{print $2}'`
    currLevel=`echo ${line} | awk '{print $4}'`
    
    check_d=$(check_date "$currDate" "$date")
    check_t=$(check_time "$currTime" "$time")
    check_l=$(check_level "$currLevel" "$level")
    # echo "check_d=$check_d"
    # echo "check_t=$check_t"
    # echo "check_l=$check_l"
    check=$(( check_t * check_d * check_l ))
    # echo "check=$check"
    if (( check == 1 )); then
        echo "$line"
    fi
done < "$filename"