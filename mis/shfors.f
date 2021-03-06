      SUBROUTINE SHFORS (NUMPX,ELID,IGRID,THIKNS,G,EPSCSI,QVECI,IDR)    
C        
C     TO CALCULATE SHELL ELEMENT FORCES FOR A 2-DL FORMULATION BASE.    
C        
C        
C     INPUT :        
C           NUMPX  - NUMBER OF EVALUATION POINTS        
C           ELID   - ELEMENT ID        
C           IGRID  - ARRAY IF EXTERNAL GRID IDS        
C           THIKNS - EVALUATION POINT THICKNESSES        
C           G      - 6X6 STRESS-STRAIN MATRIX        
C           EPSCSI - CORRECTED STRAINS AT EVALUATION POINTS        
C           QVECI  - CALCULATED SHEAR FORCES READY FOR OUTPUT        
C           IDR    - REORDERING ARRAY BASED ON EXTERNAL GRID POINT ID'S 
C          /OUTREQ/- OUTPUT REQUEST LOGICAL FLAGS        
C        
C     OUTPUT:        
C            FORCES ARE PLACED AT THE PROPER LOCATION IN /SDR2X7/.      
C        
C        
C     THE FORCE RESULTANT OUTPUT DATA BLOCK, UAI CODE        
C        
C     ADDRESS    DESCRIPTIONS        
C        
C        1       ELID        
C     ------------------------------------------------        
C        2       GRID POINT NUMBER OR 'CNTR'        
C      3 - 10    FORCES AT ELEMENT CENTER POINT        
C     ---------- ABOVE DATA REPEATED 3 TIMES        
C                FOR GRID POINTS        
C        
C        
C     THE FORCE RESULTANT OUTPUT DATA BLOCK AT ELEMETN CENTER, COSMIC   
C        
C     ADDRESS    DESCRIPTIONS        
C        
C        1       ELID        
C     ------------------------------------------------        
C      2 - 9     FORCES AT ELEMENT CENTER POINT        
C        
C        
      LOGICAL         GRIDS,VONMS,LAYER,STRCUR,STSREQ,STNREQ,FORREQ     
     1,               GRIDSS,VONMSS,LAYERS,COSMIC        
      INTEGER         IGRID(1),NFORS(1),IDR(1),ELID        
      REAL            THIKNS(1),G(6,6),EPSCSI(6,1),QVECI(2,1),        
     1                THICK,THICK2,T3OV12,DFORCE(8),GT(6,6)        
      COMMON /SDR2X7/ DUM71(100),STRES(100),FORSUL(200),STRIN(100)      
      COMMON /OUTREQ/ STSREQ,STNREQ,FORREQ,STRCUR,GRIDS,VONMS,LAYER     
     1,               GRIDSS,VONMSS,LAYERS        
      EQUIVALENCE     (NFORS(1),FORSUL(1))        
      DATA    COSMIC/ .TRUE. /        
C        
C        
C     ELEMENT CENTER POINT COMPUTAION ONLY FOR COSMIC        
C     IE. CALLER SHOULD PASS 1 IN NUMPX FOR COSMIC, 4 FOR UAI        
C        
      NUMP = NUMPX        
      IF (COSMIC) NUMP = 1        
C        
      NFORS(1)  = ELID        
C        
C     START THE LOOP ON EVALUATION POINTS        
C        
      NUMP1 = NUMP - 1        
      DO 280 INPLAN = 1,NUMP        
      THICK  = THIKNS(INPLAN)        
      THICK2 = THICK*THICK        
      T3OV12 = THICK2*THICK/12.0        
C        
      IFORCE = 1        
      IF (COSMIC) GO TO 250        
C        
      IFORCE = (INPLAN-1)*9 + 2        
      IF (.NOT.(GRIDS .AND. GRIDSS) .OR. INPLAN.LE.1) GO TO 230        
      DO 200 INPTMP = 1,NUMP1        
      IF (IDR(INPTMP) .EQ. IGRID(INPLAN)) GO TO 220        
  200 CONTINUE        
  220 CONTINUE        
      IFORCE = INPTMP*9 + 2        
      NFORS(IFORCE) = IGRID(INPLAN)        
      GO TO 240        
  230 NFORS(IFORCE) = INPLAN - 1        
  240 IF (INPLAN .EQ. 1) NFORS(IFORCE) = IGRID(INPLAN)        
C        
C     MODIFY [G], THEN CALCULATE FORCES AND MOMENTS        
C        
  250 DO 260 IG = 1,3        
      DO 260 JG = 1,3        
      GT(IG  ,JG  ) = THICK *G(IG  ,JG  )        
      GT(IG+3,JG  ) = THICK2*G(IG+3,JG  )        
      GT(IG  ,JG+3) = THICK2*G(IG  ,JG+3)        
      GT(IG+3,JG+3) = T3OV12*G(IG+3,JG+3)        
  260 CONTINUE        
      CALL GMMATS (GT,6,6,0, EPSCSI(1,INPLAN),6,1,0, DFORCE(1))        
C        
C     OUTPUT QX AND QY (WE HAVE CALCULATED QY AND QX)        
C        
      DFORCE(7) = QVECI(2,INPLAN)        
      DFORCE(8) = QVECI(1,INPLAN)        
C        
C     SHIP OUT        
C        
      DO 270 IFOR = 1,8        
      FORSUL(IFORCE+IFOR) = DFORCE(IFOR)        
  270 CONTINUE        
  280 CONTINUE        
C        
      RETURN        
      END        
