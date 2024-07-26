#!/bin/bash

i2c_addr=0x48
driver=max16065

dir=$(dirname $0)
. ${dir}/common.sh

regs_max16065=(
	7d 40 65 40 50 00 3b c0 28 80 15 00 97 00 8e 80
	6e 00 50 c0 36 00 1b c0 51 79 40 55 aa 00 00 00
	00 0e 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 09 1a ff 18 1a ff 18 1a ff
	18 1a ff 18 1a ff 18 1a ff 18 1a ff 18 1a ff 18
	1a ff 18 1a ff 18 1a ff 18 1a ff 18 00 00 00 00
	00 00 00 01 1e 00 00 cc cc cc cc cc cc cc 12 34
	56 78 9a bc 12 34 56 78 9a bc 00 00 02 01 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_max16065=(name
	curr1_alarm curr1_input
	in0_alarm in0_crit in0_input in0_lcrit in0_min
	in10_alarm in10_crit in10_input in10_lcrit in10_min
	in11_alarm in11_crit in11_input in11_lcrit in11_min
	in12_input
	in1_alarm in1_crit in1_input in1_lcrit in1_min
	in2_alarm in2_crit in2_input in2_lcrit in2_min
	in3_alarm in3_crit in3_input in3_lcrit in3_min
	in4_alarm in4_crit in4_input in4_lcrit in4_min
	in5_alarm in5_crit in5_input in5_lcrit in5_min
	in6_alarm in6_crit in6_input in6_lcrit in6_min
	in7_alarm in7_crit in7_input in7_lcrit in7_min
	in8_alarm in8_crit in8_input in8_lcrit in8_min
	in9_alarm in9_crit in9_input in9_lcrit in9_min
)

vals_max16065=(max16065
	0 18529
	1 5538 2720 521 565
	0 5538 1173 521 565
	1 5538 603 521 565
	3315
	0 5538 2199 521 565
	1 5538 1738 521 565
	0 5538 1298 521 565
	1 5538 880 521 565
	0 5538 456 521 565
	1 5538 3280 521 565
	0 5538 3095 521 565
	0 5538 2389 521 565
	1 5538 1754 521 565
)

permissions_max16065=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_max16066=(
	7d 40 65 40 50 00 3b c0 28 80 15 00 97 00 8e 80
	6e 00 50 c0 36 00 1b c0 51 79 40 aa 55 00 00 00
	00 0e 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 09 e0 ff 18 e0 ff 18 e0 ff
	18 e0 ff 18 e0 ff 18 e0 ff 18 e0 ff 18 e0 ff 18
	e0 ff 18 1a ff 18 1a ff 18 1a ff 18 00 00 00 00
	00 00 00 09 1e 00 00 cc cc cc cc cc cc cc 12 34
	56 78 9a bc 12 34 56 78 9a bc 00 00 02 01 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_max16066=(name
	curr1_alarm curr1_input
	in0_alarm in0_crit in0_input in0_lcrit in0_max
	in12_input
	in1_alarm in1_crit in1_input in1_lcrit in1_max
	in2_alarm in2_crit in2_input in2_lcrit in2_max
	in3_alarm in3_crit in3_input in3_lcrit in3_max
	in4_alarm in4_crit in4_input in4_lcrit in4_max
	in5_alarm in5_crit in5_input in5_lcrit in5_max
	in6_alarm in6_crit in6_input in6_lcrit in6_max
	in7_alarm in7_crit in7_input in7_lcrit in7_max
)

vals_max16066=(max16066
	1 18529
	0 5538 2720 521 4865
	3315
	1 5538 2199 521 4865
	0 5538 1738 521 4865
	1 5538 1298 521 4865
	0 5538 880 521 4865
	1 5538 456 521 4865
	0 5538 3280 521 4865
	1 5538 3095 521 4865
)

permissions_max16066=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_max16067=(
	7d 40 65 40 50 00 3b c0 28 80 15 00 97 00 8e 80
	6e 00 50 c0 36 00 1b c0 51 79 40 28 02 00 00 00
	00 0e 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 09 1a ff 18 1a ff 18 1a ff
	18 1a ff 18 1a ff 18 1a ff 18 1a ff 18 1a ff 18
	1a ff 18 1a ff 18 1a ff 18 1a ff 18 00 00 00 00
	00 00 00 01 1e 00 00 cc cc cc cc cc cc cc 12 34
	56 78 9a bc 12 34 56 78 9a bc 00 00 02 01 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

attrs_max16067=(name
	in0_alarm in0_crit in0_input in0_lcrit
	in1_alarm in1_crit in1_input in1_lcrit
	in2_alarm in2_crit in2_input in2_lcrit
	in3_alarm in3_crit in3_input in3_lcrit
	in4_alarm in4_crit in4_input in4_lcrit
	in5_alarm in5_crit in5_input in5_lcrit
)

vals_max16067=(max16067
	0 5538 2720 521
	1 5538 2199 521
	0 5538 1738 521
	1 5538 1298 521
	0 5538 880 521
	1 5538 456 521
)

permissions_max16067=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
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

    install_regs ${i2c_adapter} ${i2c_addr} regs[@]

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

    # i2cdump -y -f ${i2c_adapter} ${i2c_addr} w
    # grep . *
    # ls -l

    dotest attrs[@] vals[@]
    rv=$?

    for i in $(seq 0 $((channels - 1))); do
	check_range -r -q -d 11 "in${i}_lcrit"
	rv=$(($? + rv))
	check_range -r -q -d 11 "in${i}_crit"
	rv=$(($? + rv))
	if [[ -e "in${i}_min" ]]; then
	    check_range -r -q -d 11 "in${i}_min"
	fi
	if [[ -e "in${i}_max" ]]; then
	    check_range -r -q -d 11 "in${i}_max"
	fi
	rv=$(($? + rv))
    done

    modprobe -r i2c-stub 2>/dev/null
    return ${rv}
}

runtest max16065 12 regs_max16065[@] attrs_max16065[@] vals_max16065[@] permissions_max16065[@]
rv=$?
runtest max16066 8 regs_max16066[@] attrs_max16066[@] vals_max16066[@] permissions_max16066[@]
rv=$((rv + $?))
runtest max16067 6 regs_max16067[@] attrs_max16067[@] vals_max16067[@] permissions_max16067[@]
rv=$((rv + $?))

exit ${rv}
