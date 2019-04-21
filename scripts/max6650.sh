#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs_max6650=(00 00 0a 00 ff 00 00 00 00 00 00 00 f8 00 f0 00
	00 00 00 00 1f 00 02 00 00 00 00 00 00 00 00 00)

attrs_max6650=(name fan1_div fan1_input fan1_target pwm1 pwm1_enable)
vals_max6650=(max6650 4 7440 238125 255 0)

permissions_max6650=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_max6650_alarm=(00 00 0a 00 ff 00 00 00 0f 00 00 00 f8 00 f0 00
	00 00 00 00 1f 00 02 00 00 00 00 00 00 00 00 00)

attrs_max6650_alarm=(name fan1_div fan1_fault fan1_input
	fan1_max_alarm fan1_min_alarm fan1_target
	gpio1_alarm pwm1 pwm1_enable)
vals_max6650_alarm=(max6650 4 0 7440 0 0 238125 0 255 0)

permissions_max6650_alarm=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_max6651=(00 00 0a 0a ff ff 00 00 00 00 00 00 01 01 00 00
	01 01 01 01 1f 1f 02 02 91 91 91 91 91 91 91 91)

attrs_max6651=(name fan1_div fan1_input fan1_target
	fan2_input fan3_input fan4_input pwm1 pwm1_enable)
vals_max6651=(max6651 4 30 238125 0 30 30 255 0)

permissions_max6651=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_max6651_alarm=(00 00 0a 0a ff ff 00 00 1f 00 00 00 01 01 00 00
	01 01 01 01 1f 1f 02 02 91 91 91 91 91 91 91 91)

attrs_max6651_alarm=(name fan1_div fan1_fault fan1_input
	fan1_max_alarm fan1_min_alarm fan1_target
	fan2_input fan3_input fan4_input
	gpio1_alarm gpio2_alarm
	pwm1 pwm1_enable)
vals_max6651_alarm=(max6651 4 0 30 0 0 238125 0 30 30 0 0 255 0)

permissions_max6651_alarm=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

doinit()
{
    local regs=("${!1}")
    local i=0

    while [ $i -lt ${#regs[*]} ]
    do
	# echo "i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b"
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
    done
}

runtest()
{
    local desc=$1
    local chip=$2
    local attrs=("${!3}")
    local vals=("${!4}")
    local permissions=("${!5}")
    local rv

    echo "Testing ${desc}"

    do_instantiate ${chip} ${i2c_addr}

    getbasedir ${i2c_addr}

    cd ${basedir}

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    check_range -b ${basedir} -d 5000 -r -q -l 240 -u 30000 fan1_target
    check_range -b ${basedir} -r -q pwm1
    check_range -b ${basedir} -r -q -l 0 -u 3 pwm1_enable

    do_remove ${i2c_addr}

    return ${rv}
}

doinit regs_max6650[@]

runtest max6650 max6650 attrs_max6650[@] vals_max6650[@] permissions_max6650[@]
rv=$?

doinit regs_max6650_alarm[@]

modprobe -r max6650

runtest max6650-alarm max6650 attrs_max6650_alarm[@] vals_max6650_alarm[@] \
	permissions_max6650_alarm[@]
rv=$(($? + ${rv}))

doinit regs_max6651[@]

modprobe -r max6650

runtest max6651 max6651 attrs_max6651[@] vals_max6651[@] permissions_max6651[@]
rv=$(($? + ${rv}))

doinit regs_max6651_alarm[@]

modprobe -r max6650

runtest max6651-alarm max6651 attrs_max6651_alarm[@] vals_max6651_alarm[@] \
	permissions_max6651_alarm[@]
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null
modprobe -r max6650

exit ${rv}
