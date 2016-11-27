#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

regs_tmp108=(
	701c 1026 004b 0050
)

attrs_tmp108=(name temp1_input temp1_max temp1_max_alarm temp1_max_hyst temp1_min
	temp1_min_alarm temp1_min_hyst update_interval)

vals_tmp108=(tmp108 28437 80000 0 79000 75000 0 74000 1000)

permissions_tmp108=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

runtest()
{
    local chip=$1
    local regs=("${!2}")
    local attrs=("${!3}")
    local vals=("${!4}")
    local rv
    local i

    load_i2c_stub ${i2c_addr}

    install_regs ${i2c_adapter} ${i2c_addr} regs[@] w

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    sleep 0.1

    dotest attrs[@] vals[@]
    rv=$?

    check_range -b ${basedir} -s 100 -d 75 -r -q temp1_min
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 100 -d 75 -r -q temp1_max
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 500 -d 2000 -r -q temp1_min_hyst
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 500 -d 6000 -r -q update_interval
    rv=$(($? + ${rv}))

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

runtest tmp108 regs_tmp108[@] attrs_tmp108[@] vals_tmp108[@] permissions_tmp108[@]
rv=$?

modprobe -r tmp108

exit ${rv}
