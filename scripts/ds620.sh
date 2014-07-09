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

i2cset -f -y ${adapter} 0x${i2c_addr} 0xac 0x0000 w	# reg_config
i2cset -f -y ${adapter} 0x${i2c_addr} 0xaa 0x0010 w	# temperature sensor
i2cset -f -y ${adapter} 0x${i2c_addr} 0xa2 0x00f8 w	# temp low
i2cset -f -y ${adapter} 0x${i2c_addr} 0xa0 0x0032 w	# temp high

echo ds620 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm)
vals=(32000 100000 0 -16000 0)

dotest attrs[@] vals[@]
rv=$?

check_range -b ${base} -d 50 -q temp1_max
rv=$(($? + ${rv}))
check_range -b ${base} -d 50 -q temp1_min
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
