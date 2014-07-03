#!/bin/bash

i2c_addr=2c

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x${i2c_addr}
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs=(
	91 7f 00 00 5d 5d e0 00 ff ff 19 1c 19 00 00 00
	ff ff 5d 5d 3c 00 46 5d 50 00 64 5d 50 00 64 5d
	5d 5d 55 50 41 61 61 5d 5d 5d 5d 5d 5d 5d 5d 5d
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 31 41 83
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adm1031 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(alarms auto_fan1_channel auto_fan1_min_pwm auto_fan2_channel auto_fan2_min_pwm
	auto_temp1_max auto_temp1_min auto_temp1_off
	auto_temp2_max auto_temp2_min auto_temp2_off
	auto_temp3_max auto_temp3_min auto_temp3_off
	fan1_alarm fan1_div fan1_fault fan1_input fan1_min
	fan2_alarm fan2_div fan2_fault fan2_input fan2_min
	pwm1 pwm2
	temp1_crit temp1_crit_alarm temp1_input temp1_max temp1_max_alarm temp1_min
	temp1_min_alarm temp1_offset
	temp2_crit temp2_crit_alarm temp2_fault temp2_input temp2_max temp2_max_alarm
	temp2_min temp2_min_alarm temp2_offset
	temp3_crit temp3_crit_alarm temp3_fault temp3_input temp3_max temp3_max_alarm
	temp3_min temp3_min_alarm temp3_offset
	update_interval
	)

vals=(0 2 80 4 80 42000 32000 27000 58000 48000 43000 58000 48000 43000 0 2
	0 0 1323 0 2 0 0 1323 80 80 70000 0 25750 60000 0 0
	0 0 100000 0 0 28000 80000 0 0 0 0 100000 0 0 25500 80000
	0 0 0 0 1000
	)

dotest attrs[@] vals[@]
rv=$?

for i in $(seq 1 3)
do
	check_range -b ${base} -d 500 -r -q temp${i}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${i}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${i}_crit
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${i}_offset
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 4000 -r -q auto_temp${i}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -r -q auto_temp${i}_max
	rv=$(($? + ${rv}))
done

for i in $(seq 1 2)
do
	check_range -b ${base} -l 80 -u 80 -r -q pwm${i} # auto mode
	rv=$(($? + ${rv}))
done

for i in $(seq 1 2)
do
	check_range -b ${base} -l 1 -u 2 -d 0 -r -q fan${i}_div
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 20000 -d 1500 -r -q fan${i}_min
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 0 -d 8000 -r -q update_interval
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
