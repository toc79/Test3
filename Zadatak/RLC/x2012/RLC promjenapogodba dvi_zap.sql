&& ovo nazoves rezultat u sql query-ju

&&OVO JE SAD DIO KOJI RADIŠ KROZ PROGRAM***************
&&sql dio, vidi:gore, ZA OVO MORAŠ KOD NJIH NAPRAVITI TABELU _POG_FIX_DEL U KOJU ÆEŠ NAPUNITI PODATE O ID_CONT I NOVOM FIX_DEL

/*CREATE TABLE dbo._pog_spl_pog
( 	id_cont INTEGER NOT NULL
	spl_pog CHAR(5) NOT NULL
) ON [PRIMARY]*/

select id_pog,id_cont, 60 as dni_zap_new, dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash from pogodba where id_cont=

*********************************************************************************************************
&&FOX dio, tamo stavi da se dobiveni cursor zove rezultat (result alias)
#include locs.h
sele rezultat
go top
scan
local lcpogodba_hash, lcuvjeti, lnid_cont, lcOpomba, lcid_category, lcXML

lcpogodba_hash=rezultat.pogodba_hash
lcuvjeti=rezultat.dni_zap_new
lnid_cont=rezultat.id_cont
	&&staviti napomenu koju trebas
lcOpomba="Promjena je napravljena prema zahtjevu br. 959"
	&&kategorija je ostalo 000
lcid_category="000"

GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

	&&ovaj dio program uvijek izvršava a ti vidi da li æeš i ti
	&&IF _pogodba.rind_tgor != _pogodba.rind_tdol THEN
	&& REPLACE rind_tdol WITH rind_tgor IN _pogodba
	&&ENDIF
replace dni_zap with lcuvjeti in _pogodba

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