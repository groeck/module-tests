dir=$(dirname $(pwd)/$0)
getval=${dir}/../getval

pr_err()
{
    >&2 echo $*
}

install_regs ()
{
    local adapter=$1
    local i2c_addr=$2
    local regs=("${!3}")
    local i
    local size=$4

    i=0
    while [ $i -lt ${#regs[*]} ]
    do
        i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} ${size}
	i=$(($i + 1))
    done
}

dotest ()
{
    local val
    local i=0
    local a=("${!1}")
    local v=("${!2}")

    while [ $i -lt ${#a[*]} ]
    do
	val=$(cat ${a[$i]})
	if [ "${val}" != "${v[$i]}" ]
	then
		pr_err ${a[$i]} bad value ${val} expected ${v[$i]}
		return 1
	fi
	i=$(($i + 1))
    done
    return 0
}

ecode=-19

error_test()
{
	local i=0
	local rv=0
	local rc
	local adapter=$1
	local a=("${!2}")
	local val
	local efile=/sys/class/i2c-adapter/i2c-${adapter}/error

	# If i2c-stub doesn't support error code insertion,
	# there is nothing we can do.
	if [ ! -e ${efile} ]
	then
		return 0
	fi
	echo ${ecode} > ${efile}
	while [ $i -lt ${#a[*]} ]
	do
		val=$(${getval} ${a[$i]})
		rc=$?
		if [ ${rc} -eq 0 ]
		then
			pr_err ${a[$i]} returned no error
			rv=1
		else
			if [ ${val} -ne ${ecode} ]
			then
				pr_err ${a[$i]} returned ${val}, expected ${ecode}
				rv=1
			fi
		fi
		i=$(($i + 1))
	done
	echo 0 > ${efile}
	return ${rv}
}

# New API: Write basedir to global variable 'basedir', exit on error

getbasedir()
{
    local dev
    local addr="00$(echo $1 | sed -e 's/0x//')"

    dev=$(ls /sys/class/i2c-adapter/i2c-${i2c_adapter}/${i2c_adapter}-${addr}/hwmon 2>/dev/null)
    if [ "${dev}" = "" ]
    then
	pr_err "hwmon device entry not found"
	exit 1
    fi

    if [ -e "/sys/class/hwmon/${dev}/name" ]
    then
	basedir="/sys/class/hwmon/${dev}"
    else
        basedir="/sys/class/hwmon/${dev}/device"
    fi
    if [ ! -d "${basedir}" ]
    then
	pr_err "Directory ${basedir} does not exist"
	exit 1
    fi
}

# Legacy API: Print basedir to stdout
# Caller has to validate return value (getbasedir will exit on error)

getbase()
{
    i2c_adapter=$1
    getbasedir $(echo $2 | sed -e 's/00//')
    echo ${basedir}
    return 0
}

DEFAULT_MIN=-100000001
DEFAULT_MAX=100000001
OVERFLOW_MAX=4294967296001

check_range()
{
	local base="./"
	local attr
	local mdev=${DEFAULT_MAX}
	local min=${DEFAULT_MIN}
	local max=${DEFAULT_MAX}
	local omax
	local stepsize=0
	local deviation=0
	local OPTIND=1
	local opt
	local range
	local i
	local disp=0
	local restore=0
	local orig
	local rv=0
	local quiet=0
	local waittime=0
	local prev

	while getopts ":b:d:l:qrs:u:vw:" opt
	do
	    case ${opt} in
	    b)	base=${OPTARG}/
		;;
	    d)	mdev=${OPTARG}	# maximum permitted deviation
	        ;;
	    l)	min=${OPTARG}
		;;
	    q)	quiet=1
		;;
	    v)	disp=1
	        quiet=0
		;;
	    w)  waittime=${OPTARG}
	        ;;
	    r)	restore=1
		;;
	    s)  stepsize=${OPTARG}
		;;
	    u)	max=${OPTARG}
		;;
	    :)	pr_err "Option ${OPTARG} requires an argument"
	        return 1
		;;
	    esac
	done
	shift $(($OPTIND-1))

	attr=${base}$1

	if [ ! -e ${attr} ]
	then
		pr_err $(basename ${attr}): No such attribute
		return 1
	fi
	orig=$(cat ${attr})

	if [ ${min} -eq ${DEFAULT_MIN} ]
	then
		echo ${min} > ${attr} 2>/dev/null
		min=$(cat ${attr})
		if [ ${quiet} -eq 0 ]; then
			disp=1
		fi
	fi
	if [ ${max} -eq ${DEFAULT_MAX} ]
	then
		echo ${max} > ${attr} 2>/dev/null
		max=$(cat ${attr})
		if [ ${quiet} -eq 0 ]; then
			disp=1
		fi
		# Try to trigger an overflow
		echo ${OVERFLOW_MAX} > ${attr} 2>/dev/null
		omax=$(cat ${attr})
		if [ ${omax} -ne ${max} ]
		then
			pr_err "$(basename ${attr}): Suspected overflow: [${max} vs. ${omax}]"
			return 1
		fi
		if [ ${waittime} -ne 0 ]
		then
			sleep ${waittime}
			omax=$(cat ${attr})
			if [ ${omax} -ne ${max} ]
			then
			    pr_err "$(basename ${attr}): Cache mismatch: [${max} vs. ${omax}]"
			    return 1
			fi
		fi
	fi
	if [ ${max} -lt ${min} ]
	then
		pr_err "$(basename ${attr}): max [${max}] must be larger or equal to min [${min}]"
		echo ${orig} > ${attr}
		return 1
	fi
	if [ "${stepsize}" = "" -o ${stepsize} -le 0 ]
	then
	    range=$((${max} - ${min}))
	    stepsize=$((${range} / 100))
	    if [ ${stepsize} -lt 1 ]
	    then
		stepsize=1
	    fi
	fi
	prev=${min}
	for i in $(seq ${min} ${stepsize} ${max})
	do
		echo ${i} > ${attr} 2>/dev/null
		if [ $? -ne 0 ]
		then
			rv=1
		fi
		x=$(cat ${attr})
		if [ $x -lt ${prev} ]
		then
			pr_err "suspected error: Decreased value $x when expecting at least ${prev}"
		fi
		prev=${x}
		d=0
		if [ $i -gt $x ]
		then
			d=$(($i - $x))
		elif [ $i -lt $x ]
		then
			d=$(($x - $i))
		fi
		if [ $d -gt ${deviation} ]
		then
		    devi=$i
		    devv=$x
		    deviation=$d
		fi
	done
	if [ ${disp} -eq 1 ]
	then
		echo "$(basename ${attr}): value range [${min},${max}], deviation ${deviation}"
	fi

	if [ ${restore} -ne 0 ]
	then
		echo ${orig} > ${attr}
	fi
	if [ ${mdev} -lt ${deviation} ]
	then
	    pr_err "$(basename ${attr}): Deviation out of range [max ${mdev}, seen ${deviation} (val=${devv}) with ${devi}]"
	    rv=1
	fi
	return ${rv}
}

check_values ()
{
    local attr=$1/$2
    local v=("${!3}")
    local f=("${!4}")

    if [ ! -e ${attr} ]
    then
	pr_err ${attr} does not exist
	return 1
    fi

    i=0
    while [ $i -lt ${#v[*]} ]
    do
	echo ${v[$i]} > ${attr} 2>/dev/null
	if [ $? -ne 0 ]
	then
	    pr_err $2: Did not accept write of ${v[$i]}
	    return 1
	fi
	val=$(cat ${attr})

	if [ ${val} -ne ${v[$i]} ]
	then
		pr_err ${attr}: bad value ${val} expected ${v[$i]}
		return 1
	fi
	i=$(($i + 1))
    done

    i=0
    while [ $i -lt ${#f[*]} ]
    do
	echo ${f[$i]} > ${attr} 2>/dev/null
	if [ $? -eq 0 ]
	then
	    pr_err $2: Unexpected: write of ${f[$i]} succeeded
	    return 1
	fi
	i=$(($i + 1))
    done

    return 0
}

# Parameter: i2c address
load_i2c_stub()
{
    modprobe -r i2c-stub 2>/dev/null
    modprobe i2c-stub chip_addr=$1
    if [ $? -ne 0 ]
    then
	pr_err "Failed to load i2c-stub driver"
	exit 1
    fi
    i2c_adapter=$(grep "SMBus stub driver" /sys/class/i2c-adapter/*/name | cut -f1 -d: | cut -f5 -d/ | cut -f2 -d-)
    if [ "${i2c_adapter}" = "" ]
    then
	pr_err "I2C adapter not found"
	exit 1
    fi
    return 0
}

do_instantiate()
{
	echo $1 $2 > /sys/class/i2c-adapter/i2c-${i2c_adapter}/new_device 2>/dev/null
}

do_remove()
{
	echo $1 > /sys/class/i2c-adapter/i2c-${i2c_adapter}/delete_device
}
