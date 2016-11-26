#!/bin/bash

i2c_addr=0x2e

dir=$(dirname $0)
. ${dir}/common.sh

regs_dme1737=(00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 f9
	64 75 c3 c4 c0 2e 17 15 e2 01 e6 01 ed 01 d9 01
	55 55 55 00 00 00 00 00 00 00 00 00 00 00 5c 89
	05 00 00 00 00 ff 00 ff 00 ff 00 ff 00 ff 81 4b
	81 7f 81 7f ff ff ff ff ff ff ff ff 02 02 02 a7
	a7 a7 e0 00 4d 4d 4d 2d 2d 2d 64 64 64 44 40 00
	55 55 55 09 09 09 09 09 09 00 30 00 44 00 00 1c
	00 a4 05 00 69 34 5f bc 8a 00 4d 4d 0b 0b 0c 00
	cc cc cc cc 0c 0c 0c 5a f1 c1 af 00 ff 00 ff 00
	00 00 0c 00 00 00 00 0b 0b fe ff fe ff ff ff ff
	ff 00 00 00 00 00 28 28 0e 0e 2b 2b 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_dme1737=(name cpu0_vid
	fan1_alarm fan1_input fan1_min fan1_type
	fan2_alarm fan2_input fan2_min fan2_type
	fan3_alarm fan3_input fan3_min fan3_type
	fan4_alarm fan4_input fan4_min fan4_type
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in6_alarm in6_input in6_max in6_min
	pwm1 pwm1_auto_channels_zone pwm1_auto_point1_pwm pwm1_auto_point2_pwm
	pwm1_auto_pwm_min pwm1_enable pwm1_freq pwm1_ramp_rate
	pwm2 pwm2_auto_channels_zone pwm2_auto_point1_pwm pwm2_auto_point2_pwm
	pwm2_auto_pwm_min pwm2_enable pwm2_freq pwm2_ramp_rate
	pwm3 pwm3_auto_channels_zone pwm3_auto_point1_pwm pwm3_auto_point2_pwm
	pwm3_auto_pwm_min pwm3_enable pwm3_freq pwm3_ramp_rate
	temp1_alarm temp1_fault temp1_input temp1_max temp1_min temp1_offset
	temp2_alarm temp2_fault temp2_input temp2_max temp2_min temp2_offset
	temp3_alarm temp3_fault temp3_input temp3_max temp3_min temp3_offset
	vrm
	zone1_auto_channels_temp zone1_auto_point1_temp zone1_auto_point1_temp_hyst
	zone1_auto_point2_temp zone1_auto_point3_temp
	zone2_auto_channels_temp zone2_auto_point1_temp zone2_auto_point1_temp_hyst
	zone2_auto_point2_temp zone2_auto_point3_temp
	zone3_auto_channels_temp zone3_auto_point1_temp zone3_auto_point1_temp_hyst
	zone3_auto_point2_temp zone3_auto_point3_temp)

vals_dme1737=(dme1737 0 0 11203 0 2 0 11111 0 2 0 10953 0 2 0 11416 0
	2 0 2624 6641 0 0 1378 2988 0 0 3360 4383 0 0 5122 6641
	0 0 12020 15938 0 0 3324 4383 0 0 3017 4383 0 85 1 77
	255 77 2 88 0 85 1 77 255 77 2 88 0 85 1 77
	255 77 2 88 0 0 0 46250 75000 -127000 -7000 0 0 23937 127000 -127000
	0 0 0 21187 127000 -127000 0 110 1 45000 41000 65000 100000 2 45000 41000
	65000 100000 4 45000 41000 65000 100000)

permissions_dme1737=(
	"-r--r--r--"
	"-r--r--r--"
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
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

permissions_dme1737_wp=(
	"-r--r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
)

regs_sch5027=(
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00
	b0 61 c3 3a cd c5 24 1e 7c 18 ff ff ff ff ff ff
	b2 ae 3f 30 00 00 00 10 00 00 00 00 00 00 5c 69
	25 80 38 00 00 ff 00 ff 00 ff 00 ff 00 ff 81 7f
	81 7f 81 7f 4c 1d 4c 1d 4c 1d 4c 1d 42 22 02 7a
	7a 7a e8 88 b2 a5 3f e4 23 3c 00 3c 50 44 40 00
	b2 ae 3f 00 00 00 00 00 00 00 00 00 00 00 ec 1c
	7e a4 0e 80 00 40 e6 aa e4 00 33 33 24 24 19 19
	04 04 04 04 0c 0c 0c 5a f1 bf b5 00 ff 00 ff 00
	00 00 0c 00 00 ff ff 0b 0b 1d 00 00 00 0c 00 0c
	00 00 00 00 00 00 08 08 0e 0e 0f 0f 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_sch5027=(fan1_alarm fan1_input fan1_min fan1_type
	fan2_alarm fan2_input fan2_min fan2_type
	fan3_alarm fan3_input fan3_min fan3_type
	fan4_alarm fan4_input fan4_min fan4_type
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	in6_alarm in6_input in6_max in6_min
	name
	pwm1 pwm1_auto_channels_zone pwm1_auto_point1_pwm pwm1_auto_point2_pwm
	pwm1_enable pwm1_freq pwm1_ramp_rate
	pwm2 pwm2_auto_channels_zone pwm2_auto_point1_pwm pwm2_auto_point2_pwm
	pwm2_enable pwm2_freq pwm2_ramp_rate
	pwm3 pwm3_auto_channels_zone pwm3_auto_point1_pwm pwm3_auto_point2_pwm
	pwm3_enable pwm3_freq pwm3_ramp_rate
	temp1_alarm temp1_fault temp1_input temp1_max temp1_min
	temp2_alarm temp2_fault temp2_input temp2_max temp2_min
	temp3_alarm temp3_fault temp3_input temp3_max temp3_min
	zone1_auto_channels_temp zone1_auto_point1_temp zone1_auto_point2_temp zone1_auto_point3_temp
	zone2_auto_channels_temp zone2_auto_point1_temp zone2_auto_point2_temp zone2_auto_point3_temp
	zone3_auto_channels_temp zone3_auto_point1_temp zone3_auto_point2_temp zone3_auto_point3_temp
)

vals_sch5027=(0 861 720 2 1 0 720 2 1 0 720 2 1 0 720 2
	0 4600 6641 0 0 1140 2988 0 0 3367 4383 0 0 344 1494 0
	0 1206 1494 0 0 3283 4383 0 0 3111 4383 0 sch5027 178 4 178
	255 2 30000 206 174 2 165 255 2 30000 206 63 1 63 255 2 30000
	206 0 0 -59000 127000 -127000 0 0 36375 127000 -127000 0 0 30250 127000 -127000
	1 -28000 -18000 0 2 35000 45000 60000 4 60000 70000 80000
)

permissions_sch5027=(
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
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
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
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

runtest()
{
    local chip=$1
    local regs=("${!2}")
    local attrs=("${!3}")
    local vals=("${!4}")
    local permissions=("${!5}")
    local wp=$6
    local rv
    local i

    load_i2c_stub ${i2c_addr}
    install_regs ${i2c_adapter} ${i2c_addr} regs[@] b

    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    for t in $(seq 1 3)
    do
	check_range -b ${basedir} -d 500 -r -q -w 2 temp${t}_min
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -d 500 -r -q -w 2 temp${t}_max
	rv=$(($? + ${rv}))
	if [ $wp -eq 0 -a -e ${basedir}/temp1_offset ]
	then
	    check_range -b ${basedir} -d 500 -r -q -w 2 temp${t}_offset
	    rv=$(($? + ${rv}))
	fi
    done

    for i in $(seq 0 6)
    do
	check_range -b ${basedir} -d 31 -r -q -w 2 "in${i}_min"
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -d 31 -r -q -w 2 "in${i}_max"
	rv=$(($? + ${rv}))
    done

    for f in $(seq 1 4)
    do
	check_range -b ${basedir} -l 0 -u 100000 -d 1500 -r -q -w 2 fan${f}_min
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -l 1 -u 2 -d 0 -r -q -w 2 fan${f}_type
	rv=$(($? + ${rv}))
    done

    if [ $wp -eq 0 ]
    then
	for p in $(seq 1 3)
	do
	    check_range -b ${basedir} -l 0 -u 255 -d 0 -r -q -w 2 pwm${p}_auto_point1_pwm
	    rv=$(($? + ${rv}))
	    check_range -b ${basedir} -l 0 -u 2 -d 0 -r -q -w 2 pwm${p}_enable
	    rv=$(($? + ${rv}))
	    check_range -b ${basedir} -l 0 -r -q -d 7500 -w 2 pwm${p}_freq
	    rv=$(($? + ${rv}))
	    check_range -b ${basedir} -l 0 -r -q -w 2 pwm${p}_ramp_rate
	    rv=$(($? + ${rv}))
	    if [ -e ${basedir}/pwm${p}_auto_pwm_min ]
	    then
		check_range -b ${basedir} -l 0 -r -q -w 2 pwm${p}_auto_pwm_min
		rv=$(($? + ${rv}))
	    fi
	done

	for z in $(seq 1 3)
	do
	    if [ -e zone${z}_auto_point1_temp_hyst ]
	    then
		check_range -b ${basedir} -r -d 500 -q -w 2 zone${z}_auto_point1_temp_hyst
		rv=$(($? + ${rv}))
	    fi
	    for t in $(seq 1 3)
	    do
		check_range -b ${basedir} -r -q -w 2 zone${z}_auto_point${t}_temp
		rv=$(($? + ${rv}))
	    done
	done
    fi

    if [ -e ${basedir}/vrm ]
    then
	check_range -b ${basedir} -l 0 -u 255 -r -d 0 -q vrm
	rv=$(($? + ${rv}))
    fi

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0
echo "Testing dme1737"
runtest dme1737 regs_dme1737[@] attrs_dme1737[@] vals_dme1737[@] permissions_dme1737[@] 0
rv=$(($? + ${rv}))

# write-protect chip, then try again
regs_dme1737[64]=07

echo "Testing dme1737 [WP]"
runtest dme1737 regs_dme1737[@] attrs_dme1737[@] vals_dme1737[@] permissions_dme1737_wp[@] 1
rv=$(($? + ${rv}))

echo "Testing sch5027"
runtest sch5027 regs_sch5027[@] attrs_sch5027[@] vals_sch5027[@] permissions_sch5027[@] 0
rv=$(($? + ${rv}))

modprobe -r dme1737

exit ${rv}
