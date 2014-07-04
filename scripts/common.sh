dotest ()
{
    local val
    local i=0
    local a=("${!1}")
    local v=("${!2}")

    while [ $i -lt ${#a[*]} ]
    do
	val=$(cat ${a[$i]})
	if [ ${val} -ne ${v[$i]} ]
	then
		echo ${a[$i]} bad value ${val} expected ${v[$i]}
		return 1
	fi
	i=$(($i + 1))
    done
    return 0
}

getbase()
{
    local dev

    dev=$(ls /sys/class/i2c-adapter/i2c-$1/$1-$2/hwmon 2>/dev/null)
    if [ "${dev}" = "" ]
    then
	return 1
    fi

    if [ -e "/sys/class/hwmon/${dev}/name" ]
    then
    	echo /sys/class/hwmon/${dev}
    else
        echo /sys/class/hwmon/${dev}/device
    fi
    return 0
}

DEFAULT_MIN=-100000000
DEFAULT_MAX=100000000

check_range()
{
	local base="./"
	local attr
	local mdev=${DEFAULT_MAX}
	local min=${DEFAULT_MIN}
	local max=${DEFAULT_MAX}
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

	while getopts ":b:d:l:qrs:u:v" opt
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
	    r)	restore=1
		;;
	    s)  stepsize=${OPTARG}
		;;
	    u)	max=${OPTARG}
	    	;;
	    :)	echo "Option ${OPTARG} requires an argument"
	        return 1
		;;
	    esac
	done
	shift $(($OPTIND-1))

	attr=${base}$1

	if [ ! -e ${attr} ]
	then
		echo $(basename ${attr}): No such attribute
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
	fi
	if [ ${max} -lt ${min} ]
	then
		echo "$(basename ${attr}): max [${max}] must be larger or equal to min [${min}]"
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
	for i in $(seq ${min} ${stepsize} ${max})
	do
		echo ${i} > ${attr} 2>/dev/null
		if [ $? -ne 0 ]
		then
			rv=1
		fi
		x=$(cat ${attr})
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
	if [ ${mdev} -lt ${deviation} -a ${quiet} -eq 0 ]
	then
	    echo "$(basename ${attr}): Deviation out of range [max ${mdev}, seen ${deviation}]"
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
	echo ${attr} does not exist
	return 1
    fi

    i=0
    while [ $i -lt ${#v[*]} ]
    do
	echo ${v[$i]} > ${attr} 2>/dev/null
	if [ $? -ne 0 ]
	then
	    echo $2: Did not accept write of ${v[$i]}
	    return 1
	fi
	val=$(cat ${attr})

	if [ ${val} -ne ${v[$i]} ]
	then
		echo ${attr}: bad value ${val} expected ${v[$i]}
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
	    echo $2: Unexpected: write of ${f[$i]} succeeded
	    return 1
	fi
	i=$(($i + 1))
    done

    return 0
}
