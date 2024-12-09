-- RLC --

test 
DOPIS ZA REGISTRACIJU SSOFT                       


PROD
FAKT_TR_SSOFT_RLC             
DDV_DBRP_ZVEC_SSOFT_RLC            
FAK_LOBR_SSOFT_RLC            
RLC_XDOC_T1                   
OBV_LOBR_SSOFT_RLC            
OBVREG_SSOFT                  
DOPIS ZA REGISTRACIJU SSOFT                       	OBVREG_SSOFT                  
FAKT_TR_SSOFT_RLC 

FAK_LOBR_SSOFT_RLC            
RLC_XDOC_T1                               
OBV_LOBR_SSOFT_RLC            
RLC_XDOC_T1                   
                
OBV_IND_SSOFT_RLC             edoc
ZOBR_FA_SSOFT_RLC             edoc
				
(CA-OS) Dopisi za registraciju u TXT                                                                
(CA-OS) Dopisi za opremu                                                                            

*** NE KORISTI SE *** (CA-V)Obavijesti za rate u TXT 22.02.2008                                     
*** NE KORISTI SE *** (CA-V)Računi za rate u DBF                                                    
*** NE KORISTI SE *** (CA-V)Računi za rate u TXT 22.02.2008      


id_object_type	description	GDPR_customers_select
za_regis	Logiranje ispisa dopis za registraciju	DECLARE @id_za_regis int
SET @id_za_regis = '{0}'

SELECT r.id_kupca as ID_KUPCA, 
	   p.vr_osebe as VRSTA_OSEBE, 
	   'Ispis dopisa za registraciju' as ADDITIONAL_DESC
FROM
	  dbo.pfn_Za_regisSelection (getdate(), 0) r 
	  INNER JOIN dbo.partner p on r.id_kupca = p.id_kupca 
	  WHERE r.id_za_regis = @id_za_regis
	  
	  id_object_type	description	GDPR_customers_select
najem_ob	Logiranje ispisa obavijesti za rate	DECLARE @id_najem_ob int
SET @id_najem_ob = '{0}'

SELECT r.id_kupca as ID_KUPCA, 
	   p.vr_osebe as VRSTA_OSEBE, 
	   'Ispis obavijesti za rate' as ADDITIONAL_DESC
FROM
	  dbo.pft_Print_NoticeForInstallments(getdate()) r 
	  INNER JOIN dbo.partner p on r.id_kupca = p.id_kupca 
	  WHERE r.id_najem_ob = @id_najem_ob
	  

	  
PROD


(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)

(1 row(s) affected)
oldValue: gfn_Print_InvoiceForExchangeDifferences2, newValue: pfn_gmc_Print_InvoiceForExchangeDifferences
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pfn_Print_InvoiceForExchangeDifferences2, newValue: pfn_gmc_Print_InvoiceForExchangeDifferences
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: gfn_Print_InvoiceForInterestsLatePayments, newValue: pfn_gmc_Print_InvoiceForInterestsLatePayments
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pfn_Print_InvoiceForInterestsLatePayments, newValue: pfn_gmc_Print_InvoiceForInterestsLatePayments
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: gfn_print_Izp_Opc, newValue: pfn_gmc_print_Izp_Opc
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pfn_print_Izp_Opc, newValue: pfn_gmc_print_Izp_Opc
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: gfn_print_Opc_fakt, newValue: pfn_gmc_print_Opc_fakt
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pfn_print_Opc_fakt, newValue: pfn_gmc_print_Opc_fakt
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: gfn_print_spr_ddv, newValue: pfn_gmc_print_spr_ddv
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pfn_print_spr_ddv, newValue: pfn_gmc_print_spr_ddv
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pfn_Za_pzSelection, newValue: pfn_gmc_Za_pzSelection
Porocila

(1 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pfn_Za_regisSelection, newValue: pfn_gmc_Za_regisSelection
Porocila

(1 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(1 row(s) affected)
print_selection: code_before

(1 row(s) affected)

(1 row(s) affected)
oldValue: gft_Print_InvoiceForInstallments, newValue: pfn_gmc_Print_InvoiceForInstallments
Porocila

(2 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pft_Print_InvoiceForInstallments, newValue: pfn_gmc_Print_InvoiceForInstallments
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: gft_Print_NoticeForInstallments, newValue: pfn_gmc_Print_NoticeForInstallments
Porocila

(1 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(0 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
oldValue: pft_Print_NoticeForInstallments, newValue: pfn_gmc_Print_NoticeForInstallments
Porocila

(0 row(s) affected)
sql_candidates

(0 row(s) affected)

(0 row(s) affected)
sql_show

(0 row(s) affected)

(0 row(s) affected)
sql_data_select

(0 row(s) affected)

(0 row(s) affected)
sql_update

(0 row(s) affected)

(0 row(s) affected)
Ext_func: code

(0 row(s) affected)

(0 row(s) affected)
report_id_object_types: GDPR_customers_select

(1 row(s) affected)
print_selection: code_before

(0 row(s) affected)

(0 row(s) affected)
