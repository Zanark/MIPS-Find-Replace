.data
inputstring: .asciiz "Deba Deba DEba DEba DEba DEba DEba DEba Zana Zama Zana Zana"

.text
main:
la $s0, inputstring

add $t0, $s0, $0
add $t1, $s0, 60

FORI: li $s1, 0
      FORJ: lb $t2, ($t0)
            addi $t0, $t0, 1
            addi $s1, $s1, 1

            add $a0, $t2, 0 #print the character
            li $v0, 11
            syscall

            bge $t2, 59, FORJ
      addi $a0, $s1, -1 # $s1 is 1 + length
      li $v0, 1
      syscall

      addi $a0, $0, 10
      li $v0, 11
      syscall

      blt $t0, $t1, FORI
      

li $v0, 10
syscall