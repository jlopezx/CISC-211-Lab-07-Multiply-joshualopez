/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Joshua Lopez"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    
/*-------Start off code by assigning labels and initializing them with required values-------*/
mov r8, 0		/*Set up r8 with 0 to use for label initialization in loop_assignment*/
ldr r3, =a_Multiplicand /*Start memory address. In this case a_Multiplicand memory address*/
ldr r4, =final_Product	/*End memory address. Use final_Product mem address to end loop later*/
str r0, [r3]		/*Initialize a_Multiplicand label with the multiplicand in r0 */
add r3, r3, 4		/*Moves to the next mem address which is the b_Multiplier*/
str r1, [r3]		/*Stores multiplier value in r1 to b_Multiplier*/
    
/*Initializes the rest of the variables to 0*/    
loop_assignment:
    add r3, r3, 4	/*Increments to the next address by adding 4 to the current mem address (bytes)*/
    str r8, [r3]	/*Sets the current label's value to 0*/
    cmp r3, r4		/*Checks to see if we reached the end. In this case it would be final_Product mem address*/
    bne loop_assignment /*Loops if we haven't reached final_Product mem address*/
    
/*-------This code checks if the values are valid 16 bits and handles sign assignment and error assignment-------*/
ldr r3, =a_Multiplicand /*Start memory address. In this case a_Multiplicand memory address*/
ldr r4, =b_Multiplier   /*End memory address. Uses b_Multiplier mem address to end loop later*/
ldr r5, =a_Sign		/*r5 will be used to move from a_Sign to b_Sign*/
ldr r6, =a_Abs		/*r6 will be used to move from a_Abs to b_Abs*/

/*Loop is used to check if our cand and plier are valid 16 bit values*/
loop_validity:
    
    ldr r7, =0xFFFF8000 /*Super moves the 32 bit value into r7. Used later to mask the upper 17 bits*/
    ldr r8, [r3]	/*Setting r8 to temporarily hold the value of the current mem location*/
    and r8, r8, r7	/*Masks the upper 17 bits since these are the sign bits. If they're 0 then it's positive*/
    cmp r8, 0		/*the AND bitwise will store 0 in r8 if the 17 bits are 0*/
    beq is_positive	/*Branches for positive value handling*/
    
    /*If stepped here, then the AND bitwise was not 0 & need to check if upper 17 bits are all 1s*/
    asr r8, 15		/*Shifts right 15 bits arithmetically. If all Fs, then it's a valid 16 bit value, else it's greater*/
    ldr r7, =-1		/*Using 0xFFFFFFFF (-1) to check if the current value is a valid 16 bit, negative value*/
    cmp r8, r7		/*Compares if it's the sign bits are all F, if they are, then it branches to negatiive*/
    beq is_negative	/*Branches to negative handling if all Fs*/
    bne is_error	/*If not all Fs, then the value exceeds 16 bit signed value and is and error & will branch for error handling*/
    
    /*Positive number handling. Sign bit is 0 and is a valid 16 bit value*/
    is_positive:
	mov r7, 0	/*Set up r7 with 0 to use for the next instruction*/
	b store_n_loop/*Branches to store_n_loop to continue the rest of the loop*/

    /*Negative number handling. Sign bit is 1 and is a valid 16 bit value*/
    is_negative:
	mov r7, 1	/*Set up r7 with 1 to use for the next instruction*/
	b store_n_loop/*Branches to store_n_loop to continue the rest of the loop*/
	
    /*store_n_loop handles moving the mem location labels to the next locations labels, 
     *looping back or continuation, and sign and absolute value initialization*/
    store_n_loop:
	str r7, [r5]	/*Sets the current sign mem label with either 0 (positive) or 1(negative)*/
	ldr r8, [r3]	/*Sets either the cand or plier value to r8*/
	cmp r7, 1	/*Need to set flags to check if the current value is negative (1) or not*/
	negeq r8, r8	/*If r7 is 1, then reverse the 2s complement of the negative value in either the cand or plier*/
	str r8, [r6]	/*Stores the positive value into the corresponding absolute value mem label*/
	
	cmp r3, r4	/*Does a compare to see if we reached b_Multiplier mem location.*/
	add r3, r3, 4	 /*Moves from a_Multiplicand to b_Multiplier on the next loop*/
	add r5, r5, 4	 /*Moves from a_Sign to b_Sign on the next loop*/
	add r6, r6, 4	 /*Moves from a_Abs to b_Abs on the next loop*/
	
	bne loop_validity/*If we haven't reached b_Multiplier mem address, we continue the loop*/
	b multiply	 /*If code steps here, we've looped through all the above variables and are ready 
			  *to move on to multiplication handling*/
	
    /*If code branches here, then that means one of our values has exceeded the signed 16 bits requirement*/
    is_error:
	ldr r8, =rng_Error/*Preps r8 with rng_error label mem address*/
	mov r7, 1	  /*Sets up r7 with 1 for next instruction*/
	str r7, [r8]	  /*Stores 1 to rng_error meaning there is an error*/
	mov r0, 0	  /*Moves the final product to r0 as requested*/
	b done		  /*Branches to done. Nothing more to do*/
    
/*------If both the cand & plier are valid 16 bit values, execution will branch here for multiplication handling------*/
multiply:
    /*Loads labels and initializes registers to begin the multiplication process*/
    ldr r2, =a_Abs	    /*Loads the address of the absolute value of the cand*/
    ldr r3, =b_Abs	    /*Loads the address of the absolute value of the plier*/
    ldr r4, =init_Product   /*Sets r4 to hold the mem address of the init_Product*/
    
    ldr r5, [r2]	    /*Sets r5 as the absolute value of the cand*/
    ldr r6, [r3]	    /*Sets r6 as the absolute value of the plier*/
    mov r7, 0		    /*Initializes r7 to 0. Will be used to hold the initial product value.*/
    
    /*Loop handles the multiplication by shifting*/
    multiply_loop:   
	
	cmp r6, 0	    /*Checks if the plier is 0. If 0, we're done with multiplying*/
	beq product	    /*If the multiplier is 0, it will branch to product*/
	tst r6, 1	    /*If the LSB is set (1), then Z==0 and it will NOT branch to shift*/
	beq shift	    /*If the LSB is not set (0), then Z==1 and it will branch to shift*/
	add r7, r7, r5	    /*If LSB is 1, then the product and cand are added and stored back to the product*/
	/*Inner Shift Loop*/
	shift:
	    lsl r5, r5, 1   /*shifting the cand left to multiply it by 2*/
	    lsr r6, r6, 1   /*shifting the plier right to divide it by 2. Will eventually reach 0*/
	    b multiply_loop /*branches back to continue multiplication loop*/
	    
/*----------Handles the final product to see if it's either negative or positive----------*/
product:
    /*Store the product from multiply_loop to the initial_Product mem address location*/
    str r7, [r4]	    
    
    /*Load all the labels needed for handling the product*/
    ldr r1, =a_Sign
    ldr r2, =b_Sign
    ldr r3, =init_Product
    ldr r4, =final_Product
    ldr r5, =prod_Is_Neg
    
    ldr r6, [r1]    /*Puts the sign of the cand here, either 0 or 1*/
    ldr r7, [r2]    /*Puts the sign of the plier here, either 0 or 1*/
    ldr r9, [r3]    /*Loads the initial product to negate later if needed*/
    
    cmp r9, 0	    /*Comparing 0 with the initial_Product value. If matched, then we multiplied by 0*/
    beq final	    /*This will branch to final and skip over checking the final sign value since the product is 0*/
    
    eor r8, r6, r7  /*Checks the signs in a_Sign & b_Sign. Applies a XOR bitwise. If 0 xor 1 then it will be negative*/
    cmp r8, 1	    /*If we get a 1 from eor then it's negative*/
    beq product_neg /*Branches if equal meaning the signs are negative*/
    
    b final	    /*If it didn't branch to product_neg, then it's positive and will branch to final*/
    /*Handles if product is negative*/
    product_neg:

	mov r8, 1   /*Sets up r8 with 1 to use for the next instruction*/
	str r8, [r5]/*This updates the prod_Is_Neg label to 1 meaning it's true*/
	neg r9, r9  /*Takes the 2's complement of the value because its signs were either -,+ or +,- */
    
    /*Handles the final value assignments*/
    final:
	str r9, [r4] /*Stores the final value into its appropriate label*/
	mov r0, r9   /*Moves the final product to r0 as requested*/
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




