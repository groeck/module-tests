#!/bin/bash

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x18 >/dev/null 2>&1
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs=(59 05 00 00 88 00 20 00 2f 0d 2b 46 00 00 00 00
	 e0 2e 00 00 3c 00 46 00 50 00 64 50 1e 69 ff ff
	 1d 3c 74 52 78 7a 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 21 49 03
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 59 05 00 00 88 00 60 00 18 0d 27 43 00 00 00 00
	 e0 2e 00 00 3c 00 46 00 50 00 64 50 1e 69 ff ff
	 1d 3c 6c 52 78 7a 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 21 49 03
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x18 $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo amc6821 0x18 > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 0018)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name fan1_div fan1_fault fan1_input fan1_max fan1_min
	pwm1 pwm1_auto_channels_temp pwm1_auto_point1_pwm
	pwm1_auto_point2_pwm pwm1_auto_point3_pwm pwm1_enable
	temp1_auto_point1_temp temp1_auto_point2_temp temp1_auto_point3_temp
	temp1_crit temp1_crit_alarm temp1_input temp1_max temp1_max_alarm
	temp1_min temp1_min_alarm temp2_auto_point1_temp temp2_auto_point2_temp
	temp2_auto_point3_temp temp2_crit temp2_crit_alarm temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm)

vals=(amc6821 2 0 1777 0 500 116 2 0 60 255 2 30000 60000 66000 80000 0 43000 60000
	0 0 0 30000 60000 84000 105000 0 0 70000 80000 0 0 0)

rv=0
dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 1 failed
	rv=1
fi

echo 4 > fan1_div
echo 1000 > fan1_max
echo 100 > fan1_min
echo 100 > pwm1
echo 100 > pwm1_auto_point2_pwm
echo 1 > pwm1_enable

echo 40000 > temp1_auto_point2_temp
echo 50000 > temp1_auto_point3_temp
echo 90000 > temp1_crit
echo 80000 > temp1_max
echo 5000 > temp1_min

echo 81000 > temp2_auto_point1_temp # fails
echo 82000 > temp2_auto_point2_temp
echo 83000 > temp2_auto_point3_temp
# echo 30000  temp2_input BUG!!!
echo 99000 >temp2_crit
echo 95000 >temp2_max
echo 7000 >temp2_min

vals=(amc6821 4 0 1777 1000 100 100 0 0 100 255 1 40000 40000 49000 90000 0 43000
	80000 0 5000 0 40000 80000 84000 99000 0 0 70000 95000 0 7000 0)

dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 2 failed
	rv=1
fi

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
