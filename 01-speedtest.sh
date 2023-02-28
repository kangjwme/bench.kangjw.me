#!/usr/bin/env bash
trap _exit INT QUIT TERM

# 
_red() {
    printf '\033[0;31;31m%b\033[0m' "$1"
}

_green() {
    printf '\033[0;31;32m%b\033[0m' "$1"
}

_yellow() {
    printf '\033[0;31;33m%b\033[0m' "$1"
}

_blue() {
    printf '\033[0;31;36m%b\033[0m' "$1"
}

_exit() {
    _red "\nThe script has been terminated.\n"
    rm -fr speedtest-cli
    exit 1
}

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print $0}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

speed_test() {
    local nodeName="$2"
    [ -z "$1" ] && ./speedtest-cli/speedtest --progress=no --accept-license --accept-gdpr > ./speedtest-cli/speedtest.log 2>&1 || \
    ./speedtest-cli/speedtest --progress=no --server-id=$1 --accept-license --accept-gdpr > ./speedtest-cli/speedtest.log 2>&1
    if [ $? -eq 0 ]; then
        local dl_speed=$(awk '/Download/{print $3" "$4}' ./speedtest-cli/speedtest.log)
        local up_speed=$(awk '/Upload/{print $3" "$4}' ./speedtest-cli/speedtest.log)
        local latency=$(awk '/Latency/{print $2" "$3}' ./speedtest-cli/speedtest.log)
        local url=$(awk '/Result/{print $3}' ./speedtest-cli/speedtest.log)
        if [[ -n "${dl_speed}" && -n "${up_speed}" && -n "${latency}" && -n "${url}" ]]; then
            printf "%-26s%-18s%-18s%-12s%-12s\n" " ${nodeName}" "${up_speed}" "${dl_speed}" "${latency}" "${url}"
        fi
    fi
}

speed() {
    
    speed_test '' 'Speedtest.net'
    speed_test '18445' 'TW, Chunghwa Mobile'
    speed_test '11703' 'TW, Taiwan Mobile'
    speed_test '3967' 'TW, Chief Telecom'
    speed_test '13506' 'TW, TAIFO'
    speed_test '2133' 'TW, TFN'
    speed_test '35066' 'TW, DFT'
    speed_test '2327' 'TW, FET'
    speed_test '27377' 'CN, Beijing CT'
    speed_test '26352' 'CN, Nanjing CT'
    speed_test '17145' 'CN, Hefei CT'
    speed_test '27594' 'CN, Guangzhou CT'
    speed_test '27154' 'CN, TianJin CU'
    speed_test '24447' 'CN, hanghai CU'
    speed_test '26678' 'CN, Guangzhou CU'
    speed_test '17184' 'CN, Tianjin CM'
    speed_test '26850' 'CN, Wuxi CM'
    speed_test '27249' 'CN, Nanjing CM'
    speed_test '26404' 'CN, Hefei CM'
    speed_test '28491' 'CN, Changsha CM'
    speed_test '6435' 'CN, Xiangyang CT'
    speed_test '7509' 'CN, Kunming CT'
	speed_test '3633' 'CN, Shanghai CT'
	speed_test '4624' 'CN, Chengdu CT'
	speed_test '5017' 'CN, Shenyang CU'
	speed_test '4863' 'CN, Xian CU'
	speed_test '5083' 'CN, Shanghai CU'
	speed_test '5726' 'CN, Chongqing CU'
	speed_test '5292' 'CN, Xian CM'
	speed_test '16314' 'CN, Shandong CM'
    speed_test '6715' 'CN, Ningbo CM'
	speed_test '4575' 'CN, Chengdu CM'
    speed_test '34555' 'HK, HKIX'
    speed_test '16176' 'HK, HGC'
    speed_test '22126' 'HK, i3D.net'
    speed_test '21569' 'JP, i3D.net'
    speed_test '50686' 'JP, GSL Networks'
    speed_test '28910' 'JP, fdcservers.net'
    speed_test '40508' 'SG, i3D.net'
    speed_test '367' 'SG, NewMedia Express'
    speed_test '41650' 'SG, SuperInternet'
    speed_test '46246' 'MY, Telekom Malaysia'
    speed_test '5527' 'MY, Celcom'
    speed_test '50771' 'DE, GSL Networks'
    speed_test '46569' 'DE, wirsNET'
    speed_test '31851' 'TR, Turkcell'
    speed_test '11250' 'TR, TurkNet'

    
}

install_speedtest() {
    if [ ! -e "./speedtest-cli/speedtest" ]; then
        sys_bit=""
        local sysarch="$(uname -m)"
        if [ "${sysarch}" = "unknown" ] || [ "${sysarch}" = "" ]; then
            local sysarch="$(arch)"
        fi
        if [ "${sysarch}" = "x86_64" ]; then
            sys_bit="x86_64"
        fi
        if [ "${sysarch}" = "i386" ] || [ "${sysarch}" = "i686" ]; then
            sys_bit="i386"
        fi
        if [ "${sysarch}" = "armv8" ] || [ "${sysarch}" = "armv8l" ] || [ "${sysarch}" = "aarch64" ] || [ "${sysarch}" = "arm64" ]; then
            sys_bit="aarch64"
        fi
        if [ "${sysarch}" = "armv7" ] || [ "${sysarch}" = "armv7l" ]; then
            sys_bit="armhf"
        fi
        if [ "${sysarch}" = "armv6" ]; then
            sys_bit="armel"
        fi
        [ -z "${sys_bit}" ] && _red "Error: Unsupported system architecture (${sysarch}).\n" && exit 1
        url1="https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-${sys_bit}.tgz"
        url2="https://dl.lamp.sh/files/ookla-speedtest-1.1.1-linux-${sys_bit}.tgz"
        wget --no-check-certificate -q -T10 -O speedtest.tgz ${url1}
        if [ $? -ne 0 ]; then
            wget --no-check-certificate -q -T10 -O speedtest.tgz ${url2}
            [ $? -ne 0 ] && _red "Error: Failed to download speedtest-cli.\n" && exit 1
        fi
        mkdir -p speedtest-cli && tar zxf speedtest.tgz -C ./speedtest-cli && chmod +x ./speedtest-cli/speedtest
        rm -f speedtest.tgz
    fi
    printf "%-26s%-18s%-18s%-12s%-12s\n" " Node Name" "Upload Speed" "Download Speed" "Latency" "Result"
}

install_speedtest && speed && rm -fr speedtest-cli