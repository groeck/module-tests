#!/bin/bash

i2c_addr=3f

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x3f
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

i2cset -f -y ${adapter} 0x${i2c_addr} 0x0 0x7f b	# set_cnt
i2cset -f -y ${adapter} 0x${i2c_addr} 0x1 0x3f b	# act_cnt
i2cset -f -y ${adapter} 0x${i2c_addr} 0x2 0x01 b	# fan_sta
i2cset -f -y ${adapter} 0x${i2c_addr} 0x3 0x7f b	# set_out (pwm)
i2cset -f -y ${adapter} 0x${i2c_addr} 0x4 0x04 b	# fan_cmd1
i2cset -f -y ${adapter} 0x${i2c_addr} 0x5 0x00 b	# fan_cmd2

echo g762 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name fan1_alarm fan1_div fan1_fault fan1_input fan1_pulses fan1_target
	pwm1 pwm1_enable pwm1_mode)
vals=(g762 0 2 0 0 2 0 127 1 0)

dotest attrs[@] vals[@]
rv=$?

check_range -b ${base} -l 0 -u 255 -d 0 -r -q pwm1
rv=$(($? + ${rv}))
check_range -b ${base} -l 1 -u 2 -d 0 -r -q pwm1_enable
rv=$(($? + ${rv}))
check_range -b ${base} -l 0 -u 1 -d 0 -r -q pwm1_mode
rv=$(($? + ${rv}))
check_range -b ${base} -l 1 -u 2 -d 0 -r -q fan1_div
rv=$(($? + ${rv}))
check_range -b ${base} -l 4 -u 4 -d 0 -r -q fan1_div
rv=$(($? + ${rv}))
check_range -b ${base} -l 0 -r -d 0 -q fan1_target
rv=$(($? + ${rv}))
check_range -b ${base} -l 2 -u 2 -r -d 0 -q fan1_pulses
rv=$(($? + ${rv}))
check_range -b ${base} -l 4 -u 4 -r -d 0 -q fan1_pulses
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null
modprobe -r g762

exit ${rv}
