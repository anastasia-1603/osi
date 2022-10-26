#!/bin/bash
while [ -n "$1" ]
do
    case "$1" in
        -n)
            num="$2"
            shift 2
        ;;
        -t)
            time=$2
            shift 2
        ;;
        --)
            shift
            break
        ;;
        *)
            echo "usage $0 -n \<number of text outputs\> -t \<output timeout\> -- \<text\>"
            exit 1
        ;;
    esac
done
for (( i = 0; i < $num; i++ ))
do
    echo "$*"
    sleep $time
done