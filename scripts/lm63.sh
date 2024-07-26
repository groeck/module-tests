#!/bin/bash

i2c_addr=0x18
driver=lm63

dir=$(dirname $0)
. ${dir}/common.sh

regs_lm63=(
	1c 33 10 84 08 46 00 46 00 80 08 46 00 46 00 00
	20 00 00 00 00 00 a4 00 00 55 00 00 00 00 00 00
	00 0a 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 ff ff 20 3f 00 17 00 04
	7f 3f 7f 3f 7f 3f 7f 3f 7f 3f 7f 3f 7f 3f 7f 3f
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	48 20 2f d5 91 00 05 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 41
)


attrs_lm63=(alarms
	fan1_input fan1_min fan1_min_alarm
	name
	pwm1
	pwm1_auto_point1_pwm pwm1_auto_point1_temp pwm1_auto_point1_temp_hyst
	pwm1_auto_point2_pwm pwm1_auto_point2_temp pwm1_auto_point2_temp_hyst
	pwm1_auto_point3_pwm pwm1_auto_point3_temp pwm1_auto_point3_temp_hyst
	pwm1_auto_point4_pwm pwm1_auto_point4_temp pwm1_auto_point4_temp_hyst
	pwm1_auto_point5_pwm pwm1_auto_point5_temp pwm1_auto_point5_temp_hyst
	pwm1_auto_point6_pwm pwm1_auto_point6_temp pwm1_auto_point6_temp_hyst
	pwm1_auto_point7_pwm pwm1_auto_point7_temp pwm1_auto_point7_temp_hyst
	pwm1_auto_point8_pwm pwm1_auto_point8_temp pwm1_auto_point8_temp_hyst
	pwm1_enable
	temp1_input temp1_max temp1_max_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
)

vals_lm63=(16
	0 0 0
	lm63
	0
	255 127000 123000
	255 127000 123000
	255 127000 123000
	255 127000 123000
	255 127000 123000
	255 127000 123000
	255 127000 123000
	255 127000 123000
	1
	28000 70000 0
	85000 0 75000 0 51125
	70000 1 0 0 0
	62
)

permissions_lm63=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
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
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_lm96163=(
	17 17 80 86 08 46 00 55 00 86 08 46 00 55 00 00
	20 00 00 00 00 00 a4 00 00 6e 00 00 00 00 00 00
	00 0a 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 17 20 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 10 ff ff fc ff 20 3f 01 08 00 04
	7f 3f 7f 3f 7f 3f 7f 3f 7f 3f 7f 3f 7f 3f 7f 3f
	7f 3f 7f 3f 7f 3f 7f 3f 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 49
)

attrs_lm96163=(alarms
	fan1_input fan1_min fan1_min_alarm
	name
	pwm1
	pwm1_auto_point10_pwm pwm1_auto_point10_temp pwm1_auto_point10_temp_hyst
	pwm1_auto_point11_pwm pwm1_auto_point11_temp pwm1_auto_point11_temp_hyst
	pwm1_auto_point12_pwm pwm1_auto_point12_temp pwm1_auto_point12_temp_hyst
	pwm1_auto_point1_pwm pwm1_auto_point1_temp pwm1_auto_point1_temp_hyst
	pwm1_auto_point2_pwm pwm1_auto_point2_temp pwm1_auto_point2_temp_hyst
	pwm1_auto_point3_pwm pwm1_auto_point3_temp pwm1_auto_point3_temp_hyst
	pwm1_auto_point4_pwm pwm1_auto_point4_temp pwm1_auto_point4_temp_hyst
	pwm1_auto_point5_pwm pwm1_auto_point5_temp pwm1_auto_point5_temp_hyst
	pwm1_auto_point6_pwm pwm1_auto_point6_temp pwm1_auto_point6_temp_hyst
	pwm1_auto_point7_pwm pwm1_auto_point7_temp pwm1_auto_point7_temp_hyst
	pwm1_auto_point8_pwm pwm1_auto_point8_temp pwm1_auto_point8_temp_hyst
	pwm1_auto_point9_pwm pwm1_auto_point9_temp pwm1_auto_point9_temp_hyst
	pwm1_enable
	temp1_input temp1_max temp1_max_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input temp2_max
	temp2_max_alarm temp2_min temp2_min_alarm temp2_offset temp2_type
	update_interval
)

vals_lm96163=(0
	0 0 0
	lm96163
	1
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	63 127000 123000
	1
	23000 70000 0
	110000 0 100000 0 23125 85000
	0 0 0 0 2
	76
)

permissions_lm96163=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
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
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_lm64=(
	34 3e 00 03 08 46 00 46 00 03 08 46 00 46 00 00
	60 10 00 00 00 00 e5 00 00 7b 1f 1f 00 00 00 00
	00 64 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 af 0f ff ff 00 00 05 08 00 05
	00 04 32 05 46 06 5a 07 5f 0b 64 0d 69 10 69 10
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	c0 20 2a d1 19 01 0d 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 27 00 00 00 00 00 00 00 02
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 51
)

attrs_lm64=(name
)

vals_lm64=(lm64
)

permissions_lm64=(
)

runtest()
{
    local chip=$1
    local channels=$2
    local regs=("${!3}")
    local attrs=("${!4}")
    local vals=("${!5}")
    local permissions=("${!6}")
    local rv
    local i

    echo Testing ${chip} ...

    modprobe -r ${driver}

    load_i2c_stub ${i2c_addr} width=8

    install_regs ${i2c_adapter} ${i2c_addr} regs[@] b

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    # i2cdump -y -f ${i2c_adapter} ${i2c_addr}
    ls -l
    grep . *

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    check_range -r -q -d 5000 update_interval
    rv=$((rv + $?))

    check_range -l 0 -u 255 -r -q -d 3 pwm1
    rv=$((rv + $?))

    if [[ -e "fan1_min" ]]; then
	check_range -r -q -v fan1_min
	rv=$((rv + $?))
    fi

    for i in $(seq 1 ${channels}); do
	check_range -s 250 -r -q -d 500 temp${i}_max
	rv=$((rv + $?))
	if [[ "${i}" -eq 2 ]]; then
	    if is_writeable temp${i}_crit; then
		check_range -s 250 -r -q -d 500 temp${i}_crit
		rv=$((rv + $?))
	    fi
	    check_range -s 250 -r -q -d 500 temp${i}_crit_hyst
	    rv=$((rv + $?))
	    check_range -s 250 -r -q -d 0 temp${i}_min
	    rv=$((rv + $?))
	    check_range -s 250 -r -q -d 0 temp${i}_offset
	    rv=$((rv + $?))
	fi
    done

    for p in $(seq 1 8); do
	check_range -l 0 -u 255 -r -q -d 3 pwm1_auto_point${p}_pwm
	rv=$((rv + $?))
	check_range -r -q -d 500 pwm1_auto_point${p}_temp
	rv=$((rv + $?))
    done

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

# runtest lm63 2 regs_lm63[@] attrs_lm63[@] vals_lm63[@] permissions_lm63[@]
# rv=$((rv + $?))
# runtest lm64 2 regs_lm64[@] attrs_lm64[@] vals_lm64[@] permissions_lm64[@]
# rv=$((rv + $?))
runtest lm96163 2 regs_lm96163[@] attrs_lm96163[@] vals_lm96163[@] permissions_lm96163[@]
rv=$((rv + $?))

exit ${rv}
