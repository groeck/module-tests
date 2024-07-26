#!/bin/bash

i2c_addr=0x2e
chip="emc2103"

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub "${i2c_addr}"
modprobe -r "${chip}"

regs=(1a 00 19 80 1a 00 19 e0 00 00 75 00 00 00 00 00
	d0 12 12 16 07 07 00 07 00 64 64 64 00 64 00 aa
	01 0e 00 08 55 aa 00 80 00 00 00 03 00 00 00 00
	55 55 55 00 55 00 00 00 00 00 00 00 00 00 00 00
	ff 01 2b 38 01 2a 19 10 66 f5 00 00 f8 ff 24 a0
	00 fb 7f 7f 7f 7f e6 7f 7f 7f 7f d1 7f 7f 7f 7f
	bc 7f 7f 7f 7f a7 7f 7f 7f 7f 92 7f 7f 7f 7f 92
	7f 7f 7f 7f 92 7f 7f 7f 7f 0a c0 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 5a 00 00 00 72 80 43 52 2c 05 44 22
	20 00 00 07 20 00 20 40 00 00 00 12 00 00 00 00
	00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 01 26 5d 01
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

do_instantiate ${chip} ${i2c_addr} 2>/dev/null
getbasedir ${i2c_addr}

cd ${basedir}

attrs=(name
	fan1_div fan1_fault fan1_input fan1_target fan1_min fan1_min_alarm fan1_pulses
	pwm1 pwm1_enable pwm1_freq
	temp1_fault temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp1_crit temp1_crit_alarm temp1_emergency
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	temp2_crit temp2_crit_alarm
	temp3_fault temp3_input temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	temp3_crit temp3_crit_alarm
	temp4_fault temp4_input temp4_max temp4_max_alarm temp4_min temp4_min_alarm
	temp4_crit temp4_crit_alarm
	)

vals=(emc2103
	4 0 6710 0 963 0 2
	255 0 2441
	0 26000 85000 1 0 0
	100000 0 117000
	0 25500 85000 0 0 1
	100000 1
	0 26000 85000 1 0 0
	100000 0
	0 25875 85000 0 0 1
	100000 1
)

permissions=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

# ls -l

# i2cdump -y -f ${i2c_adapter} ${i2c_addr}

dotest attrs[@] vals[@] permissions[@]
rv=$?

for t in $(seq 1 4)
do
	check_range -d 500 -r -q temp${t}_min
	rv=$((rv + $?))
	check_range -d 500 -r -q temp${t}_max
	rv=$((rv + $?))
	check_range -d 500 -r -q temp${t}_crit
	rv=$((rv + $?))
done

check_range -R "1 2 4 8 : 0 3 9" -r -q -S fan1_div
rv=$((rv + $?))
check_range -R "0 3 : 1 4" -r -q -S pwm1_enable
rv=$((rv + $?))
check_range -l 0 -r -d 815 -q fan1_target
rv=$((rv + $?))

modprobe -r i2c-stub 2>/dev/null
modprobe -r emc2103

exit ${rv}
