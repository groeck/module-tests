#!/bin/bash

i2c_addr=0x4c
chip=tmp102

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub ${i2c_addr}

i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x00 0xd90c w	# temperature sensor
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x01 0xb060 w	# reg_config
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x02 0x002d w	# temp low
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x03 0x004b w	# temp high
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x04 0xc01a w	# unknown
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x05 0xd006 w	# unknown

do_instantiate ${chip} ${i2c_addr} 2>/dev/null

getbasedir ${i2c_addr}

cd ${basedir}

attrs=(name temp1_input temp1_max temp1_max_hyst)
vals=(tmp102 25687 150000 90000)

dotest attrs[@] vals[@]
rv=$?

check_range -b ${basedir} -d 50 -q temp1_max
rv=$(($? + ${rv}))
check_range -b ${basedir} -d 50 -q temp1_max_hyst
rv=$(($? + ${rv}))

modprobe -r i2c-stub 2>/dev/null
modprobe -r tmp102

exit ${rv}
