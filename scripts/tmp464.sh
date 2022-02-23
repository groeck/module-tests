#!/bin/bash

i2c_addr=0x49

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs_tmp464=(d00a f809 080a f809 000a 080a f809 f009
	e809 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	94ff 0000 0000 0000 0000 0000 0000 0000
	0005 c05f c07f 0000 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	d00a f809 080a f809 000a 080a f809 f009
	e809 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0020 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 4954 6814
)

attrs_tmp464=(name
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
	temp1_enable temp2_enable temp3_enable temp4_enable temp5_enable
	update_interval)

vals_tmp464=(tmp464
	255500 0 245500 21625 191500 0 181500 255500 0 245500 0 19938
	191500 0 181500 0 255500 0 245500 0 20063 191500 0 181500 0
	255500 0 245500 0 19938 191500 0 181500 0 255500 0 245500 0
	20000 191500 0 181500 0 1 1 1 1 1
	500)

regs_tmp468=(d00a f809 080a f809 000a 080a f809 f009
	e809 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	94ff 0000 0000 0000 0000 0000 0000 0000
	0005 c05f c07f 0000 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	0000 0000 c05f c07f 0000 0000 0000 0000
	d00a f809 080a f809 000a 080a f809 f009
	e809 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0020 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 0000 0000
	0000 0000 0000 0000 0000 0000 4954 6804
)

attrs_tmp468=(name
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
	temp1_enable temp2_enable temp3_enable temp4_enable temp5_enable
	temp6_enable temp7_enable temp8_enable temp9_enable
	update_interval)

vals_tmp468=(tmp468
	255500 0 245500 21625 191500 0 181500 255500 0 245500 0 19938
	191500 0 181500 0 255500 0 245500 0 20063 191500 0 181500 0
	255500 0 245500 0 19938 191500 0 181500 0 255500 0 245500 0
	20000 191500 0 181500 0 255500 0 245500 0 20063 191500 0 181500
	0 255500 0 245500 0 19938 191500 0 181500 0 255500 0 245500 0 19875
	191500 0 181500 0 255500 0 245500 0 19813 191500 0 181500 0
	1 1 1 1 1 1 1 1 1 500)

# permissions_tmp468=(
# 	"-r--r--r--"
# 	"-r--r--r--"
# 	"-r--r--r--"
# 	"-r--r--r--"
# )

doinit()
{
    local regs=("${!1}")
    local i=0

    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} w
	i=$(($i + 1))
    done
}

runtest()
{
    local chip=$1
    local channels=$2
    local attrs=("${!3}")
    local vals=("${!4}")
    # local permissions=("${!5}")
    local rv

    echo "Testing ${chip}"

    do_instantiate ${chip} ${i2c_addr}

    getbasedir ${i2c_addr}

    cd ${basedir}

    # dotest attrs[@] vals[@] permissions[@]
    dotest attrs[@] vals[@]
    rv=$?

    check_range -b ${basedir} -s 200 -d 500 -r -q temp1_max_hyst
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 200 -d 8000 -r -q update_interval
    rv=$(($? + ${rv}))

    for i in $(seq 1 ${channels})
    do
	check_range -b ${basedir} -s 500 -d 200 -r -q temp${i}_max
	rv=$(($? + ${rv}))
	check_range -b ${basedir} -s 500 -d 200 -r -q temp${i}_crit
	rv=$(($? + ${rv}))
	if [[ $i -ne 1 ]]; then
	    check_range -b ${basedir} -s 500 -d 200 -r -q temp${i}_offset
	    rv=$(($? + ${rv}))
	fi
    done

    do_remove ${i2c_addr}

    return ${rv}
}

doinit regs_tmp464[@]

# runtest tmp464 attrs_tmp468[@] vals_tmp468[@] permissions_tmp468[@]
runtest tmp464 5 attrs_tmp464[@] vals_tmp464[@]
rv=$?

modprobe -r tmp464

doinit regs_tmp468[@]

# runtest tmp468 attrs_tmp468[@] vals_tmp468[@] permissions_tmp468[@]
runtest tmp468 9 attrs_tmp468[@] vals_tmp468[@]
rv=$?

modprobe -r i2c-stub 2>/dev/null
modprobe -r tmp464

exit ${rv}
