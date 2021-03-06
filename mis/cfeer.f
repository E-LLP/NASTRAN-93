      SUBROUTINE CFEER (EED,METHOD,NFOUND)        
C        
C     PREVIOUS THIS ROUITNE IS CALLED CFCNTL        
C        
C     GIVEN REAL OR COMPLEX MATRICES, CFEER WILL SOLVE FOR THE        
C     REQUESTED NUMBER OF EIGENVALUES AND EIGENVECTORS CLOSEST TO A     
C     SPECIFIED POINT IN THE COMPLEX PLANE, FOR UP TO TEN POINTS,       
C     VIA THE TRIDIAGONAL REDUCTION (FEER) METHOD.        
C     THE SUBROUTINE NAME  CFEER  STANDS FOR COMPLEX FEER CONTROL.      
C        
C     DEFINITION OF INPUT AND OUTPUT PARAMETERS        
C        
C     IK(7)    = MATRIX CONTROL BLOCK FOR THE INPUT STIFFNESS MATRIX K  
C     IM(7)    = MATRIX CONTROL BLOCK FOR THE INPUT MASS      MATRIX M  
C     IB(7)    = MATRIX CONTROL BLOCK FOR THE INPUT DAMPING   MATRIX B  
C     ILAM(7)  = MATRIX CONTROL BLOCK FOR THE OUTPUT EIGENVALUES        
C     IPHI(7)  = MATRIX CONTROL BLOCK FOR THE OUTPUT EIGENVECTORS       
C     IDMPFL   = FILE CONTAINING THE EIGENVALUE SUMMARY        
C     ISCR(11) = SCRATCH FILES USED INTERNALLY        
C     REG(1,I) = INPUT REAL      PART OF CENTER I (LAMBDA)        
C     REG(2,I) = INPUT IMAGINARY PART OF CENTER I (LAMBDA)        
C     REG(5,I) = PROBLEM SIZE MAXIMUM FOR SETTING QPR        
C     REG(6,I) = SUPPRESSES ANY SPECIAL SYMMETRY LOGIC        
C     REG(7,I) = NUMBER OF DESIRED ROOTS AROUND CENTER I        
C     REG(8,1) = CONVERGENCE CRITERION (EQUIV. TO REG(1,2) TEMPORARILY) 
C        
      LOGICAL           NO B     ,SYMMET   ,QPR        
      INTEGER           METHOD   ,EED      ,NAME(2)  ,IZ(1)     ,       
     1                  EIGC(2)  ,WANT(10) ,HAVE(10)        
      DOUBLE PRECISION  LAMBDA   ,EPS        
      DIMENSION         IREG(7,1),IHEAD(10)        
      CHARACTER         UFM*23   ,UWM*25   ,UIM*29        
      COMMON  /XMSSG /  UFM      ,UWM      ,UIM        
      COMMON  /FEERAA/  IK(7)    ,IM(7)    ,IB(7)    ,ILAM(7)   ,       
     1                  IPHI(7)  ,IDMPFL   ,ISCR(11) ,REG(7,10) ,       
     2                  MCBLT(7) ,MCBUT(7) ,MCBVEC(7),MCBLMB(7)        
      COMMON  /FEERXC/  LAMBDA(2),SYMMET   ,MREDUC   ,NORD      ,       
     1                  IDIAG    ,EPS      ,NORTHO   ,NORD2     ,       
     2                  NORD4    ,NORDP1   ,NSWP     ,JSKIP     ,       
     3                  NO B     ,IT       ,TEN2MT   ,TENMHT    ,       
     4                  NSTART   ,QPR      ,JREG     ,NOREG     ,       
     5                  NZERO    ,TENMTT   ,MINOPN   ,NUMORT    ,       
     6                  NUMRAN        
CZZ   COMMON  /ZZCFCN/  Z(1)        
      COMMON  /ZZZZZZ/  Z(1)        
      COMMON  /NAMES /  RD       ,RDREW    ,WRT      ,WRTREW    ,       
     1                  REW      ,NOREW    ,EOFNRW   ,RSP       ,       
     2                  RDP        
      COMMON  /SYSTEM/  KSYSTM(65)        
      COMMON  /OUTPUT/  HEAD(1)        
      EQUIVALENCE       (IREG(1,1),REG(1,1)),(ANODES,NODES)     ,       
     1                  (KSYSTM(2),NOUT)    ,(KSYSTM(40),NBPW)  ,       
     2                  (ASYM,NONSYM)       ,(Z(1),IZ(1))        
      DATA    EIGC   /  207,2/        
      DATA    IHEAD  /  0,1009,2,7*0/        
      DATA    NAME   /  4HCFCN,4HTL  /        
C        
C     FILE ALLOCATION        
C        
C     ISCR( 1)  CONTAINS  (LAMBDA**2*M + LAMBDA*B + K) = DYNAMIC MATRIX 
C     ISCR( 2)  CONTAINS -(LAMBDA*M + B) = NOT REQUIRED WHEN B = 0      
C     ISCR( 3)  CONTAINS LOWER TRIANGLE OF DECOMPOSED DYNAMIC MATRIX    
C     ISCR( 4)  CONTAINS UPPER TRIANGLE OF DECOMPOSED DYNAMIC MATRIX    
C     ISCR( 5)  CONTAINS REDUCED TRIDIAGONAL MATRIX ELEMENTS        
C     ISCR( 6)  CONTAINS SPECIAL UPPER TRIANGLE FOR TRANSPOSED SWEEP    
C     ISCR( 7)  CONTAINS THE ORTHOGONAL VECTORS        
C     ISCR( 8)  CONTAINS OUTPUT EIGENVALUES , FOR INPUT TO CEAD1A       
C     ISCR( 9)  CONTAINS OUTPUT EIGENVECTORS, FOR INPUT TO CEAD1A       
C     ISCR(10)  SCRATCH FILE USED IN CFEER4        
C     ISCR(11)  NOT USED        
C        
C     DEFINITION OF INTERNAL PARAMETERS        
C        
C     NODES  = NUMBER OF DESIRED ROOTS IN CURRENT NEIGHBORHOOD        
C     EPS    = ACCURACY CRITERION - USED FOR REJECTING EIGENSOLUTIONS   
C     NOREG  = TOTAL NUMBER OF CENTERS (NEIGHBORHOODS) INPUT,        
C              EQUIVALENT TO THE NUMBER OF EIGC CONTINUATION CARDS      
C     JREG   = COUNTER FOR CURRENT NEIGHBORHOOD        
C     MREDUC = SIZE OF THE REDUCED PROBLEM IN CURRENT NEIGHBORHOOD      
C     NFOUND = ACCUMULATED NUMBER OF ACCEPTABLE EIGENSOLUTIONS        
C     NORD   = 2*N IF B.NE.0 AND = N IF B.EQ.0, WHERE B IS THE        
C              DAMPING MATRIX AND N IS THE PROBLEM SIZE        
C     NORD2  = VECTOR SIZE OF ORIGINAL PROBLEM (COMPLEX SINGLE        
C              PRECISION OR COMPLEX DOUBLE PRECISION)        
C     NSWP   = COMPLEX VECTOR SIZE FOR SWEEP ALGORITHM        
C     NO B   = LOGICAL INDICATOR FOR ABSENCE OF DAMPING MATRIX B        
C     SYMMET = LOGICAL INDICATOR FOR SYMMETRIC DYNAMIC MATRIX        
C     NONSYM = PROGRAM INPUT WHICH FORCES THE PROGRAM TO CONSIDER       
C              THE DYNAMIC MATRIX AS NON-SYMMETRIC        
C     IT     = NUMBER OF DECIMAL DIGITS OF ACCURACY FOR THE COMPUTER    
C     TEN2MT = 10**(2-T) CONVERGENCE CRITERION        
C     TENMHT = 10**(-HALF*T) CONVERGENCE CRITERION        
C     TENMTT = 10**(-THIRD*T) RIGID BODY ROOT CRITERION        
C     NORTHO = TOTAL CURRENT NUMBER OF ORTHOGONAL VECTOR PAIRS ON       
C              ORTHOGONAL VECTOR FILE. INITIALIZED TO NUMBER OF        
C              EIGENVECTOR PAIRS ON THE RESTART FILE.        
C     MINOPN = MINIMUM OPEN CORE NOT USED (WORDS)        
C     NSTART = NUMBER OF INITIAL REORTHOGONALIZATION ATTEMPTS        
C     IDIAG  = DIAG 12 PRINT CONTROL        
C     QPR    = LOGICAL INDICATOR FOR VERY DETAILED PRINTOUT        
C     WANT   = ARRAY OF DESIRED NUMBER OF ROOTS IN EACH NEIGHBORHOOD    
C     HAVE   = ARRAY OF ACTUAL  NUMBER OF ROOTS IN EACH NEIGHBORHOOD    
C        
      NORTHO = 0        
      NFOUND = NORTHO        
      NZERO  = NORTHO        
      JSKIP  = 0        
      CALL SSWTCH (12,IDIAG)        
C        
C     TEST COMPUTING MACHINE TYPE AND SET PRECISION PARAMETERS        
C        
      IF (NBPW .GE. 60) GO TO 20        
      IT = 8*KSYSTM(55)        
      GO TO 21        
   20 IT = 14*KSYSTM(55)        
   21 TEN2MT = 10.**(2-IT)        
      TENMHT = 10.**(-IT/2)        
      TENMTT = 10.**(-IT/3)        
      IK(1)  = 101        
      CALL RDTRL (IK)        
      IM(1)  = 103        
      CALL RDTRL (IM)        
      IB(1)  = 102        
      CALL RDTRL (IB)        
      IF (IB(1).LT.0 .OR. IB(6).EQ.0) IB(1) = 0        
C        
C     DETERMINE IF THE DYNAMIC MATRIX IS SYMMETRIC        
C        
      SYMMET = .FALSE.        
      IF (IK(1).NE.0 .AND. IK(4).NE.6) GO TO 30        
      IF (IM(1).NE.0 .AND. IM(4).NE.6) GO TO 30        
      IF (IB(1).NE.0 .AND. IB(4).NE.6) GO TO 30        
      SYMMET = .TRUE.        
   30 DO 40 I = 1,11        
   40 ISCR(I)= 300+I        
      IDMPFL = 203        
      NZ     = KORSZ(Z)        
      IBUF   = NZ - KSYSTM(1) - 2        
      LIMSUM = 12        
      IOPN   = IBUF - LIMSUM        
      IF (IDIAG .NE. 0) WRITE (NOUT,600) IOPN        
      IF (IOPN  .LE. 0) CALL MESAGE (-8,0,NAME)        
      MINOPN = IOPN        
      ILAM(1)= 308        
      IPHI(1)= 309        
      IFILE  = ILAM(1)        
      CALL OPEN (*500,ILAM,Z(IBUF),WRTREW)        
      CALL CLOSE (ILAM,REW)        
      IFILE  = IPHI(1)        
      CALL OPEN (*500,IPHI,Z(IBUF),WRTREW)        
      CALL CLOSE (IPHI,REW)        
      CALL GOPEN (IDMPFL,Z(IBUF),WRTREW)        
      CALL CLOSE (IDMPFL,EOFNRW)        
C        
C     PROCURE DATA FROM MAIN EIGC CARD        
C        
      IFILE = EED        
      CALL PRELOC (*500,Z(IBUF),EED)        
      CALL LOCATE (*500,Z(IBUF),EIGC(1),FLAG)        
   50 CALL FREAD (EED,IREG,10,0)        
      IF (IREG(1,1) .EQ. METHOD) GO TO 70        
   60 CALL FREAD (EED,IREG,7,0)        
      IF (IREG(6,1) .NE. -1) GO TO 60        
      GO TO 50        
   70 JREG  = 1        
      EPS   =.1D0/IK(2)/100.D0        
      IF (REG(1,2) .GT. 0.) EPS = DBLE(REG(1,2))/100.D0        
      UNIDUM= SNGL(EPS)*100.        
      IF (IDIAG .NE. 0) WRITE (NOUT,75) UNIDUM,REG(1,2)        
   75 FORMAT (1H0,5HCFEER,6X,18HACCURACY CRITERION,1P,E16.8,        
     2        8X,12H(INPUT VALUE,E16.8,1H))        
C        
C     PROCURE DATA FROM EIGC CONTINUATION CARDS        
C        
   80 CALL FREAD (EED,IREG(1,JREG),7,0)        
      IF (IREG(6,JREG) .EQ. -1) GO TO 90        
      JREG  = JREG + 1        
      IF (JREG .GT. 10) GO TO 90        
      GO TO 80        
   90 CALL CLOSE (EED,REW)        
      NOREG  = JREG - 1        
      NODCMP = 0        
      NUMORT = 0        
      NUMRAN = 0        
      JREG   = 0        
C        
C     PICK UP PARAMETERS FOR NEIGHBORHOOD I        
C        
  100 JREG = JREG + 1        
      IF (JREG .LE. NOREG) GO TO 105        
      JREG = NOREG        
      IF (NZERO .GT. 0) JSKIP = -1        
      GO TO 175        
  105 X1 = REG(1,JREG)        
      Y1 = REG(2,JREG)        
      ANODES = REG(7,JREG)        
      ASYM   = REG(6,JREG)        
      IF (NONSYM .NE. 0) SYMMET = .FALSE.        
      NPRINT = IFIX(REG(5,JREG))        
      QPR = .FALSE.        
      IF (IDIAG.NE.0 .AND. NPRINT.GE.IK(2)) QPR = .TRUE.        
      IF (IDIAG .NE. 0) WRITE (NOUT,110) JREG,X1,Y1,NODES,NONSYM        
  110 FORMAT (1H0,5HCFEER,6X,12HNEIGHBORHOOD,I3,8X,8HCENTER =,2F18.8,   
     1        8X,15HNO. DES. RTS. =,I5,8X,8HNONSYM =,I2/1H )        
C        
C     TEST IF USER PICKED THE ORIGIN        
C        
      IF (X1.NE.0. .OR. Y1.NE.0.) GO TO 120        
      X1 = X1 + .001        
      WRITE (NOUT,601) UWM        
  120 IF (NODES .GT. 0) GO TO 130        
      WRITE (NOUT,602) UWM,NODES        
      NODES = 1        
  130 WANT(JREG) = NODES        
      HAVE(JREG) = 0        
      NORD  = 2*IK(2)        
      NO B  = .FALSE.        
      IF (IB(1) .GT. 0) GO TO 140        
      NO B  = .TRUE.        
      NORD  = IK(2)        
  140 NSWP  = IK(2)        
      NORD2 = 2*NORD        
      NORD4 = 2*NORD2        
      NORDP1= NORD + 1        
      MREDUC= 2*NODES + 10        
      NOMNF = NORD - NFOUND        
      IF (MREDUC .GT. NOMNF) MREDUC = NOMNF        
      LAMBDA(1) = X1        
      LAMBDA(2) = Y1        
      IF (NODES .GT. NORD) WRITE (NOUT,606) UWM,NODES,JREG,NOREG,LAMBDA,
     1                                      NORD        
      ISING = 0        
C        
C      FORM (LAMBDA**2*M + LAMBDA*B + K) = THE DYNAMIC MATRIX        
C        
  150 CALL CFEER1        
C        
C     CALL IN CDCOMP TO DECOMPOSE THE DYNAMIC MATRIX        
C        
      NODCMP = NODCMP + 1        
      CALL CFEER2 (IRET)        
      IF (IRET .NE. 0) GO TO 160        
      GO TO 170        
  160 IRET = IRET + ISING        
      WRITE (NOUT,603) UWM,IRET,LAMBDA        
      IF (ISING .EQ. 1) GO TO 100        
C        
C     SINGULAR MATRIX. INCREMENT LAMBDA AND TRY ONCE MORE.        
C        
      ISING = 1        
      LAMBDA(1) = LAMBDA(1) + .02D0        
      LAMBDA(2) = LAMBDA(2) + .02D0        
      GO TO 150        
C        
C     CALL IN DRIVER TO GENERATE REDUCED TRIDIAGONAL MATRIX        
C        
  170 CALL CFEER3        
      IF (NSTART .GT. 2) GO TO 100        
C        
C     OBTAIN EIGENVALUES AND EIGENVECTORS        
C        
      CALL CFEER4        
      HAVE(JREG) = MREDUC        
      IF (MREDUC .LE. NODES) GO TO 180        
      I = MREDUC - NODES        
      WRITE (NOUT,607) UIM,I,NODES,JREG,NOREG,LAMBDA        
  180 NFOUND = NFOUND + MREDUC        
      IF (JREG.LT.NOREG .AND. NFOUND.LT.NORD) GO TO 100        
C        
C     FEER IS FINISHED. PERFORM WRAP-UP OPERATIONS.        
C        
  175 IF (JSKIP  .LT. 0) CALL CFEER4        
      IF (NFOUND .EQ. 0) GO TO 250        
      IF (NFOUND .GE. NORD) GO TO 220        
  200 DO 210 I = 1,JREG        
      IF (HAVE(I) .LT. WANT(I)) GO TO 240        
  210 CONTINUE        
      GO TO 230        
C        
C     ALL SOLUTIONS FOUND        
C        
  220 WRITE (NOUT,604) UIM        
      IF (JREG .LT. NOREG) GO TO 240        
      GO TO 200        
C        
C     EACH REQUESTED NEIGHBORHOOD HAS THE DESIRED NUMBER OF ROOTS       
C        
  230 ITERM = 0        
      GO TO 260        
C        
C     AT LEAST ONE REQUESTED NEIGHBORHOOD FAILS TO HAVE THE DESIRED     
C     NUMBER OF ROOTS        
C        
  240 ITERM = 1        
      GO TO 260        
C        
C     ABNORMAL TERMINATION. NO ROOTS FOUND.        
C        
  250 ITERM = 2        
C        
C     WRITE INFORMATION ON NASTRAN SUMMARY FILE        
C        
  260 IFILE = IDMPFL        
      CALL OPEN (*500,IDMPFL,Z(IBUF),WRT)        
      DO 270 I = 1,LIMSUM        
  270 IZ(I) = 0        
      I = 0        
      IZ(I+2) = NORTHO        
      IZ(I+3) = NUMRAN        
      IZ(I+5) = NODCMP        
      IZ(I+6) = NUMORT        
      IZ(I+7) = ITERM        
      IZ(I+8) = 1        
      I = 2        
      CALL WRITE (IDMPFL,IHEAD(1),10,0)        
      CALL WRITE (IDMPFL,IZ(I),40,0)        
      CALL WRITE (IDMPFL,HEAD(1),96,1)        
      CALL WRITE (IDMPFL,IZ(1),0,1)        
      CALL CLOSE (IDMPFL,EOFNRW)        
C        
C     WRITE DUMMY TRAILER        
C        
      IXX   = IK(1)        
      IK(1) = IDMPFL        
      CALL WRTTRL (IK(1))        
      IK(1) = IXX        
C        
C     INFORM USER IF RUN REGION SIZE CAN BE REDUCED        
C        
      IF (NBPW-36) 300,310,320        
  300 I = 4        
      GO TO 330        
  310 I = 6        
      GO TO 330        
  320 I = 10        
      IF (NBPW .EQ. 64) I = 8        
  330 I = (I*MINOPN)/1000        
      IF (I .LT. 0) I = 0        
      WRITE (NOUT,605) UIM,MINOPN,I        
      RETURN        
C        
  500 CALL MESAGE (-1,IFILE,NAME)        
      RETURN        
C        
C        
  600 FORMAT (1H1,27X,'*****  F E E R  *****  (FAST EIGENVALUE',        
     1        ' EXTRACTION ROUTINE)  *****',  ////,1H ,I10,' SINGLE ',  
     2        'PRECISION WORDS OF OPEN CORE, NOT USED (SUBROUTINE ',    
     3        'CFEER)', //)        
  601 FORMAT (A25,' 3149',//5X,'USER SPECIFIED NEIGHBORHOOD CENTERED AT'
     1,      ' ORIGIN NOT ALLOWED, CENTER SHIFTED TO THE RIGHT .001',//)
  602 FORMAT (A25,' 3150',//5X,'DESIRED NUMBER OF EIGENVALUES',I8,3X,   
     1       'INVALID. SET = 1.',//)        
  603 FORMAT (A25,' 3151',//5X,'DYNAMIC MATRIX IS SINGULAR (OCCURRENCE',
     1       I3,') IN NEIGHBORHOOD CENTERED AT ',1P,2D16.8,//)        
  604 FORMAT (A29,' 3159',//5X,'ALL SOLUTIONS HAVE BEEN FOUND.',//)     
  605 FORMAT (A29,' 3160',//5X,'MINIMUM OPEN CORE NOT USED BY FEER',I9, 
     1       ' WORDS (',I9,'K BYTES).',//)        
  606 FORMAT (A25,' 3161',//5X,'DESIRED NUMBER OF EIGENSOLUTIONS',I5,   
     1       ' FOR NEIGHBORHOOD',I3,' OF',I3,' CENTERED AT ',1P,2D16.8, 
     2       //5X,'EXCEEDS THE EXISTING NUMBER',I5,        
     3       ', ALL EIGENSOLUTIONS WILL BE SOUGHT.',//)        
  607 FORMAT (A29,' 3166',//1X,I5,' MORE ACCURATE EIGENSOLUTIONS THAN ',
     1       'THE',I5,' REQUESTED HAVE BEEN FOUND FOR NEIGHBORHOOD',I3, 
     2       ' OF',I3, //5X,'CENTERED AT ',1P,2D16.8,        
     3       '. USE DIAG 12 TO DETERMINE ERROR ESTIMATES.',//)        
      END        
