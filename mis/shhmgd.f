      SUBROUTINE SHHMGD (*,ELID,MM,SIL,BGPDT,GPTH,ELTH,GPTEMP,FLAG,MID, 
     1                   MFLAG,MCID,THETA,TEMP,NNODE,NSIL,DELTAP,HTCON, 
     2                   HTCAP)        
C        
C     SHELL ELEMENT HEAT MATRIX GENERATOR FOR QUAD8 AND TRIA6 ELEMENTS  
C        
C          ********************************************************     
C          *                                                      *     
C          *  PRESENTLY COSMIC/NASTRAN DOES NOT USE THIS ROUTINE  *     
C          *                                                      *     
C          ********************************************************     
C        
C     PERFORMS ONE OF THE FOLLOWING FOR THE ISOPARAMETRIC SHELL ELEMENTS
C        
C     FLAG =1  CALCULATE THE CONDUCTIVITY AND CAPACITY MATRICES.        
C     FLAG =2  CALCULATE THE DELTA-LOAD VECTOR FOR NONLINEAR HEAT.      
C        
C     INPUT :        
C           ELID  - ELEMENT ID        
C           MM    - MAXIMUM NO. OF NODES FOR THE ELEMENT        
C           SIL   - SIL ARRAY FROM CONNECTION        
C           BGPDT - BGPDT ARRAY FROM BGPDT        
C           GPTH  - GRID POINT THICKNESSES FROM CONNECTION        
C           ELTH  - ELEMENT THICKNESS FROM PROPERTY        
C           GPTEMP- GRID TEMPERATURES FROM GPTT        
C           FLAG  - OPTION INDICATOR        
C           MID   - MATERIAL ID        
C           MFLAG - MATERIAL FLAG        
C           MCID  - MATERIAL CID, IF MFLAG IS 1        
C           THETA - MATERIAL ANGLE, IF MFLAG IS 0        
C           TEMP  - TEMPERATURE VALUES (FOR NONLINEAR)        
C     OUTPUT:        
C           NSI L - REORDERED SIL ARRAY        
C           DELTAP- DELTA-LOAD VECTOR        
C           HTCON - CONDUCTIVITY MATRIX        
C           HTCAP - CAPACITY MATRIX        
C        
      INTEGER          SIL(8),NSIL(8),ELID,FLAG,IORDER(8),IORDRN(8),    
     1                 MMN(8),NECPT(4)        
      REAL             TEMP(1),GPTEMP(1),BGPDT(4,8),GPTH(8),BGPDM(3,8), 
     1                 ECPT(4),KHEAT        
      DOUBLE PRECISION XI,ETA,WX,WE,THK,POINTX(6),POINTE(2),WEITX(6),   
     1                 WEITE(2),WEITC,DETJ,SHP(10),VOLI,HTCON(1),       
     2                 HTCAP(1),TMPR(8),HTFLX(24),BTERMS(32),TEB(9),    
     3                 TUB(9),TBM(9),TEM(9),GT(4),GI(4),CENTE(3),AVGTHK,
     4                 EPS1,XM,YM,THETAM,PI,TWOPI,RADDEG,DEGRAD,        
     5                 EGPDT(4,8),GPNORM(4,8),EPNORM(4,8),DGPTH(8),     
     6                 TIE(9),DELTAP(1),TCE(63)        
      COMMON /MATIN /  MATID,INFLAG,ELTEMP,DUMMY,SINMAT,COSMAT        
      COMMON /HMTOUT/  KHEAT(6), HTCP        
      COMMON /CONDAD/  PI,TWOPI,RADDEG,DEGRAD        
      EQUIVALENCE      (ECPT(1),NECPT(1))        
      DATA    EPS1  /  1.0D-11 /        
C        
C        
C     DOUBLE PRECISON VERSION        
C        
C        
C     BRANCH ON ELEMENT TYPE        
C        
      IF (MM .EQ. 6) GO TO 100        
      IF (MM .EQ. 8) GO TO 200        
      GO TO 3000        
C        
C     TRIA6        
C     1.0D0/6.0D0 = 0.166666667D0        
C     2.0D0/3.0D0 = 0.666666667D0        
C        
  100 INDX = 1        
      NXI  = 3        
      NETA = 1        
      POINTX(1) = 0.166666667D0        
      POINTX(2) = 0.166666667D0        
      POINTX(3) = 0.666666667D0        
      POINTX(4) = 0.166666667D0        
      POINTX(5) = 0.666666667D0        
      POINTX(6) = 0.166666667D0        
C        
      WEITX(1)  = 0.166666667D0        
      WEITX(2)  = 0.166666667D0        
      WEITX(3)  = 0.166666667D0        
      WEITX(4)  = 0.166666667D0        
      WEITX(5)  = 0.166666667D0        
      WEITX(6)  = 0.166666667D0        
      GO TO 300        
C        
C     QUAD8        
C     -DSQRT(1.0D0/3.0D0) = -0.577350269D0        
C        
  200 INDX = 2        
      NXI  = 2        
      NETA = 2        
      POINTX(1) =-0.577350269D0        
      POINTX(2) =-POINTX(1)        
      DO 210 I = 1,2        
      POINTE(I) = POINTX(I)        
      WEITX(I) = 1.0D0        
  210 WEITE(I) = 1.0D0        
C        
C     SET UP THE ELEMENT VARIABLES        
C        
  300 CALL SHSETD (*3000,MM,SIL,BGPDT,BGPDT,GPTH,ELTH,GPTEMP,BGPDM,     
     1             EGPDT,DGPTH,GPNORM,EPNORM,NNODE,MMN,NSIL,IORDER,     
     2             IORDRN,TEB,TUB,CENTE,AVGTHK,TCE,ELID)        
C        
C     GET THE TEMPERATURE VECTOR FROM CORE        
C        
      DO 320 I = 1,MM        
      TMPR(I) = 0.0D0        
      II = NSIL(I)        
      IF (II .EQ. 0) GO TO 320        
      TMPR(I) = TEMP(II)        
  320 CONTINUE        
C        
      NNODE2 = NNODE*NNODE        
      DO 330 I = 1,NNODE2        
      HTCON(I) = 0.0D0        
  330 HTCAP(I) = 0.0D0        
C        
C     GET THE PROPERTIES        
C        
      MATID   = MID        
      INFLAG  = 12        
      ELTEMP  = 0.0        
      ECPT(2) = 0.0        
      ECPT(3) = 0.0        
      ECPT(4) = 0.0        
      DO 400 I = 1,NNODE        
      ECPT(2) = ECPT(2) + BGPDT(2,I)        
      ECPT(3) = ECPT(3) + BGPDT(3,I)        
      ECPT(4) = ECPT(4) + BGPDT(4,I)        
  400 ELTEMP  = ELTEMP  + GPTEMP(I)        
      ELTEMP  = ELTEMP/NNODE        
      ECPT(2) = ECPT(2)/NNODE        
      ECPT(3) = ECPT(3)/NNODE        
      ECPT(4) = ECPT(4)/NNODE        
C        
      IF (MFLAG .EQ. 0) GO TO 500        
C        
C     CALCULATE [TEM] USING MCID        
C        
      IF (MCID .GT. 0) GO TO 420        
      DO 410 I = 1,9        
  410 TEM(I) = TEB(I)        
      GO TO 430        
  420 NECPT(1) = MCID        
      CALL TRANSD (ECPT,TBM)        
      CALL GMMATD (TEB,3,3,0, TBM,3,3,0, TEM)        
C        
C     CALCULATE THETAM FROM THE PROJECTION OF THE X-AXIS OF THE MATERIAL
C     COORD. SYSTEM ON TO THE XY PLANE OF THE ELEMENT COORD. SYSTEM     
C        
  430 XM = TEM(1)        
      YM = TEM(4)        
      IF (DABS(XM).GT.EPS1 .OR. DABS(YM).GT.EPS1) GO TO 440        
      GO TO 3000        
  440 THETAM = DATAN2(YM,XM)        
      GO TO 510        
  500 THETAM = THETA*DEGRAD        
  510 SINMAT = DSIN(THETAM)        
      COSMAT = DCOS(THETAM)        
C        
      CALL HMAT (ELID)        
C        
      GI(1) = DBLE(KHEAT(1))        
      GI(2) = DBLE(KHEAT(2))        
      GI(3) = GI(2)        
      GI(4) = DBLE(KHEAT(3))        
C        
C     IF NONLINEAR, GET THE UPDATED MATERIAL PROPERTIES        
C        
      IF (FLAG .EQ. 1) GO TO 1000        
      ELTEMP = 0.0        
      DO 900 I = 1,NNODE        
  900 ELTEMP = ELTEMP + SNGL(TMPR(I))        
      ELTEMP = ELTEMP/NNODE        
C        
      CALL HMAT (ELID)        
C        
      GI(1) = DBLE(KHEAT(1)) - GI(1)        
      GI(2) = DBLE(KHEAT(2)) - GI(2)        
      GI(3) = GI(2)        
      GI(4) = DBLE(KHEAT(3)) - GI(4)        
C        
C     START THE TRIPLE LOOP        
C        
 1000 CONTINUE        
      DO 2000 IXI = 1,NXI        
      XI = POINTX(IXI)        
      WX = WEITX(IXI)        
C        
      DO 1200 IETA = 1,NETA        
      IF (NETA .EQ. 1) GO TO 1010        
      ETA = POINTE(IETA)        
      WE  = WEITE(IETA)        
      GO TO 1020        
 1010 ETA = POINTX(IXI+NXI)        
      WE  = 1.0D0        
 1020 CONTINUE        
C        
C     CALCULATE THE B TERMS        
C        
      IF (MM .EQ. 8) CALL SHTRMD (*3000,ELID,MM,NNODE,XI,ETA,DGPTH,     
     1               EPNORM,EGPDT,IORDER,MMN,DETJ,THK,SHP,TIE,BTERMS)   
      IF (MM .EQ. 6) CALL SHTRMD (*3000,ELID,MM,NNODE,XI,ETA,DGPTH,     
     1               EPNORM,EGPDT,IORDRN,MMN,DETJ,THK,SHP,TIE,BTERMS)   
C        
      VOLI  = DETJ*WX*WE*THK*2.0D0        
      WEITC = VOLI*HTCP        
      DO 1030 I = 1,4        
 1030 GT(I) = GI(I)*VOLI        
C        
      CALL GMMATD (GT,2,2,0, BTERMS,2,NNODE,0, HTFLX)        
      CALL GMMATD (BTERMS,2,NNODE,-1, HTFLX,2,NNODE,0, HTCON)        
C        
      IF (WEITC .EQ. 0.0) GO TO 1200        
      IP = 1        
      DO 1060 I = 1,NNODE        
      DO 1060 J = 1,NNODE        
      HTCAP(IP) = HTCAP(IP) + SHP(I)*SHP(J)*WEITC        
 1060 IP = IP + 1        
C        
 1200 CONTINUE        
 2000 CONTINUE        
C        
C     RECOVER NONLINEAR DELTA-LOAD        
C        
      IF (FLAG .NE. 1)        
     1    CALL GMMATD (HTCON,NNODE,NNODE,0, TMPR,NNODE,1,0, DELTAP(1))  
      RETURN        
C        
C        
      ENTRY SHHMGS (*,ELID,MM,SIL,BGPDT,GPTH,ELTH,GPTEMP,FLAG,MID,      
     1                MFLAG,MCID,THETA,TEMP,NNODE,NSIL,DELTAP,HTCON,    
     2                HTCAP)        
C     =============================================================     
C        
C     SINGLE PRECISION VERSION        
C        
      RETURN        
C        
 3000 CONTINUE        
      RETURN 1        
      END        
