***************************************************
* 19.05.2017 g_tomislav MR 38009
IF loForm.tip_vnosne_maske == 1
	LOCAL lcSQL38009, lnDokJeNaListi38009
	TEXT TO lcSQL38009 NOSHOW
		DECLARE @lista varchar(1000)
		SET @lista = (Select val_char from dbo.GENERAL_REGISTER Where ID_REGISTER = 'DOK_KATEGORIJA4' AND ID_KEY = 'A' AND neaktiven = 0) 
		Select count(*) AS id FROM dbo.gfn_GetTableFromList(@lista) Where LTRIM(RTRIM(id)) = '{0}'
	ENDTEXT
	lcSQL38009 = STRTRAN(lcSQL38009, "{0}", ALLT(dokument.id_obl_zav))
	lnDokJeNaListi38009 = GF_SQLExecScalarNull(lcSQL38009) && ako nema kategorije 4, rezultat će isto biti 0

	IF lnDokJeNaListi38009 > 0 THEN
		loForm.txtKategorija4.Value = "A"
	ENDIF
ENDIF
** KRAJ MR 38009*************************************************


***************************************************
* 17.05.2017 g_tomislav MR 38009
LOCAL lcSQL38009, lnDokJeNaListi38009
TEXT TO lcSQL38009 NOSHOW
	DECLARE @lista varchar(1000)
	SET @lista = (Select val_char from dbo.GENERAL_REGISTER Where ID_REGISTER = 'DOK_KATEGORIJA4' AND ID_KEY = 'A' AND neaktiven = 0) 
	Select count(*) AS id FROM dbo.gfn_GetTableFromList(@lista) Where LTRIM(RTRIM(id)) = '{0}'
ENDTEXT
lcSQL38009 = STRTRAN(lcSQL38009, "{0}", ALLT(dokument.id_obl_zav))
lnDokJeNaListi38009 = GF_SQLExecScalarNull(lcSQL38009) && ako nema kategorije 4, rezultat će isto biti 0

IF loForm.tip_vnosne_maske == 1 AND lnDokJeNaListi38009 > 0 THEN
	loForm.txtKategorija4.Value = "A"
ENDIF
** KRAJ MR 38009*************************************************