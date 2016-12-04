#!/bin/bash

i2c_addr=3f

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

i2cset -f -y ${adapter} 0x${i2c_addr} 0x0 0x7f b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x1 0x80 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x2 0x00 b

echo g760a 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name fan1_alarm fan1_input pwm1)
vals=(g760a 0 3840 128)

dotest attrs[@] vals[@]
rv=$?

modprobe -r i2c-stub 2>/dev/null
modprobe -r g760a

exit ${rv}
