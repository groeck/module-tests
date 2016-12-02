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

regs=(
	00 00 00 00 18 7f f4 ff a0 00 00 00 00 00 00 00 
	02 00 f4 ff ca 00 00 00 00 00 00 00 00 00 02 03 
	00 00 00 01 01 01 01 01 01 01 01 01 01 00 00 00 
	01 01 01 05 05 04 04 05 04 84 84 04 04 84 00 05 
	05 05 04 05 04 05 04 84 84 00 00 00 94 09 08 57 
	00 00 00 00 ff ff 01 01 60 55 ba 00 45 03 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo smsc47m192 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name cpu0_vid
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in6_alarm in6_input in6_max in6_min
	in7_alarm in7_input in7_max in7_min
	temp1_alarm temp1_input temp1_max temp1_min temp1_offset
	temp2_alarm temp2_fault temp2_input temp2_max temp2_min temp2_offset
	temp3_alarm temp3_fault temp3_input temp3_max temp3_min temp3_offset
	vrm
)

vals=(smsc47m192 1588 1 0 13 13 0 0 0 0 1 0 0 17 0 26 26
	26 0 63 313 313 0 17 69 69 1 0 1992 1992 0 0 9
	9 0 1000 -124000 -124000 3000 0 0 1000 5000 4000 0 0 0 0 96000
	85000 2000 110
)

dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 3)
do
	check_range -b ${base} -d 500 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_offset
	rv=$(($? + ${rv}))
done

for i in $(seq 0 7)
do
	check_range -b ${base} -d 32 -r -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 32 -r -q "in${i}_max"
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 0 -u 255 -r -d 0 -q vrm
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null
modprobe -r smsc47m192

exit ${rv}
