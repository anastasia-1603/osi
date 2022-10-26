#!/bin/bash
 
size=$#
array=("$@")
for (( step = 0; step < size - 1; ++step ))
do
    for (( i = 0; i < size - step - 1; ++i ))
    do
        if [ "${array[i]}" \> "${array[i + 1]}" ]
            then
            temp=${array[i]}
            array[i]=${array[i + 1]}
            array[i + 1]=${temp}
        fi
    done
done
 
echo "${array[*]}"
