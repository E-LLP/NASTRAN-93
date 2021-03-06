      SUBROUTINE RCOVLS (LASTSS)        
C        
C     THIS ROUTINE CREATES THE SOLN ITEM FOR A LOWER LEVEL SUBSTRUCTURE,
C     LASTSS, BY EDITING THAT OF THE SOLUTION SUBSTRUCTURE FSS.        
C        
      INTEGER         DRY        ,STEP       ,FSS        ,RFNO       ,  
     1                UINMS      ,UA         ,LASTSS(2)  ,EQSS       ,  
     2                RC         ,SOLN       ,SRD        ,SWRT       ,  
     3                IZ(3)      ,EOI        ,EOG        ,NAME(2)       
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / DRY        ,LOOP       ,STEP       ,FSS(2)     ,  
     1                RFNO       ,NEIGV      ,LUI        ,UINMS(2,5) ,  
     2                NOSORT     ,UTHRES     ,PTHRES     ,QTHRES        
      COMMON /RCOVCR/ ICORE      ,LCORE      ,BUF1       ,BUF2       ,  
     1                BUF3       ,BUF4       ,SOF1       ,SOF2       ,  
     2                SOF3        
      COMMON /RCOVCM/ MRECVR     ,UA         ,PA         ,QA         ,  
     1                IOPT       ,RSS(2)     ,ENERGY     ,UIMPRO     ,  
     2                RANGE(2)   ,IREQ       ,LREQ       ,LBASIC        
      COMMON /SYSTEM/ SYSBUF     ,NOUT        
CZZ   COMMON /ZZRCBX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1),IZ(1))        
      DATA    NAME  / 4HRCOV, 4HLS  /        
      DATA    EQSS  , SOLN  / 4HEQSS,4HSOLN /        
      DATA    SRD   , SWRT  / 1,2   /        
      DATA    EOG   , EOI   / 2,3   /        
C        
C     CREATE SOLN ITEM FOR THE RECOVERED SUBSTRUCTURE        
C        
      IF (RFNO .EQ. 3) GO TO 490        
C        
C     OBTAIN LIST OF CONTRIBUTING BASIC SUBSTRUCTURES FROM EQSS.        
C     STORE IN OPEN CORE AT ICORE.        
C        
      CALL SFETCH (LASTSS,EQSS,SRD,RC)        
      CALL SUREAD (Z(ICORE),4,NWDS,RC)        
      NSS = IZ(ICORE+2)        
      IF (LCORE .LE. ICORE+2*NSS-1) GO TO 9008        
      CALL SUREAD (Z(ICORE),2*NSS,NWDS,RC)        
C        
C     CONSTRUCT SOLN GROUP 0 IN OPEN CORE AT IG0.  TWO SLOTS FOR THE    
C     NUMBER OF LOADS ON EACH SUBSTRUCTURE.  FIRST IS FOR OLD FSS       
C     SOLN, SECOND FOR NEW ONE.        
C        
      IG0 = ICORE + 2*NSS        
      CALL SFETCH (FSS,SOLN,SRD,RC)        
      IF (RC .EQ. 1) GO TO 462        
      CALL SMSG (RC-2,SOLN,FSS)        
      GO TO 498        
  462 CALL SUREAD (Z(IG0),5,NWDS,RC)        
      ISOL = IZ(IG0+2)        
      IF (ISOL .NE. RFNO) GO TO 6369        
      NS = IZ(IG0+3)        
      NC = IZ(IG0+4)        
      IF (IG0+4+4*NS .GT. LCORE) GO TO 9008        
      DO 465 I = 1,NS        
      CALL SUREAD (Z(IG0+1+4*I),3,NWDS,RC)        
      IZ(IG0+4*I+4) = -65535        
      DO 463 J = 1,NSS        
      IF (IZ(IG0+4*I+1) .NE. IZ(ICORE+2*J-2)) GO TO 463        
      IF (IZ(IG0+4*I+2) .NE. IZ(ICORE+2*J-1)) GO TO 463        
      IZ(IG0+4*I+4) = IZ(IG0+4*I+3)        
      GO TO 465        
  463 CONTINUE        
  465 CONTINUE        
      IF (RFNO.EQ.8 .OR. RFNO.EQ.9) GO TO 600        
      I = 1        
      CALL SJUMP (I)        
C        
C     STATICS SOLUTION ITEM        
C        
C     READ ALL GROUPS OF THE OLD FSS SOLN INTO OPEN CORE AT IGS.        
C     AS EACH ONE IS READ, ELIMINATE LOAD VECTORS WHICH DO NOT        
C     APPLY TO THE NEW SOLN BY SETTING THEIR LOAD VECTOR        
C     NUMBERS TO -65535.        
C     UPDATE THE NUMBER OF LOAD VECTORS WHICH DO APPLY.        
C        
      IGS = IG0 + 4*NS + 5        
      JGS = IGS        
      DO 478 I = 1,NC        
      CALL SUREAD (Z(JGS),1,NWDS,RC)        
      N = IABS(IZ(JGS))        
      IF (JGS+N*2 .GT. LCORE) GO TO 9008        
      CALL SUREAD (Z(JGS+1),-1,NWDS,RC)        
      NL = 0        
      IF (N .EQ. 0) GO TO 477        
      DO 475 J = 1,N        
      LVN = IZ(JGS+2*J-1)        
C        
C     FIND SUBSTRUCTURE WHERE LVN IS APPLIED FOR FSS SOLN ITEM.        
C        
      L1 = 0        
      L2 = 0        
      DO 470 K = 1,NS        
      IF (LVN .GT. L2+IZ(IG0+4*K+3)) GO TO 468        
      IF (IZ(IG0+4*K+4) .LT. 0) GO TO 471        
      LVN = LVN - L1        
      NL  = NL + 1        
      GO TO 472        
  468 IF (IZ(IG0+4*K+4) .LT. 0) L1 = L1 + IZ(IG0+4*K+3)        
      L2 = L2 + IZ(IG0+4*K+3)        
  470 CONTINUE        
  471 LVN = -65535        
  472 IZ(JGS+2*J-1) = LVN        
  475 CONTINUE        
      IF (IZ(JGS) .LT. 0) NL = -NL        
C     IF (IZ(JGS).LT.0 .AND. NL.EQ.0) NL = -65535        
      IZ(JGS) = NL        
  477 JGS = JGS + 2*N + 1        
  478 CONTINUE        
C        
C     WRITE THE NEW SOLN FOR THE RECOVERED SUBSTRUCTURE ON THE SOF.     
C     IN CASE USER FORGOT TO EDIT OUT THIS SOLN FROM A PREVIOUS        
C     RUN, DELETE IT TO AVOID LOSING OR SCREWING UP THE RECOVERED       
C     DISPLACEMENTS.        
C        
      CALL DELETE (LASTSS,SOLN,RC)        
      IZ(IG0+3) = NSS        
      RC = 3        
      CALL SFETCH (LASTSS,SOLN,SWRT,RC)        
      CALL SUWRT (Z(IG0),5,1)        
      DO 480 I = 1,NS        
      IF (IZ(IG0+4*I+4) .LT. 0) GO TO 480        
      CALL SUWRT (Z(IG0+4*I+1),2,1)        
      CALL SUWRT (Z(IG0+4*I+4),1,1)        
  480 CONTINUE        
      CALL SUWRT (0,0,EOG)        
      JGS = IGS        
      DO 488 I = 1,NC        
      K  = 0        
      NL = IZ(JGS)        
      JGS= JGS + 1        
      CALL SUWRT (NL,1,1)        
      IF (NL .EQ. 0) GO TO 485        
      NL = IABS(NL)        
  482 IF (IZ(JGS) .EQ. -65535) GO TO 484        
      CALL SUWRT (IZ(JGS),2,1)        
      K = K + 1        
  484 JGS = JGS + 2        
      IF (K .LT. NL) GO TO 482        
  485 IF (IZ(JGS) .NE. -65535) GO TO 486        
      JGS = JGS + 2        
      GO TO 485        
  486 CALL SUWRT (0,0,EOG)        
  488 CONTINUE        
      CALL SUWRT (0,0,EOI)        
      GO TO 498        
C        
C     MODAL SOLUTION ITEM        
C        
C     FOR MODAL COPY THE SOLN UNCHANGED.  IN CASE THE USER FORGOT       
C     TO EDIT OUT THIS SOLN FROM A PREVIOUS RUN, DELETE IT TO AVOID     
C     LOSING OR SCREWING UP THE RECOVERED DISPLACEMENTS.        
C        
  490 CALL DELETE (LASTSS,SOLN,RC)        
      CALL SFETCH (FSS,SOLN,SRD,RC)        
      CALL SUREAD (IZ(ICORE),-1,NWDS,RC)        
      ISOL = IZ(ICORE+2)        
      IF (ISOL .NE. RFNO) GO TO 6369        
      IF (IZ(ICORE+3) .GT. 0) GO TO 492        
      RC = 3        
      CALL SFETCH (LASTSS,SOLN,SWRT,RC)        
      CALL SUWRT (Z(ICORE),4,EOG)        
      CALL SUWRT (0,0,EOI)        
      GO TO 498        
  492 IF (LCORE .LT. ICORE+7*IZ(ICORE+3)+3) GO TO 9008        
      CALL SUREAD (IZ(ICORE+4),-1,NWDS,RC)        
      RC = 3        
      CALL SFETCH (LASTSS,SOLN,SWRT,RC)        
      CALL SUWRT (Z(ICORE),4,EOG)        
      CALL SUWRT (Z(ICORE+4),7*IZ(ICORE+3),EOG)        
      CALL SUWRT (0,0,EOI)        
      GO TO 498        
C        
C     DYNAMIC SOLUTION ITEM        
C        
C     READ IN STATIC LOAD SETS        
C        
  600 INCR = 1        
      IF (RFNO .EQ. 8) INCR = 2        
      IGS = IG0 + 4*NS + 5        
      CALL SUREAD (Z(IGS),1,NWDS,RC)        
      NSL = IZ(IGS)        
      LSL = NSL*INCR        
      NSLL= 0        
      IF (NSL .EQ. 0) GO TO 660        
      IF (IGS+NSL .GT. LCORE) GO TO 9008        
      CALL SUREAD (Z(IGS+1),NSL,NWDS,RC)        
C        
C     FLAG THOSE STATIC LOAD IDS THAT ARE NOT IN THE LOWER LEVEL        
C     SUBSTRUCTURE AND RENUMBER THOSE THAT ARE LEFT        
C        
      DO 650 J = 1,NSL        
      LVN = IZ(IGS+J)        
      L1  = 0        
      L2  = 0        
      DO 620 K = 1,NS        
      IF (LVN .GT. L2+IZ(IG0+4*K+3)) GO TO 610        
      IF (IZ(IG0+4*K+4) .LT. 0) GO TO 630        
      LVN  = LVN - L1        
      NSLL = NSLL + 1        
      GO TO 640        
  610 IF (IZ(IG0+4*K+4) .LT. 0) L1 = L1 + IZ(IG0+4*K+3)        
      L2 = L2 + IZ(IG0+4*K+3)        
  620 CONTINUE        
  630 LVN = -65535        
  640 IZ(IGS+J) = LVN        
  650 CONTINUE        
C        
C     COPY THE FREQUENCY OR TIME STEP RECORD INTO CORE        
C        
  660 I = 1        
      CALL SJUMP (I)        
      ISTEP = IGS + NSL + 1        
      IF (ISTEP+NC .GT. LCORE) GO TO 9008        
      CALL SUREAD (IZ(ISTEP),-1,NWDS,RC)        
C        
C     COPY IN ALL LOAD FACTOR DATA        
C        
      IF (NSLL .EQ. 0) GO TO 675        
      JGS = ISTEP + NC        
      DO 670 I = 1,NC        
      IF (JGS+LSL .GT. LCORE) GO TO 9008        
      CALL SUREAD (Z(JGS),-1,NWDS,RC)        
  670 JGS = JGS + LSL        
C        
C     WRITE THE NEW SOLN ITEM FOR THE RECOVERED SUBSTRUCTURE.  IN CASE  
C     THE USER FORGOT TO EDIT OUT THIS SOLN FROM A PREVIOUS RUN,        
C     DELETE IT TO AVOID LOSING OR SCREWING UP THE RECOVERED        
C     DISPLACEMENTS        
C        
  675 CALL DELETE (LASTSS,SOLN,RC)        
      RC = 3        
      CALL SFETCH (LASTSS,SOLN,SWRT,RC)        
      IZ(IG0+3) = NSS        
      CALL SUWRT (Z(IG0),5,1)        
      DO 680 I = 1,NS        
      IF (IZ(IG0+4*I+4) .LT. 0) GO TO 680        
      CALL SUWRT (Z(IG0+4*I+1),2,1)        
      CALL SUWRT (Z(IG0+4*I+4),1,1)        
  680 CONTINUE        
      CALL SUWRT (NSLL,1,1)        
      IF (NSLL .EQ. 0) GO TO 700        
      DO 690 I = 1,NSL        
      IF (Z(IGS+I) .LT. 0) GO TO 690        
      CALL SUWRT (Z(IGS+I),1,1)        
  690 CONTINUE        
  700 CALL SUWRT (0,0,EOG)        
C        
C     COPY THE TIME OR FREQUENCY STEP INFO TO SOF.        
C        
      CALL SUWRT (Z(ISTEP),NC,EOG)        
C        
C     COPY LOAD FACTORS FOR EACH STEP TO SOF EDITING OUT THOSE        
C     THAT NO LONGER PARTICIAPTE        
C        
      IF (NSLL .EQ. 0) GO TO 730        
      KGS = ISTEP + NC        
      DO 720 I = 1,NC        
      K = 1        
      DO 710 J = 1,NSL        
      IF (Z(IGS+J) .LT. 0) GO TO 710        
      CALL SUWRT (Z(KGS+K-1),INCR,1)        
      K = K + INCR        
  710 CONTINUE        
      CALL SUWRT (0,0,EOG)        
      KGS = KGS + LSL        
  720 CONTINUE        
C        
  730 CALL SUWRT (0,0,EOI)        
      GO TO 498        
C        
C     NORMAL RETURN        
C        
  498 RETURN        
C        
C     ERROR PROCESSING        
C        
 6369 WRITE (NOUT,63690) UFM,ISOL,RFNO        
      GO TO 9100        
 9008 N = 8        
      CALL MESAGE (N,0,NAME)        
 9100 IOPT = -1        
      CALL SOFCLS        
      RETURN        
C        
63690 FORMAT (A23,' 6369.  SOLN ITEM HAS INCORRECT RIGID FORMAT NUMBER',
     1       /31X,'SOLUTION RIGID FORMAT WAS',I5,        
     2       ' AND CURRENT NASTRAN EXECUTION RIGID FORMAT IS',I5)       
      END        
