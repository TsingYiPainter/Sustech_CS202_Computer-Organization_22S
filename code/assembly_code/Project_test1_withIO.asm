.data 
.text
###每次执行完对应的测试用例均跳转至begin重新输入测试用例
start: lui   $28,0xFFFF			
       ori   $28,$28,0xF000		
begin_1:
lw $s7,0xC7C($28)
bne $s7,$zero,begin_1
begin_2:
lw $s7,0xC7C($28)
beq $s7,$zero,begin_2
lw $a3,0xC78($28)#a3存放的是测试用例
sw $zero,0xC60($28)
sw $zero,0xC68($28)
addi $s2,$zero,0
beq $a3,$s2,test0_1
addi $s2,$s2,1
beq $a3,$s2,test1_1
addi $s2,$s2,1
beq $a3,$s2,test2_1
addi $s2,$s2,1
beq $a3,$s2,test3_1
addi $s2,$s2,1
beq $a3,$s2,test4_1
addi $s2,$s2,1
beq $a3,$s2,test5_1
addi $s2,$s2,1
beq $a3,$s2,test6_1
addi $s2,$s2,1
beq $a3,$s2,test7_1

####################################
test0_1:
lw $s7,0xC7C($28)
bne $s7,$zero,test0_1
test0_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test0_2
lw $v0,0xC70($28)#v0存放a的值，a存在C70字的低16位
sw $v0,0xC60($28)#将v0也就是a的值显示在led灯上
addi $s0,$v0,0#将v0存入s0与t0，方便比较
addi $t0,$v0,0
addi $t1,$zero,0
Loop1:
beq $t0,$zero,over1
sll $t1,$t1,1
addi $t2,$zero,1
and $t2,$t0,$t2
or $t1,$t1,$t2
srl $t0,$t0,1
j Loop1

over1:
beq $s0,$t1,bianryR
lui $v0,0
add $v0,$v0,$s0
sw $v0,0xC68($28)#若a不是回文数，则led灯不亮
j begin_1

bianryR:
lui $v0,1
add $v0,$v0,$s0
sw $v0,0xC68($28)#若a为回文数，则led灯亮
j begin_1

####################################
test1_1:
lw $s7,0xC7C($28)
bne $s7,$zero,test1_1
test1_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test1_2
lw $v0,0xC70($28)
sw $v0,0xC60($28)
addi $s0,$v0,0#s0保存a的值

inputb_1:
lw $s7,0xC7C($28)#s7表示使能信号，输入完a后，拨上拨码，从板子读取b的值，接着需要拨下开关，继续读取b
bne $s7,$zero,inputb_1
inputb_2:
lw $s7,0xC7C($28)
beq $s7,$zero,inputb_2
lw $v0,0xC70($28)
sw $v0,0xC60($28)
addi $s1,$v0,0#s1存放b的值
j begin_1
####################################
test2_1:
lw $s7,0xC7C($28)#s7表示使能信号，拨下开关，开始计算
bne $s7,$zero,test2_1
test2_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test2_2
and $a0,$s0,$s1
sw $a0,0xC60($28)
j begin_1
####################################
test3_1:
lw $s7,0xC7C($28)#s7表示使能信号，拨下开关，开始计算
bne $s7,$zero,test3_1
test3_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test3_2
or  $a0,$s0,$s1
sw  $a0,0xC60($28)
j begin_1
####################################
test4_1:
lw $s7,0xC7C($28)#s7表示使能信号，拨下开关，开始计算
bne $s7,$zero,test4_1
test4_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test4_2
xor  $a0,$s0,$s1
sw  $a0,0xC60($28)
j begin_1
####################################
test5_1:
lw $s7,0xC7C($28)#s7表示使能信号，拨下开关，开始计算
bne $s7,$zero,test5_1
test5_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test5_2
sllv $s0,$s0,$s1
addi $a0,$s0,0
sw  $a0,0xC60($28)
j begin_1
####################################
test6_1:
lw $s7,0xC7C($28)#s7表示使能信号，拨下开关，开始计算
bne $s7,$zero,test6_1
test6_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test6_2
srlv $s0,$s0,$s1
addi $a0,$s0,0
sw  $a0,0xC60($28)
j begin_1
####################################
test7_1:
lw $s7,0xC7C($28)#s7表示使能信号，拨下开关，开始计算
bne $s7,$zero,test7_1
test7_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test7_2
srav $s0,$s0,$s1
addi $a0,$s0,0
sw  $a0,0xC60($28)
j begin_1



