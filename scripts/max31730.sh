#!/bin/bash

i2c_addr=1c

dir=$(dirname $0)
. ${dir}/common.sh

driver="max31730"

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x${i2c_addr}
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs=(
	7017 1770 6017 1760 a017 17a0 3017 ff30 
	ffff ffff ffff ffff ffff ffff ffff 17ff 
	b017 ffb0 10ff 1810 0018 7700 0077 0000 
	0000 0000 0000 0000 ff00 ffff ffff 7fff 
	007f 7f00 007f 7f00 007f 7f00 007f ff00 
	ffff ffff ffff ffff ffff ffff ffff c9ff 
	00c9 0000 0000 0000 0f00 000f ff00 ffff 
	ffff ffff ffff ffff ffff ffff ffff 00ff 
	0000 0000 0000 0000 0000 0000 0000 ff00 
	ffff ffff ffff ffff ffff ffff ffff 4dff 
	014d ff01 ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff ffff 
	ffff ffff ffff ffff ffff ffff ffff 17ff 
)

install_regs ${adapter} ${i2c_addr} regs[@] w

echo ${driver} 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

pushd ${base}

attrs=(name
	temp1_enable temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_enable temp2_fault temp2_input temp2_max
	temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	temp3_enable temp3_fault temp3_input temp3_max
	temp3_max_alarm temp3_min temp3_min_alarm temp3_offset
	temp4_enable temp4_fault temp4_input temp4_max
	temp4_max_alarm temp4_min temp4_min_alarm temp4_offset
)

vals=(max31730
	1 23438 127000 0 -55000 0 1 0
	23375 127000 0 -55000 0 0 1 0
	23625 127000 0 -55000 0 0 1 0
	23188 127000 0 -55000 0 0)

dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 4)
do
	check_range -b ${base} -r temp${t}_max
	rv=$(($? + ${rv}))
	if [[ ${t} -eq 1 ]]; then
	    check_range -b ${base} temp${t}_min
	    rv=$(($? + ${rv}))
	fi
	check_range -b ${base} -l 0 -u 1 -r temp${t}_enable
	rv=$(($? + ${rv}))
	if [[ ${t} -ne 1 ]]; then
	    check_range -b ${base} temp${t}_offset
	    rv=$(($? + ${rv}))
	fi
done

modprobe -r ${driver}

exit ${rv}
