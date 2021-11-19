#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

# reload driver

# modprobe -r tmp401 2>/dev/null
modprobe tmp401 2>/dev/null

# reload i2c adapter driver to force detect function to run

modprobe -r i2c_diolan_u2c 2>/dev/null
modprobe i2c_diolan_u2c 2>/dev/null

i2c_adapter=$(grep "i2c-diolan-u2c" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

if [[ -z "${i2c_adapter}" ]]; then
	echo "i2c adapter not found"
	exit 1
fi

getbasedir "${i2c_addr}"

if [[ -z "${basedir}" ]]; then
	echo "driver directory not found"
	exit 1
fi

cd "${basedir}"

attrs_tmp401=(name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
)

attrs_tmp411=(name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_highest
	temp1_input temp1_lowest temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_highest
	temp2_input temp2_lowest temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
	temp_reset_history
)

attrs_tmp432=(name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault
	temp3_input temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	update_interval
)

attrs_tmp435=(name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
)

chip="$(cat name)"

case "${chip}" in
"tmp401"|"tmp431")
	attrs=(${attrs_tmp401[@]})
	channels=2
	;;
"tmp411")
	attrs=(${attrs_tmp411[@]})
	channels=2
	;;
"tmp432")
	attrs=(${attrs_tmp432[@]})
	channels=3
	;;
"tmp435")
	attrs=(${attrs_tmp435[@]})
	channels=2
	;;
*)
	echo "Unsupported chip \"${chip}\", aborting"
	exit 1
	;;
esac

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

test_chip()
{
    local t
    local rv
    local temp
    local limit
    local alarm
    local waitcmd=""

    dotest attrs[@] vals[@]
    rv=$?

    # Make sure that alarms are updated as fast as possible
    echo 125 > update_interval

    for t in $(seq 1 ${channels})
    do
	check_range -b ${basedir} -d 500 -r -q -v temp${t}_min
	rv=$((rv + $?))
	check_range -b ${basedir} -d 500 -r -q -v temp${t}_max
	rv=$((rv + $?))
	check_range -b ${basedir} -d 500 -r -q -v temp${t}_crit
	rv=$((rv + $?))
	if [ $t -eq 1 ]
	then
	    check_range -b ${basedir} -d 500 -r -q -v temp${t}_crit_hyst
	    rv=$((rv + $?))
	fi

	# check alarm attributes
	check_alarm "temp${t}_input" "temp${t}_min" "" "temp${t}_min_alarm" -5000 0
	rv=$((rv + $?))
	check_alarm "temp${t}_input" "temp${t}_min" "" "temp${t}_min_alarm" 5000 1
	rv=$((rv + $?))

	check_alarm "temp${t}_input" "temp${t}_max" "" "temp${t}_max_alarm" -5000 1
	rv=$((rv + $?))
	check_alarm "temp${t}_input" "temp${t}_max" "" "temp${t}_max_alarm" 5000 0
	rv=$((rv + $?))

	check_alarm "temp${t}_input" "temp${t}_crit" "temp${t}_crit_hyst" "temp${t}_crit_alarm" -5000 1
	rv=$((rv + $?))
	check_alarm "temp${t}_input" "temp${t}_crit" "temp${t}_crit_hyst" "temp${t}_crit_alarm" 5000 0
	rv=$((rv + $?))

    done

    check_range -b ${basedir} -d 4000 -r -q -v update_interval
    rv=$((rv + $?))

    return ${rv}
}

echo "Running tests for ${chip}"

echo "Testing default temperature range"

i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x0
# Re-instantiate driver with new configuration
modprobe -r tmp401
modprobe tmp401

# basedir was re-created; need to repeat cd
cd "${basedir}"

# Make sure that updates happen as fast as possible
echo 125 > update_interval

sleep 0.2
vals=($(cat ${attrs[@]} 2>/dev/null))

test_chip
rv=$?

# wait to be sure the cache is clean
sleep 2

echo "Testing extended temperature range"

i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x4

# Re-instantiate driver with new configuration
modprobe -r tmp401
modprobe tmp401

# basedir was re-created; need to repeat cd
cd "${basedir}"

# Make sure that updates happen as fast as possible
echo 125 > update_interval
sleep 0.2

vals=($(cat ${attrs[@]} 2>/dev/null))

test_chip
rv=$((rv + $?))

# modprobe -r tmp401 2>/dev/null

exit ${rv}
