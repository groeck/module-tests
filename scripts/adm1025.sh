#!/bin/bash

i2c_addr=2c

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

regs=(5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 00 5b 5b 5b 5b 5b 5b 5b 5b 5b 00
	c0 7d c6 c1 c2 c6 23 21 5b 5b 5b d3 ad 84 78 d3
	ad d3 ad d3 ad d3 ad 3c 0a 2d 0a 5b 5b 5b 41 29
	09 00 00 5b 5b 5b 5b 0c 5b 80 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 00 5b 5b 5b 5b 5b 5b 5b 5b 5b 00
	c0 7d c6 c1 c2 c6 23 21 5b 5b 5b d3 ad 84 78 d3
	ad d3 ad d3 ad d3 ad 3c 0a 2d 0a 5b 5b 5b 41 29
	09 00 00 5b 5b 5b 5b 0c 5b 80 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b
	5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b 5b
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adm1025 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(alarms cpu0_vid in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	temp1_alarm temp1_fault temp1_input temp1_max temp1_min
	temp2_alarm temp2_input temp2_max temp2_min
	vrm)

vals=(0 1538 0 2500 2747 2253 0 1465 1547 1406 0 3403 3627 2973 0 5026
	5495 4505 0 12125 13188 10813 0 3403 3627 2973 0 0 35000 60000 10000
	0 33000 45000 10000 110)

rv=0
dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

for i in $(seq 1 5)
do
	check_range -b ${base} -d 31 -r -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 31 -r -q "in${i}_max"
	rv=$(($? + ${rv}))
done

for i in $(seq 1 2)
do
	check_range -b ${base} -d 500 -r -q temp${i}_min
	rv=$(($? + ${rv}))
	echo -127000 > temp${i}_min
	check_range -b ${base} -d 500 -r -q temp${i}_max
	rv=$(($? + ${rv}))
done

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
