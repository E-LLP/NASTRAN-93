      SUBROUTINE SDCMPS (ZI,ZR,ZD)        
C        
C     SDCMPS PERFORMS THE TRIANGULAR DECOMPOSITION OF A SYMMETRIC       
C     MATRIX. THE REAL MATRIX INPUT MAY BE SINGLE OR DOUBLE PRECISION.  
C     THE OUTPUT MATRICES HAVE POSITIVE DEFINATE CHECKS AND DIAGONAL    
C     SINGULARITY CHECKS        
C        
C     IF SYSTEM(57) IS .GT.1 - USED FOR -CLOS-,        
C                      .LT.0 - STOP AFTER PREPASS        
C        
      EXTERNAL          LSHIFT   ,ANDF     ,ORF        
      LOGICAL SPILL    ,SPLOUT   ,SPLIN    ,ROWONE   ,OPNSCR   ,FIRST   
      INTEGER ABLK     ,ANDF     ,ANY      ,BEGN     ,BBLK     ,BLK    ,
     1        BUF1     ,BUF2     ,BUF3     ,BUF4     ,BUF5     ,BUF6   ,
     2        C        ,CAVG     ,CHLSKY   ,CI       ,CLOS     ,CMAX   ,
     3        COL      ,C5MAX    ,DBA      ,DBC      ,DBL      ,END    ,
     4        DIAGCK   ,DIAGET   ,SYS60    ,HICORE   ,DBNAME(2)        ,
     5        EOR      ,FRSTPC   ,GROUPS   ,KEY(1)   ,ORF      ,ROW    ,
     6        PARM     ,PCAVG    ,PCGROU   ,PCMAX    ,PCROW    ,        
     7        PCSQR    ,PDEFCK   ,POWER    ,PRC      ,PREC     ,PREVC  ,
     8        RC       ,RLCMPX        
      INTEGER S        ,SAVG     ,SC       ,SCRA     ,SCRB     ,SCRC   ,
     1        SCRD     ,SCRDIA   ,SCRMSG   ,SCR1     ,SCR2     ,SCR3   ,
     2        SPFLG    ,SPROW    ,START    ,STATFL   ,STSCR    ,ZI(1)  ,
     3        SX       ,SYSBUF   ,SUBNAM(3),TYPEA    ,TWO24    ,TWO25  ,
     5        WA       ,WB       ,WORDS        
      REAL    MINDS    ,SAVE(4)  ,ZR(1)    ,DDRR(2)        
      DOUBLE PRECISION  DDIA     ,DDC      ,DDR      ,DMANT    ,DV     ,
     1        MINDD    ,PDEFD    ,ZD(1)        
      CHARACTER*10      UNUSE    ,ADDI     ,UNADD        
      CHARACTER         UFM*23   ,UWM*25   ,UIM*29   ,SFM*25        
      COMMON /XMSSG /   UFM      ,UWM      ,UIM      ,SFM        
      COMMON /MACHIN/   MACHX        
      COMMON /LHPWX /   LHPW(6)  ,MTISA        
      COMMON /SFACT /   DBA(7)   ,DBL(7)   ,DBC(7)   ,SCR1     ,SCR2   ,
     1                  LCORE    ,DDR      ,DDC      ,POWER    ,SCR3   ,
     2                  MINDD    ,CHLSKY        
      COMMON /NTIME /   NITEMS   ,TMIO     ,TMBPAK   ,TMIPAK   ,TMPAK  ,
     1                  TMUPAK   ,TMGSTR   ,TMPSTR   ,TMT(4)   ,TML(4)  
      COMMON /SYSTEM/   KSYSTM(100)        
      COMMON /NAMES /   RDNRW    ,RDREW    ,WRT      ,WRTREW   ,REW     
      COMMON /TYPE  /   PRC(2)   ,WORDS(4) ,RLCMPX(4)        
CZZ   COMMON /XNSTRN/   XNS(1)        
      COMMON /ZZZZZZ/   XNS(1)        
      COMMON /SDCOMX/   ROW      ,C        ,SPFLG    ,START    ,FRSTPC ,
     1                  LASTPL   ,LASTI    ,SC       ,IAC      ,NZZADR ,
     2                  WA       ,WB       ,PREVC    ,NZZZ     ,SPROW  ,
     3                  S        ,BLK(15)  ,ABLK(15) ,BBLK(20)        
      COMMON /SDCQ  /   NERR(2)  ,NOGLEV   ,BUF6     ,SCRMSG   ,SCRDIA ,
     1                  STSCR    ,PDEFCK   ,DIAGCK   ,DIAGET   ,PREC   ,
     2                  PARM(4)  ,OPNSCR   ,FIRST        
      COMMON /PACKX /   ITYPE1   ,ITYPE2   ,I1       ,J1       ,INCR1   
      COMMON /UNPAKX/   ITYPE3   ,I2       ,J2       ,INCR2        
      EQUIVALENCE       (NROW,DBA(3))  ,(TYPEA,DBA(5)) ,        
     1                  (JSTR,BLK(5))  ,(COL  ,BLK(4)) ,(NTERMS,BLK(6)),
     2                  (ROW ,KEY(1))  ,(DSR   ,DDR  ) ,        
     3                  (DSC,DDC)      ,(MINDS,MINDD ) ,(DDRR(1),RDIA ),
     4                  (DV,RV) ,(DMANT,RMANT),(DDIA,RDIA),(PDEFD,PDEFR)
      EQUIVALENCE       (KSYSTM( 1),SYSBUF) ,(KSYSTM( 2),NOUT) ,        
     1                  (KSYSTM(31),HICORE) ,(KSYSTM(40),NBPW) ,        
     2                  (KSYSTM(60),SYS60 )        
      DATA    UNUSE  ,  ADDI  /'    UNUSED', 'ADDITIONAL' /        
      DATA    SUBNAM /  4HSDCM,2HPS, 1H   /,        
     1        NKEY   /  6 / ,BEGN/ 4HBEGN /,  END/ 4HEND  /,        
     2        TWO24  /  16777216 /, TWO25 /   33554432    /        
C        
C     STATEMENT FUNCTIONS        
C        
      NBRWDS(I) = I + NWDS*(I*(I+1))/2        
      SX(X)     = X - SQRT(AMAX1(X*(X+4.0)-CONS,0.0)) - 1.0        
      MAXC(J)   = (SQRT(2.*FNWDS*FLOAT(J))-3.0)/FNWDS        
C        
C     VAX, UNIVAC, AND ALL WORKSTATIONS - OPEN CORE CAN BE INCREASED    
C     LOCALLY FOR SDCOMP BY SYS60        
C        
      X = 1.0        
      KORCHG = 0        
      IF (SYS60.EQ.0 .OR. MACHX.EQ.2 .OR. NBPW.GT.36) GO TO 20        
      KORCHG = SYS60 - HICORE        
      IF (KORCHG .LE. 0) GO TO 20        
      LCORE = LCORE + KORCHG        
      WRITE  (NOUT,10) UIM,SYS60        
   10 FORMAT (A29,' - OPEN CORE FOR SDCOMP IS INCREASED TO',I8,        
     1       ' WORDS BY SYSTEM(60)',/)        
   20 IF (LCORE .LE. 0) CALL MESAGE (-8,0,SUBNAM)        
C        
C     BUFFER ALLOCATION        
C        
      BUF1 = LCORE- SYSBUF        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      BUF4 = BUF3 - SYSBUF        
      BUF5 = BUF4 - SYSBUF        
      BUF6 = BUF5 - SYSBUF        
C        
C     INITIALIZATION AS A FUNCTION OF TYPE OF A MATRIX        
C     RC   = 1 IF A IS REAL (2 IF A IS COMPLEX - ILLEGAL)        
C     PREC = 1 IF A IS SINGLE, 2 IF A IS DOUBLE        
C        
      RC    = RLCMPX(TYPEA)        
      IF (RC .NE. 1) GO TO 1600        
      STATFL= IABS(KSYSTM(57))        
      PREC  = PRC(TYPEA)        
      NWDS  = WORDS(TYPEA)        
      FNWDS = NWDS        
C        
C     CHECK INPUT PARAMETERS        
C        
      IF (DBA(2) .NE. DBA(3)) GO TO 1600        
      ICRQ = NROW + 200 - BUF6        
      IF (ICRQ .GT. 0) GO TO 1850        
C        
C     INITIALIZE POSITIVE DEFINATE CHECKS.  FILES SET IN DRIVER        
C        
      PARM(1) = 0        
      PARM(3) = SUBNAM(1)        
      PARM(4) = SUBNAM(2)        
      NERR(1) = 0        
      NERR(2) = 0        
      IF (PDEFCK .LT. 0) GO TO 50        
      I = -DIAGET        
      J = 1 - MTISA        
      IF (PREC .EQ. 2) GO TO 30        
      PDEFR = 2.0E0**I        
      RMANT = 2.0E0**J        
      GO TO 50        
   30 PDEFD = 2.0D0**I        
      DMANT = 2.0D0**J        
      GO TO 50        
   50 CONTINUE        
C        
C     STSCR IS STATUS OF -SCRDIA- FILE AT BUF6        
C       0 = NOT OPEN        
C       1 = READ        
C       2 = WRITE        
C        
      STSCR = 2        
      CALL GOPEN (SCRDIA,ZI(BUF6),WRTREW)        
      SCRA = SCR3        
      SCRB = IABS(DBC(1))        
      NOGLEV = 0        
      IF (NROW .EQ. 1) GO TO 1510        
C        
C     GENERAL INITIALIZATION        
C        
      LOOP  = 1        
      ISPILL= BUF6 - MAX0(100,NROW/100)        
      FCMAX = 0.        
   60 ISPILL= ISPILL - (LOOP-1)*NROW/100        
      NSPILL= ISPILL        
      KROW  = NROW + 1        
      ICRQ  = (3-LOOP)*NROW/100 - ISPILL        
      IF (ISPILL .LE. 0) GO TO 1850        
      ZI(ISPILL) = 0        
      PCGROU= 0        
      PCAVG = 0        
      PCSQR = 0        
      PCMAX = 0        
      CSQR  = 0.0        
      SAVG  = 0        
      CLOS  = ALOG(FLOAT(NROW)) + 5.0        
      IF (STATFL .GT. 1) CLOS = STATFL        
      PCROW = -CLOS        
      ZI(1) = -NROW        
      DO 70 I = 2,NROW        
   70 ZI(I) = 0        
      CALL FNAME (DBA,DBNAME)        
      POWER = 0        
      SPILL = .FALSE.        
      GROUPS= 0        
      CONS  = 2*ISPILL/NWDS        
      C5MAX = MAXC(ISPILL)        
      DSR   = 1.0        
      DSC   = 0.        
      MINDS = 1.E+25        
      IF (PREC .EQ. 1) GO TO 80        
      DDR   = 1.0D0        
      DDC   = 0.D0        
      MINDD = 1.D+25        
   80 CONTINUE        
      CAVG  = 0        
      CMAX  = 0        
      CSPILL= 0.0        
C        
C     THE FOLLOWING CODE GENERATES THE ACTIVE COLUMN VECTOR FOR EACH    
C     ROW, SPILL GROUPS AND TIMING AND USER INFORMATION ABOUT THE       
C     DECOMPOSITION        
C        
      BLK(1)  = DBA(1)        
      ABLK(1) = SCRA        
      ABLK(2) = TYPEA        
      ABLK(3) = 0        
      CALL GOPEN (DBA ,ZI(BUF1),RDREW )        
      CALL GOPEN (SCRA,ZI(BUF2),WRTREW)        
      ROW = 1        
      JJ  = 0        
      EOR = 1        
C        
C     LSTDIA DETERMINES THE LAST DIAGONAL WRITTEN TO SCRATCH FILE       
C        
      LSTDIA = 0        
C        
C     BEGIN A ROW BY LOCATING THE DIAGONAL ELEMENT        
C        
   90 BLK(8) = -1        
C        
C     ANY DETERMINES IF ANY STRINGS SKIPPED PRIOR TO DIAGONAL        
C     AND -KK- ALLOWS STRING BEYOND ZERO DIAGONAL TO BE SAVED        
C        
      ANY = 0        
      KR  = KROW        
  100 CALL GETSTR (*110,BLK)        
      IF (PREC .EQ. 2) JSTR = 2*(JSTR-1) + 1        
      KK  = NTERMS        
      ANY = COL        
      IF (COL.GT.ROW) GO TO 130        
      KK  = 0        
      IF (COL+NTERMS-1 .GE. ROW) GO TO 140        
      CALL ENDGET (BLK)        
      GO TO 100        
C        
C     NULL COLUMN FOUND.  SAVE COLUMN ID AND SET NOGLEV        
C        
  110 KK = -1        
      IF (ANY .NE. 0) GO TO 130        
      IF (LSTDIA .LT. ROW) CALL SDCMQ (*710,1,0.,0.,0.D0,0.D0,ROW,ZI)   
  120 IF (BLK(8) .NE. 1) CALL FWDREC (*1680,BLK)        
      ROW = ROW + 1        
      IF (ROW .LE. NROW) GO TO 90        
      GO TO 710        
C        
C     ZERO DIAGONAL FOUND.  FILL CORE AND POINTERS        
C        
  130 COL = ROW        
      ZI(KR  ) = COL        
      ZI(KR+1) = 1        
      ZI(KR+2) = 0        
      IF (NWDS .EQ. 2) ZI(KR+3) = 0        
      KR = KR + 2 + NWDS        
      NTERMS = NWDS        
      IF (LSTDIA .GE. ROW) GO TO 140        
      DDIA = 0.0D0        
      CALL SDCMQ (*710,7,0.,0.,0.D0,0.D0,ROW,ZI)        
      IF (NOGLEV .GT. 1) GO TO 120        
      CALL WRITE (SCRDIA,RDIA,NWDS,EOR)        
      LSTDIA = ROW        
      GO TO 180        
C        
C     DIAGONAL TERM IS LOCATED -- COMPLETE ENTRIES IN THE FULL COLUMN   
C     VECTOR AND SAVE THE TERMS FROM EACH STRING IN CORE        
C        
  140 CONTINUE        
      JSTR = JSTR + (ROW-COL)*NWDS        
      IF (LSTDIA .GE. ROW) GO TO 150        
      RDIA = XNS(JSTR)        
      IF (PREC .EQ. 2) DDRR(2) = XNS(JSTR+1)        
      IF (NOGLEV .LE. 1) CALL WRITE (SCRDIA,RDIA,NWDS,EOR)        
      LSTDIA = ROW        
  150 CONTINUE        
      NTERMS = NTERMS - (ROW-COL)        
      COL = ROW        
  160 ZI(KR  ) = COL        
      ZI(KR+1) = NTERMS        
      KR = KR + 2        
      NSTR = JSTR + NTERMS*NWDS - 1        
      DO 170 JJ = JSTR,NSTR        
      ZR(KR) = XNS(JJ)        
      KR = KR + 1        
  170 CONTINUE        
  180 CONTINUE        
      N = COL + NTERMS - 1        
      DO 240 J = COL,N        
      IF (ZI(J)) 190,200,230        
  190 M = IABS(ZI(J))        
      ZI(J) = ROW        
      IF (M .NE. 1) ZI(J+1) = -(M-1)        
      GO TO 240        
  200 I = J        
  210 I = I - 1        
      IF (I .LE. 0) GO TO 1610        
      IF (ZI(I)) 220,210,1620        
  220 M = IABS(ZI(I))        
      ZI(I) = -(J-I)        
      ZI(J) = ROW        
      LEFT  = M - (J-I+1)        
      IF (LEFT .GT. 0) ZI(J+1) = -LEFT        
      GO TO 240        
  230 IF (ZI(J).GT.ROW .AND. ZI(J).LT.TWO24) ZI(J) = ZI(J) +TWO24 +TWO25
  240 CONTINUE        
      ICRQ = KR - ISPILL        
      IF (KR .GE. ISPILL) GO TO 700        
C        
C     CHECK IF ZERO DIAGONAL WAS JUST PROCESSED        
C        
      IF (KK) 270,250,260        
  250 CALL ENDGET (BLK)        
      CALL GETSTR (*280,BLK)        
      IF (PREC .EQ. 2) JSTR = 2*JSTR - 1        
      GO TO 160        
  260 COL = ANY        
      NTERMS = KK        
      KK = 0        
      GO TO 140        
C        
C     EXTRACT ACTIVE COLUMN VECTOR FROM THE FULL COLUMN VECTOR        
C        
  270 IF (BLK(8) .NE. 1) CALL FWDREC (*1680,BLK)        
  280 IAC = KR        
      I = IAC        
      J = ROW        
      LASTPL = -1        
  290 IF (ZI(J)) 360,1630,300        
  300 IF (ZI(J)-ROW) 310,320,350        
  310 ZI(I) = J        
      GO TO 330        
  320 ZI(I) = -J        
      IF (LASTPL .LT. 0) LASTPL = I - IAC        
  330 I = I + 1        
  340 J = J + 1        
      GO TO 370        
  350 IF (ZI(J) .LT. TWO24) GO TO 340        
      IF (ZI(J) .LT. TWO25) GO TO 310        
      ZI(J) = ZI(J) - TWO25        
      GO TO 320        
  360 J = J - ZI(J)        
  370 IF (J .LE. NROW) GO TO 290        
      ICRQ = I - ISPILL        
      IF (I .GT. ISPILL) GO TO 700        
      C = I - IAC        
      CMAX = MAX0(CMAX,C)        
      NAC = IAC + C - 1        
      IF (LASTPL .LT. 0) LASTPL = C        
C        
C     MAKE SPILL CALCULATIONS        
C        
      SPFLG = 0        
      FC    = C        
      START = 2        
      IF (C .EQ. 1) START = 0        
      FRSTPC = 0        
      IF (.NOT. SPILL) GO TO 490        
      IF (ROW .LT. LSTROW) GO TO 410        
C        
C *3* CURRENT ROW IS LAST ROW OF A SPILL GROUP. DETERMINE IF ANOTHER    
C     SPILL GROUP FOLLOWS AND, IF SO, ITS RANGE        
C        
  400 CONTINUE        
      START = 0        
      IF (C .GT. C5MAX) GO TO 500        
      SPILL = .FALSE.        
      GO TO 540        
C        
C *2* CURRENT ROW IS NEITHER FIRST NOR LAST IN CURRENT SPILL GROUP.     
C     TEST FOR PASSIVE COL CONDITION. IF SO, TERMINATE SPILL GROUP.     
C     TEST FOR POSSIBLE REDEFINITION OF SPILL GROUP. IF SO, TEST FOR    
C     OVERFLOW OF REDEFINITION TABLE,  IF SO, TRY A DIFFERENT STRATEGY  
C     FOR DEFINING S AND REDO PREFACE UP TO A LIMIT OF 3 TIMES.        
C        
  410 CONTINUE        
      IF (IABS(ZI(IAC+1))-ROW .LT. CLOS) GO TO 420        
      ASSIGN 550 TO ISWTCH        
      LSTROW= ROW        
      SPILL = .FALSE.        
      START = 0        
      IF (NSPILL+2 .LT. BUF6) GO TO 470        
      GO TO 450        
  420 ASSIGN 580 TO ISWTCH        
      IF (C .LE. ZI(SPROW)) GO TO 580        
      JJ = NAC        
  430 IF (IABS(ZI(JJ)) .LE. LSTROW) GO TO 440        
      JJ = JJ - 1        
      GO TO 430        
  440 SC = JJ - IAC        
      M  = SX(FC)        
      IF (SC .LE. M) GO TO 580        
      IF (NSPILL+2 .LT. BUF6) GO TO 460        
  450 CONTINUE        
      FCMAX = AMAX1(FCMAX,FLOAT(CMAX))        
      CALL CLOSE (SCRA,REW)        
      CALL CLOSE (DBA ,REW)        
      LOOP = LOOP + 1        
      IF (LOOP .LE. 3) GO TO 60        
      ICRQ = BUF6 - NSPILL - 3        
      GO TO 1850        
  460 S = M        
      IJKL = MAX0(IAC,JJ - (SC-M))        
      LSTROW = IABS(ZI(IJKL))        
  470 IF (ZI(NSPILL).NE.0 .AND. ZI(NSPILL).NE.SPROW) NSPILL = NSPILL + 3
      ZI(NSPILL  ) = SPROW        
      ZI(NSPILL+1) = S        
      ZI(NSPILL+2) = LSTROW        
      IF (ROW-LSTROW) 480,400,1670        
  480 CONTINUE        
      GO TO ISWTCH, (550,580)        
C        
C *1* CURRENT ROW IS NOT PART OF A SPILL GROUP. TEST FOR        
C     CREATION OF A NEW SPILL GROUP        
C        
  490 CONTINUE        
      IF (C .LE. C5MAX) GO TO 540        
  500 SPILL = .TRUE.        
      SPROW = ROW        
      GROUPS= GROUPS + 1        
      S = MIN0(SX(FC),NROW-SPROW)        
      IF (LOOP .EQ. 1) GO TO 530        
      JJ = IAC + S - 1        
  510 IF (IABS(ZI(JJ)) .LE. SPROW+S) GO TO 520        
      JJ = JJ - 1        
      GO TO 510        
  520 S = JJ - IAC + 1        
      IF (LOOP .EQ. 3) S = MIN0(S,SX(FCMAX))        
  530 S = MIN0(S,NROW-SPROW)        
      LSTROW = IABS(ZI(IAC+S-1))        
      SPFLG  = S        
      FRSTPC = LSTROW        
      SAVG   = SAVG + S        
      GO TO 580        
C        
C     TEST FOR CONDITION IN WHICH PASSIVE COLUMNS ARE CREATED        
C        
  540 COL = IABS(ZI(IAC+1))        
      IF (ROW-PCROW.LT.CLOS .OR. C.LT.CLOS/2 .OR. COL-ROW.LT.CLOS)      
     1    GO TO 580        
C        
C     CREATE PASSIVE COLUMNS BY CHANGING THEIR FIRST        
C     APPEARANCE IN THE FULL COLUMN VECTOR        
C        
  550 FRSTPC= 2        
      PCROW = ROW        
      PCAVG = PCAVG + C - 1        
      PCSQR = PCSQR + (C-1)**2        
      PCMAX = MAX0(PCMAX,C-1)        
      PCGROU= PCGROU + 1        
      NAC   = IAC + C - 1        
      IJKL  = IAC + 1        
      DO 570 I = IJKL,NAC        
      JJ = IABS(ZI(I))        
      IF (ZI(JJ) .LE. ROW) GO TO 560        
      ZI(JJ) = MIN0(ANDF(ZI(JJ),TWO24-1),COL)        
      GO TO 570        
  560 ZI(JJ) = COL        
  570 CONTINUE        
C        
C     WRITE ACTIVE COLUMN VECTOR        
C        
  580 IF (NOGLEV .GT. 1) GO TO 630        
      CALL WRITE (SCRA,KEY,NKEY,0)        
      CALL WRITE (SCRA,ZI(IAC),C,1)        
C        
C     WRITE ROW OF INPUT MATRIX. -IAC- POINTS TO END OF OUTPUT        
C        
      ABLK(8)  = -1        
      ABLK(12) = ROW        
      KR = KROW        
  590 ABLK(4)= ZI(KR)        
      NBRSTR = ZI(KR+1)        
      KR = KR + 2        
  600 CALL PUTSTR (ABLK)        
      ABLK(7) = MIN0(ABLK(6),NBRSTR)        
      JSTR = ABLK(5)        
      IF (PREC .EQ. 2) JSTR = 2*JSTR - 1        
      NSTR = JSTR + ABLK(7)*NWDS - 1        
      DO 610 JJ = JSTR,NSTR        
      XNS(JJ) = ZR(KR)        
      KR = KR + 1        
  610 CONTINUE        
      IF (KR .GE. IAC) GO TO 620        
      CALL ENDPUT (ABLK)        
      IF (ABLK(7) .EQ. NBRSTR) GO TO 590        
      ABLK(4) = ABLK(4) + ABLK(7)        
      NBRSTR  = NBRSTR  - ABLK(7)        
      GO TO 600        
  620 ABLK(8) = 1        
      CALL ENDPUT (ABLK)        
C        
C     ACCUMULATE TIMING AND STATISTICS INFORMATION        
C        
  630 CAVG = CAVG + C        
      CSQR = CSQR + C**2        
      IF (SPILL) CSPILL = CSPILL + C**2        
      ZI(ROW) = C        
      IF (ROW .EQ. NROW) GO TO 710        
      ROW = ROW + 1        
      GO TO 90        
C        
C     HERE WHEN ALL ROWS PROCESSED -- CLOSE FILES AND, IF SINGULAR      
C     MATRIX, PRINT SINGULAR COLUMNS AND GIVE ALTERNATE RETURN        
C        
  700 PARM(1) = -8        
      PARM(2) = ICRQ        
      NOGLEV  = 2        
  710 CALL CLOSE (SCRA,REW)        
      CALL CLOSE (DBA ,REW)        
      CALL CLOSE (SCRDIA,REW)        
C        
C     CALCULATE TIME ESTIMATE, PRINT USER INFORMATION AND        
C     CHECK FOR SUFFICIENT TIME TO COMPLETE DECOMPOSITION        
C        
      IF (GROUPS .NE. 0) SAVG = SAVG/GROUPS        
      SAVG    = MAX0(SAVG,1)        
      SAVE(1) = 0.5*TMT(TYPEA)*CSQR*1.0E-6        
      SAVE(2) = 0.5*(TMPSTR+TMGSTR)*FLOAT(PCSQR)*1.E-6        
      SAVE(3) = TMPSTR*FLOAT(CAVG)*1.E-6        
      SAVE(4) = TMIO*(FNWDS+1.0)*CSPILL/FLOAT(SAVG)*1.0E-6        
      MORCOR  = NBRWDS(CMAX) - ISPILL + 1        
C        
      CAVG = CAVG/NROW        
      IF (PCGROU .NE. 0) PCAVG = PCAVG/PCGROU        
      CALL TMTOGO (IJKL)        
      JKLM = SAVE(1) + SAVE(2) + SAVE(3) + SAVE(4) + 1.0        
C        
      IF (DBC(1) .GT. 0) CALL PAGE2 (9)        
      UNADD = UNUSE        
      IF (MORCOR .GT. 0) UNADD = ADDI        
      IF (DBC(1) .GT. 0) WRITE (NOUT,720)  UIM,   DBNAME,   NROW,       
     1                      JKLM,   CAVG,  PCAVG, GROUPS,   SAVG,       
     2        UNADD,      MORCOR,   CMAX,  PCMAX, PCGROU,   LOOP        
  720 FORMAT (A29,' 3023 - PARAMETERS FOR SYMMETRIC DECOMPOSITION OF ', 
     1       'DATA BLOCK ',2A4,6H ( N = , I5, 2H ) , /        
     2  14X, 17H  TIME ESTIMATE = , I7, 17H          C AVG = , I6,      
     3       17H         PC AVG = , I6,18H    SPILL GROUPS = , I6,      
     4       17H          S AVG = , I6, /        
     5  14X, A10 ,      7H CORE = , I7, 17H WORDS    C MAX = , I6,      
     6       17H          PCMAX = , I6,18H       PC GROUPS = , I6,      
     7       17H  PREFACE LOOPS = , I6  )        
      IF (MORCOR .GT. 0) WRITE (NOUT,730)        
  730 FORMAT (15X,'(FOR OPTIMIZED OPERATION)')        
      IF (DBC(1) .GT. 0) WRITE (NOUT,740) UIM,SUBNAM(1),SUBNAM(2),SAVE  
  740 FORMAT (A29,' 2378,',A4,A3,' ESTIMATE OF CPU TIME FOR MT =',      
     1        1P,E10.3,/18X,'PASSIVE COL. = ',E10.3,14X,'ACTIVE COL. =',
     2        E10.3, /25X,'SPILL = ',E10.3)        
C        
C     ESTIMATE FBS TIME AT ONE PASS, 1 LOAD        
C        
      SAVE(1) = 2.0*FLOAT(NROW)*CAVG*(TMT(TYPEA)+TMPSTR)*1.E-6        
      IF (DBC(1) .GT. 0) WRITE (NOUT,750) SAVE(1)        
  750 FORMAT (10X,41HESTIMATE FOR FBS, ONE PASS AND ONE LOAD =,1P,E10.3)
C        
      IF (JKLM .GE. IJKL) GO TO 1840        
      IF (NOGLEV .GT.  1) GO TO 1880        
      IF (KSYSTM(57) .LT. 0) GO TO 1880        
C        
C     WRITE A END-OF-MATRIX STRING ON THE PASSIVE COLUMN FILE        
C        
      CALL GOPEN (SCRB,ZI(BUF2),WRTREW)        
      BBLK(1) = SCRB        
      BBLK(2) = TYPEA        
      BBLK(3) = 0        
      BBLK(8) = -1        
      CALL PUTSTR (BBLK)        
      BBLK(4) = NROW + 1        
      BBLK(7) = 1        
      BBLK(8) = 1        
      CALL ENDPUT (BBLK)        
      CALL CLOSE (SCRB,REW)        
      SUBNAM(3) = BEGN        
      CALL CONMSG (SUBNAM,3,0)        
C        
C     THE STAGE IS SET AT LAST TO PERFORM THE DECOMPOSITION -        
C     SO LETS GET THE SHOW UNDERWAY        
C        
      CALL GOPEN (SCRA,ZI(BUF1),RDREW )        
      CALL GOPEN (SCRB,ZI(BUF2),RDREW )        
      CALL GOPEN (DBL ,ZI(BUF3),WRTREW)        
      CALL GOPEN (SCRDIA,ZI(BUF6),RDREW)        
      STSCR = 1        
      SCRC  = SCR1        
      SCRD  = SCR2        
      IF (ZI(NSPILL) .NE. 0) NSPILL = NSPILL + 3        
      ZI(NSPILL) = NROW + 1        
      SPLIN  = .FALSE.        
      SPLOUT = .FALSE.        
      SPILL  = .FALSE.        
      IF (GROUPS .NE. 0) SPILL = .TRUE.        
      NZZZ   = ORF(ISPILL-1,1)        
      ROWONE = .FALSE.        
      DBL(2) = 0        
      DBL(6) = 0        
C     DBL(7) = LSHIFT(1,NBPW-2)        
      DBL(7) = LSHIFT(1,NBPW-2 - (NBPW-32))        
C        
C     THIS 'NEXT TO SIGN' BIT WILL BE PICKED UP BY WRTTRL. ADD (NBPW-32)
C     SO THAT CRAY, WITH 48-BIT INTEGER, WILL NOT GET INTO TROUBLE      
C        
      BLK(1) = DBL(1)        
      BLK(2) = TYPEA        
      BLK(3) = 1        
      WA     = NZZZ        
      WB     = WA        
      PREVC  = 0        
      BBLK(8)= -1        
      CALL GETSTR (*1690,BBLK)        
      KSPILL = ISPILL        
C        
C     READ KEY WORDS AND ACTIVE COLUMN VECTOR FOR CURRENT ROW        
C        
  800 NAME = SCRA        
      IF (SPLIN) NAME = SCRD        
      CALL FREAD (NAME,KEY,NKEY,0)        
      IAC = C*NWDS + 1        
      CALL FREAD (NAME,ZI(IAC),C,1)        
      NAC = IAC + C - 1        
      IF (ZI(IAC) .LT. 0) PREVC = 0        
      IF (SPLIN) GO TO 840        
C        
C     READ TERMS FROM THE INPUT MATRIX        
C        
      CALL FREAD (SCRDIA,RDIA,NWDS,EOR)        
      ABLK(8) = -1        
      CALL GETSTR (*1860,ABLK)        
      N = IAC - 1        
      DO 810 I = 1,N        
      ZR(I) = 0.        
  810 CONTINUE        
      CALL SDCINS (*1830,ABLK,ZI(IAC),C,ZR,ZD)        
C        
C     IF DEFINED, MERGE ROW FROM PASSIVE COLUMN FILE        
C        
  820 IF (ROW-BBLK(4)) 850,830,1700        
  830 CALL SDCINS (*1830,BBLK,ZI(IAC),C,ZR,ZD)        
      BBLK(8) = -1        
      CALL GETSTR (*1710,BBLK)        
      GO TO 820        
C        
C     READ CURRENT PIVOT ROW FROM SPILL FILE. IF LAST ROW, CLOSE FILE   
C        
  840 PREVC = 0        
      CALL FREAD (SCRD,ZR,C*NWDS,1)        
      IF (ROW .LT. LSTSPL) GO TO 850        
      CALL CLOSE (SCRD,REW)        
C        
C     IF 1ST ROW OF A NEW SPILL GROUP, OPEN SCRATCH FILE TO WRITE       
C        
  850 IF (ROWONE) GO TO 880        
      IF (SPLOUT) GO TO 950        
      IF (SPFLG .EQ. 0) GO TO 950        
      SPLOUT = .TRUE.        
      CALL GOPEN (SCRC,ZI(BUF4),WRTREW)        
      SPROW = ROW        
      S = SPFLG        
      LSTROW = FRSTPC        
      FRSTPC = 0        
C        
C     IF S WAS REDEFINED, GET NEW DEFINITION        
C        
      DO 860 I = KSPILL,NSPILL,3        
      IF (ROW-ZI(I)) 860,870,880        
  860 CONTINUE        
      GO TO 880        
  870 S = ZI(I+1)        
      LSTROW = ZI(I+2)        
      KSPILL = I + 3        
C        
C     WRITE ANY TERMS ALREADY CALCULATED WHICH ARE        
C     BEYOND THE RANGE OF THE CURRENT SPILL GROUP        
C        
  880 IF (.NOT. SPLOUT) GO TO 950        
      N = 0        
      IJKL = NAC        
  890 IF (IABS(ZI(IJKL)) .LE. LSTROW) GO TO 900        
      IJKL = IJKL - 1        
      GO TO 890        
  900 IJKL = IJKL + 1        
      IF (IJKL .GT. NAC) GO TO 920        
      DO 910 I = IJKL,NAC        
      IF (ZI(I) .GT. 0.) N = N + 1        
  910 CONTINUE        
      N = NWDS*N*(N+1)/2        
  920 CALL WRITE (SCRC,N,1,0)        
      CALL WRITE (SCRC,ZR(NZZZ-N),N,1)        
C        
C     MOVE WA TO ACCOUNT FOR ANY TERMS JUST WRITTEN        
C        
      IF (N .EQ. 0) GO TO 950        
      J = NZZZ        
      I = NZZZ - N        
      IF ((NZZZ-WA) .EQ. N) GO TO 940        
  930 J = J - 1        
      I = I - 1        
      ZR(J) = ZR(I)        
      IF (I .GT. WA) GO TO 930        
  940 WA = J        
C        
C     IF THE PIVOTAL ROW DID NOT COME FROM THE SPILL FILE, IT IS CREATED
C        
  950 IF (SPLIN) GO TO 1180        
      I = IAC        
      L = WA        
      IF (PREC  .EQ. 2) L = (WA-1)/2 + 1        
      IF (TYPEA .EQ. 2) GO TO 1060        
C        
C     CREATE PIVOT ROW IN RSP, ACCUMULATE DETERMINANT AND MIN DIAGONAL  
C        
      IF (ZI(IAC) .LT. 0) GO TO 980        
      DO 970 J = 1,C        
      IF (ZI(I) .LT. 0) GO TO 960        
      ZR(J) = ZR(J) + ZR(L)        
      L = L + 1        
  960 I = I + 1        
  970 CONTINUE        
  980 CONTINUE        
C        
C     CHECK DIAGONAL AND CORRECT        
C        
      IF (ZR(1) .EQ. 0.0) CALL SDCMQ (*1870,2,RDIA,ZR(1),0,0,ROW,ZI)    
  990 IF (ABS(DSR) .LT. 10.) GO TO 1000        
      DSR   = DSR/10.        
      POWER = POWER + 1        
      GO TO 990        
 1000 IF (ABS(DSR) .GT. 0.1) GO TO 1010        
      DSR   = DSR*10.        
      POWER = POWER - 1        
      GO TO 1000        
 1010 DSR   = DSR*ZR(1)        
      MINDS = AMIN1(ZR(1),MINDS)        
C        
C     PERFORM MATRIX COND. CHECKS - S.P. REAL        
C        
      IF (ZR(1)) 1020,1030,1050        
 1020 I = 3        
      GO TO 1040        
 1030 I = 2        
 1040 CALL SDCMQ (*1870,I,RDIA,ZR(1),0,0,ROW,ZI)        
C        
 1050 IF (DIAGCK .LT. 0) GO TO 1170        
      IF (RDIA .EQ. 0.0) RDIA = ZR(1)        
      IF (RDIA .EQ. ZR(1)) GO TO 1170        
      RV = ABS(ZR(1)/RDIA )        
      IF (RV .GT. 1.001E0) CALL SDCMQ (*1870,6,RDIA,ZR(1),0,0,ROW,ZI)   
      RV = RMANT/RV        
      IF (RV .GT. PDEFR) CALL SDCMQ (*1870,4,RDIA,ZR(1),0,0,ROW,ZI)     
      GO TO 1170        
C        
C     CREATE PIVOT ROW IN RDP, ACCUMULATE DETERMINANT AND MIN DIAGONAL  
C        
 1060 CONTINUE        
      IF (ZI(IAC) .LT. 0) GO TO 1090        
      DO 1080 J = 1,C        
      IF (ZI(I) .LT. 0) GO TO 1070        
      ZD(J) = ZD(J) + ZD(L)        
      L = L + 1        
 1070 I = I + 1        
 1080 CONTINUE        
 1090 CONTINUE        
C        
C     CHECK DIAGONAL AND CORRECT        
C        
      IF (ZD(1) .EQ. 0.0D0) CALL SDCMQ (*1870,2,0,0,DDIA,ZD(1),ROW,ZI)  
 1100 IF (DABS(DDR) .LT. 10.0D0) GO TO 1110        
      DDR   = DDR/10.D0        
      POWER = POWER + 1        
      GO TO 1100        
 1110 IF (DABS(DDR) .GT. 0.1D0) GO TO 1120        
      DDR   = DDR*10.D0        
      POWER = POWER - 1        
      GO TO 1110        
 1120 DDR   = DDR*ZD(1)        
      MINDD = DMIN1(ZD(1),MINDD)        
C        
C     PERFORM MATRIX COND. CHECKS - D.P. REAL        
C        
      IF (ZD(1)) 1130,1140,1160        
 1130 I = 3        
       GO TO 1150        
 1140 I = 2        
 1150 CALL SDCMQ (*1870,I,0,0,DDIA,ZD(1),ROW,ZI)        
C        
 1160 IF (DIAGCK .LT.   0) GO TO 1170        
      IF (DDIA .EQ. 0.0D0) DDIA = ZD(1)        
      IF (DDIA .EQ. 0.0D0) GO TO 1170        
      DV = DABS(ZD(1)/DDIA)        
      IF (DV .GT. 1.001D0) CALL SDCMQ (*1870,6,0,0,DDIA,ZD(1),ROW,ZI)   
      DV = DMANT/DV        
      IF (DV .GT. PDEFD) CALL SDCMQ (*1870,4,0,0,DDIA,ZD(1),ROW,ZI)     
C        
C     CALCULATE WB        
C        
 1170 CONTINUE        
 1180 LASTI = 1        
      IF (START .EQ. 0) GO TO 1260        
      IF (SPLIN ) GO TO 1190        
      IF (SPLOUT) GO TO 1200        
      CI = C        
      SC = C        
      GO TO 1230        
 1190 CI = C - (START-2)        
      SC = CI        
      JJ = NAC        
      IF (SPLOUT) GO TO 1210        
      IF (CI .GT. C5MAX) GO TO 1720        
      GO TO 1230        
 1200 CI = C        
      SC = LSTROW - SPROW        
      JJ = MIN0(NAC,IAC+START+SC-2)        
 1210 IF (IABS(ZI(JJ)) .LE. LSTROW) GO TO 1220        
      JJ = JJ - 1        
      GO TO 1210        
 1220 SC = JJ - IAC - START + 2        
      IF (SC .GT. 0) GO TO 1230        
      SC = 0        
      WB = WA        
      GO TO 1240        
 1230 NTERMS = SC*(CI-1) - (SC*(SC-1))/2        
      NWORDS = NTERMS*NWDS        
      WB = NZZZ - NWORDS        
      IF (PREC .EQ. 2) WB = ORF(WB-1,1)        
      IF (WB .LT. IAC+C) GO TO 1660        
      IF (WB .GT. WA+NWDS*PREVC) GO TO 1730        
 1240 CONTINUE        
      IF (SPLIN .AND. ROW.EQ.LSTSPL) SPLIN = .FALSE.        
      LASTI = MIN0(START+SC-1,C)        
      IF (SC .EQ. 0) GO TO 1260        
C        
C     NOW CALCULATE CONTIBUTIONS FROM CURRENT PIVOT ROW TO        
C     SECOND TERM IN EQUATION (4) IN MEMO CWM-19. NOTE-TERMS ARE        
C     CALCULATED ONLY FOR ROW/COL COMBINATIONS IN THE CURRENT SPILL     
C     GROUP        
C        
      IF (TYPEA .EQ. 2) GO TO 1250        
      CALL SDCOM1 (ZI,ZI(IAC),ZR(WA+PREVC),ZR(WB))        
      GO TO 1260        
 1250 CALL SDCOM2 (ZI,ZI(IAC),ZR(WA+2*PREVC),ZR(WB))        
C        
C     SHIP PIVOT ROW OUT TO EITHER MATRIX OR SPILL FILE        
C        
 1260 IF (LASTI .EQ. C) GO TO 1300        
      IF (.NOT. SPLOUT) GO TO 1640        
C        
C     PIVOT ROW GOES TO SPILL FILE - SET INDEX WHERE TO BEGIN NEXT AND  
C                                    WRITE ROW AND ACTIVE COLUMN VECTOR 
C        
      IJKL  = SPFLG        
      II    = FRSTPC        
      SPFLG = 0        
      FRSTPC= 0        
      START = LASTI + 1        
      CALL WRITE (SCRC,KEY,NKEY, 0)        
      CALL WRITE (SCRC,ZI(IAC),C,1)        
      CALL WRITE (SCRC,ZR,C*NWDS,1)        
      IF (ROW .LT. LSTROW) GO TO 1410        
C        
C     LAST ROW OF CURRENT SPILL GROUP - REWIND FILE AND OPEN IT TO READ.
C                                      IF ANOTHER SPILL GROUP, SET IT UP
C        
      CALL CLOSE (SCRC,REW)        
      JKLM = SCRC        
      SCRC = SCRD        
      SCRD = JKLM        
      CALL GOPEN (SCRD,ZI(BUF5),RDREW)        
      LSTSPL = ROW        
      SPLIN  = .TRUE.        
      SPLOUT = .FALSE.        
      IF (IJKL .EQ. 0) GO TO 1290        
      SPLOUT = .TRUE.        
      SPROW  = ROW        
      S      = IJKL        
      LSTROW = II        
      CALL GOPEN (SCRC,ZI(BUF4),WRTREW)        
C        
C     IF S WAS REDEFINED, GET NEW DEFINITION        
C        
      DO 1270 I = KSPILL,NSPILL,3        
      IF (ROW-ZI(I)) 1270,1280,1290        
 1270 CONTINUE        
      GO TO 1290        
 1280 S = ZI(I+1)        
      LSTROW = ZI(I+2)        
      KSPILL = I + 3        
C        
C     READ ANY TERMS SAVED FROM PREVIOUS SPILL GROUP        
C        
 1290 IF (ROW .EQ. NROW) GO TO 1500        
      CALL FREAD (SCRD,N,1,0)        
      WA = NZZZ - N        
      CALL FREAD (SCRD,ZR(WA),N,1)        
      ROWONE = .TRUE.        
      GO TO 800        
C        
C     PIVOT ROW GOES TO OUTPUT FILE - IF REQUIRED, CONVERT TO CHOLESKY  
C        
 1300 IF (ROW .NE. DBL(2)+1) GO TO 1650        
      IF (CHLSKY .EQ. 0) GO TO 1340        
      IF (PREC   .EQ. 2) GO TO 1320        
      IF (ZR(1) .LT. 0.) CALL SDCMQ (*1870,3,RDIA,ZR(1),0,0,ROW,ZI)     
      ZR(1) = SQRT(ZR(1))        
      IF (C .EQ. 1) GO TO 1340        
      DO 1310 I = 2,C        
      ZR(I) = ZR(I)*ZR(1)        
 1310 CONTINUE        
      GO TO 1340        
 1320 IF (ZD(1) .LT. 0.0D0) CALL SDCMQ (*1870,3,0,0,DDIA,ZD(1),ROW,ZI)  
      ZD(1) = DSQRT(ZD(1))        
      IF (C .EQ. 1) GO TO 1340        
      DO 1330 I = 2,C        
      ZD(I) = ZD(I)*ZD(1)        
 1330 CONTINUE        
C        
C     WRITE THE ROW WITH PUTSTR/ENDPUT        
C        
 1340 CALL SDCOUT (BLK,0,ZI(IAC),C,ZR,ZR)        
C        
C     IF ACTIVE COLUMNS ARE NOW GOING PASSIVE, MERGE ROWS IN CORE       
C     WITH THOSE NOW ON THE PC FILE THUS CREATING A NEW PC FILE        
C        
      IF (FRSTPC .EQ. 0) GO TO 1400        
      IF (SPLIN .OR. SPLOUT) GO TO 1740        
      CALL GOPEN (SCRC,ZI(BUF4),WRTREW)        
      BLK(1) = SCRC        
      BLK(3) = 0        
      IJKL   = IAC + 1        
      DO 1370 I = IJKL,NAC        
 1350 IF (IABS(ZI(I)) .LE. BBLK(4)) GO TO 1360        
      CALL CPYSTR (BBLK,BLK,1,0)        
      BBLK(8) = -1        
      CALL GETSTR (*1750,BBLK)        
      GO TO 1350        
 1360 CI = NAC - I + 1        
      CALL SDCOUT (BLK,0,ZI(I),CI,ZR(WB),ZR(WB))        
      WB = WB + CI*NWDS        
 1370 CONTINUE        
      ICRQ = WB - ISPILL        
      IF (WB .GT. ISPILL) GO TO 1850        
 1380 CALL CPYSTR (BBLK,BLK,1,0)        
      IF (BBLK(4) .EQ. NROW+1) GO TO 1390        
      BBLK(8) = -1        
      CALL GETSTR (*1760,BBLK)        
      GO TO 1380        
 1390 CALL CLOSE (SCRB,REW)        
      CALL CLOSE (SCRC,REW)        
      I    = SCRB        
      SCRB = SCRC        
      SCRC = I        
      CALL GOPEN (SCRB,ZI(BUF2),RDREW)        
      BBLK(1) = SCRB        
      BBLK(8) = -1        
      CALL GETSTR (*1770,BBLK)        
      BLK(1) = DBL(1)        
      BLK(3) = 1        
C        
C     ACCUMULATE MCB INFORMATION FOR PIVOT ROW        
C        
 1400 CONTINUE        
      NWORDS = C*NWDS        
      DBL(2) = DBL(2) + 1        
      DBL(6) = MAX0(DBL(6),NWORDS)        
      DBL(7) = DBL(7) + NWORDS        
C        
C     PREPARE TO PROCESS NEXT ROW.        
C        
 1410 IF (ROW .EQ. NROW) GO TO 1500        
      PREVC = C - 1        
      ROWONE= .FALSE.        
      WA    = WB        
      GO TO 800        
C        
C     CLOSE FILES AND PUT END MESSAGE IN RUN LOG.        
C        
 1500 SUBNAM(3) = END        
      CALL CONMSG (SUBNAM,3,0)        
      GO TO 1870        
C        
C     DECOMPOSE A 1X1 MATRIX        
C        
 1510 ITYPE1= TYPEA        
      ITYPE2= TYPEA        
      ITYPE3= TYPEA        
      POWER = 0        
      I1    = 1        
      J1    = 1        
      I2    = 1        
      J2    = 1        
      INCR1 = 1        
      INCR2 = 1        
      CALL GOPEN (DBA,ZI(BUF1),RDREW)        
      PARM(2) = DBA(1)        
      CALL UNPACK (*1570,DBA,ZR)        
      CALL CLOSE (DBA,REW)        
      CALL GOPEN (DBL,ZI(BUF1),WRTREW)        
      DBL(2) = 0        
      DBL(6) = 0        
      IF (TYPEA.EQ.2) GO TO 1520        
      MINDS = ZR(1)        
      DSR   = ZR(1)        
      IF (ZR(1)) 1530,1540,1560        
 1520 MINDD = ZD(1)        
      DDR   = ZD(1)        
      IF (ZD(1)) 1530,1540,1560        
C        
 1530 I = 3        
      GO TO 1550        
 1540 I = 2        
 1550 CALL SDCMQ (*1870,I,ZR,ZR,ZD,ZD,1,ZI)        
 1560 CALL PACK (ZR,DBL,DBL)        
      CALL CLOSE (DBL,REW)        
      GO TO 1880        
C        
C     1X1 NULL COLUMN        
C        
 1570 CALL SDCMQ (*1870,1,0.,0.,0.D0,0.D0,1,ZI)        
      GO TO 1870        
C        
C     VARIOUS ERRORS LAND HERE        
C        
 1600 CALL MESAGE (-7,DBA(2),SUBNAM)        
 1610 KERR = 1045        
      GO TO  1800        
 1620 KERR = 1046        
      GO TO  1800        
 1630 KERR = 1051        
      GO TO  1800        
 1640 KERR = 1311        
      GO TO  1800        
 1650 KERR = 1320        
      GO TO  1800        
 1660 KERR = 1288        
      GO TO  1800        
 1670 KERR = 1065        
      GO TO  1800        
 1680 KERR = 1034        
      GO TO  1800        
 1690 KERR = 1204        
      GO TO  1800        
 1700 KERR = 1215        
      GO TO  1800        
 1710 KERR = 1216        
      GO TO  1800        
 1720 KERR = 1288        
      GO TO  1800        
 1730 KERR = 1289        
      GO TO  1800        
 1740 KERR = 1330        
      GO TO  1800        
 1750 KERR = 1333        
      GO TO  1800        
 1760 KERR = 1340        
      GO TO  1800        
 1770 KERR = 1344        
      GO TO  1800        
 1800 WRITE  (NOUT,1810) SFM,KERR        
 1810 FORMAT (A25,' 2379, LOGIC ERROR',I6,' IN SDCMPS.')        
      J = 66        
      WRITE  (NOUT,1820) (KEY(I),I=1,J)        
 1820 FORMAT (36H0   CONTENTS OF / SDCOMX / FOLLOW --, /,(1X,10I12))    
 1830 PARM(1) = -37        
      PARM(2) = 0        
      PARM(3) = SUBNAM(1)        
      PARM(4) = SUBNAM(2)        
      GO TO 1870        
C        
C     INSUFFICIENT TIME        
C        
 1840 PARM(1) = -50        
      PARM(2) = IJKL        
      GO TO 1870        
C        
C     INSUFFICIENT CORE        
C        
 1850 PARM(1) = -8        
      PARM(2) = ICRQ        
      GO TO 1870        
C        
C     UNEXPECTED NULL COLUMN        
C        
 1860 DV = 0.0        
      CALL SDCMQ (*1870,5,RV,RV,DV,DV,ROW,ZI)        
C        
 1870 CALL CLOSE (DBA, REW)        
      CALL CLOSE (SCRA,REW)        
      CALL CLOSE (SCRB,REW)        
      CALL CLOSE (DBL ,REW)        
 1880 CALL CLOSE (SCRDIA,REW)        
      IF (NERR(1)+NERR(2) .LE. 0) GO TO 1890        
      CALL GOPEN (SCRMSG,ZI(BUF6),WRT)        
      BBLK(2) = 0        
      BBLK(3) = 0        
      BBLK(4) = 0        
      CALL WRITE (SCRMSG,BBLK(2),3,1)        
      CALL CLOSE (SCRMSG,REW)        
 1890 CONTINUE        
      IF (KORCHG .GT. 0) LCORE = LCORE - KORCHG        
      RETURN        
      END        
