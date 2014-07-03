uid=$(id -u)
if [ ${uid} -ne 0 ]
then
	echo "Must be root to run this script"
	exit 1
fi

if [ "$1" = "" ]
then
	echo Must specify source file
	exit 1
fi

SOURCE=../linux-staging/drivers/hwmon/$1.c
if [ ! -e ${SOURCE} ]
then
	echo Missing source file ${SOURCE}
	exit 1
fi

sed -e "s/TESTME/$1/" Makefile.template > Makefile

rm -f *.[ch]
cp ${SOURCE} .
cp ../linux-staging/drivers/hwmon/lm75.h .

make clean >/dev/null 2>/dev/null
make
if [ $? -ne 0 ]
then
	echo Build failed, exiting
	exit 1
fi

if [ ! -e scripts/$1.sh ]
then
	echo No test script, exiting
	exit 0
fi

modprobe -r $1 >/dev/null 2>&1
make install
modprobe $1
if [ $? -ne 0 ]
then
	echo "Failed to load $1.ko"
	exit 1
fi

sudo scripts/$1.sh
rv=$?
if [ ${rv} -ne 0 ]
then
	echo Module test failed
else
	echo Module test passed
fi

modprobe -r $1 >/dev/null 2>&1

exit ${rv}
