      SUBROUTINE CFEER3        
C        
C     CFEER3 IS A DRIVER ROUTINE WHICH PERFORMS THE TRIDIAGONAL        
C     REDUCTION FOR THE COMPLEX FEER METHOD        
C        
      INTEGER           SWITCH   ,CDP      ,SQR      ,SYSBUF     ,      
     1                  NAME(2)        
      DOUBLE PRECISION  LAMBDA   ,DZ(1)        
      COMMON  /NAMES /  RD       ,RDREW    ,WRT      ,WRTREW     ,      
     1                  REW      ,NOREW    ,EOFNRW   ,RSP        ,      
     2                  RDP      ,CSP      ,CDP      ,SQR        
      COMMON  /SYSTEM/  KSYSTM(65)        
CZZ   COMMON  /ZZCFR3/  Z(1)        
      COMMON  /ZZZZZZ/  Z(1)        
      COMMON  /FEERXC/  LAMBDA(2),SWITCH   ,MREDUC   ,NORD       ,      
     1                  IDIAG    ,EPSDUM(2),NORTHO   ,NORD2      ,      
     2                  NORD4    ,NORDP1   ,XCDUM(12),MINOPN        
      COMMON  /FEERAA/  IK(7)    ,IM(7)    ,IB(7)    ,ILAM(7)    ,      
     1                  IPHI(7)  ,DUDXX    ,ISCR(11) ,DUMAA(84)  ,      
     2                  MCBVEC(7)        
      EQUIVALENCE       (DZ(1)   ,Z(1)   ) ,(KSYSTM(55),IPREC)   ,      
     1                  (KSYSTM(1),SYSBUF) ,(KSYSTM( 2),NOUT )        
      DATA     NAME  /  4HCFEE,4HR3  /        
C        
C     SCRATCH FILE AND BUFFER ALLOCATION        
C        
C     FILE  5  CONTAINS THE ELEMENTS OF REDUCED TRIDIAGONAL MATRIX      
C     FILE  7  CONTAINS THE ORTHOGONAL VECTOR PAIRS (NUMBER OF        
C              VECTOR PAIRS = NORTHO)        
C        
C     BUFFER Z(IBUF1) IS LOCAL SCRATCH BUFFER        
C     BUFFER Z(IBUF2) IS LOCAL SCRATCH BUFFER        
C     BUFFER Z(IBUF3) IS USED BY FILE 5        
C        
C        
C     COMPUTE STORAGE ALLOCATIONS        
C        
      NZ    = KORSZ(Z)        
      IBUF1 = NZ    - SYSBUF        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      ITOP  = IBUF3        
C        
C     COMPUTE LOCATIONS OF RIGHT-HANDED VECTORS        
C        
      IV1 = 1        
      IV2 = IV1 + NORD4        
      IV3 = IV2 + NORD4        
      IV4 = IV3 + NORD4        
      IV5 = IV4 + NORD4        
C        
C     TEST FOR INSUFFICIENT CORE        
C        
      IEND = IPREC*(5*NORD4+1)        
      IF (IEND .GT. ITOP) GO TO 70        
C        
C     COMPUTE LOCATIONS OF LEFT-HANDED VECTORS        
C        
      IV1L = IV1 + NORD2        
      IV2L = IV2 + NORD2        
      IV3L = IV3 + NORD2        
      IV4L = IV4 + NORD2        
      IV5L = IV5 + NORD2        
      IOPN = ITOP- IEND        
      IF (IDIAG .NE. 0) WRITE (NOUT,510) IOPN        
      IF (IOPN .LT. MINOPN) MINOPN = IOPN        
C        
C     INITIALIZE SCRATCH FILE TO CONTAIN TRIDIAGONAL ELEMENTS        
C        
      CALL GOPEN (ISCR(5),Z(IBUF3),WRTREW)        
C        
C     GENERATE MATRIX CONTROL BLOCK FOR SCRATCH FILE TO CONTAIN        
C     ORTHOGONAL VECTORS (LEFT VECTOR PACKED IMMEDIATELY AFTER        
C     RIGHT, I. E., EACH COLUMN CONTAINS RIGHT VECTOR FOLLOWED BY       
C     LEFT VECTOR)        
C        
      JPREC = IPREC + 2        
      CALL MAKMCB (MCBVEC(1),ISCR(7),NORD2,2,JPREC)        
C        
C     PERFORM DOUBLE PRECISION FEER        
C        
      IF (IPREC.EQ.2) CALL CFER3D (DZ(IV1),DZ(IV1L), DZ(IV2),DZ(IV2L),  
     1                             DZ(IV3),DZ(IV3L), DZ(IV4),DZ(IV4L),  
     2                             DZ(IV5),DZ(IV5L), Z(IBUF1),Z(IBUF2)) 
C        
C     PERFORM SINGLE PRECISION FEER        
C        
      IF (IPREC.NE.2) CALL CFER3S (Z(IV1),Z(IV1L), Z(IV2),Z(IV2L),      
     1                             Z(IV3),Z(IV3L), Z(IV4),Z(IV4L),      
     2                             Z(IV5),Z(IV5L), Z(IBUF1),Z(IBUF2))   
C        
C     TERMINATE SCRATCH FILE CONTAINING TRIDIAGONAL ELEMENTS        
C        
      CALL CLOSE (ISCR(5),NOREW)        
      RETURN        
C        
   70 IEND = (IEND-ITOP)/1000 + 1        
      WRITE  (NOUT,80) IEND        
   80 FORMAT (5H0NEED,I4,17HK MORE CORE WORDS)        
      CALL MESAGE (-8,0,NAME)        
  510 FORMAT (1H ,I10,36H SINGLE PRECISION WORDS OF OPEN CORE,        
     1       29H NOT USED (SUBROUTINE CFEER3))        
      END        
