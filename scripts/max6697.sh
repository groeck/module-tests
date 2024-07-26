#!/bin/bash

i2c_addr=0x4c
driver=max6697

dir=$(dirname $0)
. ${dir}/common.sh

regs_max6581=(
	00 39 3a 3b 39 3b 3b 18 ff a0 4d 00 00 00 00 00
	00 7f 7f 64 64 64 64 5a 64 00 00 00 00 00 00 00
	50 6e 6e 6e 7f 5a 5a 6e 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 55 aa 55 aa ff 00 00 00 00 00 00 00
	00 a0 60 20 e0 60 40 e0 e0 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_max6581=(name
	temp1_crit temp1_crit_alarm temp1_input temp1_min temp1_min_alarm temp1_max temp1_max_alarm
	temp2_crit temp2_crit_alarm temp2_fault temp2_input temp2_min temp2_min_alarm temp2_max temp2_max_alarm temp2_offset
	temp3_crit temp3_crit_alarm temp3_fault temp3_input temp3_min temp3_min_alarm temp3_max temp3_max_alarm temp3_offset
	temp4_crit temp4_crit_alarm temp4_fault temp4_input temp4_min temp4_min_alarm temp4_max temp4_max_alarm temp4_offset
	temp5_crit temp5_crit_alarm temp5_fault temp5_input temp5_min temp5_min_alarm temp5_max temp5_max_alarm temp5_offset
	temp6_crit temp6_crit_alarm temp6_fault temp6_input temp6_min temp6_min_alarm temp6_max temp6_max_alarm temp6_offset
	temp7_crit temp7_crit_alarm temp7_fault temp7_input temp7_min temp7_min_alarm temp7_max temp7_max_alarm temp7_offset
	temp8_crit temp8_crit_alarm temp8_fault temp8_input temp8_min temp8_min_alarm temp8_max temp8_max_alarm temp8_offset
)

vals_max6581=(max6581
	80000 1 24875 0 0 90000 1
	110000 0 1 57625 0 0 127000 1 0
	110000 1 0 58375 0 1 127000 0 0
	110000 0 1 59125 0 0 100000 1 0
	127000 1 0 57875 0 1 100000 0 0
	90000 0 1 59375 0 0 100000 1 0
	90000 1 0 59250 0 1 100000 0 0
	110000 0 1 255000 0 1 100000 0 0
)

permissions_max6581=(
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
)

# 6581, extended temperature mode, different alert register values

regs_max6581_ext=(
	00 39 3a 3b 39 3b 3b 18 ff a0 4d 00 00 00 00 00
	00 7f 7f 64 64 64 64 5a 64 00 00 00 00 00 00 00
	50 6e 6e 6e 7f 5a 5a 6e 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 02 00 00 0f f0 0f f0 ff 00 00 00 00 00 00 00
	00 a0 60 20 e0 60 40 e0 e0 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

vals_max6581_ext=(max6581
	16000 1 -39125 -64000 1 26000 0
	46000 0 1 -6375 -64000 0 63000 1 0
	46000 0 1 -5625 -64000 0 63000 1 0
	46000 0 1 -4875 -64000 0 36000 1 0
	63000 0 1 -6125 -64000 0 36000 1 0
	26000 1 0 -4625 -64000 1 36000 0 0
	26000 1 0 -4750 -64000 1 36000 0 0
	46000 1 0 191000 -64000 1 36000 0 0
)

regs_max6698=(
	00 39 3a 3b 39 3b 3b 18 00 a0 4d 00 00 00 00 00
	00 6e 7f 64 64 64 64 5a 64 00 00 00 00 00 00 00
	00 6e 6e 6e 7f 5a 5a 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 aa 55 aa 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_max6698=(name
	temp1_input temp1_max temp1_max_alarm
	temp2_crit temp2_crit_alarm temp2_fault temp2_input temp2_max temp2_max_alarm
	temp3_fault temp3_input temp3_max temp3_max_alarm
	temp4_fault temp4_input temp4_max temp4_max_alarm
	temp5_crit temp5_crit_alarm temp5_input temp5_max temp5_max_alarm
	temp6_crit temp6_crit_alarm temp6_input temp6_max temp6_max_alarm
	temp7_crit temp7_crit_alarm temp7_input temp7_max temp7_max_alarm
)

vals_max6698=(max6698
	24000 90000 0
	110000 1 1 57625 110000 0
	0 58000 127000 1
	1 59000 100000 0
	127000 0 57000 100000 1
	90000 1 59000 100000 0
	90000 0 59000 100000 1
)

permissions_max6698=(
	"-r--r--r--"
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
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

regs_max6699=(
	00 39 3a 3b 39 3b 3b 18 00 a0 4d 00 00 00 00 00
	00 6e 7f 64 64 64 64 5a 64 00 00 00 00 00 00 00
	00 6e 6e 6e 7f 5a 5a 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 55 aa 55 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_max6699=(name
	temp1_input temp1_max temp1_max_alarm
	temp2_crit temp2_crit_alarm temp2_fault temp2_input temp2_max temp2_max_alarm
	temp3_fault temp3_input temp3_max temp3_max_alarm
	temp4_fault temp4_input temp4_max temp4_max_alarm
	temp5_crit temp5_crit_alarm temp5_fault temp5_input temp5_max temp5_max_alarm
)

vals_max6699=(max6699
	24000 90000 0
	110000 1 1 57625 110000 0
	0 58000 127000 1
	1 59000 100000 0
	127000 0 0 57000 100000 1
)

permissions_max6699=(
	"-r--r--r--"
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
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
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

    # ls -l
    # grep . *
    # i2cdump -y -f ${i2c_adapter} ${i2c_addr}

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    if [[ -e "temp1_min" ]]; then
	check_range -s 250 -r -q temp1_min
	rv=$((rv + $?))
    fi

    for i in $(seq 1 ${channels}); do
	check_range -s 250 -r -q temp${i}_max
	rv=$((rv + $?))
	if [[ -e "temp${i}_crit" ]]; then
	    check_range -s 250 -r -q temp${i}_crit
	    rv=$((rv + $?))
	fi
	if [[ -e "temp${i}_offset" ]]; then
	    check_range -s 250 -r -q temp${i}_offset
	    rv=$((rv + $?))
	fi
    done

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest max6581 8 regs_max6581[@] attrs_max6581[@] vals_max6581[@] permissions_max6581[@]
rv=$((rv + $?))
runtest max6581 8 regs_max6581_ext[@] attrs_max6581[@] vals_max6581_ext[@] permissions_max6581[@]
rv=$((rv + $?))
runtest max6698 7 regs_max6698[@] attrs_max6698[@] vals_max6698[@] permissions_max6698[@]
rv=$((rv + $?))
runtest max6699 5 regs_max6698[@] attrs_max6699[@] vals_max6699[@] permissions_max6699[@]
rv=$((rv + $?))

exit ${rv}
