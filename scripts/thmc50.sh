#!/bin/bash

i2c_addr=2e

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

i2cset -f -y ${adapter} 0x${i2c_addr} 0x13 0x4e b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x14 0x4e b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x15 0x00 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x17 0x64 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x18 0x64 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x19 0x00 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x20 0x20 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x26 0x27 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x27 0x37 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x2b 0x35 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x2c 0x81 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x37 0x35 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x38 0x81 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x39 0x35 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x3a 0x81 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x3e 0x49 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x3f 0xd2 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x40 0x2b b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x41 0x10 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x43 0x96 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x4b 0x00 b
i2cset -f -y ${adapter} 0x${i2c_addr} 0x4c 0x02 b

echo thmc50 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(pwm1 pwm1_mode
	temp1_alarm temp1_crit temp1_input temp1_max temp1_min
	temp2_alarm temp2_crit temp2_fault temp2_input temp2_max temp2_min
	)

vals=(1 0 0 78000 55000 53000 -127000 0 78000 0 39000 53000 -127000)

dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 2)
do
	check_range -b ${base} -d 1000 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 1000 -r -q temp${t}_max
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 0 -u 255 -d 0 -r -q pwm1
rv=$(($? + ${rv}))

if [ ${rv} -ne 0 ]
then
	exit ${rv}
fi

echo 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/delete_device 2>/dev/null

# Now test with adm1022 register set

regs=(ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff 5a 5a 02 ff 46 64 01 ff ff ff ff ff ff
	21 ff ff ff ff ff 20 25 ff ff ff 7f 00 ff ff ff
	ff ff ff ff ff ff ff 7f 00 7f 80 ff ff ff 41 c9
	ad 00 ff d5 04 ff ff 50 ff ff 01 ff 00 ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff 5a 5a 02 ff 46 64 01 ff ff ff ff ff ff
	21 ff ff ff ff ff 20 25 ff ff ff 7f 00 ff ff ff
	ff ff ff ff ff ff ff 7f 00 7f 80 ff ff ff ff c9
	ad 00 ff d5 04 ff ff 50 ff ff 01 ff 00 ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

echo adm1022 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(pwm1 pwm1_mode
	temp1_alarm temp1_crit temp1_input temp1_max temp1_min
	temp2_alarm temp2_crit temp2_fault temp2_input temp2_max temp2_min
	temp3_alarm temp3_crit temp3_fault temp3_input temp3_max temp3_min
	)

vals=(1 0 0 90000 37000 127000 -128000 0 90000 0 32000 127000 0 0 90000 0
	33000 127000 0)

dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 3)
do
	check_range -b ${base} -d 1000 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 1000 -r -q temp${t}_max
	rv=$(($? + ${rv}))
done

check_range -b ${base} -l 0 -u 255 -d 0 -r -q pwm1
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
