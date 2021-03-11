#!/bin/bash

i2c_addr=0x2c

dir=$(dirname $0)
. ${dir}/common.sh

adm9240_regs=(
	b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1 b1
	b1 b1 b1 b1 b1 00 00 00 00 ff ff ff ff ff ff ff
	74 8f c2 c7 c5 b7 b6 21 60 ff ff 7e 69 97 82 ca
	b6 ca b6 d3 ad ba a0 a0 a0 32 2d 8c ff ff 23 02
	01 00 00 00 00 00 00 b1 2d 80 80 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 00 00 00 00 ff ff ff ff ff ff ff
	74 8f c2 c7 c5 b7 b6 21 60 ff ff 7e 69 97 82 ca
	b6 ca b6 d3 ad ba a0 a0 a0 32 2d 8c ff ff 23 02
	01 00 00 00 00 00 00 b1 2d 80 80 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
	01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
)

adm9240_attrs=(name alarms aout_output cpu0_vid
	fan1_alarm fan1_div fan1_input fan1_min
	fan2_alarm fan2_div fan2_input fan2_min
	in0_alarm in0_input in0_max in0_min
	in1_alarm in1_input in1_max in1_min
	in2_alarm in2_input in2_max in2_min
	in3_alarm in3_input in3_max in3_min
	in4_alarm in4_input in4_max in4_min
	in5_alarm in5_input in5_max in5_min
	intrusion0_alarm
	temp1_alarm temp1_input temp1_max temp1_max_hyst
	)

adm9240_vals=(adm9240 0 1250 0 0 8 1758 1205 0 4 0 0 0 1510 1641 1367 0
	2011 2123 1828 0 3334 3472 3128 0 5182 5260 4740 0 12313 13188 10813 0
	2573 2616 2250 0 0 33000 50000 45000
	)

adm9240_perm=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

lm81_regs=(
	47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47
	47 81 24 03 94 00 00 00 00 ff ff ff ff ff ff ff
	bf cb c1 00 c0 47 ec 24 ff ff 65 ff 00 ff 00 ff
	00 ff 00 ff 00 ff 00 71 a9 7f 7f ff ff 58 01 04
	01 08 00 00 00 00 00 50 2f 80 80 01 44 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 81 24 03 94 00 00 00 00 ff ff ff ff ff ff ff
	bf cb c1 00 c0 47 ec 24 ff ff 65 ff 00 ff 00 ff
	00 ff 00 ff 00 ff 00 71 a9 7f 7f ff ff 58 01 04
	01 00 00 00 00 00 00 50 2f 80 80 01 44 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
)

lm81_vals=(lm81 8 1250 0 0 2 0 0 0 2 0 0 0 2487 3320 0
	0 2855 3586 0 0 3317 4383 0 1 0 6641 0 0 12000 15938 0
	0 998 3586 0 0 0 36000 127000 127000
)

lm81_regs2=(
	ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
	ff 81 24 03 94 00 00 00 00 ff ff ff ff ff ff ff
	bf cc c1 00 c0 47 ec 1c ff ff 65 dc b4 ff c0 d3
	ad ff 00 d3 ad 4e 40 71 a9 4b 46 ff ff 58 01 04
	01 08 00 00 00 00 00 f0 2f 80 80 81 44 80 80 80
	80 80 80 80 80 80 80 80 80 80 80 80 80 80 80 80
	80 80 80 80 80 80 80 80 80 80 80 80 80 80 80 80
	80 80 80 80 80 80 80 80 80 80 80 80 80 80 80 80
	80 80 80 80 80 80 80 80 80 80 80 80 80 80 80 80
	80 81 24 03 94 00 00 00 00 ff ff ff ff ff ff ff
	bf cc c1 00 c0 47 ec 1c ff ff 65 dc b4 ff c0 d3
	ad ff 00 d3 ad 4e 40 71 a9 4b 46 ff ff 58 01 04
	01 00 00 00 00 00 00 f0 2f 80 80 81 44 80 80 80
	80 80 80 80 80 80 80 80 80 80 80 80 80 80 80 80
	80 80 80 80 80 80 80 80 80 80 80 80 80 80 80 80
	80 80 80 80 80 80 80 80 80 80 80 80 80 80 80 80
)

lm81_vals2=(lm81 8 1250 0 0 8 0 0 0 8
	0 0 0 2487 2865 2344 0 2869 3586 2700
	0 3317 3627 2973 1 0 6641 0 0 12000
	13188 10813 0 998 1097 900 0 0 28500 75000 70000
)

runtest()
{
    local chip=$1
    local regs=("${!2}")
    local attrs=("${!3}")
    local vals=("${!4}")
    local rv

    echo Testing ${chip} ...

    load_i2c_stub ${i2c_addr}

    install_regs ${i2c_adapter} ${i2c_addr} regs[@] b

    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

# grep . *
# ls -l

    dotest attrs[@] vals[@]
    rv=${rv}

    for i in $(seq 0 5)
    do
	check_range -b ${basedir} -d 31 -r -q "in${i}_min"
	rv=$(($? + rv))
	check_range -b ${basedir} -d 31 -r -q "in${i}_max"
	rv=$(($? + rv))
    done

    for i in $(seq 1 1)
    do
	check_range -b ${basedir} -d 500 -r -q temp${i}_max
	rv=$(($? + rv))
	check_range -b ${basedir} -d 500 -r -q temp${i}_max_hyst
	rv=$(($? + rv))
    done

    for i in $(seq 1 2)
    do
	check_range -b ${basedir} -l 0 -u 20000 -d 500 -r -q fan${i}_min
	rv=$(($? + rv))
    done

    check_range -b ${basedir} -r -q -d 2 aout_output
    rv=$(($? + rv))

    check_range -b ${basedir} -l 0 -u 0 -d 0 -r -q intrusion0_alarm
    rv=$(($? + rv))

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

runtest adm9240 adm9240_regs[@] adm9240_attrs[@] adm9240_vals[@] adm9240_perm[@]
rv=$?

runtest lm81 lm81_regs[@] adm9240_attrs[@] lm81_vals[@] adm9240_perm[@]
rv=$((rv + $?))

runtest lm81 lm81_regs2[@] adm9240_attrs[@] lm81_vals2[@] adm9240_perm[@]
rv=$((rv + $?))

modprobe -r adm9240

exit ${rv}
