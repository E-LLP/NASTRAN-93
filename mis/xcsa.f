      SUBROUTINE XCSA        
C        
C     XCSA READS AND PROCESSES THE NASTRAN EXECUTIVE CONTROL DECK.      
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      LOGICAL         TAPBIT        
      DIMENSION       ALTER(2),APPTYP(4),BGNAL(2),CEND(2),DIAGX(11),    
     1                DMAPBF(1),ECTT(45),ENDAL(2),HDG(19),IPTDIC(1),    
     2                IUFILE(2),IZ(2),NXPTDC(2),NXCSA(2),OSOLU(2),      
     3                OUTCRD(200),SOLREC(6),SOLU(12),SOLNM3(7,11),      
     5                SOLNMS(7,31),SOLNM1(7,10),SOLNM2(7,10),SOLNMX(6), 
     6                XALT(2),XSYS(100)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /MACHIN/ MACH,IJHALF(3),MCHNAM        
      COMMON /SEM   / MSKDUM(3),LINKS(15)        
      COMMON /SYSTEM/ IBUFSZ,OUTTAP,XNOGO,INTAPE,SY5,SY6,LOGFL,SY8,     
     1                NLPP,SY10,SY11,NLINES,SY13,SY14,IDATE(3),SY18,    
     2                IECHO,SY20,APPRCH,SY22,SY23,ICFIAT,RFFLAG,        
     3                SY26(11),LU,SY38,NBPC,NBPW,NCPW,SY42(13),PREC,    
     4                SY56(13),ISUBS,SY70(9),SWITCH(3),ICPFLG,SY83(2),  
     5                SY85,INTRA,SY87(5),LDICT        
      COMMON /XECHOX/ DUM9(9),NOECHO        
      COMMON /XRGDXX/ IRESTR,NSUBST        
      COMMON /XOLDPT/ ITOP,IBOT,LDIC,NRLFL,ISEQNO        
      COMMON /XXFIAT/ IXXFAT(1)        
      COMMON /XPFIST/ IXPFST        
      COMMON /XFIST / IFIST(1)        
      COMMON /XFIAT / IFIAT(1)        
CZZ   COMMON /ZZXCSA/ GBUFF(1)        
      COMMON /ZZZZZZ/ GBUFF(1)        
      COMMON /BLANK / ZCOM,CARD(20)        
      COMMON /STAPID/ TAPID(6),OTAPID(6)        
      COMMON /STIME / TIME        
      COMMON /L15 L8/ L15,L8,L13        
      COMMON /XLINK / LXLINK,MAXLNK        
      COMMON /OUTPUT/ PGHDG1(32),PGHDG2(32), PGHDG3(32),        
     1                PGHDG4(32),PGHDG5(32), PGHDG6(32)        
      EQUIVALENCE     (IBUFSZ   ,XSYS(1)  ), (MASK    ,MASKHI  ),       
     1                (ECTT(16) ,BGNAL(1) ), (ECTT(25),ENDAL(1)),       
     2                (ECTT(13) ,CEND(1)  ), (ECTT(34),ID      ),       
     3                (SOLREC(1),APPREC   ), (SOLREC(2),RSTRT  ),       
     4                (SOLREC(3),ALTER(1) ), (SOLREC(5),SOLU(1)),       
     5                (GBUFF(1) ,DMAPBF( 1), IPTDIC(1)),        
     6                (SOLNMS(1, 1),SOLNM1(1,1)),        
     7                (SOLNMS(1,11),SOLNM2(1,1)),        
     8                (SOLNMS(1,21),SOLNM3(1,1))        
      DATA  APPTYP                                                   /  
     1      4HDMAP,   4HDISP,   4HHEAT,   4HAERO                     /  
      DATA  BLANK,    IXDMAP,   NSUBS,    RENTER,   DOLSIN           /  
     2      1H ,      4HXDMA,   4HSUBS,   4HREEN,   4H$              /  
      DATA  IYES,     NO,       IDISK,    PTAPE,    OPTAPE,   DMEND  /  
     3      4HYES ,   4HNO  ,   4HDISK,   4HNPTP,   4HOPTP,   4HEND  /  
      DATA  IUFILE,   XALT,               NXPTDC,             INTGR  /  
     4      2*0,      4HXALT,   4HER  ,   4HXPTD,   4HC   ,   -1     /  
      DATA  NXCSA,              DIAGX                                /  
     5      4HXCSA,   4H    ,   4,9,14,17,23,24,25,28,29,30,31       /  
      DATA  APPDMP,   APPHEA,   APPAER,   NUMAPP,   SOLREC           /  
     6      1,        3,        4,        4,        0,1,0,0,0,0      /  
      DATA  SOLUF,    OSOLU,    ICOLD,    IGNORE,   OUTCRD           /  
     7      0,        2*0,      1,        0,        3,199*4H         /  
      DATA  PLOT,     PRNT,     BOTH,     INP9  ,   NOTALT           /  
     8      4HPLOT,   4HPRIN,   4HBOTH,   4HINP9,   0                /  
      DATA  MASK /    32767 /        
C                     32767 = O77777 = 2**15-1 = MASK HI        
      DATA  LECTT,    ECTT /    45,        
     1     4HTIME,4H    ,0   ,   4HAPP ,4H    ,0   ,   4HCHKP,4HNT  ,0, 
     4     4HREST,4HART ,0   ,   4HCEND,4H    ,0   ,   4HALTE,4HR   ,0, 
     7     4HSOL ,4H    ,0   ,   4HBEGI,4HN   ,0   ,   4HENDA,4HLTER,0, 
     X     4HDIAG,4H    ,0   ,   4HUMF ,4H    ,0   ,   4HID  ,4H    ,1, 
     3     4HUMFE,4HDIT ,0   ,   4HPREC,4H    ,0   ,   4HINTE,4HRACT,0/ 
      DATA HDG/4HN A ,4HS T ,4HR A ,4HN   ,4H E X,4H E C,4H U T,4H I V, 
     1  4H E  ,4H  C ,4HO N ,4HT R ,4HO L ,4H   D,4H E C,4H K  ,4H  E , 
     2  4HC H ,4HO   /        
      DATA NSOLNM /26/        
      DATA SOLNM1 /        
     1     4HSTAT,4HICS  , 4H    ,4H     , 4H    ,4H     ,  1 ,        
     2     4HINER,4HTIA  , 4HRELI,4HEF   , 4H    ,4H     ,  2 ,        
     3     4HNORM,4HAL   , 4HMODE,4HS    , 4H    ,4H     ,  3 ,        
     4     4HDIFF,4HEREN , 4HSTIF,4HFNES , 4H    ,4H     ,  4 ,        
     5     4HBUCK,4HLING , 4H    ,4H     , 4H    ,4H     ,  5 ,        
     6     4HPIEC,4HEWIS , 4HLINE,4HAR   , 4H    ,4H     ,  6 ,        
     7     4HDIRE,4HCT   , 4HCOMP,4HLEX  , 4HEIGE,4HNVAL ,  7 ,        
     8     4HDIRE,4HCT   , 4HFREQ,4HUENC , 4HRESP,4HONSE ,  8 ,        
     9     4HDIRE,4HCT   , 4HTRAN,4HSIEN , 4HRESP,4HONSE ,  9 ,        
     O     4HMODA,4HL    , 4HCOMP,4HLEX  , 4HEIGE,4HNVAL , 10 /        
      DATA SOLNM2 /        
     1     4HMODA,4HL    , 4HFREQ,4HUENC , 4HRESP,4HONSE , 11 ,        
     2     4HMODA,4HL    , 4HTRAN,4HSIEN , 4HRESP,4HONSE , 12 ,        
     3     4HSTEA,4HDY   , 4HSTAT,4HE    , 4H    ,4H     ,  3 ,        
     4     4HTRAN,4HSIEN , 4H    ,4H     , 4H    ,4H     ,  9 ,        
     5     4HMODE,4HS    , 4H    ,4H     , 4H    ,4H     ,  3 ,        
     6     4HREAL,4H     , 4HEIGE,4HNVAL , 4H    ,4H     ,  3 ,        
     7     4HMODA,4HL    , 4HFLUT,4HTER  , 4HANAL,4HYSIS , 10 ,        
     8     4HMODA,4HL    , 4HAERO,4HELAS , 4HRESP,4HONSE , 11 ,        
     9     4HNORM,4HAL   , 4HMODE,4HS    , 4HANAL,4HYSIS , 13 ,        
     O     4HSTAT,4HICS  , 4HCYCL,4HIC   , 4HSYMM,4HETRY , 14 /        
      DATA SOLNM3 /        
     1     4HMODE,4HS    , 4HCYCL,4HIC   , 4HSYMM,4HETRY , 15 ,        
     2     4HSTAT,4HIC   , 4HAERO,4HTHER , 4HMOEL,4HASTI , 16 ,        
     3     4HBLAD,4HE    , 4HCYCL,4HIC   , 4HMODA,4HL    ,  9 ,        
     4     4HDYNA,4HMIC  , 4HDESI,4HGN A , 4HNALY,4HSIS  , 17 ,        
     5     4HDIRE,4HCT   , 4HFORC,4HED V , 4HIBRA,4HTION , 18 ,        
     6     4HMODA,4HAL   , 4HFORC,4HED V , 4HIBRA,4HTION , 19 ,        
     7     4H****,4H**** , 4H****,4H**** , 4H****,4H**** ,  0 ,        
     8     4H****,4H**** , 4H****,4H**** , 4H****,4H**** ,  0 ,        
     9     4H****,4H**** , 4H****,4H**** , 4H****,4H**** ,  0 ,        
     O     4H****,4H**** , 4H****,4H**** , 4H****,4H**** ,  0 ,        
     1     4H****,4H**** , 4H****,4H**** , 4H****,4H**** ,  0 /        
C        
C     SET UP DATA IN COMMON        
C        
      ITOP   = 0        
      IBOT   = 0        
      LDIC   = 0        
      NRLFL  = 0        
      ISEQNO = 0        
      NSCR   = 315        
      IRESTR = 0        
      NSUBST = 0        
      NWPC   = 18        
      DRECSZ = 0        
C        
C        
C     INITIALIZE MACHINE DEPENDENT CONSTANTS        
C        
C     ALLON  = O777777777777  ALL BITS ON        
C     ISIGN  = O400000000000  SIGN ON ONLY        
C     MASK5  = O500000000000  SIGN AND NEXT BIT ON        
C     ENDCD  = O377777777777  ALL BITS ON EXCEPT SIGN        
C     MHIBYT = O770000000000  MASK IN HIGH ORDER BYTE        
C        
      ISIGN  = LSHIFT(1,NBPW-1)        
      MASK5  = ORF(ISIGN,RSHIFT(ISIGN,1))        
      ALLON  = COMPLF(0)        
      MHIBYT = LSHIFT(ALLON,(NCPW-1)*NBPC)        
      ENDCD  = RSHIFT(ALLON,1)        
      J      = DIAGX(2)*5 - 1        
      CARD(J  ) = XSYS(J)        
      CARD(J+1) = KHRFN1(BNK,1,XSYS(J),2)        
      CALL NA12IF (*1420,CARD(J),2,S7,1)        
      IF (S7 .NE. 0) I7 = MACH*100        
C        
C     DETERMINE OPEN CORE SIZE AND ALLOCATE BUFFER AREA        
C        
      DMAPBS = KORSZ(GBUFF) - IBUFSZ        
      CALL WALTIM (TIMEW)        
      TIMEW = MOD(TIMEW,10000000)        
C        
C     LOAD PAGE HEADING IN /OUTPUT/        
C        
      J = 32        
      DO 5 I = 1,J        
      PGHDG1(I) = BLANK        
      PGHDG2(I) = BLANK        
      PGHDG3(I) = BLANK        
      PGHDG4(I) = BLANK        
      PGHDG5(I) = BLANK        
      PGHDG6(I) = BLANK        
    5 CONTINUE        
      DO 10 I = 1,19        
   10 PGHDG3(I+1) = HDG(I)        
      CALL PAGE        
C        
C     CARD PREPARATION        
C        
      N7 = I7 + S7        
      I7 = I7/100        
      N7 = N7 - 2*I7        
      M7 = CARD(LECTT+9)        
      J  = IABS(M7)        
      I  = 3        
      IF (M7.LT.0 .AND. MOD(J,10).EQ.7) I = 4        
      IF (J/10.EQ.N7 .AND. XSYS(17)-I.LE.S7) CARD(LECTT+2) = ICOLD      
      CARD(LECTT+11) = KHRFN1(CARD(LECTT+11),2,XALT(1),3)        
      CARD(LECTT+13) = KHRFN1(CARD(LECTT+13),1,NXCSA(1),1)        
      CARD(LECTT+14) = KHRFN1(CARD(LECTT+14),2,IDISK,1)        
C        
C     WRITE DUMMY ID FILE ON PROBLEM TAPE IN CASE OF ID CONTROL CARD    
C     ERROR.        
C        
      NOGO   = XNOGO        
      XNOGO  = 0        
      OLDALT = 0        
C        
C     READ CONTROL CARD AND PROCESS        
C        
   20 ASSIGN 70 TO IRTN1        
   30 NLINES = NLINES + 1        
      IF (NLINES .GE. NLPP) CALL PAGE        
      IF (ZCOM .NE. 0) GO TO 40        
      CALL XREAD (*1232,CARD)        
C        
C     ECHO CARD        
C     (NOECHO IS SET BY SEMDBD AND READFILE OF FFREAD)        
C        
   40 ZCOM = 0        
      IF (NOECHO .NE. 0) GO TO 52        
      WRITE  (OUTTAP,50) CARD        
   50 FORMAT (5X,20A4)        
      GO TO 55        
   52 NOECHO = NOECHO + 1        
      NLINES = NLINES - 1        
C        
C     CHECK FOR COMMENT CARD        
C        
   55 IF (KHRFN1(BLANK,1,CARD(1),1) .EQ. DOLSIN) GO TO 30        
C        
C     CALL RMVEQ TO REPLACE ONE EQUAL SIGN BY ONE BLANK        
C     IF CARD IS NOT WITHIN ALTER RANGE        
C        
CCCCC   NEXT LINE CAUSE ERROR IN READING RESTART DICTIONARY. POSITION   
CCCCC   PROBLEM        
CCCCC        
CCCCC      IF (NOTALT .EQ. 0) CALL RMVEQ (CARD)        
      CALL XRCARD (OUTCRD,200,CARD)        
C        
C     CHECK FOR ERROR DETECTED BY XRCARD        
C        
      IF (XNOGO .EQ. 0) GO TO 60        
      IF (NOGO  .EQ. 0) NOGO = 1        
      XNOGO = 0        
      GO TO 30        
C        
C     CHECK FOR BLANK CARD        
C        
   60 IF (OUTCRD(1) .EQ. 0) GO TO 30        
      GO TO IRTN1, (70,270,370,510)        
   70 J = 0        
      DO 80 I = 1,LECTT,3        
      J = J + 1        
      IF (OUTCRD(2).EQ.ECTT(I) .AND. OUTCRD(3).EQ.ECTT(I+1)) GO TO 90   
   80 CONTINUE        
      IF (OUTCRD(2) .EQ. IXDMAP) GO TO 400        
      IF (IGNORE .EQ. 0) GO TO 690        
      GO TO 20        
C        
C     HAS THIS TYPE CARD ALREADY BEEN PROCESSED        
C        
   90 IGNORE = 0        
      IF (ECTT(I+2).LT.0 .AND. OUTCRD(2).EQ.ECTT(28)) ECTT(I+2) = 0     
C                                               DIAG        
      IF (ECTT(I+2)) 720,100,100        
  100 ECTT(I+2) = ORF(ECTT(I+2),MASK5)        
      GO TO (110, 120, 140, 210, 570, 330, 390, 400,1180, 480,        
     1       460, 530, 560, 565, 555), J        
C        
C        
C     NOW PROCESS TIME CARD        
C        
  110 IMHERE = 110        
      IF (OUTCRD(4).NE.-1 .OR. OUTCRD(5).LE.0) GO TO 760        
      TIME = OUTCRD(5)*60        
      GO TO 20        
C        
C        
C     NOW PROCESS APPROACH CARD        
C        
  120 DO 130 JJ = 1,NUMAPP        
      APPRCH = JJ        
      APPREC = JJ        
      IF (OUTCRD(4) .EQ. APPTYP(JJ)) GO TO 132        
  130 CONTINUE        
      IMHERE = 130        
      GO TO 760        
C        
C     CHECK FOR SUBSTRUCTURE ANALYSIS        
C        
  132 IF (OUTCRD(6) .NE. NSUBS) GO TO 20        
      ISUBS = APPRCH        
      IF (OUTCRD(8) .NE. -1) GO TO 20        
      ISUBS = ISUBS + 10*OUTCRD(9)        
      GO TO 20        
C        
C        
C     NOW PROCESS CHKPNT CARD        
C        
  140 IF (OUTCRD(4).EQ.NO .OR. OUTCRD(6).EQ.NO) GO TO 20        
C        
C     CHECK FOR ILLEGAL FORMAT        
C        
      IMHERE = 140        
      IF (OUTCRD(4).NE.IYES .AND. OUTCRD(6).NE.IYES) GO TO 750        
      ICPFLG = 1        
      IF (OUTCRD(6) .EQ. IDISK) GO TO 20        
      ASSIGN 150 TO L        
      IDFIST = PTAPE        
C        
C     CHECKPOINT FLAG IS ON,MAKE SURE NEW PROBLEM TAPE IS ON        
C     PHYSICAL TAPE DRIVE        
C        
      GO TO 160        
  150 IF (NOSTUP .NE. 0) GO TO 790        
      GO TO 20        
C        
C     CHECK TAPE SETUP        
C        
  160 IF (TAPBIT(IDFIST)) GO TO 190        
C        
C     TAPE NOT SETUP        
C        
      NOSTUP = 1        
      GO TO 200        
  190 CONTINUE        
C        
C     TAPE SETUP        
C        
      NOSTUP = 0        
C     GO TO L, (150,470)        
  200 GO TO L, (150)        
C        
C        
C     NOW PROCESS RESTART CARD        
C        
  210 NGINO  = OPTAPE        
      IRESTR = 1        
C        
C     SET UNSORTED AND SORTED BULK DATA OUTPUT (ECHO = BOTH)        
C     AS THE DEFAULT FOR RESTART RUNS        
C        
      IECHO = 3        
      CALL OPEN (*850,OPTAPE,GBUFF(DMAPBS+1),0)        
      CALL READ (*1350,*1350,OPTAPE,OTAPID,6,0,FLGWRD)        
      CALL READ (*1350,*222,OPTAPE,TIMEX,1,1,FLGWRD)        
      GO TO 225        
  222 OUTCRD(21) = 0        
      TIMEX = 0        
C        
C     COMPARE ID OF OLD PTAPE WITH THAT ON RSTART CARD        
C        
  225 RSTRT = 2        
C        
C     UNPACK DATE        
C        
      I     = LSHIFT(OTAPID(5),7)        
      IYEAR = RSHIFT(ANDF(I,MASKHI),7)        
      I     = RSHIFT(I,6)        
      IDAY  = RSHIFT(ANDF(I,MASKHI),9)        
      I     = RSHIFT(I,5)        
      IMNTH = RSHIFT(ANDF(I,MASKHI),10)        
      JJ    = OUTCRD(1)*2 - 2        
      DO 230 JK = 1,JJ        
      IF (OTAPID(JK) .NE. OUTCRD(JK+3)) GO TO 820        
  230 CONTINUE        
      IF (OUTCRD( 9).EQ.0 .AND. OUTCRD(14).EQ.0 .AND. OUTCRD(19) .EQ. 0)
     1    GO TO 235        
      IF (IMNTH.NE.OUTCRD(9) .OR. IDAY.NE.OUTCRD(14) .OR.        
     1    IYEAR.NE.OUTCRD(19)) GO TO 820        
  235 CONTINUE        
      IF (OUTCRD(21) .EQ. 0) TIMEX = 0        
      IF (TIMEX .NE. OUTCRD(21)) GO TO 820        
C        
C     MAKE SURE CORRCET REEL IS MOUNTED        
C        
      IF (OTAPID(6) .EQ. 1) GO TO 240        
      GO TO 820        
C        
C     GET OLD SOLUTION NUMBER        
C        
  240 CALL SKPFIL (OPTAPE,1)        
      CALL READ  (*1350,*1350,OPTAPE,OSOLU,1,0,FLGWRD)        
      IF (OSOLU(1) .EQ. XALT(1)  ) OLDALT = OLDALT + 1        
      IF (OSOLU(1) .EQ. NXPTDC(1)) OLDALT = OLDALT + 1        
      IF (OSOLU(1) .NE. NXCSA(1) ) GO TO 240        
      CALL FWDREC (*1350,OPTAPE)        
      CALL READ (*1350,*1350,OPTAPE,0,-4,0,FLGWRD)        
      CALL READ (*1350,*1350,OPTAPE,OSOLU,2,1,FLGWRD)        
      CALL SKPFIL (OPTAPE,1)        
      CALL CLOSE  (OPTAPE,2)        
C        
C     LOAD PROBLEM TAPE DICTIONARY        
C        
      ICRDCT = 0        
      ISEQNO = 0        
      ITOP = DRECSZ + 1        
      LDIC = KORSZ(IPTDIC(ITOP)) - IBUFSZ        
      IBOT = ITOP - 3        
C        
C     ZERO FIRST PTDIC ENTRY IN CASE THERE ARE NO ENTRIES        
C        
      IPTDIC(ITOP  ) = 0        
      IPTDIC(ITOP+1) = 0        
      IPTDIC(ITOP+2) = 0        
C        
C     SET ITOPX SO THAT FIRST XVPS ENTRY IN PTDIC WILL BE PRESERVED     
C        
      ITOPX  = ITOP + 3        
  260 ICRDCT = 1 + ICRDCT        
C        
C     READ IN NEXT CONTROL CARD        
C        
      ASSIGN 270 TO IRTN1        
      GO TO 30        
  270 IF (OUTCRD(1) .NE.     -1) GO TO 320        
      IF (OUTCRD(2) .NE. ICRDCT) GO TO 1210        
      IF (OUTCRD(3) .EQ.      5) GO TO 310        
      IF (OUTCRD(3) .EQ.  ENDCD) GO TO 320        
      IF (OUTCRD(3) .GT.      3) GO TO 310        
C        
C     CHECK FORMAT        
C        
      IMHERE = 275        
      IF (OUTCRD(3).NE.3 .OR. OUTCRD(10).NE.-1 .OR. OUTCRD(12).NE.2 .OR.
     1    OUTCRD(17).NE.-1 .OR. OUTCRD(19).NE.2 .OR. OUTCRD(24).NE.-1)  
     2    GO TO 760        
C        
C     PACK FLAGS/REEL/FILE        
C        
      FLAGS = 0        
      IF (OUTCRD(11) .GE. 4) FLAGS = ISIGN        
      REEL = ORF(LSHIFT(OUTCRD(18),16),OUTCRD(25))        
C        
C     SEE IF FILE IS ALREADY IN PTDIC - IF IT IS, PUT LATEST REEL/FILE  
C     NO. IN EXISTING ENTRY        
C        
      IF (IBOT .LT. ITOPX) GO TO 290        
      DO 280 K = ITOPX,IBOT,3        
      IF (IPTDIC(K).EQ.OUTCRD(4) .AND. IPTDIC(K+1).EQ.OUTCRD(5))        
     1    GO TO 300        
  280 CONTINUE        
C        
C     FILE NOT IN PTDIC - MAKE NEW ENTRY        
C        
  290 IBOT = IBOT + 3        
C        
C     CHECK FOR OVERFLOW        
C        
      IF (IBOT+3-ITOP .GT. LDIC) GO TO 1260        
      K = IBOT        
      IPTDIC(K  ) = OUTCRD(4)        
      IPTDIC(K+1) = OUTCRD(5)        
  300 IPTDIC(K+2) = ORF(FLAGS,REEL)        
      GO TO 260        
C        
C     THIS IS A REENTRY CARD - LOAD DMAP INSTRUCTION NO. IN ISEQNO      
C        
  310 IMHERE = 310        
      IF (OUTCRD(4).NE.RENTER .OR. OUTCRD(14).NE.-1) GO TO 760        
      ISEQNO = LSHIFT(OUTCRD(15),16)        
      GO TO 260        
C        
C     DICTIONARY PROCESSED - COPY ONTO NEW PROBLEM TAPE.        
C     THERE MUST ALWAYS BE AT LEAST ONE ENTRY IN PTDIC        
C        
  320 IF (IBOT .LT. ITOP) IBOT = ITOP        
      NGINO = PTAPE        
      IMHERE= 320        
      CALL OPEN (*1320,PTAPE,GBUFF(DMAPBS+1),3)        
C        
C     RECORD 1 = ID        
C        
      CALL WRITE (PTAPE,NXPTDC,2,1)        
C        
C     RECORD 2 = CONTENTS OF IPTDIC        
C        
      CALL WRITE (PTAPE,IPTDIC(ITOP),IBOT+3-ITOP,1)        
      CALL EOF   (PTAPE)        
      CALL CLOSE (PTAPE,2)        
      IF (OUTCRD(3) .EQ. ENDCD) GO TO 20        
      GO TO 70        
C        
C        
C     PROCESS ALTER CONTROL CARDS        
C     WRITE ALTER HEADER ONTO NEW PROBLEM TAPE        
C        
  330 NGINO  = PTAPE        
      NOTALT = 1        
      IMHERE = 330        
      CALL OPEN (*1320,PTAPE,GBUFF(DMAPBS+1),3)        
      CALL WRITE (PTAPE,XALT,2,1)        
  340 IF (OUTCRD(6) .NE. ENDCD) GO TO 350        
      OUTCRD(6) = INTGR        
      OUTCRD(7) = 0        
  350 IMHERE = 350        
      IF (OUTCRD(4).NE.INTGR .OR. OUTCRD(6).NE.INTGR .OR. OUTCRD(5).LE.0
     1   .OR. OUTCRD(7).LT.0) GO TO 750        
C        
C     CHECK SEQUENCE        
C        
      IF (OUTCRD(5).LE.ALTER(1) .OR. (OUTCRD(5).GT.OUTCRD(7) .AND.      
     1    OUTCRD(7).NE.0)) GO TO 880        
      ALTER(1) = OUTCRD(5)        
      ALTER(2) = OUTCRD(7)        
C        
C     WRITE ALTER PARAMETERS ONTO NPTP        
C        
      CALL WRITE (PTAPE,ALTER,2,1)        
      IF (ALTER(2) .NE. 0) ALTER(1) = ALTER(2)        
C        
C     READ NEXT CARD INTO CORE        
C        
  360 ASSIGN 370 TO IRTN1        
      GO TO 30        
  370 CONTINUE        
C        
C     CHECK FOR CEND CARD TO PREVENT STREAMING THRU BULK DATA        
C        
      IF (OUTCRD(2).EQ.CEND(1) .AND. OUTCRD(3).EQ.CEND(2)) GO TO 910    
C        
C     CHECK FOR ANOTHER ALTER CARD        
C        
      IF (OUTCRD(2).EQ.BGNAL(1) .AND. OUTCRD(3).EQ.BGNAL(2)) GO TO 340  
C        
C     CHECK FOR ENDALTER CARD        
C        
      IF (OUTCRD(2).NE.ENDAL(1) .OR.  OUTCRD(3).NE.ENDAL(2)) GO TO 380  
C        
C     ENDALTER ENCOUNTERED        
C        
      CALL EOF (PTAPE)        
      CALL CLOSE (PTAPE,2)        
      NOTALT = 0        
      GO TO 20        
C        
C     DMAP INSTRUCTION ENCOUNTERED - WRITE CARD IMAGE ON NPTP        
C        
  380 CALL WRITE (PTAPE,CARD,18,1)        
      GO TO 360        
C        
C        
C     NOW PROCESS SOL CONTROL CARD        
C        
  390 SOLUF = 1        
C        
C     =====================================        
C     ECTT(I+2) = 0        
C     DO 2000 JJ = 1,12        
C2000 SOLU(JJ) = 0        
C     WRITE  (6,2001)        
C2001 FORMAT (16H0+++ OUTCARD +++)        
C     JJ = 1        
C2002 WRITE  (6,2003) JJ,OUTCRD(JJ)        
C2003 FORMAT (20X,I5,5X,O20)        
C     IF (OUTCRD(JJ) .EQ. ENDCD) GO TO 2004        
C     JJ = JJ + 1        
C     GO TO 2002        
C2004 CONTINUE        
C     =====================================        
C        
      IF (OUTCRD(1) .EQ. 1) GO TO 395        
C        
      DO 391 JJ = 1,6        
  391 SOLNMX(JJ) = BLANK        
      JK = 2*OUTCRD(1) + 3        
      SOLNMX(1) = OUTCRD(4)        
      SOLNMX(2) = OUTCRD(5)        
      IF (OUTCRD(1).EQ.2 .OR. OUTCRD(7).EQ.BLANK) GO TO 392        
      SOLNMX(3) = OUTCRD(6)        
      SOLNMX(4) = OUTCRD(7)        
      IF (OUTCRD(1).EQ.3 .OR. OUTCRD(9).EQ.BLANK) GO TO 392        
      SOLNMX(5) = OUTCRD(8)        
      SOLNMX(6) = OUTCRD(9)        
  392 DO 394 JJ = 1,NSOLNM        
      DO 393 K  = 1,6        
      IF (SOLNMX(K) .NE. SOLNMS(K,JJ)) GO TO 394        
  393 CONTINUE        
      SOLU(1) = SOLNMS(7,JJ)        
      GO TO 396        
  394 CONTINUE        
      IUFILE(1) = OUTCRD(4)        
      IUFILE(2) = OUTCRD(5)        
      SOLU(1)   = 0        
      GO TO 396        
C        
  395 IMHERE = 395        
      IF (OUTCRD(4) .NE. -1) GO TO 750        
      JK = 7        
      SOLU(1) = OUTCRD(5)        
      IF (OUTCRD(6) .EQ. 1) JK = JK + 3        
      IF (OUTCRD(6) .EQ. 2) JK = JK + 5        
C        
  396 CONTINUE        
      RFFLAG = SOLU(1)        
      IF (OUTCRD(JK-1) .EQ. ENDCD) GO TO 399        
      IMHERE = 397        
      JJ = 1        
  397 JJ = JJ + 1        
      IF (JJ .GT. 12) GO TO 750        
      IF (OUTCRD(JK-1) .NE. -1) GO TO 750        
      NSUBST = JJ        
      SOLU(JJ) = OUTCRD(JK)        
      IF (OUTCRD(JK+1) .EQ. ENDCD) GO TO 399        
      JK = JK + 2        
      GO TO 397        
  399 CONTINUE        
C        
C     ===========================================        
C2005 FORMAT (1H0,100(1H+)/1H0/1H0)        
C     WRITE  (6,2006)        
C2006 FORMAT (13H0+++ SOLU +++)        
C     JJ = 1        
C2007 IF (SOLU(JJ).EQ.0 .AND. JJ.GT.2) GO TO 2009        
C     WRITE  (6,2008) JJ,SOLU(JJ)        
C2008 FORMAT (20X,I5,5X,I10)        
C     JJ = JJ + 1        
C     GO TO 2007        
C2009 CONTINUE        
C     WRITE (6,2005)        
C     ===========================================        
C        
      GO TO 20        
C        
C        
C     B E G I N  CONTROL CARD        
C     PROCESS DMAP SEQUENCE        
C        
  400 JJ = 0        
      WRITE  (OUTTAP,410)        
  410 FORMAT (5X,'(SEE NASTRAN SOURCE PROGRAM COMPILATION FOR LISTING ',
     1        'OF DMAP SEQUENCE)')        
      DO 420 JK = 1,NWPC        
      JJ = JJ + 1        
  420 DMAPBF(JJ) = CARD(JK)        
  430 CALL XREAD (*1232,CARD)        
      DO 440 JK = 1,NWPC        
      JJ = JJ + 1        
      DMAPBF(JJ) = CARD(JK)        
  440 CONTINUE        
      IF (JJ .GT. DMAPBS) GO TO 1290        
C        
C     CHECK FOR END OR CEND CARD        
C        
      CALL XRCARD (OUTCRD,200,CARD)        
C        
C     CHECK FOR ERROR DETECTED BY XRCARD        
C        
      IF (XNOGO .EQ. 0) GO TO 450        
      WRITE (OUTTAP,50) CARD        
      IF (NOGO  .EQ. 0) NOGO = 1        
      XNOGO = 0        
      GO TO 430        
  450 IF (OUTCRD(2).EQ.CEND(1) .AND. OUTCRD(3).EQ.CEND(2)) GO TO 940    
      IF (OUTCRD(2) .NE. DMEND) GO TO 430        
      WRITE (OUTTAP,50) CARD        
      DRECSZ = JJ        
      GO TO 20        
C        
C        
C     NOW PROCESS UMF CARD        
C     CHECK FORMAT        
C        
  460 WRITE  (OUTTAP,465) UWM,ECTT(I),ECTT(I+1)        
  465 FORMAT (A25,', ',2A4,' CARD IS NO LONGER AVAILABLE')        
      GO TO 20        
C        
C 460 IMHERE = 460        
C     IF (OUTCRD(4).NE.INTGR .OR. OUTCRD(6).NE.INTGR .OR.        
C    1    OUTCRD(5).LE.    0 .OR. OUTCRD(7).LT.   0) GO TO 750        
C        
C     SET UNSORTED AND SORTED BULK DATA OUTPUT (ECHO = BOTH)        
C     AS THE DEFAULT FOR RUNS USING THE UMF        
C        
C     IECHO = 3        
C        
C     MAKE SURE UMF TAPE IS SETUP        
C        
C     ASSIGN 470 TO L        
C     IDFIST = NUMF        
C     GO TO 160        
C 470 IF (NOSTUP .NE. 0) GO TO 970        
C        
C     MAKE SURE CORRECT UMF TAPE IS MOUNTED        
C        
C     NGINO = NUMF        
C     IMHERE= 470        
C     CALL OPEN  (*1320,NUMF,GBUFF(DMAPBS+1),0)        
C     CALL READ  (*1350,*1350,NUMF,UMFID,1,0,FLGWRD)        
C     CALL SKPFIL (NUMF,1)        
C     CALL CLOSE (NUMF,2)        
C     IF (UMFID .NE. OUTCRD(5)) GO TO 1000        
C     UMFID = OUTCRD(7)        
C     GO TO 20        
C        
C        
C     PROCESS DIAG CARD        
C     ALLOW MULTIPLE DIAG CARDS TO BE PROCESSED.        
C        
  480 CONTINUE        
      I = 2        
  490 I = I + 2        
      IF (OUTCRD(I) .EQ.     0) GO TO 505        
      IF (OUTCRD(I) .NE. INTGR) GO TO 520        
C        
C     SET SENSE SWITCH BITS. (DIAG 1 THRU 48, BIT COUNTS 0 THRU 47)     
C     BITS 49 THRU 63 ARE RESERVED FOR LINK NO.  (-1 THRU -15)        
C        
      JJ = OUTCRD(I+1)        
      IF (JJ .GT. 63-MAXLNK) GO TO 503        
      IF (JJ.GE.-MAXLNK .AND. JJ.LE.-1) JJ = 63 - MAXLNK - JJ        
      IF (JJ .GT. 31) GO TO 500        
      SWITCH(1) = ORF(LSHIFT(1,JJ-1),SWITCH(1))        
C        
C     TURN ON DIAG 14 IF DIAG 25 HAS BEEN REQUESTED        
C        
      IF (JJ .EQ. 25) SWITCH(1) = ORF(LSHIFT(1,13),SWITCH(1))        
      GO TO 503        
  500 IF (JJ.EQ.42 .AND. MACH.GT.5) WRITE (OUTTAP,501) UWM,MCHNAM       
  501 FORMAT (A25,', DIAG 42 IS UNSUPPORTED IN ALL UNIX MACHINES, ',    
     1        'INCLUDING ',A6,' ***')        
      JJ = JJ - 31        
      SWITCH(2) = ORF(LSHIFT(1,JJ-1),SWITCH(2))        
  503 CONTINUE        
      GO TO 490        
C        
C     DIAG CONTINUED ON NEXT CARD - READ IN NEXT CARD        
C        
  505 ASSIGN 510 TO IRTN1        
      GO TO 30        
  510 IF (OUTCRD(2).EQ.CEND(1) .AND. OUTCRD(3).EQ.CEND(2)) GO TO 570    
      I = -1        
      GO TO 490        
C        
C     SHOULD BE END OF LOGICAL DIAG CARD        
C        
  520 IMHERE = 520        
      IF (OUTCRD(I) .NE. ENDCD) GO TO 750        
      SWITCH(3) = ORF(SWITCH(3),SWITCH(1))        
      SWITCH(1) = 0        
      CALL PRESSW (LINKS(1),I)        
C        
C     RE-ACTIVATE THOSE LINK1 SPECIAL DIAGS IN DIAGX LIST IF NECESSARY  
C        
      IF (SWITCH(1) .EQ. SWITCH(3)) GO TO 527        
      DO 525 I = 1,11        
      JJ = DIAGX(I) - 1        
      SWITCH(1) = ORF(ANDF(LSHIFT(1,JJ),SWITCH(3)),SWITCH(1))        
  525 CONTINUE        
      IF (SWITCH(1) .NE. SWITCH(3)) CALL PRESSW (RENTER,I)        
  527 CALL SSWTCH (15,L15)        
      CALL SSWTCH (8 ,L 8)        
      CALL SSWTCH (13,L13)        
      GO TO 20        
C        
C        
C     NOW PROCESS ID CARD        
C     CHECK FORMAT - MUST BE AT LEAST 3 BCD FIELDS        
C        
  530 IMHERE = 530        
      IF (OUTCRD(1) .LT. 3) GO TO 750        
C        
C     MAKE SURE ID CARD IS FIRST CONTROL CARD        
C     IF ID CARD WAS IN ERROR CONTROL WILL STILL RETURN TO HERE        
C        
  531 DO 540 I = 1,LECTT,3        
      IF (ECTT(I+2).LT.0 .AND. ECTT(I).NE.ID) GO TO 1060        
  540 CONTINUE        
      IF (LOGFL .LE. 0) CALL LOGFIL (CARD)        
      DO 550 JJ = 1,4        
  550 TAPID(JJ) = OUTCRD(JJ+3)        
C        
C      PACK DATE -        
C        
      IMNTH = LSHIFT(IDATE(1),14)        
      IDAY  = LSHIFT(IDATE(2),8)        
      IYEAR = IDATE(3)        
      TAPID(5) = ORF(IMNTH,ORF(IDAY,IYEAR))        
C        
C     REEL NO. TO TAPID        
C        
      TAPID(6) = 1        
C        
C     OUTPUT IF ON NEW PROBLEM TAPE        
C        
      NGINO = PTAPE        
      CALL OPEN  (*1320,PTAPE,GBUFF(DMAPBS+1),1)        
      CALL WRITE (PTAPE,TAPID,6,0)        
      CALL WRITE (PTAPE,TIMEW,1,1)        
      CALL EOF   (PTAPE)        
      CALL CLOSE (PTAPE,2)        
      GO TO 20        
C        
C        
C     PROCESS INTERACTIVE CARD        
C     SET INTRA TO NEGATIVE IN BATCH RUN (I.E. PRE-INTERACTIVE RUN)     
C     INTRA WILL BE RESET TO POSITIVE IN AN ON-LINE INTERACTIVE RUN     
C        
C     CHECK FORMAT AND FILE ASSIGNMENT        
C        
  555 INTRA = 0        
      DO 557 JJ = 4,9        
      IF (OUTCRD(JJ) .EQ. PLOT) INTRA = ORF(INTRA,1)        
      IF (OUTCRD(JJ) .EQ. PRNT) INTRA = ORF(INTRA,2)        
      IF (OUTCRD(JJ) .EQ. BOTH) INTRA = ORF(INTRA,3)        
  557 CONTINUE        
      IF (INTRA .EQ. 0) GO TO 700        
      INTRA = -INTRA        
      JJ = 1        
      IF (MACH .EQ. 3) CALL FACIL (INP9,JJ)        
      IF (JJ   .EQ. 2) GO TO 1250        
      GO TO 20        
C        
C        
C     UMFEDIT CARD FOUND - SET EDTUMF FLAG        
C        
  560 WRITE (OUTTAP,465) UWM,ECTT(I),ECTT(I+1)        
C     EDTUMF = 1        
      GO TO 20        
C        
C        
C     PROCESS PREC CARD        
C        
  565 IMHERE = 565        
      IF (OUTCRD(5).NE.1 .AND. OUTCRD(5).NE.2) GO TO 750        
      PREC = OUTCRD(5)        
      GO TO 20        
C        
C     CEND CARD FOUND - NO MORE CONTROL CARDS TO PROCESS        
C        
C        
C     SET APP DEFAULT TO 'DISPLACEMENT' AND TIME TO 10 MINUTES        
C        
  570 IF (APPRCH .NE. 0) GO TO 572        
      APPRCH  = 2        
      APPREC  = 2        
      WRITE  (OUTTAP,571)        
  571 FORMAT ('0*** APP  DECLARATION CARD MISSING.  DISPLACEMENT IS ',  
     1        'SELECTED BY DEFAULT')        
  572 IF (TIME .GT. 0) GO TO 575        
      TIME = 300        
      WRITE  (OUTTAP,573)        
  573 FORMAT ('0*** TIME  CARD MISSING. MAXIMUM EXECUTION TIME IS SET ',
     1        'TO 5 MINUTES BY DEFAULT')        
C        
C     CALL NSINFO TO PRINT DIAG48, OR        
C     PRINT THE FOLLOWING MESSAGE OUT ONLY IF THE JOB IS RUN ON THE SAME
C     YEAR OF THE RELEASE DATE, AND USER DOES NOT MAKE A DIAG48 REQUEST 
C        
C     DIAG48 TEXT IS STORED IN 4TH SECTION OF THE NASINFO FILE        
C        
C        
  575 CALL SSWTCH (48,JJ)        
      IF (JJ .NE. 1) GO TO 576        
      CALL NSINFO (4)        
      GO TO 580        
  576 JJ = IDATE(3)        
      JJ = MOD(JJ,100)        
      CALL INT2A8 (*577,JJ,IZ(1))        
  577 IF (IZ(1) .EQ. SY42(3)) WRITE (OUTTAP,578) UIM        
  578 FORMAT (//,A29,', TURN DIAG 48 ON FOR NASTRAN RELEASE NEWS, ',    
     1       'DIAG DEFINITION, NEW DMAP', /9X,        
     2       'MODULES AND NEW BULKDATA CARDS INFORMATION')        
C        
C     CLOSE NASINFO FILE IF IT EXISTS        
C     AND RESET THE 37TH WORD OF /SYSTEM/ BACK TO ZERO        
C        
  580 IF (LU .NE. 0) CLOSE (UNIT=LU)        
      LU = 0        
C        
C     NOW MAKE SURE ALL NECESSARY CARDS HAVE BEEN FOUND        
C        
      DO 590 I = 1,LECTT,3        
      TEST = ANDF(ECTT(I+2),MASK)        
      IF (TEST .GT. 0) IF (ECTT(I+2)) 590,1090,1090        
  590 CONTINUE        
C        
C     SET APPRCH NEGATIVE FOR RESTART        
C        
      IF (RSTRT .NE. ICOLD) APPRCH = -APPRCH        
      IF (SOLUF.EQ.1 .AND. DRECSZ.NE.0) GO TO 1120        
      IF (SOLUF.EQ.0 .AND. DRECSZ.EQ.0) GO TO 1150        
C     IF (RSTRT.NE.ICOLD .AND. UMFID.NE.0) GO TO 1030        
C        
C        
  600 IF (NOGO .GT. 1) GO TO 1380        
C        
C     WRITE XCSA CONTROL FILE ONTO PROBLEM TAPE        
C     FIRST RECORD IS HEADER RECORD CONTAINING A SINGLE WORD (XCSA)     
C        
      IF (APPREC .EQ. APPDMP) GO TO 610        
C        
C     IF APPROACH IS HEAT ADD TWENTY THREE TO SOLUTION        
C        
      IF (APPREC .EQ. APPHEA) SOLU(1) = SOLU(1) + 23        
C        
C     IF APPROACH IS AEROELASTIC ADD THIRTY TO SOLUTION        
C        
      IF (APPREC .EQ. APPAER) SOLU(1) = SOLU(1) + 30        
  610 NGINO = PTAPE        
      IMHERE= 610        
      CALL OPEN  (*1320,PTAPE,GBUFF(DMAPBS+1),3)        
      CALL WRITE (PTAPE,NXCSA,2,1)        
C        
C     DIS OLD PT HAVE AN ALTER FILE AND/OR CKPT DIST        
C        
      SOLREC(4) = OLDALT        
C        
C     WRITE SIX-WORD CONTROL FILE RECORD        
C        
      CALL WRITE (PTAPE,SOLREC,6,1)        
      CALL EOF   (PTAPE)        
      CALL CLOSE (PTAPE, 3)        
      NGINO = NSCR        
      IMHERE= 613        
      CALL OPEN (*1320,NSCR,GBUFF(DMAPBS+1),1)        
      IF (APPREC .EQ. APPDMP) GO TO 620        
C        
C     APPROACH IS RIGID FORMAT        
C     WRITE RIGID FORMAT AND MED TABLES ONTO SCRATCH FILE        
C        
      ISIZE = KORSZ (DMAPBF(1)) - IBUFSZ        
      CALL XRGDFM (SOLU,OSOLU,APPREC,IUFILE,DMAPBF,ISIZE,NSCR,NOGO)     
      IF (XNOGO .EQ. 0) GO TO 615        
      IF (NOGO  .EQ. 0) NOGO = 1        
      XNOGO = 0        
  615 CONTINUE        
      IF (NOGO .GT. 1) GO TO 1380        
      GO TO 630        
C        
C     APPROACH IS DMAP        
C     WRITE DMAP SEQUENCE ONTO SCRATCH FILE FROM OPEN CORE        
C        
  620 CALL WRITE (NSCR,DMAPBF,DRECSZ,1)        
  630 CALL CLOSE (NSCR,1)        
  640 CONTINUE        
C        
C     PUNCH RESTART CARD IF CHECKPOINT FLAG IS SET.        
C        
      IF (ICPFLG .EQ. 0) GO TO 660        
      WRITE  (LDICT,641) (TAPID(I),I=1,4),(IDATE(J),J=1,3),TIMEW        
  641 FORMAT (9HRESTART  ,2A4,1H,,2A4,1H,,I2,1H/,I2,1H/,I2,1H,,I8,1H,)  
      CALL SSWTCH (9,DIAG09)        
      IF (DIAG09 .EQ. 1) GO TO 660        
      CALL PAGE        
      WRITE  (OUTTAP,651) (TAPID(I),I=1,4),(IDATE(J),J=1,3),TIMEW       
  651 FORMAT ('0ECHO OF FIRST CARD IN CHECKPOINT DICTIONARY TO BE ',    
     1        'PUNCHED OUT FOR THIS PROBLEM', /        
     2 14H0   RESTART   ,2A4,1H,,2A4,1H,,I2,1H/,I2,1H/,I2,1H,,I8,1H,)   
  660 XNOGO = NOGO        
      RETURN        
C        
C     ERROR MESSAGES        
C        
C     USER  FATAL MESSAGES        
C        
  670 NLINES = NLINES + 2        
      IF (NLINES .GE. NLPP) CALL PAGE        
      IF (NOGO   .LT.    1) NOGO = 1        
      IGNORE = 1        
      GO TO IRTN2, ( 700, 730, 770, 800, 830, 860, 890, 920, 950,       
     1              1070,1100,1130,1160,1190,1220,1234)        
C        
  690 ASSIGN 700 TO IRTN2        
      MSGNUM = 505        
      GO TO 670        
  700 WRITE  (OUTTAP,710) UFM,MSGNUM,OUTCRD(2),OUTCRD(3)        
  710 FORMAT (A23,I5,', CONTROL CARD ',2A4,11H IS ILLEGAL)        
      GO TO 20        
C        
  720 ASSIGN 730 TO IRTN2        
      MSGNUM = 506        
      GO TO 670        
  730 WRITE  (OUTTAP,740) UFM,MSGNUM,OUTCRD(2),OUTCRD(3)        
  740 FORMAT (A23,I5,', CONTROL CARD ',2A4,11H DUPLICATED)        
      GO TO 20        
C        
  750 CONTINUE        
  760 ASSIGN 770 TO IRTN2        
      MSGNUM = 507        
      GO TO 670        
  770 WRITE  (OUTTAP,780) UFM,MSGNUM,IMHERE        
  780 FORMAT (A23,I5,', ILLEGAL SPECIFICATION OR FORMAT ON PRECEDING ', 
     1       'CARD.', /5X,'IMHERE =',I5)        
      IF (OUTCRD(2).EQ.ECTT(34) .AND. OUTCRD(3).EQ.ECTT(35)) GO TO 531  
      GO TO 20        
C        
  790 ASSIGN 800 TO IRTN2        
      MSGNUM = 508        
      GO TO 670        
  800 WRITE  (OUTTAP,810) UFM,MSGNUM        
  810 FORMAT (A23,I5,', PROBLEM TAPE MUST BE ON PHYSICAL TAPE FOR ',    
     1      'CHECK POINTING')        
      IGNORE = 0        
      ICPFLG = 0        
      GO TO 20        
C        
  820 ASSIGN 830 TO IRTN2        
      MSGNUM = 509        
      GO TO 670        
  830 WRITE  (OUTTAP,840) UFM,MSGNUM,(OTAPID(I),I=1,4),IMNTH,IDAY,      
     1                    IYEAR,TIMEX,OTAPID(6)        
  840 FORMAT (A23,I5,', WRONG OLD TAPE MOUNTED.', /30X,        
     1        23H OLD PROBLEM TAPE ID = ,2A4,1H,,2A4,1H,,I2,1H/,I2,1H/, 
     2        I2,1H,,2X,I8,1H,,5X,10HREEL NO. =,I4)        
      GO TO 1410        
C        
  850 ASSIGN 860 TO IRTN2        
      MSGNUM = 512        
      GO TO 670        
  860 WRITE  (OUTTAP,870) UFM,MSGNUM        
  870 FORMAT (A23,I5,', OLD PROBLEM TAPE IS MISSING AND IS NEEDED FOR ',
     1       'RESTART')        
      NOGO = 3        
      GO TO 20        
C        
  880 ASSIGN 890 TO IRTN2        
      MSGNUM = 513        
      GO TO 670        
  890 WRITE  (OUTTAP,900) UFM,MSGNUM        
  900 FORMAT (A23,I5,', ALTER SEQUENCE NUMBERS ARE OUT OF ORDER')       
      ALTER(1) = 0        
      ALTER(2) = 0        
      IF (NOGO .LT. 2) NOGO = 2        
      GO TO 360        
C        
  910 ASSIGN 920 TO IRTN2        
      MSGNUM = 514        
      GO TO 670        
  920 WRITE  (OUTTAP,930) UFM,MSGNUM        
  930 FORMAT (A23,I5,', ENDALTER CARD IS MISSING')        
      IF (NOGO .LT. 2) NOGO = 2        
      GO TO 570        
C        
  940 ASSIGN 950 TO IRTN2        
      MSGNUM = 515        
      GO TO 670        
  950 WRITE  (OUTTAP,960) UFM,MSGNUM        
  960 FORMAT (A23,I5,', END INSTRUCTION MISSING IN DMAP SEQUENCE')      
      IF (NOGO .LT. 2) NOGO = 2        
      GO TO 570        
C        
C 970 ASSIGN 980 TO IRTN2        
C     MSGNUM = 516        
C     GO TO 670        
C 980 WRITE  (OUTTAP,990) UFM,MSGNUM        
C 990 FORMAT (A23,I5,', UMF TAPE MUST BE MOUNTED ON PHYSICAL TAPE ',    
C    1       'DRIVE')        
C     NOGO = 3        
C     GO TO 20        
C        
C1000 ASSIGN 1010 TO IRTN2        
C     MSGNUM = 517        
C     GO TO 670        
C1010 WRITE  (OUTTAP,1020) UFM,MSGNUM,UMFID        
C1020 FORMAT (A23,I5,', WRONG UMF TAPE MOUNTED - TAPE ID =',I10)        
C     NOGO = 3        
C     GO TO 20        
C        
C1030 ASSIGN 1040 TO IRTN2        
C     MSGNUM = 518        
C     GO TO 670        
C1040 WRITE  (OUTTAP,1050) UFM,MSGNUM        
C1050 FORMAT (A23,I5,', CANNOT USE UMF TAPE FOR RESTART')        
C     NOGO = 3        
C     GO TO 1380        
C        
 1060 ASSIGN 1070 TO IRTN2        
      MSGNUM = 519        
      GO TO 670        
 1070 WRITE  (OUTTAP,1080) UFM,MSGNUM        
 1080 FORMAT (A23,I5,', ID CARD MUST PRECEDE ALL OTHER CONTROL CARDS')  
      NOGO = 3        
      GO TO 20        
C        
 1090 ASSIGN 1100 TO IRTN2        
      MSGNUM = 520        
      GO TO 670        
 1100 WRITE  (OUTTAP,1110) UFM,MSGNUM,ECTT(I),ECTT(I+1)        
 1110 FORMAT (A23,I5,', CONTROL CARD ',2A4,' IS MISSING')        
      ECTT(I+2) = ORF(ECTT(I+2),MASK5)        
      IF (ECTT(I) .NE. ECTT(4)) GO TO 570        
C        
C     MISSING CARD IS APP        
C        
      IF (NOGO .LT. 2) NOGO = 2        
      GO TO 570        
C        
 1120 ASSIGN 1130 TO IRTN2        
      MSGNUM = 521        
      GO TO 670        
 1130 WRITE  (OUTTAP,1140) UFM,MSGNUM        
 1140 FORMAT (A23,I5,', SPECIFY A SOLUTION OR A DMAP SEQUENCE BUT NOT ',
     1      'BOTH')        
      IF (NOGO .LT. 2) NOGO = 2        
      GO TO 1380        
C        
 1150 ASSIGN 1160 TO IRTN2        
      MSGNUM = 522        
      GO TO 670        
 1160 WRITE  (OUTTAP,1170) UFM,MSGNUM        
 1170 FORMAT (A23,I5,', NEITHER A SOL CARD NOR A DMAP SEQUENCE WAS ',   
     1       'INCLUDED')        
      IF (NOGO .LT. 2) NOGO = 2        
      GO TO 1380        
C        
 1180 ASSIGN 1190 TO IRTN2        
      NOTALT = 0        
      MSGNUM = 523        
      GO TO 670        
 1190 WRITE  (OUTTAP,1200) UFM,MSGNUM        
 1200 FORMAT (A23,I5,', ENDALTER CARD OUT OF ORDER')        
      GO TO 20        
C        
 1210 ASSIGN 1220 TO IRTN2        
      MSGNUM = 526        
      GO TO 670        
 1220 WRITE  (OUTTAP,1230) UFM,MSGNUM        
 1230 FORMAT (A23,I5,', CHECKPOINT DICTIONARY OUT OF SEQUENCE - ',      
     1       'REMAINING RESTART CARDS IGNORED')        
      GO TO 20        
 1232 ASSIGN 1234 TO IRTN2        
      MSGNUM = 529        
      GO TO 670        
 1234 WRITE  (OUTTAP,1236) UFM,MSGNUM        
 1236 FORMAT (A23,I5,', MISSING CEND CARD.')        
      NOGO = 3        
      GO TO 1380        
C        
C     SYSTEM FATAL MESSAGES        
C        
 1240 NLINES = NLINES +2        
      IF (NLINES .GE. NLPP) CALL PAGE        
      IF (NOGO   .LT.    2) NOGO = 2        
      IGNORE = 1        
      GO TO IRTN2, (1255,1270,1300,1330,1360)        
C        
 1250 ASSIGN 1255 TO IRTN2        
      MSGNUM = 530        
      GO TO 1240        
 1255 WRITE  (OUTTAP,1256) SFM,MSGNUM        
 1256 FORMAT (A25,I5,2H, , /5X,'INP9 FILE WAS NOT ASSIGNED FOR ',       
     1       'NASTRAN INTERACTIVE POST-PROCESSOR',/)        
      GO TO 20        
 1260 ASSIGN 1270 TO IRTN2        
      MSGNUM = 510        
      GO TO 1240        
 1270 WRITE  (OUTTAP,1280) SFM,MSGNUM        
 1280 FORMAT (A25,I5,', CHECKPOINT DICTIONARY EXCEEDS CORE SIZE - ',    
     1       'REMAINING RESTART CARDS IGNORED')        
      GO TO 20        
C        
 1290 ASSIGN 1300 TO IRTN2        
      MSGNUM = 511        
      GO TO 1240        
 1300 WRITE  (OUTTAP,1310) SFM,MSGNUM        
 1310 FORMAT (A25,I5,', DMAP SEQUENCE EXCEEDS CORE SIZE - ',        
     1       'REMAINING DMAP INSTRUCTIONS IGNORED')        
      IF (NOGO .LT. 2) NOGO = 2        
      GO TO 20        
C        
 1320 ASSIGN 1330 TO IRTN2        
      MSGNUM = 524        
      GO TO 1240        
 1330 WRITE  (OUTTAP,1340) SFM,MSGNUM,NGINO,IMHERE        
 1340 FORMAT (A25,I5,', ALTERNATE RETURN TAKEN WHEN OPENING FILE ',A4,  
     1        3X,1H-,I3)        
      NOGO = 3        
      GO TO 1410        
C        
 1350 ASSIGN 1360 TO IRTN2        
      MSGNUM = 525        
      GO TO 1240        
 1360 WRITE  (OUTTAP,1370) SFM,MSGNUM,NGINO        
 1370 FORMAT (A25,I5,', ILLEGAL FORMAT ENCOUNTERED WHILE READING FILE ',
     1        A4)        
      NOGO = 3        
      GO TO 1410        
C        
 1380 GO TO (600,1400,1390), NOGO        
C        
C     NOGO = 3 - TERMINATE JOB HERE        
C        
 1390 ICPFLG = 0        
      CALL MESAGE (-61,0,0)        
C        
C     NOGO = 2 - PUT IN DUMMY CONTROL FILE ON PROBLEM TAPE        
C        
 1400 NGINO = PTAPE        
      CALL CLOSE (PTAPE,1)        
      CALL OPEN  (*1320,PTAPE,GBUFF(DMAPBS+1),0)        
      CALL SKPFIL(PTAPE,1)        
      CALL CLOSE (PTAPE,2)        
      CALL OPEN  (*1320,PTAPE,GBUFF(DMAPBS+1),3)        
      CALL WRITE (PTAPE,NXCSA,2,1)        
      SOLU(1) = 0        
      SOLU(2) = 0        
      APPRCH  = APPDMP        
      IF (RSTRT .NE. ICOLD) APPRCH = -APPRCH        
      CALL WRITE (PTAPE,SOLREC,6,1)        
      CALL EOF   (PTAPE)        
      CALL CLOSE (PTAPE,3)        
      GO TO 640        
C        
C        
C     XCSA HAS BEEN DISASTERED - GET DUMP AND QUIT.        
C        
 1410 ICPFLG = 0        
 1420 CALL MESAGE (-37,0,NXCSA)        
      RETURN        
      END        
