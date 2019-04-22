#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

regs_ltc2990=(
	00 00 00 00 01 90 07 d0 2c cd 7d 80 7c 29 20 00
)

attrs_ltc2990=(in0_input in1_input in2_input in3_input in4_input
	temp1_input temp2_input temp3_input curr1_input curr2_input
	name
)

vals_2990=(5000 610 3500 -195 -299 25000 125000 -40000 38840 -12428 ltc2990
)

permissions_ltc2990=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
)

runtest()
{
    local chip=$1
    local regs=("${!2}")
    local attrs=("${!3}")
    local vals=("${!4}")
    local permissions=("${!5}")
    local rv
    local i

    load_i2c_stub ${i2c_addr}

    i=0
    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
    done

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    modprobe -r i2c-stub 2>/dev/null
    modprobe -r ltc2990

    return ${rv}
}

runtest ltc2990 regs_ltc2990[@] attrs_ltc2990[@] vals_ltc2990[@] permissions_ltc2990[@]
rv=$?

modprobe -r ltc2990

exit ${rv}
