COBJ_CB:
blrl

backup

mr REG_GOBJ, r3

# Check if paused
lbz	r0, -0x4934 (r13)
cmpwi r0, 1
beq COBJ_CB_Exit

# handle player 0
li REG_PLAYER_INDEX, 0

UPDATE_PLAYER_CONTROLLER:
bl GET_CONTROLLER_DATA_STICK
fmr f14, f3
fmr f15, f4

loadTextStruct r3, MAIN_STICK_STRUCT
bl MAIN_STICK_LOC
mflr r10
bl HANDLE_PIECE_STICK

fmr f1, f14
fmr f2, f15
loadTextStruct r3, C_STICK_STRUCT
bl C_STICK_LOC
mflr r10
bl HANDLE_PIECE_STICK

.macro handleBtn loc, reg_btnPressed, strct
loadTextStruct r10, \strct
bl \loc
mflr r10
mr r11, \reg_btnPressed
bl HANDLE_PIECE_BTN
.endm

bl GET_CONTROLLER_DATA_BTN
handleBtn A_BTN_LOC, r3, A_BTN_STRUCT
handleBtn B_BTN_LOC, r4, B_BTN_STRUCT
handleBtn X_BTN_LOC, r5, X_BTN_STRUCT
handleBtn Y_BTN_LOC, r6, Y_BTN_STRUCT

handleBtn L_BTN_LOC, r9, L_BTN_STRUCT
handleBtn R_BTN_LOC, r8, R_BTN_STRUCT
handleBtn Z_BTN_LOC, r7, Z_BTN_STRUCT

UPDATE_PLAYER_CONTROLLER_DONE:
addi REG_PLAYER_INDEX, REG_PLAYER_INDEX, 1
cmpwi REG_PLAYER_INDEX, 4
blt+ UPDATE_PLAYER_CONTROLLER

# Draw camera
mr r3, REG_GOBJ
branchl r12, 0x803910d8

COBJ_CB_Exit:
restore
blr

GET_CONTROLLER_DATA_STICK: # r3 is player slot
load r10, CONTROLLER_DATA_ADDRESS
# main stick
lfs f1, 0x20(r10)
lfs f2, 0x24(r10)
# c stick
lfs f3, 0x28(r10)
lfs f4, 0x2c(r10)
blr

GET_CONTROLLER_DATA_BTN:
load r10, CONTROLLER_DATA_ADDRESS
lwz r14, 0x4(r10)
andi r3, r14, 0x100, REG_SCRATCH # a
andi r4, r14, 0x200, REG_SCRATCH # b
andi r5, r14, 0x400, REG_SCRATCH # x
andi r6, r14, 0x800, REG_SCRATCH # y
andi r7, r14, 0x10, REG_SCRATCH # Z
andi r8, r14, 0x20, REG_SCRATCH # R
andi r9, r14, 0x40, REG_SCRATCH # L
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

cmpwi r11, 0
bne BTN_IS_PRESSED

fsubs f6, f6, f9

BTN_IS_PRESSED:
setTextPosScale REG_TEXT_STRUCT, f5, f6, f7, f8
blr
