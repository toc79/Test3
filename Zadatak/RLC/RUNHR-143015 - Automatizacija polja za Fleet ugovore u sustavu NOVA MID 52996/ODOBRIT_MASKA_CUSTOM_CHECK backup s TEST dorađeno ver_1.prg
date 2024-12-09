**********************
** 22.08.2024 g_tomislav MID 52996

** zadnji označen zapis ne uvažava pa su potrebne sljedeće 3 linije tj. tabela se ne osvježi
SELECT _zavar 
SCAN FOR GF_NULLOREMPTY(id_kupca)
ENDSCAN

lcIdPosrednik = ALLT(NVL(GF_SQLEXECScalarNull("select id_posrednik from dbo.ponudba where id_pon = "+GF_Quotedstr(NVL(_odobrit.id_pon, ""))), ""))

IF lcIdPosrednik == "FLT" OR lcIdPosrednik == "RBAF" OR lcIdPosrednik == "DOBF" OR lcIdPosrednik == "DOPF"

	SELECT * FROM _zavar WHERE id_obl_zav == "DF" INTO CURSOR _ef_DF
									   
	IF RECCOUNT("_ef_DF") == 0
		POZOR("U tablici Osiguranja je obavezan unos dokumenta DF kada je na ponudi unesen Posrednik = FLT, RBAF, DOBF ili DOPF!")
		RETURN .F.
	ENDIF
ENDIF
** END MID 52996 *****