#!/bin/bash

i2c_addr=0x18
driver=lm95234

dir=$(dirname $0)
. ${dir}/common.sh

regs_lm95233=(
	00 00 00 00 02 05 0f cc aa aa 00 00 01 00 07 00
	1d 1e 1f 00 00 00 00 00 00 1e 1f 00 00 00 00 00
	a0 c8 f8 00 00 00 00 00 00 c8 f8 00 00 00 00 00
	15 00 01 02 03 04 00 00 00 00 00 00 00 00 00 00
	55 6e 6f 00 00 00 00 00 00 56 57 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 0a 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	38 94 a0 99 89 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	9f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 89
)

attrs_lm95233=(name
	temp1_input temp1_max temp1_max_alarm temp1_max_hyst temp1_enable
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_max_hyst temp2_offset temp2_type temp2_enable
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault temp3_input
	temp3_max temp3_max_alarm temp3_max_hyst temp3_offset temp3_type temp3_enable
	update_interval
)

vals_lm95233=(
	lm95233
	29625 85000 0 75000 1
	110000 1 100000 0 30781
	86000 1 76000 0 2 0
	111000 0 101000 1 31969
	87000 0 77000 500 1 1
	1000
)

permissions_lm95233=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_lm95234=(
	00 00 00 00 02 1a 0f 33 55 55 00 00 01 00 07 00
	1d 1e 1f 20 21 00 00 00 00 1e 1f 20 21 00 00 00
	00 28 48 60 80 00 00 00 00 28 48 60 80 00 00 00
	0a 00 01 02 03 04 00 00 00 00 00 00 00 00 00 00
	55 6e 6f 56 57 00 00 00 00 55 56 57 58 00 00 00
	00 00 00 00 00 00 00 00 00 00 0a 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	38 94 a0 99 89 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	9f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 79
)

attrs_lm95234=(name
	temp1_input temp1_max temp1_max_alarm temp1_max_hyst temp1_enable
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_max_hyst temp2_offset temp2_type temp2_enable
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault temp3_input
	temp3_max temp3_max_alarm temp3_max_hyst temp3_offset temp3_type temp3_enable
	temp4_fault temp4_input temp4_max temp4_max_alarm temp4_max_hyst
	temp4_offset temp4_type temp4_enable
	temp5_fault temp5_input temp5_max temp5_max_alarm temp5_max_hyst
	temp5_offset temp5_type temp5_enable
	update_interval
)

vals_lm95234=(
	lm95234
	29000 85000 1 75000 0
	110000 0 100000 1 30156
	85000 0 75000 0 1 1
	111000 1 101000 0 31281
	86000 1 76000 500 2 0
	1 32375 86000 0 76000
	1000 1 1
	0 33500 87000 1 77000
	1500 2 1
	1000
)

permissions_lm95234=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
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

    check_range -s 250 -d 500 -r -q temp1_max_hyst
    rv=$((rv + $?))

    for i in $(seq 1 ${channels}); do
	check_range -s 250 -d 500 -r -q -v temp${i}_max
	rv=$((rv + $?))
	if [[ $i -ge 2 ]]; then
	    check_range -s 250 -d 500 -r -q temp${i}_offset
	    rv=$((rv + $?))
	    check_range -R "1 2 : 0 9 3" -r -q temp${i}_type
	    rv=$((rv + $?))
	    if [[ $i -lt 4 ]]; then
		check_range -s 250 -d 500 -r -q temp${i}_crit
		rv=$((rv + $?))
	    fi
	fi
    done

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest lm95233 3 regs_lm95233[@] attrs_lm95233[@] vals_lm95233[@] permissions_lm95233[@]
rv=$((rv + $?))
runtest lm95234 5 regs_lm95234[@] attrs_lm95234[@] vals_lm95234[@] permissions_lm95234[@]
rv=$((rv + $?))

exit ${rv}
