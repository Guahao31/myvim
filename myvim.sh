#!/bin/bash

source func.sh # 使辅助函数生效

# 检查参数
if [ $# -ne 1 ]; then
    echo "myvim: Expected 1 parameter with the file name to edit."
    exit 1
fi

# 获取文件名
file_name=$1
temp_file=.$1.my_tmp

# 准备建立编辑暂存使用的文件 形式为 file_name.my_tmp
# 检查当前是否存在暂存文件，如果存在，证明其他myvim正在编辑本文本
# 报错并退出
# if [ -e $temp_file ]; then
#     echo "Some other myvim is editing $file_name."
#     exit 1
# fi

curr_line="" # 记录光标当前所在的行的内容
# 如果文件存在，则将内容复制到临时文件中，如果文件不存在，则直接新建一个临时文件
if [ -e $file_name ]; then
    cp $file_name $temp_file # 拷贝获得临时文件
    # 获取第一行内容到curr_line
    # $()获取指令输出到环境变量
    # cat file_name带行数打印文件内容通过管道传给sed，-n选取第一行传给curr_line
    curr_line=$(cat $temp_file | sed -n '1p')
else
    touch $temp_file # 文件不存在，直接新建一个临时文件
fi

# 规定起始光标位置
cur_pos_col=0
cur_pos_row=0

tput civis # 取消终端光标的显示
# 初始打印
clear; print_page

main_part() {
    local edit_mode=0 # 为0时表示正常模式，1为编辑模式

    # 主体部分，退出前一直循环，每次处理一个字符的输入
    while read -s -N1 input; do
        # -s 不将用户的输入反映到终端输出；-N1 每次读入1个字符

        # 参考 https://stackoverflow.com/questions/10679188/casing-arrow-keys-in-bash 中的回答
        # 处理上下左右按键
        # -t 指定获取多长时间内的下一个输入，用来组成上下左右键的esc后的部分
        # 超过-t指定时间的读入并不会记录
        read -s -N1 -t 0.0001 k1
        read -s -N1 -t 0.0001 k2
        input=${input}${k1}${k2}

        # 获得目前处理的行内容
        curr_line=$(cat $temp_file | sed -n $((cur_pos_row+1))'p')

        local modify_line="";

        if [ $edit_mode -eq 0 ]; then
            # 正常模式
            case $input in
                j|$'\e[D'|$'\e0D') myvim_left   ;;  # 左移动
                k|$'\e[C'|$'\e0C') myvim_right  ;;  # 右移动
                h|$'\e[A'|$'\e0A') myvim_up     ;;  # 上移动
                l|$'\e[B'|$'\e0B') myvim_down   ;;  # 下移动
                i) edit_mode=1  ;;  # 进入编辑模式
                w) myvim_save   ;;  # 保存
                q) break        ;;  # 退出
                d) myvim_del    ;;  # 删除所在行
                # NOTE: 待完善，在底部显示错误提示；支持d删除单行
                # d)
                # *)
            esac
        else
            case $input in
                $'\x1b') edit_mode=0    ;; # ESC，退出编辑模式
                $'\e[A'|$'\e0A') myvim_up       ;; # 上移动
                $'\e[B'|$'\e0B') myvim_down     ;; # 下移动
                $'\e[C'|$'\e0C') myvim_right    ;; # 右移动
                $'\e[D'|$'\e0D') myvim_left     ;; # 左移动
                $'\x7f') # 回退键
                    if [ $cur_pos_col -gt 0 ]; then
                        # 如果光标位置大于1，即光标前仍有字符，则可以进行回退
                        modify_line=${curr_line:0:$cur_pos_col-1}${curr_line:$cur_pos_col}
                        sed -i $((cur_pos_row+1))'s/.*/'"${modify_line}"'/' ${temp_file}
                        cur_pos_col=$((cur_pos_col-1))
                    fi
                ;;
                $'\n') # 换行键
                    # NOTE: 换行键将cursor前的内容保留到本行，将后边内容插入到下一行
                    myvim_enter
                ;;
                *) # 其他输入
                    # 处理输入
                    modify_line=${curr_line:0:$cur_pos_col}$input${curr_line:$cur_pos_col}
                    sed -i $((cur_pos_row+1))'s/.*/'"${modify_line}"'/' ${temp_file}
                    cur_pos_col=$((cur_pos_col+1)) # 移动光标到下一个字符
                ;;
            esac
        fi

        # 清除屏幕并准备打印文件内容
        clear # 清屏
        print_page # 打印内容

    done
}

main_part

# set | tail # 查看文件所有的参数内容

rm $temp_file # 删除临时文件

tput cvvis # 退出时，恢复光标

