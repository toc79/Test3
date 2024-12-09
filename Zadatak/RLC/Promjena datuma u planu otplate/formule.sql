select 
b.ID_POG Br_ugovora, b.id_kupca Šif_kupca, a.ZAP_OBR Rata, a.ST_DOK Br_dok, a.datum_dok
, DAY(datum_dok) as dan_u_mj
, a.* 
from planp a 
join pogodba b on a.id_cont = b.id_cont
WHERE b.status_akt = 'A'
AND a.st_dok = dbo.gfn_GetOpcSt_dok(b.id_cont, b.nacin_leas)
AND dbo.gfn_Nacin_leas_HR(b.nacin_leas) like 'F1'
AND evident != '*'
AND DAY(datum_dok) != 1

Poštovani, 
u prilogu vam šaljemo ponudu za masovnu promjenu datuma dospijeća za ugovore prema zahtjevu. Promjena će biti evidentirana u pregled reprograma.

Pod buduće rate, da li se tu podrazumijevaju neproknjižene (prema datumu dokumenta) ili nedospjele (prema datumu dospijeća)?

$SIGN


[gfn_GetStDokContractHash]

lnHash = GF_SQLExecScalar("SELECT CHECKSUM_AGG(CHECKSUM(*)) FROM dbo.planp WHERE st_dok IN ("+ tcSt_dok_list +")")

************
<?xml version='1.0' encoding='utf-8' ?>
<rpg_change_ap_dates xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>8521</id_cont>
<comment>Promijena datuma u planu otplate</comment>
<hash_value>357007144</hash_value>
<id_rep_category>000</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<st_dok>7059/17-21-003AVT</st_dok>
<st_dok_list>'7059/17-21-003AVT    '</st_dok_list>
<new_date>2020-06-01T00:00:00.000</new_date>
<due_date_single_claim>false</due_date_single_claim>
<change_document_dates>true</change_document_dates>
<change_all_claims>false</change_all_claims>
<claims_hash>395099030</claims_hash>
<all_same_day>false</all_same_day>
</rpg_change_ap_dates>
************

za SGL promjena datuma dospijeća Aktivnih ugovora 

SELECT CHECKSUM_AGG(CHECKSUM(*)) FROM dbo.planp WHERE st_dok IN ('06228/14-21-034AVT','06228/14-21-035AVT','06228/14-21-036AVT')

************
<?xml version='1.0' encoding='utf-8' ?>
<rpg_change_ap_dates xmlns="urn:gmi:nova:leasing">
<common_parameters>
<id_cont>6932</id_cont>
<comment>Promijena datuma u planu otplate</comment>
<hash_value>1392277992</hash_value>
<id_rep_category>000</id_rep_category>
<use_4eyes>false</use_4eyes>
</common_parameters>
<st_dok>06228/14-21-034AVT</st_dok>
<st_dok_list>'06228/14-21-034AVT','06228/14-21-035AVT','06228/14-21-036AVT'</st_dok_list>
<new_date>2017-08-25T00:00:00.000</new_date>
<due_date_single_claim>false</due_date_single_claim>
<change_document_dates>false</change_document_dates>
<change_all_claims>true</change_all_claims>
<claims_hash>769329695</claims_hash>
<all_same_day>false</all_same_day>
</rpg_change_ap_dates>