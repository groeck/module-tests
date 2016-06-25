#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs_tmp421=(19 19 19 45 ff ff ff ff 80 00 1c 07 ff ff ff 01
	00 01 00 10 ff ff ff ff ff ff ff ff ff ff ff ff
	ff 00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff 55 21
)

attrs_tmp421=(name temp1_input temp2_fault temp2_input)
vals_tmp421=(tmp421 25000 1 25000)

permissions_tmp421=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
)

attrs_tmp422=(name temp1_input temp2_fault temp2_input temp3_fault temp3_input)
vals_tmp422=(tmp422 25000 1 25000 0 25000)

permissions_tmp422=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
)

attrs_tmp423=(name temp1_input temp2_fault temp2_input temp3_fault temp3_input temp4_fault temp4_input)
vals_tmp423=(tmp423 25000 1 25000 0 25000 0 69063)

permissions_tmp423=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
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

    do_remove ${i2c_addr}

    return ${rv}
}

doinit regs_tmp421[@]

runtest tmp421 attrs_tmp421[@] vals_tmp421[@] permissions_tmp421[@]
rv=$?

i2cset -y -f ${i2c_adapter} ${i2c_addr} 0xff 0x22 b	# tmp422
runtest tmp422 attrs_tmp422[@] vals_tmp422[@] permissions_tmp422[@]
rv=$(($? + ${rv}))

i2cset -y -f ${i2c_adapter} ${i2c_addr} 0xff 0x23 b	# tmp423

runtest tmp423 attrs_tmp423[@] vals_tmp423[@] permissions_tmp423[@]
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
