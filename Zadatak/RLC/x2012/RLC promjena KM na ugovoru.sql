select id_pog,id_cont, 16666 as dovol_km, dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash from pogodba where id_cont=42863

*********************************************************************************************************
&&FOX dio, tamo stavi da se dobiveni cursor zove rezultat (result alias)
#include locs.h
sele rezultat
go top
scan
local lcpogodba_hash, lcdovol_km, lnid_cont, lcOpomba, lcid_category, lcXML

lcpogodba_hash=rezultat.pogodba_hash
lcdovol_km=rezultat.dovol_km
lnid_cont=rezultat.id_cont
	&&staviti napomenu koju trebas
lcOpomba="Promjena je napravljena sukladno zahtjevu br. 955"
	&&kategorija je ostalo 000
lcid_category="000"

GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

replace dovol_km with lcdovol_km in _pogodba

lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")

&& ako je lcXML prazan ne šalji poziv ništa se nije promjenilo, nisu poslali novi fix_del
IF LEN(ALLTRIM(lcXml)) > 0 THEN
	IF GF_ProcessXML(lcXML) THEN
		&&=obvesti("OK za ugovor: " + allt(trans(lnid_cont)))
	ELSE
	obvesti("NOT OK za ugovor:" + allt(trans(lnid_cont)))
	ENDIF
ELSE
=obvesti("Za ugovor: "+ allt(trans(lnid_cont)) + ". Nisu definirali nove uvjete")
ENDIF

use in _pogodba
use in _pogodba_copy
endscan

obvesti("Postupak je završio")
----
select * from reprogram where time>=getdate()-1 and [user] = 'g_tomislav'
UPDATE reprogram SET [user] = 'g_system' where time>=getdate()-1 and [user] = 'g_tomislav'