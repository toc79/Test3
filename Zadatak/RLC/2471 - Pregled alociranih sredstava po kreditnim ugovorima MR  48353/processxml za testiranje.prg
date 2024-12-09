<calculate_npm xmlns='urn:gmi:nova:leasing'>  <sum_allocation_amount>17453.79</sum_allocation_amount>  <ccontract_allocation_list>  <amount>17453.79</amount>  <all_in_price_for_NPM>5</all_in_price_for_NPM>  </ccontract_allocation_list>  <contract_parameters>  <id_cont>1244</id_cont>  </contract_parameters>  </calculate_npm>

       1642
	   
<calculate_npm xmlns='urn:gmi:nova:leasing'>  <sum_allocation_amount>10301.01</sum_allocation_amount>  <ccontract_allocation_list>  <amount>10301.01</amount>  <all_in_price_for_NPM>5</all_in_price_for_NPM>  </ccontract_allocation_list>  <contract_parameters>  <id_cont>1642</id_cont>  </contract_parameters>  </calculate_npm>

<?xml version="1.0" encoding="utf-16"?>
<calculate_npm_response xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:leasing">
  <npm>-4.9999999999999555910790149937</npm>
  <pasive_ir>5.00</pasive_ir>
  <eom_for_npm>0.0000000000000444089209850063</eom_for_npm>
  <start_date>2011-07-04T00:00:00</start_date>
</calculate_npm_response>



<calculate_npm xmlns='urn:gmi:nova:leasing'>  <sum_allocation_amount>115217.29</sum_allocation_amount>  <ccontract_allocation_list>  <amount>115217.29</amount>  <all_in_price_for_NPM>5</all_in_price_for_NPM>  </ccontract_allocation_list>  <contract_parameters>  <id_cont>398</id_cont>  </contract_parameters>  </calculate_npm>

<LE_contract_ccontracts_allocation_insert_update xmlns='urn:gmi:nova:credit-contracts'><is_update>false</is_update>  <id_cont>398</id_cont>  <amount_for_allocation>115217.29</amount_for_allocation>  <ccontract_allocation_list><id_kredpog>3</id_kredpog>  <amount>115217.29</amount>  <all_in_price_for_NPM>5</all_in_price_for_NPM>  <all_in_price_for_NPM_zac>5</all_in_price_for_NPM_zac>  <is_canceled>false</is_canceled>  </ccontract_allocation_list></LE_contract_ccontracts_allocation_insert_update>

-- NOVO
<LE_contract_ccontracts_allocation_insert_update xmlns='urn:gmi:nova:credit-contracts'><is_update>false</is_update>  <id_cont>1244</id_cont>  <amount_for_allocation>17453.79</amount_for_allocation>  <ccontract_allocation_list><id_kredpog>3</id_kredpog>  <amount>115217.29</amount>  <all_in_price_for_NPM>5</all_in_price_for_NPM>  <all_in_price_for_NPM_zac>5</all_in_price_for_NPM_zac>  <is_canceled>false</is_canceled>  </ccontract_allocation_list></LE_contract_ccontracts_allocation_insert_update>


-- NOVO Z
<LE_contract_ccontracts_allocation_insert_update xmlns='urn:gmi:nova:credit-contracts'><is_update>false</is_update>  <id_cont>1642</id_cont>  <amount_for_allocation>10301.01</amount_for_allocation>  <ccontract_allocation_list><id_kredpog>3</id_kredpog>  <amount>10301.01</amount>  <all_in_price_for_NPM>5</all_in_price_for_NPM>  <all_in_price_for_NPM_zac>5</all_in_price_for_NPM_zac>  <is_canceled>false</is_canceled>  </ccontract_allocation_list></LE_contract_ccontracts_allocation_insert_update>

podaci za 
all_in_price_for_NPM
i 
all_in_price_for_NPM_zac
idu iz kred_pog
ili iz 
gv_KredPogAllocation za ugovori koji već imaju zapis u alociranju (valjda)

select 
    a.id_pog
    , a.iznos_akolacije
	, pog.id_cont
	, kp.id_kredpog
	, kp.all_in_price_for_NPM
	, kp.all_in_price_for_NPM as all_in_price_for_NPM_zac
	--, * 
from dbo._tmp_alociranje_MR48353 a
join dbo.POGODBA pog on dbo.gfn_Id_cont4Id_pog(a.id_pog) = pog.id_cont
left join dbo.pogodba_kp_npm pkp on pog.ID_CONT = pkp.id_cont
cross join dbo.KRED_POG kp --on kp.id_kred_pog 
where kp.ID_KREDPOG = '0253 21' --'0253 21'
-- provjere
and a.iznos_akolacije = pog.NET_NAL_zac --svi
and pkp.id_cont is null -- ne smije biti alokacije
--and pog.NET_NAL = pog.net_nal_zac -- dva ista, ostalih 40 su promjenjeni
order by pog.id_cont

** 04.03.2022 g_tomislav MID 48353 - created. Po potrebi treba prilagoditi skriptu
#include locs.h

lnUkupno = reccount("kp_pogodba_alloc")
lnOK = 0
lnError = 0

select kp_pogodba_alloc
go top
SCAN
* PROCEDURE prepare_xml_for_save
		LOCAL lcXml && lnAmount, llCanceled
		
		lcXml = "<LE_contract_ccontracts_allocation_insert_update xmlns='urn:gmi:nova:credit-contracts'>" +gce	
		lcXml = lcXml + GF_CreateNode("is_update", .F., "L", 1) + gcE && Thisform.tip_vnosne_maske != 1
		lcXml = lcXml + GF_CreateNode("id_cont", kp_pogodba_alloc.id_cont, "I", 1) + gcE && thisform.id_cont
		lcXml = lcXml + GF_CreateNode("amount_for_allocation", kp_pogodba_alloc.iznos_akolacije, "N", 1) + gcE && thisform.amount_for_allocation
		*IF Thisform.tip_vnosne_maske = 2 OR Thisform.chkUse_zac_eom_from_contract.Value = .T. THEN
			*lcXml = lcXml + GF_CreateNode("eom", IIF(Thisform.tip_vnosne_maske = 2, pogodba_kp_npm.ef_obrm_npm_zac, pogodba.ef_obrm), "N", 1) + gcE
		*ENDIF		
		*SELECT kp_pogodba_alloc
		*GO TOP
		*SCAN
			*llCanceled = kp_pogodba_alloc.is_canceled
			*lnAmount = IIF(!kp_pogodba_alloc.is_canceled, kp_pogodba_alloc.allocated_amount, kp_pogodba_alloc.canceled_amount) && we always store one amount (if allocation is canceled or not)
			
			lcXml = lcXml + "<ccontract_allocation_list>" +gce
			*IF !GF_NULLOREMPTY(kp_pogodba_alloc.id_kred_pog_pogodba_alloc) THEN
				*lcXml = lcXml + GF_CreateNode("id_kred_pog_pogodba_alloc", kp_pogodba_alloc.id_kred_pog_pogodba_alloc, "I", 1) + gcE
			*ENDIF
			lcXml = lcXml + GF_CreateNode("id_kredpog", kp_pogodba_alloc.id_kredpog, "C", 1) + gcE
			lcXml = lcXml + GF_CreateNode("amount", kp_pogodba_alloc.iznos_akolacije, "N", 1) + gcE && lnAmount
			lcXml = lcXml + GF_CreateNode("all_in_price_for_NPM", kp_pogodba_alloc.all_in_price_for_NPM, "N", 1) + gcE
			lcXml = lcXml + GF_CreateNode("all_in_price_for_NPM_zac", kp_pogodba_alloc.all_in_price_for_NPM_zac, "N", 1) + gcE
			* IF !GF_NULLOREMPTY(kp_pogodba_alloc.id_kredpog_return) THEN
				* lcXml = lcXml + GF_CreateNode("id_kredpog_return", kp_pogodba_alloc.id_kredpog_return, "C", 1) + gcE
				* lcXml = lcXml + GF_CreateNode("amount_return", kp_pogodba_alloc.amount_return, "N", 1) + gcE
				* IF !GF_NULLOREMPTY(kp_pogodba_alloc.date_return)
					* lcXml = lcXml + GF_CreateNode("date_return", kp_pogodba_alloc.date_return, "D", 1) + gcE
				* ENDIF
			* ENDIF
			lcXml = lcXml + GF_CreateNode("is_canceled", .F., "L", 1) + gcE && kp_pogodba_alloc.is_canceled
			*IF !GF_NULLOREMPTY(kp_pogodba_alloc.date_canceled) THEN
				*lcXml = lcXml + GF_CreateNode("date_canceled", kp_pogodba_alloc.date_canceled, "D", 1) + gcE
			*ENDIF
			lcXml = lcXml + "</ccontract_allocation_list>" +gce
		*ENDSCAN
		* IF Thisform.tip_vnosne_maske != 1 THEN
			* lcXml = lcXml + GF_CreateNode("sys_ts", Thisform.sys_ts, "I", 1) + gcE
		* ENDIF
		lcXml = lcXml + "</LE_contract_ccontracts_allocation_insert_update>"	
		*RETURN lcXml
	*ENDPROC
	
	IF GF_ProcessXml(lcXml) THEN
		lnOK = lnOK + 1
		*obvesti("Podatki uspešno shranjeni.")
		*lcXmlResult = GOBJ_Comm.GetResult()
		*lnId_cont = GF_GetSingleNodeXml(GOBJ_Comm.GetResult(), "id_cont")
		*Thisform.id_field = VAL(lnId_cont)
	ELSE
		lnError = lnError + 1
		*RETURN .F.
	ENDIF
ENDSCAN 
obvesti("Ukupno: "+allt(trans(lnUkupno))+". Greške: "+allt(trans(lnError))+". OK: "+allt(trans(lnOK)))

