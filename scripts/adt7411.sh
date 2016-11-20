#!/bin/bash

i2c_addr=0x48

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs=(00 0c 00 0a f9 0e 93 19 01 5d ff ff 5d 06 00 00
	00 00 00 00 00 00 00 00 09 40 18 00 00 00 00 00
	00 d8 d8 c7 62 64 c9 ff 00 00 00 ff 00 ff 00 ff
	00 ff 00 ff 00 ff 00 ff 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 02 41 04
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 e9 ed 00 00 00 02
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs=(name adc_ref_vdd fast_sampling
	in0_input in1_input in2_input in3_input
	in4_input in5_input in6_input in7_input in8_input
	no_average temp1_input
)

vals=(adt7411 1 0 4033 19 1472 4029 4029 1472 106 0 0 0 25500)

permissions=(
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

attrs2=(adc_ref_vdd fast_sampling in0_input in3_input in4_input
	in5_input in6_input in7_input in8_input name
	no_average temp1_input temp2_input)

vals2=(1 0 4033 4029 4029 1472 106 0 0 adt7411 0 25500 1250)

permissions2=(
	"-rw-r--r--"
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
	"-r--r--r--"
	"-r--r--r--"
)

doinit()
{
    local regs=("${!1}")
    local i=0

    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
    done
}

runtest()
{
    local chip=$1
    local attrs=("${!2}")
    local vals=("${!3}")
    local permissions=("${!4}")
    local rv

    echo "Testing ${chip}"

    do_instantiate ${chip} ${i2c_addr}

    getbasedir ${i2c_addr}

    cd ${basedir}

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    check_range -b ${basedir} -l 0 -u 1 -d 0 -r -q fast_sampling
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -l 0 -u 1 -d 0 -r -q no_average
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -l 0 -u 1 -d 0 -r -q no_average
    rv=$(($? + ${rv}))

    do_remove ${i2c_addr}

    modprobe -r adt7411

    return ${rv}
}

doinit regs[@]

runtest adt7411 attrs[@] vals[@] permissions[@]
rv=$?

i2cset -y -f ${i2c_adapter} ${i2c_addr} 0x18 0x0d b	# select external temp sensors

runtest adt7411 attrs2[@] vals2[@] permissions2[@]
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
