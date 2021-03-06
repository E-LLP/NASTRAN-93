      SUBROUTINE FRLGB (PP,USETD,GMD,GOD,MULTI,SINGLE,OMIT,MODAL,PHIDH, 
     1                  PD,PS,PH,SCR1,SCR2,SCR3,SCR4)        
C        
C     THIS ROUTINE REDUCES LOADS FROM P SET TO D SET        
C        
C     ENTRY POINT - FRRD1B        
C                   ======        
C        
      INTEGER         PP,USETD,GMD,GOD,SINGLE,OMIT,PHIDH,PD,PS,PH,PO,   
     1                SCR1,SCR2,SCR3,SCR4,USET,PN,PNBAR,PM,PF,PDBAR     
      COMMON /BITPOS/ UM,UO,UR,USG,USB,UL,UA,UF,US,UN,UG,UE,UP,UNE,UFE, 
     1                UD        
      COMMON /PATX  / NZ,N1,N2,N3,USET        
CZZ   COMMON /ZZFRB1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      DATA    MODA  / 4HMODA /        
C        
      GO TO 5        
C        
C        
      ENTRY FRRD1B (PP,USETD,GMD,GOD,MULTI,SINGLE,OMIT,MODAL,PHIDH,     
     1              PD,PS,PH,SCR1,SCR2,SCR3,SCR4)        
C     =============================================================     
C        
C     SET UP INITIAL VALUES        
C        
    5 NZ    = KORSZ(CORE)        
      USET  = USETD        
      PNBAR = SCR2        
      PM    = SCR3        
      PN    = SCR4        
      PF    = SCR2        
      PDBAR = SCR3        
      PO    = PH        
C        
C     REMOVE EACH TYPE OF CONSTRAINT        
C        
      IF (MULTI .LT. 0) GO TO 10        
C        
C     REMOVE MULTIPOINT CONSTRAINTS        
C        
      IF (SINGLE.LT.0 .AND. OMIT.LT.0) PN = PD        
      CALL CALCV (SCR1,UP,UNE,UM,CORE(1))        
      CALL SSG2A (PP,PNBAR,PM,SCR1)        
      CALL SSG2B (GMD,PM,PNBAR,PN,1,1,1,SCR1)        
      GO TO 20        
C        
C     NO M-S        
C        
   10 PN = PP        
   20 IF (SINGLE .LT. 0) GO TO 30        
C        
C     REMOVE SINGLE POINT CONSTRAINTS        
C        
      IF (OMIT .LT. 0) PF = PD        
      CALL CALCV (SCR1,UNE,UFE,US,CORE(1))        
      CALL SSG2A (PN,PF,PS,SCR1)        
      GO TO 40        
C        
C     NO SINGLE POINT CONSTRAINTS        
C        
   30 PF = PN        
   40 IF (OMIT .LT. 0) GO TO 50        
C        
C     REMOVE OMITS        
C        
      CALL CALCV (SCR1,UFE,UD,UO,CORE(1))        
      CALL SSG2A (PF,PDBAR,PO,SCR1)        
      CALL SSG2B (GOD,PO,PDBAR,PD,1,1,1,SCR1)        
      GO TO 60        
   50 PD = PF        
   60 IF (MODAL .NE. MODA) GO TO 70        
C        
C     TRANSFORM TO MODAL COORDINATES        
C        
      CALL SSG2B (PHIDH,PD,0,PH,1,1,1,SCR1)        
   70 RETURN        
      END        
