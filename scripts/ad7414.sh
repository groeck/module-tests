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

i2cset -f -y ${adapter} 0x3f 0x0 0x402e w
i2cset -f -y ${adapter} 0x3f 0x1 0x00 b
i2cset -f -y ${adapter} 0x3f 0x2 0x64 b
i2cset -f -y ${adapter} 0x3f 0x3 0x10 b

echo ad7414 0x3f > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 003f)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm)
vals=(ad7414 46250 100000 0 16000 0)

rv=0
dotest attrs[@] vals[@]
rv=$?

check_range -b ${base} -d 500 -s 100 -q temp1_max
rv=$((${rv} + $?))
check_range -b ${base} -d 500 -s 100 -q temp1_min
rv=$((${rv} + $?))

modprobe -r i2c-stub 2>/dev/null
modprobe -r ad7414

exit ${rv}
