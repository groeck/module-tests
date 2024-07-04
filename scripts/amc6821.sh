#!/bin/bash

i2c_addr=0x18
chip=amc6821

dir=$(dirname $0)
. ${dir}/common.sh

regs=(59 05 00 00 88 00 20 00 2f 0d 2b 46 00 00 00 00
	 e0 2e 00 00 3c 00 46 00 50 00 64 50 1e 69 ff ff
	 1d 3c 74 52 78 7a 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 21 49 03
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 59 05 00 00 88 00 60 00 18 0d 27 43 00 00 00 00
	 e0 2e 00 00 3c 00 46 00 50 00 64 50 1e 69 ff ff
	 1d 3c 6c 52 78 7a 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 21 49 03
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00)

attrs=(name
	fan1_pulses fan1_fault fan1_input fan1_max fan1_min fan1_target
	pwm1 pwm1_auto_channels_temp pwm1_auto_point1_pwm
	pwm1_auto_point2_pwm pwm1_auto_point3_pwm pwm1_enable pwm1_mode
	temp1_auto_point1_temp temp1_auto_point2_temp temp1_auto_point3_temp
	temp1_crit temp1_crit_alarm temp1_input temp1_max temp1_max_alarm
	temp1_min temp1_min_alarm temp2_auto_point1_temp temp2_auto_point2_temp
	temp2_auto_point3_temp temp2_crit temp2_crit_alarm temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm)

vals=(amc6821
	2 0 1777 0 500 91
	116 2 0 60 255 2 0 30000 60000 66000 80000 0 43000 60000
	0 0 0 30000 60000 84000 105000 0 0 70000 80000 0 0 0)

permissions=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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
)

load_i2c_stub ${i2c_addr}

modprobe -r amc6821

i=0
while [ $i -lt ${#regs[*]} ]
do
        i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
        i=$((i + 1))
done

do_instantiate ${chip} ${i2c_addr} 2>/dev/null
getbasedir ${i2c_addr}

cd ${basedir}

# ls -l
# grep . *

dotest attrs[@] vals[@] permissions[@]
rv=$?

for i in $(seq 1 2)
do
    check_range -b ${basedir} -s 500 -d 500 -r -q temp${i}_min
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 500 -d 500 -r -q temp${i}_max
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 500 -d 500 -r -q temp${i}_crit
    rv=$(($? + ${rv}))
done

check_range -b ${basedir} -s 1000 -d 3000000 -r -q fan1_min
rv=$(($? + ${rv}))
check_range -b ${basedir} -s 1000 -d 3000000 -r -q fan1_max
rv=$(($? + ${rv}))
check_range -b ${basedir} -s 1000 -d 3000000 -r -q fan1_target
rv=$(($? + ${rv}))

check_range -b ${basedir} -l 0 -u 255 -d 0 -r -q pwm1
rv=$(($? + ${rv}))
check_range -b ${basedir} -l 0 -u 255 -d 0 -r -q pwm1_auto_point2_pwm
rv=$(($? + ${rv}))
check_range -b ${basedir} -l 1 -u 4 -d 0 -r -q pwm1_enable
rv=$(($? + ${rv}))
check_range -b ${basedir} -l 0 -u 1 -r -q -d 0 pwm1_mode
rv=$(($? + ${rv}))

check_range -b ${basedir} -s 500 -d 2000 -r -q temp1_auto_point2_temp
rv=$(($? + ${rv}))
check_range -b ${basedir} -s 500 -d 48000 -r -q temp1_auto_point3_temp
rv=$(($? + ${rv}))

check_range -b ${basedir} -s 500 -d 500 -r -q temp2_auto_point1_temp
rv=$(($? + ${rv}))
check_range -b ${basedir} -s 500 -d 2000 -r -q temp2_auto_point2_temp
rv=$(($? + ${rv}))
check_range -b ${basedir} -s 500 -d 48000 -r -q temp2_auto_point3_temp
rv=$(($? + ${rv}))

exit ${rv}
