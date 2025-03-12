#To be inserted at 0x8016e9b4
.include "./macros.asm"

b START

.macro loadTextAddr regOut, structOffset
offsetaddr REG_SCRATCH, \regOut, CONTROLLER_VISUAL_ADDR, CONTROLLER_VISUAL_OFFSET, REG_PLAYER_INDEX
load \regOut, \structOffset
add \regOut, \regOut, REG_SCRATCH
.endm

.macro loadTextStruct regSecondScratch, structOffset
loadTextAddr \regSecondScratch, \structOffset
lwz REG_TEXT_STRUCT, 0(\regSecondScratch)
.endm

# .set NAME_TAG_BASE_X, 0x80453080 + 0x10
# .set PLAYER_BLOCK_OFFSET, 0xe90
.macro getNameTagXfloat fregOut, regSecondaryScratch
mr r3, REG_PLAYER_INDEX
branchl REG_SCRATCH, 0x802f3424
# HUD X
lfs \fregOut, 0x0(r3)
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
