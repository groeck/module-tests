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

attrs=(adc_ref_vdd fast_sampling
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in6_alarm in6_input in6_max in6_min
	in7_alarm in7_input in7_max in7_min
	in8_alarm in8_input in8_max in8_min
	name no_average
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
)

vals=(1 0 0 4033 5441 2679 0 19 4017 0 0 1472 4017 0 0 4029 4017
	0 0 4029 4017 0 0 1472 4017 0 0 106 4017 0 1 0 4017
	0 1 0 4017 0 adt7411 0 25500 100000 0 -55000 0
)

permissions=(
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

attrs2=(adc_ref_vdd fast_sampling
	in0_alarm in0_input in0_max in0_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in6_alarm in6_input in6_max in6_min
	in7_alarm in7_input in7_max in7_min
	in8_alarm in8_input in8_max in8_min
	name no_average
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	)

vals2=(1 0 0 4033 5441 2679 0 4029 4017
	0 0 4029 4017 0 0 1472 4017 0 0 106 4017 0 1 0 4017
	0 1 0 4017 0 adt7411 0 25500 100000 0 -55000 0
	0 1250 -1000 0 0 0
)

permissions2=(
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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

    for i in $(seq 0 8)
    do
	if [ -e "in${i}_min" ]
	then
	    check_range -b ${basedir} -d 16 -r -q "in${i}_min"
	    rv=$(($? + ${rv}))
	    check_range -b ${basedir} -d 16 -r -q "in${i}_max"
	    rv=$(($? + ${rv}))
	fi
    done

    for i in $(seq 1 2)
    do
	if [ -e "temp${i}_min" ]
	then
	    check_range -b ${basedir} -d 500 -r -q "temp${i}_min"
	    rv=$(($? + ${rv}))
	    check_range -b ${basedir} -d 500 -r -q "temp${i}_max"
	    rv=$(($? + ${rv}))
	fi
    done

    do_remove ${i2c_addr}

    return ${rv}
}

doinit regs[@]

runtest adt7411 attrs[@] vals[@] permissions[@]
rv=$?

doinit regs[@]
i2cset -y -f ${i2c_adapter} ${i2c_addr} 0x18 0x0d b	# select external temp sensors

runtest adt7411 attrs2[@] vals2[@] permissions2[@]
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null
modprobe -r adt7411

exit ${rv}
