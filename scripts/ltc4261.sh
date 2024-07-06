#!/bin/bash

i2c_addr=0x17
chip="ltc4261"

dir=$(dirname $0)
. ${dir}/common.sh

load_i2c_stub "${i2c_addr}"
modprobe -r "${chip}"

i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x0 0x90 b	# status
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x1 0x00 b	# fault
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x2 0xff b	# alert
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x3 0x1f b	# control
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x4 0x22 b	# sense MSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x5 0x80 b	# sense LSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x6 0x77 b	# ADIN2/OV MSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x7 0xc0 b	# ADIN2/OV LSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x8 0x88 b	# ADIN MSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x00 b	# ADIN LSB

do_instantiate ${chip} ${i2c_addr} 2>/dev/null
getbasedir ${i2c_addr}

cd ${basedir}

attrs=(name
	curr1_input curr1_max_alarm
	in1_input in1_max_alarm in1_min_alarm in1_fault
	in2_input in2_max_alarm in2_min_alarm
)
vals=(ltc4261 8625 0 1360 0 0 0 1197 0 0)

permissions=(
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
)

dotest attrs[@] vals[@] permissions[@]
rv=$?

# Set all alarms and different ADC values, and try again

i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x1 0xff b	# fault
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x4 0x33 b	# sense MSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x5 0xc0 b	# sense LSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x6 0x44 b	# ADIN2/OV MSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x7 0x00 b	# ADIN2/OV LSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x8 0x33 b	# ADIN MSB
i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x80 b	# ADIN LSB

vals=(ltc4261 12937 1 515 1 1 1 680 1 1)

dotest attrs[@] vals[@] permissions[@]
rv=$((rv + $?))

modprobe -r i2c-stub 2>/dev/null
modprobe -r ltc4261

exit ${rv}
