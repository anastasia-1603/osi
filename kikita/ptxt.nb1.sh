#!/bin/bash
 
while [ -n "$1" ] 
do
    case "$1" in
        "-n")
            nb=$2
            shift 2
            ;;
        "-t")
            to=$2
            shift 2
            ;;
        "--")
            text=$2
            shift 2
            ;;
        *)
            echo "Invalid args"
            echo "Usage: $0 -n <n> -t <t> -- <text>"
            ;;
    esac
done
i=1
while [ $i -lt "${nb}" ] 
do
    echo ${text}
    sleep ${to}
    i=$(expr $i + 1)
done
echo ${text}
