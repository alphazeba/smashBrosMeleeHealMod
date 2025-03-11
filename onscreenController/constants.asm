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

.set FRAME_COUNTER_ADDRESS, 0x80479d60

.set MAIN_STICK_STRUCT, 0x8046b8d0
.set C_STICK_STRUCT, 0x8046b8d4
.set A_BTN_STRUCT, 0x8046b8d8
.set B_BTN_STRUCT, 0x8046b8dc
.set X_BTN_STRUCT, 0x8046b8c0
.set Y_BTN_STRUCT, 0x8046b8c4

.set L_BTN_STRUCT, 0x8046b8c8
.set R_BTN_STRUCT, 0x8046b8cc
.set Z_BTN_STRUCT, 0x8046b8e0



