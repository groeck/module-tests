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

regs=(ff80 ff00 ff00 ff40 ff8f ffc7 ffc2 0017
	0000 9cbf 8ead 4655 bee8 ff4f ff2f ffa0
	ff00 ff00 ff60 ff00 ff00 ff00 ff00 ff00
	ff00 ff00 ff00 ff00 ff00 ff00 ff00 ff80)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs[$i]} w
	i=$(($i + 1))
done

echo gl518sm 0x2c > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 002c)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarms beep_enable beep_mask
	fan1_alarm fan1_auto fan1_beep fan1_div fan1_input fan1_min
	fan2_alarm fan2_beep fan2_div fan2_input fan2_min
	in0_alarm in0_beep in0_max in0_min
	in1_alarm in1_beep in1_max in1_min
	in2_alarm in2_beep in2_max in2_min
	in3_alarm in3_beep in3_input in3_max in3_min
	temp1_alarm temp1_beep temp1_input temp1_max temp1_max_hyst)

vals=(gl518sm 96 1 0 1 1 0 4 5217 0 1 0 4 0 0 0 0
	5510 4513 0 0 3629 2964 0 0 3287 2698 0 0 1501 1615 1330 0
	0 24000 80000 75000)

rv=0
dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 1 failed
	rv=1
fi

check_range -l 0 -u 1 -b ${base} -r -d 0 temp1_beep
rv=$(($? + ${rv}))
check_range -b ${base} -d 500 -r -q temp1_max
rv=$(($? + ${rv}))
check_range -b ${base} -d 500 -r -q temp1_max_hyst
rv=$(($? + ${rv}))

for i in $(seq 0 3)
do
	check_range -b ${base} -l 0 -r -d 11 -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -d 11 -q "in${i}_max"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 1 -r -d 0 "in${i}_beep"
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 0 -u 1 -q -r fan1_auto
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
modprobe -r gl518sm

exit ${rv}
