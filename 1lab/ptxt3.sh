#!/bin/bash
arr=("$@")

size=${#arr[*]}
for (( i=0; i+1\<$size; i++ ))
do
    for (( j=0; j+1\<$size-i; j++ ))
    do
        if [ ${arr[$j]} \> ${arr[$(expr $j + 1)]} ] 
        then
            temp=${arr[$j]}
            arr[$j]=${arr[$(expr $j + 1)]}
            arr[$(expr $j + 1)]=$temp
        fi
    done
done
echo ${arr[*]}