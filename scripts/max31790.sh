#!/bin/bash

i2c_addr=20

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
	bb27 40bb 4040 4040 4040 4040 4040 4c40
	4c4c 4c4c 4c4c 4c4c 4c4c 004c 0000 0000
	0000 3f00 3f3f 453f 0045 0000 0000 ff00
	e0ff ffe0 e0ff ffe0 e0ff ffe0 e0ff ffe0
	e0ff ffe0 e0ff ffe0 e0ff ffe0 e0ff ffe0
	e0ff ffe0 e0ff ffe0 e0ff ffe0 e0ff 80e0
	0080 8000 0080 8000 0080 8000 0080 8000
	0080 8000 0080 0000 0000 0000 0000 8000
	0080 8000 0080 8000 0080 8000 0080 8000
	0080 8000 0080 0000 0000 0000 0000 3c00
	003c 3c00 003c 3c00 003c 3c00 003c 3c00
	003c 3c00 003c 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 ff00
	ffff ffff ffff ffff ffff ffff ffff ffff
	ffff ffff ffff ffff ffff ffff ffff 00ff
	0000 0000 0000 0000 0000 0000 0000 ff00
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
	ffff ffff ffff ffff ffff ffff ffff 27ff
)

install_regs ${adapter} ${i2c_addr} regs[@] w

echo max31790 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

pushd ${base}

attrs=(fan1_fault fan1_input fan1_target
	fan2_fault fan2_input fan2_target
	fan3_fault fan3_input fan3_target
	fan4_fault fan4_input fan4_target
	fan5_fault fan5_input fan5_target
	fan6_fault fan6_input fan6_target
	name
	pwm1 pwm1_enable pwm2 pwm2_enable
	pwm3 pwm3_enable pwm4 pwm4_enable
	pwm5 pwm5_enable pwm6 pwm6_enable)

vals=(0 480 2048
	0 480 2048
	0 480 2048
	0 480 2048
	0 480 2048
	0 480 2048
	max31790
	128 0 128 0
	128 0 128 0
	128 0 128 0)

dotest attrs[@] vals[@]
rv=$?

for f in $(seq 1 6)
do
	check_range -b ${base} -l 120 -u 7864320 -d 3932160 -r -w 2 fan${f}_target
	rv=$(($? + ${rv}))
done

for p in $(seq 1 6)
do
	check_range -b ${base} -l 0 -u 2 -r -w 2 pwm${p}_enable
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 255 -d 0 -r -w 2 pwm${p}
	rv=$(($? + ${rv}))
done

popd

modprobe -r max31790

i2cset -f -y ${adapter} 0x${i2c_addr} 0x02 0x41 b

modprobe max31790

base=$(getbase ${adapter} 00${i2c_addr})

cd ${base}
ls -l

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
