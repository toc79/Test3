Select id_cont, dovol_km,40000 as novi_dovol_km, dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash from pogodba where id_cont=43756
**************************************

&&FOX dio, tamo stavi da se dobiveni cursor zove rezultat (result alias)
#include locs.h
sele rezultat
go top
scan
local lcpogodba_hash, lcdovolKM, lnid_cont, lcOpomba, lcid_category, lcXML

lcpogodba_hash=rezultat.pogodba_hash
lcdovolKM=rezultat.novi_dovol_km
lnid_cont=rezultat.id_cont
	&&staviti napomenu koju trebas
lcOpomba="Promjena podataka prema zahtjevu br. 24329"
	&&kategorija je ostalo 000
lcid_category="000"

GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

	&&ovaj dio program uvijek izvršava a ti vidi da li ćeš i ti
	&&IF _pogodba.rind_tgor != _pogodba.rind_tdol THEN
	&& REPLACE rind_tdol WITH rind_tgor IN _pogodba
	&&ENDIF
replace dovol_km with lcdovolKM in _pogodba

lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")

&& ako je lcXML prazan ne šalji poziv ništa se nije promjenilo, nisu poslali novi fix_del
IF LEN(ALLTRIM(lcXml)) > 0 THEN
IF GF_ProcessXML(lcXML) THEN
&&=obvesti("OK za ugovor: " + allt(trans(lnid_cont)))
ELSE
=obvesti("NOT OK za ugovor:" + allt(trans(lnid_cont)))
ENDIF
ELSE
=obvesti("Za ugovor: "+ allt(trans(lnid_cont)) + ". Nisu definirali nove uvjete")
ENDIF
use in _pogodba
use in _pogodba_copy
endscan

=obvesti("Postupak je završio")

----
select * from reprogram where time>=getdate()-1 and [user] = 'g_tomislav'
UPDATE reprogram SET [user] = 'g_system' where time>=getdate()-1 and [user] = 'g_tomislav'