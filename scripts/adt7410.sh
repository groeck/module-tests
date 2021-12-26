#!/bin/bash

i2c_addr=0x48

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs=(0c 58 00 00 20 00 05 00 49 80 05 cb 00 00 00 00
	00 00 00 00 00 00 00 00 58 00 06 00 00 00 00 00
	0c 58 80 00 20 00 05 00 49 80 05 cb 00 00 00 00
	00 00 00 00 00 00 00 00 58 00 06 00 00 00 00 00
	00 00 80 00 20 00 05 00 49 80 05 cb 00 00 00 00
	00 00 00 00 00 00 00 00 58 00 06 00 00 00 00 00
	00 00 80 00 20 00 05 00 49 80 05 cb 00 00 00 00
	00 00 00 00 00 00 00 00 58 00 06 00 00 00 00 00
	00 00 80 00 20 00 05 00 49 80 05 cb 00 00 00 00
	00 00 00 00 00 00 00 00 58 00 06 00 00 00 00 00
	00 00 80 00 20 00 05 00 49 80 05 cb 00 00 00 00
	00 00 00 00 00 00 00 00 58 00 06 00 00 00 00 00
	00 00 80 00 20 00 05 00 49 80 05 cb 00 00 00 00
	00 00 00 00 00 00 00 00 58 00 06 00 00 00 00 00
	00 00 80 00 20 00 05 00 49 80 05 cb 00 00 00 00
	00 00 00 00 00 00 00 00 58 00 06 00 00 00 00 00
)

attrs=(name
	temp1_crit temp1_crit_alarm temp1_crit_hyst
	temp1_input
	temp1_max temp1_max_alarm temp1_max_hyst
	temp1_min temp1_min_alarm temp1_min_hyst
)

vals=(adt7410
	146000 0 141000 24000 64000 0 59000 10000 0 15000
)

permissions=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
)

doinit()
{
    local regs=("${!1}")
    local i=0

    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
    done
}

runtest()
{
    local chip=$1
    local attrs=("${!2}")
    local vals=("${!3}")
    local permissions=("${!4}")
    local rv

    echo "Testing ${chip}"

    do_instantiate ${chip} ${i2c_addr}

    getbasedir ${i2c_addr}

    cd ${basedir}

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    check_range -b ${basedir} -d 10 -r -q "temp1_min"
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 10 -r -q "temp1_max"
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 500 -r -q "temp1_max_hyst"
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -d 10 -r -q "temp1_crit"
    rv=$(($? + ${rv}))

    do_remove ${i2c_addr}

    return ${rv}
}

doinit regs[@]

runtest adt7410 attrs[@] vals[@] permissions[@]
rv=$?

modprobe -r i2c-stub 2>/dev/null
modprobe -r adt7410
modprobe -r adt7x10

exit ${rv}
