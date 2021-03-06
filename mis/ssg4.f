      SUBROUTINE SSG4        
C        
C     DRIVER TO DO INERTIAL RELIEF PORTION OF SSG        
C        
C     DMAP SEQUENCE        
C        
C     SSG4  PL,QR,PO,MR,MLR,D,MLL,MOOB,MOAB,GO,USET/PLI,POI/V,N,IOMT $  
C        
      INTEGER  GO,USET        
      INTEGER PL,QR,PO,D,PLI,POI,SCR1,SCR2,SCR3,SCR4,SCR5        
      COMMON /BITPOS/ UM,UO,UR,USG,USB,UL,UA,UF,US,UN,UG        
      COMMON /BLANK/ IOMT        
      DATA PL,QR,PO,MR,MLR,D,MLL,MOOB,MOAB,PLI,POI,SCR1,SCR2,SCR3,SCR4  
     1   ,SCR5,GO,USET        
     2   / 101,102,103,104,105,106,107,108,109,201,202,301,302,303,304, 
     3   305,110,111/        
C        
C     COMPUTE  MR-1*QR=TEMP2        
C        
      CALL FACTOR(MR,SCR1,SCR2,SCR3,SCR4,SCR5)        
      CALL SSG3A( MR, SCR1, QR, SCR3, SCR4, SCR5, -1, XXX )        
C        
C     COMPUTE  MLL*D+MLR=TEMP1        
C        
      CALL SSG2B(MLL,D,MLR,SCR4,0,2,1,SCR1)        
C        
C     COMPUTE  TEMP1*TEMP2+PL=PLI        
C        
      CALL SSG2B(SCR4,SCR3,PL,PLI,0,2,1,SCR1)        
      IF(IOMT) 20,20,10        
C        
C     COMPUTE  MOOB*GO+MOAB=SCR4        
C        
   10 CALL SSG2B(MOOB,GO,MOAB,SCR4,0,2,1,SCR1)        
C        
C     COMPUTE DI*TEMP2  =SCR2        
C        
      CALL SSG2B(D,SCR3,0,SCR2,0,2,1,SCR1)        
      CALL SDR1B(SCR5,SCR2,SCR3,SCR1,UA,UL,UO,USET,0,0)        
C        
C     COMPUTE  SCR4*SCR1+PO=POI        
C        
      CALL SSG2B(SCR4,SCR1,PO,POI,0,2,1,SCR3)        
   20 RETURN        
      END        
