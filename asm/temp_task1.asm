.data 0x0000
.text 0x0000

start:
j main_func
# 1寄存器在每次循环之后会得到输入的值（后16个开关的值）,且在最后会以灯的亮灭来显示结果
# 3寄存器在每次循环之后会得到输入的值（前8个开关的值，前八位为0），且在最后会以灯的亮灭来显示结果
# 2寄存器用来帮助获取最左边开关的值
# 4寄存器用来保存每次获取的值
# 5寄存器用来获取测试场景的值
# 每次load_data的时候，就会刷新1,2,3, 4,5寄存器的值
load_data:
addi $20,$0,0
addi $21,$0,1
addi $22,$0,2
addi $23,$0,3
addi $24,$0,4
addi $25,$0,5
addi $26,$0,6
addi $27,$0,7
lui   $1,0xFFFF   
ori   $28,$1,0xF000        
switled_func: 
lw   $1,0xC70($28) 
lw   $3,0xC72($28)  
andi $2,$3,1
# 2已经取到了左边第八位的数

# 下面是获取5寄存器内最终值的过程
addi  $5,$3,0
srl     $5,$5,5
addi  $4,$1,0
# 这两行可要可不要
#sw   $1,0xC60($28)    
#sw   $3,0xC62($28)  

beq  $2,$21,during
j switled_func
during:
lw   $3,0xC72($28)  
andi $2,$3,1
beq $2,$20,test1
j during
#ra寄存器
# 到此为止 方法体load_data写完了，其中
# 4寄存器用来保存每次获取的值
# 5寄存器用来获取测试场景的值

main_func:
j 	load_data
test1:
beq $5,$20,case1
beq $5,$21,case2
beq $5,$22,case3
beq $5,$23,case4
beq $5,$24,case5
beq $5,$25,case6
beq $5,$26,case7
beq $5,$27,case8

# case1
case1:
# 在这个case1中，相关的是四号寄存器,其他的寄存器其实可以随便修改，不会影响任何后续结果
j    load_data
sw   $4,0xC60($28)    
# 10号寄存器用来辅佐
# 在这行之后，开关输入的值已经存入了4号寄存器，而且4号的值，已经显示在了右边的16个灯上面,接下来是判断是否是回文数字,规定，如果是回文数字
# 我就亮起左边八个灯中的最右边的一个
addi $10,$4,0

loop_for_2:
sll $2,$2,1
andi $3,$10,1
or $2,$3,$2
sra $10,$10,1
bne $10,$zero,loop_for_2

#出来之后，4寄存器是原值，2寄存器是回文值
beq $4,$2,yes
no:
addi $1,$20,128
sw   $1,0xC62($28)
j load_data
yes:
addi $1,$20,1
sw   $1,0xC62($28)
j load_data



# case2
case2:
jal load_data
addi $6,$4,0
sw   $6,0xC60($28)  


jal load_data
addi  $7,$4,0
sw   $7,0xC60($28)  
j load_data

# case3
case3:
and $8,$6,$7
sw   $8,0xC60($28)  
j load_data

# case4
case4:
or $8,$6,$7
sw   $8,0xC60($28)  
j load_data


case5:
xor  $8,$6,$7
sw   $8,0xC60($28)  
j load_data


#9寄存器作为辅助寄存器
case6:
addi  $9,$7,0
circle6:
sll     $8,$6,1
sub  $9,$9,$21
bne   $9,$0,circle6
j load_data

case7:
addi  $9,$7,0
circle7:
srl     $8,$6,1
sub   $9,$9,$21
bne   $9,$0,circle7
j load_data

case8:
addi  $9,$7,0
circle8:
sra   $8,$6,1
sub  $9,$9,$21
bne   $9,$0,circle8
j  load_data










