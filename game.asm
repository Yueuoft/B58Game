#####################################################################
#
# CSCB58 Winter 2024 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Yue Li, 1004746091, liyue42, yuee.li@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# - Milestone 4
#
#
# Which approved features have been implemented for milestone 4?
#
# 1. Moving objects (2 marks)
#	[enemies patrol left and right across on the platform they are on; pickups hovering gently up and down]
# 2. Moving platforms (2 marks)
#	[Two moving platforms;]
# 3. Double jump (1 mark):
#	allow the player to jump when in mid-air, but only once!
#
####
#
# Link to video demonstration for final submission:
# - https://youtu.be/kw-EAm9JxDY?si=jgWh2k4E4X0Sn_TY
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (sometimes the "you won" page and gameover page takes longer to load, please try again)
# - (Display score in game over page was added later which was not included in the demo, please notice that it now displays the score earned in game over page)
#
#####################################################################










.eqv BASE_ADDRESS 	0x10008000

.eqv EnemieInitialAddress		16108
# Max address (X = 59, Y = 62) 63 - 1 - 3 = 59; 63 - 1 = 62; Width = 64 =>   16108
.eqv EnemieMaxPossibleBaseAddress	16108
# Min Address (X = 4, Y = 62) 		15888
.eqv EnemieMinPossibleBaseAddress	15888
#
.eqv MainCharacterInitialAddress	15912
.eqv MainCharacterMaxXonGround		16116
.eqv MainCharacterMinXonGround		15880
#
.eqv MainCharacterMaxY

# .eqv PickUpsInitialAddresses



#  Each 4-byte value has the following structure: 0x00RRGGBB, where 00 are just zeros, RR is
# an 8-bit colour value for the red component, GG are the 8-bits for the green components, and BB are
# the 8-bits for the blue component. For example, 0x00000000 is black,0x00ff0000 is bright red,
# 0x0000ff00 is green, and 0x00ffff00 is yellow


.eqv Orange 				0x00ff7e00
.eqv BoundaryPink 			0x00ffa3b1
.eqv PlatformGreen 			0x00a8e61d
.eqv Black 				0x00000000
.eqv Yellow 				0x00fff200
.eqv CRLightBlue 			0x0099d9ea
.eqv CRLightGreen 			0x00d3f9bc
.eqv CRDarkGreen			0x0022b14c
.eqv EMGrey				0x00546d8e
.eqv EMRed				0x00ed1c24
.eqv EMdarkblue				0x002f3699


.eqv Sleeptime 	40

.eqv NumEnemies 		1
.eqv NumPickUps 		3
.eqv JumpHeight			12	# units
.eqv MaxTimeJumped		2	# time before Collide with platform
.eqv FallingRate		1
.eqv JumpRate			12
.eqv platformMovingRate		1	#unitFrameBuffer
.eqv EnemieMovingRate		1
.eqv MainCharacterMovingRate	3
.eqv PickUpHoverRate		1


.eqv HeightofMainCharacter	9



.eqv RowUnit		64
.eqv LBM 		16128		# (62*64+0)*4 = 16128
.eqv RBM		16124		#(62*64+63)*4 = 16124
.eqv GBM		16380		# (63*64+63)*4 = 16380




#####
.data

NumCollected: 	.word 	0
NumFilled:	.word	0
NumJumped:	.word	0




EnemieState:	.word	0
# Initial == 0
# Patrol Right == 1
# Collision with wall == 2
# Patrol left == 3


PickUpState1:	.word	0
# ==
# == 1 ----> Erase ---> ScoreState + 1
PickUpState2:	.word	0
PickUpState3:	.word	0





ScoreState:	.word 	0
# Score == 0
# Score == 1	PaintScore1
# Score == 2	PaintScore2
# Score == 3	PaintScore3 --> GameState --> you win



######################
# Main Character 4 Signals:

Collison_with_Ground_Signal:	.word 	0
# A[0]   Collison_with_Ground_Signal
# on_the_ground == 0 -> suspend respond_to_s;(no respond_to_s all the time?)
# in the air, could double jump == 1
# has double jumped == 2 -> suspend respond_to_w


Collision_with_Wall_Signal:	.word	0
# A[1]   Collision_with_Wall_Signal
# no wall == 0
# left_wall == 1 --> suspend respond_to_a
# right_Wall == 2 ---> suspend respond_to_d



Collision_with_Enemie_Signal:	.word	0
# A[2]   Collision_with_Enemie_Signal
# No == 0
#Yes == 1 ---> Red EFFECT --> GameOVer


Collision_with_PickUp_Signal:	.word	0
# A[3]   Collision_with_PickUp_Signal
# No == 0
# Yes == 1 ----> YellowEffect ----> NumCollected + 1






MainCharacterState:	.word 	0
#  Initial/steady state == 0
# Jumping State == 1 --> detect up
# Falling State == 2 ----> detect down



GameState:	.word	1
# initial == 1;  win == 2; lose == 3;



# [0-63, 0-63]
# Address =
MainCRCoordinateXY:	.word 0:2


PickUp1CoordinateXY:	.word 22 50
# [23, 50]

PickUp2CoordinateXY:	.word 35 50
# [36, 50]

PickUp3CoordinateXY:	.word	54 38
# [55, 38]

EnemieInitialCoordinate:	.word 	31 62
EnemieCurrentCoordinate:	.word 	31 62
EnemieLeftMostCoordinate:	.word	17 62
EnemieRightMostCoordinate:	.word	46 62


# Range (Same as FLOATING PLATFORM)???
# base / central address
# [18, 63] ----[47, 63]

MainCharacterCurrentCoordinate:	.word 	4 62
MainCharacterInitialCoordinate:	.word	4 62


MovingPlatformState:	.word	1
# initial state == 0 == initial position
# Patrol right == 2
# Patrol left == 1

MovingPlatformState2:	.word	1
# PatrolUp == 1
# PatrolDown == 2



MovingPlatformInitialCoordinateA:	.word 48 39
# [48, 40]----[61, 40]
# Length == 14
MovingPlatformInitialCoordinateB:	.word 61 39


MovingPlatformEndCoordinateA:	.word 	43 39
# [43, 40]------[56,40]
# Length == 14
MovingPlatformEndCoordinateB:	.word	56 39

# MovingPlatformInitial [48, 40] ---- [61, 40]   length = 14
# MovingPlatformEndRange [ 44, 40] ------[56, 40]   length = 14

MovingPlatform2InitialCoordinateA:	.word	48 29
# 27
MovingPlatform2InitialCoordinateB:	.word	61 29
# 27
MovingPlatform2EndCoordinateA:		.word	48 15
# 13
MovingPlatform2EndCoordinateB:		.word	61 15
# 13









MovingPlatformCurrentCoordinateA:	.word 48 39

MovingPlatformCurrentCoordinateB:	.word 61 39


MovingPlatform2CurrentCoordinateA:	.word 48 27

MovingPlatform2CurrentCoordinateB:	.word 61 27




FloatingPlatformXCoordinate:	.word 14 51
# [15,52] ----[49, 52]    Length == 35

FloatingPlatformENDCoordinate:	.word 48 51

FloatingPlatformLength:		.word 35


MainCharacterCurrentAddress:	.word 7 62



# IF Main Character's X coordinate less than or equal to 3, detect collision_with_left_wall
LeftWallBoundaryCoordinate:	.word 2

# IF Main Character's X coordinate is greater than or equal to 62, collision_with_right_wall detected
RightWallBoundaryCoordinate:	.word 61


ScoreBoxCoordinate:	.word
# [2, 2]        [7,2]		[12,2]		[17,2]
# [2, 7]	[7,7]		[12,7]		[17,7]

ScoreBoxCoordinate1:	.word	1 1
ScoreBoxCoordinate2:	.word	16 1
ScoreBoxCoordinate3:	.word	1 6
ScoreBoxCoordinate4:	.word	16 6
ScoreBoxCoordinate5:	.word	6 1
ScoreBoxCoordinate6:	.word	6 6
ScoreBoxCoordinate7:	.word	11 1
ScoreBoxCoordinate8:	.word	11 6


FillScoreBox1Coordinate:	.word	2 2
#	[2,2]	[5 2] ALL MINUS 1 !!!!!!!!!!!

#	[2,5]	[5,5]
FillScoreBox2Coordinate:	.word	7 2
#	[7,2]	[10,2]

#	[7,5]	[10,5]

FillScoreBox3Coordinate:	.word	12 2
#	[12,2]	[15,2]

#	[12,5]	[15,5]

DrawGameOverCoordinate:		.word	14 22

DrawYouWinCoordinate:		.word	10 23

###########################################################################################################
.text
.globl main



###################################################################################### MAIN STARTS HERE
main:
	jal ClearScreenSetup

	# GAME INITIAL SET UP
	DrawInitialScreen:

	# Start With DrawBoundaries Block
	# WHICH draws in the order of UpperLeftGround -----> then Branch to Draw MiddlePlatform Block
	# then branch to Draw Moving Platfrom Initial
	# THEN BRANCH TO InitialDrawScoreBox
	# Then Branch To Initial Draw PickUps
	# Then Branch To initial Draw Enemie
	# Then Branch to initial Draw Character
	# Initial Drawing Finished
	# NEXT, SET UP THE INITIAL STATES


################################    BLOCK #1 -------->   DrawBoundaries

DrawBoundaries:
	# This Block of Code uses all temporary registers t0 - t7 to paint the four boundaries for now
	#	IT ENDS THE WHOLE PROGRAM after running FOR NOW


	# Draw the Upper Boundary to Pink
	li $t0, BASE_ADDRESS
	li $t1, BoundaryPink
	# Draw the ground boundary (platform to green later [after drawing upper,left,right boundaries])
	li $t7, PlatformGreen
	# let t2 be the current address
	move $t2, $t0
	# endpoint for upper boundary painting
	addi $t3, $t2, 256
	# endpoint for left boundary painting	256 * 64 = 16384
	addi $t4, $t0, LBM
	# endpoint for right boundary painting
	addi $t5, $t0, RBM
	# endpoint for Ground Boundary painting
	addi $t6, $t0, GBM

PaintUpperBoundary:
	beq $t2, $t3, PaintLeftBoundary
	sw $t1, 0($t2) 	# paint the first (top-left) unit pink

	addi $t2, $t2, 4
	j PaintUpperBoundary

PaintLeftBoundary:
	# $t2 = $t0 + 256 at this time
	beq $t2, $t4, PaintRightBoundaryInitial
	sw $t1, 0($t2)			# paint row 1 column 0 to pink
	addi $t2, $t2, 256
	j PaintLeftBoundary

PaintRightBoundaryInitial:
	# $t2 = $t0 + LBM at this time

	add $t2, $t0, 252

PaintRightBoundary:

	sw $t1, 0($t2)
	beq $t2, $t5, PaintGroundInitial
	addi $t2, $t2, 256

	j PaintRightBoundary

PaintGroundInitial:
	# start from current t2 + 4
	addi $t2, $t2, 4

PaintGround:
	sw $t7, 0($t2)
	beq $t2, $t6, DrawMiddlePlatform

	addi $t2, $t2, 4
	j PaintGround

################ BLOCK #1 <----------------------------

################################### BLOCK # 2------------------------------>

DrawMiddlePlatform:
	# Set Up platform Length and Coordinates
	la $t1, FloatingPlatformXCoordinate
	# Load X coordinate
	lw $t2, 0($t1)
	# Load Y coordinate
	lw $t3, 4($t1)
	# Calculate Address
	move $a0, $t2
	move $a1, $t3

	jal CalculateAddress
	move $t4, $v0
	# StartAddress in $t4




	# Get endpoint
	la $t5, FloatingPlatformENDCoordinate
	# Load X coordinate
	lw $t6, 0($t5)
	# Load Y coordinate
	lw $t7, 4($t5)
	# Calculate Address
	move $a0, $t6
	move $a1, $t7
	jal CalculateAddress
	move $t0, $v0

	# Start Drawing
	li $t7, PlatformGreen
DrawMidPlat:
	bgt $t4, $t0, DrawMovingPlatformInitial
	sw $t7, 0($t4)

	addi $t4, $t4, 4
	j DrawMidPlat



################################### BLOCK #2 <-----------------------------



################################ BLOCK # 3 ------------------------->

DrawMovingPlatformInitial:
	# Set up Platform length and Moving Ranges
	la $t1, MovingPlatformInitialCoordinateA
	# Load X coordinate
	lw $t2, 0($t1)
	# Load Y coordinate
	lw $t3, 4($t1)
	# Calculate Address
	move $a0, $t2
	move $a1, $t3

	jal CalculateAddress
	move $t4, $v0

	# Get endpoint
	la $t5, MovingPlatformInitialCoordinateB
	# Load X coordinate
	lw $t6, 0($t5)
	# Load Y coordinate
	lw $t7, 4($t5)
	# Calculate Address
	move $a0, $t6
	move $a1, $t7
	jal CalculateAddress
	move $t0, $v0

StartDrawingFlot:

	li $t7, PlatformGreen
DrawFlotPlatI:
	bgt $t4, $t0, DrawMovingPlatform2Initial
	sw $t7, 0($t4)

	addi $t4, $t4, 4
	j DrawFlotPlatI


# Change from branch to initial draw pickup to DRAWSCOREBOX, THEN BRANCH TO INITIAL DRAW PICKUP FROM THERE.

################################# INITIAL DRAW OF MOVING PLATFORM <----------------

################################# INITIAL DRAW OF MOVING PLATFORM 2 ------------->

DrawMovingPlatform2Initial:
	# Set up Platform length and Moving Ranges
	la $t1, MovingPlatform2InitialCoordinateA
	# Load X coordinate
	lw $t2, 0($t1)
	# Load Y coordinate
	lw $t3, 4($t1)
	# Calculate Address
	move $a0, $t2
	move $a1, $t3

	jal CalculateAddress
	move $t4, $v0

	# Get endpoint
	la $t5, MovingPlatform2InitialCoordinateB
	# Load X coordinate
	lw $t6, 0($t5)
	# Load Y coordinate
	lw $t7, 4($t5)
	# Calculate Address
	move $a0, $t6
	move $a1, $t7
	jal CalculateAddress
	move $t0, $v0

StartDrawingFlot2:

	li $t7, PlatformGreen
DrawFlotPlatII:
	bgt $t4, $t0, InitialDrawScoreBox
	sw $t7, 0($t4)

	addi $t4, $t4, 4
	j DrawFlotPlatII









################################# INITIAL DRAW OF MOVING PLATFORM 2 <----------------

######################### Initial DRAW THE SCORE BOX ----------------->
# BRANCH HERE FROM INITIAL MOVING PLATFORM, AND BRANCH TO INITIALDRAWPICKUP AFTER DONE IT

InitialDrawScoreBox:
	la $t1, ScoreBoxCoordinate1
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0
	# get the starting address and saved in $t4

	la $t1, ScoreBoxCoordinate2
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t5, $v0
	# Get the endpoint and paint -->

	li $t0, Orange
StartPaintIB1:
	bgt $t4, $t5, PaintIB2
	sw $t0, 0($t4)

	addi $t4, $t4, 4
	j StartPaintIB1

PaintIB2:
	la $t1, ScoreBoxCoordinate3
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0
	# get the starting address and saved in $t4

	la $t1, ScoreBoxCoordinate4
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t5, $v0
	# Get the endpoint and paint -->
	li $t0, Orange
StartPaintIB2:
	bgt $t4, $t5, PaintIBV1
	sw $t0, 0($t4)

	addi $t4, $t4, 4
	j StartPaintIB2

	# start paint vertical lines   FOUR(4) in total
PaintIBV1:
	la $t1, ScoreBoxCoordinate1
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0
	# get the starting address and saved in $t4

	la $t1, ScoreBoxCoordinate3
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t5, $v0
	# Get the endpoint and paint -->
	li $t0, Orange
StartPaintIBV1:
	bgt $t4, $t5, PaintIBV2
	sw $t0, 0($t4)

	addi $t4, $t4, 256
	j StartPaintIBV1



PaintIBV2:
	la $t1, ScoreBoxCoordinate5
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0
	# get the starting address and saved in $t4

	la $t1, ScoreBoxCoordinate6
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t5, $v0
	# Get the endpoint and paint -->
	li $t0, Orange
StartPaintIBV2:
	bgt $t4, $t5, PaintIBV3
	sw $t0, 0($t4)

	addi $t4, $t4, 256
	j StartPaintIBV2


PaintIBV3:
	la $t1, ScoreBoxCoordinate7
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0
	# get the starting address and saved in $t4

	la $t1, ScoreBoxCoordinate8
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t5, $v0
	# Get the endpoint and paint -->
	li $t0, Orange
StartPaintIBV3:
	bgt $t4, $t5, PaintIBV4
	sw $t0, 0($t4)

	addi $t4, $t4, 256
	j StartPaintIBV3



PaintIBV4:
	la $t1, ScoreBoxCoordinate2
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0
	# get the starting address and saved in $t4

	la $t1, ScoreBoxCoordinate4
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t5, $v0
	# Get the endpoint and paint -->
	li $t0, Orange
StartPaintIBV4:
	bgt $t4, $t5, InitialDrawPickup
	sw $t0, 0($t4)

	addi $t4, $t4, 256
	j StartPaintIBV4

	# BRANCH TO InitialDrawPickup AFTER
#############################  Initial SCORE BOX DRAWING <---------


######################## Initial Draw PickUps --------------->

InitialDrawPickup:

	la $t1, PickUp1CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0

	li $t5, Yellow
	sw $t5, 0($t4)
	sw $t5, -260($t4)
	sw $t5, -252($t4)
	sw $t5, -512($t4)
	sw $t5, -764($t4)
	sw $t5, -772($t4)

	la $t1, PickUp2CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0

	li $t5, Yellow
	sw $t5, 0($t4)
	sw $t5, -260($t4)
	sw $t5, -252($t4)
	sw $t5, -512($t4)
	sw $t5, -764($t4)
	sw $t5, -772($t4)

	la $t1, PickUp3CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0

	li $t5, Yellow
	sw $t5, 0($t4)
	sw $t5, -260($t4)
	sw $t5, -252($t4)
	sw $t5, -512($t4)
	sw $t5, -764($t4)
	sw $t5, -772($t4)


	j InitialDrawEnemie
################################### Initial Draw Pick Ups <------------





##################### Initial Draw Enemie  ---------------->

InitialDrawEnemie:

	la $t0, EnemieInitialCoordinate

	lw $t1, 0($t0)
	lw $t2, 4($t0)

	move $a0, $t1
	move $a1, $t2
	jal CalculateAddress
	move $t1, $v0


	# Get Colors
	li $t7, EMGrey
	li $t6, EMRed
	li $t5, EMdarkblue
	# Draw Bottom layer (1)
	sw $t7, 0($t1)
	sw $t7, 8($t1)
	sw $t7, 12($t1)
	sw $t7, -8($t1)
	sw $t7, -12($t1)
	sw $t5, 4($t1)
	sw $t5, -4($t1)
	# Draw Layer (2)
	sw $t6, -252($t1)
	sw $t6, -260($t1)
	sw $t7, -248($t1)
	sw $t7, -264($t1)
	#  lw $t7, 0($t1)   Black no need to draw

	# Draw Layer (3)
	sw $t7, -516($t1)
	sw $t7, -508($t1)
	#lw $t7, 0($t1)     Black no need to draw

	# Draw Layer (4)
	sw $t7, -768($t1)

	j InitialDrawCharacter

	# Branch to Initial Draw Character After it done
###############################  Initial Draw Enemie  <------------

################### Initial Draw Main Character ---------------->
InitialDrawCharacter:
	la $t1, MainCharacterInitialCoordinate
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t2, $v0

	# t2 as the base address


	li $t5, CRLightBlue
	li $t6, CRLightGreen

	# Draw Middle Line
	sw $t5, 0($t2)
	sw $t5, -256($t2)
	sw $t5, -512($t2)
	sw $t5, -768($t2)
	sw $t6, -1024($t2)
	sw $t6, -1280($t2)
	sw $t6, -1536($t2)
	sw $t5, -1792($t2)
	sw $t5, -2048($t2)

	sw $t5, 4($t2)
	sw $t5, -772($t2)
	sw $t6, -1276($t2)
	sw $t5, -1540($t2)
	sw $t5, -1796($t2)

	sw $t5, -4($t2)
	sw $t5, -764($t2)
	sw $t6, -1284($t2)
	sw $t5, -1532($t2)
	sw $t5, -1788($t2)

	# Finish Drawing

	j InitializeState

########################### Initial Draw Main Character <----------












############
# for each iteration:

#• Check for keyboard input.

#• Figure out if the player character is standing on a platform.

#• Update player location, enemies, platforms, power ups, etc.

#• Check for various collisions (e.g., between playerand enemies).

#• Update other game state and end of game.

#• Erase objects from the old position on the screen.

#• Redraw objects in the new position on the screen.

# sleep for a short time and loop again...
############

InitializeState:
	# Set up Game State
	# Initial State should == 1
	la $t1, GameState
	li $t2, 1
	sw $t2, 0($t1)

	# 2. Set up MovingPlatformState
	la $t1, MovingPlatformState
	li $t2, 1 # patrol left == 1, right == 2
	sw $t2, 0($t1)

	# 3. Set up EnemieState
	la $t1, EnemieState
	li $t2, 2 # patrol left == 1, right == 2
	sw $t2, 0($t1)

	# 4. Set up all the signals
	la $t1, Collison_with_Ground_Signal
	sw $zero, 0($t1)

	la $t1, Collision_with_Wall_Signal
	li $t2, 1
	sw $t2, 0($t1)

	la $t1, Collision_with_Enemie_Signal
	sw $zero, 0($t1)

	la $t1, Collision_with_PickUp_Signal
	sw $zero, 0($t1)

	### Check if the signals match!!!

	# Set PickUps States
	la $t1, PickUpState1
	sw $zero, 0($t1)

	la $t1, PickUpState2
	sw $zero, 0($t1)

	la $t1, PickUpState3
	sw $zero, 0($t1)

	# Set Score State
	la $t1, ScoreState
	sw $zero, 0($t1)


	# Set Main Character State
	la $t1, MainCharacterState
	sw $zero, 0($t1)

	# Set initial Num Collected
	la $t1, NumCollected
	sw $zero, 0($t1)

	# Set initial Num Filled
	la $t1, NumFilled
	sw $zero, 0($t1)

	# Reset pickup1 initial coordinates
	la $t1, PickUp1CoordinateXY
	li $t2, 22
	sw $t2, 0($t1)
	li $t2, 50
	sw $t2, 4($t1)


	# Reset pickup2 initial coordinates
	la $t1, PickUp2CoordinateXY
	li $t2, 35
	sw $t2, 0($t1)
	li $t2, 50
	sw $t2, 4($t1)

	# Reset pickup3 initial coordinates
	la $t1, PickUp3CoordinateXY
	li $t2, 54
	sw $t2, 0($t1)
	li $t2, 38
	sw $t2, 4($t1)

	# Reset MainCharacter initial Coordinate?
	la $t1, MainCharacterCurrentCoordinate
	li $t2, 4
	sw $t2, 0($t1)
	li $t2, 62
	sw $t2, 4($t1)

	# Set up Moving platfrom STATES
	la $t1, MovingPlatformState
	li $t2, 1
	sw $t2, 0($t1)

	la $t1, MovingPlatformState2
	li $t2, 1
	sw $t2, 0($t1)

	# Set up moving platform initial coordinates
	la $t1, MovingPlatformCurrentCoordinateA
	li $t2, 48
	li $t3, 39
	sw $t2, 0($t1)
	sw $t3, 4($t1)

	la $t1, MovingPlatformCurrentCoordinateB
	li $t2, 61
	li $t3, 39
	sw $t2, 0($t1)
	sw $t3, 4($t1)

	la $t1, MovingPlatform2CurrentCoordinateA
	li $t2, 48
	li $t3, 29
	sw $t2, 0($t1)
	sw $t3, 4($t1)

	la $t1, MovingPlatform2CurrentCoordinateB
	li $t2, 61
	li $t3, 29
	sw $t2, 0($t1)
	sw $t3, 4($t1)








mainLoop:
	j Step1











#############################################

Step1: # Check Game State
	# initial == 1;  win == 2; lose == 3
	la $t0, GameState
	lw $t1, 0($t0)

	beq $t1, 2, DrawYouWinPage
	beq $t1, 3, GameOverPage




Step2: # Update Moving Platform
	la $t0, MovingPlatformState
	lw $t1, 0($t0)

	beq $t1, 1, MovingPlatFormPatrolLeft
	beq $t1, 2, MovingPlatFormPatrolRight

MovingPlatFormPatrolLeft:
	# Erase and Redraw platform

		# updateCurrentCoordinate
		la $t2, MovingPlatformCurrentCoordinateA
		lw $t3, 0($t2)
		addi $t4, $t3, -1
		la $t5, MovingPlatformEndCoordinateA
		lw $t6, 0($t5)
		blt $t4, $t6, DonePatrolLeft
		# jal Erase
		jal EraseMovingPlatformA

		la $t2, MovingPlatformCurrentCoordinateA
		lw $t3, 0($t2)
		addi $t4, $t3, -1
		sw $t4, 0($t2)

		la $t2, MovingPlatformCurrentCoordinateB
		lw $t3, 0($t2)
		addi $t4, $t3, -1
		sw $t4, 0($t2)

		jal DrawMovingPlatformA
		j CheckPlatB

DonePatrolLeft:
		# Update Moving Platform State and goes to the next one
		la $t0, MovingPlatformState
		li $t1, 2
		sw $t1, 0($t0)
		j CheckPlatB
		# CheckCollison?

	# branch to next step in mainloop
	#		j Step3

MovingPlatFormPatrolRight:
	# Erase and Redraw platform
		# Erase and Redraw platform

		# updateCurrentCoordinate
		la $t2, MovingPlatformCurrentCoordinateB
		lw $t3, 0($t2)
		addi $t4, $t3, 1
		la $t5, MovingPlatformInitialCoordinateB
		lw $t6, 0($t5)
		bgt $t4, $t6, DonePatrolRight
		# jal Erase
		jal EraseMovingPlatformA

		la $t2, MovingPlatformCurrentCoordinateA
		lw $t3, 0($t2)
		addi $t4, $t3, 1
		sw $t4, 0($t2)


		la $t2, MovingPlatformCurrentCoordinateB
		lw $t3, 0($t2)
		addi $t4, $t3, 1
		sw $t4, 0($t2)

		jal DrawMovingPlatformA
		j CheckPlatB

DonePatrolRight:
		# Update Moving Platform State and goes to the next one
		la $t0, MovingPlatformState
		li $t1, 1
		sw $t1, 0($t0)
		j CheckPlatB
		# CheckCollison?

CheckPlatB:
	la $t0, MovingPlatformState2
	lw $t1, 0($t0)

	beq $t1, 1, MovingPlatFormPatrolUp
	beq $t1, 2, MovingPlatFormPatrolDown

MovingPlatFormPatrolUp:
	# Erase and Redraw platform

		# updateCurrentCoordinate
		la $t2, MovingPlatform2CurrentCoordinateA
		lw $t3, 4($t2)
		addi $t4, $t3, -1
		la $t5, MovingPlatform2EndCoordinateA
		lw $t6, 4($t5)
		blt $t4, $t6, DonePatrolUp
		# jal Erase
		jal EraseMovingPlatformB

		la $t2, MovingPlatform2CurrentCoordinateA
		lw $t3, 4($t2)
		addi $t4, $t3, -1
		sw $t4, 4($t2)
		la $t2, MovingPlatform2CurrentCoordinateB
		lw $t3, 4($t2)
		addi $t4, $t3, -1
		sw $t4, 4($t2)

		jal DrawMovingPlatformB
		j Step3

DonePatrolUp:
		# Update Moving Platform State and goes to the next one
		la $t0, MovingPlatformState2
		li $t1, 2
		sw $t1, 0($t0)
		j Step3
		# CheckCollison?

	# branch to next step in mainloop
	#		j Step3

MovingPlatFormPatrolDown:
	# Erase and Redraw platform
		# Erase and Redraw platform

		# updateCurrentCoordinate
		la $t2, MovingPlatform2CurrentCoordinateA
		lw $t3, 4($t2)
		addi $t4, $t3, 1
		la $t5, MovingPlatform2InitialCoordinateA
		lw $t6, 4($t5)
		bgt $t4, $t6, DonePatrolDown
		# jal Erase
		jal EraseMovingPlatformB

		la $t2, MovingPlatform2CurrentCoordinateA
		lw $t3, 4($t2)
		addi $t4, $t3, 1
		sw $t4, 4($t2)

		la $t2, MovingPlatform2CurrentCoordinateB
		lw $t3, 4($t2)
		addi $t4, $t3, 1
		sw $t4, 4($t2)

		jal DrawMovingPlatformB
		j Step3

DonePatrolDown:
		# Update Moving Platform State and goes to the next one
		la $t0, MovingPlatformState2
		li $t1, 1
		sw $t1, 0($t0)
		j Step3
		# CheckCollison?













Step3: # Update Enemie
	la $t0, EnemieState
	lw $t1, 0($t0)

	# Patrol Left == 1
	# Patrol Right == 2

	beq $t1, 1, EnemiePatrolLeft
	beq $t1, 2, EnemiePatrolRight

EnemiePatrolLeft:
	# EraseEnemie
	jal EraseCurrentEnemie
	# UpdateCurrentCoordinate to left
	la $t0, EnemieCurrentCoordinate
	lw $t1, 0($t0)
	lw $t2, 4($t0)

	addi $t1, $t1, -4
	sw $t1, 0($t0)


	# CheckCollison and Update Enemie State
	ble $t1, 20, EnemieCollideLeftWall


	# DrawEnemie
	jal DrawEnemie

	j Step4

EnemieCollideLeftWall:
	# Update Enemie State
	la $t0, EnemieState
	li $t1, 2
	sw $t1, 0($t0)

	# Branch to next step
	j Step4


EnemiePatrolRight:
	# EraseEnemie
	jal EraseCurrentEnemie
	# UpdateCurrentCoordinate to left
	la $t0, EnemieCurrentCoordinate
	lw $t1, 0($t0)
	lw $t2, 4($t0)

	addi $t1, $t1, 4
	sw $t1, 0($t0)


	# CheckCollison and Update Enemie State
	bge $t1, 44, EnemieCollideRightWall


	# DrawEnemie
	jal DrawEnemie

	j Step4


EnemieCollideRightWall:
	# Update Enemie State
	la $t0, EnemieState
	li $t1, 1
	sw $t1, 0($t0)

	# Branch to next step
	j Step4






Step4: # Update PickUps

	PU1:
	la $t0, PickUpState1
	lw $t1, 0($t0)

	# PickUpState == 4, Collected. Erase and set coordinate to [0,0]
	# PickUpState == 1, Hover Up
	# PickUpState == 2, Hover Down

	beq $t1, 1, HoverUp1
	beq $t1, 2, HoverDown1
	beq $t1, 4, Collected1
	# Write the 1.erase part in the collision detection part, also 2.set the coordinate to [0,0] there
	# 3. Update state to collected

	#Collected branch should do nothing and jump to next step directly

HoverUp1:
	# ErasePickUp1
	la $t1, PickUp1CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp

	# UpdateCurrentCoordinate to Up
	la $t1, PickUp1CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	addi $t3, $t3, -1
	sw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3

	# DrawPickUp1
	jal DrawPickUp

	# Update PickUp1 State
	la $t0, PickUpState1
	li $t1, 2
	sw $t1, 0($t0) # set to 2 hoverdown


	# Branch to next step (Check for next pick Up)
	j PU2




HoverDown1:
	# ErasePickUp1
	la $t1, PickUp1CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp
	# UpdateCurrentCoordinate to Down
	la $t1, PickUp1CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	addi $t3, $t3, 1
	sw $t3, 4($t1)


	move $a0, $t2
	move $a1, $t3

	# DrawPickUp1
	jal DrawPickUp

	# Update PickUp1 State
	la $t0, PickUpState1
	li $t1, 1
	sw $t1, 0($t0) # set to 1 hoverup

	# Branch to next step (Check for next pick Up)
	j PU2





Collected1:
	j PU2


PU2:
	la $t0, PickUpState2
	lw $t1, 0($t0)

	# PickUpState == 4, Collected. Erase and set coordinate to [0,0]
	# PickUpState == 1, Hover Up
	# PickUpState == 2, Hover Down

	beq $t1, 1, HoverUp2
	beq $t1, 2, HoverDown2
	beq $t1, 4, Collected2
	# Write the 1.erase part in the collision detection part, also 2.set the coordinate to [0,0] there
	# 3. Update state to collected

	#Collected branch should do nothing and jump to next step directly

HoverUp2:
	# ErasePickUp2
	la $t1, PickUp2CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp

	# UpdateCurrentCoordinate to Up
	la $t1, PickUp2CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	addi $t3, $t3, -1
	sw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3

	# DrawPickUp2
	jal DrawPickUp

	# Update PickUp2 State
	la $t0, PickUpState2
	li $t1, 2
	sw $t1, 0($t0) # set to 2 hoverdown



	# Branch to next step (Check for next pick Up)
	j PU3




HoverDown2:
	# ErasePickUp2
	la $t1, PickUp2CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp

	# UpdateCurrentCoordinate to Up
	la $t1, PickUp2CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	addi $t3, $t3, 1
	sw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3

	# DrawPickUp2
	jal DrawPickUp

	# Update PickUp2 State
	la $t0, PickUpState2
	li $t1, 1
	sw $t1, 0($t0) # set to 1 hoverUp


	# Branch to next step (Check for next pick Up)
	j PU3





Collected2:
	j PU3


PU3:
	la $t0, PickUpState3
	lw $t1, 0($t0)

	# PickUpState == 4, Collected. Erase and set coordinate to [0,0]
	# PickUpState == 1, Hover Up
	# PickUpState == 2, Hover Down

	beq $t1, 1, HoverUp3
	beq $t1, 2, HoverDown3
	beq $t1, 4, Collected3
	# Write the 1.erase part in the collision detection part, also 2.set the coordinate to [0,0] there
	# 3. Update state to collected

	#Collected branch should do nothing and jump to next step directly

HoverUp3:
	# ErasePickUp3
	la $t1, PickUp3CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp

	# UpdateCurrentCoordinate to Up
	la $t1, PickUp3CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	addi $t3, $t3, -1
	sw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3

	# DrawPickUp3
	jal DrawPickUp

	# Update PickUp3 State
	la $t0, PickUpState3
	li $t1, 2
	sw $t1, 0($t0) # set to 2 hoverdown

	# Branch to next step (Check for next pick Up)
	j Step5




HoverDown3:
	# ErasePickUp3
	la $t1, PickUp3CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp

	# UpdateCurrentCoordinate to Up
	la $t1, PickUp3CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	addi $t3, $t3, 1
	sw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3

	# DrawPickUp3
	jal DrawPickUp

	# Update PickUp3 State
	la $t0, PickUpState3
	li $t1, 1
	sw $t1, 0($t0) # set to 1 hoverUp

	# Branch to next step (Check for next pick Up)
	j Step5






Collected3:

	j Step5













Step5: # Check_Keyboard_input
	Check_Keyboard_input:
		li $t9, 0xffff0000
		lw $t8, 0($t9)
		beq $t8, 1, keypress_happened

		j Step6

		keypress_happened:
			lw $t2, 4($t9) 			# this assumes $t9 is set to 0xfff0000 from before
			beq $t2, 0x77, respond_to_w 	# ASCII code of 'w' is 0x77 or 119 in decimal
			beq $t2, 0x61, respond_to_a 	# ASCII code of 'a' is 0x61 or 97 in decimal
			#beq $t2, 0x73, respond_to_s 	# ASCII code of 's' is 0x73 or 115 in decimal
			beq $t2, 0x64, respond_to_d 	# ASCII code of 'd' is 0x64 or 100 in decimal
			beq $t2, 0x72, Restart 		# ASCII code of 'r' is 0x72 or 114 in decimal
			beq $t2, 0x71, QuitGame 	# ASCII code of 'q' is 0x71 or 113 in decimal
	# in the case of capital letters
			beq $t2, 0x57, respond_to_w 	# ASCII code of 'W' is 0x57 or 87 in decimal
			beq $t2, 0x41, respond_to_a 	# ASCII code of 'A' is 0x41 or 65 in decimal
			#beq $t2, 0x53, respond_to_s 	# ASCII code of 'S' is 0x53 or 83 in decimal
			beq $t2, 0x44, respond_to_d 	# ASCII code of 'D' is 0x44 or 68 in decimal
			beq $t2, 0x52, Restart 		# ASCII code of 'R' is 0x52 or 82 in decimal
			beq $t2, 0x51, QuitGame 	# ASCII code of 'Q' is 0x51 or 81 in decimal

	##################################### Check Keyboard Input Part

respond_to_w:
#######################  Main Character Jump ###################
IFJUMP:
# Check Ground
	la $t1, Collison_with_Ground_Signal
	lw $t6, 0($t1)
	# on_the_ground == 0 -> suspend respond_to_s;(no respond_to_s all the time?)
	# in the air, could double jump == 1
	# has double jumped == 2 -> suspend respond_to_w
	beq $t6, 0, JUMP
	beq $t6, 1, DOUBLEJUMP
	# or next line in the mainloop
	beq $t6, 2, Step6


JUMP:
	## Start Jumping ####

	# change the SIGNAL TO 1
	la $t1, Collison_with_Ground_Signal
	addi $t2, $zero, 1

	sw $t2, 0($t1)


	# Erase Current Main Character
	jal EraseMainCharacter

	# Base Address =  current base address $t2 + 256 * JumpRate
	#li $t5, JumpRate
	#li $t0, -256
	#mult $t0, $t5
	#mflo $t5


	# the multiply for 2 part does not make sense.
	# li $t1, 2

	# mult $t5, $t2
	# mflo $t2


	#la $t7, MainCharacterCurrentAddress
	#lw $t6, 0($t7)
	# blt $t6, $t5, END
	# add $t2, $t6, $t2

	# Current Address of main character
	#add $t6, $t6, $t5

	# Store the new main character address
	#sw $t6, 0($t7)

	# Update Coordinate
	la $t3, MainCharacterCurrentCoordinate
	lw $t4, 0($t3)
	lw $t5, 4($t3)
	li $t6, JumpRate
	sub $t5, $t5, $t6
	sw $t5, 4($t3)

	# Draw new main character

	jal DrawCharacter

	la $t2, MainCharacterState
	li $t3, 2 # Set to FallingState
	sw $t3, 0($t2)

	# Jump to the next line in the mainloop?
	j Step6


DOUBLEJUMP:
	## Start Double Jumping ####

	# change the SIGNAL TO 2
	la $t1, Collison_with_Ground_Signal
	addi $t2, $zero, 2

	sw $t2, 0($t1)


	# Erase Current Main Character
	jal EraseMainCharacter

	# Base Address =  current base address $t2 + 256 * JumpRate
	#li $t5, JumpRate
	#li $t0, -256
	#mult $t0, $t5
	#mflo $t5


	# the multiply for 2 part does not make sense.
	# li $t1, 2

	# mult $t5, $t2
	# mflo $t2


	#la $t7, MainCharacterCurrentAddress
	#lw $t6, 0($t7)
	# blt $t6, $t5, END
	# add $t2, $t6, $t2

	# Current Address of main character
	#add $t6, $t6, $t5

	# Store the new main character address
	#sw $t6, 0($t7)

	# Update Coordinate
	la $t3, MainCharacterCurrentCoordinate
	lw $t4, 0($t3)
	lw $t5, 4($t3)
	li $t6, JumpRate
	sub $t5, $t5, $t6
	sw $t5, 4($t3)


	# Draw new main character

	jal DrawCharacter

	la $t2, MainCharacterState
	li $t3, 2 # Set to FallingState
	sw $t3, 0($t2)


	# Jump to the next line in the mainloop?
	j Step6

######################################################## Respond toW <--------------

respond_to_a:
################# Main Character Move Left ##################

MoveLeft:

	# Check if collide with Left wall, if so branch to next step
	la $t1, MainCharacterCurrentCoordinate
	lw $t2, 0($t1)	#X
	lw $t3, 4($t1)

	# if x less than or equal to 2 + move rate, then collide  MainCharacterMovingRate

	ble $t2, 4, CollideLeftWall


	# Check if in the NO GO Zone

	# ...!



	# if in the no go zone, branch to next step directly


	# Erase Current Main Character
	jal EraseMainCharacter


	# Update Coordinate
	# Get Current Coordinate
	la $t1, MainCharacterCurrentCoordinate
	lw $t2, 0($t1)
	lw $t3, 4($t1)
	# Update to new Coordinate x = x-1
	subi $t2, $t2, MainCharacterMovingRate
	sw $t2, 0($t1)

	jal DrawCharacter

	j Step6

CollideLeftWall:
	la $t1, Collision_with_Wall_Signal
	li $t2, 1
	sw $t2, 0($t1)

	j Step6

###############################################################





respond_to_d:
################# Main Character Move Right ##################

MoveRight:

	# Check if collide with wall, if so branch to next step
	la $t1, MainCharacterCurrentCoordinate
	lw $t2, 0($t1)	#X
	lw $t3, 4($t1)

	bge $t2, 60, CollideRightWall


	# Check if in the NO GO Zone

	# if in the no go zone, branch to next step directly



	# Erase Current Main Character
	jal EraseMainCharacter


	# UpdateCoordinate
	# Update Coordinate
	# Get Current Coordinate
	la $t1, MainCharacterCurrentCoordinate
	lw $t2, 0($t1)
	lw $t3, 4($t1)
	# Update to new Coordinate x = x+1
	addi $t2, $t2, MainCharacterMovingRate
	sw $t2, 0($t1)





	# Draw new main character

	jal DrawCharacter

	j Step6

CollideRightWall:
	la $t1, Collision_with_Wall_Signal
	li $t2, 2
	sw $t2, 0($t1)

	j Step6

###############################################################
##################################### Respond to keyboard


Step6: # Detect Ground

DetectGroundS:
		# if MainCharacter's Coordinate Y == 63 or 51 or 39
		# if Y == 63, ground detected
		# if Y == 51, X in the range [14, 50]
		# then floating ground detected
		# if Y == 39,


		# Get Main Character's Current Coordinate
		la $t1, MainCharacterCurrentCoordinate
		lw $t2, 0($t1)
		lw $t3, 4($t1)

##### Check if on moving platform B
		blt $t2, 47, KeepLogic
		bgt $t2, 62, KeepLogic

ComparePlat2Y:
		la $t4, MovingPlatformState2
		lw $t5, 0($t4)

		la $t6, MovingPlatform2CurrentCoordinateA
		lw $t7, 4($t6)

		beq $t5, 1, UpdateMCRCoordinate
		j KeepLogic

	UpdateMCRCoordinate:

		# if moving up, Y1 - Y2 less than or equal to 1, then detect ground?
		sub $t2, $t3, $t7
		bge $t2, $zero, CheckDelta
		j KeepLogic

	CheckDelta:
		bgt $t2, 1, KeepLogic

		jal EraseMainCharacter

		la $t1, MainCharacterCurrentCoordinate
		lw $t3, 4($t1)

		la $t6, MovingPlatform2CurrentCoordinateA
		lw $t7, 4($t6)


		addi $t3, $t7, -1
		sw $t3, 4($t1)
		# AND redraw the main CR
		jal DrawCharacter

		#Also redraw the platform 2
		jal DrawMovingPlatformB



		# Set main character current coordinate to Y1 = Y2 + 1

		# if moving down, do Nothing?


########
KeepLogic:
		la $t1, MainCharacterCurrentCoordinate
		lw $t2, 0($t1)
		lw $t3, 4($t1)
		# IF FALLING RATE == 1
		# Y = Y + 1
		addi $t3, $t3,1


			# Check X = X - 1
			addi $t4, $t2, -1
			# Calculate Address
			move $a0, $t4
			move $a1, $t3
			jal CalculateAddress
			move $t4, $v0
				# Get t5 as the address
				lw $t5, 0($t4)
				li $t6, Black
				li $t7, PlatformGreen
				beq $t5, $t7, GroundDetected
				beq $t5, $t6, GroundNotDetected

		# Check X = X + 1
		# Get Main Character's Current Coordinate
		la $t1, MainCharacterCurrentCoordinate
		lw $t2, 0($t1)
		lw $t3, 4($t1)

		# IF FALLING RATE == 1
		# Y = Y + 1
		addi $t3, $t3,1
		addi $t4, $t2, 1

		# Calculate Address
		move $a0, $t2
		move $a1, $t3
		jal CalculateAddress
		move $t4, $v0

		lw $t5, 0($t4)
		li $t6, Black
		li $t7, PlatformGreen
		beq $t5, $t6, GroundNotDetected
		beq $t5, $t7, GroundDetected

		# jr $ra
######
GroundDetected:
	la $t1, Collison_with_Ground_Signal
	sw $zero, 0($t1)
	# jr $ra
	la $t2, MainCharacterState
	sw $zero, 0($t2)

	j Step7
############################
GroundNotDetected:

	la $t2, MainCharacterState
	li $t3, 2        # Set to fallingState
	sw $t3, 0($t2)

FallingState:
	la $t2, MainCharacterState
	lw $t3, 0($t2)
	beq $t3, 2, FallDown

	j Step7
FallDown:
	# Get Current MainCharacterCoordinate


	#move $a0, $t2
	#move $a1, $t3
	#jal CalculateAddress
	#move $


	# Erase Current Main Character
	jal EraseMainCharacter
	# Get Current Coordinate
	la $t1, MainCharacterCurrentCoordinate
	lw $t2, 0($t1)
	lw $t3, 4($t1)
	# Update to new Coordinate
	addi $t3, $t3, FallingRate
	sw $t3, 4($t1)

	# Draw new main character
	jal DrawCharacter

	j Step7



Restart:
	jal ClearScreenSetup
	j main

QuitGame:

	jal ClearScreenSetup

	j END
############################################################################
Step7: # Detect_Collison_with_PickUps

CheckP1:
	la $t1, MainCharacterCurrentCoordinate
	la $t2, PickUp1CoordinateXY

	lw $t3, 0($t1)  # X1 main CR
	lw $t4, 4($t1)	# Y1 MainCR

	lw $t5, 0($t2)	#X2
	lw $t6, 4($t2)	#Y2

	# X1 - X2 less than or equal to 3, depends on which on is bigger

	# AND Y2 - Y1 is less than or equal to 3 Or Y1 - Y2 is less than or equal to 1
	CheckP1X:
	bge $t3, $t5, AtRight1
	ble $t3, $t5, AtLeft1

AtRight1:

	sub $t1, $t3, $t5
	ble $t1, 3, CheckP1Y

	j CheckP2

AtLeft1:
	sub $t1, $t5, $t3
	ble $t1, 3, CheckP1Y

	j CheckP2


CheckP1Y:
	bgt $t4, $t6, Down1
	blt $t4, $t6, AirUp1
Down1:
	sub $t7, $t4, $t6
	ble $t7, 1, CollisionPickUp1

	j CheckP2

AirUp1:
	sub $t7, $t6, $t4
	ble $t7, 3, CollisionPickUp1

	j CheckP2

CollisionPickUp1:
	# Erase PickUp and Set PickUp state to 4

	# ErasePickUp1
	la $t1, PickUp1CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp

	# Update state to 4
	la $t0, PickUpState1
	li $t4, 4
	sw $t4, 0($t0)

	# Set its coordinate to [0,0]

	la $t1, PickUp1CoordinateXY
	sw $zero, 0($t1)
	sw $zero, 4($t1)

	# Set NumCollected to NumCollected ++
	la $t1, NumCollected
	lw $t2, 0($t1)
	addi $t2, $t2, 1
	sw $t2, 0($t1)

	# FillScoreBox --> NumFilled ++

	# Call FillScoreBox Function
	jal FillScoreBox


	la $t1, NumFilled
	lw $t2, 0($t1)
	addi $t2, $t2, 1
	sw $t2, 0($t1)


	# Check NumFilled, if == 3, Update Game State to YOU WON == 2

	beq $t2, 3, UpdateToWin
	j Step8

	UpdateToWin:
	# Set GameState to You Won

	la $t1, GameState
	li $t2, 2	# 2 as Win
	sw $t2, 0($t1)

	# branch to
	j DrawYouWinPage


######

CheckP2:
	la $t1, MainCharacterCurrentCoordinate
	la $t2, PickUp2CoordinateXY

	lw $t3, 0($t1)  # X1 main CR
	lw $t4, 4($t1)	# Y1 MainCR

	lw $t5, 0($t2)	#X2
	lw $t6, 4($t2)	#Y2

	# X1 - X2 less than or equal to 3, depends on which on is bigger

	# AND Y2 - Y1 is less than or equal to 3 Or Y1 - Y2 is less than or equal to 1
	CheckP2X:
	bge $t3, $t5, AtRight2
	ble $t3, $t5, AtLeft2

AtRight2:

	sub $t1, $t3, $t5
	ble $t1, 3, CheckP2Y

	j CheckP3

AtLeft2:
	sub $t1, $t5, $t3
	ble $t1, 3, CheckP2Y

	j CheckP3


CheckP2Y:
	bgt $t4, $t6, Down2
	blt $t4, $t6, AirUp2
Down2:
	sub $t7, $t4, $t6
	ble $t7, 1, CollisionPickUp2

	j CheckP3

AirUp2:
	sub $t7, $t6, $t4
	ble $t7, 3, CollisionPickUp2

	j CheckP3

CollisionPickUp2:
	# Erase PickUp and Set PickUp state to 4

	# ErasePickUp1
	la $t1, PickUp2CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp

	# Update state to 4
	la $t0, PickUpState2
	li $t4, 4
	sw $t4, 0($t0)

	# Set its coordinate to [0,0]

	la $t1, PickUp2CoordinateXY
	sw $zero, 0($t1)
	sw $zero, 4($t1)

	# Set NumCollected to NumCollected ++
	la $t1, NumCollected
	lw $t2, 0($t1)
	addi $t2, $t2, 1
	sw $t2, 0($t1)

	# FillScoreBox --> NumFilled ++

	# Call FillScoreBox Function
	jal FillScoreBox


	la $t1, NumFilled
	lw $t2, 0($t1)
	addi $t2, $t2, 1
	sw $t2, 0($t1)


	# Check NumFilled, if == 3, Update Game State to YOU WON == 2

	beq $t2, 3, UpdateToWin
	j Step8

	#UpdateToWin:
	# Set GameState to You Won

	la $t1, GameState
	li $t2, 2	# 2 as Win
	sw $t2, 0($t1)

	# branch to GameOverPage
	j DrawYouWinPage



##########
######

CheckP3:
	la $t1, MainCharacterCurrentCoordinate
	la $t2, PickUp3CoordinateXY

	lw $t3, 0($t1)  # X1 main CR
	lw $t4, 4($t1)	# Y1 MainCR

	lw $t5, 0($t2)	#X2
	lw $t6, 4($t2)	#Y2

	# X1 - X2 less than or equal to 3, depends on which on is bigger

	# AND Y2 - Y1 is less than or equal to 3 Or Y1 - Y2 is less than or equal to 1
	CheckP3X:
	bge $t3, $t5, AtRight3
	ble $t3, $t5, AtLeft3

AtRight3:

	sub $t1, $t3, $t5
	ble $t1, 3, CheckP3Y

	j Step8

AtLeft3:
	sub $t1, $t5, $t3
	ble $t1, 3, CheckP3Y

	j Step8


CheckP3Y:
	bgt $t4, $t6, Down3
	blt $t4, $t6, AirUp3
Down3:
	sub $t7, $t4, $t6
	ble $t7, 1, CollisionPickUp3

	j Step8

AirUp3:
	sub $t7, $t6, $t4
	ble $t7, 3, CollisionPickUp3

	j Step8

CollisionPickUp3:
	# Erase PickUp and Set PickUp state to 4

	# ErasePickUp1
	la $t1, PickUp3CoordinateXY
	lw $t2, 0($t1)
	lw $t3, 4($t1)



	move $a0, $t2
	move $a1, $t3

	jal ErasePickUp

	# Update state to 4
	la $t0, PickUpState3
	li $t4, 4
	sw $t4, 0($t0)

	# Set its coordinate to [0,0]

	la $t1, PickUp3CoordinateXY
	sw $zero, 0($t1)
	sw $zero, 4($t1)

	# Set NumCollected to NumCollected ++
	la $t1, NumCollected
	lw $t2, 0($t1)
	addi $t2, $t2, 1
	sw $t2, 0($t1)

	# FillScoreBox --> NumFilled ++
	jal FillScoreBox

	# Call FillScoreBox Function

	la $t1, NumFilled
	lw $t2, 0($t1)
	addi $t2, $t2, 1
	sw $t2, 0($t1)


	# Check NumFilled, if == 3, Update Game State to YOU WON == 2

	beq $t2, 3, UpdateToWin
	j Step8

	#UpdateToWin:
	# Set GameState to You Won

	la $t1, GameState
	li $t2, 2	# 2 as Win
	sw $t2, 0($t1)

	# branch to GameOverPage
	j DrawYouWinPage












Step8: # Detect Collision with Enemie
	la $t1, MainCharacterCurrentCoordinate
	la $t2, EnemieCurrentCoordinate

	lw $t3, 0($t1)  # X1 main CR
	lw $t4, 4($t1)	# Y1 MainCR

	lw $t5, 0($t2)	#X2
	lw $t6, 4($t2)	#Y2

	# Check for Y1 -Y2 less than or euqal to 1 first
	# Check which one is great first then sub and compare with 1

	# bgt $t4, $t6, Down
	# blt $t4, $t6, Up

	sub $t7, $t6, $t4
	# if t7 less than or equal to 1
	ble $t7, 1, YCloseCheckX

	j Step9



YCloseCheckX:
	# check if X1-X2 less than or equal to 5
	# check for greater or smaller, then great minus small

	bgt $t3, $t5, AtRight
	blt $t3, $t5, AtLeft
AtRight:

	sub $t1, $t3, $t5
	ble $t1, 5, EnemieCollision

	j Step9



AtLeft:
	sub $t1, $t5, $t3
	ble $t1, 5, EnemieCollision

	j Step9

EnemieCollision:
	# Set GameState to Lose

	la $t1, GameState
	li $t2, 3	# 3 as LOSE
	sw $t2, 0($t1)

	# branch to GameOverPage
	j GameOverPage



Step9: # Check if there is any signals or states





Step10: # Sleep for a while and j back to mainLoop
	Sleep:
	# sleep for a short time
	li $v0, 32
	li $a0, Sleeptime			# Wait one second (1000 milliseconds)
	syscall

	# loop again
	j mainLoop



DrawYouWinPage:
	jal ClearScreenSetup
	j DrawYouWin
	j END


GameOverPage:
	jal ClearScreenSetup

	j DrawGameOverPage

	#j END












	###################################################################################################################

END:
	#exit program
	li $v0, 10
	syscall





#####################################################################################

Functions:


########################### Clear Screen Block ###################
# 1.

ClearScreenSetup:
	# Draw the Entire Screen to Black
	li $t0, BASE_ADDRESS
	li $t7, Black
	li $t3, GBM
	move $t2, $zero
	move $t1, $t0

ClearScreen:
	bgt $t2, $t3, DoneClear

	add $t1, $t0, $t2
	sw $t7, 0($t1)
	addi $t2, $t2, 4

	j ClearScreen
DoneClear:
	jr $ra
# 1. Clear Screen Function
########################## Clear Screen FUNCTION Block ##########




######################### CALCULATE ADDRESS FUNCTION BLOCK###########
#   2.


CalculateAddress:
	# Take a0 = X and a1 = Y
	# Get Base Address
	li $t0, BASE_ADDRESS

	# offset = (Y * 64 + X )* 4
	addi $t1, $zero, 64
	mult $a1, $t1
	mflo $t1
	add $t1, $t1, $a0
	addi $t2, $zero, 4
	mult $t1, $t2
	mflo $t1

	add $t1, $t1, $t0
	move $v0, $t1

	jr $ra
# 2. CALCULATE ADDRESS FUNCTION
#####################################################

########### DrawEnemie Function ###########--------->
# 3.
# This function takes

DrawEnemie:

	# Push the current $ra value to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# Get Current Base Coordinator from , and calculate Base Address (save to $t1)
	la $t0, EnemieCurrentCoordinate
	lw $t1, 0($t0)
	lw $t2, 4($t0)

	move $a0, $t1
	move $a1, $t2
	jal CalculateAddress
	move $t1, $v0


	# Get Colors
	li $t7, EMGrey
	li $t6, EMRed
	li $t5, EMdarkblue
	# Draw Bottom layer (1)
	sw $t7, 0($t1)
	sw $t7, 8($t1)
	sw $t7, 12($t1)
	sw $t7, -8($t1)
	sw $t7, -12($t1)
	sw $t5, 4($t1)
	sw $t5, -4($t1)
	# Draw Layer (2)
	sw $t6, -252($t1)
	sw $t6, -260($t1)
	sw $t7, -248($t1)
	sw $t7, -264($t1)
	#  lw $t7, 0($t1)   Black no need to draw

	# Draw Layer (3)
	sw $t7, -516($t1)
	sw $t7, -508($t1)
	#lw $t7, 0($t1)     Black no need to draw

	# Draw Layer (4)
	sw $t7, -768($t1)

# Get(pop) the stored $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4


	# Jump Back to Caller
	jr $ra


# 3.
################ The Draw Enemie Function <-------------------------------

######### Erase Enemie Function ######---------------->
#4.
EraseCurrentEnemie:
	# Push the current $ra value to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# Get Current Base Coordinator from , and calculate Base Address (save to $t1)
	la $t0, EnemieCurrentCoordinate
	lw $t1, 0($t0)
	lw $t2, 4($t0)

	move $a0, $t1
	move $a1, $t2
	jal CalculateAddress
	move $t1, $v0

	# t1 be the base address
	li $t6, Black
	# Erase Bottom layer (1)
	sw $t6, 0($t1)
	sw $t6, 8($t1)
	sw $t6, 12($t1)
	sw $t6, -8($t1)
	sw $t6, -12($t1)
	sw $t6, 4($t1)
	sw $t6, -4($t1)
	# Erase Layer (2)
	sw $t6, -252($t1)
	sw $t6, -260($t1)
	sw $t6, -248($t1)
	sw $t6, -264($t1)
	#  sw $t7, 0($t1)   Black no need to draw

	# Draw Layer (3)
	sw $t6, -516($t1)
	sw $t6, -508($t1)
	#s w$t7, 0($t1)     Black no need to draw

	# Erase Layer (4)
	sw $t6, -768($t1)

	# Get(pop) the stored $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	# jump back to caller
	jr $ra

#4.
###################    Erase Enemie Function <-----------------------

#########  Main Character Drawing Function #########################----->
# 5.
DrawCharacter:
	# Push the Current $ra to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	la $t1, MainCharacterCurrentCoordinate
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t2, $v0

	# t2 as the base address


	li $t5, CRLightBlue
	li $t6, CRLightGreen

	# Draw Middle Line
	sw $t5, 0($t2)
	sw $t5, -256($t2)
	sw $t5, -512($t2)
	sw $t5, -768($t2)
	sw $t6, -1024($t2)
	sw $t6, -1280($t2)
	sw $t6, -1536($t2)
	sw $t5, -1792($t2)
	sw $t5, -2048($t2)

	sw $t5, 4($t2)
	sw $t5, -772($t2)
	sw $t6, -1276($t2)
	sw $t5, -1540($t2)
	sw $t5, -1796($t2)

	sw $t5, -4($t2)
	sw $t5, -764($t2)
	sw $t6, -1284($t2)
	sw $t5, -1532($t2)
	sw $t5, -1788($t2)

	# Finish Drawing

	# Pop the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	# Back to caller
	jr $ra
# 5.
######################################################<------------Main Character Drawing Function

########### Erase Main Character #########################
# 6.
EraseMainCharacter:
	# t2 as the base address

	# Push the Current $ra to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	la $t1, MainCharacterCurrentCoordinate
	lw $t2, 0($t1)
	lw $t3, 4($t1)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t2, $v0

	# t2 as the base address
	# Draw Middle Line
	li $t5, Black
	sw $t5, 0($t2)
	sw $t5, -256($t2)
	sw $t5, -512($t2)
	sw $t5, -768($t2)
	sw $t5, -1024($t2)
	sw $t5, -1280($t2)
	sw $t5, -1536($t2)
	sw $t5, -1792($t2)
	sw $t5, -2048($t2)

	sw $t5, 4($t2)
	sw $t5, -772($t2)
	sw $t5, -1276($t2)
	sw $t5, -1540($t2)
	sw $t5, -1796($t2)

	sw $t5, -4($t2)
	sw $t5, -764($t2)
	sw $t5, -1284($t2)
	sw $t5, -1532($t2)
	sw $t5, -1788($t2)

	# Finish Drawing

	# Pop the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
# 6.
############################# Erase MainCharacter <--------------

################### Draw Pick Up Function  ################
# 7.
DrawPickUp:

	# push the current ra to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0

	li $t5, Yellow
	sw $t5, 0($t4)
	sw $t5, -260($t4)
	sw $t5, -252($t4)
	sw $t5, -512($t4)
	sw $t5, -764($t4)
	sw $t5, -772($t4)

	# pop the ra from the stack and jump back to caller
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra


# 7.
########################################

######################## Erase Pick Up Function ###################
# 8.
ErasePickUp:

	# push the current ra to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	move $a0, $t2
	move $a1, $t3
	jal CalculateAddress
	move $t4, $v0

	li $t5, Yellow
	li $t6, Black

Erase1:
	lw $t7, 0($t4)
	bne $t7, $t5, Erase2
	sw $t6, 0($t4)

Erase2:

	lw $t7, -260($t4)
	bne $t7, $t5, Erase3
	sw $t6, -260($t4)


Erase3:

	lw $t7, -252($t4)
	bne $t7, $t5, Erase4
	sw $t6, -252($t4)


Erase4:

	lw $t7, -512($t4)
	bne $t7, $t5, Erase5
	sw $t6, -512($t4)


Erase5:

	lw $t7, -764($t4)
	bne $t7, $t5, Erase6
	sw $t6, -764($t4)


Erase6:

	lw $t7, -772($t4)
	bne $t7, $t5, DoneE
	sw $t6, -772($t4)


DoneE:

	# pop the ra from the stack and jump back to caller
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra



# 8.
##################################################################

################### Fill Score Box Function #######################
# 9.
FillScoreBox:
	# push ra onto the stack

	addi $sp, $sp, -4
	sw $ra, 0($sp)


# Check which score box to fill by Check NumCollected
# then choose the correct coordinate
# calculate address and start filling

	la $t1, NumCollected
	lw $t2, 0($t1)
	# FillScoreBox1Coordinate
	beq $t2, 1, Fill1
	beq $t2, 2, Fill2
	beq $t2, 3, Fill3

Fill1:
	la $t3, FillScoreBox1Coordinate
	lw $t4, 0($t3)
	lw $t5, 4($t3)

	move $a0, $t4
	move $a1, $t5

	jal CalculateAddress
	move $t4, $v0

	li $t6, Yellow
	sw $t6, 0($t4)
	sw $t6, 4($t4)
	sw $t6, 8($t4)
	sw $t6, 12($t4)

	sw $t6, 256($t4)
	sw $t6, 260($t4)
	sw $t6, 264($t4)
	sw $t6, 268($t4)

	sw $t6, 512($t4)
	sw $t6, 516($t4)
	sw $t6, 520($t4)
	sw $t6, 524($t4)

	sw $t6, 768($t4)
	sw $t6, 772($t4)
	sw $t6, 776($t4)
	sw $t6, 780($t4)

	j DoneFilling

Fill2:
	la $t3, FillScoreBox2Coordinate
	lw $t4, 0($t3)
	lw $t5, 4($t3)

	move $a0, $t4
	move $a1, $t5

	jal CalculateAddress
	move $t4, $v0

	li $t6, Yellow
	sw $t6, 0($t4)
	sw $t6, 4($t4)
	sw $t6, 8($t4)
	sw $t6, 12($t4)

	sw $t6, 256($t4)
	sw $t6, 260($t4)
	sw $t6, 264($t4)
	sw $t6, 268($t4)

	sw $t6, 512($t4)
	sw $t6, 516($t4)
	sw $t6, 520($t4)
	sw $t6, 524($t4)

	sw $t6, 768($t4)
	sw $t6, 772($t4)
	sw $t6, 776($t4)
	sw $t6, 780($t4)

	j DoneFilling

Fill3:
	la $t3, FillScoreBox3Coordinate
	lw $t4, 0($t3)
	lw $t5, 4($t3)

	move $a0, $t4
	move $a1, $t5

	jal CalculateAddress
	move $t4, $v0

	li $t6, Yellow
	sw $t6, 0($t4)
	sw $t6, 4($t4)
	sw $t6, 8($t4)
	sw $t6, 12($t4)

	sw $t6, 256($t4)
	sw $t6, 260($t4)
	sw $t6, 264($t4)
	sw $t6, 268($t4)

	sw $t6, 512($t4)
	sw $t6, 516($t4)
	sw $t6, 520($t4)
	sw $t6, 524($t4)

	sw $t6, 768($t4)
	sw $t6, 772($t4)
	sw $t6, 776($t4)
	sw $t6, 780($t4)

	j DoneFilling

DoneFilling:

	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra




# 9.
####3######################### Fill Score Box <-------------------

########### DrawMovingPlatformFUNCTION --------------------->
# 10. a
DrawMovingPlatformA:
	# push the ra to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)



	# Set up Platform length and Moving Ranges
	la $t1, MovingPlatformCurrentCoordinateA
	# Load X coordinate
	lw $t2, 0($t1)
	# Load Y coordinate
	lw $t3, 4($t1)
	# Calculate Address
	move $a0, $t2
	move $a1, $t3

	jal CalculateAddress
	move $t4, $v0

	# Get endpoint
	la $t5, MovingPlatformCurrentCoordinateB
	# Load X coordinate
	lw $t6, 0($t5)
	# Load Y coordinate
	lw $t7, 4($t5)
	# Calculate Address
	move $a0, $t6
	move $a1, $t7
	jal CalculateAddress
	move $t0, $v0

StartDrawingMovingA:

	li $t7, PlatformGreen
DrawMovingPlatI:
	bgt $t4, $t0, DoneDrawA
	sw $t7, 0($t4)

	addi $t4, $t4, 4
	j DrawMovingPlatI

DoneDrawA:

	# pop ra off the stack and jump back to caller
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra





# 10.a
############################### DrawMovingPlatformFunction <-----------------

########### DrawMovingPlatform2FUNCTION --------------------->
# 10.b
DrawMovingPlatformB:
	# push the ra to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)



	# Set up Platform length and Moving Ranges
	la $t1, MovingPlatform2CurrentCoordinateA
	# Load X coordinate
	lw $t2, 0($t1)
	# Load Y coordinate
	lw $t3, 4($t1)
	# Calculate Address
	move $a0, $t2
	move $a1, $t3

	jal CalculateAddress
	move $t4, $v0

	# Get endpoint
	la $t5, MovingPlatform2CurrentCoordinateB
	# Load X coordinate
	lw $t6, 0($t5)
	# Load Y coordinate
	lw $t7, 4($t5)
	# Calculate Address
	move $a0, $t6
	move $a1, $t7
	jal CalculateAddress
	move $t0, $v0

StartDrawingMovingB:

	li $t7, PlatformGreen
DrawMovingPlatII:
	bgt $t4, $t0, DoneDrawB
	sw $t7, 0($t4)

	addi $t4, $t4, 4
	j DrawMovingPlatII

DoneDrawB:

	# pop ra off the stack and jump back to caller
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra













# 10.b
############################### DrawMovingPlatform2Function <-----------------



########### EraseMovingPlatformFUNCTION --------------------->
# 11.a
EraseMovingPlatformA:
	# push the ra to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)



	# Set up Platform length and Moving Ranges
	la $t1, MovingPlatformCurrentCoordinateA
	# Load X coordinate
	lw $t2, 0($t1)
	# Load Y coordinate
	lw $t3, 4($t1)
	# Calculate Address
	move $a0, $t2
	move $a1, $t3

	jal CalculateAddress
	move $t4, $v0

	# Get endpoint
	la $t5, MovingPlatformCurrentCoordinateB
	# Load X coordinate
	lw $t6, 0($t5)
	# Load Y coordinate
	lw $t7, 4($t5)
	# Calculate Address
	move $a0, $t6
	move $a1, $t7
	jal CalculateAddress
	move $t0, $v0

StartEraseMovingA:

	li $t7, Black
EraseMovingPlatI:
	bgt $t4, $t0, DoneEraseA
	sw $t7, 0($t4)

	addi $t4, $t4, 4
	j EraseMovingPlatI

DoneEraseA:

	# pop ra off the stack and jump back to caller
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra







# 11.a
############################### EraseMovingPlatformFunction <-----------------

########### EraseMovingPlatformFUNCTION --------------------->
# 11.b

EraseMovingPlatformB:
	# push the ra to the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)



	# Set up Platform length and Moving Ranges
	la $t1, MovingPlatform2CurrentCoordinateA
	# Load X coordinate
	lw $t2, 0($t1)
	# Load Y coordinate
	lw $t3, 4($t1)
	# Calculate Address
	move $a0, $t2
	move $a1, $t3

	jal CalculateAddress
	move $t4, $v0

	# Get endpoint
	la $t5, MovingPlatform2CurrentCoordinateB
	# Load X coordinate
	lw $t6, 0($t5)
	# Load Y coordinate
	lw $t7, 4($t5)
	# Calculate Address
	move $a0, $t6
	move $a1, $t7
	jal CalculateAddress
	move $t0, $v0

StartEraseMovingB:

	li $t7, Black
EraseMovingPlatII:
	bgt $t4, $t0, DoneEraseB
	sw $t7, 0($t4)

	addi $t4, $t4, 4
	j EraseMovingPlatII

DoneEraseB:

	# pop ra off the stack and jump back to caller
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra

# 11.b
############################### EraseMovingPlatformFunction <-----------------



# Finished Draw Main Game Functions

# Signal and Control Functions Starts Here


###########  --------------------->
# 12.











# 12.
###############################      <-----------------


################3 Draw YOU WON PAGE#################
DrawYouWin:

	la $t2, DrawYouWinCoordinate
	lw $t3, 0($t2)
	lw $t4, 4($t2)

	move $a0, $t3
	move $a1, $t4
	jal CalculateAddress
	move $t5, $v0

	li $t1, CRLightBlue
	# Start Y
	sw $t1, 0($t5)
	#2
	addi $t5, $t5, 260
	sw $t1, 0($t5)
	#3
	addi $t5, $t5, 260
	sw $t1, 0($t5)
	#4
	addi $t5, $t5, -252
	sw $t1, 0($t5)
	#5
	addi $t5, $t5, -252
	sw $t1, 0($t5)
	#6
	addi $t5, $t5, 1016
	sw $t1, 0($t5)
	#7  O starts here for you
	addi $t5, $t5, 28
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, -252
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -260
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	addi $t5, $t5, 252
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	# U starts here for you
	addi $t5, $t5, 32
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, 12
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 252
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	# O for won starts here
	addi $t5, $t5, 1792
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 252
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	addi $t5, $t5, -260
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	# N starts here for won
	addi $t5, $t5, 36
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, 512
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 12
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, 248
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)
	# ! starts here
	addi $t5, $t5, 40
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, 1536
	sw $t1, 0($t5)

	# W for won starts here

	addi $t5, $t5, -380
	sw $t1, 0($t5)

	addi $t5, $t5, -252
	sw $t1, 0($t5)

	addi $t5, $t5, -252
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -16
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, 16
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, -252
	sw $t1, 0($t5)

	addi $t5, $t5, -252
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

Check_RQ2:
		li $t9, 0xffff0000
		lw $t8, 0($t9)
		beq $t8, 1, keypress_happened2

		#j Sleep2

		keypress_happened2:
			lw $t2, 4($t9) 			# this assumes $t9 is set to 0xfff0000 from before
			beq $t2, 0x72, Restart 		# ASCII code of 'r' is 0x72 or 114 in decimal
			beq $t2, 0x71, QuitGame 	# ASCII code of 'q' is 0x71 or 113 in decimal
	# in the case of capital letters
			beq $t2, 0x52, Restart 		# ASCII code of 'R' is 0x52 or 82 in decimal
			beq $t2, 0x51, QuitGame 	# ASCII code of 'Q' is 0x51 or 81 in decimal

	##################################### Check Keyboard Input Part
	#Sleep2:
	#li $v0, 32
	#li $a0, Sleeptime			# Wait one second (1000 milliseconds)
	#syscall
	j Check_RQ2


	#j END

#####################################################

################# Draw Game Over Page ################

DrawGameOverPage:
	li $t0, BASE_ADDRESS
	li $t1, BoundaryPink

# [14, 22] -[18, 22] ; [23, 22] - [25, 22] ; [31, 23]-[35,23]; [41,22]-[43,22]
#
	la $t2, DrawGameOverCoordinate
	lw $t3, 0($t2)
	lw $t4, 4($t2)

	move $a0, $t3
	move $a1, $t4
	jal CalculateAddress
	move $t5, $v0
DrawPink:
	# Print G 1
	li $t1, BoundaryPink
	sw $t1, 0($t5)
	#2
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#3
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#4
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#5
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#6
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#7
	addi $t5, $t5, -16
	sw $t1, 0($t5)
	#8
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#9
	addi $t5, $t5, 512
	sw $t1, 0($t5)
	#10
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#11
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#12
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#13
	addi $t5, $t5, 260
	sw $t1, 0($t5)
	#14
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#15
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#16
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#17
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#18
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#19
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#20
	addi $t5, $t5, -4
	sw $t1, 0($t5)
	# Start print A #1
	addi $t5, $t5, 24
	sw $t1, 0($t5)
	#2
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#3
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#4
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#5
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#6
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#7
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#8
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#9
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#10
	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#11
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#12
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#13
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#14
	addi $t5, $t5, -4
	sw $t1, 0($t5)
	#15
	addi $t5, $t5, -4
	sw $t1, 0($t5)
	#16
	addi $t5, $t5, -4
	sw $t1, 0($t5)
	#17
	addi $t5, $t5, 252
	sw $t1, 0($t5)
	#18
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#19
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#20
	addi $t5, $t5, 16
	sw $t1, 0($t5)
	#21
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#22
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	# Start Printing M #1  STARTED FROM middle left corner
	addi $t5, $t5, 16
	sw $t1, 0($t5)
	#2
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#3
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#4
	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#5
	addi $t5, $t5, -252
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)
	#
	addi $t5, $t5, 260
	sw $t1, 0($t5)
	#
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#
	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#
	addi $t5, $t5, -12
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)
	##
	addi $t5, $t5, 1268
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, 40
	sw $t1, 0($t5)
	#
	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)
	#
	addi $t5, $t5, 1280
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)
	###
	addi $t5, $t5, -768
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)
	###

	addi $t5, $t5, -1024
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	#####

	addi $t5, $t5, 3724
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)
	#
	addi $t5, $t5, 252
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	addi $t5, $t5, -260
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	#### V starts here
	addi $t5, $t5, 36
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, 512
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, -252
	sw $t1, 0($t5)

	addi $t5, $t5, -252
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	# E starts here
	addi $t5, $t5, 20
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 244
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, -768
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	addi $t5, $t5, -4
	sw $t1, 0($t5)

	## R starts here

	addi $t5, $t5, 796
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, -256
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 260
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, 256
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

	addi $t5, $t5, -784
	sw $t1, 0($t5)

	addi $t5, $t5, 4
	sw $t1, 0($t5)

DrawScoreOnGameOver:
	la $t1, NumFilled
	lw $t2, 0($t1)

	beq $t2, 1, DrawOne
	beq $t2, 2, DrawTwo

	j Check_RQ1
DrawOne:
	# [16, 55]
	#la $t3, PickUp1CoordinateXY
	#li $t4, 16
	#sw $t4, 0($t3)
	#li $t4, 55
	#sw $t4, 4($t3)

	li $t2, 16
	li $t3, 55

	jal DrawPickUp

	j Check_RQ1



DrawTwo:
	# [16, 55], [25, 55]
	li $t2, 16
	li $t3, 55

	jal DrawPickUp

	li $t2, 25
	li $t3, 55

	jal DrawPickUp

Check_RQ1:
		li $t9, 0xffff0000
		lw $t8, 0($t9)
		beq $t8, 1, keypress_happened1

		j Check_RQ1
		#j Sleep1

		keypress_happened1:
			lw $t2, 4($t9) 			# this assumes $t9 is set to 0xfff0000 from before
			beq $t2, 0x72, Restart 		# ASCII code of 'r' is 0x72 or 114 in decimal
			beq $t2, 0x71, QuitGame 	# ASCII code of 'q' is 0x71 or 113 in decimal
	# in the case of capital letters
			beq $t2, 0x52, Restart 		# ASCII code of 'R' is 0x52 or 82 in decimal
			beq $t2, 0x51, QuitGame 	# ASCII code of 'Q' is 0x51 or 81 in decimal

	##################################### Check Keyboard Input Part
	#Sleep1:
	#li $v0, 32
	#li $a0, Sleeptime			# Wait one second (1000 milliseconds)
	#syscall
		j Check_RQ1















######################################################
