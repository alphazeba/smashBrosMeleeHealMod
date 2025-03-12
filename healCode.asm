#To be inserted at 80376a1c
# TODO we should choose a different injection address.
# something that runs once per frame in the game.
# i was able to confirm that current injection address does run once per frame in game.
# however, we should still find a different place to inject so it doesn't conflict with slippi

.include "./macros.asm"

# call the replaced instruction
addi r30, r3, 0


# start real code
backup

# consts
.set GAME_PAUSED_ADDRESS, 0x80479D68
.set SCENE_MINOR_ADDRESS, 0x80479d33
.set FRAME_COUNTER_ADDRESS, 0x80479d60

.set STATIC_BLOCK_ADDRESS, 0x80453080
.set STATIC_BLOCK_OFFSET, 0xe90
.set STATIC_BLOCK_PERCENT_VISUAL_OFFSET, 0x60
.set STATIC_BLOCK_PLAYER_STOCK_OFFSET, 0x8e
.set STATIC_BLOCK_PLAYER_TYPE_OFFSET, 0x0a
.set STATIC_BLOCK_AMOUNT_HEALED_OFFSET, 0xd24
.set STATIC_BLOCK_HIT_COOLDOWN_OFFSET, 0x61

.set PLAYER_TYPE_NONE, 0x3

.set FLOAT_ONE, 0x3f800000 # 1 https://www.h-schmidt.net/FloatConverter/IEEE754.html
.set FLOAT_ZERO, 0x00000000

.set HEAL_EVERY_X_FRAMES, 8 # 60fps * 1hp/8f = 7.5 hp/s
.set FRAMES_TO_DELAY_HEAL, 240

.set REG_CUR_PLAYER, 12

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
modulo r5, r3, r4
cmpwi r5, 0
bne EXIT

CHECK_IF_ANY_PLAYERS_FULL_HEALTH:
# for each player, check if they are in game.
# check if they are in game.
li REG_CUR_PLAYER, 0

CHECK_NEXT_PLAYER:
offsetaddr r7, r4, STATIC_BLOCK_ADDRESS, STATIC_BLOCK_OFFSET, REG_CUR_PLAYER
# is player slot in use?
lhz r3, STATIC_BLOCK_PLAYER_TYPE_OFFSET(r7)
cmpwi r3, PLAYER_TYPE_NONE
beq DONE_CHECKING_PLAYER
# is player dead? (in time games stocks are still greater than 0)
lbz r4, STATIC_BLOCK_PLAYER_STOCK_OFFSET(r7)
cmpwi r4, 0
beq DONE_CHECKING_PLAYER
# if a valid player has 0 damage stop healing
# this is to prevent camping.
lhz r5, STATIC_BLOCK_PERCENT_VISUAL_OFFSET(r7)
cmpwi r5, 0
ble EXIT

DONE_CHECKING_PLAYER:
addi REG_CUR_PLAYER, REG_CUR_PLAYER, 1
cmpwi REG_CUR_PLAYER, 4
blt CHECK_NEXT_PLAYER


PERFORM_HEAL:
# set player register to 0
li REG_CUR_PLAYER, 0

HANDLE_PLAYER:
loadplayerdatapointer r6, r4, REG_CUR_PLAYER

# check if it has been too soon since last hit
lwz r4, DATA_POINTER_LAST_HIT_OFFSET(r6)
cmpwi r4, FRAMES_TO_DELAY_HEAL
blt DONE_HANDLING_PLAYER

# read the percentage value
lfs f3, DATA_POINTER_PERCENT_OFFSET(r6)

# set f4 to amount to heal
loadfs r4, f4, FLOAT_ONE

# check if remaining damage is less than heal amount
fcmpo cr1, f3, f4
blt cr1, HEAL_COMPLETELY

HEAL_BY_AMOUNT:
# perform heal
fsubs f3, f3, f4

offsetaddr r7, r4, STATIC_BLOCK_ADDRESS, STATIC_BLOCK_OFFSET, REG_CUR_PLAYER
# score healing
lwz r4, STATIC_BLOCK_AMOUNT_HEALED_OFFSET(r7)
addi r4, r4, 1
stw r4, STATIC_BLOCK_AMOUNT_HEALED_OFFSET(r7)

b DONE_HEALING

HEAL_COMPLETELY:
loadfs r4, f3, FLOAT_ZERO

DONE_HEALING:
# write updated percentage back to memory
stfs f3, DATA_POINTER_PERCENT_OFFSET(r6)

# update visuals with new percent
floattoint r4, f3, f3
sth r4, STATIC_BLOCK_PERCENT_VISUAL_OFFSET(r7)

DONE_HANDLING_PLAYER:

# increment the player count register
addi REG_CUR_PLAYER, REG_CUR_PLAYER, 1
cmpwi REG_CUR_PLAYER, 4
blt HANDLE_PLAYER

EXIT:
restore

# website for finding float values https://www.h-schmidt.net/FloatConverter/IEEE754.html
# helpful doc on working with floats https://mariokartwii.com/showthread.php?tid=1744
# another helpful doc https://docs.google.com/spreadsheets/d/1MIcQkeoKeXdZEoaz9EWIP1FNXSDjT3_DtHNbH3WkQMs/edit?gid=19#gid=19


