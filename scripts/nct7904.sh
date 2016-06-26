#!/bin/bash

dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x2c bank_reg=0xff bank_mask=0x07 bank_start=0x00 bank_end=0xfe
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

regs00=(31 43 ff ff ff ff ff ff 00 01 00 ff 5c 50 c5 51
	ff ff ff ff ff ff ff ff 00 00 ff ff ff ff ff ff
	40 d5 03 00 fb 00 0f 0f 0f ff 02 0a 00 02 00 00
	00 00 00 a0 00 00 68 2a ef 50 00 44 00 db 09 73
	29 07 00 00 00 00 00 00 00 00 00 00 44 03 00 00
	73 01 00 00 32 03 00 00 38 03 00 00 46 00 46 00
	46 01 23 02 00 00 00 00 00 00 ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff 50 c5 51 ff ff ff
	ff 1f ff 1f ff 1f ff 1f ff 1f ff 1f ff 1f ff 1f
	ff 1f ff 1f 00 00 00 00 ff ff ff ff ff ff ff ff
	2c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 ff ff ff ff 00 00 00 00 00 00 00 00
	10 ff ff 1d 00 ff 03 00 00 00 40 ff ff 1f 01 ff
	0f 0f 0f 0f 4f ff 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 ff ff 60 7f 00 00 00 0f 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 ff 00)

regs01=(ff 07 00 00 ff 07 00 00 ff 07 00 00 ff 07 00 00
	ff 07 00 00 ff 07 00 00 ff 07 00 00 ff 07 00 00
	ff 07 00 00 ff 07 00 00 ff 07 00 00 ff 07 00 00
	ff 07 00 00 ff 07 00 00 ff 07 00 00 ff 07 00 00
	ff 07 00 00 64 5f 55 50 ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff 1f ff 1f ff 1e ff 1e ff 1e ff 1e ff 1e ff 1e
	ff 1e ff 1e ff 1e ff 1e ff ff 50 c5 51 ff ff ff
	ff 07 00 00 ff 07 00 00 ff 07 00 00 ff ff ff ff
	64 5f 55 50 64 5f 55 50 64 5f 55 50 64 5f 55 50
	64 5f 55 50 64 5f 55 50 64 5f 55 50 64 5f 55 50
	78 73 64 5f 78 73 64 5f 78 73 64 5f 78 73 64 5f
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	4f 00 00 00 00 ff ff ff 00 00 00 00 00 00 00 ff
	00 00 00 00 ff ff ff ff 01 ff ff ff ff ff ff ff
	ff ff ff ff 40 01 00 ff 00 00 00 00 00 ff 02 01)

regs02=(18 01 00 40 01 00 01 01 00 00 00 00 03 ff 12 62
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff
	f8 80 f8 80 f8 80 f8 80 f8 80 f8 80 f8 80 f8 80
	00 a0 00 00 00 00 00 00 00 00 00 ff 00 00 00 00
	90 01 08 00 00 00 00 00 ff ff ff ff ff ff ff ff
	20 00 00 00 08 00 00 00 00 ff 00 ff 00 00 00 00
	00 00 00 00 ff ff ff ff ff ff 50 c5 51 ff ff ff
	03 10 ff ff 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 f3 f3 f3 f3
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff 07 ff ff 00 00 00 00 00 00 00 00 00 00 00 ff
	00 00 00 07 00 00 00 07 00 00 00 07 00 00 00 07
	00 00 00 07 00 00 00 07 00 00 00 07 00 00 00 07
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 02)

regs03=(01 02 00 00 7f 0a 0a 00 02 04 05 00 00 00 00 00
	8e 2c 7f 7f 08 08 84 84 00 ff ff 10 00 ff ff ff
	47 3c 5a 5a 53 53 53 53 00 00 00 00 14 14 14 14
	19 1e 28 32 2f 6f af ff 26 2b 30 35 00 20 40 60
	19 23 2d 37 8c aa c8 e6 19 23 2d 37 8c aa c8 e6
	00 80 00 ff ff ff ff ff 8e 2c 8c 8c 00 00 00 00
	ff ff ff ff 00 00 00 00 00 00 00 00 ff ff ff ff
	00 00 00 00 ff ff ff ff ff ff 50 c5 51 ff ff ff
	00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff ff
	00 00 80 00 00 07 ff ff ff ff ff ff ff ff ff ff
	00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 03)

regs04=(00 00 00 00 00 00 ff ff 00 00 00 00 00 00 ff ff
	5a 5a 5a 5a 5a 5a ff ff ff ff ff ff ff ff ff ff
	53 53 53 53 53 53 ff ff ff ff ff ff ff ff ff ff
	19 23 2d 37 8c aa c8 e6 19 23 2d 37 8c aa c8 e6
	19 23 2d 37 8c aa c8 e6 19 23 2d 37 8c aa c8 e6
	19 23 2d 37 8c aa c8 e6 19 23 2d 37 8c aa c8 e6
	ff ff ff ff 8c 8c 8c 8c 8c 8c ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff 50 c5 51 ff ff ff
	ff ff ff ff ff ff ff ff 3c 50 3c 50 3c 50 3c 50
	3c 50 3c 50 3c 50 3c 50 33 33 33 33 33 33 33 33
	00 00 00 00 00 00 ff ff 00 00 00 00 00 00 00 00
	8e 2c 7f 7f 00 00 00 00 00 00 00 00 ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 04)

regs05=(ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff 50 c5 51 ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 05)

i2cset -f -y ${adapter} 0x2c 0xff 0x0 b
i=0
while [ $i -lt ${#regs00[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs00[$i]} b
	i=$(($i + 1))
done

i2cset -f -y ${adapter} 0x2c 0xff 0x1 b
i=0
while [ $i -lt ${#regs01[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs01[$i]} b
	i=$(($i + 1))
done

i2cset -f -y ${adapter} 0x2c 0xff 0x2 b
i=0
while [ $i -lt ${#regs02[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs02[$i]} b
	i=$(($i + 1))
done

i2cset -f -y ${adapter} 0x2c 0xff 0x3 b
i=0
while [ $i -lt ${#regs03[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs03[$i]} b
	i=$(($i + 1))
done

i2cset -f -y ${adapter} 0x2c 0xff 0x4 b
i=0
while [ $i -lt ${#regs04[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs04[$i]} b
	i=$(($i + 1))
done

i2cset -f -y ${adapter} 0x2c 0xff 0x5 b
i=0
while [ $i -lt ${#regs05[*]} ]
do
	i2cset -f -y ${adapter} 0x2c $i 0x${regs05[$i]} b
	i=$(($i + 1))
done

i2cset -y -f ${adapter} 0x2c 0xff 0	# re-select bank 0

echo nct7904 0x2c > /sys/class/i2c-adapter/i2c-${adapter}/new_device

base=$(getbase ${adapter} 002c)
if [ "${base}" = "" -o ! -d "${base}" ]
then
	echo fail: No hwmon device
	exit 1
fi

cd ${base}

attrs=(fan1_input fan2_input fan4_input fan5_input
	fan6_input fan7_input fan8_input
	in11_input in13_input in15_input in16_input in20_input
	in7_input in9_input
	name
	pwm1 pwm1_enable pwm2 pwm2_enable
	pwm3 pwm3_enable pwm4 pwm4_enable
	temp1_input temp2_input temp3_input temp4_input
	temp5_input temp6_input temp7_input temp8_input temp9_input)

vals=(0 0 0 0 0 0 0
	806 902 3360 3360 3366 1094 1842
	nct7904
	142 2 44 2 127 1 127 1
	35250 44000 0 0 0 0 0 0 0)

permissions=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
)

dotest attrs[@] vals[@] permissions[@]
rv=$?

for p in 1 2 3 4
do
	check_range -l 0 -u 255 -b ${base} -r -d 0 -q pwm${p}
	rv=$(($? + ${rv}))
done

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
