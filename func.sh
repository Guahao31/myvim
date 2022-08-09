# 用来存放myvim的辅助函数定义

# 打印当前页
print_page() {
    curr_row=0
    # IFS= 是为了避免字符串前后的空白符被截去
    while IFS= read -r one_line; do
        if [ $curr_row -ne $cur_pos_row ]; then
            echo "$one_line"
        else
            # 通过格式化输出，将光标处的背景调为浅色
            echo -n "${one_line:0:$cur_pos_col}" # -n 避免echo添加换行
            echo -e -n "\e[100m${one_line:$cur_pos_col:1}" # -e用来打开echo对转义符号的开关
            cur_next_col=$cur_pos_col+1
            echo -e "\e[0m${one_line:$cur_next_col}" # 转为正常前景背景，输出光标后边的内容
        fi
            ((++curr_row)) # 行数计数器自增1
    done < "$temp_file"
}