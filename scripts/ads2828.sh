#!/bin/bash

i2c_addr=0x48

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

i=0
while [ $i -lt 256 ]
do
	v=$((0x400 + $(($i * 4))))
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i $v w
	i=$(($i + 1))
done

do_instantiate ads7828 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

attrs=(in0_input in1_input in2_input in3_input
	in4_input in5_input in6_input in7_input)

vals=(7499 7500 17494 17494 27488 27488 37482 37483)

dotest attrs[@] vals[@]
rv=$?

do_remove ${i2c_addr}

i=0
while [ $i -lt 256 ]
do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i $i b
	i=$(($i + 1))
done

do_instantiate ads7830 ${i2c_addr}

cd ${basedir}

attrs=(in0_input in1_input in2_input in3_input
	in4_input in5_input in6_input in7_input)

vals=(1367 1992 1523 2149 1680 2305 1836 2461)

dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

do_remove ${i2c_addr}

exit ${rv}
