                .data

    head1: .asciiz "FIND & REPLACE"
    head2: .asciiz "\n This program helps the user to \n--->  Find a word in the paragrah entered by the user and \n--->  Replace it with another word of user's choice"

    input_paragraph: .asciiz "Enter a paragraph: "
    input_target: .asciiz "Enter target word: "
    input_replacement: .asciiz "Enter the replacement word: "
    output_times: .asciiz "The target was found: "
    output_paragraph: .asciiz " times\nThe final paragraph is:\n"

    error_length: .asciiz "Error: Replacement word should be same size as target!\n"
    error_not_found: .asciiz "Could not find target word in given paragraph.\n"

    horizon: .asciiz "\n----------------------------------------------------------------------------------------------------------------\n"

    paragraph: .space 1501
    target: .space 51
    replacement: .space 51
    paragraph_limit: .word 1501
    target_limit: .word 51
    replacement_limit: .word 51

                .text

                ######################################
                # Sets $t6 = 1 if $t1 and $t3        #
                # contain the same character.        #
                # Is case insensitive in checking    #
                ######################################

    .globl checkCharsEqual
    .ent checkCharsEqual
    
    checkCharsEqual:
        
        sub $t1, $t1, 64
        sub $t3, $t3, 64
        ble $t1, 26, CHECK_T3
        sub $t1, $t1, 32  # 96 ('a' - 1) - 64 ('A' - 1)

        CHECK_T3 : ble $t3, 26, CHECK_FIN
                   sub $t3, $t3, 32
        CHECK_FIN: seq $t6, $t1, $t3
        jr $ra

    .end checkCharsEqual

                #######################################
                # Finds number of times the target    #
                # appears in given paragraph and      #
                # replace it each time                #
                # $a0 is address of last character    #
                #        of paragraph                 #
                # $a1 is address of last character    #
                #        of target                    #
                # $a2 is address of last character    #
                #        of replacement               #
                # $v0 will be number of times the     #
                #        target is found              #
                #######################################

    .globl findTarget
    .ent findTarget

    findTarget:

        addi $sp, $sp, -4
        sw $ra, ($sp)

        add $v0, $0, $0              # Set $v0 to 0
        la $t0, paragraph            # Start reading from the beginning

        NEXT_WORD: la $t2, target    
                    add $t9, $t0, $0  # Copy pointer to first character of word to $t9
                    lb $t1, ($t0)     # Load first character of word
                    lb $t3, ($t2)     # Load first character of target

            jal checkCharsEqual  # Sets $t6 to 1 if characters are same

           # If equal, check rest of the word
           beq $t6, 1, CHECK_WORDEQ
           # Else move pointer to beginning of next word
           FIND_NEXTWORD: lb $t1, ($t0)
                          addi $t0, $t0, 1
                          bge $t1, 65, FIND_NEXTWORD  # If letter, repeat
                          j END_REACHED               # Start loop again

           CHECK_WORDEQ: jal checkCharsEqual
                         beq $t6, $0, FIND_NEXTWORD   # If not equal, repeat loop
                         lb $t1, 1($t0)
                         lb $t3, 1($t2)
                         addi $t0, $t0, 1
                         addi $t2, $t2, 1
                         ble $t2, $a1, CHECK_WORDEQ   # If last address isn't reached, goto next character

                         # If the last + 1 character is not a letter, target is found
                         bge $t1, 65, FIND_NEXTWORD
                         add $v0, $v0, 1              # Target found once

                         # Replace string
                         la $t8, replacement
                         REPLACE_TARGET: lb $t7, ($t8)       # Load character from replacement word
                                         sb $t7, ($t9)       # Replace character in target word
                                         addi $t8, $t8, 1
                                         addi $t9, $t9, 1
                                         ble $t8, $a2, REPLACE_TARGET

        END_REACHED: blt $t0, $a0, NEXT_WORD                         # Repeat process until end of paragraph
                    lw $ra, ($sp)
                    addi $sp, $sp, 4
                    jr $ra
    .end findTarget
                
                #######################################
                # Find last character of given string #
                # $a0 is address of the string        #
                # $v0 will hold address of last       #
                #       character                     #
                #######################################
        
    .globl findLast
    .ent findLast
    findLast:

        add $v0, $a0, $0     # Set pointer to starting address
        
        MOVE_TO_NULL: lb $t0, ($v0)              # Load the character
                    addi $v0, $v0, 1             # Move pointer to next character
                    bne $t0, 0, MOVE_TO_NULL     # Continue until null character is found

        # Move pointer to last character
        MOVE_TO_LAST: lb $t0, ($v0)
                    addi $v0, $v0, -1
                    blt $t0, 65, MOVE_TO_LAST    # Continue until a letter is found
        addi $v0, $v0, 1
        jr $ra

        .end findLast

                #######################################
                # Main function of the program        #
                #######################################

    main:

        # Headers
        la $a0, head1
        li $v0, 4
        syscall
        la $a0, head2
        li $v0, 4
        syscall
        la $a0, horizon # Horizontal Line
        li $v0, 4
        syscall

        # Prompt user for paragraph
        la $a0, input_paragraph
        li $v0, 4
        syscall
        la $a0, paragraph           # Base address of papragraph in $a0
        lw $a1, paragraph_limit     # Size of paragraph
        li $v0, 8
        syscall

        # Prompt user for target word
        la $a0, input_target
        li $v0, 4
        syscall
        la $a0, target              # Base address of target in $a0
        lw $a1, target_limit        # Size of target
        li $v0, 8
        syscall

        # Prompt user for replacement word
        la $a0, input_replacement
        li $v0, 4
        syscall
        la $a0, replacement         # Base address of replacement in $a0
        lw $a1, replacement_limit   # Size of replacement
        li $v0, 8
        syscall

        # Find last address of paragraph
        # $a0 should be address of paragraph
        la $a0, paragraph
        jal findLast
        add $s0, $v0, $0  # Keep address of last character of paragraph in $s0

        # Find last address of target
        # $a0 should be address of target
        la $a0, target
        jal findLast
        add $s1, $v0, $0  # Keep address of last character of target in $s1

        # Find last address of replacement
        # $a0 should be address of replacement
        la $a0, replacement
        jal findLast
        add $s2, $v0, $0  # Keep address of last character of replacement in $s2

        # Proceed only if replacement length = target length
        la $t0, target
        sub $t0, $s1, $t0
        la $t1, replacement
        sub $t1, $s2, $t1
        bne $t0, $t1, ERROR

        add $a0, $s0, $0    # Paragraph's Last Character
        add $a1, $s1, $0    # Target's Last Character
        add $a2, $s2, $0    # Replacement's Last Character
        jal findTarget
        add $s4, $v0, $0

        # If target wasn't found even once, show appropriate error message
        beq $s4, $0, ERROR_NOT_FOUND

        # Print number of times the target was found
        la $a0, output_times
        li $v0, 4
        syscall
        add $a0, $s4, $0
        li $v0, 1
        syscall

        # Print the final string
        la $a0, output_paragraph
        li $v0, 4
        syscall
        la $a0, paragraph
li $v0, 4
syscall

j EXIT

ERROR_NOT_FOUND: la $a0, error_not_found        # Target not found
                 li $v0, 4
                 syscall
                 j EXIT

ERROR: la $a0, error_length                     # Lengths of target and replacement are not equal
       li $v0, 4
       syscall

# Exit
EXIT: li $v0, 10
      syscall

