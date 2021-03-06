      SUBROUTINE SUREAD (IA,ND,NOUT,ITEST)        
C        
C     READS DATA FROM THE SOF INTO THE ARRAY IA.  ND IS AN INPUT        
C     PARAMETER INDICATING THE NUMBER OF WORDS DESIRED.  ND=-1 MEANS    
C     READ UNTIL END OF GROUP. NOUT IS AN OUTPUT PARAMETER INDICATING   
C     THE NUMBER OF WORD THAT HAVE BEEN READ.  ITEST IS AN OUTPUT       
C     PARAMETER WHERE ITEST=3 MEANS END OF ITEM ENCOUNTERED, ITEST=2    
C     MEANS END OF GROUP ENCOUNTERED, AND ITEST=1 OTHERWISE.        
C        
      EXTERNAL        ANDF,RSHIFT        
      INTEGER         ANDF,RSHIFT,BUF,BLKSIZ,DIRSIZ,IA(1),NMSBR(2)      
      COMMON /MACHIN/ MACH,IHALF,JHALF        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DITDUM(6),IO,IOPBN,IOLBN,IOMODE,IOPTR,IOSIND,     
     1                IOITCD,IOBLK        
      COMMON /SYS   / BLKSIZ,DIRSIZ        
      DATA    IDLE  , IRD / 0,1    /        
      DATA    IEOG  , IEOI/ 4H$EOG ,4H$EOI       /        
      DATA    INDSBR/ 19  /, NMSBR /4HSURE,4HAD  /        
C        
      CALL CHKOPN (NMSBR(1))        
      ICOUNT = 0        
      IF (IOMODE .EQ. IRD) GO TO 20        
      ITEST = 4        
      NOUT  = 0        
      RETURN        
C        
   10 ICOUNT = ICOUNT + 1        
      IA(ICOUNT) = BUF(IOPTR)        
      IOPTR = IOPTR + 1        
      IF (ICOUNT .EQ. ND) GO TO 35        
   20 IF (IOPTR .GT. BLKSIZ+IO) GO TO 80        
C        
C     READ SOF INTO ARRAY IA, BUT WATCH FOR END OF GROUP AND END OF ITEM
C        
   30 IF (BUF(IOPTR) .EQ. IEOI) GO TO 50        
      IF (BUF(IOPTR).EQ.IEOG .AND. ND.NE.-2) GO TO 40        
      GO TO 10        
C        
C     READ THE REQUIRED NUMBER OF WORDS.        
C        
   35 ITEST = 1        
      GO TO 70        
C        
C    REACHED END OF GROUP.        
C        
   40 ITEST = 2        
      GO TO 60        
C        
C    REACHED END OF ITEM.        
C        
   50 ITEST  = 3        
      IOMODE = IDLE        
   60 IOPTR  = IOPTR + 1        
   70 NOUT   = ICOUNT        
      RETURN        
C        
C     REACHED END OF BLOCK.  REPLACE THE BLOCK CURRENTLY IN CORE BY ITS 
C     LINK BLOCK.        
C        
   80 CALL FNXT (IOPBN,INXT)        
      IF (MOD(IOPBN,2) .EQ. 1) GO TO 90        
      NEXT = ANDF(RSHIFT(BUF(INXT),IHALF),JHALF)        
      GO TO 100        
   90 NEXT = ANDF(BUF(INXT),JHALF)        
  100 IF (NEXT .EQ. 0) GO TO 510        
      IOPBN = NEXT        
      IOLBN = IOLBN + 1        
      CALL SOFIO (IRD,IOPBN,BUF(IO-2))        
      IOPTR = IO + 1        
      GO TO 30        
C        
C     ERROR MESSAGES.        
C        
  510 CALL ERRMKN (INDSBR,9)        
      RETURN        
      END        
