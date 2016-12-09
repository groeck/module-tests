#!/bin/bash

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x2c bank_reg=0x0 bank_mask=0x01 bank_start=0x01 bank_end=0xff
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs00=(00 54 7f f2 45 20 63 00 00 ce db 00 83 94 d2 40
	ff ff ff f8 00 64 2f 02 04 12 30 02 00 10 00 30
	02 81 7d 03 03 03 03 03 00 04 ee 80 f4 32 40 00
	64 00 55 00 55 00 50 00 55 00 64 64 5a 64 64 ff
	00 e8 00 ee 00 bc 00 c8 8c ff ff ff f8 f8 f8 7f
	3f 07 8f bf 3f 00 3f 00 00 00 00 00 00 00 00 00
	ff ff 7f 00 21 00 00 00 44 00 ff ff ff 02 01 01
	7f 84 84 84 53 53 53 80 0a 00 80 00 00 ff ff ff
	3b 3c 4b 5a 5f 00 4c a5 ff ff ff ff ff ff ff ff
	3b 3c 4b 5a 5f 00 4c a5 ff ff ff ff ff ff ff ff
	36 37 43 4f 5f 00 b2 d8 ff ff ff ff ff ff ff ff
	3f b9 00 00 00 00 00 00 00 00 ff ff ff ff 00 0b
	00 00 10 10 00 00 00 39 33 33 ff 00 00 00 40 00
	00 aa 0a 0a 0a 0a 02 f2 81 1e 00 18 07 41 7f 70
	e4 00 00 00 00 00 00 00 00 00 00 00 00 00 10 f0
	00 30 00 ff 00 05 ff ff 20 08 0f 01 ff 50 c3 21)

regs01=(01 91 00 30 00 00 00 00 00 64 64 00 00 00 00 00
	00 00 00 00 00 00 00 f1 fc f8 80 f8 80 f8 80 01
	2b 03 06 00 00 09 00 31 00 f9 00 00 00 00 00 00
	00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff ff
	01 91 00 30 00 00 00 00 00 64 64 00 00 00 00 00
	00 00 00 00 00 00 00 f2 1d f8 80 f8 80 f8 80 01
	2c 01 06 00 00 09 00 6e 00 f9 00 00 00 00 00 00
	00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff ff
	01 91 00 30 00 00 00 00 00 64 64 00 00 00 00 00
	00 00 00 00 00 00 00 f2 1d f8 80 f8 80 f8 80 01
	2c 01 06 00 00 09 00 6e 00 f9 00 00 00 00 00 00
	00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff ff
	01 91 00 30 00 00 00 00 00 64 64 00 00 00 00 00
	00 00 00 00 00 00 00 f2 1d f8 80 f8 80 f8 80 01
	2c 01 06 00 00 09 00 6e 00 f9 00 00 00 00 00 00
	00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff ff)

i=0
while [ $i -lt ${#regs00[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs00[$i]} b
	i=$(($i + 1))
done

i=0
while [ $i -lt ${#regs01[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs01[$i]} b
	i=$(($i + 1))
done

i2cset -y -f ${adapter} 0x2c 0 0	# re-select bank 0

echo nct7802 0x2c > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 002c)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(fan1_alarm fan1_beep fan1_input fan1_min
	fan2_alarm fan2_beep fan2_input fan2_min
	in0_alarm in0_beep in0_input in0_max in0_min
	in1_input
	in3_alarm in3_beep in3_input in3_max in3_min
	in4_alarm in4_beep in4_input in4_max in4_min
	name
	pwm1 pwm1_auto_point1_pwm pwm1_auto_point1_temp pwm1_auto_point2_pwm
	pwm1_auto_point2_temp pwm1_auto_point3_pwm pwm1_auto_point3_temp
	pwm1_auto_point4_pwm pwm1_auto_point4_temp pwm1_auto_point5_pwm
	pwm1_auto_point5_temp pwm1_enable pwm1_mode
	pwm2 pwm2_auto_point1_pwm pwm2_auto_point1_temp pwm2_auto_point2_pwm
	pwm2_auto_point2_temp pwm2_auto_point3_pwm pwm2_auto_point3_temp
	pwm2_auto_point4_pwm pwm2_auto_point4_temp pwm2_auto_point5_pwm
	pwm2_auto_point5_temp pwm2_enable pwm2_mode
	pwm3 pwm3_auto_point1_pwm pwm3_auto_point1_temp pwm3_auto_point2_pwm
	pwm3_auto_point2_temp pwm3_auto_point3_pwm pwm3_auto_point3_temp
	pwm3_auto_point4_pwm pwm3_auto_point4_temp pwm3_auto_point5_pwm
	pwm3_auto_point5_temp pwm3_enable pwm3_mode
	temp1_beep temp1_crit temp1_crit_alarm temp1_fault temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm temp1_type
	temp4_beep temp4_crit temp4_crit_alarm temp4_input temp4_max
	temp4_max_alarm temp4_min temp4_min_alarm
	temp5_beep temp5_crit temp5_crit_alarm temp5_input temp5_max
	temp5_max_alarm temp5_min temp5_min_alarm
	temp6_beep temp6_input)

vals=(0 0 0 0 0 0 0 0 0 0 3300 4092 0 1754 0 0
	1186 1500 0 0 0 1682 1400 0 nct7802 255 0 59000 76 60000 165 75000
	255 90000 255 95000 2 1 255 0 59000 76 60000 165 75000 255 90000 255
	95000 1 1 127 0 54000 178 55000 216 67000 255 79000 255 95000 1 1
	0 100000 0 0 84125 100000 0 0 0 3 0 100000 0 69000 80000 0
	0 0 0 100000 0 99000 85000 1 0 0 0 0)

permissions=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

dotest attrs[@] vals[@] permissions[@]
rv=$?

for p in 1 2 3
do
	check_range -l 0 -u 255 -b ${base} -r -d 0 -q pwm${p}
	rv=$(($? + ${rv}))
	check_range -l 1 -u 2 -b ${base} -r -d 0 -q pwm${p}_enable
	rv=$(($? + ${rv}))
	for a in 1 2 3 4
	do
	    check_range -l 0 -u 255 -b ${base} -r -d 0 -q pwm${p}_auto_point${a}_pwm
	    rv=$(($? + ${rv}))
	done
	for a in 1 2 3 4 5
	do
	    check_range -b ${base} -d 500 -r -q pwm${p}_auto_point${a}_temp
	    rv=$(($? + ${rv}))
	done
done

for t in 1 4 5
do
	check_range -l 0 -u 1 -b ${base} -r -d 0 -q temp${t}_beep
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_min
	rv=$(($? + ${rv}))
done

check_range -l 0 -u 1 -b ${base} -r -d 0 -q temp6_beep
rv=$(($? + ${rv}))

for i in 0 3 4
do
	check_range -b ${base} -l 0 -r -d 0 -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -d 0 -q "in${i}_max"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 1 -r -d 0 -q "in${i}_beep"
	rv=$(($? + ${rv}))
done

for i in $(seq 1 2)
do
	check_range -b ${base} -l 0 -u 1 -r -d 0 -q "fan${i}_beep"
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 445500 -q "fan${i}_min"
	rv=$(($? + ${rv}))
done

modprobe -r i2c-stub 2>/dev/null
modprobe -r nct7802

exit ${rv}
