dir=$(dirname $(pwd)/$0)
getval=${dir}/../getval

pr_err()
{
    echo $* >&2
}

install_regs ()
{
    local adapter=$1
    local i2c_addr=$(echo $2 | sed -e 's/0x//')
    local regs=("${!3}")
    local size=$4
    local i

    i=0
    while [ $i -lt ${#regs[*]} ]
    do
	i2cset -f -y ${adapter} 0x${i2c_addr} $i 0x${regs[$i]} ${size}
	i=$(($i + 1))
    done
}

containsElement()
{
    local e

    for e in "${@:2}"
    do
	if [ "$e" = "$1" ]
	then
		return 0
	fi
    done

    return 1
}

dotest ()
{
    local val
    local i
    local a=("${!1}")
    local v=("${!2}")
    local p=("${!3}")
    local f
    local known=("device" "driver" "hwmon" "modalias" "power" "subsystem" "uevent")
    local rv=0

    ls | while read f
    do
	containsElement "$f" "${known[@]}"
	if [ $? -ne 0 ]
	then
		containsElement "$f" "${a[@]}"
		if [ $? -ne 0 ]
		then
			pr_err "Unexpected attribute \"$f\", value=\"$(cat $f)\""
			rv=1
		fi
	fi
    done

    i=0
    while [ $i -lt ${#a[*]} ]
    do
	if [ ! -e ${a[$i]} ]
	then
	    pr_err "${a[$i]}: Attribute not found"
	    rv=1
	    i=$(($i + 1))
	    continue
	fi
	val=$(cat ${a[$i]})
	if [ "${val}" != "${v[$i]}" ]
	then
		pr_err "${a[$i]}: bad value ${val}, expected ${v[$i]}"
		rv=1
	fi
	if [ -n "${p[$i]}" ]
	then
	    perm=$(ls -l ${a[$i]} | cut -f1 -d' ')
	    if [ "${perm}" != "${p[$i]}" ]
	    then
		pr_err "${a[$i]}: bad permissions: ${perm}, expected ${p[$i]}"
		rv=1
	    fi
	fi
	i=$(($i + 1))
    done
    return ${rv}
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
	# Give it a second, then retry
	sleep 1
	dev=$(ls /sys/class/i2c-adapter/i2c-${i2c_adapter}/${i2c_adapter}-${addr}/hwmon 2>/dev/null)
	if [ "${dev}" = "" ]
	then
	    pr_err "hwmon device entry not found"
	    exit 1
	fi
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

UNDERFLOW_MIN=(-2147483648	# 0x80000000
	-9223372036854775808	# 0x8000000000000000
	-1
	0
)

OVERFLOW_MAX=(2147483647	# 0x7fffffff
	2147483648		# 0x80000000
	4294967295		# 0xffffffff
	4294967296		# 0x100000000
	4294967296001		# (0x100000000 * 1000) + 1
	4611686018427387904	# 0x4000000000000000
	9223372036854775807	# 0x7fffffffffffffff
	9223372036854775808	# 0x8000000000000000
	18446744073709551615	# 0xffffffffffffffff
)

fixup_writeattr()
{
    :
}

writeattr()
{
    local attr="$1"
    local value="$2"

    echo "${value}" > "${attr}" 2>/dev/null

    fixup_writeattr "${attr}" "${value}"
}

underflow_check_val()
{
    local attr=$1
    local underflow=$2
    local min=$3
    local waittime=$4
    local omin

    # Make sure that the write doesn't fail because the value
    # written is too low to be accepted by the infrastructure.
    # Keep trying with higher values until the write succeeds or
    # the underflow is 0.
    while :; do
	if writeattr ${attr} ${underflow}; then
	    break
	fi
	if [ ${underflow} -ge ${min} ]; then
	    break
	fi
	if [ ${underflow} -eq 0 ]; then
	    break
	fi
	underflow=$((underflow / 2))
    done

    # If the written value is larger than the expected minimum, we can't
    # be sure if any observed differences are due to rounding or due to
    # a real problem. Declare success in that case.
    if [ ${underflow} -gt ${min} ]; then
	return 0
    fi

    omin=$(cat ${attr})
    if [ ${omin} -ne ${min} -a "${omin}" != "${underflow}" ]; then
	pr_err "$(basename ${attr}): Suspected underflow: [min=${min}, read ${omin}, written ${underflow}]"
	return 1
    fi
    if [ ${waittime} -ne 0 ]; then
	sleep ${waittime}
	omax=$(cat ${attr})
	if [ ${omin} -ne ${min} ]; then
	    pr_err "$(basename ${attr}): Cache mismatch: [${min} vs. ${omin}]"
	    return 1
	fi
    fi
    return 0
}

underflow_check()
{
    local i=0

    while [ $i -lt ${#UNDERFLOW_MIN[*]} ]; do
	if ! underflow_check_val $1 ${UNDERFLOW_MIN[$i]} $2 $3; then
	    return 1
	fi
	i=$((i + 1))
    done

    return 0
}

overflow_check_val()
{
    local attr=$1
    local overflow=$2
    local max=$3
    local waittime=$4

    # Make sure that the write doesn't fail because the value
    # written is too high to be accepted by the infrastructure.
    # Keep trying with lower values until the write succeeds or
    # the overflow is 0.
    while :
    do
	writeattr ${attr} ${overflow}
	if [ $? -eq 0 ]
	then
	    break
	fi
	if [ "${overflow}" = "9223372036854775808" ]
	then
	    # Neither bash nor expr can handle this number
	    overflow=4611686018427387904
	    continue
	fi
	if [ "${overflow}" = "18446744073709551615" ]
	then
	    # Neither bash nor expr can handle this number
	    overflow=9223372036854775807
	    continue
	fi
	if [ ${overflow} -le ${max} ]
	then
	    break
	fi
	overflow=$((${overflow} / 2))
    done

    omax=$(cat ${attr})
    if [ ${omax} -ne ${max} -a "${omax}" != "${overflow}" ]
    then
	pr_err "$(basename ${attr}): Suspected overflow: [max=${max}, read ${omax}, written ${overflow}]"
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
    return 0
}

overflow_check()
{
    local i=0

    while [ $i -lt ${#OVERFLOW_MAX[*]} ]
    do
	overflow_check_val $1 ${OVERFLOW_MAX[$i]} $2 $3
	if [ $? -ne 0 ]
	then
	    return 1
	fi
	i=$(($i + 1))
    done

    return 0
}

findmin()
{
	local attr=$1
	local min=-134217728
	local found=$(cat ${attr})
	local tmp

	# 0 is a good baseline
	writeattr "${attr}" 0
	if [ $? -eq 0 ]
	then
		tmp=$(cat ${attr})
		if [ ${tmp} -lt ${found} ]
		then
			found=${tmp}
		fi
	fi
	while [ ${min} -gt -9223372036854775808 ]
	do
		min=$((${min} * 2))
		writeattr ${attr} ${min}
		tmp=$(cat ${attr})
		if [ ${tmp} -lt ${found} ]
		then
			found=${tmp}
		fi
	done

	echo ${found}
}

findmax()
{
	local attr=$1
	# local max=134217727	# 7FFFFFF
	# local max=1048575	# FFFFF
	local max=65535		# FFFF
	local found=$(cat ${attr})
	local tmp

	while [ ${max} -lt 9223372036854775807 ]	# 7FFFFFFFFFFFFFFF
	do
		max=$((${max} * 2))
		max=$((${max} + 1))
		writeattr ${attr} ${max}
		tmp=$(cat ${attr})
		if [ ${tmp} -gt ${found} ]
		then
			found=${tmp}
		fi
		# The following suggests an overflow. Stop looking.
		if [ ${tmp} -lt ${found} ]
		then
			break
		fi
	done

	echo ${found}
}

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
	local ignore=0
	local silent=0

	while getopts "Sb:d:il:qrs:u:vw:" opt
	do
	    case ${opt} in
	    b)	base=${OPTARG}/
		;;
	    d)	mdev=${OPTARG}	# maximum permitted deviation
		;;
	    i)  ignore=1
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
	    S)  silent=1
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

	if [ ! -e "${attr}" ]
	then
		if [ ${ignore} -eq 1 ]
		then
		    return 0
		fi
		pr_err $(basename ${attr}): No such attribute
		return 1
	fi
	orig=$(cat ${attr})

	if [ ${min} -eq ${DEFAULT_MIN} ]; then
		min=$(findmin ${attr})
		if [ ${quiet} -eq 0 ]; then
			disp=1
		fi
		# Try to trigger an underflow
		if ! underflow_check ${attr} ${min} ${waittime}; then
			return 1
		fi
	fi
	if [ ${max} -eq ${DEFAULT_MAX} ]
	then
		max=$(findmax ${attr})
		if [ ${quiet} -eq 0 ]; then
			disp=1
		fi
		# Try to trigger an overflow
		overflow_check ${attr} ${max} ${waittime}
		if [ $? -ne 0 ]
		then
			return 1
		fi
	fi
	if [[ "${min}" -eq "${max}" && "${silent}" -eq 0 ]]; then
		# Not necessarily an error but let's report it.
		pr_err "$(basename ${attr}): min [${min}] is equal to max [${max}]"
	elif [[ "${max}" -lt "${min}" ]]; then
		pr_err "$(basename ${attr}): max [${max}] must be larger or equal to min [${min}]"
		writeattr ${attr} ${orig}
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
		writeattr ${attr} ${i}
		if [ $? -ne 0 ]
		then
			pr_err "failed to write ${i} into ${attr}"
			return 1
		fi
		x=$(cat ${attr})
		if [ $x -lt ${prev} ]
		then
			pr_err "$(basename ${attr}): suspected error: Decreased value $x when expecting at least ${prev}"
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
		writeattr ${attr} ${orig}
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
	writeattr ${attr} ${v[$i]}
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
	writeattr ${attr} ${f[$i]}
	if [ $? -eq 0 ]
	then
	    pr_err $2: Unexpected: write of ${f[$i]} succeeded
	    return 1
	fi
	i=$(($i + 1))
    done

    return 0
}

fixup_regwrite()
{
    :
}

check_volatile()
{
    local sleeptime=""
    local val
    local rval
    local aval
    local rv=0
    local change_only=0
    local OPTIND=1
    local opt

    while getopts "cs:" opt
    do
	case ${opt} in
	c) change_only=1
	   ;;
	s) sleeptime="${OPTARG}"
	   ;;
	esac
    done
    shift $(($OPTIND - 1))

    local i2c_adapter="$1"
    local i2c_addr="${2//0x/}"
    local reg=$3
    local regsize=$4
    local _regsize="${regsize//s/}"
    local fromval=$5
    local toval=$6
    local stepsize=$7
    local attribute=$8
    local attr_startval="${9}"
    local attr_stepsize="${10}"
    local attrval="${attr_startval}"

    for val in $(seq ${fromval} ${stepsize} ${toval}); do
	rval="${val}"
	if [[ "${regsize}" == "ws" ]]; then
	    # swap register write value if needed
	    rval=$((((val & 0xff) << 8) | ((val & 0xff00) >> 8)))
	fi
	i2cset -f -y "${i2c_adapter}" "0x${i2c_addr}" ${reg} ${rval} ${_regsize}
	fixup_regwrite "${i2c_adapter}" "0x${i2c_addr}" ${reg} ${rval}
	if [[ -n "${sleeptime}" ]]; then
	    sleep "${sleeptime}"
	fi
	aval="$(cat ${attribute})"
	if [[ "${change_only}" -eq 0 ]]; then
	    if [[ "${aval}" != "${attrval}" ]]; then
		echo "${attribute} error read ${aval} expected ${attrval}"
		rv=1
	    fi
	    attrval="$((attrval + attr_stepsize))"
	else
	    if [[ "${val}" -ne "${fromval}" && "${aval}" == "${attrval}" ]]; then
		echo "${attribute}: value did not change"
		rv=1
	    fi
	    attrval="${aval}"
	fi
    done
    return ${rv}
}

# Parameter: i2c address
load_i2c_stub()
{
    modprobe -r i2c-stub 2>/dev/null
    modprobe i2c-stub chip_addr=$1 $2 $3
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
