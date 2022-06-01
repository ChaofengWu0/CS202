.data 0x0000
    # 申请了4x10个32bit连续内存空间
    # 0x10010000
    group0_0: .word 0
    group0_1: .word 0
    group0_2: .word 0
    group0_3: .word 0
    group0_4: .word 0
    group0_5: .word 0
    group0_6: .word 0
    group0_7: .word 0
    group0_8: .word 0
    group0_9: .word 0
    # 0x10010028
    group1_0: .word 0
    group1_1: .word 0
    group1_2: .word 0
    group1_3: .word 0
    group1_4: .word 0
    group1_5: .word 0
    group1_6: .word 0
    group1_7: .word 0
    group1_8: .word 0
    group1_9: .word 0
    # 0x10010050
    group2_0: .word 0
    group2_1: .word 0
    group2_2: .word 0
    group2_3: .word 0
    group2_4: .word 0
    group2_5: .word 0
    group2_6: .word 0
    group2_7: .word 0
    group2_8: .word 0
    group2_9: .word 0
    # 0x10010078
    group3_0: .word 0
    group3_1: .word 0
    group3_2: .word 0
    group3_3: .word 0
    group3_4: .word 0
    group3_5: .word 0
    group3_6: .word 0
    group3_7: .word 0
    group3_8: .word 0
    group3_9: .word 0

.text  0x0000
# 寄存器注意事项
# 7号寄存器用于存储输入的个数 请勿再次改变7号寄存器
# 20号至27号寄存器为常数寄存器 请勿再次更改
# 28号寄存器用于储存外设基地址 请勿再次更改
# 1号寄存器规定为右侧16个拨码开关数值
# 2号寄存器规定为小键盘状态值
# 3号寄存器规定为左侧8个拨码开关数值
# 4号5号寄存器在顶层模块中被使用 请勿再次更改
# 9至19号寄存器均可用于运算 规定使用前对其数值初始化
# 9号寄存器一般被视为地址指针

initial:
    lui $1, 0xFFFF
    ori $28, $1, 0xF000
    # 此时28号寄存器中为0xFFFFF000
    addi $20,$0,0 # 000
    addi $21,$0,1 # 001
    addi $22,$0,2 # 010
    addi $23,$0,3 # 011
    addi $24,$0,4 # 100
    addi $25,$0,5 # 101
    addi $26,$0,6 # 110
    addi $27,$0,7 # 111
    # 此时20至27号寄存器存储着0至7

# 顶层模块 每个case运行完成后回到此模块
scene_begin:
    # 1号寄存器存储右侧16个拨码开关的数值
    lw $1, 0xC70($28)
    # 3号寄存器存储左侧8个拨码开关的数值
    lw $3, 0xC72($28)
    # 2号寄存器存储小键盘的状态值
    lw $2, 0xC40($28)
    # 二号寄存器存储的是小键盘状态
 
    addi $5, $3, 0
    srl $5, $5, 5
    addi $4, $1, 0
    # 5号寄存器中存储左数3位开关的数值 
    # 4号寄存器存储前16个开关的数值
    
    # 当小键盘状态为1时 进入信号等待模块 否则继续循环此模块
    beq $2, $21, wait_switch_signal
    j scene_begin

# 信号等待模块 一般需要等待小键盘状态值变化为2
wait_switch_signal:
    # 当小键盘状态为2时 进入case判断模块 否则继续循环此模块
    lw $3, 0xC72($28)
    lw $2, 0xC40($28)
    beq $2, $22, case_select
    j wait_switch_signal

# case判断模块
case_select:
    beq $5,$20,case0
    beq $5,$21,case1


case0:
    # 3'b000 输入测试数据的个数(0到10之间) >10进入异常
    # 小键盘确定 地址为C40
    # 将数据的个数固定存在7号寄存器 请勿再次改变7号寄存器
    # 数据的读入沿用1号寄存器 
    # 将9号寄存器初始化为 0x10010000
    lui $9, 0x1001

    wait_button_signal0_0:
        # 从C40循环读取 读到1时跳出
        lw $7, 0xC70($28)
        sw $7, 0xC60($28)
        lw $2, 0xC40($28)
        bne $2, $21, wait_button_signal0_0

    wait_button_zero0_0:
        # 从C40循环读取 读到2时跳出
        lw $2, 0xC40($28)
        bne $2, $22, wait_button_zero0_0

    # 清空led
    sw $20, 0xC60($28)
    # todo: exception

    # 将$10初始化为0
    addi $10, $20, 0

    loop_input:
        # 临时使用10号寄存器进行累加 结束后对其归零 后续可调用
        # 从C40循环读取 读到1时跳出
        lw $1, 0xC70($28)
        lw $2, 0xC40($28)
        bne $2, $21, loop_input

        wait_button_zero0_1:
            # 从C40循环读取 读到2时跳出
            lw $2, 0xC40($28)
            bne $2, $22, wait_button_zero0_1  

        # 显示已经完成读取的数据
        sw $1, 0xC60($28)
        # 将读取的数据存入内存
        sw $1, 0($9)
        # 计数器++
        addi $10, $10, 1
        # 地址加4
        addi $9, $9, 4
        # 判断循环次数
        beq $10, $7, scene_begin # 正常状态应为secen_begin
        j loop_input

# case0结束

case1:
    j place


#单独的一个方法段，用来把9寄存器内的值转移到想要放置的地址的位置
place:
lui  $10,0x1001
addi $9,$10,0
ori  $10,$10,0x28
addi $14,$10,0
#9号寄存器的值存入了13号寄存器
addi $13,$9,0
#10寄存器存着要存入的位置的首地址
#11寄存器存着有多少个数
addi $11,$7,0
circle:
sub $11,$11,$21
lw   $12,0($13)
addi $13,$13,4
sw   $12,0($10)
addi $10,$10,4
beq  $11,$20,sort
j circle


#从7号寄存器拿出有多少个数据，9号寄存器存着初始地址，每个数据32位，将排序完的数据存入0x10010140中
# 可用的寄存器的编号为10-16
sort:
addi $9,$0,0
addi $10,$0,0
addi $11,$0,0
addi $12,$0,0
addi $13,$0,0
addi $15,$0,0
addi $16,$0,0
addi $17,$0,0
addi $18,$0,0

outer_loop:
slt  $12,$9,$7
beq  $12,$20,exit_outer
get_index:
addi $11,$9,0
addi $10,$9,0
inner_loop:
slt   $12,$10,$7
beq  $12,$20,exit_inner

# 这里是拿arr[min]的过程  15 = arr[min]
sll $13,$11,2
add $13,$13,$14
lw    $15,0($13)
# 这里是拿arr[j]的过程    16 = arr[j]
sll     $13,$10,2
add  $13,$13,$14
lw    $16,0($13)

#17存arr[min]的符号位,18存arr[j]的符号位
andi $17,$15,128
andi $18,$16,128
beq  $17,$18,same_signbit
#符号位不同
slt    $12,$18,$17
j       exchange

same_signbit:
beq   $17,$20,zero
j  one
zero:
slt    $12,$15,$16
j exchange
one:
andi  $15,$15,127
andi  $16,$16,127

slt    $12,$16,$15
j  exchange

exchange:
#判断是否要更换值
beq  $12,$21,increament
addi $11,$10,0

increament:
addi $10,$10,1
j inner_loop

exit_inner:
#todo
j swap
back:
addi $9,$9,1
j outer_loop

exit_outer:
addi $19,$20,127
sw $19, 0xC62($28)
j test_case_1


swap:
#得到第一个地址,存到13(中转寄存器),并且将值存入15寄存器
sll    $13,$9,2
add  $13,$13,$14
lw  $15,0($13)

sll    $17,$11,2
add  $17,$17,$14
lw  $16,0($17)

sw  $16,0($13)
sw  $15,0($17) 
j back























test_case_1:
    lui $9, 0x1001
    addi $9, $9, 0x0028
    addi $10, $20, 0
    addi $11, $20, 0

    test_loop_1:
        lw $6, 0xC40($28)
        bne $6, $21, test_loop_1

        wait_button_zero_test_2_0:
            lw $6, 0xC40($28)
            bne $6, $22, wait_button_zero_test_2_0

        lw $11, 0($9)
        sw $11, 0xC60($28)

        addi $10, $10, 1
        addi $9, $9, 4
        bne $10, $7, test_loop_1
    
    wait_button_signal_test_2_1:
        lw $6, 0xC40($28)
        bne $6, $21, wait_button_signal_test_2_1

    wait_button_zero_test_2_1:
        lw $6, 0xC40($28)
        bne $6, $22, wait_button_zero_test_2_1

    # 显示完所有数据后再次按下按键 灯全灭
    sw $20, 0xC60($28)
    j scene_begin


