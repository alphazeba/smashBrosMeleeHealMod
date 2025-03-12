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
load REG_SCRATCH, CONTROLLER_VISUAL_ADDR
# TODO offset by player index.
load \regOut, \structOffset
add \regOut, \regOut, REG_SCRATCH
.endm

.macro loadTextStruct regSecondScratch, structOffset
loadTextAddr \regSecondScratch, \structOffset
lwz REG_TEXT_STRUCT, 0(\regSecondScratch)
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
