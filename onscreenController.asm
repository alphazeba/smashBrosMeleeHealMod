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
