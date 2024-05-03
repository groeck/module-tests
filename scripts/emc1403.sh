#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

regs_emc1402=(
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
	00 00 00 00 00 00 00 00 00 00 00 00 00 20 5d 01
)

regs_emc1403=(
	00 00 00 00 06 55 00 55 00 00 06 55 00 55 00 00
	00 00 00 00 00 55 00 00 00 55 55 00 00 00 00 00
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

regs_emc1404=(
	00 00 00 00 06 55 00 55 00 00 06 55 00 55 00 00
	00 00 00 00 00 55 00 00 00 55 55 00 00 00 00 00
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
	00 00 00 00 00 00 00 00 00 00 00 00 00 25 5d 01
)

attrs_emc1402=(name power_state
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_max_hyst temp1_min temp1_min_alarm temp1_min_hyst
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_max_hyst temp2_min temp2_min_alarm
	temp2_min_hyst
	update_interval
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
	update_interval
)

attrs_emc1404=(name power_state
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_max_hyst temp1_min temp1_min_alarm temp1_min_hyst
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_max_hyst temp2_min temp2_min_alarm
	temp2_min_hyst
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault temp3_input
	temp3_max temp3_max_alarm temp3_max_hyst temp3_min temp3_min_alarm
	temp3_min_hyst
	temp4_crit temp4_crit_alarm temp4_crit_hyst temp4_fault temp4_input
	temp4_max temp4_max_alarm temp4_max_hyst temp4_min temp4_min_alarm
	temp4_min_hyst
	update_interval
)

vals_emc1402=(emc1402 0
	85000 0 75000 0 85000 0 75000 0 0 10000
	85000 0 75000 0 0 85000 0 75000 0 0 10000
	250
)

vals_emc1403=(emc1403 0
	85000 0 75000 0 85000 0 75000 0 0 10000
	85000 0 75000 0 0 85000 0 75000 0 0 10000
	85000 0 75000 0 0 85000 0 75000 0 0 10000
	250
)

vals_emc1404=(emc1404 0
	85000 0 75000 0 85000 0 75000 0 0 10000
	85000 0 75000 0 0 85000 0 75000 0 0 10000
	85000 0 75000 0 0 85000 0 75000 0 0 10000
	85000 0 75000 0 0 85000 0 75000 0 0 10000
	250
)

permissions_emc1402=(
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

permissions_emc1404=(
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
    local channels=$2
    local regs=("${!3}")
    local attrs=("${!4}")
    local vals=("${!5}")
    local permissions=("${!6}")
    local rv
    local i
    local stepsize

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

    check_range -b ${basedir} -s 200 -d 500 -r temp1_crit
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 200 -d 500 -r temp1_crit_hyst
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 200 -d 8000 -r update_interval
    rv=$(($? + ${rv}))

    stepsize=1000
    for i in $(seq 1 ${channels})
    do
	if [[ $i -ne 1 ]]; then
	    check_range -b ${basedir} -s 200 -d 500 -r -q temp${i}_crit
	    rv=$(($? + ${rv}))
	fi
	check_range -b ${basedir} -s ${stepsize} -d 0 -r -q temp${i}_min
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -s ${stepsize} -d 0 -r -q temp${i}_max
	rv=$(($? + ${rv}))
	stepsize=125
    done

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest emc1402 2 regs_emc1402[@] attrs_emc1402[@] vals_emc1402[@] permissions_emc1402[@]
rv=$(($? + ${rv}))
runtest emc1403 3 regs_emc1403[@] attrs_emc1403[@] vals_emc1403[@] permissions_emc1403[@]
rv=$(($? + ${rv}))
runtest emc1404 4 regs_emc1404[@] attrs_emc1404[@] vals_emc1404[@] permissions_emc1404[@]
rv=$(($? + ${rv}))

modprobe -r emc1403

exit ${rv}
