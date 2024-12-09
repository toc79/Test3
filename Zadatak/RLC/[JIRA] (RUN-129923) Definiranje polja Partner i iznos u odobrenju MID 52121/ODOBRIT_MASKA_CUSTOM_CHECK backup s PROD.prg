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