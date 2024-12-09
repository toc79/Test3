loForm = GF_GetFormObject("frmKategorije_entiteta_maska")
IF ISNULL(loForm) THEN 
 RETURN
ENDIF

****************
* 04.10.2017. g_tomislav MR 38731 - posebne ovlasti za kategorije entiteta
****************
LOCAL laPar[1], lcOnemogucavanje, lcPostavljanje, lcSifra, lcId_cont, lcPogodba_status_akt

* omogućavanje unosa entiteta na Z ugovorima i svim ostalim kategorijama za koje korisnik ima posebna prava (definirano niže u kodu)
IF loForm.txtEntiteta.Value = "POGODBA" 
	lcId_cont = loForm.txtId_entitete.Value
	lcPogodba_status_akt = GF_SQLEXECScalarNull("SELECT status_akt FROM dbo.pogodba WHERE id_cont = "+GF_Quotedstr(lcId_cont))
	
	IF lcPogodba_status_akt == "Z"
		loForm.tip_vnosne_maske = 1 
	ENDIF
ENDIF
* kraj omogućavanje unosa entiteta na Z ugovorima

TEXT TO lcSql NOSHOW
	SELECT a.* FROM (
	SELECT SUBSTRING(id_key, 0, CHARINDEX(';', id_key) ) AS sifra
	, SUBSTRING(id_key, CHARINDEX(';', id_key) + 1, LEN(id_key) ) AS rola
	, dbo.gfn_UserIsInRole(?p1, SUBSTRING(id_key, CHARINDEX(';', id_key) + 1, LEN(id_key) )) as JeURoli --neaktivne role vraća 0
	--, * 
	FROM dbo.general_register 
	WHERE id_register = 'RLC_ENTITETI_OVLASTI'
	AND neaktiven = 0
	) a 
	WHERE a.JeURoli = 1
ENDTEXT

laPar[1] = allt(GObj_Comm.getUserName())

GF_SqlExec_P(lcSql, @laPar, "_ef_RLC_ENTITETI_OVLASTI")

lcPostavljanje = ""

select kategorije
GO TOP
SCAN 
	lcOnemogucavanje = "loForm.Block_kategorije."+kategorije.obj_name+".Enabled = .F." && početno sve šifre kategorija onemogućavamo za promjenu
	&lcOnemogucavanje
	
	lcSifra = kategorije.sifra
	select TOP 1 * FROM _ef_RLC_ENTITETI_OVLASTI WHERE sifra = lcSifra ORDER BY JeURoli INTO CURSOR _ef_ima_ovlast

	IF RECCOUNT() > 0
		lcPostavljanje = "loForm.Block_kategorije."+kategorije.obj_name+".Enabled = .T."
		&lcPostavljanje
	ENDIF
	
	IF USED ("_ef_ima_ovlast") 
		USE IN _ef_ima_ovlast
	ENDIF
	
ENDSCAN


IF USED ("_ef_RLC_ENTITETI_OVLASTI") 
	USE IN _ef_RLC_ENTITETI_OVLASTI
ENDIF 
**** KRAJ MR 38731 - posebne ovlasti za kategorije entiteta
****************
* 14.04.2020. g_dejank MR 44169 - kontrola za NIB broj za plovila
* 18.10.2022. g_vuradin MR 49719 - dorada kontrole zbog dinamičkog textboxa 
****************
IF loForm.txtEntiteta.Value == "POGODBA" THEN
lcId_cont = loForm.txtId_entitete.Value
select * from kategorije where sifra = 'NIB' into cursor _ef_kategorije_NIB	

lcPogodbaIdVrste = GF_SQLEXECScalarNull("SELECT id_vrste FROM dbo.pogodba WHERE id_cont = "+GF_Quotedstr(lcId_cont ))


	IF !GF_NULLOREMPTY(_ef_kategorije_NIB.id_kategorije_tip) and ALLT(lcPogodbaIdVrste) == "1481" THEN && for active entity
			
		lcPostavljanje1="loForm.Block_kategorije."+allt(_ef_kategorije_NIB.obj_name)+".Enabled = .T."
		&lcPostavljanje1
		lcPostavljanje2="loForm.Block_kategorije."+allt(_ef_kategorije_NIB.obj_name)+".obvezen = .T."
		&lcPostavljanje2
	ENDIF


	IF INLIST(lcPogodbaIdVrste , "1486", "1488") THEN
		lcPostavljanje3="loForm.Block_kategorije." +allt(_ef_kategorije_NIB.obj_name)+".Enabled = .T."
        &lcPostavljanje3
	ENDIF
	
ENDIF 
**** KRAJ MR 44169 - posebne ovlasti za kategorije entiteta
****************

****************
*21.08.2024 g_tomislav MID 52996
****************
IF loForm.txtEntiteta.Value == "POGODBA" THEN
lcId_cont = loForm.txtId_entitete.Value
select * from kategorije where sifra = 'NIB' into cursor _ef_kategorije_NIB	

lcPogodbaIdVrste = GF_SQLEXECScalarNull("SELECT id_vrste FROM dbo.pogodba WHERE id_cont = "+GF_Quotedstr(lcId_cont ))


	IF !GF_NULLOREMPTY(_ef_kategorije_NIB.id_kategorije_tip) and ALLT(lcPogodbaIdVrste) == "1481" THEN && for active entity
			
		lcPostavljanje1="loForm.Block_kategorije."+allt(_ef_kategorije_NIB.obj_name)+".Enabled = .T."
		&lcPostavljanje1
		lcPostavljanje2="loForm.Block_kategorije."+allt(_ef_kategorije_NIB.obj_name)+".obvezen = .T."
		&lcPostavljanje2
	ENDIF


	IF INLIST(lcPogodbaIdVrste , "1486", "1488") THEN
		lcPostavljanje3="loForm.Block_kategorije." +allt(_ef_kategorije_NIB.obj_name)+".Enabled = .T."
        &lcPostavljanje3
	ENDIF
	
ENDIF 
**** KRAJ MR 44169 - posebne ovlasti za kategorije entiteta
****************