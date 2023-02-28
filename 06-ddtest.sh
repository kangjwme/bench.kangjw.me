WorkDir="/tmp/.LemonBench"
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

Run_DiskTest_DD() {
    # 调用方式: Run_DiskTest_DD "测试文件名" "块大小" "写入次数" "测试项目名称"
    mkdir -p ${WorkDir}/DiskTest/ >/dev/null 2>&1
    
    mkdir -p /.tmp_LBench/DiskTest >/dev/null 2>&1
    mkdir -p ${WorkDir}/data >/dev/null 2>&1
    local Var_DiskTestResultFile="${WorkDir}/data/disktest_result"
    # 将先测试读, 后测试写
    echo -n -e " $4\t\t->\c"
    # 清理缓存, 避免影响测试结果
    sync
    # 避免磁盘压力过高, 启动测试前暂停1s
    sleep 1
    # 正式写测试
    dd if=/dev/zero of=/.tmp_LBench/DiskTest/$1 bs=$2 count=$3 oflag=direct 2>${Var_DiskTestResultFile}
    local DiskTest_WriteSpeed_ResultRAW="$(cat ${Var_DiskTestResultFile} | grep -oE "[0-9]{1,4} kB\/s|[0-9]{1,4}.[0-9]{1,2} kB\/s|[0-9]{1,4} KB\/s|[0-9]{1,4}.[0-9]{1,2} KB\/s|[0-9]{1,4} MB\/s|[0-9]{1,4}.[0-9]{1,2} MB\/s|[0-9]{1,4} GB\/s|[0-9]{1,4}.[0-9]{1,2} GB\/s|[0-9]{1,4} TB\/s|[0-9]{1,4}.[0-9]{1,2} TB\/s|[0-9]{1,4} kB\/秒|[0-9]{1,4}.[0-9]{1,2} kB\/秒|[0-9]{1,4} KB\/秒|[0-9]{1,4}.[0-9]{1,2} KB\/秒|[0-9]{1,4} MB\/秒|[0-9]{1,4}.[0-9]{1,2} MB\/秒|[0-9]{1,4} GB\/秒|[0-9]{1,4}.[0-9]{1,2} GB\/秒|[0-9]{1,4} TB\/秒|[0-9]{1,4}.[0-9]{1,2} TB\/秒")"
    DiskTest_WriteSpeed="$(echo "${DiskTest_WriteSpeed_ResultRAW}" | sed "s/秒/s/")"
    local DiskTest_WriteTime_ResultRAW="$(cat ${Var_DiskTestResultFile} | grep -oE "[0-9]{1,}.[0-9]{1,} s|[0-9]{1,}.[0-9]{1,} s|[0-9]{1,}.[0-9]{1,} 秒|[0-9]{1,}.[0-9]{1,} 秒")"
    DiskTest_WriteTime="$(echo ${DiskTest_WriteTime_ResultRAW} | awk '{print $1}')"
    DiskTest_WriteIOPS="$(echo ${DiskTest_WriteTime} $3 | awk '{printf "%d\n",$2/$1}')"
    DiskTest_WritePastTime="$(echo ${DiskTest_WriteTime} | awk '{printf "%.2f\n",$1}')"
    if [ "${DiskTest_WriteIOPS}" -ge "10000" ]; then
        DiskTest_WriteIOPS="$(echo ${DiskTest_WriteIOPS} 1000 | awk '{printf "%.2f\n",$2/$1}')"
        echo -n -e "\r $4\t\t${Font_SkyBlue}${DiskTest_WriteSpeed} (${DiskTest_WriteIOPS}K IOPS, ${DiskTest_WritePastTime}s)${Font_Suffix}\t\t->\c"
    else
        echo -n -e "\r $4\t\t${Font_SkyBlue}${DiskTest_WriteSpeed} (${DiskTest_WriteIOPS} IOPS, ${DiskTest_WritePastTime}s)${Font_Suffix}\t\t->\c"
    fi
    # 清理结果文件, 准备下一次测试
    rm -f ${Var_DiskTestResultFile}
    # 清理缓存, 避免影响测试结果
    sync
    if [ "${Var_VirtType}" != "docker" ] && [ "${Var_VirtType}" != "wsl" ]; then
        echo 3 >/proc/sys/vm/drop_caches
    fi
    sleep 0.5
    # 正式读测试
    dd if=/.tmp_LBench/DiskTest/$1 of=/dev/null bs=$2 count=$3 iflag=direct 2>${Var_DiskTestResultFile}
    local DiskTest_ReadSpeed_ResultRAW="$(cat ${Var_DiskTestResultFile} | grep -oE "[0-9]{1,4} kB\/s|[0-9]{1,4}.[0-9]{1,2} kB\/s|[0-9]{1,4} KB\/s|[0-9]{1,4}.[0-9]{1,2} KB\/s|[0-9]{1,4} MB\/s|[0-9]{1,4}.[0-9]{1,2} MB\/s|[0-9]{1,4} GB\/s|[0-9]{1,4}.[0-9]{1,2} GB\/s|[0-9]{1,4} TB\/s|[0-9]{1,4}.[0-9]{1,2} TB\/s|[0-9]{1,4} kB\/秒|[0-9]{1,4}.[0-9]{1,2} kB\/秒|[0-9]{1,4} KB\/秒|[0-9]{1,4}.[0-9]{1,2} KB\/秒|[0-9]{1,4} MB\/秒|[0-9]{1,4}.[0-9]{1,2} MB\/秒|[0-9]{1,4} GB\/秒|[0-9]{1,4}.[0-9]{1,2} GB\/秒|[0-9]{1,4} TB\/秒|[0-9]{1,4}.[0-9]{1,2} TB\/秒")"
    DiskTest_ReadSpeed="$(echo "${DiskTest_ReadSpeed_ResultRAW}" | sed "s/s/s/")"
    local DiskTest_ReadTime_ResultRAW="$(cat ${Var_DiskTestResultFile} | grep -oE "[0-9]{1,}.[0-9]{1,} s|[0-9]{1,}.[0-9]{1,} s|[0-9]{1,}.[0-9]{1,} 秒|[0-9]{1,}.[0-9]{1,} 秒")"
    DiskTest_ReadTime="$(echo ${DiskTest_ReadTime_ResultRAW} | awk '{print $1}')"
    DiskTest_ReadIOPS="$(echo ${DiskTest_ReadTime} $3 | awk '{printf "%d\n",$2/$1}')"
    DiskTest_ReadPastTime="$(echo ${DiskTest_ReadTime} | awk '{printf "%.2f\n",$1}')"
    rm -f ${Var_DiskTestResultFile}
    # 输出结果
    echo -n -e "\r $4\t\t${Font_SkyBlue}${DiskTest_WriteSpeed} (${DiskTest_WriteIOPS} IOPS, ${DiskTest_WritePastTime}s)${Font_Suffix}\t\t${Font_SkyBlue}${DiskTest_ReadSpeed} (${DiskTest_ReadIOPS} IOPS, ${DiskTest_ReadPastTime}s)${Font_Suffix}\n"
    echo -e " $4\t\t${DiskTest_WriteSpeed} (${DiskTest_WriteIOPS} IOPS, ${DiskTest_WritePastTime} s)\t\t${DiskTest_ReadSpeed} (${DiskTest_ReadIOPS} IOPS, ${DiskTest_ReadPastTime} s)" >>${WorkDir}/DiskTest/result.txt
    rm -rf /.tmp_LBench/DiskTest/
}
Function_DiskTest_Full() {
    mkdir -p ${WorkDir}/DiskTest/ >/dev/null 2>&1
    echo -e "\n ${Font_Yellow}-> Disk Speed Test (4K Block/1M Block, Direct-Write)${Font_Suffix}\n"
    echo -e "\n -> Disk Speed Test (4K Block/1M Block, Direct-Write)\n" >>${WorkDir}/DiskTest/result.txt
    echo -e " ${Font_Yellow}Test Name\t\tWrite Speed\t\t\t\tRead Speed${Font_Suffix}"
    echo -e " Test Name\t\tWrite Speed\t\t\t\tRead Speed" >>${WorkDir}/DiskTest/result.txt
    Run_DiskTest_DD "10MB.test" "4k" "2560" "10MB-4K Block"
    Run_DiskTest_DD "10MB.test" "1M" "10" "10MB-1M Block"
    Run_DiskTest_DD "100MB.test" "4k" "25600" "100MB-4K Block"
    Run_DiskTest_DD "100MB.test" "1M" "100" "100MB-1M Block"
    Run_DiskTest_DD "1GB.test" "4k" "256000" "1GB-4K Block"
    Run_DiskTest_DD "1GB.test" "1M" "1000" "1GB-1M Block"
    # 执行完成, 标记FLAG
    LBench_Flag_FinishDiskTestFull="1"
    sleep 1
}
Function_DiskTest_Full