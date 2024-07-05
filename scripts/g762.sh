#!/bin/bash

i2c_addr=0x3f
chip="g762"

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub "${i2c_addr}"
modprobe -r "${chip}"

i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x0 0x7f b	# set_cnt
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x1 0x3f b	# act_cnt
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x2 0x01 b	# fan_sta
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x3 0x7f b	# set_out (pwm)
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x4 0x04 b	# fan_cmd1
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x5 0x00 b	# fan_cmd2

do_instantiate ${chip} ${i2c_addr} 2>/dev/null
getbasedir ${i2c_addr}

cd ${basedir}

attrs=(name fan1_alarm fan1_div fan1_fault fan1_input fan1_pulses fan1_target
	pwm1 pwm1_enable pwm1_mode)
vals=(g762 0 2 0 3900 2 1935 127 1 0)
permissions=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

dotest attrs[@] vals[@] permissions[@]
rv=$?

check_range -l 0 -u 255 -d 0 -r -q pwm1
rv=$(($? + ${rv}))
check_range -l 1 -u 2 -d 0 -r -q pwm1_enable
rv=$(($? + ${rv}))
check_range -l 0 -u 1 -d 0 -r -q pwm1_mode
rv=$(($? + ${rv}))
check_range -R "1 2 4 8 : 0 3 9" -r -q fan1_div
rv=$(($? + ${rv}))
check_range -r -d 82000 -q fan1_target
rv=$(($? + ${rv}))
check_range -R "2 4 : 1 3 9" -S -q fan1_pulses
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null
modprobe -r g762

exit ${rv}
