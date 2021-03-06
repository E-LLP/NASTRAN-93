      SUBROUTINE COPY        
C        
C     COPY  INPUT /OUTPUT/ PARAM $        
C        
C     THIS UTILITY MODULE GENERATES A PHYSICAL COPY OF THE INPUT DATA   
C     BLOCK IF THE VALUE OF PARAM IS LESS THAN ZERO (DEFAULT IS -1).    
C     THE OUTPUT DATA BLOCK CARRIES THE INPUT DATA BLOCK NAME IN THE    
C     HEADER RECORD.        
C     IF PARAM IS SET TO ZERO, THE OUTPUT DATA BLOCK WILL HAVE ITS OWN  
C     NAME IN THE OUTPUT FILE HEADER RECORD.  (IMPLEMENTED IN JUNE 84)  
C        
C        
      INTEGER         MODNAM(2),SYSBUF,OUTPUT,ITRL(7),IN(15),OUT(15)    
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZCOPY/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / IPARAM        
C     COMMON /GINOX / IGINO        
      COMMON /XFIST / IFIST(1)        
      COMMON /XFIAT / IFIAT(1)        
      DATA    INPUT / 101 /, OUTPUT / 201 /, MODNAM / 4HCOPY,4H    /    
C        
C     RETURN IF IPARAM NOT GREATER THAN ZERO        
C        
      IF (IPARAM .EQ. 0) IPARAM = -1111        
      IF (IPARAM .GE. 0) RETURN        
C        
C     COMPUTE OPEN CORE AND INITIALIZE GINO BUFFERS        
C        
      NZWD = KORSZ(Z(1))        
      IF (NZWD .LE. 0) CALL MESAGE (-8,0,MODNAM)        
      IBUF1 = NZWD  - SYSBUF        
      IBUF2 = IBUF1 - SYSBUF        
      LCORE = IBUF2 - 1        
      IF (LCORE .LE. 0) CALL MESAGE (-8,0,MODNAM)        
C        
C     OPEN INPUT AND OUTPUT DATA BLOCKS        
C        
      IN(1)   = INPUT        
      OUT(1)  = OUTPUT        
      ITRL(1) = 101        
      CALL RDTRL (ITRL)        
      CALL OPEN  (*1001,INPUT,Z(IBUF1),0)        
      CALL OPEN  (*1002,OUTPUT,Z(IBUF2),1)        
      CALL CPYFIL (IN,OUT,Z(1),LCORE,ICOUNT)        
      CALL CLOSE (OUTPUT,1)        
      CALL CLOSE (INPUT,1)        
      ITRL(1) = 201        
      CALL WRTTRL (ITRL)        
      RETURN        
C        
 1001 CALL MESAGE (-1,INPUT,MODNAM)        
 1002 CALL MESAGE (-1,OUTPUT,MODNAM)        
      RETURN        
      END        
