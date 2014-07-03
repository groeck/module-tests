modprobe -r i2c-stub 2>/dev/null
modprobe i2c-stub chip_addr=0x3f
if [ $? -ne 0 ]
then
	echo must be root
	exit 1
fi

adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)

i2cset -f -y ${adapter} 0x3f 0x0 0x402e w
i2cset -f -y ${adapter} 0x3f 0x1 0x0000 w
i2cset -f -y ${adapter} 0x3f 0x2 0x004b w
i2cset -f -y ${adapter} 0x3f 0x3 0x0050 w
i2cset -f -y ${adapter} 0x3f 0x4 0xc0ff w
i2cset -f -y ${adapter} 0x3f 0x5 0x0000 w
i2cset -f -y ${adapter} 0x3f 0x6 0xc071 w
i2cset -f -y ${adapter} 0x3f 0x7 0xc071 w

echo ad7418 0x3f > /sys/class/i2c-adapter/i2c-${adapter}/new_device

sensors

modprobe -r i2c-stub 2>/dev/null
