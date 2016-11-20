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

regs=(b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1
	b1 b1 b1 b1 b1 00 00 00 00 ff ff ff ff ff ff ff
	74 8f c2 c7 c5 b7 b6 21 60 ff ff 7e 69 97 82 ca
	b6 ca b6 d3 ad ba a0 a0 a0 32 2d 8c ff ff 23 02
	01 00 00 00 00 00 00 b1 2d 80 80 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 00 00 00 00 ff ff ff ff ff ff ff
	74 8f c2 c7 c5 b7 b6 21 60 ff ff 7e 69 97 82 ca
	b6 ca b6 d3 ad ba a0 a0 a0 32 2d 8c ff ff 23 02
	01 00 00 00 00 00 00 b1 2d 80 80 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adm9240 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarms aout_output cpu0_vid
	fan1_alarm fan1_div fan1_input fan1_min
	fan2_alarm fan2_div fan2_input fan2_min
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	intrusion0_alarm
	temp1_alarm temp1_input temp1_max temp1_max_hyst
	)

vals=(adm9240 0 1250 0 0 8 1758 1205 0 4 0 0 0 1510 1641 1367 0
	2011 2123 1828 0 3334 3472 3128 0 5182 5260 4740 0 12313 13188 10813 0
	2573 2616 2250 0 0 33000 50000 45000
	)

rv=0
dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

for i in $(seq 0 5)
do
	check_range -b ${base} -d 31 -r -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 31 -r -q "in${i}_max"
	rv=$(($? + ${rv}))
done

for i in $(seq 1 1)
do
	check_range -b ${base} -d 500 -r -q temp${i}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${i}_max_hyst
	rv=$(($? + ${rv}))
done

for i in $(seq 1 2)
do
	check_range -b ${base} -l 0 -u 20000 -d 500 -r -q fan${i}_min
	rv=$(($? + ${rv}))
done

check_range -b ${base} -r -q -d 2 aout_output
rv=$(($? + ${rv}))

check_range -b ${base} -l 0 -u 0 -d 0 -r -q intrusion0_alarm
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
