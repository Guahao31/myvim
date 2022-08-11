# 用来存放myvim的辅助函数定义

# 打印当前页
print_page() {
    curr_row=0
    # IFS= 是为了避免字符串前后的空白符被截去
    while IFS= read -r one_line; do
        if [ $curr_row -ne $cur_pos_row ]; then
            echo "$one_line"
        else
            if [ $cur_pos_col -ne ${#one_line} ]; then
                # 通过格式化输出，将光标处的背景调为浅色
                echo -n "${one_line:0:$cur_pos_col}" # -n 避免echo添加换行
                echo -e -n "\e[100m${one_line:$cur_pos_col:1}" # -e用来打开echo对转义符号的开关
                cur_next_col=$cur_pos_col+1
                echo -e "\e[0m${one_line:$cur_next_col}" # 转为正常前景背景，输出光标后边的内容
            else
                # 光标在行末
                echo -n "$one_line"
                echo -e "\e[100m \e[0m" # 在行末打印空格，表示光标所在位置
            fi
        fi
            ((++curr_row)) # 行数计数器自增1
    done < "$temp_file"
}

myvim_left() {
    # 处理光标左移
    if [ $cur_pos_col -gt 0 ]; then
        # 如果目前光标并不在第一个位置，则将光标左移
        cur_pos_col=$((cur_pos_col-1))
    fi
}

myvim_right() {
    # 处理光标右移
    if [ $cur_pos_col -lt ${#curr_line} ]; then
        # 最多允许到最大长度加一(即编辑行末)
        cur_pos_col=$((cur_pos_col+1))
    fi
}