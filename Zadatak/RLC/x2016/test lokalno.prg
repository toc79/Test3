<?xml version='1.0' encoding='utf-8' ?><rpg_contract_update xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>52</id_cont>
<comment>f wefwe</comment>
<hash_value>1311598466</hash_value>
<id_rep_category>000</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>ID_RTIP</name>
  <updated_value>3E</updated_value>
</updated_values>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>RIND_DATUM</name>
  <updated_value>2009-01-09T00:00:00.000</updated_value>
</updated_values>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>ID_RIND_STRATEGIJE</name>
  <is_null>true</is_null>
</updated_values>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>RIND_DAT_NEXT</name>
  <is_null>true</is_null>
</updated_values>
</rpg_contract_update>

2.2009-01-09T00************
<?xml version='1.0' encoding='utf-8' ?><rpg_contract_update xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>52027</id_cont>
<comment>fsd fwe fwe</comment>
<hash_value>1446612679</hash_value>
<id_rep_category>000</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>ID_RTIP</name>
  <updated_value>EUR62</updated_value>
</updated_values>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>RIND_DATUM</name>
  <updated_value>2015-01-01T00:00:00.000</updated_value>
</updated_values>
<updated_values>
  <table_name>POGODBA</table_name>
  <name>KK_MEMO</name>
  <updated_value></updated_value>
</updated_values>
</rpg_contract_update>
************

select top 5 p.ID_CONT, p.id_pog, p.id_kupca, p.nacin_leas, p.ID_RTIP, p.RIND_ZADNJI  , p.RIND_DATUM, 'EUR34' as new_id_rtip, getdate() as new_rind_zadnji, dbo.gfn_GetContractDataHash(p.id_cont) as pogodba_hash
from pogodba p
join rtip a on p.ID_RTIP = a.id_rtip
join OBDOBJA b on a.id_obdrep=b.id_obd
--join RTIP d on a.id_rtip= d.id_rtip_base
join (
	select id_cont, COUNT(*) broj_rata from PLANP 
	WHERE ID_TERJ='21' AND DATUM_DOK>GETDATE() AND EVIDENT != '*'
	group by ID_CONT HAVING COUNT(*) >= 3
) c on p.ID_CONT=c.id_cont
WHERE
-- a.id_tiprep = 2 AND a.id_rtip_base is null
 --AND 
 dbo.gfn_Nacin_leas_HR(p.NACIN_LEAS)= 'OL' 
 AND STATUS_AKT='A'
 --AND RIND_ZADNJI < 0
  --PROVJERE
 --AND d.id_rtip is not null 
 order by p.ID_CONT --p.RIND_DATUM 
 
 #include locs.h
sele rezultat
go top
scan
local lcpogodba_hash, lcId_rtip, lcRind_zadnji, lnid_cont, lcOpomba, lcid_category, lcXML, tcXMLStrDobr

lcpogodba_hash = rezultat.pogodba_hash
lcId_rtip = rezultat.new_id_rtip
lcRind_zadnji = gstod(rezultat.new_rind_zadnji)

lnid_cont=rezultat.id_cont
	&&staviti napomenu koju trebas
lcOpomba = "Promjena prema zahtjevu 1535 (MID 34427)"
	&&kategorija je ostalo 000 ili 999
lcid_category="000"

GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

replace id_rtip with lcId_rtip in _pogodba
replace rind_zadnji with lcRind_zadnji in _pogodba

	tcXMLStrDobr = "" && XML for fictive cost; dodano u 2.19
lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy", tcXMLStrDobr)

&& ako je lcXML prazan ne šalji poziv ništa se nije promjenilo, nisu poslali novi fix_del
obvesti (lcXml)
return .f.
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