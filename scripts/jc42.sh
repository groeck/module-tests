#!/bin/bash

i2c_addr=0x1b

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs=(2f00 0000 0000 0000 f0c1 a0c1 4a10 0100 0000 0000 0000 0000 0000)

attrs=(name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_max_hyst temp1_min temp1_min_alarm)

vals=(jc42 31000 1 31000 26000 0 1 0 0 0)

permissions=(
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
)

i=0
while [ $i -lt ${#regs[*]} ]
do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} w
	i=$(($i + 1))
done

do_instantiate jc42 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

dotest attrs[@] vals[@] permissions[@]
rv=$?

check_range -b ${basedir} -d 500 -s 100 -q -r temp1_crit
rv=$((${rv} + $?))
check_range -b ${basedir} -d 500 -s 100 -q temp1_max
rv=$((${rv} + $?))
check_range -b ${basedir} -d 500 -s 100 -q temp1_min
rv=$((${rv} + $?))
check_range -b ${basedir} -l 25000 -d 1500 -q temp1_crit_hyst
rv=$((${rv} + $?))

check_volatile -s '1.1' "${i2c_adapter}" "${i2c_addr}" 0x05 ws 0x0100 0x0300 0x0040 temp1_input 16000 4000

modprobe -r i2c-stub 2>/dev/null
modprobe -r jc42

exit ${rv}
