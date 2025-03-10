#To be inserted at 0x8016e9b4

.include "./macros.asm"

b START

.include "./onscreenController/oscData.asm"

#########################################
COBJ_CB:
blrl
.set REG_GOBJ,31

backup

mr REG_GOBJ, r3

/*
# Check if paused
li r3,1
branchl r12,0x801a45e8
cmpwi r3,2
beq COBJ_CB_Exit
*/
# Check if paused
lbz	r0, -0x4934 (r13)
cmpwi r0, 1
beq COBJ_CB_Exit

# Draw camera
mr r3, REG_GOBJ
branchl r12,0x803910d8

COBJ_CB_Exit:
restore
blr
#########################################

START:
backup

.set GObj_Create,0x803901f0 #(obj_type,subclass,priority)
.set GObj_AddUserData,0x80390b68 #void (*GObj_AddUserData)(GOBJ *gobj, int userDataKind, void *destructor, void *userData) = (void *)0x80390b68;
.set GObj_Destroy,0x80390228
.set GObj_AddProc,0x8038fd54 # (obj,func,priority)
.set GObj_RemoveProc,0x8038fed4
.set GObj_AddToObj,0x80390A70 #(gboj,obj_kind,obj_ptr)
.set GObj_SetupGXLink, 0x8039069c #(gobj,function,gx_link,priority)

.set HSD_ArchiveGetPublicAddress, 0x80380358 # what is hsd
.set Text_InitializeSubtext, 0x803a6b98
.set Text_CreateStruct,0x803a6754

# CObj stuff
.set COBJ_GXPRI, 8
.set TEXT_GXPRI, 80
.set TEXT_GXLINK, 12

.set REG_DATA_ADDR, 29
.set REG_TEXT_STRUCT, 28
.set REG_CANVAS, 27
.set REG_COBJ, 26 # camero obj?
.set REG_GOBJ, 25 # game obj?

.set REG_SCRATCH, 12

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

# build text object
li r3, 2
mr r4, REG_CANVAS # todo need to create the canvas.
branchl REG_SCRATCH, Text_CreateStruct
mr REG_TEXT_STRUCT, r3

li r3, 0x1
stb r3, 0x48(REG_TEXT_STRUCT) # Fixed Width
stb r3, 0x4A(REG_TEXT_STRUCT) # Set text to align center
stb r3, 0x4C(REG_TEXT_STRUCT) # Unk?
stb r3, 0x49(REG_TEXT_STRUCT) # kerning?

# set position and scale
lfs f1, TEXT_X(REG_DATA_ADDR)
stfs f1, 0x0(REG_TEXT_STRUCT) # or maybe it is shifting for which player we currently looking at.

lfs f1, TEXT_Y(REG_DATA_ADDR)
stfs f1, 0x4(REG_TEXT_STRUCT)

lfs f1, TEXT_Z(REG_DATA_ADDR)
stfs f1, 0x8(REG_TEXT_STRUCT)

# create the player name text
crset 6 # even code i'm looking at doesn't know what this is.
lfs f1, FLOAT_ZERO(REG_DATA_ADDR)
fmr f2, f2
mr r3, REG_TEXT_STRUCT
# previously i was literally putting the text in the register. Now im building the pointer to the text
bl TEXT_LOC
mflr r4
branchl REG_SCRATCH, Text_InitializeSubtext
b EXIT

# how to update the text on the screen?
# draw an A, B, X, Y

# how to draw a box?
# draw a constant box 
# draw a smaller box inside representing the control stick

# do a second time for the c stick.

EXIT:
restore
# replaced instruction
lwz	r0, 0x001C (sp)