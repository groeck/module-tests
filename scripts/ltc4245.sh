#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

regs_ltc4245=(
	98 00 29 ff 07 80 38 00 98 00 29 ff 07 80 38 00
	d3 00 d4 ea 00 ea d8 04 d8 00 00 00 00 00 00 00
	98 00 29 ff 07 80 38 00 98 00 29 ff 07 80 38 00
	d3 00 d4 ea 00 ea d8 04 d8 00 00 00 00 00 00 00
	98 00 29 ff 07 80 38 00 98 00 29 ff 07 80 38 00
	d3 00 d4 ea 00 ea d8 04 d8 00 00 00 00 00 00 00
	98 00 29 ff 07 80 38 00 98 00 29 ff 07 80 38 00
	d3 00 d4 ea 00 ea d8 04 d8 00 00 00 00 00 00 00
	98 00 29 ff 07 80 38 00 98 00 29 ff 07 80 38 00
	d3 00 d4 ea 00 ea d8 04 d8 00 00 00 00 00 00 00
	98 00 29 ff 07 80 38 00 98 00 29 ff 07 80 38 00
	d3 00 d4 ea 00 ea d8 04 d8 00 00 00 00 00 00 00
	98 00 29 ff 07 80 38 00 98 00 29 ff 07 80 38 00
	d3 00 d4 ea 00 ea d8 04 d8 00 00 00 00 00 00 00
	98 00 29 ff 07 80 38 00 98 00 29 ff 07 80 38 00
	d3 00 d4 ea 00 ea d8 04 d8 00 00 00 00 00 00 00
)

attrs_ltc4245=(curr1_input curr1_max_alarm curr2_input curr2_max_alarm
	curr3_input curr3_max_alarm curr4_input curr4_max_alarm
	in1_input in1_min_alarm in2_input in2_min_alarm in3_input in3_min_alarm
	in4_input in4_min_alarm in5_input in5_min_alarm in6_input in6_min_alarm
	in7_input in7_min_alarm in8_input in8_min_alarm in9_input
	name
	power1_input power2_input power3_input power4_input
)

vals_ltc4245=(0 0 0 0 200 0 0 0 11605 0
	5148 0 3240 0 0 0 11660 0 5148 0
	3240 0 0 0 0 ltc4245 0 0 648000 0
)

permissions_ltc4245=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
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

    load_i2c_stub ${i2c_addr}

    i=0
    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
    done

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

runtest ltc4245 regs_ltc4245[@] attrs_ltc4245[@] vals_ltc4245[@] permissions_ltc4245[@]
rv=$?

exit ${rv}
