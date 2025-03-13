
SETUP:
mflr r30
# get data address
bl DATA_LOC
mflr REG_DATA_ADDR

# buil COBJ
load r3, 0x804d6d5c # idk what any of this does.
lwz r3, 0x0 (r3)
load r4, 0x803f94d0
branchl r12, HSD_ArchiveGetPublicAddress
lwz r3,0x4(r3)
lwz r3,0x0(r3)
branchl r12,0x8036a590 # assumedly creates the cobj
mr REG_COBJ,r3

# b GO_STRAIGHT_HERE

# build GOBJ
li r3, 19
li r4, 20
li r5, 0
branchl REG_SCRATCH, GObj_Create
mr REG_GOBJ, r3

# add object
mr r3, REG_GOBJ
lbz r4, -0x3E55(r13) # what is this offset?
mr r5, REG_COBJ
branchl REG_SCRATCH, GObj_AddToObj

# Init camera
mr r3, REG_GOBJ
bl COBJ_CB
mflr r4
li r5, COBJ_GXPRI
branchl r12, 0x8039075c
# Store COBJs GXLinks: idk what this does
load r3, 1 << TEXT_GXLINK
stw r3, 0x24 (REG_GOBJ)

#build canvas.
li r3, 2
mr r4,REG_GOBJ
li r5, 9
li r6, 13
li r7, 0
li r8, TEXT_GXLINK
li r9, TEXT_GXPRI
li r10, COBJ_GXPRI
branchl REG_SCRATCH, 0x803a611c
mr REG_CANVAS, r3

.macro setupPiece loc, strct
bl \loc
mflr r3
li r4, 0
loadTextAddr r5, \strct
bl SETUP_PIECE
.endm

li REG_PLAYER_INDEX, 0

SETUP_PLAYER:
# is player present?
offsetaddr r3, REG_SCRATCH, STATIC_BLOCK_ADDRESS, STATIC_BLOCK_OFFSET, REG_PLAYER_INDEX
lhz r3, STATIC_BLOCK_PLAYER_TYPE_OFFSET(r3)
cmpwi r3, PLAYER_TYPE_NONE
bne PLAYER_IS_PRESENT
# if player type is none set data to 0.
loadTextAddr r3, MAIN_STICK_STRUCT
li r4, 0
stw r4, 0(r3)
b SETUP_PLAYER_DONE

PLAYER_IS_PRESENT:
# build pieces
setupPiece MAIN_STICK_LOC, MAIN_STICK_STRUCT
setupPiece C_STICK_LOC, C_STICK_STRUCT
setupPiece A_BTN_LOC, A_BTN_STRUCT
setupPiece B_BTN_LOC, B_BTN_STRUCT
setupPiece X_BTN_LOC, X_BTN_STRUCT
setupPiece Y_BTN_LOC, Y_BTN_STRUCT
setupPiece L_BTN_LOC, L_BTN_STRUCT
setupPiece R_BTN_LOC, R_BTN_STRUCT
setupPiece Z_BTN_LOC, Z_BTN_STRUCT
# GO_STRAIGHT_HERE:
## background
# Create gobj
li  r3,14
li  r4,15
li  r5,0
branchl r12,0x803901f0
.set REG_BG_GOBJ, 23
mr  REG_BG_GOBJ,r3
#Create Background
load  r3,0x804a1ed0
lwz r3,0x0(r3)
branchl r12,0x80370e44
.set REG_BG_JOBJ, 22
mr  REG_BG_JOBJ,r3
# Add as object
mr  r3,REG_BG_GOBJ
lbz	r4, -0x3E57 (r13)
mr  r5,REG_BG_JOBJ
branchl r12,0x80390a70
# Add GX Link
mr  r3,REG_BG_GOBJ
load  r4,0x80391070
li  r5, TEXT_GXLINK
li  r6,0
branchl r12,0x8039069c

# Get HUD pos
getNameTagXfloat f1, r3
# Set bg position
lfs f1,0x0 (r3)
lfs f2, BG_X (REG_DATA_ADDR)
fadds f1,f1,f2
stfs  f1,0x38 (REG_BG_JOBJ)
lfs f1, BG_Y (REG_DATA_ADDR)
stfs  f1,0x3C (REG_BG_JOBJ)
# Adjust scale
lfs f1, BG_W (REG_DATA_ADDR)
stfs f1, 0x2c (REG_BG_JOBJ)
lfs f1, BG_H (REG_DATA_ADDR)
stfs f1, 0x30 (REG_BG_JOBJ)
# Get JOBJ 1
mr  r3,REG_BG_JOBJ
addi  r4,sp,0x80
li  r5,1
li  r6,-1
branchl r12,0x80011e24
# Z transform = 0
lwz r3,0x80(sp)
li  r4,0
stw r4,0x40(r3)
# Remove unneccessary dobjs
lwz r3,0x80(sp)
lwz r3,0x18(r3)  #first dobj
lwz r4,0x14(r3)
ori r4,r4,0x1
stw r4,0x14(r3)
lwz r3,0x4(r3)  #next dobj
lwz r4,0x14(r3)
ori r4,r4,0x1
stw r4,0x14(r3)
# Adjust opacity of BG
lwz r3,0x4(r3)  #next dobj
lwz r3,0x8(r3)  #mobj
lwz r3,0xC(r3)  #material
lfs f1, BG_OPACITY (REG_DATA_ADDR)
stfs f1, 0xC(r3)
# Adjust color of BG
lwz r4, BG_COLOR (REG_DATA_ADDR)
stw r4, 0x4(r3)

SETUP_PLAYER_DONE:
addi REG_PLAYER_INDEX, REG_PLAYER_INDEX, 1
cmpwi REG_PLAYER_INDEX, 4
blt+ SETUP_PLAYER

b SETUP_DONE

# r3 piece data loc
# r4 player
# r5 save location
SETUP_PIECE:
backup
mr r10, r3
mr r14, r5
# build text object
li r3, 2
mr r4, REG_CANVAS 
branchl REG_SCRATCH, Text_CreateStruct
mr REG_TEXT_STRUCT, r3
li r3, 0x1
stb r3, 0x48(REG_TEXT_STRUCT) # Fixed Width
stb r3, 0x4A(REG_TEXT_STRUCT) # Set text to align center
stb r3, 0x4C(REG_TEXT_STRUCT) # Unk?
stb r3, 0x49(REG_TEXT_STRUCT) # kerning?
#don't need to set position of the text because we update it every frame
# set text on the struct
crset 6
lfs f1, FLOAT_ZERO(REG_DATA_ADDR)
lfs f2, FLOAT_ZERO(REG_DATA_ADDR)
mr r3, REG_TEXT_STRUCT
addi r4, r10, TEXT
branchl REG_SCRATCH, Text_InitializeSubtext

# save the text struct
stw REG_TEXT_STRUCT, 0(r14)
restore
blr

PLACE_BACKDROP_STICK:
loadPieceData
li r3, PRESSED_OPACITY
stb r3, TEXT_STRUCT_OPACITY_BYTE_OFFSET(REG_TEXT_STRUCT)
b SET_TEXT_POS_SCALE_AND_BLR
