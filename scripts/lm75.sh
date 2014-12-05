#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs=(
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
i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} w
	i=$(($i + 1))
done

# may be auto-detected
do_instantiate lm75 ${i2c_addr} 2>/dev/null

getbasedir ${i2c_addr}

cd ${basedir}

attrs=(temp1_input temp1_max temp1_max_hyst)

vals=(28000 80000 75000)

dotest attrs[@] vals[@]
rv=$?

check_range -b ${basedir} -s 100 -d 200 -r -q temp1_max
rv=$(($? + ${rv}))
check_range -b ${basedir} -s 100 -d 200 -r -q temp1_max_hyst
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
