#!/bin/bash

i2c_addr=0x29
driver=max1619

dir=$(dirname $0)
. ${dir}/common.sh

regs_max1619=(
	1a 19 0a 0c 02 04 04 7f c9 04 04 04 04 04 04 04
	64 5f 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 4d 04
)

regs_max1619_pol=(
	9a c9 14 2c 02 04 04 7f c9 04 04 04 04 04 04 04
	64 5f 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 04 04
	04 04 04 04 04 04 04 04 04 04 04 04 04 04 4d 04
)

attrs_max1619=(alarms
	name
	temp1_input
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
)

vals_max1619=(8
	max1619
	26000
	100000 0 95000 0
	25000 127000 0 -55000 1
	4000
)

vals_max1619_pol=(20
	max1619
	-102000
	100000 0 95000 1
	-55000 127000 1 -55000 0
	4000
)

permissions_max1619=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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

    load_i2c_stub ${i2c_addr} width=8

    install_regs ${i2c_adapter} ${i2c_addr} regs[@] b

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    # i2cdump -y -f ${i2c_adapter} ${i2c_addr}
    # ls -l
    # grep . *

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    check_range -r -q -d 4000 update_interval
    rv=$((rv + $?))
    check_range -s 250 -r -q -d 500 temp2_min
    rv=$((rv + $?))
    check_range -s 250 -r -q -d 500 temp2_max
    rv=$((rv + $?))
    check_range -s 250 -r -q -d 500 temp2_crit
    rv=$((rv + $?))

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest max1619 regs_max1619[@] attrs_max1619[@] vals_max1619[@] permissions_max1619[@]
rv=$((rv + $?))
runtest max1619 regs_max1619_pol[@] attrs_max1619[@] vals_max1619_pol[@] permissions_max1619[@]
rv=$((rv + $?))

exit ${rv}
