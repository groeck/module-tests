#!/bin/bash

i2c_addr=0x40

dir=$(dirname $0)
. ${dir}/common.sh

regs_ina3221=(
	2771 0000 0000 0000 0000 0000 0000 f87f
	f87f f87f f87f f87f f87f 0000 fe7f 0300
	1027 2823 ffff ffff ffff ffff ffff ffff
	ffff ffff 0000 f8f8 ffff ffff 4954 2032
	2771 0000 0000 0000 0000 0000 0000 f87f
	f87f f87f f87f f87f f87f 0000 fe7f 0300
	1027 2823 ffff ffff ffff ffff ffff ffff
	ffff ffff 0000 f8f8 ffff ffff 4954 2032
	2771 0000 0000 0000 0000 0000 0000 f87f
	f87f f87f f87f f87f f87f 0000 fe7f 0300
	1027 2823 ffff ffff ffff ffff ffff ffff
	ffff ffff 0000 f8f8 ffff ffff 4954 2032
	2771 0000 0000 0000 0000 0000 0000 f87f
	f87f f87f f87f f87f f87f 0000 fe7f 0300
	1027 2823 ffff ffff ffff ffff ffff ffff
	ffff ffff 0000 f8f8 ffff ffff 4954 2032
	2771 0000 0000 0000 0000 0000 0000 f87f
	f87f f87f f87f f87f f87f 0000 fe7f 0300
	1027 2823 ffff ffff ffff ffff ffff ffff
	ffff ffff 0000 f8f8 ffff ffff 4954 2032
	2771 0000 0000 0000 0000 0000 0000 f87f
	f87f f87f f87f f87f f87f 0000 fe7f 0300
	1027 2823 ffff ffff ffff ffff ffff ffff
	ffff ffff 0000 f8f8 ffff ffff 4954 2032
	2771 0000 0000 0000 0000 0000 0000 f87f
	f87f f87f f87f f87f f87f 0000 fe7f 0300
	1027 2823 ffff ffff ffff ffff ffff ffff
	ffff ffff 0000 f8f8 ffff ffff 4954 2032
	2771 0000 0000 0000 0000 0000 0000 f87f
	f87f f87f f87f f87f f87f 0000 fe7f 0300
	1027 2823 ffff ffff ffff ffff ffff ffff
	ffff ffff 0000 f8f8 ffff ffff 4954 2032
)

attrs_ina3221=(curr1_crit curr1_crit_alarm curr1_input curr1_max curr1_max_alarm
	curr2_crit curr2_crit_alarm curr2_input curr2_max curr2_max_alarm
	curr3_crit curr3_crit_alarm curr3_input curr3_max curr3_max_alarm
	in1_input in2_input in3_input in4_input in5_input in6_input
	name
	shunt1_resistor shunt2_resistor shunt3_resistor
)

vals_ina3221=(16380 0 0 16380 0 16380 0 0 16380 0 16380
	0 0 16380 0 0 0 0 0 0 0 ina3221 10000 10000 10000
)

permissions_ina3221=(
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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

    load_i2c_stub ${i2c_addr}

    i=0
    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} w
	i=$(($i + 1))
    done

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    check_range -b ${basedir} -s 100 -d 200 -r -q curr1_max
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 100 -d 200 -r -q curr1_crit
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 100 -d 200 -r -q curr2_max
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 100 -d 200 -r -q curr2_crit
    rv=$(($? + ${rv}))

    check_range -b ${basedir} -r -q shunt1_resistor
    rv=$(($? + ${rv}))

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

runtest ina3221 regs_ina3221[@] attrs_ina3221[@] vals_ina3221[@] permissions_ina3221[@]
rv=$?

exit ${rv}
