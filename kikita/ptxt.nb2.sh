#!/bin/bash
 
while getopts n:t: options
do
    case "${options}" in
        n)
            nb=${OPTARG}
            ;;
        t)
            to=${OPTARG}
            ;;
        *)
            echo "Invalid args"
            echo "Usage: $0 -n <n> -t <t> -- <text>"
            ;;
    esac
done
shift $(expr $OPTIND - 1)
text=$1
i=1
while [ $i -lt "${nb}" ] 
do
    echo ${text}
    sleep ${to}
    i=$(expr $i + 1)
done
echo ${text}