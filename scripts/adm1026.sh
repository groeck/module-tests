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

regs=(00 00 55 55 ff ff 00 00 00 00 00 00 00 37 50 50
	28 40 40 00 00 00 41 40 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	64 64 ff ff ff ff ff ff 80 80 00 00 00 00 00 00
	ff ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00
	ff ff ff ff ff ff ff ff 50 80 ff 00 ff 00 00 00
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adm1026 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarm_mask alarms analog_out cpu0_vid
	fan1_alarm fan1_div fan1_input fan1_min
	fan2_alarm fan2_div fan2_input fan2_min
	fan3_alarm fan3_div fan3_input fan3_min
	fan4_alarm fan4_div fan4_input fan4_min
	fan5_alarm fan5_div fan5_input fan5_min
	fan6_alarm fan6_div fan6_input fan6_min
	fan7_alarm fan7_div fan7_input fan7_min
	fan8_alarm fan8_div fan8_input fan8_min
	gpio gpio_mask
	in0_alarm in0_input in0_max in0_min
	in10_alarm in10_input in10_max in10_min
	in11_alarm in11_input in11_max in11_min
	in12_alarm in12_input in12_max in12_min
	in13_alarm in13_input in13_max in13_min
	in14_alarm in14_input in14_max in14_min
	in15_alarm in15_input in15_max in15_min
	in16_alarm in16_input in16_max in16_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in6_alarm in6_input in6_max in6_min
	in7_alarm in7_input in7_max in7_min
	pwm1 pwm1_enable pwm2 pwm2_enable pwm3 pwm3_enable
	temp1_alarm temp1_auto_point1_pwm temp1_auto_point1_temp
	temp1_auto_point1_temp_hyst temp1_auto_point2_pwm
	temp1_auto_point2_temp temp1_crit temp1_crit_enable
	temp1_input temp1_max temp1_min temp1_offset
	temp2_alarm temp2_auto_point1_pwm temp2_auto_point1_temp
	temp2_auto_point1_temp_hyst temp2_auto_point2_pwm
	temp2_auto_point2_temp temp2_crit temp2_crit_enable
	temp2_input temp2_max temp2_min temp2_offset
	temp3_alarm temp3_auto_point1_pwm temp3_auto_point1_temp
	temp3_auto_point1_temp_hyst temp3_auto_point2_pwm
	temp3_auto_point2_temp temp3_crit temp3_crit_enable
	temp3_input temp3_max temp3_min temp3_offset
	vrm
	)

vals=(adm1026 0 0 2500 0 0 2 -1 0 0 2 -1 0 0 2 -1 0
	0 2 -1 0 0 2 -1 0 0 2 -1 0 0 2 -1 0
	0 2 -1 0 0 0 0 0 2988 0 0 0 3984 0 0 0
	4423 0 0 0 4423 0 0 0 6634 0 0 0 2988 0 0 0
	15938 0 0 -16000 2428 -16000 0 0 2988 0 0 0 2988 0 0 0
	2988 0 0 0 2988 0 0 0 2988 0 0 0 2490 0 0 0
	2490 0 255 0 255 0 255 0 0 255 40000 34000 255 60000 55000 0
	0 80000 -128000 0 0 255 64000 58000 255 84000 80000 0 0 100000 -128000 0
	0 255 64000 58000 255 84000 80000 0 0 100000 -128000 0 110
	)

rv=0
dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

for i in $(seq 0 16)
do
	# in8 and in9 not available in this configuration
	if [ $i -eq 8 -o $i -eq 9 ]
	then
		continue
	fi
	check_range -b ${base} -d 36 -r -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 36 -r -q "in${i}_max"
	rv=$(($? + ${rv}))
done

for i in $(seq 1 3)
do
	check_range -b ${base} -d 500 -r -q temp${i}_min
	rv=$(($? + ${rv}))
	echo -127000 > temp${i}_min
	check_range -b ${base} -d 500 -r -q temp${i}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 1 -r -q temp${i}_crit_enable
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${i}_crit
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${i}_offset
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -d 0 -r -q temp${i}_auto_point1_pwm
	rv=$(($? + ${rv}))
	check_range -b ${base} -r -q temp${i}_auto_point1_temp
	rv=$(($? + ${rv}))
done

for i in $(seq 1 3)
do
	echo 1 > pwm${i}_enable	# needed to be able to write pwm
	check_range -b ${base} -l 0 -u 255 -d 0 -r -q pwm${i}
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 2 -r -q pwm${i}_enable
	rv=$(($? + ${rv}))
done

for i in $(seq 1 8)
do
	check_range -b ${base} -l 1 -u 2 -d 0 -r -q fan${i}_div
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 20000 -d 2500 -r -q fan${i}_min
	rv=$(($? + ${rv}))
done

check_range -b ${base} -d 8 -r -q analog_out
rv=$(($? + ${rv}))
check_range -b ${base} -d 0 -l 0 -u 131071 -r -q gpio	# 0x1ffff
rv=$(($? + ${rv}))
check_range -b ${base} -d 0 -l 0 -u 131071 -r -q gpio_mask	# 0x1ffff
rv=$(($? + ${rv}))
check_range -b ${base} -d 0 -l 0 -u 65535 -r -q alarm_mask
rv=$(($? + ${rv}))
check_range -b ${base} -d 0 -l 0 -u 255 -r -q vrm
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
