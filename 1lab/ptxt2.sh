#!/bin/bash
while getopts n:t:s a
do
    case "$a" in
        n)
            num="$OPTARG"
        ;;
        t)
            time="$OPTARG"
        ;;
        s)
            break
        ;;
        \?)
            echo "usage $0 -n \<number of text outputs\> -t \<output timeout\> -s \<text\>"
            exit 1
        ;;
    esac
done
shift $(expr $OPTIND - 1)

for (( i = 0; i < $num; i++ ))
do
    echo "$*"
    sleep $time
done