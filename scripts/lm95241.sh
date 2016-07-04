#!/bin/bash

i2c_addr=0x19

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs_lm95241=(00 00 00 00 00 00 05 01 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 a4
)

attrs_lm95241=(name temp1_input
	temp2_input temp2_max temp2_min temp2_type temp2_fault
	temp3_input temp3_max temp3_min temp3_type temp3_fault
	update_interval)

vals_lm95241=(lm95241 0 0 255875 0 2 0 0 255875 0 2 0 1000)

vals_lm95231=(lm95231 0 0 255875 0 2 0 0 255875 0 2 0 1000)

permissions_lm95241=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
)

doinit()
{
    local regs=("${!1}")
    local i=0

    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
    done
}

runtest()
{
    local chip=$1
    local attrs=("${!2}")
    local vals=("${!3}")
    local permissions=("${!4}")
    local rv

    echo "Testing ${chip}"

    do_instantiate ${chip} ${i2c_addr}

    getbasedir ${i2c_addr}

    cd ${basedir}

# ls -l 
# grep . *

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    check_range -b ${basedir} -d 129000 -r -q temp2_min
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 129000 -r -q temp2_max
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -l 1 -u 2 -r -q temp2_type
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 129000 -r -q temp3_min
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 129000 -r -q temp3_max
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -l 1 -u 2 -r -q temp3_type
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -l 0 -s 100 -d 800 -r -q update_interval
    rv=$(($? + ${rv}))

    do_remove ${i2c_addr}

    return ${rv}
}

doinit regs_lm95241[@]

runtest lm95241 attrs_lm95241[@] vals_lm95241[@] permissions_lm95241[@]
rv=$?

i2cset -f -y ${i2c_adapter} ${i2c_addr} 0xff 0xa1 b

modprobe -r lm95241

runtest lm95231 attrs_lm95241[@] vals_lm95231[@] permissions_lm95241[@]
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
