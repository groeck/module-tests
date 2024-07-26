#!/bin/bash

i2c_addr=0x48
driver=lm92

dir=$(dirname $0)
. ${dir}/common.sh

regs_lm92=(
	3a0c b800 0001 0028 0005 0020 0020 0180
	3a0c b800 0001 0028 0005 0020 0020 0180
)

regs_max6635=(
	390c b800 0001 0028 0005 0020 0020 0020
	390c b800 0001 0028 0005 0020 0020 0020
)

attrs_lm92=(name alarms temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_max_hyst temp1_min temp1_min_alarm temp1_min_hyst)

vals_lm92=(lm92 2 80000 0 78000 24437 64000 1 62000 10000 0 12000)

vals_max6635=(max6635 1 80000 0 78000 24437 64000 0 62000 10000 1 12000)

permissions_lm92=(
	"-r--r--r--"
	"-r--r--r--"
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
)

runtest()
{
    local chip=$1
    local regs=("${!2}")
    local attrs=("${!3}")
    local vals=("${!4}")
    local permissions=("${!5}")
    local rv

    echo Testing ${chip} ...

    modprobe -r ${driver}

    load_i2c_stub ${i2c_addr} width=16

    install_regs ${i2c_adapter} ${i2c_addr} regs[@] w

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    # i2cdump -y -f ${i2c_adapter} ${i2c_addr} w
    # grep . *

    dotest attrs[@] vals[@]
    rv=$?

    check_range -d 800 -r -q temp1_min
    rv=$(($? + rv))
    check_range -d 800 -r -q temp1_max
    rv=$(($? + rv))
    check_range -d 800 -r -q temp1_crit
    rv=$(($? + rv))
    check_range -d 800 -r -q temp1_crit_hyst
    rv=$(($? + rv))

    modprobe -r i2c-stub 2>/dev/null
    return ${rv}
}

runtest lm92 regs_lm92[@] attrs_lm92[@] vals_lm92[@] permissions_lm92[@]
rv=$?
runtest max6635 regs_max6635[@] attrs_lm92[@] vals_max6635[@] permissions_lm92[@]
rv=$((rv + $?))

exit ${rv}
