#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

regs_lm75=(
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
	7f1c ff00 7f4b 7f50 7f50 7f50 7f50 7f50
)

attrs_lm75=(name temp1_input temp1_max temp1_max_hyst update_interval)
vals_lm75=(lm75 28000 80000 75000 500)

regs_ds75=(
	7f1c 0030 004b 0050 0050 0050 0050 0050
	0050 0050 0050 0050 0050 0050 0050 0050
)

attrs_ds75=(name temp1_input temp1_max temp1_max_hyst update_interval)
vals_ds75=(ds75 28375 80000 75000 1000)

runtest()
{
    local chip=$1
    local regs=("${!2}")
    local attrs=("${!3}")
    local vals=("${!4}")
    local rv
    local i

    load_i2c_stub ${i2c_addr}

    i=0
    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} w
	i=$(($i + 1))
    done

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    dotest attrs[@] vals[@]
    rv=$?

    check_range -b ${basedir} -s 100 -d 200 -r -q temp1_max
    rv=$(($? + rv))

    check_range -b ${basedir} -s 100 -d 200 -r -q temp1_max_hyst
    rv=$(($? + rv))

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

runtest lm75 regs_lm75[@] attrs_lm75[@] vals_lm75[@]
rv=$?
runtest ds75 regs_ds75[@] attrs_ds75[@] vals_ds75[@]
rv=$(($? + ${rv}))

modprobe -r lm75

exit ${rv}
