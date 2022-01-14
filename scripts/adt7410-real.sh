#!/bin/bash
dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r adt7410 >/dev/null 2>&1
modprobe -r adt7x10 >/dev/null 2>&1
modprobe adt7410 >/dev/null 2>&1

i2c_adapter=$(grep "i2c-diolan-u2c" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)
if [[ -z "${i2c_adapter}" ]]; then
    i2c_adapter=$(grep "i2c-devantech-iss" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)
    if [[ -z "${i2c_adapter}" ]]; then
	echo "i2c adapter not found"
	exit 1
    fi
fi

attrs_adt7420="name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_max_hyst temp1_min temp1_min_alarm temp1_min_hyst
"

test_chip()
{
    local chip="$1"
    local rv
    local extended_range=0

    test_one attrs[@]
    rv=$?

    return ${rv}
}

# The chip needs to be instantiated manually.
# Unfortunately that means that we need to know its I2C address.

if i2cget -y -f "${i2c_adapter}" 0x48 0 >/dev/null 2>&1; then
    echo adt7420 0x48 > "/sys/class/i2c-adapter/i2c-${i2c_adapter}/new_device" >/dev/null 2>&1
fi

test_chips
rv=$?

exit ${rv}
