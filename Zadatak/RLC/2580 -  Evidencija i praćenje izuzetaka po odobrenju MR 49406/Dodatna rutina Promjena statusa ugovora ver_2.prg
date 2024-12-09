** Promjena statusa na ugovorima
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


lcStatusOpomeneZaDokumentaciju = "OD"
lcNazivStatusaZaDokumentaciju = ALLT(GF_LOOKUP("statusi.naziv", lcStatusOpomeneZaDokumentaciju, "statusi.status"))

TEXT TO lcSql NOSHOW 		
	select pog.id_cont
		, dbo.gfn_GetContractDataHash(pog.id_cont) as pogodba_hash
		, par.naz_kr_kup
		, pog.id_pog
	from dbo.pogodba pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca 
	where pog.status_akt = 'A'
	and pog.status != {0}
	and pog.id_kupca = {1}
	--and pog.id_cont != {2} netreba isključivati trenutni
ENDTEXT 
lcSql = STRTRAN(lcSql, '{0}', GF_QuotedStr(lcStatusOpomeneZaDokumentaciju))
lcSql = STRTRAN(lcSql, '{1}', GF_QuotedStr(lcId_kupca))
GF_SQLEXEC(lcSql, "_dr_pogodba")

IF RECCOUNT("_dr_pogodba") = 0
	OBVESTI("Partner nema aktivnih ugovora u drugim statusima!")
	RETURN .F.
ENDIF

&& preveri in nastavi permission-e
IF GOBJ_Permissions.GetPermission('ActiveContractUpdate') < 2 THEN
	POZOR(STRTRAN(PERMISSION_DENIED, "{0}", "ActiveContractUpdate"))
	RETURN .F.
ELSE 
	IF POTRJENO("Da li želite promijeniti status ugovora na " +lcStatusOpomeneZaDokumentaciju +" " +lcNazivStatusaZaDokumentaciju +" na sve aktivne ugovore partnera" + SPACE(1) + ALLTRIM(_dr_pogodba.naz_kr_kup) + "?")  && nije potreban uvjet RECCOUNT("_dr_pogodba") > 0 izvrši samo ako ima kandidata za promjenu
		SELE _dr_pogodba

		lnUkupno=RECCOUNT()
		lnErrorCount = 0
		lnUspjesno = 0
		lcUgovoriUGresci = ""
		lcPoruka = ""          

		GO TOP
		SCAN		
			LOCAL lcXML
			* alternativa je GF_ChangeContractStatus je se ne može mijenjati Comment i sl.
			lcXML = ""
			lcXML = lcXML + "<?xml version='1.0' encoding='utf-8' ?>" + gcE
			lcXML = lcXML + '<rpg_contract_update xmlns="urn:gmi:nova:leasing">' + gcE
			lcXML = lcXML + '<common_parameters>'+ gcE
			lcXML = lcXML + GF_CreateNode("id_cont", _dr_pogodba.id_cont, "N", 1)+ gcE
			lcXML = lcXML + GF_CreateNode("comment", "Automatska promjena statusa ugovora dodatnom rutinom na posebnostima", "C", 1)+ gcE
			lcXML = lcXML + GF_CreateNode("hash_value", TRANS(_dr_pogodba.pogodba_hash), "C", 1)+ gcE
			lcXML = lcXML + GF_CreateNode("id_rep_category", "999", "C", 1)+ gcE
			lcXML = lcXML + GF_CreateNode("use_4eyes", .F., "L", 1)+ gcE
			lcXML = lcXML + '</common_parameters>'+ gcE 
			lcXML = lcXML + '<updated_values>'+ gcE
			lcXML = lcXML + GF_CreateNode("table_name", "POGODBA", "C", 1)+ gcE
			lcXML = lcXML + GF_CreateNode("name", "STATUS", "C", 1)+ gcE
			lcXML = lcXML + GF_CreateNode("updated_value", lcStatusOpomeneZaDokumentaciju, "C", 1)+ gcE
			lcXML = lcXML + '</updated_values>'+ gcE
			lcXML = lcXML + '</rpg_contract_update>'
	*obvesti(lcXml)
			WAIT WINDOW "Pripremam podatke (ugovor " +allt(_dr_pogodba.id_pog) +")" NOWAIT

			IF !GF_ProcessXml(lcXml) THEN
				*pozor("Greška u izvođenju promjene statusa za ugovor " +allt(_dr_pogodba.id_pog) +"!")
				lnErrorCount = lnErrorCount + 1
				lcUgovoriUGresci = lcUgovoriUGresci +allt(_dr_pogodba.id_pog) +gce
			ELSE 
				lnUspjesno = lnUspjesno + 1
			ENDIF
		ENDSCAN
		
		lcPoruka = "Rezultat promjena na ugovorima"+gce ;
					+"ukupno za promjenu: "+allt(trans(lnUkupno))+gce ;
					+"uspješno promijenjeno: "+allt(trans(lnUspjesno))+gce ;
					+"greške: "+allt(trans(lnErrorCount)) 
		
		OBVESTI(lcPoruka + IIF(lnErrorCount = 0, "", gce +"Greška u izvođenju je bila kod ugovora " +gce +lcUgovoriUGresci +gce +"Za ugovore u grešci možete ponovno pokrenuti rutinu da se napravi promjena statusa. U slučaju učestale greške pokušajte ponovno malo kasnije."))
	ENDIF
ENDIF

** Osvježavanje pregleda
loForm = GF_GetFormObject("frmPos_Pog_pregled")
loForm.runsql() 