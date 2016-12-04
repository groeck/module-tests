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
i2cset -f -y ${adapter} 0x3f 0x1 0x0000 w
i2cset -f -y ${adapter} 0x3f 0x2 0x004b w
i2cset -f -y ${adapter} 0x3f 0x3 0x0050 w
i2cset -f -y ${adapter} 0x3f 0x4 0xc0ff w
i2cset -f -y ${adapter} 0x3f 0x5 0x0000 w
i2cset -f -y ${adapter} 0x3f 0x6 0xc071 w
i2cset -f -y ${adapter} 0x3f 0x7 0xc071 w

echo ad7418 0x3f > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 003f)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name in1_input temp1_input temp1_max temp1_max_hyst)
vals=(ad7418 2498 46000 80000 75000)

rv=0
dotest attrs[@] vals[@]
if [ $? -ne 0 ]
then
	echo value test 1 failed
	rv=1
fi

check_range -b ${base} -d 200 -s 100 -q temp1_max
check_range -b ${base} -d 200 -s 100 -q temp1_max_hyst

modprobe -r i2c-stub 2>/dev/null
modprobe -r ad7418

exit ${rv}
