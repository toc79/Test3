** Dodavanje dokumenata na ugovore 
** 09.03.2023 g_tomislav MID 49406 - created
#include locs.h  && potrebno za prikaz poruke oko premissiona

lcId_kupca = pog_pos.id_kupca
*lnId_cont = pog_pos.id_cont

IF GF_NULLOREMPTY(lcId_kupca)
	llPcdId_kupcaEnabled = GF_PCDDESC('_PCDPARAMETER','PARNAME','PARCONT','ENABLED','PAR','PARVALUE','L')
	IF llPcdId_kupcaEnabled
		lcId_kupca = GF_PCDDESC('_PCDPARAMETER','PARNAME','PARCONT','PARTNER','PAR','PARVALUE','C')
	ENDIF
ENDIF

IF GF_NULLOREMPTY(lcId_kupca)  && AND GF_NULLOREMPTY(lnId_cont)
	OBVESTI("Nema podataka partnera!")
	RETURN .F.
ENDIF


lcId_obl_zavNemaInterkalarnih = "NI"
lcNazivDokNemaInterkalarnih = ALLT(GF_LOOKUP("dok.opis", lcId_obl_zavNemaInterkalarnih, "dok.id_obl_zav"))

TEXT TO lcSql NOSHOW 		
	select pog.id_cont
		, dbo.gfn_GetContractDataHash(pog.id_cont) as pogodba_hash
		, par.naz_kr_kup
		, pog.id_pog
	from dbo.pogodba pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca 
	where pog.status_akt = 'A'
	and not exists (select * from dbo.dokument where id_obl_zav = {0} and id_cont = pog.id_cont)
	and pog.id_kupca = {1}
ENDTEXT 
lcSql = STRTRAN(lcSql, '{0}', GF_QuotedStr(lcId_obl_zavNemaInterkalarnih))
lcSql = STRTRAN(lcSql, '{1}', GF_QuotedStr(lcId_kupca))
GF_SQLEXEC(lcSql, "_dr_pogodba")

IF RECCOUNT("_dr_pogodba") = 0
	OBVESTI("Partner nema aktivnih ugovora bez dokumenta " +lcId_obl_zavNemaInterkalarnih +" " +lcNazivDokNemaInterkalarnih +"!")
	RETURN .F.
ENDIF

&& preveri in nastavi permission-e
IF GOBJ_Permissions.GetPermission('ContractDocumentationInsert') < 2 THEN
	POZOR(STRTRAN(PERMISSION_DENIED, "{0}", "ContractDocumentationInsert"))
	RETURN .F.
ELSE 
	IF POTRJENO("Da li želite kreirati dokument " +lcId_obl_zavNemaInterkalarnih +" " +lcNazivDokNemaInterkalarnih +" na sve aktivne ugovore partnera" + SPACE(1) + ALLTRIM(_dr_pogodba.naz_kr_kup) + "?")  && nije potreban uvjet RECCOUNT("_dr_pogodba") > 0 izvrši samo ako ima kandidata za promjenu
		
		SELE _dr_pogodba

		lnUkupno=RECCOUNT()
		lnErrorCount = 0
		lnUspjesno = 0
		lcUgovoriUGresci = ""
		lcPoruka = ""          

		GO TOP
		SCAN			
			LOCAL lcXML
			TEXT TO lcSql NOSHOW
				declare @today datetime = dbo.gfn_getDatePart(getdate())
				select '<insert_update_dokument xmlns="urn:gmi:nova:leasing"><dokument>'
					+'<dat_poprave>'+CONVERT(varchar(30), getdate(), 126)+'</dat_poprave>'
					+'<datum>'+CONVERT(varchar(30), dateadd(dd, dok.dni_zap, @today), 126)+'</datum>'
					+'<datum_dok>'+CONVERT(varchar(30), @today, 126)+'</datum_dok>'
					+'<dok_in_safe>false</dok_in_safe>'
					+'<id_cont>{0}</id_cont>'
					+'<id_obl_zav>'+dok.id_obl_zav+'</id_obl_zav>'
					+'<id_zapo></id_zapo><ima>false</ima><is_elligible>false</is_elligible><kolicina>1</kolicina>'
					+'<opis>'+ltrim(rtrim(dok.opis))+'</opis>'
					+'<opis1></opis1><opombe></opombe><opravi_sam>2</opravi_sam>'
					+'<popravil>{1}</popravil>'
					+'<potrebno>true</potrebno><rang_hipo>1</rang_hipo><reg_stev></reg_stev><st_nalepke></st_nalepke><st_vink></st_vink><status_akt>A</status_akt><status_zk></status_zk><stevilka></stevilka><tip_cen></tip_cen>'
					+'<vnesel>{1}</vnesel>'
					+'<vrednost>0</vrednost><vrst_red_d></vrst_red_d><vrsta></vrsta>'
					+'<zav_je_on>false</zav_je_on></dokument></insert_update_dokument>'
				from dbo.dok 
				where id_obl_zav = {3}
			ENDTEXT
			lcSql = STRTRAN(lcSql, "{0}", ALLT(STR(_dr_pogodba.id_cont)))
			lcSql = STRTRAN(lcSql, "{1}", ALLT(GObj_Comm.getUserName()))
			lcSql = STRTRAN(lcSql, "{3}", GF_QuotedStr(lcId_obl_zavNemaInterkalarnih))
			
			lcXML = GF_SQLEXECScalar(lcSql)
			
			WAIT WINDOW "Pripremam podatke (ugovor " +allt(_dr_pogodba.id_pog) +")" NOWAIT
			
			lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)
			
			IF TYPE("lcXmlResult") != "C" THEN  && !GF_ProcessXml(lcXml) THEN
				*pozor("Greška u izvođenju promjene statusa za ugovor " +allt(_dr_pogodba.id_pog) +"!")
				lnErrorCount = lnErrorCount + 1
				lcUgovoriUGresci = lcUgovoriUGresci +allt(_dr_pogodba.id_pog) +gce
			ELSE 
				lnUspjesno = lnUspjesno + 1
			ENDIF
		ENDSCAN
		
		lcPoruka = "Rezultat promjena na dokumentima"+gce ;
					+"ukupno za dodati: "+allt(trans(lnUkupno))+gce ;
					+"uspješno dodano: "+allt(trans(lnUspjesno))+gce ;
					+"greške: "+allt(trans(lnErrorCount)) 
		
		OBVESTI(lcPoruka + IIF(lnErrorCount = 0, "", gce +"Greška u izvođenju je bila kod ugovora " +gce +lcUgovoriUGresci +gce +"Za ugovore u grešci možete ponovno pokrenuti rutinu da se napravi dodavanje dokumenta. U slučaju učestale greške pokušajte ponovno malo kasnije."))
	ENDIF
ENDIF

*Osvježavanje 
loForm = GF_GetFormObject("frmPos_Pog_pregled")
loForm.runsql() 