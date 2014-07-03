#!/bin/bash

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x3f
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

i2cset -f -y ${adapter} 0x3f 0xe3 0x0060 w
i2cset -f -y ${adapter} 0x3f 0xe5 0x0050 w

echo htu21 0x3f > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 003f)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(humidity1_input temp1_input)
vals=(33062 19045)

rv=0
dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test failed
	rv=1
fi

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
