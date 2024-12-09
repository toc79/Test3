&& ovo nazoves rezultat u sql query-ju

&&OVO JE SAD DIO KOJI RADIŠ KROZ PROGRAM***************
&&sql dio, vidi:gore, ZA OVO MORAŠ KOD NJIH NAPRAVITI TABELU _POG_FIX_DEL U KOJU ÆEŠ NAPUNITI PODATE O ID_CONT I NOVOM FIX_DEL
--select * from _tmp_izvedeni --2343 zapisa
select a.id_pog, a.ID_RTIP new_id_rtip, dbo.gfn_Id_cont4Id_pog(a.id_pog) as id_cont_izvedeni, '20150101' as new_rind_datum, p.RIND_ZADNJI, p.RIND_DATUM, p.id_rtip id_rtip,  p.id_cont, dbo.gfn_GetContractDataHash(p.id_cont) as pogodba_hash
from _tmp_izvedeni a
join pogodba p on  dbo.gfn_Id_cont4Id_pog(a.id_pog) = p.ID_CONT
 order by p.ID_CONT --p.RIND_DATUM 
*********************************************************************************************************
&&FOX dio, tamo stavi da se dobiveni cursor zove rezultat (result alias)
#include locs.h
sele rezultat
go top
scan
local lcpogodba_hash, lcId_rtip, lcRind_datum, lnid_cont, lcOpomba, lcid_category, lcXML, tcXMLStrDobr

lcpogodba_hash = rezultat.pogodba_hash
lcId_rtip = rezultat.new_id_rtip
lcRind_datum = gstod(rezultat.new_rind_datum)
*Promjena datuma: koristiti gstod
*lcdatum_odob_new=gstod(rezultat.datum_odob_new) 
*dok kod DATETIME polja NE treba (onda samo npr. lcdat_1op=rezultat.dat_1op). IF izgleda ovako 
*IF 	rezultat.dat_1op != gstod(_pogodba_copy.dat_1op) 
*ukoliko ima potrebe

lnid_cont=rezultat.id_cont
	&&staviti napomenu koju trebas
lcOpomba="Promjena prema zahtjevu 1535 (MID 35236)"
	&&kategorija je ostalo 000 ili 999
lcid_category="000"

GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

	&&ovaj dio program uvijek izvršava a ti vidi da li æeš i ti
	&&IF _pogodba.rind_tgor != _pogodba.rind_tdol THEN
	&& REPLACE rind_tdol WITH rind_tgor IN _pogodba
	&&ENDIF
replace id_rtip with lcId_rtip in _pogodba
replace Rind_datum with lcRind_datum in _pogodba

	tcXMLStrDobr = "" && XML for fictive cost; dodano u 2.19, obrisano u 2.20 i 2.21
*2.19
*lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", tcXMLStrDobr)

* 2.20.10
*lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", "", .t.)

*2.20 i 2.21
*lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")  & 7 parametar je * tbFourEyes - set use_4eyes depends on form check; .f. znaèi da nema provjere 4 oka
	
* NE lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")
*lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", "", .t.) && DA 2.20.10
lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy") && DA 2.20.11

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