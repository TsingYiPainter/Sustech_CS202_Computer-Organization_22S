.data
array0: .space 40
array1: .space 40
array2: .space 40
array3: .space 40

.text
start: 
       lui   $28,0xFFFF			
       ori   $28,$28,0xF000
       lui $at,0

#�ȴ�������       
begin_1:
lw $s7,0xC7C($28)
bne $s7,$zero,begin_1
begin_2:
lw $s7,0xC7C($28)
beq $s7,$zero,begin_2
sw $zero,0xC60($28)
lw $v0,0xC78($28)#v0��ŵ��ǲ�������

addi $s5,$zero,0
beq $v0,$s5,test0_1
addi $s5,$s5,1
beq $v0,$s5,test1_1
addi $s5,$s5,1
beq $v0,$s5,test2_1
addi $s5,$s5,1
beq $v0,$s5,test3_1
addi $s5,$s5,1
beq $v0,$s5,test4_1
addi $s5,$s5,1
beq $v0,$s5,test5_1
addi $s5,$s5,1
beq $v0,$s5,test6_1
addi $s5,$s5,1
beq $v0,$s5,test7_1
#############   test0  #######################

#�ȴ�������
test0_1:
lw $s7,0xC7C($28)
bne $s7,$zero,test0_1
test0_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test0_2
lw $s4,0xC70($28) 
sw $s4,0xC60($28)        
addi  $s0,$s4,0	#s0,s4��������С��$s0���ܸ���
addi $t0,$zero,0# $t0 ѭ������

loop_in:
beq $t0, $s0, loop_in_end  # $t0 == $s0 ��ʱ������ѭ��
sll $t1, $t0, 2            # $t1 = $t0 << 2���� $t1 = $t0 * 4

#�ȴ�������
inputdata_1:
lw $s7,0xC7C($28)
bne $s7,$zero,inputdata_1
inputdata_2:
lw $s7,0xC7C($28)
beq $s7,$zero,inputdata_2
lw $a3,0xC70($28) #a3Ϊ�������
sw $a3,0xC60($28)


lui $at,0
addu $t1,$at,$t1
sw $a3,0($t1)  	#�������ݼ�0

addiu $t1,$t1,40
sw $a3,0($t1)	#�������ݼ�1

addiu $t1,$t1,40
sw $a3,0($t1)	#�������ݼ�2

addi $t0, $t0, 1           # $t0 = $t0 + 1
j loop_in                  # ��ת�� loop_in

loop_in_end:
j begin_1
##############  test0  ######################



##############  test1  ######################
test1_1:
#����ѭ������t7��㣬t9�ڲ�
addi $t7,$zero,0	
addi $t9,$zero,0

loop1:
    addi $t9,$zero,0    # ÿ��ִ�����ѭ�������ڲ�ѭ����ѭ��������Ϊ0
loop2:
    # ��ȡa1[i] �����t2
    addi $t0,$t9,0      
    sll $t0, $t0, 2
    lui $at,0
    addu $t0,$at,$t0
    lw $t2,40($t0)
    
    # ��ȡa1[i+1] �����t3
    addi $t1,$t9,1    
    sll $t1, $t1, 2
    lui $at,0
    addu $t1,$at,$t1
    lw $t3,40($t1)
    
    #bge $t3,$t2,skip  # ���a[i+1] > a[i],��ת��skip�����,����slt��bne���
    slt $s6,$t2,$t3 #��t2С��t3����s6Ϊ1
    bne $s6,$zero,skip
    #sw $t3,0xC60($28)
    sw $t3,40($t0)   # �����ִ�����������䣬�������ߵ�ֵ
    sw $t2,40($t1)    

skip:
#for(i=0;i<n-1;i++)
#   for(j=0;j<n-i-1;j++)
   addi $t9,$t9,1   # �ڲ�ѭ����������
   addi $t0,$t9,1   #t0Ϊj+1
   sub $t1,$s0,$t7    	# t1Ϊn-i
   
   slt $s6,$t0,$t1	
   bne $s6,$zero,loop2
   # ��������㣬�����ѭ����ѭ���������������ж��Ƿ�����ѭ������
   addi $t7,$t7,1    
   addi $a2,$zero,1
   sub  $t2,$s0,$a2	
   #t2Ϊn-1��t7Ϊi
   slt $s6,$t7,$t2	
   bne $s6,$zero,loop1
   addi $t0,$zero,0

test1_end:
j begin_1
#############   test1  #######################


#############   test2  #######################
test2_1:
addi $t0,$zero,0
changeLoop:
beq $t0, $s0,test2_end  # $t0 == $s0 ��ʱ������ѭ��            
sll $t1, $t0, 2            # $t1 = $t0 << 2���� $t1 = $t0 * 4
lui $at,0
addu $t1,$at,$t1

#ȡ�����ݼ�2�����ݴ���s1
lw $s1, 80($t1)
#s2Ϊ����λ
srl $s2,$s1,7

addi $t5,$zero,0
beq $s2,$t5,unchange

addi $a2,$zero,128
sub $s1,$s1,$a2#s1Ϊ����ֵ�ľ���ֵ
#s1ȡ����1
lui $at,0xffff
ori $at,$at,0xffff
xor $s1,$s1,$at
lui $at,0
addi $s1,$s1,1
sw $s1,80($t1)

unchange:
addi $t0, $t0, 1           # $t0 = $t0 + 1
j changeLoop

test2_end:
j begin_1
#############   test2   #######################


#############   test3   #######################
test3_1:
#�����ݼ�2�е�����װ�����ݼ�3
addi $t0,$zero,0
loop_3:
beq $t0, $s0, loop3_in_end                
sll $t1, $t0, 2    
lui $at,0
addu $t1,$at,$t1        
lw $v0,80($t1)
sw $v0, 120($t1) 
addi $t0, $t0, 1           
j loop_3    
              
loop3_in_end:  
addi $t7,$zero,0
addi $t9,$zero,0
loop1_3:
    addi $t9,$zero,0    # ÿ��ִ�����ѭ�������ڲ�ѭ����ѭ��������Ϊ0
loop2_3:
    addi $t0,$t9,0      # ��ȡa[i]
    sll $t0,$t0,2
    lui $at,0
    addu $t0,$at,$t0
    lw $t2,120($t0)

    addi $t1,$t9,1    # ��ȡa[i+1]
    sll $t1,$t1,2
    lui $at,0
    addu $t1,$at,$t1
    lw $t3,120($t1)
    
    slt $s6,$t2,$t3
    bne $s6,$zero,skip_3
    sw $t3,120($t0)   # �����ִ�����������䣬�������ߵ�ֵ
    sw $t2,120($t1)   

skip_3:   
   addi $t9,$t9,1   
   addi $t0,$t9,1   
   sub $t1,$s0,$t7    	
   #blt $t0,$t1,loop2_3  	# ��������㣬�����ѭ����ѭ���������������ж��Ƿ�����ѭ������
   slt $s6,$t0,$t1	
   bne $s6,$zero,loop2_3
   addi $t7,$t7,1 
   addi $a2,$zero,1
   sub  $t2,$s0,$a2  
   #blt $t7,$t2,loop1	# ��������㣬����ת������ִ������Ĵ���
   slt $s6,$t7,$t2	
   bne $s6,$zero,loop1_3
   addi $t0,$zero,0

test3_end:
j begin_1
#############   test3   #######################


#############   test4   #######################
test4_1:
addi $t0,$zero,0      # ��ȡa[i]
lui $at,0
addu $t0,$at,$t0
lw $t2,40($t0)
sll $s5,$s4,2
add $t0,$t0,$s5 #s0,s4���������С
addi $t0,$t0,-4
lw $t3,40($t0)
sub $t2,$t3,$t2
sw $t2,0xC60($28)
j begin_1
#############   test4   #######################


#############   test5   #######################
test5_1:
addi $t0,$zero,0      # ��ȡa[i]
lui $at,0
addu $t0,$at,$t0
lw $t2,120($t0)
sll $s5,$s4,2
add $t0,$t0,$s5
addi $t0,$t0,-4
lw $t3,120($t0)
sub $t2,$t3,$t2
sw $t2,0xC60($28)
j begin_1

#############   test5   #######################


#############   test6   #######################

test6_1:
lw $s7,0xC7C($28)
bne $s7,$zero,test6_1
test6_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test6_2

lw $s3,0xC70($28)#s3��ʾ�ڼ������ݼ�
addi $t2,$zero,0#t2��ʾ���ݼ�ƫ����
searchCube:
beq $s3,$zero,searchM_1
addi $t2,$t2,40
addi $t5,$zero,1
sub $s3,$s3,$t5
j searchCube

searchM_1:
lw $s7,0xC7C($28)
bne $s7,$zero,searchM_1
searchM_2:
lw $s7,0xC7C($28)
beq $s7,$zero,searchM_2
lw $s3,0xC70($28)#s3��ʾ�ڼ�������
addi $t3,$zero,0#t3��ʾ����ƫ����

searchI:
beq $s3,$zero,Cal
addi $t3,$t3,4
addi $t5,$zero,1
sub $s3,$s3,$t5
j searchI

Cal:
lui $at,0
addu $t1,$at,$zero
add $t1,$t2,$t1
add $t1,$t3,$t1
lw $t2,0($t1)
sll $t2,$t2,24
srl $t2,$t2,24
sw $t2,0xC60($28)
j begin_1


#############   test6   #######################


#############   test7   #######################
test7_1:
lw $s7,0xC7C($28)
bne $s7,$zero,test7_1
test7_2:
lw $s7,0xC7C($28)
beq $s7,$zero,test7_2
lw $s3,0xC70($28)#s3��ʾ�ڼ�������
addi $t3,$zero,0#t3��ʾ����ƫ����

search:
beq $s3,$zero,Calcu
addi $t3,$t3,4
addi $t5,$zero,1
sub $s3,$s3,$t5
j search

Calcu:
lui $at,0
addu $t1,$at,$zero
add $t1,$t3,$t1

show:
lw $t2,0($t1)
sll $t2,$t2,24
srl $t2,$t2,24
sw $t2,0xC60($28)

addi $t7,$zero,1500
addi $t9,$zero,15000

loop71:
    addi $t9,$zero,15000    # ÿ��ִ�����ѭ�������ڲ�ѭ����ѭ��������Ϊ0
loop72:
   addi $t5,$zero,1
   sub $t9,$t9,$t5   # �ڲ�ѭ���������������ж��Ƿ�����ѭ������   
   bne $t9,$zero,loop72
   sub $t7,$t7,$t5    	
   bne $t7,$zero,loop71
   
lw $t2,80($t1)
sll $t2,$t2,24
srl $t2,$t2,24
sw $t2,0xC60($28)

addi $t7,$zero,1500
addi $t9,$zero,15000

loop73:
    addi $t9,$zero,15000    # ÿ��ִ�����ѭ�������ڲ�ѭ����ѭ��������Ϊ0
loop74:
   addi $t5,$zero,1
   sub $t9,$t9,$t5   # �ڲ�ѭ���������������ж��Ƿ�����ѭ������   
   bne $t9,$zero,loop74
   sub $t7,$t7,$t5    	
   bne $t7,$zero,loop73
   
test7_3:
lw $s7,0xC7C($28)
beq $s7,$zero,begin_1
j show
#############   test7   #######################
