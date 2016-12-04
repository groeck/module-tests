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

i2cset -f -y ${adapter} 0x${i2c_addr} 0xe3 0x1080 w	# temperature
i2cset -f -y ${adapter} 0x${i2c_addr} 0xe5 0x1050 w	# humidity

echo sht21 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name humidity1_input temp1_input)
vals=(sht21 33093 41052)

error_test ${adapter} attrs[@]
rv=$?

dotest attrs[@] vals[@]
rv=$((${rv} + $?))

modprobe -r i2c-stub 2>/dev/null
modprobe -r sht21

exit ${rv}
