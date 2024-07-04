dir=$(dirname $(pwd)/$0)
getval=${dir}/../getval

__verbose=0

pr_err()
{
    echo $* >&2
}

pr_verbose()
{
    if [[ "${__verbose}" -ge "$1" ]]; then
	pr_err "$2"
    fi
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
	i=$((i + 1))
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
    local permissive=0
    if [[ $1 = "-p" ]]; then
	permissive=1
	shift
    fi
    local quiet=0
    if [[ $1 = "-q" ]]; then
	quiet=1
	shift
    fi
    local a=("${!1}")
    local v=("${!2}")
    local p=("${!3}")
    local f
    local known=("device" "driver" "hwmon" "modalias" "power" "subsystem" "uevent")
    local rv=0
    local perm
    local val
    local i

    for f in $(ls); do
	if ! containsElement "$f" "${known[@]}"; then
	    if ! containsElement "$f" "${a[@]}"; then
		pr_err "Unexpected attribute \"$f\", value=\"$(cat $f)\""
		rv=$((rv + 1))
	    fi
	fi
    done

    i=0
    while [ $i -lt ${#a[*]} ]
    do
	if [ ! -e ${a[$i]} ]
	then
	    pr_err "${a[$i]}: Attribute not found"
	    rv=$((rv + 1))
	    i=$((i + 1))
	    continue
	fi
	# Don't try to read the attribute if it is write-only
	perm="$(ls -l "${a[$i]}" | cut -f1 -d' ')"
	# we can not use "test -r" because that does not work for root
	if [[ "${perm}" != "--w-------" ]]; then
	    val=$(cat "${a[$i]}")
	    if [[ "${val}" != "${v[$i]}" ]]; then
		if [[ ${permissive} -eq 0 || ${a[$i]%_input} = ${a[$i]} ]];
		then
		    pr_err "${a[$i]}: bad value ${val}, expected ${v[$i]}"
		    rv=$((rv + 1))
		elif [[ ${permissive} -eq 1 && ${quiet} -eq 0 ]]; then
		    echo "Note: ${a[$i]}: value difference: reported ${val}, expected ${v[$i]}"
		fi
	    fi
	fi
	if [ -n "${p[$i]}" ]
	then
	    if [ "${perm}" != "${p[$i]}" ]
	    then
		pr_err "${a[$i]}: bad permissions: ${perm}, expected ${p[$i]}"
		rv=$((rv + 1))
	    fi
	fi
	i=$((i + 1))
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
		i=$((i + 1))
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
    local rv

    echo "${value}" > "${attr}" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    fixup_writeattr "${attr}" "${value}"
    return $?
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
	overflow=$((overflow / 2))
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
	i=$((i + 1))
    done

    return 0
}

findmin()
{
	local attr=$1
	local min=-134217728
	local found=$(cat ${attr})
	local tmp
	local written

	# 0 is a good baseline
	writeattr "${attr}" 0
	if [ $? -eq 0 ]
	then
		tmp=$(cat ${attr})
		if [ ${tmp} -lt ${found} ]
		then
			found=${tmp}
			written="0"
		fi
	fi
	while [ ${min} -gt -9223372036854775808 ]
	do
		min=$((min * 2))
		writeattr ${attr} ${min}
		tmp=$(cat ${attr})
		if [ ${tmp} -lt ${found} ]
		then
			found=${tmp}
			written="${tmp}"
		fi
	done

	pr_verbose 1 "$(basename "${attr}"): Found min ${found} when writing ${written}"
	echo "${found}"
}

findmax()
{
	local attr=$1
	# local max=134217727	# 7FFFFFF
	# local max=1048575	# FFFFF
	local max=65535		# FFFF
	local found=$(cat ${attr})
	local tmp
	local written="${found}"

	while [ ${max} -lt 9223372036854775807 ]	# 7FFFFFFFFFFFFFFF
	do
		max=$((max * 2))
		max=$((max + 1))
		writeattr ${attr} ${max}
		tmp=$(cat ${attr})
		if [ ${tmp} -gt ${found} ]
		then
			found="${tmp}"
			written="${max}"
		fi
		# The following suggests an overflow. Stop looking.
		if [ ${tmp} -lt ${found} ]
		then
			break
		fi
	done

	pr_verbose 1 "$(basename "${attr}"): Found max ${found} when writing ${written}"
	echo "${found}"
}

check_read_write_read()
{
    local attr="$1"
    local val="$2"

    if [[ -z "${val}" ]]; then
	val="$(cat ${attr})"
    fi

    writeattr "${attr}" "${val}"

    if [[ $? -ne 0 ]]; then
	pr_err "$(basename ${attr}): Failed to write ${val}"
    else
	local x=$(cat ${attr})
	if [[ $x -ne ${val} ]]; then
	    pr_err "$(basename ${attr}): Failed read->write->read sequence: ${val} -> ${x}"
	fi
    fi
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
	local restore=0
	local orig
	local rv=0
	local quiet=0
	local waittime=0
	local prev
	local ignore=0
	local silent=0

	__verbose=0

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
	    v)	__verbose="$((__verbose + 1))"
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
	shift $((OPTIND - 1))

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
		min="$(findmin ${attr})"
		if [ ${quiet} -eq 0 -a ${__verbose} -eq 0 ]; then
			__verbose=1
		fi
		# Try to trigger an underflow
		if ! underflow_check ${attr} ${min} ${waittime}; then
			return 1
		fi
		check_read_write_read "${attr}" "${min}"
	else
		writeattr ${attr} $((min - 1))
		if [ $? -eq 0 ]
		then
			pr_err "Out of range value accepted writing into $(basename ${attr}): val=$((min - 1)) min=${min}"
		fi
	fi
	if [ ${max} -eq ${DEFAULT_MAX} ]
	then
		max="$(findmax ${attr})"
		if [ ${quiet} -eq 0 -a ${__verbose} -eq 0 ]; then
			__verbose=1
		fi
		# Try to trigger an overflow
		if ! overflow_check ${attr} ${max} ${waittime}; then
		    return 1
		fi
		check_read_write_read "${attr}" "${max}"
	else
		writeattr ${attr} $((max + 1))
		if [ $? -eq 0 ]
		then
			pr_err "Out of range value accepted writing into $(basename ${attr}): val=$((max + 1)) max=${max}"
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
	    range=$((max - min))
	    stepsize=$((range / 100))
	    if [ ${stepsize} -lt 1 ]
	    then
		stepsize=1
	    fi
	fi
	pr_verbose 2 "range check attribute ${attr} (min ${min} max ${max} original ${orig})"
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
			d=$((i - x))
		elif [ $i -lt $x ]
		then
			d=$((x - i))
		fi

		pr_verbose 2 "write $i read $x deviation $d"

		if [ $d -gt ${deviation} ]
		then
		    devi=$i
		    devv=$x
		    deviation=$d
		fi
	done

	pr_verbose 1 "$(basename ${attr}): value range [${min},${max}], deviation ${deviation}"

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
	i=$((i + 1))
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
	i=$((i + 1))
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

# Check if file is writeable. We can not use '-w' since that always
# returns true when running as super-user
is_writeable()
{
    if [[ ! -e "$1" ]]; then
	return 1
    fi
    ls -l "$1" | grep -q -- "-rw-r--r--"
    return $?
}

check_alarm()
{
	local input=$1
	local limit=$2
	local hyst_index=$3
	local alarm=$4
	local offset=$5
	local expect=$6
	local val
	local aflag
	local rv=0
	local index
	local limit_val="$(cat ${limit})"
	local hyst_base_attr
	local hyst_attr
	local hyst_val

	if [[ -n "${hyst_index}" ]]; then
	    if is_writeable "temp${hyst_index}_crit_hyst"; then
		hyst_base_attr="temp${hyst_index}_crit"
		hyst_attr="temp${hyst_index}_crit_hyst"
	    else
		hyst_base_attr="temp${hyst_index}_max"
		hyst_attr="temp${hyst_index}_max_hyst"
	    fi
	fi

	val="$(cat ${input})"
	echo "$((offset + val))" > "${limit}"
	# echo "${input}: ${val} ${limit}: $((offset + val)) [$(cat ${limit})]"
	if [[ -n "${hyst_index}" ]]; then
	    hyst_val="$(cat ${hyst_attr})"
	    hyst_base_val="$(cat ${hyst_base_attr})"
	    echo "$((offset + hyst_base_val - 1000))" > "${hyst_attr}"
	    # echo "${hyst_attr}: $((offset + hyst_base_val - 1000)) [$(cat ${hyst_attr})]"
	fi

	# wait up to one second for the alarm to clear/set
	sleep 0.2
	cat ${alarm} >/dev/null
	sleep 0.2
	for index in $(seq 1 10); do
	    aflag="$(cat ${alarm})"
	    if [[ "${aflag}" -eq "${expect}" ]]; then
		break
	    fi
	    sleep 0.1
	done

	if [[ "${aflag}" -ne "${expect}" ]]; then
	    echo "${alarm} is ${aflag}, expected ${expect} (${input}=$(cat ${input}), ${limit}=$(cat ${limit}))"
	    if [[ -e "${hyst_base_attr}" ]]; then
	    	echo "  ${hyst_base_attr}: $(cat ${hyst_base_attr}) ${hyst_attr}: $(cat ${hyst_attr})"
	    fi
	    rv=1
	fi

	echo "${limit_val}" > "${limit}"
	if [[ -n "${hyst_index}" ]]; then
	    echo "${hyst_val}" > "${hyst_attr}"
	fi

	return $rv
}

_test_one()
{
    local a=("${!1}")
    local channels
    local t
    local rv
    local temp
    local temp2
    local fault
    local enable
    local temp_max_hyst_index=""
    local temp_crit_hyst_index=""

    # determine number of channels to test
    channels=0
    for t in $(seq 9 -1 1); do
	if [[ -e "temp${t}_input" ]]; then
	    channels=$t
	    break
	fi
    done

    # Make sure that updates happen as fast as possible
    if is_writeable update_interval; then
	echo 1 > update_interval
    fi
    if is_writeable temp_samples; then
	echo 1 > temp_samples
    fi

    # Clear temperature offsets
    for t in $(seq 1 ${channels}); do
	if is_writeable "temp${t}_offset"; then
	    echo 0 > "temp${t}_offset"
	fi
    done

    sleep 0.2

    temp="$(cat temp1_input)"
    if [[ temp -le 0 || temp -gt 50000 ]]; then
	local r

	echo -n "Waiting for temperature to settle ..."
	for r in $(seq 1 20); do
	    temp="$(cat temp1_input)"
	    if [[ temp -gt 0 && temp -lt 50000 ]]; then
		break
	    fi
	    sleep 1
	    echo -n "."
	done
	if [[ temp -le 0 || temp -gt 50000 ]]; then
	    echo "Temperature failed to settle. Aborting."
	    return 1
	fi
	echo
    fi

    # dummy value reads to give alarms time to settle
    cat ${a[@]} >/dev/null 2>&1
    sleep 0.2

    local vals=($(cat ${a[@]} 2>/dev/null))

    # give alarms time to recover
    sleep 0.2

    dotest -p -q a[@] vals[@]
    if [[ $? -ne 0 ]]; then
	return 1
    fi

    for t in $(seq 1 ${channels}); do
	if [[ -e "temp${t}_min" ]]; then
	    check_range -b ${basedir} -d 500 -r -q temp${t}_min
	    rv=$((rv + $?))
	fi
	if [[ -e "temp${t}_max" ]]; then
	    check_range -b ${basedir} -d 500 -r -q temp${t}_max
	    rv=$((rv + $?))
	    if is_writeable "temp${t}_max_hyst"; then
		check_range -b ${basedir} -d 500 -r -q temp${t}_max_hyst
		rv=$((rv + $?))
		temp_max_hyst_index="${t}"
	    fi
	fi
	if is_writeable "temp${t}_crit"; then
	    check_range -b ${basedir} -d 500 -r -q temp${t}_crit
	    rv=$((rv + $?))
	    if is_writeable "temp${t}_crit_hyst"; then
		check_range -b ${basedir} -d 500 -r -q temp${t}_crit_hyst
		rv=$((rv + $?))
		temp_crit_hyst_index="${t}"
	    fi
	fi

	if [[ -e "temp${t}_emergency" ]]; then
	    check_range -b ${basedir} -d 500 -r -q temp${t}_emergency
	    rv=$((rv + $?))
	    if is_writeable "temp${t}_emergency_hyst"; then
		check_range -b ${basedir} -d 500 -r -q temp${t}_emergency_hyst
		rv=$((rv + $?))
	    fi
	fi

	if [[ -e "temp${t}_enable" ]]; then
	    enable="$(cat temp${t}_enable)"
	    if [[ enable -eq 0 ]]; then
		echo "temp${t} disabled, skipping offset and alarm attribute tests"
		continue
	    fi
	    if is_writeable "temp${t}_enable"; then
		echo 0 > "temp${t}_enable"
		if ! cat temp${t}_input |& grep -q "No data available"; then
		    echo "Failed to disable temp${t}"
		    rv=$((rv + 1))
		fi
		echo 1 > "temp${t}_enable"
		sleep 0.2
	    fi
	fi

	if [[ -e "temp${t}_fault" ]]; then
	    fault="$(cat temp${t}_fault)"
	    if [[ fault -ne 0 ]]; then
		echo "temp${t} reports fault, skipping offset and alarm attribute tests"
		continue
	    fi
	fi

	if is_writeable "temp${t}_offset"; then
	    # Check if temperature offsets are working
	    temp="$(cat temp${t}_input)"
	    # echo "temp${t}_offset: $(cat temp${t}_offset) temp${t}_input: $(cat temp${t}_input)"
	    echo 10000 > "temp${t}_offset"
	    sleep 0.3
	    temp2="$(cat temp${t}_input)"
	    # echo "temp${t}_offset: $(cat temp${t}_offset) temp${t}_input: $(cat temp${t}_input)"
	    local d=$((temp - temp2 + 10000))
	    if [[ d -gt 3000 || d -lt -3000 ]]; then
		pr_err "temp${t}_input: Unexpected temperature difference ${d}, expected < 3000"
		rv=$((rv + 1))
	    elif [[ d -gt 1000 || d -lt -1000 ]]; then
		echo "Note: temp${t}_input: Unusually high temperature difference ${d}"
	    fi
	    echo -10000 > "temp${t}_offset"
	    sleep 0.3
	    temp2="$(cat temp${t}_input)"
	    d=$((temp2 - temp + 10000))
	    if [[ diff -gt 3000 || d -lt -3000 ]]; then
		pr_err "temp${t}_input: Unexpected temperature difference ${d}, expected < 3000"
		rv=$((rv + 1))
	    elif [[ diff -gt 1000 || d -lt -1000 ]]; then
		echo "temp${t}_input: Unusually high temperature difference ${d}"
	    fi
	    # Now make sure that temperature ranges are as expected.
	    echo 128000 > "temp${t}_offset"
	    sleep 0.1
	    temp="$(cat temp${t}_input)"
	    if [[ temp -lt 0 ]]; then
		# Some chips (G781) may take longer to update the temperature
		sleep 0.5
		temp="$(cat temp${t}_input)"
		if [[ temp -lt 0 ]]; then
		    pr_err "temp${t}_input: Bad high temperature: Expected value > 0, got ${temp}"
		    rv=$((rv + 1))
		fi
	    fi
	    echo -128000 > "temp${t}_offset"
	    sleep 0.1
	    temp="$(cat temp${t}_input)"
	    if [[ temp -gt 0 ]]; then
		sleep 0.5
		temp="$(cat temp${t}_input)"
		if [[ temp -gt 0 ]]; then
		    pr_err "temp${t}_input: Bad low temperature: Expected value <= 0, got ${temp}"
		    rv=$((rv + 1))
		fi
	    fi
	    check_range -b ${basedir} -d 500 -r -q temp${t}_offset
	    rv=$((rv + $?))
	    echo 0 > "temp${t}_offset"
	    sleep 0.3
	fi

	# check alarm attributes

	if [[ -e "temp${t}_min" ]]; then
	    check_alarm "temp${t}_input" "temp${t}_min" "" "temp${t}_min_alarm" -5000 0
	    rv=$((rv + $?))
	    check_alarm "temp${t}_input" "temp${t}_min" "" "temp${t}_min_alarm" 5000 1
	    rv=$((rv + $?))
	fi

	if [[ -e "temp${t}_max" ]]; then
	    check_alarm "temp${t}_input" "temp${t}_max" "${temp_max_hyst_index}" "temp${t}_max_alarm" -5000 1
	    rv=$((rv + $?))
	    check_alarm "temp${t}_input" "temp${t}_max" "${temp_max_hyst_index}" "temp${t}_max_alarm" 5000 0
	    rv=$((rv + $?))
	fi

	if is_writeable "temp${t}_crit" && [[ -e "temp${t}_crit_alarm" ]]; then
	    check_alarm "temp${t}_input" "temp${t}_crit" "${temp_crit_hyst_index}" "temp${t}_crit_alarm" -5000 1
	    rv=$((rv + $?))
	    check_alarm "temp${t}_input" "temp${t}_crit" "${temp_crit_hyst_index}" "temp${t}_crit_alarm" 5000 0
	    rv=$((rv + $?))
	fi

    done

    if is_writeable update_interval; then
	check_range -b ${basedir} -d 4000 -r -q update_interval
	rv=$((rv + $?))
    fi

    if is_writeable temp_samples; then
	check_range -b ${basedir} -r -q -v temp_samples
	rv=$((rv + $?))
    fi

    return ${rv}
}

test_one()
{
    local a=("${!1}")
    local rv

    # basedir was re-created; need to repeat cd
    cd "${basedir}"

    if [[ -e "device/pec" ]]; then
	echo "  Testing with PEC disabled"
	echo 0 > "device/pec"
    fi

    _test_one a[@]
    rv=$?

    if [[ -e "device/pec" ]]; then
	echo "  Testing with PEC enabled"
	echo 1 > "device/pec"
	_test_one a[@]
	rv=$((rv + $?))
	echo 0 > "device/pec"
    fi
    return ${rv}
}

# Test supported chips
# Conditions:
# - Calling code provides test_chip function
# - Calling code provides attrs_XXX strings listing attributes
#   supported by supported chips
# Function:
# - Determine and set global basedir, i2c_addr, attrs variables
# - Call test_chip for each supported chip; parameter: chip name
# Return value: Number of failed tests
test_chips()
{
    local hname
    local chip
    local subsystem
    local tmp

    for hname in $(ls /sys/class/hwmon/*/name); do
	chip="$(cat ${hname})"
	basedir="$(dirname ${hname})"

	if [[ ! -e "${basedir}/device/subsystem" ]]; then
	    continue
	fi

	subsystem="$(readlink ${basedir}/device/subsystem | grep i2c)"
	if [[ -z "${subsystem}" ]]; then
	    continue
	fi

	i2c_addr="0x$(readlink ${basedir}/device | cut -f2 -d- | sed -e 's/^00//')"
	if [[ "${i2c_addr}" = "0x" ]]; then
	    echo "Can not determine I2C base address for ${chip}, skipping test"
	    continue
	fi

	cd "${basedir}"

	tmp="attrs_${chip}"
	attrs=(${!tmp})
	if [[ -z "${attrs[@]}" ]]; then
	    echo "Unsupported chip \"${chip}\", skipping"
	    continue
	fi

	echo "Running tests for ${chip}@${i2c_addr##0x}"

	test_chip "${chip}"
	rv=$((rv + $?))
    done

    if [[ rv -gt 0 ]]; then
	echo "### ${rv} test failure(s) ###"
    else
	echo "### All tests passed ###"
    fi

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
