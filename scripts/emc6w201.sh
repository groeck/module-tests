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

attrs=(fan1_input fan1_min fan2_input fan2_min fan3_input
	fan3_min fan4_input fan4_min fan5_input fan5_min
	in0_input in0_max in0_min in1_input in1_max in1_min
	in2_input in2_max in2_min in3_input in3_max in3_min
	in4_input in4_max in4_min in5_input in5_max in5_min
	temp1_input temp1_max temp1_min temp2_input temp2_max temp2_min
	temp3_input temp3_max temp3_min temp4_input temp4_max temp4_min
	temp5_input temp5_max temp5_min temp6_input temp6_max temp6_min)

vals=(1614 300 0 300 2153 200 0 82 0 82 1822 1979 1640 1257 1703 781 3334
	3523 3076 5104 5338 4661 1507 1601 1398 0 1703 781 54000 88000 -127000
	0 88000 -127000 0 60000 -127000 0 55000 -127000 48000 75000 -127000
	44000 80000 -127000)

rv=0
dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 1 failed
	rv=1
fi

echo 100 > fan1_min
echo 200 > fan2_min
echo 300 > fan3_min
echo 400 > fan4_min
echo 500 > fan5_min

echo 2000 > in0_max
echo 2100 > in1_max
echo 2200 > in2_max
echo 2300 > in3_max
echo 2400 > in4_max
echo 2500 > in5_max

echo 100 > in0_min
echo 200 > in1_min
echo 300 > in2_min
echo 400 > in3_min
echo 500 > in4_min
echo 600 > in5_min

echo 80000 > temp1_max
echo 81000 > temp2_max
echo 82000 > temp3_max
echo 83000 > temp4_max
echo 84000 > temp5_max
echo 85000 > temp6_max

echo 10000 > temp1_min
echo 11000 > temp2_min
echo 12000 > temp3_min
echo 13000 > temp4_min
echo 14000 > temp5_min
echo 15000 > temp6_min

vals=(1614 100 0 200 2153 300 0 400 0 500 1822 2005 104 1257 1992 203 3334
	2200 292 5104 2291 390 1507 1992 500 0 1992 601 54000 80000 10000 0
	81000 11000 0 82000 12000 0 83000 13000 48000 84000 14000 44000 85000
	15000)

dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 2 failed
	rv=1
fi

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
