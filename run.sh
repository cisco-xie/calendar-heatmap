#!/bin/bash

# 检查是否有足够的参数传递给脚本
if [[ $# -lt 2 ]]; then
    echo "必须提供开始时间和结束时间两个参数，如：$0 2022-01-01$(date +%Y-%m-%d)"
    exit 1
fi

# 设置开始和结束时间戳
START_DAY=$(date -j -f "%Y-%m-%d" "$1" "+%s")
END_DAY=$(date -j -f "%Y-%m-%d" "$2" "+%s")

# 设置退出时的陷阱
trap resetTime EXIT

# 定义一个函数来在脚本退出时重置时间
resetTime() {
    # 系统时间同步
    sntp -sS time.apple.com
    echo "重置时间"
}

# 生成一周中随机几天的数组
generateRandomWeekdays() {
    shuf -i 1-7 -n $(shuf -i 4-6 -n 1) # 随机选择2到4天
}

# 定义修改函数
modify() {
    echo "处理中……"
    while (( "${START_DAY}" <= "${END_DAY}" )); do

        # 生成随机工作日数组
        WEEKDAYS=( $(generateRandomWeekdays) )

        # 获取当前日期的星期几
        cur_weekday=$(date -j -f "%s" "${START_DAY}" "+%u")

        # 检查今天是否是选中的工作日
         if [[ " ${WEEKDAYS[*]} " =~ "${cur_weekday} " ]]; then
            # 转换时间戳为日期格式
            cur_day=$(date -r ${START_DAY} +"%m%d%H%M%Y")

            # 修改系统时间
            date "${cur_day}"
            # 随机选择1到30次提交
            for (( i=0; i<$(shuf -i 1-30 -n 1); i++ )); do
                # 模拟Git提交
                commit="${cur_day} feature: random commit${i}"
                echo "${commit}" > log.txt
                # 提交
                git add .
                # GIT_AUTHOR_DATE="${cur_day} 12:00:00" \
                # GIT_COMMITTER_DATE="${cur_day} 12:00:00" \
                git commit -m "${commit}"
                # echo "提交：${commit}"
            done
            echo "选中时间是$(date -j -f "%s" "${START_DAY}" "+%Y-%m-%d"),在${WEEKDAYS[*]}中选中了周${cur_weekday}"
         fi

        # 增加一天的时间戳
        START_DAY=$((START_DAY + 86400))
    done

    echo "处理完成"
}

# 调用修改函数
modify

exit 0