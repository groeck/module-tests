#!/bin/bash

i2c_addr=0x18
driver=max1668

dir=$(dirname $0)
. ${dir}/common.sh

regs_max1668=(
	17 18 19 1a 20 0f f0 00 7f c9 7f c9 7f c9 7f c9
	7f c9 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 4d 03
)

attrs_max1668=(name
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	temp3_fault temp3_input temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	temp4_fault temp4_input temp4_max temp4_max_alarm temp4_min temp4_min_alarm
	temp5_fault temp5_input temp5_max temp5_max_alarm temp5_min temp5_min_alarm
)

vals_max1668=(max1668
	23000 127000 0 -55000 0
	0 24000 127000 1 -55000 1
	0 25000 127000 1 -55000 1
	0 26000 127000 0 -55000 0
	0 32000 127000 0 -55000 0
)

permissions_max1668=(
	"-r--r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

alarms_max1668=(
	0x05 0x40 temp1_max_alarm
	0x05 0x20 temp1_min_alarm
	0x06 0x80 temp2_min_alarm
	0x06 0x40 temp2_max_alarm
	0x06 0x20 temp3_min_alarm
	0x06 0x10 temp3_max_alarm
	0x06 0x08 temp4_min_alarm
	0x06 0x04 temp4_max_alarm
	0x06 0x02 temp5_min_alarm
	0x06 0x01 temp5_max_alarm
)

regs_max1989=(
	33 32 31 10 7f f0 0f 00 7f c9 7f c9 7f c9 7f c9
	7f c9 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 4d 0b
)

vals_max1989=(max1989
	51000 127000 1 -55000 1
	0 50000 127000 0 -55000 0
	0 49000 127000 0 -55000 0
	0 16000 127000 1 -55000 1
	1 127000 127000 1 -55000 1
)

regs_max1805=(
	30 32 7f 00 00 a0 aa 00 7f c9 7f c9 7f c9 7f c9
	7f c9 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	03 03 03 03 03 03 03 03 03 03 03 03 03 03 4d 05
)

attrs_max1805=(name
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	temp3_fault temp3_input temp3_max temp3_max_alarm temp3_min temp3_min_alarm
)

vals_max1805=(max1805
	48000 127000 0 -55000 1
	0 50000 127000 0 -55000 1
	0 127000 127000 0 -55000 1
)

alarms_max1805=(
	0x05 0x40 temp1_max_alarm
	0x05 0x20 temp1_min_alarm
	0x06 0x80 temp2_min_alarm
	0x06 0x40 temp2_max_alarm
	0x01 0x7f temp2_fault
	0x06 0x20 temp3_min_alarm
	0x06 0x10 temp3_max_alarm
	0x02 0x7f temp3_fault
)
permissions_max1668=(
	"-r--r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

runtest()
{
    local chip=$1
    local channels=$2
    local regs=("${!3}")
    local attrs=("${!4}")
    local vals=("${!5}")
    local permissions=("${!6}")
    local alarms=("${!7}")
    local rv
    local i

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

    # Set fault bit prior to check alarms.
    # The actual alarm is then set by temperature register
    # value of 0x7f == 127.
    i2cset -y -f ${i2c_adapter} ${i2c_addr} 0x05 0x10

    check_alarms ${i2c_adapter} ${i2c_addr} alarms[@]
    rv=$((rv + $?))

    for i in $(seq 1 ${channels}); do
	check_range -s 250 -r -q temp${i}_min
	rv=$((rv + $?))
	check_range -s 250 -r -q temp${i}_max
	rv=$((rv + $?))
    done

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest max1668 5 regs_max1668[@] attrs_max1668[@] vals_max1668[@] permissions_max1668[@] alarms_max1668[@]
rv=$((rv + $?))
runtest max1989 5 regs_max1989[@] attrs_max1668[@] vals_max1989[@] permissions_max1668[@] alarms_max1668[@]
rv=$((rv + $?))
runtest max1805 3 regs_max1805[@] attrs_max1805[@] vals_max1805[@] permissions_max1805[@] alarms_max1805[@]
rv=$((rv + $?))

exit ${rv}
