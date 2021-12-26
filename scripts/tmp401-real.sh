#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

# reload driver

modprobe -r tmp401 2>/dev/null
modprobe tmp401 2>/dev/null

# reload i2c adapter driver to force detect function to run

modprobe -r i2c_diolan_u2c 2>/dev/null
modprobe i2c_diolan_u2c 2>/dev/null

i2c_adapter=$(grep "i2c-diolan-u2c" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

if [[ -z "${i2c_adapter}" ]]; then
    i2c_adapter=$(grep "i2c-devantech-iss" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)
    if [[ -z "${i2c_adapter}" ]]; then
	echo "i2c adapter not found"
	exit 1
    fi
fi

attrs_tmp401="name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
"

attrs_tmp411="name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_highest
	temp1_input temp1_lowest temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_highest
	temp2_input temp2_lowest temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
	temp_reset_history
"

attrs_tmp431="name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
"

attrs_tmp432="name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault
	temp3_input temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	update_interval
"

attrs_tmp435="name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
"

test_chip()
{
    local rv

    echo "  Testing default temperature range"

    modprobe -r tmp401
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x0
    modprobe tmp401

    test_one attrs[@]
    rv=$?

    echo "  Testing extended temperature range"

    modprobe -r tmp401
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x4
    # alarms need time to settle
    sleep 0.1
    modprobe tmp401

    test_one attrs[@]
    rv=$((rv + $?))

    return ${rv}
}

test_chips
rv=$?

exit ${rv}
