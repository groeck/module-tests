#!/bin/bash

i2c_addr=0x1b

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs=(2f00 0000 0000 0000 0000 a0c1 4a10 0100 0000 0000 0000 0000 0000)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} w
	i=$(($i + 1))
done

do_instantiate jc42 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

attrs=(temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_max_hyst temp1_min temp1_min_alarm)

vals=(0 1 0 26000 0 1 0 0 0)

dotest attrs[@] vals[@]
rv=$?

check_range -b ${basedir} -d 500 -s 100 -q temp1_crit
rv=$((${rv} + $?))
check_range -b ${basedir} -d 500 -s 100 -q temp1_max
rv=$((${rv} + $?))
check_range -b ${basedir} -d 500 -s 100 -q temp1_min
rv=$((${rv} + $?))

modprobe -r i2c-stub 2>/dev/null

exit ${rv}
