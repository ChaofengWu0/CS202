#2号寄存器存要读取的地址
lui $2,0x1001
ori $2,$2,0x28
#1号寄存器存储总共的位数
addi $1,$7,0
lw   $3,0($2)
circle_test:
addi $1,$1,-1
#把值存在3号寄存器中
lw   $3,0($2)
#加4
addi $3,$3,4
sw   $3,0xC60($28)
#5号寄存器用来判断
lw    $5,0xC40($28)
bne  $5,$21,during_test
during_test:
lw    $5,0xC40($28)
bne  $5,$22,during_test
bne $1,$0,circle_test
end_test:
