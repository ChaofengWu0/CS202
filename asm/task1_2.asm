.data 0x0000
.text 0x0000



case2:
#这时候已经读取了当前值存在4里面,第一个数放到6寄存器中
jal load_data
addi $6,$4,0
sw   $6,0xC60($28)  


jal load_data
addi  $7,$4,0
sw   $7,0xC60($28)  
j end




load_data:
addi  $20,$0,0
addi  $21,$0,1
lui   $1,0xFFFF   
ori   $28,$1,0xF000        
switled:


lw   $1,0xC70($28) 
lw   $3,0xC72($28)  
sw   $3,0xC62($28)  

addi $2,$3,0
# 2已经取到了左边八位的数
# 下面是获取5寄存器内最终值的过程

sra  $2,$2,7
# 此时$2的值就取到了
addi $4,$1,0
# 这两行可要可不要
#sw   $1,0xC60($28)    
#sw   $3,0xC62($28)  

beq  $2,$21,during
j switled
during:
lw   $3,0xC72($28)  
beq $3,$20,jump
j during
# 到此为止 方法体load_data写完了，其中
# 4寄存器用来保存每次获取的值
# 5寄存器用来获取测试场景的值
jump:
jr  $31


end:
j end










