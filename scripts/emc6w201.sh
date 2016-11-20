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

regs=(00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	8c a1 c2 c4 c1 00 36 00 00 00 30 2c 10 0d ff ff
	cc 09 ff ff ff ff 3f 47 6f 00 00 00 00 00 5c b1
	05 0d 0d 00 00 00 00 ec 1a 04 7e 98 64 da b3 cd
	b3 cd b3 cd 64 da 81 58 81 58 81 3c 81 37 81 4b
	81 50 50 46 50 46 78 69 f0 ff f0 ff 04 3f 00 ff
	00 ff 00 ff 00 ff 00 ff 00 ff ed 1a 04 00 00 00
	a9 a9 49 99 90 cc ff fa e8 88 3f 47 6f 00 00 00
	40 40 2f 2f 2f 2d 7f 7f 7f 7f 7f 7f 20 02 02 a4
	28 69 db 00 0d 0d 04 04 2f 2f 2f 01 1f 00 62 7f
	7f 7f 7f 7f 00 00 00 80 00 00 00 00 00 00 00 00
	00 80 40 00 7f 7f 7f 7f 7f 7f 00 00 00 00 00 00
	00 ff ff ff ff ff ff ff ff ff ff 6f ff ff ff ff
	00 0a a0 2a e6 00 40 00 18 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo emc6w201 0x2c > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 002c)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name fan1_input fan1_min fan2_input fan2_min fan3_input
	fan3_min fan4_input fan4_min fan5_input fan5_min
	in0_input in0_max in0_min in1_input in1_max in1_min
	in2_input in2_max in2_min in3_input in3_max in3_min
	in4_input in4_max in4_min in5_input in5_max in5_min
	temp1_input temp1_max temp1_min temp2_input temp2_max temp2_min
	temp3_input temp3_max temp3_min temp4_input temp4_max temp4_min
	temp5_input temp5_max temp5_min temp6_input temp6_max temp6_min)

vals=(emc6w201 1614 300 0 300 2153 200 0 82 0 82 1822 1979 1640 1257 1703 781 3334
	3523 3076 5104 5338 4661 1507 1601 1398 0 1703 781 54000 88000 -127000
	0 88000 -127000 0 60000 -127000 0 55000 -127000 48000 75000 -127000
	44000 80000 -127000)

rv=0
dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 6)
do
	check_range -b ${base} -d 500 -r -q -w 2 temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q -w 2 temp${t}_max
	rv=$(($? + ${rv}))
done

for i in $(seq 0 5)
do
	check_range -b ${base} -d 13 -r -q -w 2 "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 13 -r -q -w 2 "in${i}_max"
	rv=$(($? + ${rv}))
done

for f in $(seq 1 5)
do
	check_range -b ${base} -l 0 -u 10000 -d 9 -r -q -w 2 "fan${f}_min"
	rv=$(($? + ${rv}))
done

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
