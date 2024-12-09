﻿* SQL
*Select id_cont, DATEADD(mm,-1,zap_opc) as zap_opc_new, zap_opc, dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash from pogodba where  id_cont=13431
select * from rep_category

select c.id_cont, b.id_pog, b.zap_opc AS zap_opc_new, trojna_opc 
, c.st_dok , c.datum_dok
from dbo._tmp_zap_opc a 
join dbo.planp c on a.st_dok = c.st_dok
join dbo.pogodba  b ON c.id_cont = b.id_cont
WHERE c.EVIDENT = ''
AND c.datum_dok != b.zap_opc
order by 1

*********************************************************************************************************
&&FOX dio, tamo stavi da se dobiveni cursor zove rezultat (result alias)
#include locs.h

LOCAL lnUspjesno, lnError
lnUspjesno = 0
lnError = 0
	
sele rezultat
go top
SCAN
	LOCAL lnContractHash, lcComment, tnId_cont, tnHash, tcSt_dok_list, lcSql, tcSt_dok, tlDue_date_single_claim, tlChange_document_dates, tlChange_all_claims

	tnId_cont = rezultat.Id_cont
	tcRepCat = "999" 
    lnContractHash = GF_SQLEXECSCALAR("SELECT dbo.gfn_getContractDataHash("+ ALLTRIM(STR(tnId_cont)) +")")
   	lcComment = "Promjena datuma u planu otplate"        &&"Changing dates in amortization plan" && caption

	* TEXT TO lcSql NOSHOW
	* SELECT ID_CONT, st_dok, dat_zap
	* , dat_zap - (DATEPART(dd, dat_zap)) + 25 as dat_zap_new -- pomak na 0 pa onda na 25 u mjesecu
	* FROM dbo.PLANP 
	* WHERE ID_TERJ = '21' 
	* AND DAT_ZAP > GETDATE() --i DATUM_DOK > GETDATE() BUDUĆE RATE ONDA BI TREBALO GLEDATI DATUM_DOK
	* AND id_cont = 
	* ENDTEXT 
	* GF_SQLEXEC(lcSql+gf_Quotedstr(tnId_cont) +"order by DATUM_DOK, dat_zap, zap_obr","_fox_planp")
	
	* select _fox_planp
	* go top
	tcSt_dok = rezultat.st_dok && dobivanje prvog _fox_planp.st_dok potraživanja
	tcSt_dok_list = "'" + tcSt_dok + "'"
	
	* LcList_condition = ""  && Mora biti 
	* tcSt_dok_list = GF_CreateDelimitedList("_fox_planp", "st_dok", LcList_condition, ",", .t.) && S NAVODNICIMA

	tdNew_date = rezultat.zap_opc_new

	tlDue_date_single_claim = .F.
	tlChange_document_dates = .T.
	tlChange_all_claims = .F.
	
	tnHash = GF_SQLExecScalar("SELECT CHECKSUM_AGG(CHECKSUM(*)) FROM dbo.planp WHERE st_dok IN ("+ tcSt_dok_list +")")
	
    LOCAL lcXML
	lcXML = ""
	lcXML = lcXML + "<?xml version='1.0' encoding='utf-8' ?>" + gcE
	lcXML = lcXML + '<rpg_change_ap_dates xmlns="urn:gmi:nova:leasing">' + gcE
	lcXML = lcXML + '<common_parameters>'+ gcE
	lcXML = lcXML + GF_CreateNode("id_cont", tnId_cont, "N", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("comment", lcComment, "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("hash_value", lnContractHash , "C", 1)+ gcE
	* IF TYPE("tcRepCat") = "C" AND !EMPTY(tcRepCat) &&for backward compatibility
		lcXML = lcXML + GF_CreateNode("id_rep_category", tcRepCat, "C", 1) + gcE
	* ENDIF
	lcXML = lcXML + GF_CreateNode("use_4eyes", .F. , "L", 1)+ gcE && 3.2.3 PROVJERITI NA PROD 2.23.8
	lcXML = lcXML + '</common_parameters>'+ gcE
	lcXML = lcXML + GF_CreateNode("st_dok", tcSt_dok , "C", 1)+ gcE	
	lcXML = lcXML + GF_CreateNode("st_dok_list", tcSt_dok_list, "C", 1)+ gcE	
	lcXML = lcXML + GF_CreateNode("new_date", tdNew_date, "D", 1)+ gcE			
	lcXML = lcXML + GF_CreateNode("due_date_single_claim", tlDue_date_single_claim, "L", 1)+ gcE	
	lcXML = lcXML + GF_CreateNode("change_document_dates", tlChange_document_dates, "L", 1)+ gcE	
	lcXML = lcXML + GF_CreateNode("change_all_claims", tlChange_all_claims, "L", 1)+ gcE	
	lcXML = lcXML + GF_CreateNode("claims_hash", tnHash, "N", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("all_same_day", .F. , "L", 1)+ gcE && 3.2.3 PROVJERITI NA PROD 2.23.8
	lcxml = lcXML + '</rpg_change_ap_dates>'    	

	IF GF_ProcessXml(lcXml) THEN 
        lnUspjesno = lnUspjesno + 1 &&RETURN .T.
    ELSE 
        lnError = lnError + 1 &&RETURN .F.
    ENDIF 
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