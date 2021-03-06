      SUBROUTINE RBMG4
C*****
C RBMG4 COMPUTES MR FROM THE MATRIX EQUATION
C      MR = MRR + DM(T) * MLR + MLR(T) * DM + DM(T) * MLL * DM
C*****
      INTEGER SCR1,SCR2,DM
      INTEGER SCR3
C*****
C     INPUT DATA FILES
C*****
      DATA DM,MLL,MLR,MRR/101,102,103,104/                              
C*****                                                                  
C     OUTPUT DATA FILES
C*****
      DATA MR/201/                                                      
C*****                                                                  
C     SCRATCH DATA FILES
C*****
      DATA SCR1,SCR2,SCR3/301,302,303/                                  
C*****                                                                  
C     COMPUTE MR
C*****
      CALL ELIM(MRR,MLR,MLL,DM,MR,SCR1,SCR2,SCR3)
      RETURN
      END
