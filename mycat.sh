#!/bin/bash
func(){
    echo $(( $1 + $2 ))
}

func 1 2

sum=$(func 1 2)
echo "SUM $sum "

err_report() {
    echo "error"
}

trap err_report ERR

[ ! -e $1 ]