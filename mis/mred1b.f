      SUBROUTINE MRED1B (MODE)        
C        
C     THIS SUBROUTINE PROCESSES THE BDYS AND BDYS1 DATA FOR THE FIXED   
C     IDENTIFICATION SET (FIXSET) AND THE BOUNDARY IDENTIFICATION SET   
C     (BNDSET) FOR THE MRED1 MODULE.        
C        
C     INPUT DATA        
C     GINO   - GEOM4  - BDYS DATA        
C                     - BDYS1 DATA        
C     OTHERS - MODE   - SUBROUTINE PROCESSING FLAG        
C                     = 1, PROCESS FIXED ID SET        
C                     = 2, PROCESS BOUNDARY ID SET        
C        
C     OUTPUT DATA        
C     GINO   - USETX  - S,R,B DEGREES OF FREEDOM        
C        
C     PARAMETERS        
C     INPUT  - NOUS   - FIXED POINTS FLAG        
C                       .GE.  0, FIXED POINTS DEFINED        
C                       .EQ. -1, NO FIXED POINTS DEFINED        
C              GBUF1  - GINO BUFFER        
C              KORLEN - CORE LENGTH        
C              IO     - OUTPUT OPTION FLAG        
C              NAMEBS - BEGINNING ADDRESS OF BASIC SUBSTRUCTURES NAMES  
C              EQSIND - BEGINNING ADDRESS OF EQSS GROUP ADDRESSES       
C              NSLBGN - BEGINNING ADDRESS OF SIL DATA        
C              KBDYC  - BEGINNING ADDRESS OF BDYC DATA        
C              USETX  - USETX OUTPUT FILE NUMBER        
C              NBDYCC - NUMBER OF BDYC WORDS        
C     OUTPUT - DRY    - MODULE OPERATION FLAG        
C     OTHERS - LOCUST - BEGINNING ADDRESS OF USET ARRAY        
C              IERR   - NO BDYS/BDYS1 DATA ERROR FLAG        
C                       .LT. 2, NO ERRORS        
C                       .EQ. 2, ERRORS        
C              GRPBGN - ABSOLUTE BEGINNING ADDRESS OF EQSS GROUP DATA   
C              GRPEND - ABSOLUTE ENDING ADDRESS OF EQSS GROUP DATA      
C              GRPIP  - ABSOLUTE ADDRESS OF EQSS DATA GROUP        
C              LOCBGN - BEGINNING ADDRESS OF EQSS DATA FOR SUBSTRUCTURE 
C              NFOUND - NUMBER OF EQSS DATA ITEMS FOUND FOR SET ID      
C              KPNTBD - ARRAY OF BDYC DOF COMPONENTS        
C              KPNTSL - ARRAY OF EQSS DOF COMPONENTS        
C              INDSIL - ABSOLUTE INDEX INTO SIL DATA        
C              NSILUS - ABSOLUTE INDEX INTO USET ARRAY        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        RSHIFT,ANDF,ORF,COMPLF        
      LOGICAL         BOUNDS,PONLY        
      REAL            RZ(1)        
      DIMENSION       ARRAY(3),BDYI(2,2),BDY(2),EQSTRL(7),IDUM(3),      
     1                KPNTSL(32),IOSHFT(2),KPNTBD(9),MODNAM(2),USETRL(7)
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / OLDNAM(2),DRY,IDUM13,NOUS,IDUM2(4),GBUF1,        
     1                IDUM14(4),KORLEN,IDUM4(5),IO,IDUM5(2),BNDSET,     
     2                FIXSET,IEIG,KORBGN,IDUM12,NAMEBS,EQSIND,NSLBGN,   
     3                IDUM6,KBDYC,NBDYCC,LUSET,LOCUST,IDUM3(4),BOUNDS,  
     4                PONLY        
CZZ   COMMON /ZZMRD1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ IDUM7,IPRNTR,IDUM8(6),NLPP,IDUM9(2),LINE        
      COMMON /TWO   / ITWO(32)        
      COMMON /BITPOS/ IDUM10(5),UL,UA,UF,US,UN,IDUM11(10),UB,UI        
      COMMON /PATX  / LCORE,NSUB(3),FUSET        
      COMMON /UNPAKX/ TYPEU,IROWU,NROWU,INCRU        
      EQUIVALENCE     (RZ(1),Z(1))        
      DATA    GEOM4 , BDYI,USETX/102,1210,12,1310,13,201/        
      DATA    MODNAM/ 4HMRED,4H1B   /        
      DATA    IOSHFT/ 11,2  /        
      DATA    ITEM  / 4HUPRT/        
      DATA    UPRT  , EQST  /301,203/        
C        
C     TEST FOR FIXED SET INPUT        
C        
      IF (NOUS.EQ.-1 .AND. MODE.EQ.1) GO TO 430        
C        
C     CHECK FOR LOADS PROCESSING ONLY        
C        
      IF (PONLY) GO TO 345        
C        
C     PROCESS BDY(S/S1) BULK DATA FOR SPECIFIED BDYC        
C        
      ISHIFT = IOSHFT(MODE)        
      IF (NBDYCC .EQ. 0) GO TO 335        
      KORBGN = KBDYC + 4*NBDYCC        
      IF (KORBGN .GE. KORLEN) GO TO 300        
      IF (ANDF(RSHIFT(IO,ISHIFT),1) .EQ. 0) GO TO 10        
      CALL PAGE1        
      IF (MODE .EQ. 1) WRITE (IPRNTR,900)        
      IF (MODE .EQ. 2) WRITE (IPRNTR,901)        
      LINE  = LINE + 7        
   10 IBITS = ITWO(UL) + ITWO(UA) + ITWO(UF)        
      IF (MODE .EQ. 2) IBITS = ITWO(UI)        
      IBITS = COMPLF(IBITS)        
      IERR  = 0        
      IBDY  = 0        
      IFILE = GEOM4        
C        
C     SET BULK DATA PROCESSING FLAG AND READ SET ID        
C     IBDY .EQ. 1 - BDYS        
C     IBDY .EQ. 2 - BDYS1        
C        
      NXTBDY = 1        
      IFOUND = 0        
      CALL PRELOC (*270,Z(GBUF1),GEOM4)        
   20 IBDY = IBDY + 1        
      IF (IBDY .EQ. 3) GO TO 260        
      DO 30 I = 1,2        
   30 BDY(I) = BDYI(I,IBDY)        
      CALL LOCATE (*250,Z(GBUF1),BDY,IFLAG)        
      GO TO 40        
   35 CALL BCKREC (GEOM4)        
      NXTBDY = NXTBDY + 1        
      IF (NXTBDY .GT. NBDYCC) GO TO 20        
      CALL READ (*280,*290,GEOM4,IDUM,3,0,IFLAG)        
   40 CALL READ (*280,*20,GEOM4,ARRAY,IBDY,0,IFLAG)        
C        
C     CHECK REQUEST ID        
C        
      BDYJ = 2        
      BDYK = 2        
      BDYL = 3        
      BDYM = 2        
      IF (IBDY .EQ. 1) GO TO 50        
      BDYJ = 3        
      BDYK = 1        
      BDYL = 2        
      BDYM = 3        
   50 IWDS = 2 + 4*(NXTBDY-1)        
      DO 55 I = NXTBDY, NBDYCC        
      IF (Z(KBDYC+IWDS) .EQ. ARRAY(1)) GO TO 90        
   55 IWDS = IWDS + 4        
C        
C     FINISH BDY(S/S1) SET ID READING        
C        
   60 CALL READ (*280,*290,GEOM4,ARRAY(BDYJ),BDYK,0,IFLAG)        
      IF (IBDY - 2) 70,80,80        
   70 IF (ARRAY(2).NE.-1 .AND. ARRAY(3).NE.-1) GO TO 60        
      GO TO 40        
   80 IF (ARRAY(3) .NE. -1) GO TO 60        
      GO TO 40        
C        
C     CONTINUE BDY(S/S1) SET ID PROCESSING        
C        
   90 CALL READ (*280,*290,GEOM4,ARRAY(BDYJ),BDYK,0,IFLAG)        
      IF (IBDY - 2) 100,110,110        
  100 IF (ARRAY(2).EQ.-1 .AND. ARRAY(3).EQ.-1) GO TO 115        
      GO TO 120        
  110 IF (ARRAY(3) .EQ. -1) GO TO 115        
      GO TO 120        
C        
C     CHECK FOR NEXT BDY(S/S1) CARD HAVING SAME SET ID AS CURRENT ID    
C        
  115 CALL READ (*280,*35,GEOM4,ARRAY,IBDY,0,IFLAG)        
      IF (Z(KBDYC+IWDS) .EQ. ARRAY(1)) GO TO 90        
      GO TO 35        
C        
C     LOCATE EQSS DATA FOR SUBSTRUCTURE        
C        
  120 IFOUND = 1        
      IP     = 2*(Z(KBDYC+IWDS+1)-1)        
      GRPBGN = Z(EQSIND+IP)        
      GRPEND = GRPBGN + Z(EQSIND+IP+1)        
      K = Z(EQSIND+IP+1)/3        
      CALL BISLOC (*170,ARRAY(BDYM),Z(GRPBGN),3,K,LOCBGN)        
      GRPIP  = GRPBGN + LOCBGN - 1        
      LOC    = GRPIP - 3        
  130 IF (LOC .LT. GRPBGN) GO TO 140        
      IF (Z(LOC) .LT. Z(GRPIP)) GO TO 140        
      LOC    = LOC - 3        
      GO TO 130        
  140 LOCBGN = LOC + 3        
      NFOUND = 1        
      LOC    = LOCBGN + 3        
  150 IF (LOC .GE. GRPEND) GO TO 180        
      IF (Z(LOCBGN) .LT. Z(LOC)) GO TO 180        
      LOC    = LOC + 3        
      NFOUND = NFOUND + 1        
      GO TO 150        
C        
C     CANNOT LOCATE EXTERNAL ID        
C        
 170  CALL PAGE1        
      IF (MODE .EQ. 1) WRITE (IPRNTR,902) UFM,ARRAY(3),ARRAY(2),        
     1                 ARRAY(1),Z(NAMEBS+IP),Z(NAMEBS+IP+1)        
      IF (MODE .EQ. 2) WRITE (IPRNTR,903) UFM,ARRAY(3),ARRAY(2),        
     1                 ARRAY(1),Z(NAMEBS+IP),Z(NAMEBS+IP+1)        
      DRY = -2        
      GO TO 90        
C        
C     LOCATE CORRECT IP FOR THIS EXTERNAL ID        
C        
  180 CALL SPLT10 (ARRAY(BDYL),KPNTBD,JWDS)        
      M = 0        
      DO 230 I = 1, NFOUND        
      J = (3*(I-1)) + 2        
      ICODE = Z(LOCBGN+J)        
      CALL DECODE (ICODE,KPNTSL,KWDS)        
      DO 230 K = 1, KWDS        
      DO 190 L = 1, JWDS        
      IF (KPNTSL(K) .EQ. KPNTBD(L)-1) GO TO 200        
  190 CONTINUE        
      GO TO 230        
C        
C     CONVERT GRID ID AND COMPONENT TO SIL VALUE        
C        
  200 IF (ANDF(RSHIFT(IO,ISHIFT),1) .EQ. 0) GO TO 220        
      IF (LINE .LE. NLPP) GO TO 210        
      CALL PAGE1        
      IF (MODE .EQ. 1) WRITE (IPRNTR,900)        
      IF (MODE .EQ. 2) WRITE (IPRNTR,901)        
      LINE = LINE + 7        
  210 IF (M .EQ. 0) WRITE (IPRNTR,906) ARRAY(1),ARRAY(BDYM),ARRAY(BDYL) 
      M    = 1        
      LINE = LINE + 1        
  220 INDSIL = NSLBGN + ((2*Z(LOCBGN+J-1))-2)        
      NSILUS = LOCUST + ((Z(INDSIL)-1)+(K-1))        
      KPNTBD(L) = 0        
C        
C     FILL USET ARRAY        
C     IF FIXSET - TURN OFF UL, UA, UF BITS AND TURN ON US BIT        
C     IF BNDSET - TURN OFF UI BIT AND TURN ON UB BIT        
C        
      UBORS = US        
      IF (MODE .EQ. 2) UBORS = UB        
      Z(NSILUS) = ANDF(Z(NSILUS),IBITS)        
      Z(NSILUS) = ORF(Z(NSILUS),ITWO(UBORS))        
  230 CONTINUE        
C        
C     CHECK THAT ALL IP FOUND        
C        
      DO 240 I = 1,JWDS        
      IF (KPNTBD(I) .EQ. 0) GO TO 240        
      IF (MODE .EQ. 1) WRITE (IPRNTR,904) UWM,ARRAY(BDYM),Z(NAMEBS+IP), 
     1                 Z(NAMEBS+IP+1)        
      IF (MODE .EQ. 2) WRITE (IPRNTR,905) UWM,ARRAY(BDYM),Z(NAMEBS+IP), 
     1                 Z(NAMEBS+IP+1)        
      GO TO 90        
  240 CONTINUE        
      GO TO 90        
C        
C     SET NO DATA AVAILABLE FLAG        
C        
  250 IERR = IERR + 1        
      GO TO 20        
C        
C     END OF ID SET PROCESSING        
C        
  260 CALL CLOSE (GEOM4,1)        
      IF (IERR   .EQ. 2) GO TO 330        
      IF (IFOUND .EQ. 0) GO TO 330        
      IF (MODE   .EQ. 1) GO TO 430        
C        
C     WRITE USETX DATA        
C        
      CALL GOPEN (USETX,Z(GBUF1),1)        
      CALL WRITE (USETX,Z(LOCUST),LUSET,1)        
      CALL CLOSE (USETX,1)        
      USETRL(1) = USETX        
      USETRL(2) = 1        
      USETRL(3) = LUSET        
      USETRL(4) = 7        
      USETRL(5) = 1        
      CALL WRTTRL (USETRL)        
C        
C     VERIFY OLD BOUNDARY UNCHANGED        
C        
      IF (.NOT.BOUNDS) GO TO 430        
      IF (LOCUST+2*LUSET .GE. KORLEN) GO TO 300        
  345 CALL SOFTRL (OLDNAM,ITEM,USETRL)        
      IF (USETRL(1) .NE. 1) GO TO 440        
      NROWU = USETRL(3)        
      IF (PONLY) LUSET = NROWU        
      IF (NROWU .NE. LUSET) GO TO 420        
C        
C     GET OLD UPRT VECTOR        
C        
      TYPEU = USETRL(5)        
      CALL MTRXI (UPRT,OLDNAM,ITEM,0,ITEST)        
      NEWUST = LOCUST + LUSET        
      IF (PONLY) NEWUST = LOCUST        
      IF (PONLY .AND. NEWUST+NROWU.GE.KORLEN) GO TO 300        
      IROWU = 1        
      INCRU = 1        
      CALL GOPEN (UPRT,Z(GBUF1),0)        
      CALL UNPACK (*350,UPRT,RZ(NEWUST))        
      GO TO 370        
  350 DO 360 I = 1,LUSET        
  360 RZ(NEWUST+I-1) = 0.0        
  370 CALL CLOSE (UPRT,1)        
      IF (PONLY) GO TO 405        
C        
C     GET NEW UPRT VECTOR        
C        
      LCORE = KORLEN - (NEWUST+LUSET)        
      FUSET = USETX        
      CALL CALCV (UPRT,UN,UI,UB,Z(NEWUST+LUSET))        
      TYPEU = 1        
      NROWU = LUSET        
      CALL GOPEN (UPRT,Z(GBUF1),0)        
      CALL UNPACK (*380,UPRT,RZ(NEWUST+LUSET))        
      GO TO 400        
  380 DO 390 I = 1,LUSET        
  390 RZ(NEWUST+LUSET+I-1) = 0.0        
  400 CALL CLOSE (UPRT,1)        
C        
C     CHECK OLD, NEW UPRT VECTORS AND COUNT NUMBER OF ROWS IN 0, 1      
C     SUBSETS AND SAVE IN EQST TRAILER FOR USE IN MRED2A        
C        
  405 ISUB0 = 0        
      ISUB1 = 0        
      DO 410 I = 1,LUSET        
      IF (RZ(NEWUST+I-1) .EQ. 0.0) ISUB0 = ISUB0 + 1        
      IF (RZ(NEWUST+I-1) .EQ. 1.0) ISUB1 = ISUB1 + 1        
      IF (PONLY) GO TO 410        
      IF (RZ(NEWUST+I-1) .NE. RZ(NEWUST+LUSET+I-1)) GO TO 420        
  410 CONTINUE        
      EQSTRL(1) = EQST        
      EQSTRL(6) = ISUB0        
      EQSTRL(7) = ISUB1        
      CALL WRTTRL (EQSTRL)        
      GO TO 430        
C        
C     BOUNDARY POINTS ARE NOT THE SAME        
C        
  420 WRITE (IPRNTR,909) UFM,OLDNAM        
      DRY = -2        
  430 CONTINUE        
      RETURN        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  270 IMSG = -1        
      GO TO 320        
  280 IMSG = -2        
      GO TO 310        
  290 IMSG = -3        
      GO TO 310        
  300 IMSG = -8        
      IFILE = 0        
  310 CALL CLOSE (GEOM4,1)        
  320 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  330 IF (MODE .EQ. 1) WRITE (IPRNTR,907) UFM,FIXSET        
      IF (MODE .EQ. 2) WRITE (IPRNTR,908) UFM,BNDSET        
  335 DRY = -2        
      CALL SOFCLS        
      CALL CLOSE (GEOM4,1)        
      RETURN        
  440 GO TO (450,450,460,470,480,480), ITEST        
  450 WRITE (IPRNTR,910) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
  460 IMSG = -1        
      GO TO 490        
  470 IMSG = -2        
      GO TO 490        
  480 IMSG = -3        
  490 CALL SMSG (IMSG,ITEM,OLDNAM)        
      RETURN        
C        
  900 FORMAT (//45X,40HTABLE OF GRID POINTS COMPOSING FIXED SET,        
     1       //53X,5HFIXED,/53X,25HSET ID   GRID POINT   DOF, /53X,     
     2       26HNUMBER   ID NUMBER    CODE,/)        
  901 FORMAT (1H0,44X,43HTABLE OF GRID POINTS COMPOSING BOUNDARY SET,   
     1       //52X,8HBOUNDARY,/53X,25HSET ID   GRID POINT   DOF, /53X,  
     2       26HNUMBER   ID NUMBER    CODE,/)        
  902 FORMAT (A23,' 6624, GRID POINT',I9,' COMPONENT',I9,' SPECIFIED ', 
     1       'IN FIXED SET',I9, /5X,'FOR SUBSTRUCTURE ',2A4,        
     2       ' DOES NOT EXIST.',//////)        
  903 FORMAT (A23,' 6611, GRID POINT',I9,' COMPONENT',I9,' SPECIFIED ', 
     1       'IN BOUNDARY SET',I9, /5X,'FOR SUBSTRUCTURE ',2A4,        
     2       ' DOES NOT EXIST.',//////)        
  904 FORMAT (A25,' 6625, DEGREES OF FREEDOM AT GRID POINT',I9,        
     1       ' COMPONENT SUBSTRUCTURE ',2A4, /32X,'INCLUDED IN A FIXED',
     2       ' SET DO NOT EXIST.  REQUEST WILL BE IGNORED.')        
  905 FORMAT (A25,' 6610, DEGREES OF FREEDOM AT GRID POINT',I9,        
     1       ' COMPONENT SUBSTRUCTURE ',2A4, /32X,'INCLUDED IN A NON-', 
     2       'EXISTING BOUNDARY SET.  REQUEST WILL BE IGNORED.')        
  906 FORMAT (52X,2(I8,3X),I6)        
  907 FORMAT (A23,' 6626, NO BDYS OR BDYS1 BULK DATA HAS BEEN INPUT TO',
     1       ' DEFINE FIXED SET',I9,1H.)        
  908 FORMAT (A23,' 6607, NO BDYS OR BDYS1 BULK DATA HAS BEEN INPUT TO',
     1       ' DEFINE BOUNDARY SET',I9,1H.)        
  909 FORMAT (A23,' 6637, OLDBOUND HAS BEEN SPECIFIED BUT THE BOUNDARY',
     1       ' POINTS FOR SUBSTRUCTURE ',2A4,' HAVE BEEN CHANGED.')     
  910 FORMAT (A23,' 6215, MODULE ',2A4,8H - ITEM ,A4,' OF SUBSTRUCTURE '
     1,       2A4,' PSEUDO-EXISTS ONLY.')        
C        
      END        
