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

regs=(00 02 00 00 00 00 00 02 00 50 00 00 00 00 00 00 
	00 00 00 01 05 00 04 02 00 64 a4 02 00 08 0c 04 
	b0 b0 cb be c7 d9 d3 1c ff 7b ff b5 a9 b5 a9 d8 
	c4 c3 b0 cf bb e2 cc da c5 28 26 ff 8d 00 00 00 
	01 00 08 ff 7f 00 40 61 2d 00 00 00 00 00 00 00 
	01 00 00 ff 7f 00 40 61 2d 00 00 00 00 00 00 00 
	b0 b0 cb be c7 d9 d3 1c ff 7b ff b5 a9 b5 a9 d8 
	c4 c3 b0 cf bb e2 cc da c5 28 26 ff 8d 00 00 00 
	00 02 00 00 00 00 00 02 00 50 00 00 00 00 00 00 
	00 00 00 01 05 00 04 02 00 64 a4 02 00 08 0c 04 
	b0 b0 cb be c7 d9 d3 1c ff 7b ff b5 a9 b5 a9 d8 
	c4 c3 b0 cf bb e2 cc da c5 28 26 ff 8d 00 00 00 
	01 00 00 ff 7f 00 40 61 2d 00 00 00 00 00 00 00 
	01 00 00 ff 7f 00 40 61 2d 00 00 00 00 00 00 00 
	b0 b0 cb be c7 d9 d3 1c ff 7b ff b5 a9 b5 a9 d8 
	c4 c3 b0 cf bb e2 cc da c5 28 26 ff 8d 00 00 00 
)

install_regs ${adapter} ${i2c_addr} regs[@]

echo lm78 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarms cpu0_vid
	fan1_alarm fan1_div fan1_input fan1_min
	fan2_alarm fan2_div fan2_input fan2_min
	fan3_alarm fan3_div fan3_input fan3_min
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in6_alarm in6_input in6_max in6_min
	temp1_alarm temp1_input temp1_max temp1_max_hyst
)

vals=(lm78 2048 3400 0 4 0 0 0 2 5487 4787 1 2 0 -1 0 2816
	2896 2704 0 2816 2896 2704 0 3248 3456 3136 0 3040 3120 2816 0 3184
	3312 2992 0 3472 3616 3264 0 3376 3488 3152 0 28000 40000 38000
	) 

dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 1)
do
	check_range -b ${base} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max_hyst
	rv=$(($? + ${rv}))
done

for f in $(seq 1 3)
do
	check_range -b ${base} -l 0 -u 20000 -d 2500 -q fan${f}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 1 -u 2 -d 0 -q fan${t}_div
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 4 -u 4 -d 0 -q fan${t}_div
	rv=$(($? + ${rv}))
done

for i in $(seq 0 6)
do
	check_range -b ${base} -r -q -d 8 "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -r -q -d 8 "in${i}_max"
	rv=$(($? + ${rv}))
done

modprobe -r i2c-stub 2>/dev/null
modprobe -r lm78

exit ${rv}
