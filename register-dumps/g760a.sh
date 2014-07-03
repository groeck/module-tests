modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x3f
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

i2cset -f -y ${adapter} 0x3f 0x0 0x7f b
i2cset -f -y ${adapter} 0x3f 0x1 0x80 b
i2cset -f -y ${adapter} 0x3f 0x2 0x00 b

echo g760a 0x3f > /sys/class/i2c-adapter/i2c-${adapter}/new_device

# echo Attributes: 
# echo

ls /sys/class/i2c-adapter/i2c-${adapter}/${adapter}-003f >/dev/null 2>&1
if [ $? -ne 0 ]
then
	sleep 0.5
fi

hwmon_dev=$(ls /sys/class/i2c-adapter/i2c-${adapter}/${adapter}-003f/hwmon 2>/dev/null)

if [ "${hwmon_dev}" = "" ]
then
	echo fail: No hwmon device
	exit 1
fi

base=/sys/class/i2c-adapter/i2c-${adapter}/${adapter}-003f
if [ ! -e ${base}/fan1_input ]
then
	base=${hwmon_dev}
fi

if [ ! -e ${base}/fan1_alarm -o ! -e ${base}/fan1_input -o ! -e ${base}/pwm1 ]
then
	echo fail: Missing attribute
	exit 1
fi

if [ $(cat ${base}/fan1_alarm) -ne 0 ]
then
	echo fail: fan1_alarm
	exit 1
fi

if [ $(cat ${base}/fan1_input) -ne 3840 ]
then
	echo fail: fan1_input
	exit 1
fi

if [ $(cat ${base}/pwm1) -ne 128 ]
then
	echo fail: pwm1
	exit 1
fi

modprobe -r i2c-stub 2>/dev/null

echo pass
