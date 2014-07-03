modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x3f
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

i2cset -f -y ${adapter} 0x3f 0x0 0x402e w
i2cset -f -y ${adapter} 0x3f 0x1 0x00 b
i2cset -f -y ${adapter} 0x3f 0x2 0x64 b
i2cset -f -y ${adapter} 0x3f 0x3 0x10 b

echo ad7414 0x3f > /sys/class/i2c-adapter/i2c-${adapter}/new_device

# echo Attributes: 
# echo

hwmon_dev=$(ls /sys/class/i2c-adapter/i2c-${adapter}/${adapter}-003f/hwmon)

echo hwmon device: ${hwmon_dev}
echo

# echo
# echo Sensors:
# echo

sensors ad7414-i2c-${adapter}-3f

modprobe -r i2c-stub 2>/dev/null
