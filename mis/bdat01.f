      SUBROUTINE BDAT01        
C        
C     THIS SUBROUTINE PROCESSES CONCT1 BULK DATA GENERATING        
C     CONNECTION ENTRIES IN TERMS OF GRID POINT ID NUMBERS        
C     CODED TO THE PSEUDO-STRUCTURE ID NUMBER.        
C     THESE ARE THEN WRITTEN ON SCR1.        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         TDAT,PRINT        
      INTEGER         IO(9),ID(14),IS(7),IC(7),SCR1,CONSET,GEOM4,AAA(2),
     1                FLAG,BUF1,CONCT1(2),BUF2,OUTT,ANDF,RSHIFT,COMBO   
      DIMENSION       IBITS(32),JBITS(32),NAME(14),IHD(16)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT        
      COMMON /CMB004/ TDAT(6)        
      COMMON /CMBFND/ INAM(2),IERR        
      COMMON /OUTPUT/ ITITL(96),IHEAD(96)        
      COMMON /BLANK / STEP,IDRY        
      DATA    AAA   / 4HBDAT,4H01     / , CONCT1 / 110,41 /        
      DATA    IHD   / 4H  SU , 4HMMAR , 4HY OF , 4H CON , 4HNECT ,      
     1                4HION  , 4HENTR , 4HIES  , 4HSPEC , 4HIFIE ,      
     2                4HD BY , 4H CON , 4HCT1  , 4HBULK , 4H DAT ,      
     3                4HA    /        
      DATA    IBLNK / 4H     /        
C        
      DO 10 I = 1,96        
      IHEAD(I) = IBLNK        
   10 CONTINUE        
      J = 1        
      DO 15 I = 73,88        
      IHEAD(I) = IHD(J)        
   15 J = J + 1        
      PRINT = .FALSE.        
      IF (ANDF(RSHIFT(IPRINT,2),1) .EQ. 1) PRINT = .TRUE.        
      NP2 = 2*NPSUB        
      DO 20 I = 1,NP2,2        
      J = I/2 + 1        
      NAME(I  ) = COMBO(J,1)        
      NAME(I+1) = COMBO(J,2)        
   20 CONTINUE        
      IFILE = SCR1        
      CALL OPEN (*320,SCR1,Z(BUF2),1)        
      CALL LOCATE (*400,Z(BUF1),CONCT1,FLAG)        
      IFILE = GEOM4        
   30 CALL READ (*300,*210,GEOM4,ID,2,0,N)        
      NSS   = ID(1)        
      NSSP1 = NSS + 1        
      IF (ID(2) .EQ. CONSET) GO TO 50        
   40 CALL READ (*300,*310,GEOM4,ID,1,0,NNN)        
      IF (ID(1) .NE. -1) GO TO 40        
      GO TO 30        
   50 NWD = 2*NSS        
      IF (.NOT.PRINT) GO TO 70        
      CALL PAGE        
      CALL PAGE2 (6)        
      WRITE  (OUTT,60) (NAME(KDH),KDH=1,NP2)        
   60 FORMAT (/24X,74HNOTE  GRID POINT ID NUMBERS HAVE BEEN CODED TO THE
     1 COMPONENT SUBSTRUCTURE, /30X,75HWITHIN A GIVEN PSEUDOSTRUCTURE BY
     2 - 1000000*COMPONENT NO. + ACTUAL GRID ID.,//15X,22HCONNECTED   CO
     3NNECTION,23X,33HGRID POINT ID FOR PSEUDOSTRUCTURE, /18X,3HDOF,9X, 
     44HCODE,3X,7(3X,2A4)/)        
   70 CONTINUE        
C        
C     MAKING IT TO 50 IMPLIES THAT CONCT1 DATA EXISTS        
C        
      TDAT(1) = .TRUE.        
      CALL READ (*300,*310,GEOM4,ID,NWD,0,NNN)        
      DO 90 I = 1,NSS        
      J = 2*(I-1)        
      CALL FINDER (ID(1+J),IS(I),IC(I))        
      IF (IERR .NE. 1) GO TO 90        
      WRITE  (OUTT,80) UFM,ID(1+J),ID(2+J)        
   80 FORMAT (A23,' 6522, THE BASIC SUBSTRUCTURE ',2A4, /30X,        
     1       'REFERED TO BY A CONCT1 BULK DATA CARD CAN NOT BE FOUND ', 
     2       'IN THE PROBLEM TABLE OF CONTENTS.')        
      IDRY = -2        
   90 CONTINUE        
  100 DO 110 I = 1,9        
  110 IO(I) = 0        
      DO 120 I = 1,NSSP1        
      CALL READ (*300,*310,GEOM4,ID(I),1,0,NNN)        
      IF (ID(I) .EQ. -1) GO TO 30        
  120 CONTINUE        
      DO 140 I = 1,NSS        
      DO 130 J = 1,NSS        
      IF (I .EQ. J) GO TO 130        
      IF (IS(I).EQ.IS(J) .AND. ID(I+1).NE.0 .AND. ID(J+1).NE.0)        
     1    GO TO 150        
  130 CONTINUE        
  140 CONTINUE        
      GO TO 170        
  150 KK = 2*IS(I) - 1        
      WRITE  (OUTT,160) UFM,ID(I+1),ID(J+1),NAME(KK),NAME(KK+1)        
  160 FORMAT (A23,' 6536, MANUAL CONNECTION DATA IS ATTEMPTING TO ',    
     1       'CONNECT', /31X,'GRID POINTS',I9,5X,4HAND ,I8, /31X,       
     2       'WHICH ARE BOTH CONTAINED IN PSEUDOSTRUCTURE ',2A4)        
      IDRY = -2        
  170 CALL ENCODE (ID(1))        
      IO(1) = ID(1)        
      ISUM  = 0        
      DO 180 I = 1,NSS        
      IF (ID(I+1) .EQ. 0) GO TO 180        
      IF (ID(I+1) .NE. 0) ISUM = ISUM + 2**(IS(I)-1)        
      M = 2 + IS(I)        
      IO(M) = IC(I)*1000000 + ID(I+1)        
  180 CONTINUE        
      IO(2) = -1*ISUM        
      NWD   = 2 + NPSUB        
      CALL WRITE (SCR1,IO,NWD,1)        
      IF (.NOT.PRINT .OR. IDRY.EQ.-2) GO TO 200        
      CALL BITPAT (IO(1),IBITS)        
      CALL BITPAT (IABS(IO(2)),JBITS)        
      CALL PAGE2 (1)        
      WRITE (OUTT,190) (IBITS(KDH),KDH=1,2),(JBITS(KDH),KDH=1,2),       
     1                 (IO(KDH+2),KDH=1,NPSUB)        
  190 FORMAT (16X,A4,A2,6X,A4,A3,2X,7(3X,I8))        
  200 CONTINUE        
      GO TO 100        
  210 CONTINUE        
      GO TO 400        
C        
  300 IMSG = -2        
      GO TO 330        
  310 IMSG = -3        
      GO TO 330        
  320 IMSG = -1        
  330 CALL MESAGE (IMSG,IFILE,AAA)        
  400 CALL CLOSE  (SCR1,2)        
      RETURN        
      END        
