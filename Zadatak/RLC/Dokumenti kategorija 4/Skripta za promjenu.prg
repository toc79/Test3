&& Prava za promjenu
select * from USERS_CUSTOM_FUNCS where [USERNAME] = 'g_tomislav'
INSERT INTO dbo.USERS_CUSTOM_FUNCS(func_id,username,type,keyid) VALUES(306,'g_tomislav','DocTypes','AK')
INSERT INTO dbo.USERS_CUSTOM_FUNCS(func_id,username,type,keyid) VALUES(306,'g_tomislav','DocTypes','BK')
INSERT INTO dbo.USERS_CUSTOM_FUNCS(func_id,username,type,keyid) VALUES(306,'g_tomislav','DocTypes','OP')
INSERT INTO dbo.USERS_CUSTOM_FUNCS(func_id,username,type,keyid) VALUES(306,'g_tomislav','DocTypes','PŽ')
&&
select d.id_cont, CAST(d.sys_ts as bigint) as cast_sys_ts, d.id_dokum 
from dokument d 
JOIN dbo._tmp_dokumenti b ON d.ID_DOKUM = b.id_dokum
WHERE  
(kategorija4 is null OR kategorija4 != 'A')
AND id_obl_zav in ('AK','BK','OP','PŽ')
&&
#INCLUDE locs.h

LOCAL lnUkupno, lnErrorCount

select rezultat
lnUkupno = RECCOUNT()
lnErrorCount = 0
go top
scan
	LOCAL lcXML

	lcXML = ""
	lcXML = lcXML + "<?xml version='1.0' encoding='utf-8' ?>" + gcE
	lcXML = lcXML + '<rpg_documentation_update_delete xmlns="urn:gmi:nova:leasing">' + gcE
	lcXML = lcXML + '<common_parameters>'+ gcE
	lcXML = lcXML + GF_CreateNode("id_cont", rezultat.id_cont, "N", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("comment", "Automatsko popunjavanje Kategorije 4 na dokumentu prema zahtjevu 1727 (MR 38009)", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("sys_ts", rezultat.cast_sys_ts, "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("id_dokum", rezultat.id_dokum, "N", 1)+ gcE
	lcXML = lcXML + '</common_parameters>'+ gcE
	lcXML = lcXML + GF_CreateNode("is_update", .T., "L", 1)+ gcE	
	lcXML = lcXML + '<updated_values>'+ gcE
	lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("name", "KATEGORIJA4", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("updated_value", "A", "C", 1)+ gcE
	lcXML = lcXML + '</updated_values>'+ gcE
	lcXML = lcXML + '<updated_values>'+ gcE
	lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("name", "POPRAVIL", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("updated_value", "g_system", "C", 1)+ gcE
	lcXML = lcXML + '</updated_values>'+ gcE
	lcXML = lcXML + '<updated_values>'+ gcE
	lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("name", "dat_poprave", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("updated_value", datetime(), "D", 1)+ gcE
	lcXML = lcXML + '</updated_values>'+ gcE
	lcXML = lcXML + '</rpg_documentation_update_delete>'

	IF !GF_ProcessXml(lcXml) THEN
		lnErrorCount=lnErrorCount+1 && možda nije potrebno, zato jer ako pukne zbog neodgovarjućih custom functionalitis prava, skripta se prekine
	ENDIF
endscan
=obvesti("Ukupno: "+allt(trans(lnUkupno))+". Greške: "+allt(trans(lnErrorCount)))

************
select * from reprogram where time>=getdate()-1 and [user] = 'g_tomislav'
UPDATE reprogram SET [user] = 'g_system' where time>=getdate()-1 and [user] = 'g_tomislav'

select * from USERS_CUSTOM_FUNCS where [USERNAME] = 'g_tomislav'

begin tran
DELETE FROM dbo.USERS_CUSTOM_FUNCS where [USERNAME] = 'g_tomislav'
--commit

DROP TABLE dbo._tmp_dokumenti

************

select * from DOKUMENT where dat_poprave > '20170517' AND popravil = 'g_system' AND (kategorija4 !='A' OR kategorija4 is null)
AK
BK
OP
PŽ

************
<?xml version='1.0' encoding='utf-8' ?><rpg_documentation_update_delete xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>8417</id_cont>
<comment></comment>
<sys_ts>3143610</sys_ts>
<id_dokum>44926</id_dokum>
</common_parameters>
<is_update>true</is_update>
<updated_values>
  <table_name>DOKUMENT</table_name>
  <name>KATEGORIJA4</name>
  <updated_value>001</updated_value>
</updated_values>
<updated_values>
<table_name>DOKUMENT</table_name>
<name>dat_poprave</name>
<updated_value>2017-05-08T14:00:57.000</updated_value>
</updated_values></rpg_documentation_update_delete>
************

#INCLUDE locs.h

IF !USED("Candidates") OR RECCOUNT("Candidates") = 0
	POZOR("Za odabrane ugovore ne postoje dokumenti za koje bi se popravili podatci")
	RETURN .F.
ENDIF

LOCAL lcXml, lcXmlResult, lcID


Sele Candidates
GO TOP

SCAN
	lcID = Candidates.id_dokum
	SELECT * FROM Candidates WHERE id_dokum = lcID INTO CURSOR _dok READWRITE
	
	SELECT _dok
	SELECT * FROM _dok INTO CURSOR _dok_copy
	
	SELECT _dok
	REPLACE ima WITH pattern, popravil WITH GOBJ_Comm.GetUserName(), dat_poprave WITH DATETIME()
	
	IF _dok.ima <> _dok_copy.ima 
		lcXmlDiff = GF_CreateUpdateDifFieldsXML('DOKUMENT', "_dok", "_dok_copy")
	ELSE
		RETURN .F.
	ENDIF
	
	lcXmlDiff = lcXmlDiff + '<updated_values>' + gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("name", "dat_poprave", "C", 1)+ gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("updated_value", DATETIME(), "T", 1)+ gcE
	lcXmlDiff = lcXmlDiff + '</updated_values>'+ gcE


	lcXML = "<?xml version='1.0' encoding='utf-8' ?>"+ gcE
	lcXML = lcXML + '<rpg_documentation_update_delete xmlns="urn:gmi:nova:leasing">' + gcE
	lcXML = lcXML + '<common_parameters>'+ gcE
	
	IF !GF_NULLOREMPTY(_dok.id_cont) THEN
		lcXML = lcXML + GF_CreateNode("id_cont", _dok.id_cont, "C", 1)+ gcE
	ENDIF
	IF !GF_NULLOREMPTY(_dok.id_kupca) THEN
		lcXML = lcXML + GF_CreateNode("id_kupca", _dok.id_kupca, "C", 1)+ gcE
	ENDIF

	lcXML = lcXML + GF_CreateNode("comment", _dok.opombe, "C", 1)+ gcE
	IF !GF_NULLOREMPTY(_dok.sys_ts) THEN
		lcXML = lcXML + GF_CreateNode("sys_ts", _dok.sys_ts, "I", 1) + gcE
	ENDIF
	IF !GF_NULLOREMPTY(_dok.id_dokum) THEN
		lcXML = lcXML + GF_CreateNode("id_dokum", _dok.id_dokum, "N", 1) + gcE
	ENDIF
	
	lcXML = lcXML + '</common_parameters>'+ gcE
	
	lcXML = lcXML + GF_CreateNode("is_update", .T., "L", 1) + gcE

	lcXML = lcXML + lcXmlDiff
	lcXML = lcXML + "</rpg_documentation_update_delete>"

	GF_ProcessXml(lcXml, .T., .T.)
	
	USE IN _dok
	USE IN _dok_copy	
ENDSCAN

OBVESTI("Obrada je uspješno dovršena!")

loForm = GF_GetFormObject("frmPripDok")
loForm.Release
