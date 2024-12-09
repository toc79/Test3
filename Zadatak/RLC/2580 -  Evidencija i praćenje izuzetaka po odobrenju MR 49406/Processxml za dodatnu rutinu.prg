** 09.03.2023 g_tomislav MID 49406 - created
#include locs.h  && potrebno za prikaz poruke oko premissiona

lcId_kupca = pog_pos.id_kupca
lnId_cont = pog_pos.id_cont

llPcdId_kupcaEnabled = GF_PCDDESC('_PCDPARAMETER','PARNAME','PARCONT','ENABLED','PAR','PARVALUE','L')
lcPcdId_kupca = GF_PCDDESC('_PCDPARAMETER','PARNAME','PARCONT','PARTNER','PAR','PARVALUE','C')

IF GF_NULLOREMPTY(lcId_kupca) OR GF_NULLOREMPTY(lnId_cont) OR ! llPcdId_kupcaEnabled 
	OBVESTI("Nema podataka!")
	RETURN .F.
ENDIF


lcStatusOpomeneZaDokumentaciju = "OD"
lcNazivStatusaZaDokumentaciju = ALLT(GF_LOOKUP("statusi.naziv", lcStatusOpomeneZaDokumentaciju, "statusi.status"))

TEXT TO lcSql NOSHOW 		
	select pog.id_cont
		, dbo.gfn_GetContractDataHash(pog.id_cont) as pogodba_hash
		, par.naz_kr_kup
		, p.id_pog
	from dbo.pogodba pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca 
	where pog.status_akt = 'A'
	and pog.status != {0}
	and pog.id_kupca = {1}
	--and pog.id_cont != {2} netreba isključivati trenutni
ENDTEXT 
lcSql = STRTRAN(lcSql, '{0}', GF_QuotedStr(lcStatusOpomeneZaDokumentaciju))
lcSql = STRTRAN(lcSql, '{1}', GF_QuotedStr(NVL(lcId_kupca, lcPcdId_kupca)))

GF_SQLEXEC(lcSql, "_dr_pogodba")

IF RECCOUNT("_dr_pogodba") = 0
	OBVESTI("Partner nema aktivnih ugovora u drugim statusima!")
	RETURN .F.
ENDIF

* IF thisform.check4eye THEN
lnUpdCount = GF_SQLExecScalarNull( "SELECT * FROM dbo.pog_pos_upd WHERE id_cont = " + allt(str(lnId_cont)) + " and obdelan=0" )
IF lnUpdCount > 0 THEN
	POZOR("Ugovor ima još nepotvrđene promijenjene posebnosti (princip četiri oka)." )
	RETURN .F.
ENDIF
*ENDIF

&& preveri in nastavi permission-e
IF GOBJ_Permissions.GetPermission('ActiveContractUpdate') < 2 THEN
	POZOR(STRTRAN(PERMISSION_DENIED, "{0}", "ActiveContractUpdate"))
	RETURN .F.
ELSE 
	IF POTRJENO("Da li želite promijeniti status ugovora na " +lcStatusOpomeneZaDokumentaciju +" " +lcNazivStatusaZaDokumentaciju +" na sve aktivne ugovore partnera" + SPACE(1) + ALLTRIM(_dr_pogodba.naz_kr_kup) + "?")  && nije potreban uvjet RECCOUNT("_dr_pogodba") > 0 izvrši samo ako ima kandidata za promjenu
		SELE _dr_pogodba

		lnUkupno=RECCOUNT()
		lnErrorCount=0
		lnUspjesno=0
		lcUgovoriUGresci=""
		lcPoruka=""          

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
				pozor("Greška u izvođenju promjene statusa za ugovor " +allt(_dr_pogodba.id_pog) +"!")
				lnErrorCount = lnErrorCount + 1
				lcUgovoriUGresci = lcUgovoriUGresci +allt(_dr_pogodba.id_pog) +gce
			ELSE 
				lnUspjesno = lnUspjesno + 1
			ENDIF
		ENDSCAN
		
		lcPoruka = "Rezultat promjena na ugovorima" +gce ;
					+"ukupno za promjenu: "+allt(trans(lnUkupno)) +gce ;
					+"uspješno promijenjeno: "+allt(trans(lnUspjesno)) +gce ;
					+"greške: "+allt(trans(lnErrorCount)) 
		OBVESTI(lcPoruka)
		
		IF lnErrorCount > 0
			OBVESTI("Za ugovore u grešci možete ponovno pokrenuti rutinu da se napravi promjena statusa. U slučaju učestale greške pokušajte ponovno malo kasnije. ")
		ENDIF
	ENDIF
ENDIF







	TEXT TO lcSql NOSHOW 
		SELECT COUNT(*) as stev
	  	FROM dbo.pogodba
	 	WHERE status_akt = 'A' AND id_kupca = '{0}'
	ENDTEXT 
	lcSql = STRTRAN(lcSql , "{0}", &lcCursor..id_kupca)
	lnCount = GF_SQLExecScalarNull(lcSql)

	IF ISNULL(lnCount) OR lnCount = 0 THEN
		Obvesti("Partner nima več aktivnih pogodb")
	ELSE
		
		IF thisform.check4eye THEN
			lnUpdCount = GF_SQLExecScalarNull( "SELECT * FROM dbo.pog_pos_upd WHERE id_cont = " + TRANSFORM(&lcCursor..id_cont) + " and obdelan=0" )
			IF lnUpdCount > 0 THEN
				pozor( "Pogodba ima še nepotrjene spremenjene posebnosti." )
				RETURN .F.
			ENDIF
		ENDIF
		
		&& preveri in nastavi permission-e
		IF GOBJ_Permissions.GetPermission('PosPogInsertUpdate') < 2 THEN
			pozor(STRTRAN(PERMISSION_DENIED, "{0}", "PosPogInsertUpdate"))
			RETURN .F.
		ELSE 
			IF potrjeno("Ali želite prenesti posebnosti na vse aktivne pogodbe partnerja" + SPACE(1) + ALLTRIM(&lcCursor..naz_kr_kup) + "?") &&caption 
				DO FORM pos_pog_kopiraj WITH &lcCursor..id_kupca, &lcCursor..id_cont
				thisform.runsql
			ENDIF
		ENDIF  
	ENDIF 	



<?xml version='1.0' encoding='utf-8' ?><rpg_contract_update xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>62933</id_cont>
<comment>test</comment>
<hash_value>1316832242</hash_value>
<id_rep_category>999</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>OPOMBE</name>
  <updated_value>test</updated_value>
</updated_values>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>KK_MEMO</name>
  <updated_value></updated_value>
</updated_values>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>SF_FREE_PERIOD</name>
  <is_null>true</is_null>
</updated_values>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>SF_OFFSET</name>
  <is_null>true</is_null>
</updated_values>
</rpg_contract_update>