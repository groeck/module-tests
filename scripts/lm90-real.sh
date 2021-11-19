#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

# reload i2c adapter driver to force detect function to run

modprobe -r i2c_diolan_u2c 2>/dev/null
modprobe i2c_diolan_u2c 2>/dev/null

i2c_adapter=$(grep "i2c-diolan-u2c" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

if [[ -z "${i2c_adapter}" ]]; then
	echo "i2c adapter not found"
	exit 1
fi

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

# Check if file is writeable. We can not use '-w' since that always
# returns true when running as super-user
is_writeable()
{
    if [[ ! -e "$1" ]]; then
	return 1
    fi
    ls -l "$1" | grep -q -- "-rw-r--r--"
    return $?
}

check_alarm()
{
	local input=$1
	local limit=$2
	local hyst=$3
	local alarm=$4
	local offset=$5
	local expect=$6
	local val
	local aflag
	local rv=0
	local index

	val="$(cat ${input})"
	echo "$((offset + val))" > "${limit}"
	# echo "${limit}: $((offset + val)) [$(cat ${limit})]"
	if [[ -n "${hyst}" ]]; then
	    echo "$((offset + val - 1000))" > "${hyst}"
	    # echo "${hyst}: $((offset + val - 2000)) [$(cat ${hyst})]"
	fi

	# wait up to one second for the alarm to clear/set
	sleep 0.2
	cat ${alarm} >/dev/null
	sleep 0.2
	for index in $(seq 1 10); do
	    aflag="$(cat ${alarm})"
	    if [[ "${aflag}" -eq "${expect}" ]]; then
		break
	    fi
	    sleep 0.1
	done

	aflag="$(cat ${alarm})"
	if [[ "${aflag}" -ne "${expect}" ]]; then
	    echo "${alarm} is ${aflag}, expected ${expect} (input=$(cat ${input}), limit=$(cat ${limit}))"
	    rv=1
	fi

	return $rv
}

test_one()
{
    local t
    local rv
    local temp
    local limit
    local alarm
    local waitcmd=""
    local temp_crit_hyst=""

    # basedir was re-created; need to repeat cd
    cd "${basedir}"

    # Make sure that updates happen as fast as possible
    if is_writeable update_interval; then
	echo 1 > update_interval
    fi

    sleep 0.2

    # dummy value read to give alarms time to settle
    cat ${attrs[@]} >/dev/null 2>&1
    sleep 0.2

    local vals=($(cat ${attrs[@]} 2>/dev/null))

    dotest -p attrs[@] vals[@]
    if [[ $? -ne 0 ]]; then
	return 1
    fi

    for t in $(seq 1 ${channels})
    do
	if [[ -e "temp${t}_min" ]]; then
	    check_range -b ${basedir} -d 500 -r -q -v temp${t}_min
	    rv=$((rv + $?))
	fi
	check_range -b ${basedir} -d 500 -r -q -v temp${t}_max
	rv=$((rv + $?))
	if [[ -e "temp${t}_crit" ]]; then
	    check_range -b ${basedir} -d 500 -r -q -v temp${t}_crit
	    rv=$((rv + $?))
	    if is_writeable "temp${t}_crit_hyst"; then
	        check_range -b ${basedir} -d 500 -r -q -v temp${t}_crit_hyst
	        rv=$((rv + $?))
	        temp_crit_hyst="temp${t}_crit_hyst"
	    fi
	fi

	if [[ -e "temp${t}_emergency" ]]; then
	    check_range -b ${basedir} -d 500 -r -q -v temp${t}_emergency
	    rv=$((rv + $?))
	    if is_writeable "temp${t}_emergency_hyst"; then
	        check_range -b ${basedir} -d 500 -r -q -v temp${t}_emergency_hyst
	        rv=$((rv + $?))
	    fi
	fi

	# check alarm attributes
	if [[ -e "temp${t}_min" ]]; then
	    check_alarm "temp${t}_input" "temp${t}_min" "" "temp${t}_min_alarm" -5000 0
	    rv=$((rv + $?))
	    check_alarm "temp${t}_input" "temp${t}_min" "" "temp${t}_min_alarm" 5000 1
	    rv=$((rv + $?))
	fi

	check_alarm "temp${t}_input" "temp${t}_max" "" "temp${t}_max_alarm" -5000 1
	rv=$((rv + $?))
	check_alarm "temp${t}_input" "temp${t}_max" "" "temp${t}_max_alarm" 5000 0
	rv=$((rv + $?))

	if [[ -e "temp${t}_crit" && -e "temp${t}_crit_alarm" ]]; then
	    check_alarm "temp${t}_input" "temp${t}_crit" "${temp_crit_hyst}" "temp${t}_crit_alarm" -5000 1
	    rv=$((rv + $?))
	    check_alarm "temp${t}_input" "temp${t}_crit" "${temp_crit_hyst}" "temp${t}_crit_alarm" 5000 0
	    rv=$((rv + $?))
	fi

    done

    if [[ -w update_interval ]]; then
	check_range -b ${basedir} -d 4000 -r -q -v update_interval
	rv=$((rv + $?))
    fi

    return ${rv}
}

test_chip()
{
    local rv

    echo "Running tests for ${chip}"

    echo "Testing default temperature range"

    modprobe -r lm90
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x0
    modprobe lm90

    test_one
    rv=$?

    if [[ "${extended_range}" -ne 0 ]]; then
	echo "Testing extended temperature range"

	modprobe -r lm90
	i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x4
	modprobe lm90

	test_one
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


    # set common defaults
    channels=2
    if [[ -e "temp3_input" ]]; then
	channels=3
    fi

    extended_range=0
    case "${chip}" in
    "adt7461"|"adt7481"|"adt7483a"|"tmp451"|"tmp461")
	extended_range=1
	;;
    esac

    test_chip
done

exit ${rv}
