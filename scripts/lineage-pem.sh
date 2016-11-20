#!/bin/bash

i2c_addr=2c

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x${i2c_addr} functionality=0xffffffff
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

# Note: Requires SMBus block command support in i2c-stub driver

i2cset -y -f ${adapter} 0x${i2c_addr} 0xd0 0 0 0 0 0 0 0 0 0 s # data
i2cset -y -f ${adapter} 0x${i2c_addr} 0xdc 0 0 0 0 s # input string
i2cset -y -f ${adapter} 0x${i2c_addr} 0xdd 11 22 33 44 s	# firmware rev
i2cset -y -f ${adapter} 0x${i2c_addr} 0xdf 0 0 0 0 0 s # fan hi speed
i2cset -y -f ${adapter} 0x${i2c_addr} 0xe0 0 0 0 0 0 s # fan normal speed
i2cset -y -f ${adapter} 0x${i2c_addr} 0xe1 0 0 0 0 0 s # fan speed

echo lineage_pem 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name curr1_alarm fan1_alarm in1_alarm in1_crit_alarm
	in1_input in2_alarm power1_alarm
	temp1_alarm temp1_crit temp1_crit_alarm temp1_fault temp1_input
	temp1_max)

vals=(lineage_pem 0 0 0 0 0 0 0 0 107000 0 0 0 97000)

dotest attrs[@] vals[@]
rv=$?

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
