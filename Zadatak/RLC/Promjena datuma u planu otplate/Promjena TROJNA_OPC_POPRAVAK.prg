* SQL
*Select id_cont, DATEADD(mm,-1,zap_opc) as zap_opc_new, zap_opc, dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash from pogodba where  id_cont=13431
select * from rep_category

select c.id_cont, b.id_pog, trojna_opc
, dbo.gfn_GetContractDataHash(b.id_cont) as pogodba_hash
from dbo._tmp_zap_opc a 
join dbo.planp c on a.st_dok = c.st_dok
join dbo.pogodba  b ON c.id_cont = b.id_cont
where b.trojna_opc = 1
order by 1

*********************************************************************************************************
&&FOX dio, tamo stavi da se dobiveni cursor zove rezultat (result alias)
#include locs.h

LOCAL lnUspjesno, lnError
lnUspjesno = 0
lnError = 0

sele rezultat
GO TOP
SCAN
	LOCAL lcpogodba_hash, lcuvjeti, lnid_cont, lcOpomba, lcid_category, lcXML

	lcpogodba_hash = rezultat.pogodba_hash
	lcuvjeti = .f.    	&&rezultat.trojna_opc
	lnid_cont = rezultat.id_cont
		&&staviti napomenu koju trebas
	lcOpomba = "Popravak podatka na ugovoru prema zahtjevu 1630 (MR 38629)"
		&&kategorija je ostalo 000 ili 999
	lcid_category="999"

	GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
	GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

		&&ovaj dio program uvijek izvršava a ti vidi da li ćeš i ti
		&&IF _pogodba.rind_tgor != _pogodba.rind_tdol THEN
		&& REPLACE rind_tdol WITH rind_tgor IN _pogodba
		&&ENDIF
	replace trojna_opc with lcuvjeti in _pogodba

	lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")

	&& ako je lcXML prazan ne šalji poziv ništa se nije promjenilo, nisu poslali novi fix_del
	IF LEN(ALLTRIM(lcXml)) > 0 THEN
		IF GF_ProcessXML(lcXML) THEN
			lnUspjesno = lnUspjesno + 1 &&=obvesti("OK za ugovor: " + allt(trans(lnid_cont)))
		ELSE
			lnError = lnError + 1 &&=obvesti("NOT OK za ugovor:" + allt(trans(lnid_cont)))
		ENDIF
	ELSE
		obvesti("Za ugovor: "+ allt(trans(lnid_cont)) + ". Nisu definirali nove uvjete.")
	ENDIF
	use in _pogodba
	use in _pogodba_copy
ENDSCAN
OBVESTI("Postupak je završio!"+gcE+"Uspješno ugovora: "+trans(lnUspjesno)+". Neuspješno ugovora: "+trans(lnError))
*********************************************************************************************************

----
select * from reprogram where time>=getdate()-1 and [user] = 'g_tomislav'
UPDATE reprogram SET [user] = 'g_system' where time>=getdate()-1 and [user] = 'g_tomislav'


* XML koji se pokreće prilikom promjena datuma u planu otplate -> on ne mijenja podatak na mapi ugovora
<?xml version='1.0' encoding='utf-8' ?>
<rpg_change_ap_dates xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>8377</id_cont>
<comment>Promijena datuma u planu otplate</comment>
<hash_value>278437940</hash_value>
<id_rep_category>000</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<st_dok>00006926/16-21-037R01</st_dok>
<st_dok_list>'00006926/16-21-037R01'</st_dok_list>
<new_date>2019-11-01T00:00:00.000</new_date>
<due_date_single_claim>false</due_date_single_claim>
<change_document_dates>true</change_document_dates>
<change_all_claims>false</change_all_claims>
<claims_hash>314425191</claims_hash>
<all_same_day>false</all_same_day>
</rpg_change_ap_dates>

Promjena datuma u planu otplate
***************************************************************************************
* wrapper for SOAP call for change of dates in amortisation plan
* tnId_cont - id_cont from contract
* tcSt_dok - Document number of initial claim for date change.
* tcSt_dok_list - List of claims for date change in case of change_all_claims = true
* tdNew_date - New due date to be applied for the initial claim.
* tlDue_date_single_claim - Flag indicating only change of due date for single claim.
* tlChange_document_dates - Flag indication if document dates should also be changed.
* tlChange_all_claims - Flag indicating if all claims after initial claim should be changed.
* tnHash - Hash of the claims to change.
* tcRepCat - reprogram category - optional for backward compatibility
* tcComment - comment (reprogram.comment) - optional for backward compatibility
* returns: true/false.
* FUNCTION GF_APDateChange(tnId_cont, tcSt_dok as string, tcSt_dok_list as string, tdNew_date as Datetime, ;
* GF_ChangePPDates() u blproc.prg
* GF_APDateChange u soap_wrappers.prg
PROVJERITI
[gfn_GetStDokContractHash]
tcSt_dok_list = "'" + tcSt_dok + "'"
lnHash = GF_SQLExecScalar("SELECT CHECKSUM_AGG(CHECKSUM(*)) FROM dbo.planp WHERE st_dok IN ("+ tcSt_dok_list +")")
tnHash