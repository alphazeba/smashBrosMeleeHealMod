####### internal functions 
GET_CONTROLLER_DATA_STICK:
loadplayerdatapointer r10, REG_SCRATCH, REG_PLAYER_INDEX
# main stick
lfs f11, 0x620(r10)
lfs f12, 0x624(r10)
# c stick
lfs f13, 0x638(r10)
lfs f14, 0x63C(r10)
blr

GET_CONTROLLER_DATA_BTN:
loadplayerdatapointer r10, REG_SCRATCH, REG_PLAYER_INDEX
lwz r14, 0x65c(r10)
andi r3, r14, 0x100, REG_SCRATCH # a
andi r4, r14, 0x200, REG_SCRATCH # b
andi r5, r14, 0x400, REG_SCRATCH # x
andi r6, r14, 0x800, REG_SCRATCH # y
andi r7, r14, 0x10, REG_SCRATCH # Z
andi r8, r14, 0x20, REG_SCRATCH # R
andi r9, r14, 0x40, REG_SCRATCH # L
blr

.macro handleStick regx, regy, loc, strct
loadTextStruct r3, \strct
bl \loc
mflr r10
fmr f1, \regx
fmr f2, \regy
bl HANDLE_PIECE_STICK
.endm
# f1,f2 is input stick x,y
# r10 is loc address
HANDLE_PIECE_STICK:
lfs f5, TEXT_X(r10)
lfs f6, TEXT_Y(r10)
lfs f7, TEXT_Z(r10)
lfs f8, TEXT_CANVAS_SCALE(r10)
lfs f9, MOVE_SCALE(r10)
# scale the stick movement
fmuls f1, f1, f9
fmuls f2, f2, f9
# scooch by hud nametag offset
fadds f5, f5, f10
fadds f5, f5, f1
fsubs f6, f6, f2
setTextPosScale REG_TEXT_STRUCT, f5, f6, f7, f8
blr

.macro handleBtn reg_btnPressed, loc, strct
loadTextStruct r10, \strct
bl \loc
mflr r10
mr r11, \reg_btnPressed
bl HANDLE_PIECE_BTN
.endm
# r11 is btn data
# r10 is loc address
HANDLE_PIECE_BTN:
lfs f5, TEXT_X(r10)
lfs f6, TEXT_Y(r10)
lfs f7, TEXT_Z(r10)
lfs f8, TEXT_CANVAS_SCALE(r10)
lfs f9, MOVE_SCALE(r10)
# scooch by hud nametag offset
fadds f5, f5, f10
# branch on whether button is pressed
cmpwi r11, 0
bne- BTN_IS_PRESSED
# button not pressed
fsubs f6, f6, f9
li r3, UNPRESSED_OPACITY
b BTN_SET_VALUES
BTN_IS_PRESSED:
li r3, PRESSED_OPACITY
BTN_SET_VALUES:
setTextPosScale REG_TEXT_STRUCT, f5, f6, f7, f8
stb r3, TEXT_STRUCT_OPACITY_BYTE_OFFSET(REG_TEXT_STRUCT)
blr


#### begin callback
COBJ_CB:
blrl

backup

mr REG_GOBJ, r3

# Check if paused
lbz	r0, -0x4934 (r13)
cmpwi r0, 1
beq COBJ_CB_Exit

# start per player loop
li REG_PLAYER_INDEX, 0

UPDATE_PLAYER_CONTROLLER:
getNameTagXfloat f10, r3
bl GET_CONTROLLER_DATA_STICK
handleStick f11, f12, MAIN_STICK_LOC, MAIN_STICK_STRUCT
handleStick f13, f14, C_STICK_LOC, C_STICK_STRUCT
bl GET_CONTROLLER_DATA_BTN
handleBtn r3, A_BTN_LOC, A_BTN_STRUCT
handleBtn r4, B_BTN_LOC, B_BTN_STRUCT
handleBtn r5, X_BTN_LOC, X_BTN_STRUCT
handleBtn r6, Y_BTN_LOC, Y_BTN_STRUCT
handleBtn r9, L_BTN_LOC, L_BTN_STRUCT
handleBtn r8, R_BTN_LOC, R_BTN_STRUCT
handleBtn r7, Z_BTN_LOC, Z_BTN_STRUCT

DONE_HANDLING_PLAYER:
addi REG_PLAYER_INDEX, REG_PLAYER_INDEX, 1
cmpwi REG_PLAYER_INDEX, 4
blt+ UPDATE_PLAYER_CONTROLLER

# Draw camera
mr r3, REG_GOBJ
branchl r12, 0x803910d8

COBJ_CB_Exit:
restore
blr
#### end callback
