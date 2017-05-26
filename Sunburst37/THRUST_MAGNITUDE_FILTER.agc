### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    THRUST_MAGNITUDE_FILTER.agc
## Purpose:     A section of Sunburst revision 37, or Shepatin revision 0.
##              It is part of an early development version of the software
##              for Apollo Guidance Computer (AGC) on the unmanned Lunar
##              Module (LM) flight Apollo 5. Sunburst 37 was the program
##              upon which Don Eyles's offline development program Shepatin
##              was based; the listing herein transcribed was actually for
##              the equivalent revision 0 of Shepatin.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 862-863
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.

## NOTE: Page numbers below have not yet been updated to reflect Sunburst 37.

## Page 923
# PROGRAM NAME - ATMAG

# MODIFICATION BY - BERMAN AND CATTANACH

# FUNCTIONAL DESCRIPTION -

#     THE THRUST MAGNITUDE FILTER CONVERTS ABDELV TO M/CS, INVERTS AND COMBINES IT WITH TWO PRECEDING
# INPUTS TO PRODUCE THE INVERTED EXHAUST VELOCITY, BURN UP TIME, AND ANTICIPATED THRUST ACCELERATION FOR
# THE NEXT TIME INCREMENT.  THRUST MAGNITUDE FILTER IS BYPASSED UNTIL AFTER THE MAIN ENGINE GOES ON.

# CALLING SEQUENCE - ATMAG IS ENTERED BY EXTEND                 AND        EXTEND
#                                      DCA      ATMAGAD                   DCA     ATMAG4
#                                      DXCH	AVGEXIT			  DXCH	  AVGEXIT
# NORMAL EXIT - FROM ATMAG BY GOTO
#                                  ASCENT

# OUTPUT - INVERTED EXHAUST VELOCITY, BURN UP TIME, AND ANTICIPATED THRUST ACCELERATION

# ERASABLE INITIALIZATION REQUIRED - THIS IS DONE BY PRE-APS PROGRAMS

# DEBRIS - ABDVCONV, 1/DV1, 1/DV2, 1/VE, TBUP, AT.

# ALARM OR ABORT EXIT MODES - 

# SUBROUTINES CALLED - NONE

		BANK	32
		
		EBANK=	TCO		# EBANK4
		
ATMAG		TC	INTPRET
		DLOAD	DCOMP		# LOAD -VE*2(-6)
			NEGVEX
		SR1
		STORE	VE		# VE*2(-7)
		SETPD	SLOAD
			00D
			BIT4H
		DDV	EXIT
			ABDVCONV
			
		DXCH	MPAC
		DXCH	1/DV3
		DXCH	1/DV2
		DXCH	1/DV1
		DXCH	MPAC		# MPAC=1/DV0*2(-7)
		TC	INTPRET
		DAD
			1/DV1		# (1/DV0+1/DV1)*2(-7)
		DAD	DAD
## Page 924
			1/DV2
			1/DV3		# SUM(1/DV)*2(-7)
		DMP	DMP		# VE SUM(1/DV)*2(-14)
			VE		# DT VE SUM(1/DV)*2(-21)
			2SEC(9)
		SL3	PDDL		# 1/8 DT VE SUM(1/DV)*2(-17)
			TBUP		# LOAD TBUP*2(-17)
		SR1	DAD		# 1/2 OLD TBUP*2(-17)
		DSU
			6SEC(18)	# GET NEW TBUP *2(-17)
		STODL	TBUP
			VE
		SR1	DDV		# VE*2(-8)
			TBUP		# AT*2(9)
		STORE	AT
FILTEND		GOTO
			ASCENT
			
BIT4H		OCT	10
6SEC(18)	2DEC	600B-18

ASCPATCH	STOVL	UNNORM		# PATCH FROM ASCENT STEERING LOG SECTION.
			RCOV
		UNIT	GOTO
			ENDPATCH