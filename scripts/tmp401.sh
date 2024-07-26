#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

regs_401=(
	8018 0000 96 00 08 0055 0000 55 00 00 08 55 00 55 00 ff
	00 00 00 00 00 0080 0000 00 00 55 1c 1c 1c 1c 1c 1c
	55 0a 81 81 00 00 00 00 00 00 00 00 00 00 00 00
	18 80 19 00 ff f0 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 ff ff 55 11
)

regs_411=(
	8034 f07f 92 00 08 0055 0000 55 00 00 08 55 00 55 00 ff
	f0 00 00 00 00 0080 0000 00 00 55 1c ff ff ff ff ff
	55 0a 81 ff 00 00 00 ff ff ff ff ff ff ff ff ff
	22 80 72 80 7f f0 ff f0 ff ff ff ff ff ff ff ff
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
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff 55 12
)

regs_435=(
	901a 701b 00 00 05 0055 0000 55 00 00 05 55 00 55 00 0d
	70 00 00 00 00 0090 00 0000 00 55 1c 00 ff ff ff 00
	55 0a 70 101b 10 0f ff ff ff ff ff ff ff ff ff ff
	ff ff ff ff ff 00 00 00 ff ff ff ff ff ff ff ff
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
	ff ff ff ff ff ff ff ff ff ff ff ff 00 35 55 35
)

__install_regs()
{
    local regs=("${!1}")
    local i=0
    local size

    while [ $i -lt ${#regs[*]} ]
    do
	if [[ "${#regs[$i]}" -eq 4 ]]; then
	    size="w"
	else
	    size="b"
	fi
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} ${size}
	i=$(($i + 1))
    done
}

__install_regs regs_401[@]

echo "Testing tmp401"

do_instantiate tmp401 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

attrs=(name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
)
vals=(tmp401 85000 0 75000 24500 85000 0 0 0 85000 1 75000 1 0 85000 1 0 0 500)

dotest attrs[@] vals[@]
rv=$?

do_remove ${i2c_addr}

__install_regs regs_435[@]

echo "Testing tmp435"
do_instantiate tmp435 ${i2c_addr}

getbasedir ${i2c_addr}

cd ${basedir}

attrs=(name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
)
vals=(tmp435 85000 0 75000 26563 85000 0 0 0 85000 0 75000 0 27438 85000 0 0 0 500)

dotest attrs[@] vals[@]
rv=$?

for t in $(seq 1 2)
do
	# We can not test ranges on min/max attributes since the
	# read and write registers are different.
	check_range -b ${basedir} -d 500 -r -q -w 2 temp${t}_crit
	rv=$(($? + ${rv}))
	if [ $t -eq 1 ]
	then
	    check_range -b ${basedir} -d 500 -r -q -w 2 temp${t}_crit_hyst
	    rv=$(($? + ${rv}))
	fi
done

check_range -b ${basedir} -d 4000 -r -q update_interval
rv=$(($? + ${rv}))

do_remove ${i2c_addr}

i2cset -y -f ${i2c_adapter} ${i2c_addr} 0xff 0x31 b	# tmp431

echo "Testing tmp431"
do_instantiate tmp431 ${i2c_addr}

vals=(tmp431 85000 0 75000 26563 85000 0 0 0 85000 0 75000 0 27438 85000 0 0 0 500)

cd ${basedir}

dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

do_remove ${i2c_addr}

i2cset -y -f ${i2c_adapter} ${i2c_addr} 0xff 0x32 b	# tmp432
echo "Testing tmp432"
do_instantiate tmp432 ${i2c_addr}

cd ${basedir}

attrs=(name temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	temp3_crit temp3_crit_alarm temp3_crit_hyst temp3_fault
	temp3_input temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	update_interval
)
vals=(tmp432 85000 0 75000 26563 85000 0 0 0 85000 0 75000 0 27438 85000 0 0
	0 28000 0 18000 0 27063 144000 0 0 0 500)

dotest attrs[@] vals[@]
rv=$(($? + ${rv}))

for t in $(seq 1 3)
do
	# We can not test ranges on min/max attributes since the
	# read and write registers are different.
	check_range -b ${basedir} -d 500 -r -q -w 2 temp${t}_crit
	rv=$(($? + ${rv}))
	if [ $t -eq 1 ]
	then
	    check_range -b ${basedir} -d 500 -r -q -w 2 temp${t}_crit_hyst
	    rv=$(($? + ${rv}))
	fi
done

check_range -b ${basedir} -d 4000 -r -q update_interval
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null
modprobe -r tmp401 2>/dev/null

exit ${rv}
