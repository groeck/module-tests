#!/bin/bash

i2c_addr=0x4c

dir=$(dirname $0)
. ${dir}/common.sh

regs_max6695=(
	16 80 8c 00 06 46 c9 46 c9 c9 c9 c9 c9 c9 c9 c9
	00 00 5e 00 00 00 78 5a 5a 5a 5a 5a 5a 5a 5a 5a
	46 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 4d 01
)

attrs_max6695=(alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst
	temp1_emergency temp1_emergency_alarm temp1_emergency_hyst
	temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst
	temp2_emergency temp2_emergency_alarm temp2_emergency_hyst
	temp2_fault temp2_input temp2_max temp2_max_alarm
	temp2_min temp2_min_alarm
	temp3_crit temp3_crit_alarm temp3_crit_hyst
	temp3_emergency temp3_emergency_alarm temp3_emergency_hyst
	temp3_fault temp3_input
	temp3_max temp3_max_alarm temp3_min temp3_min_alarm
	update_interval
)

vals_max6695=(24204 max6695 70000 0 60000 90000 0 80000
	22000 70000 0 -55000 0 90000 0 80000 120000
	0 110000 1 -128000 70000 0 -55000 1 90000 1 80000
	120000 1 110000 1 -128000 70000 1 -55000 1 500
)

permissions_max6695=(
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-r--r--r--"
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
)

regs_lm86=(
	30 37 00 00 05 46 00 46 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 55 00 00 00 00 00 00
	55 0a 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	4f 20 40 b3 98 00 0d 00 00 4b 4b 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 11
)

attrs_lm86=(alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst
	temp1_input temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min temp2_min_alarm
	temp2_offset update_interval
)

vals_lm86=(0 lm86 85000 0 75000 48000 70000 0
	0 0 85000 0 75000 0 55000 70000 0 0 0 0 500
)

permissions_lm86=(
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_g781=(
	11 0D 80 00 08 55 00 55 00 00 08 55 00 55 00 11
	D0 00 00 00 00 11 11 11 11 55 11 11 11 11 11 11
	55 0A 00 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
	11 06 FF 00 FF E0 00 FF 11 11 11 11 11 11 47 01
)

attrs_g781=(alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input temp1_max
	temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
)

vals_g781=(128 g781 85000 0 75000 17000 85000 0
	0 0 85000 0 75000 0 13750 85000 0 0 0 0 500
)

permissions_g781=(
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_adt7461=(
	67 75 53 04 05 55 00 55 00 04 05 55 00 55 00 00
	00 00 00 00 00 80 80 00 00 55 00 00 00 00 00 00
	55 0a 01 00 00 00 00 00 00 c3 00 00 00 00 00 00
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
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 41 51
)

attrs_adt7461=(alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault temp2_input
	temp2_max temp2_max_alarm temp2_min temp2_min_alarm temp2_offset
	update_interval
)

vals_adt7461=(83 adt7461 21000 1 11000 39000 21000 1 -64000 0
	21000 1 11000 0 53000 21000 1 -64000 0 -64000 500
)

permissions_adt7461=(
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_adm1032=(
	18 19 80 00 08 55 00 55 00 00 08 55 00 55 00 00
	00 00 00 00 00 80 80 00 00 55 00 00 00 00 00 00
	55 0a 01 00 00 00 00 00 00 e3 00 00 00 00 00 00
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
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 41 42
)

attrs_adm1032=(alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min
	temp2_min_alarm temp2_offset update_interval
)

vals_adm1032=(128 adm1032 85000 0 75000 24000 85000 0 0 0
	85000 0 75000 0 25000 85000 0 0 0 0 500
)

permissions_adm1032=(
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_tmp451=(
	5d 69 00 04 08 bf 00 ff 53 00 00 00 00 00 00 00
	a0 00 00 00 00 f0 00 00 00 a9 00 00 00 00 00 00
	b8 0a 01 00 00 00 00 00 00 00 0e 00 00 00 00 00
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
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 00
)

attrs_tmp451=(alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min
	temp2_min_alarm temp2_offset update_interval
)

vals_tmp451=(0 tmp451 120000 0 110000 29750 127000 0 -64000 0
	105000 0 95000 0 41500 191000 0 19000 0 -64000 500
)

permissions_tmp451=(
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_sa56004=(
	36 7f 16 80 05 46 00 46 00 00 00 00 00 00 00 00
	2c 00 00 00 00 00 00 00 00 55 00 00 00 00 00 00
	55 0a 80 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	07 05 26 48 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 a1 00
)

attrs_sa56004=(alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_input
	temp1_max temp1_max_alarm temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_fault
	temp2_input temp2_max temp2_max_alarm temp2_min
	temp2_min_alarm temp2_offset update_interval
)

vals_sa56004=(22 sa56004 85000 0 75000 54500 70000 0 0
	0 85000 1 75000 1 127125 70000 1 0 0 0 500
)

permissions_sa56004=(
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
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-rw-r--r--"
)

regs_max6659=(
	39 32 00 00 04 46 00 37 00 00 00 00 00 00 00 00
	80 00 00 00 00 00 55 55 00 64 64 64 64 64 64 64
	64 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a 0a
	0a 0a 0a 0a 0a 0a 0a 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 4d 4d
)

attrs_max6659=(alarms name
	temp1_crit temp1_crit_alarm temp1_crit_hyst temp1_emergency
	temp1_emergency_hyst temp1_input temp1_max temp1_max_alarm
	temp1_min temp1_min_alarm
	temp2_crit temp2_crit_alarm temp2_crit_hyst temp2_emergency
	temp2_emergency_hyst temp2_fault temp2_input temp2_max
	temp2_max_alarm temp2_min temp2_min_alarm
	update_interval
)

vals_max6659=(0 max6659 100000 0 90000 85000 75000 57000 70000 0 0
	0 100000 0 90000 85000 75000 0 50500 55000 0 0 0 500
)

permissions_max6659=(
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
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
	"-r--r--r--"
	"-rw-r--r--"
)

# others:
# ../register-dumps/w83l771-manuel.dump (similar to lm86)
# ../register-dumps/lm99.dump (same as lm86)

runtest()
{
    local chip=$1
    local regs=("${!2}")
    local attrs=("${!3}")
    local vals=("${!4}")
    local permissions=("${!5}")
    local rv
    local i

    echo Testing ${chip} ...

    load_i2c_stub ${i2c_addr}

    i=0
    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${i2c_adapter} ${i2c_addr} $i 0x${regs[$i]} b
	i=$(($i + 1))
    done

    # may be auto-detected
    do_instantiate ${chip} ${i2c_addr} 2>/dev/null

    getbasedir ${i2c_addr}

    cd ${basedir}

# grep . *
# ls -l

    dotest attrs[@] vals[@] permissions[@]
    rv=$?

    # Most register ranges can not be checked this way because read and
    # write registers are different.
    check_range -i -b ${basedir} -s 200 -d 500 -r -q temp1_emergency
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 200 -d 500 -r -q temp1_crit
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 200 -d 500 -r -q temp1_crit_hyst
    rv=$(($? + ${rv}))
    check_range -i -b ${basedir} -s 200 -d 500 -r -q temp2_offset
    rv=$(($? + ${rv}))
    check_range -i -b ${basedir} -s 200 -d 500 -r -q temp2_emergency
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 200 -d 500 -r -q temp2_crit
    rv=$(($? + ${rv}))
    check_range -i -b ${basedir} -s 200 -d 500 -r -q temp3_emergency
    rv=$(($? + ${rv}))
    check_range -i -b ${basedir} -s 200 -d 500 -r -q temp3_crit
    rv=$(($? + ${rv}))
    check_range -b ${basedir} -s 200 -d 8000 -r -q update_interval
    rv=$(($? + ${rv}))

    modprobe -r i2c-stub 2>/dev/null

    return ${rv}
}

rv=0

runtest max6695 regs_max6695[@] attrs_max6695[@] vals_max6695[@] permissions_max6695[@]
rv=$?
runtest lm86 regs_lm86[@] attrs_lm86[@] vals_lm86[@] permissions_lm86[@]
rv=$(($? + ${rv}))
runtest g781 regs_g781[@] attrs_g781[@] vals_g781[@] permissions_g781[@]
rv=$(($? + ${rv}))
runtest adt7461 regs_adt7461[@] attrs_adt7461[@] vals_adt7461[@] permissions_adt7461[@]
rv=$(($? + ${rv}))
runtest adm1032 regs_adm1032[@] attrs_adm1032[@] vals_adm1032[@] permissions_adm1032[@]
rv=$(($? + ${rv}))
runtest tmp451 regs_tmp451[@] attrs_tmp451[@] vals_tmp451[@] permissions_tmp451[@]
rv=$(($? + ${rv}))
runtest sa56004 regs_sa56004[@] attrs_sa56004[@] vals_sa56004[@] permissions_sa56004[@]
rv=$(($? + ${rv}))
runtest max6659 regs_max6659[@] attrs_max6659[@] vals_max6659[@] permissions_max6659[@]
rv=$(($? + ${rv}))

exit ${rv}
