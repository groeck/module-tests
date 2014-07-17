#!/bin/bash

i2c_addr=58

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

regs=(20 b1 7c 08 00 00 00 c0 e0 00 00 00 40 80 00 01
	c0 7c ca 30 00 00 00 00 37 37 00 03 00 00 00 00
	00 80 80 58 38 90 93 00 00 00 30 37 ff 00 00 00
	92 f7 f4 e0 3f b8 ff 00 ff 00 00 00 00 62 41 04
	00 00 00 00 40 40 40 00 95 88 77 ff ff ff ff ff
	ff ff ff ff 22 22 00 00 00 00 a4 a4 9a 72 62 9a
	c4 84 84 c4 40 00 00 00 ff ff d2 ce ff b4 b4 00
	00 00 20 b2 b2 00 00 00 ff ff ff de ce ce f0 f0
	ff 10 00 00 00 00 00 00 00 61 c0 5b 00 57 00 00
	5f c3 bf 00 00 00 00 79 00 00 00 00 00 00 00 00
	00 20 00 c0 00 c0 84 03 a3 03 ff ff ff ff 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 20 00 00 00
	00 00 00 00 20 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adt7462 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(fan1_alarm fan1_input fan1_min fan2_alarm fan2_input fan2_min
	fan3_alarm fan3_input fan3_min fan4_alarm fan4_input fan4_min
	fan5_alarm fan5_input fan5_min fan6_alarm fan6_input fan6_min
	fan7_alarm fan7_input fan7_min fan8_alarm fan8_input fan8_min
	force_pwm_max
	in10_alarm in10_input in10_label in10_max in10_min
	in11_alarm in11_input in11_label in11_max in11_min
	in12_alarm in12_input in12_label in12_max in12_min
	in13_alarm in13_input in13_label in13_max in13_min
	in1_alarm in1_input in1_label in1_max in1_min
	in2_alarm in2_input in2_label in2_max in2_min
	in3_alarm in3_input in3_label in3_max in3_min
	in4_alarm in4_input in4_label in4_max in4_min
	in5_alarm in5_input in5_label in5_max in5_min
	in6_alarm in6_input in6_label in6_max in6_min
	in7_alarm in7_input in7_label in7_max in7_min
	in8_alarm in8_input in8_label in8_max in8_min
	in9_alarm in9_input in9_label in9_max in9_min
	pwm1 pwm1_auto_channels_temp pwm1_auto_point1_pwm pwm1_auto_point2_pwm pwm1_enable
	pwm2 pwm2_auto_channels_temp pwm2_auto_point1_pwm pwm2_auto_point2_pwm pwm2_enable
	pwm3 pwm3_auto_channels_temp pwm3_auto_point1_pwm pwm3_auto_point2_pwm pwm3_enable
	pwm4 pwm4_auto_channels_temp pwm4_auto_point1_pwm pwm4_auto_point2_pwm pwm4_enable
	temp1_alarm temp1_auto_point1_hyst temp1_auto_point1_temp temp1_auto_point2_hyst
	temp1_auto_point2_temp temp1_input temp1_label temp1_max temp1_min
	temp2_alarm temp2_auto_point1_hyst temp2_auto_point1_temp temp2_auto_point2_hyst
	temp2_auto_point2_temp temp2_input temp2_label temp2_max temp2_min
	temp3_alarm temp3_auto_point1_hyst temp3_auto_point1_temp temp3_auto_point2_hyst
	temp3_auto_point2_temp temp3_input temp3_label temp3_max temp3_min
	temp4_alarm temp4_auto_point1_hyst temp4_auto_point1_temp temp4_auto_point2_hyst
	temp4_auto_point2_temp temp4_input temp4_label temp4_max temp4_min)

vals=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 6000 87 0 5800 87 1 0 3285 +3.3V 3543 3061 0 1521
	+1.5 1638 1388 0 0 N/A 0 0 0 0 N/A 0 0 0 12000 +12V1
	12875 11250 0 1187 Vccp1 3187 400 0 0 N/A 0 0 0 0 N/A 0
	0 0 0 +0.9V 1195 0 0 0 N/A 0 0 0 0 N/A 0 0
	0 12000 +12V2 12875 11250 0 0 N/A 0 0 255 0 0 255 0
	255 0 0 255 0 255 4 48 255 2 255 2 55 255 2 0
	4000 90000 4000 122000 33000 local 85000 0 0 4000 50000 4000 63300 27750 remote1 72000
	0 0 4000 34000 4000 47300 23000 remote2 55000 0 0 4000 90000 4000 122000 0
	N/A 0 0)

dotest attrs[@] vals[@]
rv=$?

# other voltages are disabled
for i in $(seq 1 2)
do
	check_range -b ${base} -l 1 -d 32 -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 1 -d 32 -q "in${i}_max"
	rv=$(($? + ${rv}))
done

# temp4 is disabled
for t in $(seq 1 3)
do
	check_range -b ${base} -d 500 -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -q temp${t}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -q temp${t}_auto_point1_hyst
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -q temp${t}_auto_point1_temp
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -q temp${t}_auto_point2_hyst
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -q temp${t}_auto_point2_temp
	rv=$(($? + ${rv}))
done

# other fans are disabled
for f in $(seq 7 8)
do
	check_range -b ${base} -l 1000 -u 10000 -d 4000 -q fan${f}_min
	rv=$(($? + ${rv}))
done

for p in $(seq 1 4)
do
	check_range -b ${base} -l 0 -u 255 -r -d 0 -q pwm${p}
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 8 -u 9 -d 0 -q pwm${p}_auto_channels_temp
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 255 -r -d 0 -q pwm${p}_auto_point1_pwm
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 255 -r -d 0 -q pwm${p}_auto_point2_pwm
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 1 -d 0 -q pwm${p}_enable
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 0 -u 1 -d 0 -r -q force_pwm_max
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
