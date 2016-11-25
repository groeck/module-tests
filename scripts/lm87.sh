#!/bin/bash

i2c_addr=0x2c

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs_lm87=(
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 32 55 00 04 32 55 ff 00 00 00 00 00 00
	80 79 bf c3 c4 00 1b 1b ff ff 00 4b 00 8e 46 cc
	ae d4 ad d0 a0 8e 46 55 00 32 00 ed ed 00 02 04
	07 c0 80 c1 be 00 00 57 00 80 08 00 80 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	30 2e 00 00 5b 02 00 00 00 00 00 00 00 00 00 00
	00 00 00 33 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 7f fc b4 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

regs_adm1024=(
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d
	5d 5d 5d 48 46 00 02 46 55 00 00 00 5d 5d 5d 5d
	83 79 c3 c3 c3 75 1e 1b 69 ff fe ff 00 89 62 d1
	ad d3 ad d3 ad 80 6a 50 00 50 00 fe fe 00 41 1b
	07 80 00 80 fe 01 00 ff 5d 81 09 5d 80 00 5d 5d
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d
	5d 5d 5d 48 46 00 02 46 55 00 00 00 5d 5d 5d 5d
	83 79 c3 c3 c3 74 1e 1a 69 ff fe ff 00 89 62 d1
	ad d3 ad d3 ad 80 6a 50 00 50 00 fe fe 00 41 1b
	07 80 00 80 fe 00 00 ff 5d 81 09 5d 80 00 5d 5d
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d
	5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d 5d
)

attrs_lm87=(alarms aout_output
	cpu0_vid
	fan1_alarm fan1_div fan1_input fan1_min
	fan2_alarm fan2_div fan2_input fan2_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	name
	temp1_alarm temp1_crit temp1_input temp1_max temp1_min
	temp2_alarm temp2_crit temp2_fault temp2_input temp2_max temp2_min
	temp3_alarm temp3_crit temp3_fault temp3_input temp3_max temp3_min
	vrm
)

vals_lm87=(32960 2499 1569 1 2 0 2848 1 2 0 2848 0 1702 1997 984
	0 3283 3506 2991 0 5078 5521 4505 0 12250 13000 10000 lm87 0 50000 27000
	50000 0 0 85000 0 27000 85000 0 0 85000 1 -128000 75000 0 110
)

permissions_lm87=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

attrs_lm87_2=(alarms aout_output cpu0_vid
	fan2_alarm fan2_div fan2_input fan2_min
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in6_alarm in6_input in6_max in6_min
	name
	temp1_alarm temp1_crit temp1_input temp1_max temp1_min
	temp2_alarm temp2_crit temp2_fault temp2_input temp2_max temp2_min
	vrm
)

vals_lm87_2=(32960 2499 1569 1 2 0 2848 0 1667 977 0 0 1702 1997 984
	0 3283 3506 2991 0 5078 5521 4505 0 12250 13000 10000 0 0 1997 984
	1 2490 2314 0 lm87 0 50000 27000 50000 0 0 85000 0 27000 85000 0 110
)

permissions_lm87_2=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

attrs_adm1024=(alarms aout_output cpu0_vid
	fan1_alarm fan1_div fan1_input fan1_min
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in7_alarm in7_input in7_max in7_min
	name
	temp1_alarm temp1_crit temp1_input temp1_max temp1_min
	temp2_alarm temp2_crit temp2_fault temp2_input temp2_max temp2_min
	vrm
)

vals_adm1024=(128 0 1419 0 8 1607 664 0 1706 3320 0 0 1702 1927 1378 0
	3352 3592 2973 0 5078 5495 4505 0 12188 13188 10813 0 1645 1800 1491
	1 2490 2480 0 adm1024 0 70000 27000 80000 0 0 70000 0 30000 80000 0 110
)

permissions_adm1024=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

i=0
while [ $i -lt ${#regs_lm87[*]} ]
do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs_lm87[$i]} b
	i=$(($i + 1))
done

do_instantiate lm87 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

dotest attrs_lm87[@] vals_lm87[@] permissions_lm87[@]
rv=$?

for t in $(seq 1 3)
do
	check_range -b ${basedir} -d 500 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
done

check_range -b ${basedir} -d 0 -l 0 -u 255 -r -q vrm
rv=$(($? + ${rv}))

check_range -b ${basedir} -d 5 -r -q aout_output
rv=$(($? + ${rv}))

do_remove ${i2c_addr}

# Change configuration to enable in0, in5, and in6
i2cset -y -f ${i2c_adapter} ${i2c_addr} 0x16 0x01 b

do_instantiate lm87 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

dotest attrs_lm87_2[@] vals_lm87_2[@] permissions_lm87_2[@]
rv=$(($? + ${rv}))

for i in $(seq 0 6)
do
	check_range -b ${basedir} -d 31 -r -q "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -d 31 -r -q "in${i}_max"
	rv=$(($? + ${rv}))
done

do_remove ${i2c_addr}

i=0
while [ $i -lt ${#regs_adm1024[*]} ]
do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs_adm1024[$i]} b
	i=$(($i + 1))
done

do_instantiate adm1024 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

dotest attrs_adm1024[@] vals_adm1024[@] permissions_adm1024[@]
rv=$(($? + ${rv}))

modprobe -r lm87

exit ${rv}
