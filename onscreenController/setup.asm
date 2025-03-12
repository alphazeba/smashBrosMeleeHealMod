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
branchl r12,0x8039075c
# Store COBJs GXLinks
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

b SETUP_DONE

.macro buildText
mr r10, r15
li r3, 2
mr r4, REG_CANVAS 
branchl REG_SCRATCH, Text_CreateStruct
mr REG_TEXT_STRUCT, r3

li r3, 0x1
stb r3, 0x48(REG_TEXT_STRUCT) # Fixed Width
stb r3, 0x4A(REG_TEXT_STRUCT) # Set text to align center
stb r3, 0x4C(REG_TEXT_STRUCT) # Unk?
stb r3, 0x49(REG_TEXT_STRUCT) # kerning?

# set position
lfs f1, TEXT_X(r10)
lfs f2, TEXT_Y(r10)
lfs f3, TEXT_Z(r10)
lfs f4, TEXT_CANVAS_SCALE(r10)
setTextPosScale REG_TEXT_STRUCT, f1, f2, f3, f4
# set text on the struct
crset 6
lfs f1, FLOAT_ZERO(REG_DATA_ADDR)
lfs f1, FLOAT_ZERO(REG_DATA_ADDR)
mr r3, REG_TEXT_STRUCT
addi r4, r10, TEXT
branchl REG_SCRATCH, Text_InitializeSubtext
.endm

# r3 piece data loc
# r4 player
# r5 save location
SETUP_PIECE:
backup
mr r15, r3
mr r14, r5
# build text object
# do it twice so there is a shadow showing the unmoved location
buildText
buildText

# save the text struct
stw REG_TEXT_STRUCT, 0(r14)
restore
blr

