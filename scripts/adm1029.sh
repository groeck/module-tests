#!/bin/bash

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x2f >/dev/null 2>&1
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs=(a0 10 03 01 7f 04 03 00 00 00 51 00 03 41 02 00
	00 05 51 51 51 51 51 51 3a 10 51 51 51 51 51 51
	ff ff 51 51 51 51 51 51 00 00 04 00 00 00 00 51
	00 00 00 51 51 51 51 51 00 00 00 00 00 00 00 51
	08 08 80 51 51 51 51 51 03 03 03 51 51 51 51 51
	00 80 51 51 51 51 51 51 00 00 51 51 51 51 51 51
	f0 f0 51 51 51 51 51 51 af af 51 51 51 51 51 51
	ff 00 51 51 51 51 51 51 ff ff 51 51 51 51 51 51
	2b 37 ff 51 51 51 51 51 f0 f0 f0 51 51 51 51 51
	3c 46 ff 51 51 51 51 51 37 41 ff 51 51 51 51 51
	19 23 80 51 51 51 51 51 ff ff 51 51 51 51 51 51
	00 00 51 51 51 51 51 51 06 00 51 51 51 51 51 51
	51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
	51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
	51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
	51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x2f $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adm1029 0x2f > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 002f)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name fan1_div fan1_input fan1_min fan2_div fan2_input fan2_min temp1_input
	temp1_max temp1_min temp2_input temp2_max temp2_min temp3_input
	temp3_max temp3_min)
vals=(adm1029 2 0 0 2 0 0 25000 60000 55000 35000 70000 65000 -128000 -1000 -1000)

rv=0
dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 1 failed
	rv=1
fi

values=(1 2 4)
failvals=(-1 0 8)
check_values ${base} fan1_div values[@] failvals[@]
rv=$?

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
