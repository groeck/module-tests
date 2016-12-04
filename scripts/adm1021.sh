#!/bin/bash

i2c_addr=18

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

# max1617
regs=(13 15 20 00 04 3c 14 3c 14)
i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo max1617 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarms low_power temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm)

vals=(max1617 32 0 19000 60000 0 20000 1 0 21000 60000 0 20000 0)

rv=0
dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

check_range -b ${base} -l 0 -u 1 -d 0 -r -q low_power
rv=$(($? + ${rv}))

for i in $(seq 1 2)
do
	check_range -b ${base} -s 1000 -d 0 -r -q temp${i}_min
	rv=$(($? + ${rv}))
	echo -127000 > temp${i}_min
	check_range -b ${base} -s 1000 -d 0 -r -q temp${i}_max
	rv=$(($? + ${rv}))
done

echo 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/delete_device

# max1617a
regs=(1e 1c 00 00 04 7f c9 7f c9 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 4d 01)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo max1617a 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarms low_power temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm)

vals=(max1617a 0 0 30000 127000 0 -55000 0 0 28000 127000 0 -55000 0)

dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

check_range -b ${base} -l 0 -u 1 -d 0 -r -q low_power
rv=$(($? + ${rv}))

for i in $(seq 1 2)
do
	check_range -b ${base} -s 1000 -d 0 -r -q temp${i}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -s 1000 -d 0 -r -q temp${i}_max
	rv=$(($? + ${rv}))
done

modprobe -r i2c-stub 2>/dev/null
modprobe -r adm1021

exit ${rv}
