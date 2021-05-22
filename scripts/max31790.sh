#!/bin/bash

i2c_addr=20

dir=$(dirname $0)
. ${dir}/common.sh

fixup_writeattr()
{
    local attr="${1##*/}"
    local value="$2"
    local index
    local reg

    # Writes into pwm attributes are written into registers 0x40..0x4a
    # but read back from 0x30..0x3a.
    case "${attr}" in
    "pwm1"|"pwm2"|"pwm3"|"pwm4"|"pwm5"|"pwm6")
	index="$((${attr//pwm/} - 1))"
	reg="$((index * 2 + 0x30))"
	i2cset -f -y ${adapter} 0x${i2c_addr} ${reg} ${value}
	;;
    *)
	;;
    esac
}

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x${i2c_addr}
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs=(	27 bb 48 48 48 48 48 48
	4c 4c 4c 4c 4c 4c 00 00
	00 00 3f 3f 45 00 00 00
	20 00 40 00 60 00 80 00
	a0 00 ff e0 10 e0 20 e0
	30 e0 40 e0 50 e0 ff e0
	80 00 80 00 80 00 80 00
	80 00 80 00 00 00 00 00
	80 00 80 00 80 00 80 00
	80 00 80 00 00 00 00 00
	3c 00 3c 00 3c 00 3c 00
	3c 00 3c 00 00 00 00 00
	00 00 00 00 00 00 00 00
)

install_regs ${adapter} ${i2c_addr} regs[@] b

# i2cdump -y -f ${adapter} 0x${i2c_addr} b

echo max31790 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

base=$(getbase ${adapter} 00${i2c_addr})
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

pushd ${base} >/dev/null

attrs=(fan1_enable fan1_fault fan1_input fan1_target
	fan2_enable fan2_fault fan2_input fan2_target
	fan3_enable fan3_fault fan3_input fan3_target
	fan4_enable fan4_fault fan4_input fan4_target
	fan5_enable fan5_fault fan5_input fan5_target
	fan6_enable fan6_fault fan6_input fan6_target
	name
	pwm1 pwm1_enable pwm2 pwm2_enable
	pwm3 pwm3_enable pwm4 pwm4_enable
	pwm5 pwm5_enable pwm6 pwm6_enable)

vals=(1 0 3840 2048
	1 0 1920 2048
	1 0 1280 2048
	1 0 960 2048
	1 0 768 2048
	1 0 0 2048
	max31790
	128 1 128 1
	128 1 128 1
	128 1 128 1)

dotest attrs[@] vals[@]
rv=$?

for f in $(seq 1 6)
do
	check_range -b ${base} -l 0 -u 1 -r -w 2 fan${f}_enable
	rv=$(($? + ${rv}))
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

# Registers 0x18 .. 0x2e are volatile, but nonlinear. Check value change only.
# There is a total of 12 fanX_input attributes, but only 6 are active for
# the given configuration.

for index in $(seq 1 6); do
    reg=$((0x16 + (index * 2)))
    check_volatile -c "${adapter}" "${i2c_addr}" "${reg}" b 0x10 0xff 0x10 "fan${index}_input"
    rv=$(($? + ${rv}))
done
# Registers 0x30 .. 0x3a are 16-bit pwm duty cycle registers.
for index in $(seq 1 6); do
    reg=$((0x2e + (index * 2)))
    check_volatile "${adapter}" "${i2c_addr}" ${reg} b 0x10 0xff 0x10 "pwm${index}" 16 16
    rv=$(($? + ${rv}))
done

popd >/dev/null

modprobe -r max31790

# Reconfigure the chip to monitor 12 fan speeds instead of 6 fan speeds
# and 6 pwm controls
regs=(	27 bb 49 49 49 49 49 49
	4c 4c 4c 4c 4c 4c 00 00
	00 00 3f 3f 45 00 00 00
	20 00 40 00 60 00 80 00
	a0 00 ff e0 10 e0 20 e0
	30 e0 40 e0 50 e0 ff e0
	80 00 80 00 80 00 80 00
	80 00 80 00 00 00 00 00
	80 00 80 00 80 00 80 00
	80 00 80 00 00 00 00 00
	3c 00 3c 00 3c 00 3c 00
	3c 00 3c 00 00 00 00 00
	00 00 00 00 00 00 00 00
)

install_regs ${adapter} ${i2c_addr} regs[@] b

modprobe max31790

base=$(getbase ${adapter} 00${i2c_addr})
pushd ${base} >/dev/null

attrs=(fan1_enable fan1_fault fan1_input
	fan2_enable fan2_fault fan2_input
	fan3_enable fan3_fault fan3_input
	fan4_enable fan4_fault fan4_input
	fan5_enable fan5_fault fan5_input
	fan6_enable fan6_fault fan6_input
	fan7_fault fan7_input fan8_fault fan8_input
	fan9_fault fan9_input fan10_fault fan10_input
	fan11_fault fan11_input fan12_fault fan12_input
	name)

vals=(1 0 3840 1 0 1920 1 0 1280 1 0 960 1 0 768 1 0 0
	0 7281 0 3737 0 2514 0 1894 0 1519 0 0
	max31790)

dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

# check all 12 fan input attributes
for index in $(seq 1 12); do
    reg=$((0x16 + (index * 2)))
    check_volatile -c "${adapter}" "${i2c_addr}" "${reg}" b 0x10 0xff 0x10 "fan${index}_input"
    rv=$(($? + ${rv}))
done

popd >/dev/null

modprobe -r i2c-stub 2>/dev/null
modprobe -r max31790

exit ${rv}
