#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

regs_max6639=(
	ff 1a 00 03 30 e1 a0 ff 55 55 6e 6e 55 55 ff ff
	82 00 00 41 82 00 00 41 ff ff ff ff ff ff ff ff
	ff ff ff ff 40 40 78 78 40 40 ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff 58 4d 00
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
)

attrs_max6639=(fan1_fault fan1_input fan1_pulses fan2_fault fan2_input fan2_pulses
	name
	pwm1 pwm1_freq pwm2 pwm2_freq
	temp1_crit temp1_crit_alarm temp1_emergency temp1_emergency_alarm
	temp1_fault temp1_input temp1_max temp1_max_alarm
	temp2_crit temp2_crit_alarm temp2_emergency temp2_emergency_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm
)

vals_max6639=(0 0 2 0 0 2
	max6639
	255 25000 255 25000
	90000 0 100000 0 1 255875 80000 0
	90000 0 100000 0 0 26625 80000 0
)

permissions_max6639=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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

    modprobe -r max6639

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

    for i in $(seq 1 2)
    do
	check_range -b ${basedir} -l 1 -u 4 -q fan${i}_pulses
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -l 0 -u 255 -d 2 -r -q pwm${i}
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -d 6200 -r -q pwm${i}_freq
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -s 500 -d 500 -r -q temp${i}_crit
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -s 500 -d 500 -r -q temp${i}_emergency
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -s 500 -d 500 -r -q temp${i}_max
	rv=$(($? + ${rv}))
    done

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest max6639 regs_max6639[@] attrs_max6639[@] vals_max6639[@] permissions_max6639[@]
rv=$(($? + ${rv}))

modprobe -r max6639

exit ${rv}
