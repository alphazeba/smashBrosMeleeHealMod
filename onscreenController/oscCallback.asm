COBJ_CB:
blrl

backup

mr REG_GOBJ, r3

# Check if paused
lbz	r0, -0x4934 (r13)
cmpwi r0, 1
beq COBJ_CB_Exit

# handle player 0
li r3, 0
bl GET_CONTROLLER_DATA_STICK
fmr f14, f3
fmr f15, f4

loadwz REG_TEXT_STRUCT, MAIN_STICK_STRUCT
bl MAIN_STICK_LOC
mflr r10
bl HANDLE_PIECE_STICK

fmr f1, f14
fmr f2, f15
loadwz REG_TEXT_STRUCT, C_STICK_STRUCT
bl C_STICK_LOC
mflr r10
bl HANDLE_PIECE_STICK

.macro handleBtn loc, reg_btnPressed
bl \loc
mflr r10
mr r11, \reg_btnPressed
bl HANDLE_PIECE_BTN
.endm

bl GET_CONTROLLER_DATA_BTN
handleBtn A_BTN_LOC, r3

# Draw camera
mr r3, REG_GOBJ
branchl r12, 0x803910d8

COBJ_CB_Exit:
restore
blr

GET_CONTROLLER_DATA_STICK: # r3 is player slot
load r10, 0x804c1fac # p1 controller location
# main stick
lfs f1, 0x20(r10)
lfs f2, 0x24(r10)
# c stick
lfs f3, 0x28(r10)
lfs f4, 0x2c(r10)
blr

.macro andi reg_out, reg_num, value
load REG_SCRATCH, \value
and \reg_out, \reg_num, REG_SCRATCH
.endm

GET_CONTROLLER_DATA_BTN:
load r10, 0x804c1fac
lwz r14, 0x4(r10)
andi r3, r14, 0x100 # a
andi r4, r14, 0x200 # b
andi r5, r14, 0x400 # x
andi r6, r14, 0x800 # y

andi r7, r14, 0x10 # Z
andi r8, r14, 0x20 # R
andi r9, r14, 0x40 # L
blr

HANDLE_PIECE_STICK:
lfs f5, TEXT_X(r10)
lfs f6, TEXT_Y(r10)
lfs f7, TEXT_Z(r10)
lfs f8, TEXT_CANVAS_SCALE(r10)
lfs f9, MOVE_SCALE(r10)

fmuls f1, f1, f9
fmuls f2, f2, f9

fadds f5, f5, f1
fsubs f6, f6, f2
setTextPosScale REG_TEXT_STRUCT, f5, f6, f7, f8
blr

# r11 is btn data
# r10 is loc address
HANDLE_PIECE_BTN:
lfs f5, TEXT_X(r10)
lfs f6, TEXT_Y(r10)
lfs f7, TEXT_Z(r10)
lfs f8, TEXT_CANVAS_SCALE(r10)
lfs f9, MOVE_SCALE(r10)

cmpwi r10, 0
beq BTN_NOT_PRESSED

fadds f6, f6, f9

BTN_NOT_PRESSED:
setTextPosScale REG_TEXT_STRUCT, f5, f6, f7, f8
blr
