#!/bin/bash
dir=$(dirname $0)
. ${dir}/common.sh

modprobe -r i2c_diolan_u2c 2>/dev/null
modprobe i2c_diolan_u2c 2>/dev/null
modprobe -r i2c_devantech_iss 2>/dev/null
modprobe i2c_devantech_iss 2>/dev/null

modprobe -r tmp421 2>/dev/null
modprobe tmp421 2>/dev/null

i2c_adapter=$(grep "i2c-diolan-u2c" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)
if [[ -z "${i2c_adapter}" ]]; then
    i2c_adapter=$(grep "i2c-devantech-iss" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)
    if [[ -z "${i2c_adapter}" ]]; then
        echo "i2c adapter not found"
        exit 1
    fi
fi

attrs_tmp421="name temp1_fault temp1_input temp2_fault temp2_input"
attrs_tmp422="name temp1_fault temp1_input temp2_fault temp2_input temp3_fault temp3_input"
attrs_tmp423="name temp1_fault temp1_input temp2_fault temp2_input temp3_fault temp3_input temp4_fault temp4_input"
attrs_tmp441="name temp1_fault temp1_input temp2_fault temp2_input"
attrs_tmp442="name temp1_fault temp1_input temp2_fault temp2_input temp3_fault temp3_input"

test_chip()
{
    local rv

    echo "  Testing default temperature range"

    modprobe -r tmp421
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x0
    modprobe tmp421

    test_one attrs[@]
    rv=$?

    echo "  Testing extended temperature range"

    modprobe -r tmp421
    i2cset -f -y ${i2c_adapter} ${i2c_addr} 0x9 0x4
    # alarms need time to settle
    sleep 0.1
    modprobe tmp421

    test_one attrs[@]
    rv=$((rv + $?))

    return ${rv}
}

test_chips
rv=$?


exit ${rv}
