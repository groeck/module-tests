#!/bin/bash

i2c_addr=0x19

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs_lm95245=(
	14 f4 00 00 02 00 00 55 00 00 02 00 00 55 00 00
	b0 00 00 00 00 00 00 00 00 6e 00 00 00 00 00 00
	55 0a 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	58 98 9f 9a 9a 00 00 00 00 00 00 00 00 00 00 1f
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	9a 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 b3
)

attrs_lm95245=(name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp2_max temp2_max_alarm temp2_max_hyst temp2_offset
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_type
	update_interval
)

vals_lm95245=(lm95245
	85000 0 75000 20875
	85000 0 75000 0
	110000 0 100000 0 -12000 1 1000)

permissions_lm95245=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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

    check_range -b ${basedir} -d 1000 -r -q temp1_crit
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -r -q temp1_crit_hyst
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 1000 -r -q temp2_max
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 1000 -r -q temp2_offset
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 1000 -r -q temp2_crit
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -l 1 -u 2 -d 0 -r -q temp2_type
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -l 0 -u 3000 -d 1500 -r -q update_interval
    rv=$(($? + ${rv}))

    do_remove ${i2c_addr}

    return ${rv}
}

doinit regs_lm95245[@]

runtest lm95245 attrs_lm95245[@] vals_lm95245[@] permissions_lm95245[@]
rv=$?

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
