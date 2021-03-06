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

regs=(
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
	380c b800 0001 0028 0005 0020 0020 0180
)

install_regs ${adapter} ${i2c_addr} regs[@] w

echo lm92 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(name alarms temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_max_hyst temp1_min temp1_min_alarm temp1_min_hyst)

vals=(lm92 0 80000 0 78000 24437 64000 0 62000 10000 0 12000)

dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 1)
do
	check_range -b ${base} -d 50 -r -q -w 2 temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 50 -r -q -w 2 temp${t}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 50 -r -q -w 2 temp${t}_crit
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 50 -r -q -w 2 temp${t}_crit_hyst
	rv=$(($? + ${rv}))
done

modprobe -r i2c-stub 2>/dev/null
modprobe -r lm92

exit ${rv}
