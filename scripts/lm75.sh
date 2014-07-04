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

regs=(
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
)
i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} w
	i=$(($i + 1))
done

# may be auto-detected
echo lm75 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(temp1_input temp1_max temp1_max_hyst)

vals=(28000 80000 75000)

dotest attrs[@] vals[@]
rv=$?

check_range -b ${base} -s 100 -d 200 -r -q temp1_max
rv=$(($? + ${rv}))
check_range -b ${base} -s 100 -d 200 -r -q temp1_max_hyst
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
