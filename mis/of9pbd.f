      BLOCK DATA OF9PBD        
COF9PBD        
C        
C     BLOCK DATA FOR ALL NON-STRESS AND NON-FORCE C ARRAYS        
C        
      INTEGER C1, C41        
      COMMON /OFPB9/ C1(240), C41(240)        
C DISPLACEMENT VECTOR REAL SORT 1        
      DATA C1  /    1,  0,  1, -1,  0,  2   ,   0,  0,  0, -1,  0,  0   
C DISPLACEMENT VECTOR REAL SORT 2        
     A           ,311,107,  1, -1,  0,315   , 354,107,  1, -1,  0,112   
C DISPLACEMENT VECTOR COMPLEX SORT 1        
     B           ,374,104,119,125,  0,  2   , 411,104,119,126,  0,  2   
C DISPLACEMENT VECTOR COMPLEX SORT 2        
     C           ,392,107,119,125,  0,111   , 429,107,119,126,  0,111   
C LOAD VECTOR REAL SORT 1        
     D           ,  1,  0, 33, -1,  0,  2   ,   0,  0,  0, -1,  0,  0   
C LOAD VECTOR REAL SORT 2        
     E           ,311,107, 33, -1,  0,315   , 354,107, 33, -1,  0,112   
C LOAD VECTOR COMPLEX SORT 1        
     F           ,374,104,123,125,  0,  2   , 411,104,123,126,  0,  2   
C LOAD VECTOR COMPLEX SORT 2        
     G           ,392,107,123,125,  0,111   , 429,107,123,126,  0,111   
C SPCF VECTOR REAL SORT 1        
     H           ,  1,  0, 45, -1,  0,  2   ,   0,  0,  0, -1,  0,  0   
C SPCF VECTOR REAL SORT 2        
     I           ,311,107, 45, -1,  0,315   , 354,107, 45, -1,  0,112   
C SPCF VECTOR COMPLEX SORT 1        
     J           ,374,104,122,125,  0,  2   , 411,104,122,126,  0,  2   
C SPCF VECTOR COMPLEX SORT 2        
     K           ,392,107,122,125,  0,111   , 429,107,122,126,  0,111   
C VELOCITY VECTOR REAL SORT 1     ACCELERATION VECTOR REAL SORT 1       
     L           ,  1,106,113, -1,  0,  2   ,   1,106,114, -1,  0,  2   
C VELOCITY REAL SORT 2(LEFT)     ACCELERATION REAL SORT 2 (RIGHT)       
     M           ,354,107,113, -1,  0,112   , 354,107,114, -1,  0,112   
C NON-LINEAR FORCE REAL SORT 1     NON-LINEAR FORCE REAL SORT 2        
     N           ,  1,106,115, -1,  0,  2   , 354,107,115, -1,  0,112   
C VELOCITY COMPLEX SORT 1        
     O           ,374,104,120,125,  0,  2   , 411,104,120,126,  0,  2   
C VELOCITY COMPLEX SORT 2        
     P           ,392,107,120,125,  0,111   , 429,107,120,126,  0,111   
C ACCELERATION COMPLEX SORT 1        
     Q           ,374,104,121,125,  0,  2   , 411,104,121,126,  0,  2   
C ACCELERATION COMPLEX SORT 2        
     R           ,392,107,121,125,  0,111   , 429,107,121,126,  0,111   
C EIGENVALUE SUMMARY REAL SORT 1       EIGENVALUE SUMMARY COMPLEX SORT 1
     S           ,298,  0,  3, -1,  4,  5   , 365,  0,116, -1,117,118 / 
C        
C EIGENVECTOR COMPLEX SORT 1        
      DATA C41 /  374,  0,124,125,  0,  2   , 411,  0,124,126,  0,  2   
C VDR-DISPLACEMENT REAL SORT 1     VDR-DISPLACEMENT REAL SORT 2        
     A           ,  1,  0,212, -1,  0,  2   , 354,107,212, -1,  0,112   
C VDR-DISPLACEMENT VECTOR COMPLEX SORT 1        
     B           ,374,104,208,125,  0,  2   , 411,104,208,126,  0,  2   
C VDR-DISPLACEMENT VECTOR COMPLEX SORT 2        
     C           ,392,107,208,125,  0,111   , 429,107,208,126,  0,111   
C VDR-VELOCITY REAL SORT 1     VDR-VELOCITY REAL SORT 2        
     D           ,  1,  0,211, -1,  0,  2   , 354,107,211, -1,  0,112   
C VDR-VELOCITY VECTOR COMPLEX SORT 1        
     E           ,374,104,209,125,  0,  2   , 411,104,209,126,  0,  2   
C VDR-VELOCITY VECTOR COMPLEX SORT 2        
     F           ,392,107,209,125,  0,111   , 429,107,209,126,  0,111   
C VDR-ACCELERATION REAL SORT 1     VDR-ACCELERATION REAL SORT 2        
     G           ,  1,  0,213, -1,  0,  2   , 354,107,213, -1,  0,112   
C VDR-ACCELERATION VECTOR COMPLEX SORT 1        
     H           ,374,104,210,125,  0,  2   , 411,104,210,126,  0,  2   
C VDR-ACCELERATION VECTOR COMPLEX SORT 2        
     I           ,392,107,210,125,  0,111   , 429,107,210,126,  0,111   
C VDR-EIGENVECTOR COMPLEX SORT 1        
     J           ,374,104,214,125,  0,  2   , 411,104,214,126,  0,  2   
C VDR-EIGENVECTOR COMPLEX SORT 2        
     K           ,392,107,214,125,  0,111   , 429,107,214,126,  0,111   
C EIGENVALUE ANALYSIS SUMMARY  (4 TYPES)      REAL SORT 1        
     L           ,  1,  0,  0, -1, 92, 93   ,   1,  0,  0, -1, 90, 91   
     M           ,336,  0, 92, -1, 95, 94   ,   1,  0,  0, -1,215,216   
C EIGENVALUE ANYLYSIS SUMMARY COMPLEX SORT 1  (4 TYPES)        
     N           ,  1,  0,  0, -1, 96, 98   ,   1,  0,  0, -1,100, 99   
     O           ,345,  0, 96, -1, 95, 97   ,   1,  0,  0, -1,100, 99   
C EIGENVECTOR REAL SORT 1     GPST REAL SORT 1        
     P           ,  1,  0,  6, -1,  0,  2   , 321,  0, 30, -1, 31, 32   
C ELEMENT STRAIN ENERGY        
     Q          ,2258,  0,353, -1,  0,354   ,   0,  0,  0,  0,  0,  0   
C GRID POINT FORCE BALANCE        
     R          ,2266,  0,355, -1,  0,356   ,   0,  0,  0,  0,  0,  0   
C MPCFORCE VECTOR REAL SORT 1        
     S           ,  1,  0,375, -1,  0,  2   ,   0,  0,  0, -1,  0,  0  /
C        
      END        
