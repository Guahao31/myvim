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
if [ -e $temp_file ]; then
    echo "Some other myvim is editing $file_name."
    exit 1
fi
# 如果文件存在，则将内容复制到临时文件中，如果文件不存在，则直接新建一个临时文件
if [ -e $file_name ]; then
    cp $file_name $temp_file # 拷贝获得临时文件
else
    touch $temp_file # 文件不存在，直接新建一个临时文件
fi

# 规定起始光标位置
cur_pos_col=0
cur_pos_row=0

# 清除屏幕并准备打印文件内容
clear # 清屏
tput civis # 取消终端光标的显示

print_page 

# set | tail # 查看文件所有的参数内容

rm $temp_file # 删除临时文件

tput cvvis # 退出时，恢复光标

# 检查文件是否存在