{74e4fa6e-f3cb-445c-942c-d8752487a5f6}
************
<?xml version='1.0' encoding='utf-8' ?><rpg_contract_update xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>2222</id_cont>
<comment>Objapšnjenje promjena GMC test</comment>
<hash_value>90703162</hash_value>
<id_rep_category>999</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>RIND_DAT_NEXT</name>
  <updated_value>2021-06-30T00:00:00.000</updated_value>
</updated_values>
</rpg_contract_update>
************
-- 28.09.2020 g_tomislav MR 45222

--Zadnji radni dan u mjesecu
declare @id_rind_strategije int = (select top 1 id_rind_strategije from dbo.rind_strategije where odmik = 0 and working_days = 0 order by id_rind_strategije)

select 
'<?xml version=''1.0'' encoding=''utf-8'' ?><rpg_contract_update xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>'+cast(pog.id_cont as varchar)+'</id_cont>
<comment>Automatska promjena datuma sljedećeg reprograma</comment>
<hash_value>'+cast(dbo.gfn_GetContractDataHash(pog.id_cont) as varchar)+'</hash_value>
<id_rep_category>999</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>RIND_DAT_NEXT</name>
  <updated_value>'+CONVERT(varchar, pog.Izracunati_rind_dat_next, 126)+'.000</updated_value>
</updated_values>
</rpg_contract_update>
' as lcXml
--, *
from (
	select pog.id_cont, pog.rind_dat_next, dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(pog.rind_dat_next)) as Izracunati_rind_dat_next
	from dbo.pogodba pog
	where pog.id_rind_strategije = @id_rind_strategije
	and status_akt = 'A'
) pog
where pog.rind_dat_next != Izracunati_rind_dat_next
order by pog.id_cont 

left join dbo.pog_pos as ps on pog.ID_CONT = ps.ID_CONT 
-- AND ps.KNJIZENJE is null  
-- AND (ps.rep_spr_ind is null or ps.rep_spr_ind < dbo.gfn_getdatepart(GETDATE()))  



select 
'<?xml version=''1.0'' encoding=''utf-8'' ?><rpg_contract_update xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>'+cast(pog.id_cont as varchar)+'</id_cont>
<comment>Automatska promjena datuma sljedećeg reprograma</comment>
<hash_value>'+cast(dbo.gfn_GetContractDataHash(id_cont) as varchar)+'</hash_value>
<id_rep_category>000</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>RIND_DAT_NEXT</name>
  <updated_value>'+CONVERT(varchar, dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(pog.rind_dat_next)), 126)+'.000</updated_value>
</updated_values>
</rpg_contract_update>
' as lcXml
	, rind_dat_next
	, dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(pog.rind_dat_next)) as zadnjiRadnoDanUMjesecu
	, CONVERT(varchar, dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(pog.rind_dat_next)), 126)
	, * 
from dbo.pogodba pog
left join dbo.pog_pos as ps on pog.ID_CONT = ps.ID_CONT 
where exists (select id_rind_strategije from dbo.rind_strategije where odmik = 0 and working_days = 0 and id_rind_strategije = pog.id_rind_strategije)
and status_akt = 'A'
and rind_dat_next != dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(pog.rind_dat_next))
-- AND ps.KNJIZENJE is null  
-- AND (ps.rep_spr_ind is null or ps.rep_spr_ind < dbo.gfn_getdatepart(GETDATE()))  

--za test
lcXml= _tmp.lcXml
IF !GF_ProcessXML(lcXml)
lcText = 'Greška'
else 
lcText = 'Kraj'
endif
obvesti(lcText)

Select id_cont, '01000' as novi_opci_uvjeti, dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash from pogodba where dat_sklen>='20100101'
select * from rep_category
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

	lcpogodba_hash=rezultat.pogodba_hash
	lcNovaVrijednost=rezultat.rind_zadnji_new
	*Promjena datuma: koristiti gstod
	*lcdatum_odob_new=gstod(rezultat.datum_odob_new) 
	*dok kod DATETIME polja NE treba (onda samo npr. lcdat_1op=rezultat.dat_1op). IF izgleda ovako 
	*IF 	rezultat.dat_1op != gstod(_pogodba_copy.dat_1op) 
	*ukoliko ima potrebe

	lnid_cont=rezultat.id_cont
		&&staviti napomenu koju trebas
	lcOpomba="Prema zahtjevu ....."
		&&kategorija je ostalo 000 ili 999 
	lcid_category="000"

	GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
	GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

		&&ovaj dio program uvijek izvršava a ti vidi da li ćeš i ti
		&&IF _pogodba.rind_tgor != _pogodba.rind_tdol THEN
		&& REPLACE rind_tdol WITH rind_tgor IN _pogodba
		&&ENDIF
	replace RIND_DATUM with lcNovaVrijednost in _pogodba

		tcXMLStrDobr = "" && XML for fictive cost; dodano u 2.19, obrisano u 2.20 i 2.21
	*2.19
	*lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", tcXMLStrDobr)
	* 2.20.10
	*lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", "", .t.)
	*2.20 i 2.21
	lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")  && 7 parametar je * tbFourEyes - set use_4eyes depends on form check; .f. znači da nema provjere 4 oka

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