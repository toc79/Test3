&& ovo nazoves rezultat u sql query-ju

&&OVO JE SAD DIO KOJI RADIŠ KROZ PROGRAM***************
&&sql dio, vidi:gore, ZA OVO MORAŠ KOD NJIH NAPRAVITI TABELU _POG_FIX_DEL U KOJU ÆEŠ NAPUNITI PODATE O ID_CONT I NOVOM FIX_DEL
select p.ID_CONT, p.id_pog, p.id_kupca, p.nacin_leas, p.ID_RTIP, p.RIND_ZADNJI  , p.RIND_DATUM, d.id_rtip as new_id_rtip, '20150101' as new_rind_datum, dbo.gfn_GetContractDataHash(p.id_cont) as pogodba_hash
from pogodba p
join rtip a on p.ID_RTIP = a.id_rtip
join OBDOBJA b on a.id_obdrep=b.id_obd
join RTIP d on a.id_rtip= d.id_rtip_base
join (
	select id_cont, COUNT(*) broj_rata from PLANP 
	WHERE ID_TERJ='21' AND EVIDENT != '*'
	group by ID_CONT HAVING COUNT(*) > 3
) c on p.ID_CONT=c.id_cont
WHERE
 a.id_tiprep = 2 AND a.id_rtip_base is null
 AND dbo.gfn_Nacin_leas_HR(p.NACIN_LEAS)= 'OL' 
 AND STATUS_AKT='A'
 --AND RIND_ZADNJI < 0
  --PROVJERE
 --AND d.id_rtip is not null 
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
lcOpomba="Promjena prema zahtjevu 1535 (MID 34427)"
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

	tcXMLStrDobr = "" && XML for fictive cost; dodano u 2.19
* lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", tcXMLStrDobr)
lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", "", .t.)

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