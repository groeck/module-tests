#!/bin/bash

i2c_addr=2e

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

regs=(1a 00 19 80 1a 00 19 e0 00 00 75 00 00 00 00 00
	d0 12 12 16 07 07 00 07 00 64 64 64 00 64 00 00
	01 0e 00 08 00 00 00 80 00 00 00 03 00 00 00 00
	55 55 55 00 55 00 00 00 00 00 00 00 00 00 00 00
	ff 01 2b 38 01 2a 19 10 66 f5 00 00 f8 ff 24 a0
	00 fb 7f 7f 7f 7f e6 7f 7f 7f 7f d1 7f 7f 7f 7f
	bc 7f 7f 7f 7f a7 7f 7f 7f 7f 92 7f 7f 7f 7f 92
	7f 7f 7f 7f 92 7f 7f 7f 7f 0a c0 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 5a 00 00 00 72 80 43 52 2c 05 44 22
	20 00 00 07 20 00 20 40 00 00 00 12 00 00 00 00
	00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 01 26 5d 01
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo emc2103 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(fan1_div fan1_fault fan1_input fan1_target pwm1_enable
	temp1_fault temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	temp3_fault temp3_input temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	temp4_fault temp4_input temp4_max temp4_max_alarm temp4_min temp4_min_alarm
	)

vals=(4 0 6710 0 0 0 26000 85000 0 0 0 0 25500 85000 0 0
	0 0 26000 85000 0 0 0 0 25875 85000 0 0 0
)
dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 4)
do
	check_range -b ${base} -d 500 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 1 -u 2 -d 0 -r -q fan1_div
rv=$(($? + ${rv}))
check_range -b ${base} -l 4 -u 4 -d 0 -r -q fan1_div
rv=$(($? + ${rv}))
check_range -b ${base} -l 0 -u 0 -d 0 -r -q pwm1_enable
rv=$(($? + ${rv}))
check_range -b ${base} -l 0 -r -d 815 -q fan1_target
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
