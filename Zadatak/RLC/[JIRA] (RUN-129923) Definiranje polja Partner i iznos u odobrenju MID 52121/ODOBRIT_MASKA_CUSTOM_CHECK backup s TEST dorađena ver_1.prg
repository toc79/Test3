LPARAMETERS lcId_kupca 
*obvesti ("ODOBRIT_MASKA_CUSTOM_CHECK")

loForm = GF_GetFormObject("frmOdobrit_Maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF


* g_tomislav MR 40667
IF loForm.tip_vnosne_maske == 1 && Novi zapis 
	POZOR("Da li ste predali Asistentu dokumentaciju klijenta ili Grupe na ažuriranje (evaluacija, ZSPNFT ..)?")
ENDIF

*22.11.2023 g_vuradin MR 51671 - provjera ponude starije od 12 dana
LOCAL lcSql

TEXT TO lcSql NOSHOW
select case when dat_pon < GETDATE()-12 then 1 else 0 end as datum from dbo.ponudba where id_pon = '{0}'
ENDTEXT

lcSql = STRTRAN(lcSql, '{0}', trans(_odobrit.id_pon)) 
GF_SQLEXEC(lcSql, "_provjera_ponudbe")

IF loForm.tip_vnosne_maske == 1 and _provjera_ponudbe.datum = 1 
Obvesti("Ponuda je istekla, potrebno je izraditi novu ponudu!")
RETURN .F.
ENDIF

**********************
** 16.08.2024 g_tomislav MID 52121

** zadnji označen zapis ne uvažava pa su potrebne sljedeće 3 linije
SELECT _zavar 
SCAN FOR GF_NULLOREMPTY(id_kupca)
ENDSCAN

SELECT * FROM _zavar WHERE INLIST(id_obl_zav, "B1", "B2", "B3", "B4", "B5", "B6", "ZE") AND GF_NULLOREMPTY(id_kupca) INTO CURSOR _ef_obavezni_ima_part
								   
IF RECCOUNT("_ef_obavezni_ima_part") > 0
	POZOR("U tablici Osiguranja je obavezan unos šifre partnera (Osoba) za dokumente B1, B2, B3, B4, B5, B6 i ZE!")
	RETURN .F.
ENDIF

SELECT * FROM _zavar WHERE id_obl_zav == "ZE" AND (NVL(id_vr_val, 0) == 0 OR GF_NULLOREMPTY(id_tec)) INTO CURSOR _ef_obavezna_vrijednost
									 
IF RECCOUNT("_ef_obavezna_vrijednost") > 0
	POZOR("U tablici Osiguranja je obavezan unos vrijednosti (Do iznosa) i Tečaja za dokument ZE!")
	RETURN .F.
ENDIF

** END MID 52121 *****

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