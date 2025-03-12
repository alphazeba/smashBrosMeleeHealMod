#To be inserted at 0x8016e9b4
.include "./macros.asm"

b START

.macro setTextPosScale textStruct, x, y, z, s
stfs \x, 0x0(\textStruct)
stfs \y, 0x4(\textStruct)
stfs \z, 0x8(\textStruct)
stfs \s, 0x24(\textStruct)
stfs \s, 0x28(\textStruct)
.endm

.macro loadTextAddr regOut, structOffset
load \regOut, \structOffset
.endm

.macro loadTextStruct regSecondScratch, structOffset
# load \regSecondScratch, \structOffset
# getControllerPieceAddr REG_TEXT_STRUCT, REG_SCRATCH, REG_PLAYER_INDEX, \regSecondScratch
# lwz REG_TEXT_STRUCT, 0(REG_TEXT_STRUCT)
.endm


.include "./onscreenController/oscData.asm"
.include "./onscreenController/constants.asm"
.include "./onscreenController/oscCallback.asm"
.include "./onscreenController/setup.asm"

START:
backup

b SETUP

SETUP_DONE:
b EXIT

EXIT:
restore
# replaced instruction
lwz	r0, 0x001C (sp)
