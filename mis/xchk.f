      SUBROUTINE XCHK        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO SAVE ON THE NEW PROBLEM NPTP    
C     TAPE ALL FILES REQUESTED BY XCHK OSCAR ENTRY TOGETHER WITH ANY    
C     OTHER DATA NECESSARY FOR RESTART.        
C        
C          ... DEFINITION OF PROGRAM VARIABLES ...        
C     NPTPNT = POINTER TO GINO BUFFER FOR NEW PROBLEM NPTP TAPE        
C     DPPNT  = POINTER TO GINO BUFFER FOR DATA POOL TAPE        
C     FPNT   = POINTER TO GINO BUFFER FOR FILES LISTED IN FIAT TABLE    
C     IOBUF  = INPUT/OUTPUT BUFFER AREA        
C     IOPNT  = POINTER TO IOBUF        
C     LIOBUF = LENGTH OF IOBUF        
C     DICT   = PRELIMINARY FILE DICTIONARY        
C     FDICT  = FINAL FILE DICTIONARY TO BE WRITTEN ON NEW PROBLEM TAPE  
C     LDC    = POINTER TO LAST DICT ENTRY MADE.        
C     DCPNT  = POINTER TO DICT ENTRY BEING SCANNED.        
C     NPTFN  = NEW PROBLEM TAPE (NPTP) FILE NUMBER TO BE ASSIGNED       
C     UCBPNT = UCB POINTER FOUND IN FIAT ENTRIES        
C     MINFN  = SMALLEST DATA POOL FILE NUMBER        
C     DPFCT  = DATA POOL FILE POSITION        
C     OSCFN  = DATA POOL FILE NUMBER OF OSCAR FILE        
C     EORFLG = END OF RECORD FLAG        
C     PURGE  = TABLE OF PURGED CHECKPOINT FILES        
C     LPURGE = LENGTH OF PURGE TABLE        
C     PRGPNT = POINTER TO LAST PURGE ENTRY        
C     REELCT = KEEPS TRACK OF HOW MANY PROBLEM TAPE REELS A FILE IS     
C              USING        
C     EQFLG  = EQUIVALENCE FLAG        
C     DPLFLG = DATA POOL FLAG        
C     EOTFLG = END OF TAPE FLAG        
C     SETEOR = END OF RECORD FLAG SET        
C     FNASS  = NPTP FILE NUMBER ASSIGNED FLAG        
C     MASKHI = MASK FOR ALL BITS EXCEPT LOWEST ORDER 16 BITS OF A WORD. 
C     NOFLGS = MASK FOR ALL FLAG BITS        
C     ALLON  = ALL BITS ON        
C     PTDIC  = ARRAY CONTAINING CHECKPOINT DICTIONARY        
C     SEQNO  = SEQUENCE NO. OF LAST PTDIC ENTRY THAT WAS PUNCHED OUT.   
C     NRLFL  = NEXT REEL/FILE NO. TO BE USED IN PTDIC        
C     PTDTOP = POINTER TO FIRST WORD OF FIRST ENTRY IN PTDIC        
C     PTDBOT = POINTER TO FIRST WORD OF LAST  ENTRY IN PTDIC        
C     LCPTP  = POINTER TO FIRST WORD OF FIRST ENTRY OF NEW GROUP OF     
C              ENTRIES TO BE PUT IN PTDIC.        
C     LPTDIC = LENGTH (IN WORDS) OF PTDIC        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      DIMENSION       BLKCNT(90),DCPARM(2),HEAD(2),PURGE(100),SVFST(2), 
     1                PGHDG(1),HDG(32),DICT(400),FDICT(400),PTDIC(1),   
     2                NXPTDC(2),IOBUF(1),NXCHK(2),NVPS(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /XFIST / FIST(2)        
      COMMON /XPFIST/ IPFST        
      COMMON /OSCENT/ OSCAR(7)        
      COMMON /XCEITB/ CEITBL(2)        
      COMMON /XFIAT / FIAT(3)        
      COMMON /XDPL  / DPL(3)        
      COMMON /XVPS  / VPS(2)        
CZZ   COMMON /ZZXSEM/ GBUF(1)        
      COMMON /ZZZZZZ/ GBUF(1)        
      COMMON /SYSTEM/ ZSYS(91),LDICT        
      COMMON /MACHIN/ MACH        
      COMMON /OUTPUT/ PGHDG        
      COMMON /STAPID/ TAPID(6)        
      EQUIVALENCE     (ZSYS( 1),BUFSZ ),(ZSYS( 2),OTPE  ),        
     1                (ZSYS( 9),NLPP  ),(ZSYS(11),NPAGES),        
     2                (ZSYS(12),NLINES),(ZSYS(24),ICFIAT),        
     3                (ZSYS(26),CPPGCT),(ZSYS(40),NBPW  )        
      EQUIVALENCE     (DCPARM(1),NRLFL),(DCPARM(2),SEQNO),        
     1                (GBUF(1),IOBUF(1),PTDIC(1))        
      DATA    NPTP  / 4HNPTP/        
      DATA    DPT   / 4HPOOL/        
      DATA    NBLANK/ 4H    /        
      DATA    NOSCAR/ 4HXOSC/        
      DATA    NXCHK / 4HXCHK,4H    /        
      DATA    NVPS  / 4HXVPS,4H    /        
      DATA    NXPTDC/ 4HXPTD,4HIC  /, DCPARM/4H(NON,4HE)  /        
      DATA    HDG   / 4H    ,4HADDI,4HTION,4HS TO,4H CHE,4HCKPO,4HINT , 
     1                4HDICT,4HIONA,4HRY  ,22*4H    /        
      DATA    BLKCNT/ 90*0  /,      LIMIT /90       /        
      DATA    LPURGE/ 100   /        
C        
C     INITIALIZE        
C        
      FILCNT = 0        
      REELCT = 0        
      LDC    =-2        
      RECSZ  = 0        
      PRGPNT =-1        
      CALL SSWTCH (9,DIAG09)        
      IF (MACH .LT. 5) CALL XFLSZD (0,BLKSIZ,0)        
C        
C     MASKHI - O000000077777        
      MASKHI = 32767        
C        
C     DPLFLG - O004000000000        
      DPLFLG = LSHIFT(1,29)        
C        
C     SETEOR - O004000000000        
      SETEOR = DPLFLG        
C        
C     FNASS  - O010000000000        
      FNASS  = LSHIFT(1,30)        
C        
C     EOTFLG - O010000000000        
      EOTFLG = FNASS        
C        
C     ALLON  - O777777777777        
      ALLON  = COMPLF(0)        
C        
C     NOSGN  - O377777777777        
      NOSGN  = RSHIFT(ALLON,1)        
C        
C     EQFLG  - O400000000000        
      EQFLG  = COMPLF(NOSGN)        
C        
C     NOFLGS - O003777777777        
      NOFLGS = RSHIFT(ALLON,NBPW-29)        
C        
C        
C     FIND OSCAR FILE NUMBER IN DPL        
C        
      J1 = DPL(3)*3 + 1        
      DO 10 J = 4,J1,3        
      IF (DPL(J) .EQ. NOSCAR) GO TO 20        
   10 CONTINUE        
   20 OSCFN = ANDF(DPL(J+2),MASKHI)        
      DPFCT = OSCFN        
C        
C     ALLOCATE CORE FOR GINO BUFFERS        
C        
      NPTPNT = KORSZ(GBUF) - BUFSZ - 1        
      DPPNT  = NPTPNT - BUFSZ        
      FPNT   = DPPNT  - BUFSZ        
      IF (FPNT .LT. 1) CALL MESAGE (-8,0,NXCHK)        
C        
C     INITIALIZE PTDIC PARAMETERS AND LOAD CHECKPOINT DICTIONARY        
C        
      NGINO = NXPTDC(1)        
      CALL OPEN (*905,NXPTDC,GBUF(NPTPNT),0)        
      CALL READ (*970,*30,NXPTDC,DCPARM,2,1,RECSZ)        
   30 IF (DCPARM(1) .NE. NXPTDC(1)) GO TO 970        
      CALL READ (*970,*35,NXPTDC,DCPARM,2,1,RECSZ)        
   35 PTDTOP = 1        
      LPTDIC = NPTPNT - PTDTOP        
      CALL READ (*970,*40,NXPTDC,PTDIC(PTDTOP),LPTDIC,1,RECSZ)        
      GO TO 940        
   40 PTDBOT = RECSZ  + PTDTOP - 3        
      IOPNT  = PTDBOT + 6        
      LIOBUF = FPNT - IOPNT        
      IF (LIOBUF .LT. 1) CALL MESAGE (-8,0,NXCHK)        
      CALL CLOSE (NXPTDC,1)        
      LCPTP = PTDBOT + 3        
C        
C     SAVE CHECKPOINT DMAP SEQ. NO. AND RECORD NO.        
C        
      PTDIC(LCPTP  ) = NBLANK        
      PTDIC(LCPTP+1) = NBLANK        
      PTDIC(LCPTP+2) = ORF(OSCAR(2),LSHIFT(ANDF(MASKHI,OSCAR(6))+1,16)) 
      NPTFN = NRLFL        
C        
C     GET FIRST/NEXT FILE NAME FROM OSCAR ENTRY        
C        
      I1 = OSCAR(7)*2 + 6        
      DO 200 I = 8,I1,2        
C        
C     SEE IF FILE IS ALREADY IN DICT        
C        
      IF (OSCAR(I).EQ.NVPS(1) .AND. OSCAR(I+1).EQ.NVPS(2)) GO TO 200    
      IF (LDC .LT. 0) GO TO 110        
      DO 100 J = 1,LDC,3        
      IF (DICT(J).EQ.OSCAR(I) .AND. DICT(J+1).EQ.OSCAR(I+1)) GO TO 200  
  100 CONTINUE        
C        
C     CHECK FIAT TABLE FOR FILE NAME        
C        
  110 J1 = FIAT(3)*ICFIAT - 2        
      DO 115 J = 4,J1,ICFIAT        
      IF (OSCAR(I).EQ.FIAT(J+1) .AND. OSCAR(I+1).EQ.FIAT(J+2)) GO TO 120
  115 CONTINUE        
      GO TO 160        
C        
C     FILE IS IN FIAT - ENTER FILE AND ALL EQUIVALENCED FILES IN DICT   
C        
  120 IF (ANDF(FIAT(J),MASKHI) .EQ. MASKHI) GO TO 155        
C        
C     FILE NOT PURGED - CHECK FIAT TRAILER WORDS TO INSURE THAT FILE HAS
C     BEEN GENERATED        
C        
      IF (FIAT(J+3).NE.0 .OR. FIAT(J+4).NE.0 .OR. FIAT(J+5).NE.0)       
     1    GO TO 125        
      IF (ICFIAT.EQ.11 .AND. (FIAT(J+8).NE.0 .OR. FIAT(J+9).NE.0 .OR.   
     1    FIAT(J+10).NE.0)) GO TO 125        
      GO TO 155        
  125 IF (FIAT(J) .LT. 0) GO TO 145        
      LDC = LDC + 3        
      DICT(LDC  ) = FIAT(J+1)        
      DICT(LDC+1) = FIAT(J+2)        
      DICT(LDC+2) = ORF(LSHIFT(J,16),ANDF(FIAT(J),MASKHI))        
C        
C     DESTROY ANY EQUIVS TO THIS FILE        
C        
C     FIND LAST DICTIONARY REFERENCE TO THIS DATA BLOCK NAME        
C        
      DO 130 J = PTDTOP,PTDBOT,3        
      K = PTDBOT - (J-PTDTOP)        
      IF (DICT(LDC).EQ.PTDIC(K) .AND. PTDIC(K+1).EQ.DICT(LDC+1))        
     1    GO TO 132        
  130 CONTINUE        
      GO TO 140        
C        
C     FILE EXISTS IN DICTIONARY SEE IF IT IS EQUIVED        
C        
  132 CONTINUE        
      IF (ANDF(PTDIC(K+2),EQFLG) .EQ. 0) GO TO 140        
C        
C     FILE IS EQUIVED.  PURGE ALL SUBSEQUENT ENTRIES FOR THIS FILE      
C        
      IF (K .EQ. PTDBOT) GO TO 140        
      DO 135 J = K,PTDBOT,3        
      IF (PTDIC(J+2) .NE. PTDIC(K+2)) GO TO 135        
C        
C     PURGE FILE        
C        
      PRGPNT = PRGPNT + 2        
      IF (LPURGE .LT. PRGPNT+1) GO TO 960        
      PURGE(PRGPNT  ) = PTDIC(J  )        
      PURGE(PRGPNT+1) = PTDIC(J+1)        
  135 CONTINUE        
  140 CONTINUE        
      GO TO 200        
  145 K = ANDF(FIAT(J),ORF(MASKHI,EQFLG))        
      DO 150 J = 4,J1,ICFIAT        
      IF (ANDF(FIAT(J),ORF(MASKHI,EQFLG)) .NE. K) GO TO 150        
      LDC = LDC + 3        
C        
C     EQUIVALENCED FILE FOUND        
C        
      DICT(LDC  ) = FIAT(J+1)        
      DICT(LDC+1) = FIAT(J+2)        
C        
C     ENTER EQUIVALENCE FLAG, FIAT POINTER AND UCB POINTER IN DICT      
C        
      DICT(LDC+2) = ORF(LSHIFT(J,16),K)        
  150 CONTINUE        
      GO TO 200        
C        
C     ENTER PURGED FILE IN PURGE TABLE        
C        
  155 PRGPNT = PRGPNT + 2        
      IF (LPURGE .LT. PRGPNT+1) GO TO 960        
      PURGE(PRGPNT  ) = OSCAR(I  )        
      PURGE(PRGPNT+1) = OSCAR(I+1)        
      GO TO 200        
C        
C     SEE IF FILE IS IN DPL        
C        
  160 J1 = DPL(3)*3 + 1        
      DO 170 J = 4,J1,3        
      IF (OSCAR(I).EQ.DPL(J) .AND. OSCAR(I+1).EQ.DPL(J+1)) GO TO 180    
  170 CONTINUE        
      GO TO 155        
C        
C     FILE IS IN DPL - ENTER FILE AND ALL EQUIVALENCED FILES IN DICT    
C        
  180 K = ANDF(DPL(J+2),MASKHI)        
      DPFCT = MIN0(OSCFN,K)        
      DO 190 J = 4,J1,3        
      IF (ANDF(DPL(J+2),MASKHI) .NE. K) GO TO 190        
      LDC = LDC + 3        
C        
C     EQUIVALENCED FILE FOUND        
C        
      DICT(LDC  ) = DPL(J  )        
      DICT(LDC+1) = DPL(J+1)        
C        
C     ENTER EQUIVALENCE FLAG, DPLFLG AND FILE NO. IN DICT        
C        
      DICT(LDC+2) = ORF(DPLFLG,ANDF(DPL(J+2),ORF(MASKHI,EQFLG)))        
  190 CONTINUE        
  200 CONTINUE        
C        
C     MOVE DICT ENTRIES TO FDICT TABLE        
C     GET FIRST NEXT/ENTRY IN DICT        
C        
      IF (LDC .LT. 1) GO TO 400        
      DO 300 I = 1,LDC,3        
C        
C     IF DICT ENTRY IS EQUIVALENCED - SEE IF IT IS IN PTDIC        
C        
      IF (ANDF(DICT(I+2),FNASS) .EQ. FNASS) GO TO 300        
      IF (DICT(I+2) .GT. 0) GO TO 225        
C        
C     SEARCH BACKWARD FOR PREVIOUS ENTRY        
C        
      DO 210 J = PTDTOP,PTDBOT,3        
      K = PTDBOT - (J-PTDTOP)        
      IF (PTDIC(K).EQ.DICT(I) .AND. PTDIC(K+1).EQ.DICT(I+1) .AND.       
     1    PTDIC(K+2).NE.0) GO TO 215        
  210 CONTINUE        
      GO TO 225        
C        
C     DICT ENTRY IS IN PTDIC        
C        
  215 FDICT(I  ) = DICT(I  )        
      FDICT(I+1) = DICT(I+1)        
      FDICT(I+2) = ORF(PTDIC(K+2),EQFLG)        
      UCBPNT     = DICT(I+2)        
      DICT(I+2)  = FNASS        
C        
C     ENTER PTDIC FILE NUMBER IN FDICT ENTRIES THAT ARE EQUIVALENCED TO 
C     PTDIC ENTRY        
C        
      UCBPNT = ANDF(UCBPNT,ORF(MASKHI,DPLFLG))        
      DO 220 J = 1,LDC,3        
      IF (ANDF(DICT(J+2),ORF(MASKHI,DPLFLG)) .NE. UCBPNT) GO TO 220     
      FDICT(J  ) = DICT(J  )        
      FDICT(J+1) = DICT(J+1)        
      FDICT(J+2) = ORF(EQFLG,PTDIC(K+2))        
      DICT(J+2)  = FNASS        
  220 CONTINUE        
C        
C     MOVE DICT ENTRY TO FDICT IF NOT ALREADY MOVED        
C        
  225 IF (ANDF(DICT(I+2),FNASS) .EQ. FNASS) GO TO 300        
      FDICT(I  ) = DICT(I  )        
      FDICT(I+1) = DICT(I+1)        
      FDICT(I+2) = DICT(I+2)        
      IF (ANDF(DICT(I+2),DPLFLG) .EQ. DPLFLG) GO TO 300        
C        
C     DICT ENTRY IS FIAT FILE - ENTER NPTP FILE NO. IN FDICT        
C        
      FDICT(I+2) = ORF(ANDF(FDICT(I+2),EQFLG),NPTFN)        
      DICT (I+2) = ORF(DICT(I+2),FNASS)        
      IF (DICT(I+2) .GT. 0) GO TO 295        
C        
C     FILE IS EQUIVALENCED - ENTER NPTP FILE NO. IN FDICT FOR FILES THAT
C     THIS ENTRY IS EQUIVALENCED TO.        
C        
      UCBPNT = ANDF(DICT(I+2),MASKHI)        
      J1 = I + 3        
      IF (J1 .GT. LDC) GO TO 295        
      DO 230 J = J1,LDC,3        
      IF (ANDF(DICT(J+2),MASKHI) .NE. UCBPNT) GO TO 230        
      FDICT(J  ) = DICT(J  )        
      FDICT(J+1) = DICT(J+1)        
      FDICT(J+2) = FDICT(I+2)        
      DICT(J+2)  = ORF(DICT(J+2),FNASS)        
  230 CONTINUE        
  295 NPTFN = 1 + NPTFN        
  300 CONTINUE        
C        
C     NOW ASSIGN NPTP FILE NUMBERS TO DATA POOL FILES IN SAME ORDER THAT
C     FILES APPEAR ON DATA POOL TAPE.        
C        
  310 MINFN = RSHIFT(ALLON,1)        
C        
C     GET FIRST/NEXT DICT ENTRY        
C        
      DO 330 I = 1,LDC,3        
      IF (ANDF(DICT(I+2),FNASS) .EQ. FNASS) GO TO 330        
      MINFN = MIN0(MINFN,ANDF(DICT(I+2),MASKHI))        
  330 CONTINUE        
      IF (MINFN .EQ. RSHIFT(ALLON,1)) GO TO 400        
      DO 350 I = 1,LDC,3        
      IF (ANDF(DICT(I+2),FNASS)  .EQ. FNASS) GO TO 350        
      IF (ANDF(DICT(I+2),MASKHI) .NE. MINFN) GO TO 350        
      FDICT(I+2) = ORF(NPTFN,ANDF(FDICT(I+2),EQFLG))        
      DICT (I+2) = ORF(DICT(I+2),FNASS)        
  350 CONTINUE        
      NPTFN = NPTFN + 1        
      GO TO 310        
C        
C     OPEN DATA POOL TAPE SO IT IS POSITIONED BEFORE FIRST FILE TO      
C     CHECKPOINT.        
C        
  400 IF (DPFCT .LT. OSCFN) GO TO 401        
      J = 2        
      DPFCT = OSCFN        
      GO TO 402        
  401 J = 0        
      DPFCT = 1        
  402 NAME  = DPT        
      CALL OPEN (*905,DPT,GBUF(DPPNT),J)        
      NAME  = NPTP        
C        
C     OPEN NEW PROBELM NPTP TAPE FOR WRITE        
C        
      CALL OPEN (*905,NPTP,GBUF(NPTPNT),3)        
C        
C     MAKE TEMPORARY ENTRY IN FIST FOR FIAT FILES        
C        
      IFSTMP   = 2*IPFST + 3        
      SVFST(1) = FIST(IFSTMP  )        
      SVFST(2) = FIST(IFSTMP+1)        
      FIST(2)  = IPFST + 1        
      FIST(IFSTMP) = 301        
C        
C     WRITE FILES ON NEW PROBLEM NPTP TAPE AS SPECIFIED IN FDICT.       
C        
      N1 = NPTFN - 1        
C        
C     GET FIRST/NEXT FDICT ENTRY        
C        
      N = NRLFL        
      IF (LDC.LT.1 .OR. N1.LT.N) GO TO 615        
  405 DO 410 I = 1,LDC,3        
      IF (ANDF(FDICT(I+2),NOFLGS) .EQ. N) GO TO 415        
  410 CONTINUE        
C        
C     FDICT ENTRIES SHOULD ALL BE COPIED - MAKE SURE ALL IS O.K.        
C        
      DO 412 I = 1,LDC,3        
      IF (ANDF(FDICT(I+2),NOFLGS) .GT. N) GO TO 920        
  412 CONTINUE        
      NPTFN = N        
      GO TO 615        
C        
C     THIS FDICT ENTRY IS NEXT TO GO ON NEW PROBLEM NPTP TAPE.        
C        
  415 IF (ANDF(DICT(I+2),DPLFLG) .EQ. DPLFLG) GO TO 450        
C        
C     FILE IS IN FIAT TABLE        
C        
      K = RSHIFT(ANDF(NOFLGS,DICT(I+2)),16)        
      IF (DICT(I+2) .GT. 0) GO TO 418        
C        
C     GET SMALLEST FIAT POINTER FOR EQUIVALENCED FIAT FILES        
C        
      DO 416 II = 1,LDC,3        
      IF (ANDF(DICT(II+2),DPLFLG) .EQ. DPLFLG) GO TO 416        
      IF (ANDF(DICT(I+2),MASKHI)  .EQ. ANDF(DICT(II+2),MASKHI))        
     1    K = MIN0(RSHIFT(ANDF(NOFLGS,DICT(II+2)),16),K)        
  416 CONTINUE        
C        
C     INSERT FIAT POINTER IN TEMPORARY FIST ENTRY        
C        
  418 FIST(IFSTMP+1) = K - 1        
C        
C     READ FIRST 2 WORDS OF DATA BLOCK, CHECK NAME AND WRITE TO NEW     
C     PROBLEM NPTP TAPE SPECIAL HEADER AND 3 OR 6 TRAILER WORDS        
C     (TOTAL OF 5 OR 8 WORDS IN THIS NPTP RECORD)        
C        
      NGINO = FIST(IFSTMP)        
      CALL OPEN (*900,NGINO,GBUF(FPNT),0)        
      FILCNT = FILCNT + 1        
      IF (FILCNT .GT. LIMIT) GO TO 990        
      CALL XFLSZD (-1,BLKCNT(FILCNT),NGINO)        
      CALL READ (*930,*930,NGINO,HEAD,2,0,RECSZ)        
      DO 440 J = I,LDC,3        
      IF (HEAD(1).EQ.FDICT(J) .AND. HEAD(2).EQ.FDICT(J+1) .AND.        
     1    FDICT(J+2).EQ.FDICT(I+2)) GO TO 445        
  440 CONTINUE        
      GO TO 930        
  445 CALL WRITE (NPTP,HEAD,2,0)        
      IF (ICFIAT .EQ. 11) GO TO 447        
      CALL WRITE (NPTP,FIAT(K+3),3,1)        
      GO TO 448        
  447 CALL WRITE (NPTP,FIAT(K+3),3,0)        
      CALL WRITE (NPTP,FIAT(K+8),3,1)        
C        
C     COPY ENTIRE FILE ONTO NEW PROBLEM NPTP TAPE USING CPYFIL        
C        
  448 CALL WRITE  (NPTP,HEAD,2,0)        
      CALL CPYFIL (NGINO,NPTP,IOBUF(IOPNT),LIOBUF,RECSZ)        
      CALL CLOSE  (NGINO,1)        
      GO TO 600        
C        
C     FILE IS ON POOL -- POSITION POOL AND COPY FILE USING CPYFIL       
C        
  450 NGINO = DPT        
      K = ANDF(DICT(I+2),MASKHI)        
      CALL SKPFIL (DPT,K-DPFCT)        
      DPFCT  = K + 1        
      FILCNT = FILCNT + 1        
      IF (FILCNT .GT. LIMIT) GO TO 990        
      CALL XFLSZD (K,BLKCNT(FILCNT),0)        
      CALL CPYFIL (DPT,NPTP,IOBUF(IOPNT),LIOBUF,RECSZ)        
C        
C     GET NEXT FDICT ENTRY        
C        
  600 CALL EOF (NPTP)        
      N = N + 1        
      IF (N .LE. N1) GO TO 405        
C        
C     RESTORE FIST ENTRY        
C        
      FIST(IFSTMP  ) = SVFST(1)        
      FIST(IFSTMP+1) = SVFST(2)        
C        
C     WRITE VPS TABLE ONTO NEW PROBLEM NPTP TAPE        
C     MAKE ENTRY IN FDICT FOR VPS TABLE        
C        
  615 LDC = LDC + 3        
      FDICT(LDC  ) = NVPS(1)        
      FDICT(LDC+1) = NBLANK        
      FDICT(LDC+2) = NPTFN        
      EORFLG = SETEOR        
      I = LDC        
      CALL WRITE (NPTP,NVPS,5,1)        
      CALL WRITE (NPTP,VPS,VPS(2),1)        
C        
C     WRITE CEITBL TABLE ONTO PROBLEM TAPE        
C        
      CALL WRITE (NPTP,CEITBL,CEITBL(2),1)        
C        
C     WRITE /SYSTEM/ ONTO PROBLEM TAPE        
C        
      CALL WRITE (NPTP,BUFSZ,20,1)        
      CALL EOF   (NPTP)        
      CALL CLOSE (NPTP,2)        
C        
C     POSITION DATA POOL TAPE AT CORRECT OSCAR ENTRY FOR RETURN TO XSEM 
C        
      IF (DPFCT .EQ. OSCFN) GO TO 675        
      CALL REWIND (DPT)        
      IF (OSCFN .GT. 1) CALL SKPFIL (DPT,OSCFN-1)        
      J1 = OSCAR(2)        
      DO 670 J = 1,J1        
      CALL FWDREC (*910,DPT)        
  670 CONTINUE        
  675 CALL CLOSE (DPT,2)        
C        
C     UPDATE PTDIC AND ASSOCIATED VARIABLES        
C        
      NRLFL  = NPTFN + 1        
      PTDBOT = LCPTP        
      DO 690 I = 1,LDC,3        
      DO 680 J = PTDTOP,PTDBOT,3        
C        
C     SCAN PTDIC TO SEE IF FILE IS ALREADY THERE        
C        
      IF (FDICT(I).EQ.PTDIC(J) .AND. FDICT(I+1).EQ.PTDIC(J+1) .AND.     
     1    FDICT(I+2).EQ.PTDIC(J+2)) GO TO 690        
  680 CONTINUE        
C        
C     ENTER FILE IN PTDIC        
C        
      PTDBOT = PTDBOT + 3        
      PTDIC(PTDBOT  ) = FDICT(I  )        
      PTDIC(PTDBOT+1) = FDICT(I+1)        
      PTDIC(PTDBOT+2) = FDICT(I+2)        
  690 CONTINUE        
C        
C     PUT PURGED FILES IN PTDIC        
C        
      IF (PRGPNT .LT. 1) GO TO 800        
      DO 710 I = 1,PRGPNT,2        
      DO 700 J = PTDTOP,PTDBOT,3        
      IF (PURGE(I).EQ.PTDIC(J) .AND. PURGE(I+1).EQ.PTDIC(J+1) .AND.     
     1    PTDIC(J+2).EQ.0) GO TO 710        
  700 CONTINUE        
      PTDBOT = PTDBOT + 3        
      PTDIC(PTDBOT  ) = PURGE(I)        
      PTDIC(PTDBOT+1) = PURGE(I+1)        
      PTDIC(PTDBOT+2) = 0        
  710 CONTINUE        
C        
C     CHECK FOR PTDIC OVERFLOW        
C        
  800 IF (PTDBOT+3-PTDTOP .GT. LPTDIC) GO TO 940        
C        
C        
C     PUNCH AND PRINT LATEST ENTRIES IN PTDIC        
C     INITIALIZE PAGE HEADING AND CHECK PAGE COUNT        
C        
      IF (DIAG09 .EQ. 1) GO TO 802        
      DO 801 I = 1,32        
      PGHDG(I+ 96) = HDG(I)        
      PGHDG(I+128) = NBLANK        
  801 PGHDG(I+160) = NBLANK        
      IF (CPPGCT .NE. NPAGES) CALL PAGE        
  802 CONTINUE        
      I1 = ((LCPTP  - PTDTOP)/3) + 1        
      I2 = ((PTDBOT - PTDTOP)/3) + 1        
      DO 810 I = I1,I2        
      J1 = (I-1)*3 + PTDTOP        
      J2 = J1 + 2        
C        
C     SEPARATE FLAGS, REEL NO., FILE NO.        
C        
      NFLAGS = 0        
      IF (PTDIC(J2) .LT. 0) NFLAGS = 4        
      NFLAGS = ORF(NFLAGS,RSHIFT(ANDF(PTDIC(J2),NOSGN),29))        
      NREEL  = RSHIFT(ANDF(PTDIC(J2),NOFLGS),16)        
      NFILE  = ANDF(PTDIC(J2),MASKHI)        
      SEQNO  = 1 + SEQNO        
      IF (PTDIC(J1) .EQ. NBLANK) GO TO 805        
      WRITE  (LDICT,820) SEQNO,PTDIC(J1),PTDIC(J1+1),NFLAGS,NREEL,NFILE 
  820 FORMAT (I10,4H,   ,2A4,12H,   FLAGS = ,I1,11H,   REEL = ,I2,      
     1        11H,   FILE = ,I6)        
      IF (DIAG09 .EQ. 1) GO TO 810        
      NLINES = NLINES + 1        
      IF (MACH.LT.5 .AND. NFILE.NE.0 .AND. PTDIC(J1).NE.NVPS(1))        
     1    NLINES = NLINES + 1        
      IF (NLINES .GE. NLPP) CALL PAGE        
      WRITE  (OTPE,821) SEQNO,PTDIC(J1),PTDIC(J1+1),NFLAGS,NREEL,NFILE  
  821 FORMAT (1H ,I9 ,4H,   ,2A4,12H,   FLAGS = ,I1,11H,   REEL = ,I2,  
     1        11H,   FILE = ,I6)        
      IF (MACH.LT.5 .AND. NFILE.NE.0 .AND. PTDIC(J1).NE.NVPS(1))        
     1    WRITE (OTPE,822) PTDIC(J1),PTDIC(J1+1),BLKCNT(I-I1),BLKSIZ    
  822 FORMAT (13X,6H FILE ,2A4, 9H CONTAINS, I10,        
     1        28H BLOCKS, EACH BLOCK CONTAINS,I5,7H WORDS.)        
      GO TO 810        
  805 WRITE  (LDICT,806) SEQNO,NREEL        
  806 FORMAT (I10,36H,   REENTER AT DMAP SEQUENCE NUMBER ,I5)        
      IF (DIAG09 .EQ. 1) GO TO 810        
      NLINES = NLINES + 2        
      IF (NLINES .GE. NLPP) CALL PAGE        
      WRITE  (OTPE,807) SEQNO,NREEL        
  807 FORMAT (1H ,/1H ,I9,36H,   REENTER AT DMAP SEQUENCE NUMBER ,I5)   
  810 CONTINUE        
C        
C     WRITE PTDIC ONTO XPTD        
C        
      NGINO = NXPTDC(1)        
      CALL OPEN  (*905,NXPTDC,GBUF(NPTPNT),1)        
      CALL WRITE (NXPTDC,NXPTDC,2,1)        
      CALL WRITE (NXPTDC,DCPARM,2,1)        
      CALL WRITE (NXPTDC,PTDIC(PTDTOP),PTDBOT+3-PTDTOP,1)        
      CALL CLOSE (NXPTDC,1)        
      CPPGCT = NPAGES        
C        
      RETURN        
C        
C        
C     ERRORS -        
C        
  900 N = 1101        
      ASSIGN 901 TO RETURN        
      GO TO 980        
  901 WRITE  (OTPE,902) FDICT(I),FDICT(I+1)        
  902 FORMAT (4X,26HCOULD NOT OPEN FILE NAMED ,2A4)        
      GO TO 995        
C        
  905 N = 1102        
      ASSIGN 906 TO RETURN        
      GO TO 985        
  906 WRITE (OTPE,902) NGINO,NBLANK        
      GO TO 995        
C        
  910 N = 1103        
      ASSIGN 911 TO RETURN        
      GO TO 985        
  911 WRITE  (OTPE,912)        
  912 FORMAT (4X,43HUNABLE TO POSITION DATA POOL TAPE CORRECTLY )       
      GO TO 995        
C        
  920 N = 1104        
      ASSIGN 921 TO RETURN        
      GO TO 985        
  921 WRITE  (OTPE,922)        
  922 FORMAT (4X,24HFDICT TABLE IS INCORRECT )        
      GO TO 995        
C        
  930 N = 1105        
      ASSIGN 931 TO RETURN        
      GO TO 980        
  931 WRITE  (OTPE,932) FDICT(I),FDICT(I+1),HEAD(1),HEAD(2)        
  932 FORMAT (4X,29HCANNOT FIND DATA BLOCK NAMED ,2A4,17H HEADER RECORD 
     1= ,2A4)        
      GO TO 995        
C        
  940 N = 1106        
      ASSIGN 941 TO RETURN        
      GO TO 985        
  941 WRITE  (OTPE,942)        
  942 FORMAT (4X,32HCHECKPOINT DICTIONARY OVERFLOWED)        
      GO TO 995        
C        
  960 N = 1108        
      ASSIGN 961 TO RETURN        
      GO TO 985        
  962 FORMAT (4X,22HPURGE TABLE OVERFLOWED)        
  961 WRITE  (OTPE,962)        
      GO TO 995        
C        
  970 N = 1109        
      ASSIGN 971 TO RETURN        
      GO TO 985        
  971 WRITE (OTPE,932) NXPTDC,DCPARM        
      GO TO 995        
C        
C     USER FATAL ERROR        
C        
  980 WRITE  (OTPE,981) UFM,N        
  981 FORMAT (A23,I5)        
      GO TO 987        
C        
C     SYSTEM FATAL ERROR        
C        
  985 CALL PAGE2 (3)        
      WRITE  (OTPE,986) SFM,N        
  986 FORMAT (A25,I5)        
  987 GO TO RETURN, (901,906,911,921,931,941,961,971)        
C        
  990 WRITE  (OTPE,991) SFM        
  991 FORMAT (A25,', BLKCNT ARRAY EXCEEDED IN XCHK')        
C        
  995 CALL MESAGE (-37,0,NXCHK)        
      RETURN        
      END        
