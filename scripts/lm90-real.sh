#!/bin/bash
dir=$(dirname $0)
. ${dir}/common.sh

# reload i2c adapter driver to force detect function to run

modprobe -r i2c_diolan_u2c 2>/dev/null
modprobe i2c_diolan_u2c 2>/dev/null

modprobe -r adm1021 >/dev/null 2>&1
modprobe -r max6642 >/dev/null 2>&1
modprobe -r lm90 >/dev/null 2>&1
modprobe lm90 >/dev/null 2>&1

i2c_adapter=$(grep "i2c-diolan-u2c" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

if [[ -z "${i2c_adapter}" ]]; then
	echo "i2c adapter not found"
	exit 1
fi

attrs_adm1023="alarms name
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm
	temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_adm1032="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_adt7461="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_adt7481="name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault temp3_input
	temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	update_interval
"

attrs_adt7483a="name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault temp3_input
	temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	update_interval
"

attrs_g781="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_lm84="alarms name
	temp1_input temp1_max temp1_max_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm
"

attrs_lm86="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_lm90="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_lm99="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_max1617="alarms name
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm
	temp2_min temp2_min_alarm update_interval
"

attrs_max6642="name
	temp1_input temp1_max temp1_max_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm
"

attrs_max6646="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
"

attrs_max6649="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
"

attrs_max6657="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
"

attrs_max6659="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_emergency temp1_emergency_hyst
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_emergency temp2_emergency_hyst
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
"

attrs_max6680="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_max6690="alarms name
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_fault temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
"

attrs_max6696="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst
	temp1_emergency temp1_emergency_alarm temp1_emergency_hyst
	temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst
	temp2_emergency temp2_emergency_alarm temp2_emergency_hyst
	temp2_fault temp2_input temp2_max temp2_max_alarm
	temp2_min temp2_min_alarm
	temp3_crit temp3_crit_alarm temp3_crit_hyst
	temp3_emergency temp3_emergency_alarm temp3_emergency_hyst
	temp3_fault temp3_input
	temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	update_interval
"

attrs_nct214="name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_nct72="name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_sa56004="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_tmp451="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

attrs_tmp461="alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
"

test_chip()
{
    local rv

    echo "Running tests for ${chip}"

    echo "Testing default temperature range"

    modprobe -r lm90
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x0
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0xf 0x0
    modprobe lm90

    test_one attrs[@]
    rv=$?

    if [[ "${extended_range}" -ne 0 ]]; then
	echo "Testing extended temperature range"

	modprobe -r lm90
	i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x4
	i2cset -f -y ${i2c_adapter} ${i2c_addr} 0xf 0x0
	modprobe lm90

	test_one attrs[@]
	rv=$((rv + $?))
    fi

    return ${rv}
}

extended_range=0
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

    extended_range=0
    case "${chip}" in
    "adt7461"|"adt7481"|"adt7483a"|"tmp451"|"tmp461"|"nct72"|"nct214")
	extended_range=1
	;;
    esac

    test_chip
    rv=$((rv + $?))
done

if [[ rv -gt 0 ]]; then
    echo "### ${rv} test failure(s) ###"
else
    echo "### All tests passed ###"
fi

exit ${rv}
