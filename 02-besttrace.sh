#!/usr/bin/env bash
trap _exit INT QUIT TERM



next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

_exit() {
    echo -e "\nThe script has been terminated.\n"
    rm -fr besttrace
    exit 1
}

besttrace_test() {
    local nodeName="$2"
    local nodeIP="$1"
    printf "** %s (%s) **\n " " ${nodeName}" " ${nodeIP}"
    echo -e
    ./besttrace $1 -q 1
    next
}


trace() {
	besttrace_test '168.95.1.1' 'TW, Hinet'
	besttrace_test '139.175.1.1' 'TW, FETNet'
	besttrace_test '203.79.224.10' 'TW, APTG'
	besttrace_test '61.64.127.1' 'TW, SoNET'
	besttrace_test '219.87.66.1' 'TW, TFN'
	besttrace_test '103.31.196.1' 'TW,TAIFO'
	besttrace_test '123.195.236.110' 'TW,Kbro'
    besttrace_test '219.141.147.210' '北京电信'
    besttrace_test '202.96.209.133' '上海电信'
    besttrace_test '58.60.188.222' '深圳电信'
    besttrace_test '202.106.50.1' '北京联通'
    besttrace_test '210.22.97.1' '上海联通'
    besttrace_test '210.21.196.6' '深圳联通'
    besttrace_test '221.179.155.161' '北京移动'
    besttrace_test '211.136.112.200' '上海移动'
    besttrace_test '120.196.165.24' '深圳移动'
    besttrace_test '202.112.14.151' '成都教育网'
}

chmod 755 ./besttrace
next
trace
rm -fr besttrace
