E1,E2,ED,EG,EL,EN,EO,EP,EZ,ZY,ZZ

INSERT INTO dbo.GENERAL_REGISTER(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC Reporting list','RLC_KROV_INST_OSIG','E1,E2,ED,EG,EL,EN,EO,EP,EZ,ZY,ZZ',0,NULL,NULL,0,NULL)


	TEXT TO lcSQL40834 NOSHOW
		DECLARE @lista varchar(300)
		SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_KROV_INST_OSIG' and neaktiven = 0) 

		Select value AS id FROM dbo.gfn_GetTableFromList(@lista) Where LTRIM(RTRIM(id)) = '{0}'
	ENDTEXT

	lcSQL40834 = STRTRAN(lcSQL40834, "{0}", ALLT(dokument.id_obl_zav))
	lnDokJeNaListi = GF_SQLExecScalarNull(lcSQL40834) && ako nema RLC_DAT_VRACANJA, rezultat će isto biti 0

	IF loForm.tip_vnosne_maske = 2 AND lnDokJeNaListi > 0 THEN 
	
	
GF_SqlExec("SELECT * FROM dbo.dokument WHERE id_frame = " + GF_QuotedStr(lnId_frame), "_okvir_krovni_dokument")

* NOVO
	TEXT TO lcSQL40834 NOSHOW
		DECLARE @lista varchar(max)
		SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_KROV_INST_OSIG' and neaktiven = 0) 
		
		SELECT * FROM dbo.dokument WHERE id_frame = {0} AND id_obl_zav IN (SELECT id FROM dbo.gfn_GetTableFromList(@lista))
	ENDTEXT
	
	lcSQL40834 = STRTRAN(lcSQL40834, "{0}", trans(lnId_frame))

	GF_SQLEXEC(lcSQL40834, "_okvir_krovni_dokument")
	
	
	