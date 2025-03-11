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
.float -4.0
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
.float 0.07
.set TEXT_X, TEXT_CANVAS_SCALE + 4
.float 4.0
.set TEXT_Y, TEXT_X + 4
.float 17.0
.set TEXT_Z, TEXT_Y + 4
.float 0.0
.set MOVE_SCALE, TEXT_Z + 4
.float 2.0
.set TEXT, MOVE_SCALE + 4
.string "o"
.align 2


A_BTN_LOC:
blrl
.set TEXT_CANVAS_SCALE, 0
.float 0.04
.set TEXT_X, TEXT_CANVAS_SCALE + 4
.float 6
.set TEXT_Y, TEXT_X + 4
.float 14.0
.set TEXT_Z, TEXT_Y + 4
.float 0.0
.set MOVE_SCALE, TEXT_Z + 4
.float 2.0
.set TEXT, MOVE_SCALE + 4
.string "A"
.align 2

B_BTN_LOC:
blrl
.set TEXT_CANVAS_SCALE, 0
.float 0.03
.set TEXT_X, TEXT_CANVAS_SCALE + 4
.float 3
.set TEXT_Y, TEXT_X + 4
.float 15
.set TEXT_Z, TEXT_Y + 4
.float 0.0
.set MOVE_SCALE, TEXT_Z + 4
.float 2.0
.set TEXT, MOVE_SCALE + 4
.string "B"
.align 2

X_BTN_LOC:
blrl
.set TEXT_CANVAS_SCALE, 0
.float 0.03
.set TEXT_X, TEXT_CANVAS_SCALE + 4
.float 8
.set TEXT_Y, TEXT_X + 4
.float 13.0
.set TEXT_Z, TEXT_Y + 4
.float 0.0
.set MOVE_SCALE, TEXT_Z + 4
.float 2.0
.set TEXT, MOVE_SCALE + 4
.string "x"
.align 2

Y_BTN_LOC:
blrl
.set TEXT_CANVAS_SCALE, 0
.float 0.03
.set TEXT_X, TEXT_CANVAS_SCALE + 4
.float 6
.set TEXT_Y, TEXT_X + 4
.float 12.0
.set TEXT_Z, TEXT_Y + 4
.float 0.0
.set MOVE_SCALE, TEXT_Z + 4
.float 2.0
.set TEXT, MOVE_SCALE + 4
.string "y"
.align 2
