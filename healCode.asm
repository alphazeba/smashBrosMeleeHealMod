#To be inserted at 80376a24
# TODO we should choose a different injection address.
# something that runs once per frame in the game.

.include "../macros.asm"

# call the replaced instruction
branchl r12, 0x8034da00


# start real code
backup

# consts
.set GAME_PAUSED_ADDRESS, 0x80479D68
.set SCENE_MINOR_ADDRESS, 0x80479d33
.set FRAME_COUNTER_ADDRESS, 0x80479d60

.set STATIC_ENTITY_POINTER, 0x80453130
.set STATIC_ENTITY_POINTER_OFFSET, 0xe90
.set ENTITY_DATA_POINTER_OFFSET, 0x2c
.set DATA_POINTER_PERCENT_OFFSET, 0x1830
.set DATA_POINTER_LAST_HIT_OFFSET, 0x18AC

.set STATIC_BLOCK_ADDRESS, 0x80453080
.set STATIC_BLOCK_OFFSET, 0xe90
.set STATIC_BLOCK_PERCENT_VISUAL_OFFSET, 0x60
.set STATIC_BLOCK_PLAYER_STOCK_OFFSET, 0x8e
.set STATIC_BLOCK_PLAYER_TYPE_OFFSET, 0x0a

.set STATIC_PERCENT_VISUAL_ADDRESS, 0x804530e0
.set STATIC_HIT_COOLDOWN_ADDRESS, 0x804530e1
.set STATIC_AMOUNT_HEALED_ADDRESS, 0x80453da4
.set STATIC_PLAYER_TYPE_ADDRESS, 0x8045308a
.set STATIC_PLAYER_STOCK_ADDRESS, 0x8045310e

.set PLAYER_TYPE_NONE, 0x3

.set FLOAT_ONE, 0x3f800000 # 1 https://www.h-schmidt.net/FloatConverter/IEEE754.html
.set FLOAT_ZERO, 0x00000000
.set HEAL_EVERY_X_FRAMES, 8 # 60fps * 1hp/8f = 7.5 hp/s
.set FRAMES_TO_DELAY_HEAL, 240

.macro loadplayerdatapointer reg, regscratch, regplayer
load \reg, STATIC_ENTITY_POINTER
offsetaddr \reg, \regscratch, STATIC_ENTITY_POINTER, STATIC_ENTITY_POINTER_OFFSET, \regplayer
followp \reg, 0
followp \reg, ENTITY_DATA_POINTER_OFFSET
.endm

# check skip scenarios
loadbz r3, SCENE_MINOR_ADDRESS
cmpwi r3, 0x2 # Checks if we are in-game
beq WE_ARE_IN_GAME
cmpwi r3, 0x3 # Checks if we are in-game sudden death
beq WE_ARE_IN_GAME # should we heal during sudden death?
cmpwi r3, 0x4 # Checks if we are in-game training mode
beq WE_ARE_IN_GAME
b EXIT

WE_ARE_IN_GAME:
loadwz r3, GAME_PAUSED_ADDRESS
cmpwi r3, 0
bgt EXIT # pause value will be greater than zero if paused

# check if this is valid frame
loadwz r3, FRAME_COUNTER_ADDRESS
load r4, HEAL_EVERY_X_FRAMES
modulo r2, r3, r4, r5
cmpwi r2, 0
bne EXIT

CHECK_IF_ANY_PLAYERS_FULL_HEALTH:
# for each player, check if they are in game.
# check if they are in game.
li r2, 0

CHECK_NEXT_PLAYER:
offsetaddr r5, r3, STATIC_BLOCK_ADDRESS, STATIC_BLOCK_OFFSET, r2
# is player slot in use?
lhz r3, STATIC_BLOCK_PLAYER_TYPE_OFFSET(r5)
cmpwi r3, PLAYER_TYPE_NONE
beq DONE_CHECKING_PLAYER
# is player dead? (in time games stocks are still greater than 0)
lbz r4, STATIC_BLOCK_PLAYER_STOCK_OFFSET(r5)
cmpwi r4, 0
beq DONE_CHECKING_PLAYER
# if a valid player has 0 damage stop healing
# this is to prevent camping.
lhz r3, STATIC_BLOCK_PERCENT_VISUAL_OFFSET(r5)
cmpwi r3, 0
ble EXIT

DONE_CHECKING_PLAYER:
addi r2, r2, 1
cmpwi r2, 4
blt CHECK_NEXT_PLAYER


PERFORM_HEAL:
# set player register to 0
li r2, 0

HANDLE_PLAYER:
loadplayerdatapointer r3, r4, r2

# check if it has been too soon since last hit
lwz r4, DATA_POINTER_LAST_HIT_OFFSET(r3)
cmpwi r4, FRAMES_TO_DELAY_HEAL
blt DONE_HANDLING_PLAYER

# read the percentage value
addi r3, r3, DATA_POINTER_PERCENT_OFFSET
lfs f3, 0(r3)

# set f4 to amount to heal
loadfs r4, f4, FLOAT_ONE

# check if remaining damage is less than heal amount
fcmpo cr1, f3, f4
blt cr1, HEAL_COMPLETELY

HEAL_BY_AMOUNT:
# perform heal
fsubs f3, f3, f4

# score healing
offsetaddr r6, r5, STATIC_AMOUNT_HEALED_ADDRESS, STATIC_BLOCK_OFFSET, r2
lwz r4, 0(r6)
addi r4, r4, 1
stw r4, 0(r6)

b DONE_HEALING

HEAL_COMPLETELY:
loadfs r4, f3, 0x00000000

DONE_HEALING:
# write updated f3(percentage) back to r3(memory location).
stfs f3, 0(r3)

# update visuals with new percent
floattoint r4, f3, f3
offsetaddr r3, r5, STATIC_PERCENT_VISUAL_ADDRESS, STATIC_BLOCK_OFFSET, r2
sth r4, 0(r3)

DONE_HANDLING_PLAYER:

# increment the player count register
addi r2, r2, 1
cmpwi r2, 4
blt HANDLE_PLAYER

EXIT:
restore

# website for finding float values https://www.h-schmidt.net/FloatConverter/IEEE754.html
# helpful doc on working with floats https://mariokartwii.com/showthread.php?tid=1744
# another helpful doc https://docs.google.com/spreadsheets/d/1MIcQkeoKeXdZEoaz9EWIP1FNXSDjT3_DtHNbH3WkQMs/edit?gid=19#gid=19


