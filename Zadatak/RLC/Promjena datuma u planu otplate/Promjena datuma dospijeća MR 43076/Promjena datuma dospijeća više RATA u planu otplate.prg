* SQL
*Select id_cont, DATEADD(mm,-1,zap_opc) as zap_opc_new, zap_opc, dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash from pogodba where  id_cont=13431
select * from rep_category
SELECT * FROM dbo._tmp_ugovori --129
SELECT a.id_cont, dni_zap, 20 as dni_zap_new FROM dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_cont = b.id_cont --85 na testu
SELECT a.id_cont, dni_zap, 20 as dni_zap_new FROM nova_prod.dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_pog = b.id_pog --129 na prod

select id_cont, st_dok, datum_dok, dat_zap, cast('20190821' as datetime) AS dat_zap_new 
FROM dbo.planp 
where datum_dok = '20190801' 
AND EXISTS (select * from dbo._tmp_ugovori where id_cont = planp.id_cont)
AND dat_zap = '20190809'
AND evident != '*'
order by id_cont


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

	TEXT TO lcSql NOSHOW
		SELECT ID_CONT, st_dok, dat_zap
		--, dat_zap - (DATEPART(dd, dat_zap)) + 25 as dat_zap_new -- pomak na 0 pa onda na 25 u mjesecu
		FROM dbo.PLANP 
		WHERE ID_TERJ IN ('21', '23')
		--AND DAT_ZAP > GETDATE() --i DATUM_DOK > GETDATE() BUDUĆE RATE ONDA BI TREBALO GLEDATI DATUM_DOK
		AND datum_dok >= '20190801'
		AND id_cont = 
	ENDTEXT 
	GF_SQLEXEC(lcSql+gf_Quotedstr(tnId_cont) +"order by DATUM_DOK, dat_zap, zap_obr","_fox_planp")
	select _fox_planp
	go top
	
	tcSt_dok = _fox_planp.st_dok && rezultat.st_dok && dobivanje prvog _fox_planp.st_dok potraživanja
	* tcSt_dok_list = "'" + tcSt_dok + "'"
	
	LcList_condition = ""  && Mora biti 
	tcSt_dok_list = GF_CreateDelimitedList("_fox_planp", "st_dok", LcList_condition, ",", .t.) && S NAVODNICIMA

	tdNew_date = rezultat.dat_zap_new

	tlDue_date_single_claim = .F.
	tlChange_document_dates = .F.
	tlChange_all_claims = .T.
	
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
        lnUspjesno = lnUspjesno + 1  &&RETURN .T.
    ELSE 
        lnError = lnError + 1  &&RETURN .F.
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
<id_cont>8770</id_cont>
<comment>Promijena datuma u planu otplate</comment>
<hash_value>1987852360</hash_value>
<id_rep_category>000</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<st_dok>7302/19-21-003AVT</st_dok>
<st_dok_list>'7302/19-21-003AVT','7302/19-21-004AVT','7302/19-21-005AVT','7302/19-21-006AVT','7302/19-21-007AVT','7302/19-21-008AVT','7302/19-21-009AVT','7302/19-21-010AVT','7302/19-21-011AVT','7302/19-21-012AVT','7302/19-21-013AVT','7302/19-21-014AVT','7302/19-21-015AVT','7302/19-21-016AVT','7302/19-21-017AVT','7302/19-21-018AVT','7302/19-21-019AVT','7302/19-21-020AVT','7302/19-21-021AVT','7302/19-21-022AVT','7302/19-21-023AVT','7302/19-21-024AVT','7302/19-21-025AVT','7302/19-21-026AVT','7302/19-21-027AVT','7302/19-21-028AVT','7302/19-21-029AVT','7302/19-21-030AVT','7302/19-21-031AVT','7302/19-21-032AVT','7302/19-21-033AVT','7302/19-21-034AVT','7302/19-21-035AVT','7302/19-21-036AVT','7302/19-21-037AVT','7302/19-21-038AVT','7302/19-21-039AVT','7302/19-21-040AVT','7302/19-21-041AVT','7302/19-21-042AVT','7302/19-21-043AVT','7302/19-21-044AVT','7302/19-21-045AVT','7302/19-21-046AVT','7302/19-21-047AVT','7302/19-21-048AVT','7302/19-21-049AVT','7302/19-21-050AVT','7302/19-21-051AVT','7302/19-21-052AVT','7302/19-21-053AVT','7302/19-21-054AVT','7302/19-21-055AVT','7302/19-21-056AVT','7302/19-21-057AVT','7302/19-21-058AVT','7302/19-21-059AVT','7302/19-21-060AVT','7302/19-21-061AVT','7302/19-21-062AVT','7302/19-21-063AVT','7302/19-21-064AVT','7302/19-21-065AVT','7302/19-21-066AVT','7302/19-21-067AVT','7302/19-21-068AVT','7302/19-21-069AVT','7302/19-21-070AVT','7302/19-21-071AVT','7302/19-21-072AVT','7302/19-21-073AVT','7302/19-21-074AVT','7302/19-21-075AVT','7302/19-21-076AVT','7302/19-21-077AVT','7302/19-21-078AVT','7302/19-21-079AVT','7302/19-21-080AVT','7302/19-21-081AVT','7302/19-21-082AVT','7302/19-21-083AVT','7302/19-21-084AVT','7302/19-21-085AVT','7302/19-21-086AVT','7302/19-21-087AVT','7302/19-21-088AVT','7302/19-21-089AVT','7302/19-21-090AVT','7302/19-21-091AVT','7302/19-21-092AVT','7302/19-21-093AVT','7302/19-21-094AVT','7302/19-21-095AVT','7302/19-21-096AVT','7302/19-21-097AVT','7302/19-21-098AVT','7302/19-21-099AVT','7302/19-21-100AVT','7302/19-21-101AVT','7302/19-21-102AVT','7302/19-21-103AVT','7302/19-21-104AVT','7302/19-21-105AVT','7302/19-21-106AVT','7302/19-21-107AVT','7302/19-21-108AVT','7302/19-21-109AVT','7302/19-21-110AVT','7302/19-21-111AVT','7302/19-21-112AVT','7302/19-21-113AVT','7302/19-21-114AVT','7302/19-21-115AVT','7302/19-21-116AVT','7302/19-21-117AVT','7302/19-21-118AVT','7302/19-21-119AVT','7302/19-21-120AVT','7302/19-21-121AVT','7302/19-21-122AVT','7302/19-21-123AVT','7302/19-21-124AVT','7302/19-21-125AVT','7302/19-21-126AVT','7302/19-21-127AVT','7302/19-21-128AVT','7302/19-21-129AVT','7302/19-21-130AVT','7302/19-21-131AVT','7302/19-21-132AVT','7302/19-21-133AVT','7302/19-21-134AVT','7302/19-21-135AVT','7302/19-21-136AVT','7302/19-21-137AVT','7302/19-21-138AVT','7302/19-21-139AVT','7302/19-21-140AVT','7302/19-21-141AVT','7302/19-21-142AVT','7302/19-21-143AVT','7302/19-21-144AVT','7302/19-21-145AVT','7302/19-21-146AVT','7302/19-21-147AVT','7302/19-21-148AVT','7302/19-21-149AVT','7302/19-21-150AVT','7302/19-21-151AVT','7302/19-21-152AVT','7302/19-21-153AVT','7302/19-21-154AVT','7302/19-21-155AVT','7302/19-21-156AVT','7302/19-21-157AVT','7302/19-21-158AVT','7302/19-21-159AVT','7302/19-21-160AVT','7302/19-21-161AVT','7302/19-21-162AVT','7302/19-21-163AVT','7302/19-21-164AVT','7302/19-21-165AVT','7302/19-21-166AVT','7302/19-21-167AVT','7302/19-21-168AVT','7302/19-21-169AVT','7302/19-21-170AVT','7302/19-21-171AVT','7302/19-21-172AVT','7302/19-21-173AVT','7302/19-21-174AVT','7302/19-21-175AVT','7302/19-21-176AVT','7302/19-21-177AVT','7302/19-21-178AVT','7302/19-21-179AVT','7302/19-21-180AVT','7302/19-23-181AVT'</st_dok_list>
<new_date>2019-08-20T00:00:00.000</new_date>
<due_date_single_claim>false</due_date_single_claim>
<change_document_dates>false</change_document_dates>
<change_all_claims>true</change_all_claims>
<claims_hash>85524115</claims_hash>
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