#!/bin/bash

i2c_addr=4c

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

regs=(19 19 19 45 ff ff ff ff 80 00 1c 07 ff ff ff 01
	00 01 00 10 ff ff ff ff ff ff ff ff ff ff ff ff
	ff 00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff 55 21
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo tmp421 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(temp1_input temp2_fault temp2_input)
vals=(25000 1 25000)
dotest attrs[@] vals[@]
rv=$?

echo 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/delete_device
i2cset -y -f ${adapter} 0x${i2c_addr} 0xff 0x22 b	# tmp422
echo tmp422 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

cd ${base}

attrs=(temp1_input temp2_fault temp2_input temp3_fault temp3_input)
vals=(25000 1 25000 0 25000)
dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

echo 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/delete_device
i2cset -y -f ${adapter} 0x${i2c_addr} 0xff 0x23 b	# tmp423
echo tmp423 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

cd ${base}

attrs=(temp1_input temp2_fault temp2_input temp3_fault temp3_input temp4_fault temp4_input)
vals=(25000 1 25000 0 25000 0 69063)
dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
