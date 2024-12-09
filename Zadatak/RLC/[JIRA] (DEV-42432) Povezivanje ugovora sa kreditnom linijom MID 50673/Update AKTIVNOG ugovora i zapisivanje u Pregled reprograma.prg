
select * from rep_category

&& ovo nazoves rezultat u sql query-ju
--550 zapisa
select pog.id_cont, REFINANC, refinanc_new
from dbo.pogodba pog
left join dbo._ugovori_refinanc_50673 ur on pog.id_cont = ur.id_cont
where ur.id_cont is not null
and isnull(REFINANC, '') != refinanc_new

*********************************************************************************************************
&&FOX dio, tamo stavi da se dobiveni cursor zove rezultat (result alias)
#include locs.h

LOCAL lnErrorCount, lnUkupno, lnNepromjenjeni

SELE rezultat
lnUkupno = RECCOUNT()
lnErrorCount = 0
lnNepromjenjeni = 0
GO TOP
SCAN
	local lcpogodba_hash, lcNovaVrijednost, lnid_cont, lcOpomba, lcid_category, lcXML, tcXMLStrDobr

	*lcpogodba_hash=rezultat.pogodba_hash
	lcpogodba_hash= GF_SQLEXECScalar("Select dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash from dbo.pogodba where id_cont = " +allt(str(rezultat.id_cont)))
	
	lcNovaVrijednost=rezultat.refinanc_new
	*Promjena datuma: koristiti gstod
	*lcdatum_odob_new=gstod(rezultat.datum_odob_new) 
	*dok kod DATETIME polja NE treba (onda samo npr. lcdat_1op=rezultat.dat_1op). 
	* IF izgleda ovako kada nije datetime
	*IF 	rezultat.neki_datum != gstod(_pogodba_copy.neki_datum) 
	*ukoliko ima potrebe

	lnid_cont=rezultat.id_cont
		&&staviti napomenu koju trebas
	lcOpomba="Promjena podataka prema zahtjevu DEV-42432 (MID 50673)"
		&&kategorija je ostalo 000 ili 999 
	lcid_category="999"

	GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
	GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

		&&ovaj dio program uvijek izvršava a ti vidi da li æeš i ti
		&&IF _pogodba.rind_tgor != _pogodba.rind_tdol THEN
		&& REPLACE rind_tdol WITH rind_tgor IN _pogodba
		&&ENDIF
	replace REFINANC with lcNovaVrijednost in _pogodba

	*tcXMLStrDobr = "" && XML for fictive cost; dodano u 2.19, obrisano u 2.20 i 2.21
	*2.19
	*lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", tcXMLStrDobr)
	* 2.20.10
	*lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", "", .t.)
	*2.20 i 2.21
	lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")  && 7 parametar je * tbFourEyes - set use_4eyes depends on form check; .f. znaèi da nema provjere 4 oka

	&& ako je lcXML prazan ne šalji poziv ništa se nije promjenilo, nisu poslali novi fix_del
	IF LEN(ALLTRIM(lcXml)) > 0 THEN
		IF GF_ProcessXML(lcXML) THEN
			&&=obvesti("OK za ugovor: " + allt(trans(lnid_cont)))
		ELSE
			lnErrorCount = lnErrorCount + 1 &&=obvesti("NOT OK za ugovor:" + allt(trans(lnid_cont)))
		ENDIF
	ELSE
		lnNepromjenjeni = lnNepromjenjeni + 1  &&=obvesti("Za ugovor: "+ allt(trans(lnid_cont)) + ". Nisu definirali nove uvjete")
	ENDIF
		use in _pogodba
		use in _pogodba_copy
ENDSCAN
=obvesti("Ukupno: "+allt(trans(lnUkupno))+". Greške: "+allt(trans(lnErrorCount))+". Nepromijenjeni: "+allt(trans(lnNepromjenjeni)))

----
select * from reprogram where time>=getdate()-1 and [user] = 'g_tomislav'
UPDATE reprogram SET [user] = 'g_system' where time>=getdate()-1 and [user] = 'g_tomislav'