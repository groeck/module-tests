#!/bin/bash

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x2c
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs=(0020 0080 0000 0040 00a5 00b4 0000 003d 
	f0f0 a8b3 8aa3 6f79 cadb 005b 00a5 0050 
	0000 0000 00d8 009e 00b2 00d9 0000 00b4)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs[$i]} w
	i=$(($i + 1))
done

echo gl520sm 0x2c > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 002c)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(alarms beep_enable beep_mask cpu0_vid
	fan1_alarm fan1_beep fan1_div fan1_input fan1_min fan1_off
	fan2_alarm fan2_beep fan2_div fan2_input fan2_min
	in0_alarm in0_beep in0_input in0_max in0_min
	in1_alarm in1_beep in1_input in1_max in1_min
	in2_alarm in2_beep in2_input in2_max in2_min
	in3_alarm in3_beep in3_input in3_max in3_min
	temp1_alarm temp1_beep temp1_input temp1_max temp1_max_hyst
	temp2_alarm temp2_beep temp2_input temp2_max temp2_max_hyst)

vals=(216 1 0 0 0 0 2 3934 1000 0 1 0 2 0 1000 0 0 5154 5201
	4798 0 0 3382 3401 3192 0 0 3002 3097 2622 1 0 1729
	2299 2109 1 0 35000 50000 -130000 1 0 35000 50000 -130000)

rv=0
dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 1 failed
	rv=1
fi

for t in $(seq 1 2)
do
	check_range -l 0 -u 1 -b ${base} -r -d 0 temp${t}_beep
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max_hyst
	rv=$(($? + ${rv}))
done

for i in $(seq 0 3)
do
	check_range -b ${base} -l 0 -r -d 11 -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -d 11 -q "in${i}_max"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 1 -r -d 0 "in${i}_beep"
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 0 -u 1 -q -r -d 0 fan1_off
rv=$(($? + ${rv}))

for i in $(seq 1 2)
do
	check_range -b ${base} -l 0 -u 1 -r -d 0 -q "fan${i}_beep"
	rv=$(($? + ${rv}))
	# don't reset fanX_min to avoid beep_mask failure
	check_range -b ${base} -l 0 -u 10000 -d 400 -q "fan${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 1 -u 2 -r "fan${i}_div" # should be 1, 2, 4, 8
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 0 -u 1 -q -d 0 -r beep_enable
rv=$(($? + ${rv}))

check_range -b ${base} -l 0 -u 127 -q -d 0 -r beep_mask
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
