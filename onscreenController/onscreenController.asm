b START

.include "../macros.asm"
.include "../onscreenController/oscData.asm"

START:
backup

.set REG_DATA, 30
.set REG_A, 18
.set REG_B, 19
.set REG_C, 20
.set REG_SCRATCH, 29
load REG_A, 0x11112222
bl DATA_LOC
mflr REG_DATA
lfs REG_B, FLOAT_ONE_FIVE(REG_DATA)
lfs REG_C, FLOAT_URMUM(REG_DATA)

# how to draw text to the screen?

# how to update the text on the screen?
# draw an A, B, X, Y

# how to draw a box?
# draw a constant box 
# draw a smaller box inside representing the control stick

# do a second time for the c stick.


EXIT:
restore
