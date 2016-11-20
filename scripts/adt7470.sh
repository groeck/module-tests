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

regs=(00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	22 01 21 01 00 00 00 00 00 00 95 09 51 0b ff ff
	ff ff 70 68 ff ff 0c 00 ff ff ff ff 00 70 41 02
	01 80 00 55 85 78 81 7f 85 78 81 7f 81 7f 81 7f
	81 7f 81 7f 81 7f 81 7f f0 ff f0 ff ff ff ff ff
	00 00 00 00 00 00 00 00 c0 00 60 60 80 80 20 20
	5a 5a 7f cf 1c 88 00 00 22 00 00 07 13 00 00 00
	00 ce 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adt7470 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarm_mask auto_update_interval fan1_alarm fan1_input fan1_max fan1_min
	fan2_alarm fan2_input fan2_max fan2_min fan3_alarm fan3_input fan3_max fan3_min
	fan4_alarm fan4_input fan4_max fan4_min
	force_pwm_max num_temp_sensors
	pwm1 pwm1_auto_channels_temp pwm1_auto_point1_pwm pwm1_auto_point1_temp
	pwm1_auto_point2_pwm pwm1_auto_point2_temp pwm1_enable
	pwm2 pwm2_auto_channels_temp pwm2_auto_point1_pwm pwm2_auto_point1_temp
	pwm2_auto_point2_pwm pwm2_auto_point2_temp pwm2_enable
	pwm3 pwm3_auto_channels_temp pwm3_auto_point1_pwm pwm3_auto_point1_temp
	pwm3_auto_point2_pwm pwm3_auto_point2_temp pwm3_enable
	pwm4 pwm4_auto_channels_temp pwm4_auto_point1_pwm pwm4_auto_point1_temp
	pwm4_auto_point2_pwm pwm4_auto_point2_temp pwm4_enable
	temp10_alarm temp10_input temp10_max temp10_min
	temp1_alarm temp1_input temp1_max temp1_min
	temp2_alarm temp2_input temp2_max temp2_min
	temp3_alarm temp3_input temp3_max temp3_min
	temp4_alarm temp4_input temp4_max temp4_min
	temp5_alarm temp5_input temp5_max temp5_min
	temp6_alarm temp6_input temp6_max temp6_min
	temp7_alarm temp7_input temp7_max temp7_min
	temp8_alarm temp8_input temp8_max temp8_min
	temp9_alarm temp9_input temp9_max temp9_min
	pwm1_freq)

vals=(adt7470 cf7f 2000 0 2201 0 82 0 1863 0 82 0 0 0 0 0 0
	0 0 0 4 112 1 96 32000 255 52000 2 104 4 96 32000 255
	52000 2 255 1023 128 90000 255 110000 1 255 1023 128 90000 255 110000 1
	0 0 127000 -127000 0 34000 120000 -123000 0 1000 127000 -127000 0 33000 120000 -123000
	0 1000 127000 -127000 0 0 127000 -127000 0 0 127000 -127000 0 0 127000 -127000
	0 0 127000 -127000 0 0 127000 -127000
	22500)

dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 10)
do
	check_range -b ${base} -d 500 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
done

for f in $(seq 1 4)
do
	check_range -b ${base} -l 1 -u 50000 -d 400 -q fan${f}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 1 -u 50000 -d 400 -q fan${f}_max
	rv=$(($? + ${rv}))
done

for p in $(seq 1 4)
do
	check_range -b ${base} -l 0 -u 255 -r -d 0 -q pwm${p}
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -q pwm${p}_auto_channels_temp
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 255 -r -d 0 -q pwm${p}_auto_point1_pwm
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 255 -r -d 0 -q pwm${p}_auto_point2_pwm
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -q pwm${p}_auto_point1_temp
	rv=$(($? + ${rv}))
done

check_range -b ${base} -d 0 -r -q num_temp_sensors
rv=$(($? + ${rv}))
check_range -b ${base} -d 0 -r -q auto_update_interval
rv=$(($? + ${rv}))
check_range -b ${base} -l 0 -u 1 -d 0 -r -q force_pwm_max
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
