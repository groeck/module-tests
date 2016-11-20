#!/bin/bash

i2c_addr=2c

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

do_tests ()
{
    local chip=$1
    local regs=("${!2}")
    local attrs=("${!3}")
    local vals=("${!4}")
    local base
    local olddir

    install_regs ${adapter} ${i2c_addr} regs[@]

    echo ${chip} 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/new_device 2>/dev/null

    base=$(getbase ${adapter} 00${i2c_addr})
    if [ "${base}" = "" -o ! -d "${base}" ]
    then
	echo fail: No hwmon device
	exit 1
    fi

    olddir=$(pwd)
    cd ${base}

# grep . * 2>/dev/null
# return 0

    dotest attrs[@] vals[@]
    rv=$?

    for t in $(seq 1 3)
    do
	check_range -b ${base} -d 500 -r -q temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_auto_temp_crit
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 13260 -r -q temp${t}_auto_temp_max
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_auto_temp_min
	rv=$(($? + ${rv}))
	check_range -b ${base} -d 500 -r -q temp${t}_auto_temp_off
	rv=$(($? + ${rv}))
    done

    for f in $(seq 1 4)
    do
	check_range -b ${base} -l 0 -u 20000 -d 52 -q fan${f}_min
	rv=$(($? + ${rv}))
    done

    for i in $(seq 0 4)
    do
	check_range -b ${base} -r -q -d 32 "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -r -q -d 32 "in${i}_max"
	rv=$(($? + ${rv}))
    done

    for p in $(seq 1 3)
    do
	check_range -b ${base} -l 0 -u 255 -r -q -d 0 "pwm${p}"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 255 -r -q -d 0 "pwm${p}_auto_pwm_min"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 255 -r -q -d 0 "pwm${p}_auto_pwm_minctl"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -u 2 -r -q -d 0 "pwm${p}_enable"
	rv=$(($? + ${rv}))
	check_range -b ${base} -l 0 -r -q -d 16 "pwm${p}_freq"
	rv=$(($? + ${rv}))
    done

    check_range -b ${base} -l 0 -u 255 -r -q -d 0 "vrm"
    rv=$(($? + ${rv}))

    echo 0x${i2c_addr} > /sys/class/i2c-adapter/i2c-${adapter}/delete_device 2>/dev/null

    return ${rv}
}

regs_lm85=(00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 76 94 c0 c5 c2 1f 20 1f a7 06 ff ff 73 12 33 11
	 ff ff 4d 00 00 00 00 00 00 00 00 00 00 00 01 62
	 07 8b 01 04 00 ff 00 ff 00 ff 00 ff 00 ff 81 7f
	 81 7f 81 7f ff ff ff ff ff ff ff ff 62 62 42 c4
	 c4 c4 e0 00 80 80 4d 5a 5a 25 64 64 2f 44 40 00
	 1f 20 1f 32 00 07 00 00 00 00 00 40 28 31 6c 57
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_lm85=(name alarms cpu0_vid
	fan1_alarm fan1_input fan1_min
	fan2_alarm fan2_input fan2_min
	fan3_alarm fan3_input fan3_min
	fan4_alarm fan4_input fan4_min
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	pwm1 pwm1_auto_channels pwm1_auto_pwm_min pwm1_auto_pwm_minctl pwm1_enable pwm1_freq
	pwm2 pwm2_auto_channels pwm2_auto_pwm_min pwm2_auto_pwm_minctl pwm2_enable pwm2_freq
	pwm3 pwm3_auto_channels pwm3_auto_pwm_min pwm3_auto_pwm_minctl pwm3_enable pwm3_freq
	temp1_alarm temp1_auto_temp_crit temp1_auto_temp_max temp1_auto_temp_min
	temp1_auto_temp_off temp1_fault temp1_input temp1_max temp1_min
	temp2_alarm temp2_auto_temp_crit temp2_auto_temp_max temp2_auto_temp_min
	temp2_auto_temp_off temp2_input temp2_max temp2_min
	temp3_alarm temp3_auto_temp_crit temp3_auto_temp_max temp3_auto_temp_min
	temp3_auto_temp_off temp3_fault temp3_input temp3_max temp3_min
	vrm
)

vals_lm85=(lm85 395 1588 0 3170 0 0 0 0 0 1143 0 0 1226 0 1 1536
	3320 0 1 1734 2988 0 0 3300 4383 0 1 5130 6641 0 1 12125
	15938 0 255 -1 128 1 0 38 255 -1 128 1 0 38 77 3
	77 1 2 38 0 100000 122000 90000 86000 0 31000 127000 -127000 0 100000 122000
	90000 86000 32000 127000 -127000 0 47000 69000 37000 33000 0 31000 127000 -127000 110
	) 

do_tests "lm85" regs_lm85[@] attrs_lm85[@] vals_lm85[@]
rv=$?

regs_emc6d102=(00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	71 80 c4 c4 c2 1b 19 1c a4 07 ff ff 1b 09 ab 07
	ff ff ff 00 00 00 00 00 00 00 00 00 00 00 5c 65
	05 00 00 0d 6d 79 7c 89 b6 ca b6 ca b6 ca 0a 37
	0a 2d 0a 2d 8c 0a ff ff ff ff ff ff 62 62 62 c0
	70 70 20 00 80 80 4d 1f 23 23 3f 2d 2d 44 40 00
	ff ff ff 09 09 09 09 09 09 00 30 00 40 00 ec 18
	1e a4 0e 00 00 3b 50 44 58 00 4d 4d 09 09 0a 00
	04 04 04 04 0c 0c 0c 5a f1 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 12
)

attrs_emc6d102=(name alarms cpu0_vid
	fan1_alarm fan1_input fan1_min fan2_alarm fan2_input fan2_min
	fan3_alarm fan3_input fan3_min fan4_alarm fan4_input fan4_min
	in0_alarm in0_input in0_max in0_min in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	pwm1 pwm1_auto_channels pwm1_auto_pwm_min pwm1_auto_pwm_minctl pwm1_enable pwm1_freq
	pwm2 pwm2_auto_channels pwm2_auto_pwm_min pwm2_auto_pwm_minctl pwm2_enable pwm2_freq
	pwm3 pwm3_auto_channels pwm3_auto_pwm_min pwm3_auto_pwm_minctl pwm3_enable pwm3_freq
	temp1_alarm temp1_auto_temp_crit temp1_auto_temp_max temp1_auto_temp_min temp1_auto_temp_off
	temp1_fault temp1_input temp1_max temp1_min
	temp2_alarm temp2_auto_temp_crit temp2_auto_temp_max temp2_auto_temp_min temp2_auto_temp_off
	temp2_input temp2_max temp2_min
	temp3_alarm temp3_auto_temp_crit temp3_auto_temp_max temp3_auto_temp_min temp3_auto_temp_off
	temp3_fault temp3_input temp3_max temp3_min
	vrm)

vals_emc6d102=(emc6d102 0 1531 0 2760 2000 0 0 0 0 2316 0 0 2750 0 0 1475
	1576 1419 0 1506 1605 1453 0 3374 3472 3128 0 5111 5260 4740 0 12145
	12625 11375 255 -1 128 1 0 11 255 -1 128 0 0 11 255 -1
	77 0 0 11 0 63000 63000 31000 27000 0 27688 55000 10000 0 45000 45000
	35000 31000 25000 45000 10000 0 45000 45000 35000 31000 0 28188 45000
	10000 110)

do_tests "emc6d102" regs_emc6d102[@] attrs_emc6d102[@] vals_emc6d102[@]
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
