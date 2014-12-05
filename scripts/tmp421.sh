#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs=(19 19 19 45 ff ff ff ff 80 00 1c 07 ff ff ff 01
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

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
done

do_instantiate tmp421 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

attrs=(temp1_input temp2_fault temp2_input)
vals=(25000 1 25000)
dotest attrs[@] vals[@]
rv=$?

do_remove ${i2c_addr}

i2cset -y -f ${i2c_adapter} ${i2c_addr} 0xff 0x22 b	# tmp422
do_instantiate tmp422 ${i2c_addr}

cd ${basedir}

attrs=(temp1_input temp2_fault temp2_input temp3_fault temp3_input)
vals=(25000 1 25000 0 25000)
dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

do_remove ${i2c_addr}

i2cset -y -f ${i2c_adapter} ${i2c_addr} 0xff 0x23 b	# tmp423
do_instantiate tmp423 ${i2c_addr}

cd ${basedir}

attrs=(temp1_input temp2_fault temp2_input temp3_fault temp3_input temp4_fault temp4_input)
vals=(25000 1 25000 0 25000 0 69063)
dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
