#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

regs_emc1403=(
	00 00 00 00 06 55 00 55 00 00 06 55 00 55 00 00
	00 00 00 00 00 55 00 00 00 55 00 00 00 00 00 00
	55 0a 70 00 00 08 08 12 12 00 00 00 55 00 00 00
	55 12 00 00 00 00 00 00 00 00 00 00 00 00 00 00
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
	00 00 00 00 00 00 00 00 00 00 00 00 00 21 5d 01
)

attrs_emc1403=(name power_state
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_max_hyst temp1_min temp1_min_alarm temp1_min_hyst
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_max_hyst temp2_min temp2_min_alarm
	temp2_min_hyst
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault temp3_input
	temp3_max temp3_max_alarm temp3_max_hyst temp3_min temp3_min_alarm
	temp3_min_hyst
)

vals_emc1403=(emc1403 0
	85000 0 75000 0 85000 0 75000 0 0 10000 85000
	0 75000 0 0 85000 0 75000 0 0 10000 0 0 -10000
	0 0 85000 0 75000 0 0 10000
)

permissions_emc1403=(
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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

    echo Testing ${chip} ...

    load_i2c_stub ${i2c_addr}

    modprobe -r emc1403

    i=0
    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$((i + 1))
    done

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    # ls -l
    # grep . *

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    check_range -b ${basedir} -s 200 -d 500 -r -q temp1_crit
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 200 -d 500 -r -q temp1_crit_hyst
    rv=$(($? + ${rv}))

    for i in $(seq 1 3)
    do
	if [[ $i -ne 1 ]]; then
	    check_range -b ${basedir} -s 200 -d 500 -r -q temp${i}_crit
	    rv=$(($? + ${rv}))
	fi
	check_range -b ${basedir} -s 1000 -d 0 -r -q temp${i}_min
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -s 1000 -d 0 -r -q temp${i}_max
	rv=$(($? + ${rv}))
    done

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest emc1403 regs_emc1403[@] attrs_emc1403[@] vals_emc1403[@] permissions_emc1403[@]
rv=$(($? + ${rv}))

modprobe -r emc1403

exit ${rv}
