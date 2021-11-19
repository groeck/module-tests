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
	echo "i2c adapter not found"
	exit 1
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

    echo "Running tests for ${chip}"

    echo "Testing default temperature range"

    modprobe -r tmp401
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x0
    modprobe tmp401

    test_one attrs[@]
    rv=$?

    echo "Testing extended temperature range"

    modprobe -r tmp401
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x4
    modprobe tmp401

    test_one attrs[@]
    rv=$((rv + $?))

    return ${rv}
}

rv=0

for hname in $(ls /sys/class/hwmon/*/name); do
    chip="$(cat ${hname})"
    basedir="$(dirname ${hname})"

    if [[ ! -e "${basedir}/device/subsystem" ]]; then
	continue
    fi

    subsystem="$(readlink ${basedir}/device/subsystem | grep i2c)"
    if [[ -z "${subsystem}" ]]; then
	continue
    fi

    i2c_addr="0x$(readlink ${basedir}/device | cut -f2 -d- | sed -e 's/^00//')"
    if [[ "${i2c_addr}" = "0x" ]]; then
	echo "Can not determine I2C base address for ${chip}, skipping test"
	continue
    fi

    cd "${basedir}"

    tmp="attrs_${chip}"
    attrs=(${!tmp})
    if [[ -z "${attrs[@]}" ]]; then
	echo "Unsupported chip \"${chip}\", skipping"
	continue
    fi

    test_chip
    rv=$((rv + $?))
done

exit ${rv}
