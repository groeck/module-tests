#!/bin/bash

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x2c >/dev/null 2>&1
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs=(00 00 00 00 00 00 34 80 34 80 00 00 00 00 00 00
	00 35 00 35 00 80 00 80 e0 34 e0 34 00 80 00 80
	00 22 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 30 00 00 00 80 80 00 00 00 01 7a
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	35 80 22 00 34 80 be bd bc af c2 bc b0 ae c5 c3
	73 ab d4 ed ff c1 00 00 00 00 00 2c 00 00 fc ff
	fc ff fc ff fc ff 00 00 80 80 80 80 80 80 80 80
	3c 3c 23 23 00 00 00 00 00 00 00 00 00 00 00 00
	00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff
	00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff 00 ff
	ff ff 17 17 fc ff fc ff fc ff fc ff 00 00 00 00
	44 44 00 00 00 00 00 11 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 3f 00 80 03 ff 0f ff 0f 07 ff 07 ff 3f 00 00
	09 09 08 08 06 10 04 08 0c 20 08 08 10 09 09 09)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo lm94 0x2c > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 002c)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarms cpu0_vid cpu1_vid fan1_input fan1_min fan1_smart_tach
	fan2_input fan2_min fan2_smart_tach
	fan3_input fan3_min fan3_smart_tach
	fan4_input fan4_min fan4_smart_tach
	gpio
	in10_input in10_max in10_min in11_input in11_max in11_min
	in12_input in12_max in12_min in13_input in13_max in13_min
	in14_input in14_max in14_min in15_input in15_max in15_min
	in16_input in16_max in16_min in1_input in1_max in1_min
	in2_input in2_max in2_min in3_input in3_max in3_min
	in4_input in4_max in4_min in5_input in5_max in5_min
	in6_input in6_max in6_min in7_input in7_max in7_min
	in8_input in8_max in8_min in9_input in9_max in9_min
	prochot1 prochot1_avg prochot1_interval prochot1_max prochot1_override
	prochot2 prochot2_avg prochot2_interval prochot2_max prochot2_override
	prochot_override_duty_cycle prochot_short
	pwm1 pwm1_auto_channels pwm1_auto_spinup_min pwm1_auto_spinup_time pwm1_enable pwm1_freq
	pwm2 pwm2_auto_channels pwm2_auto_spinup_min pwm2_auto_spinup_time pwm2_enable pwm2_freq
	pwm_auto_prochot_ramp pwm_auto_vrdhot_ramp
	temp1_auto_base temp1_auto_boost temp1_auto_boost_hyst temp1_auto_offset1 temp1_auto_offset10
	temp1_auto_offset11 temp1_auto_offset12 temp1_auto_offset2 temp1_auto_offset3 temp1_auto_offset4
	temp1_auto_offset5 temp1_auto_offset6 temp1_auto_offset7 temp1_auto_offset8 temp1_auto_offset9
	temp1_auto_offset_hyst temp1_auto_pwm_min temp1_input temp1_max temp1_min
	temp2_auto_base temp2_auto_boost temp2_auto_boost_hyst temp2_auto_offset1 temp2_auto_offset10
	temp2_auto_offset11 temp2_auto_offset12 temp2_auto_offset2 temp2_auto_offset3 temp2_auto_offset4
	temp2_auto_offset5 temp2_auto_offset6 temp2_auto_offset7 temp2_auto_offset8 temp2_auto_offset9
	temp2_auto_offset_hyst temp2_auto_pwm_min temp2_input temp2_max temp2_min
	temp3_auto_base temp3_auto_boost temp3_auto_boost_hyst temp3_auto_offset1 temp3_auto_offset10
	temp3_auto_offset11 temp3_auto_offset12 temp3_auto_offset2 temp3_auto_offset3 temp3_auto_offset4
	temp3_auto_offset5 temp3_auto_offset6 temp3_auto_offset7 temp3_auto_offset8 temp3_auto_offset9
	temp3_auto_offset_hyst temp3_auto_pwm_min temp3_input temp3_max temp3_min
	vrdhot1 vrdhot2)

vals=(lm94 0 1088 1088 21428 21428 0 21428 21428 0 21428 21428 0 21428 21428 0 211
	5070 6630 0 1503 3333 0 1760 2625 0 1091 1312 0 1219 1312 0 1236
	1236 0 3326 4389 17 921 1236 0 916 1236 0 911 1236 0 1098 1600
	0 1522 2000 0 1474 2000 0 1104 1600 0 1092 1600 0 3399 4400 0
	0 0 146 255 0 0 0 146 255 0 0 0 0 0 0 0
	2 22500 0 0 0 0 2 22500 0 0 0 60000 56000 0 0 0
	0 0 0 0 0 0 0 0 0 0 0 53000 -128000 -128000 0 60000
	56000 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -128000
	-128000 -128000 0 35000 31000 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 34000 -128000 -128000 0 0)

rv=0
dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 1 failed
	rv=1
fi

for t in $(seq 1 3)
do
	check_range -b ${base} -d 500 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_auto_base
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_auto_boost
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 250 -r -q temp${t}_auto_boost_hyst
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 250 -r -q temp${t}_auto_offset_hyst
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_auto_pwm_min
	rv=$(($? + ${rv}))
	for o in $(seq 1 12)
	do
		check_range -b ${base} -d 250 -r -q temp${t}_auto_offset${o}
		rv=$(($? + ${rv}))
	done
done

for i in $(seq 1 3)
do
	check_range -b ${base} -l 0 -r -q fan${i}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -q fan${i}_smart_tach
	rv=$(($? + ${rv}))
done

for i in $(seq 1 2)
do
	check_range -b ${base} -l 0 -u 255 -r -q pwm${i} # buggy, does not clear cache
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -d 0 -q pwm${i}_auto_channels
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -q pwm${i}_auto_spinup_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -q pwm${i}_enable # buggy, does not clear cache
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -q pwm${i}_freq
	rv=$(($? + ${rv}))
done

for i in $(seq 1 15)
do
	check_range -b ${base} -l 0 -r -d 13 -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -d 13 -q "in${i}_max"
	rv=$(($? + ${rv}))
done

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
