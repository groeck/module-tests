#!/bin/bash

i2c_addr=0x50

dir=$(dirname $0)
. ${dir}/common.sh

regs_spd5118=(
	51 18 0a 86 32 03 32 00 00 00 00 00 ff 7f 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 70 03 00 00
	50 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 5c 02 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	30 10 12 02 04 00 20 62 00 00 00 00 60 00 00 00
	00 00 00 00 a0 01 f2 03 72 0d 00 00 00 00 1a 41
	1a 41 1a 41 00 7d 1a be 30 75 27 01 a0 00 82 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 88 13 08 88 13 08 20 4e 20 10
	27 10 15 34 20 10 27 10 c4 09 04 4c 1d 0c 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_spd5118=(name
	temp1_crit
	temp1_crit_alarm
	temp1_enable
	temp1_input
	temp1_lcrit
	temp1_lcrit_alarm
	temp1_max
	temp1_max_alarm
	temp1_min
	temp1_min_alarm
)

vals_spd5118=(spd5118
	85000 0 1 37750 0 0 55000 0 0 0
)

permissions_spd5118=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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

    modprobe -r spd5118

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

    check_range -b ${basedir} -s 250 -d 0 -r -q temp1_lcrit
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 250 -d 0 -r -q temp1_min
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 250 -d 0 -r -q temp1_max
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 250 -d 0 -r -q temp1_crit
    rv=$(($? + ${rv}))

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest spd5118 regs_spd5118[@] attrs_spd5118[@] vals_spd5118[@] permissions_spd5118[@]
rv=$(($? + ${rv}))

exit ${rv}
