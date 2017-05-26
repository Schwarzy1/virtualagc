### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    S-BAND_ANTENNA_FOR_LM.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 501-504
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-27 HG   Transcribed
##		2016-12-25 RSB	Comment-text proofed using ProoferComments
##				and corrected errors found.
  
## Page 501
# SUBROUTINE NAME: R05 - S-BAND ANTENNA FOR LM

# MOD0 BY T. JAMES
# MOD1 BY P. SHAKIR

# FUNCTIONAL DESCRIPTION

#     THE S-BAND ANTENNA ROUTINE, R05, COMPUTES AND DISPLAYS THE PITCH AND
# YAW ANTENNA GIMBAL ANGLES REQUIRED TO POINT THE LM STEERABLE ANTENNA
# TOWARD THE CENTER OF THE EARTH. THIS ROUTINE IS SELECTED BY THE ASTRO-
# NAUT VIA DSKY ENTRY DURING COASTING FLIGHT OR WHEN THE LM IS ON THE MOON
# SURFACE. THE EARTH OR MOON REFERENCE COORDINATE SYSTEM IS USED DEPENDING
# ON WHETHER THE LM IS ABOUT TO ENTER OR HAS ALREADY ENTERED THE MOON
# SPHERE OF INFLUENCE, RESPECTIVELY.  CAN BE CALLED ANY TIME EXCEPT WHEN
# ANOTHER EXTENDED VERB IS IN USE. DISPLAY IS MEANINGLESS WITH IMU OFF.

# TO CALL SUBROUTINE, ASTRONAUT KEYS IN V 64 E

# SUBROUTINES CALLED-

#     INTPRET
#     LOADTIME
#     LEMCONIC
#     LUNPOS
#     CDUTRIG
#     *SMNB*
#     BANKCALL
#     B5OFF
#     ENDOFJOB
#     BLANKET

# RETURNS WITH

#     PITCH ANGLE IN PITCHANG  REV. B0
#     YAW ANGLE IN YAWANG  REV. B0

# ERASABLES USED

#     PITCHANG
#     YAWANG
#     RLM
#     VAC AREA

                BANK            41
                SETLOC          SBAND
                BANK

                EBANK=          WHOCARES
                COUNT*          $$/R05
SBANDANT        TC              INTPRET

## Page 502
                SETPD           RTB
                                0D
                                LOADTIME                # PICK UP CURRENT TIME
                STCALL          TDEC1                   # ADVANCE INTEGRATION TO TIME IN TDEC1
                                LEMCONIC                # USING CONIC INTEGRATION
                SLOAD           BHIZ
                                X2                      # X2 =0 EARTH SPHERE, X2 =2 MOON SPHERE
                                CONV4
                VLOAD
                                RATT
                STODL           RLM
                                TAT
CONV3           CALL
                                LUNPOS                  # UNIT POSITION VECTOR FROM EARTH TO MOON
                VLOAD           VXSC
                                VMOON
                                REMDIST                 # MEAN DISTANCE FROM EARTH TO MOON
                VSL1            VAD
                                RLM
                GOTO
                                CONV5
CONV4           VLOAD
                                RATT                    # UE = -UNIT(RATT)  EARTH SPHERE
CONV5           SETPD           UNIT                    # UE = -UNIT((REM)(UEM) + RL)  MOON SPHERE
                                0D                      # SET PL POINTER TO 0
                VCOMP           CALL
                                CDUTRIG                 # COMPUTE SINES AND COSINES OF CDU ANGLES
                MXV             VSL1                    # TRANSFORM REF. COORDINATE SYSTEM TO
                                REFSMMAT                # STABLE MEMBER B-1 X B-1 X B+1 = B-1
                PUSH            DLOAD                   # 8D
                                HI6ZEROS
                STORE           PITCHANG
                STOVL           YAWANG                  # ZERO OUT ANGLES
                CALL
                                *SMNB*
                STODL           RLM                     # PRE-MULTIPLY RLM BY (NBSA) MATRIX(B0)
                                RLM             +2
                PUSH            DSU
                                RLM
                DMP
                                1OVSQRT2
                STODL           RLM             +2
                DAD             DMP
                                RLM
                                1OVSQRT2
                STOVL           RLM                     # R  B-1
                                RLM
                UNIT            PDVL
                                RLM
                VPROJ           VSL2                    # PROJECTION OF R ONTO LM XZ PLANE

## Page 503
                                HIUNITY
                BVSU            BOV                     # CLEAR OVERFLOW INDICATOR IF ON
                                RLM
                                COVCNV
COVCNV          UNIT            BOV                     # EXIT ON OVERFLOW
                                SBANDEX
                PUSH            VXV                     # URP VECTOR  B-1
                                HIUNITZ
                VSL1            VCOMP                   # UZ X URP = -(URP X UZ)
                STORE           RLM                     # X VEC  B-1
                DOT             PDVL                    # SGN(X.UY) UNSCALED
                                HIUNITY
                                RLM
                ABVAL           SIGN
                ASIN                                    # ASIN((SGN(X.UY))ABV(X)) REV B0
                STOVL           PITCHANG
                                URP
                DOT             BPL
                                HIUNITZ
                                NOADJUST                # YES, -90 TO +90
                DLOAD           DSU
                                HIDPHALF
                                PITCHANG
                STORE           PITCHANG
NOADJUST        VLOAD           VXV
                                UR                      # Z = (UR X URP)
                                URP
                VSL1
                STODL           RLM                     # Z VEC  B-1
                                PITCHANG
                SIN             VXSC
                                HIUNITZ
                PDDL            COS
                                PITCHANG
                VXSC            VSU
                                HIUNITX                 # (UX COS ALPHA) - (UZ SIN ALPHA)
                DOT             PDVL                    # YAW.Z
                                RLM
                                RLM
                ABVAL           SIGN
                ASIN
                STORE           YAWANG
SBANDEX         EXIT
                CA              EXTVBACT
                MASK            BIT5                    # IS BIT5 STILL ON
                EXTEND
                BZF             ENDEXT                  # NO
                CAF             PRIO5
                TC              PRIOCHNG
                CAF             V06N51                  # DISPLAY ANGLES

## Page 504
                TC              BANKCALL
                CADR            GOMARKFR
                TC              B5OFF                   # TERMINATE
                TC              B5OFF                   # PROCEED
                TC              ENDOFJOB                # RECYCLE
                CAF             BIT3                    # IMMEDIATE RETURN
                TC              BLANKET                 # BLANK R3
                CAF             PRIO4
                TC              PRIOCHNG
                TC              SBANDANT                # YES, CONTINUE DISPLAYING ANGLES.
V06N51          VN              0651

                SETLOC          SBAND40
                BANK

1OVSQRT2        2DEC            .7071067815             # 1/SQRT(2)

UR              EQUALS          0D
URP             EQUALS          6D
                SBANK=          LOWSUPER
