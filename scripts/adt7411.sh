#!/bin/bash

i2c_addr=48

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

regs=(00 0c 00 0a f9 0e 93 19 01 5d ff ff 5d 06 00 00
	00 00 00 00 00 00 00 00 09 40 18 00 00 00 00 00
	00 d8 d8 c7 62 64 c9 ff 00 00 00 ff 00 ff 00 ff
	00 ff 00 ff 00 ff 00 ff 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 02 41 04
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 e9 ed 00 00 00 02
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adt7411 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name adc_ref_vdd fast_sampling
	in0_input in1_input in2_input in3_input
	in4_input in5_input in6_input in7_input in8_input
	no_average temp1_input
)

vals=(adt7411 1 0 4033 19 1472 4029 4029 1472 106 0 0 0 25500)

permissions=(
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

dotest attrs[@] vals[@] permissions[@]
rv=$?

check_range -b ${base} -l 0 -u 1 -d 0 -r -q fast_sampling
rv=$(($? + ${rv}))
check_range -b ${base} -l 0 -u 1 -d 0 -r -q no_average
rv=$(($? + ${rv}))
check_range -b ${base} -l 0 -u 1 -d 0 -r -q no_average
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
