DATA_LOC:
blrl
.set FLOAT_ZERO, 0
.float 0.0
.set FLOAT_ONE, FLOAT_ZERO + 4
.float 1.0


MAIN_STICK_LOC:
blrl
.set TEXT_CANVAS_SCALE, 0
.float 0.08
.set TEXT_X, TEXT_CANVAS_SCALE + 4
.float -1.0
.set TEXT_Y, TEXT_X + 4
.float 15.0
.set TEXT_Z, TEXT_Y + 4
.float 0.0
.set MOVE_SCALE, TEXT_Z + 4
.float 2.0
.set TEXT, MOVE_SCALE + 4
.string "o"
.align 2

C_STICK_LOC:
blrl
.set TEXT_CANVAS_SCALE, 0
.float 0.08
.set TEXT_X, TEXT_CANVAS_SCALE + 4
.float 1.0
.set TEXT_Y, TEXT_X + 4
.float 17.0
.set TEXT_Z, TEXT_Y + 4
.float 0.0
.set MOVE_SCALE, TEXT_Z + 4
.float 2.0
.set TEXT, MOVE_SCALE + 4
.string "o"
.align 2
