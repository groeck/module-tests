#!/bin/bash

i2c_addr=0x40
driver=ina2xx

dir=$(dirname $0)
. ${dir}/common.sh

regs_ina226=(
	2745 7f13 4b0a 9202 7f13 0008 0800 0000 
	ffff ffff 0000 aaf3 ffff c0ff 4954 6022 
)

attrs_ina226=(name
	curr1_input
	in0_crit in0_crit_alarm in0_input in0_lcrit in0_lcrit_alarm
	in1_crit in1_crit_alarm in1_input in1_lcrit in1_lcrit_alarm
	power1_crit power1_crit_alarm power1_input
	shunt_resistor
	update_interval
)

vals_ina226=(
	ina226
	1248
	0 0 12 0 0
	0 0 3294 0 0
	0 0 4112500
	10000
	35
)

permissions_ina226=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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
    local permissions=("${!5}")
    local rv
    local i

    echo Testing ${chip} ...

    modprobe -r ${driver}

    load_i2c_stub ${i2c_addr}

    install_regs ${i2c_adapter} ${i2c_addr} regs[@] w

    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    # i2cdump -y -f ${i2c_adapter} ${i2c_addr} w
    # grep . *

    dotest attrs[@] vals[@]
    rv=$?

    for i in $(seq 0 1); do
	check_range -l 0 -r -q -d 1 "in${i}_crit"
	rv=$(($? + rv))
	check_range -l 0 -r -q -d 1 "in${i}_lcrit"
	rv=$(($? + rv))
    done

    check_range -l 0 -r -q -d 3120 "power1_crit"
    rv=$(($? + rv))
    check_range -r -q -d 0 "shunt_resistor"
    rv=$(($? + rv))
    check_range -r -q -d 600 "update_interval"
    rv=$(($? + rv))

    modprobe -r i2c-stub 2>/dev/null
    return ${rv}
}

# Just in case the iio module is loaded
modprobe -r ina2xx_adc

runtest ina226 regs_ina226[@] attrs_ina226[@] vals_ina226[@] permissions_ina226[@]
rv=$?

exit ${rv}
