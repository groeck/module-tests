#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

# reload driver

modprobe -r tmp464 2>/dev/null
modprobe tmp464 2>/dev/null

# reload i2c adapter driver to force detect function to run

adapter_module="i2c_diolan_u2c"
i2c_adapter=$(grep "i2c-diolan-u2c" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

if [[ -z "${i2c_adapter}" ]]; then
    adapter_module="i2c_devantech_iss"
    i2c_adapter=$(grep "i2c-devantech-iss" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)
    if [[ -z "${i2c_adapter}" ]]; then
	echo "i2c adapter not found"
	exit 1
    fi
fi

modprobe -r "${adapter_module}" 2>/dev/null
modprobe "${adapter_module}" 2>/dev/null

attrs_tmp464="name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_max_hyst
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_max_hyst temp2_offset
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault
	temp3_input temp3_max temp3_max_alarm temp3_max_hyst temp3_offset
	temp4_crit temp4_crit_alarm temp4_crit_hyst temp4_fault
	temp4_input temp4_max temp4_max_alarm temp4_max_hyst temp4_offset
	temp5_crit temp5_crit_alarm temp5_crit_hyst temp5_fault
	temp5_input temp5_max temp5_max_alarm temp5_max_hyst temp5_offset
	update_interval"

attrs_tmp468="name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_max_hyst
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_max_hyst temp2_offset
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault
	temp3_input temp3_max temp3_max_alarm temp3_max_hyst temp3_offset
	temp4_crit temp4_crit_alarm temp4_crit_hyst temp4_fault
	temp4_input temp4_max temp4_max_alarm temp4_max_hyst temp4_offset
	temp5_crit temp5_crit_alarm temp5_crit_hyst temp5_fault
	temp5_input temp5_max temp5_max_alarm temp5_max_hyst temp5_offset
	temp6_crit temp6_crit_alarm temp6_crit_hyst temp6_fault
	temp6_input temp6_max temp6_max_alarm temp6_max_hyst temp6_offset
	temp7_crit temp7_crit_alarm temp7_crit_hyst temp7_fault
	temp7_input temp7_max temp7_max_alarm temp7_max_hyst temp7_offset
	temp8_crit temp8_crit_alarm temp8_crit_hyst temp8_fault
	temp8_input temp8_max temp8_max_alarm temp8_max_hyst temp8_offset
	temp9_crit temp9_crit_alarm temp9_crit_hyst temp9_fault
	temp9_input temp9_max temp9_max_alarm temp9_max_hyst temp9_offset
	update_interval"

test_chip()
{
    local rv

    test_one attrs[@]
    rv=$((rv + $?))

    return ${rv}
}

test_chips
rv=$?

exit ${rv}
