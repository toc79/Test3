------------------------------------------------------------------
-- this procedure prepares snapshot data from "open-claims-on-day" batch. 
--
-- History:
-- xx.04.2004 Vik; created
-- 24.05.2004 Vik; check of ku_dnev - now checks only target id_kupca
-- 27.05.2004 Vik; major rewrite
-- 02.06.2004 Vik; removed some parameters
-- 17.06.2004 Vik; added ex_max_dat_zap to oc_contracts
-- 22.06.2004 Vik; added dejavnos lookup data into oc_customers
-- 23.06.2004 Vik; error message is now translation code, added id_kupca1 to oc_contracts
-- 26.08.2004 Vik; fixed bug - I assummed id_terj is numeric-like
-- 27.09.2004 Vik; oc_customers has new fields
-- 29.09.2004 Vik; new fields in oc_contracts
-- 22.11.2004 Vik; added ex_nacin_leas_odstej_var to oc_contracts
-- 02.12.2004 Vik; optimizations
-- 13.12.2004 Vik; minor bugfix in transfer of data into oc_contracts
-- 26.01.2005 Vik; fixed bug in advances balance calculation
-- 26.01.2005 Vik; added fields ex_debit_val_claim, ex_kredit_val_claim, ex_saldo_val_claim
-- 03.02.2005 Vik; fixed calculation of ex_*_val
-- 07.02.2005 Vik; all active contracts for signle user are now prepared
-- 08.03.2005 Vik; added "print" statements for easier maintenance
-- 19.05.2005 Vik; added fields ex_saldo_dom, ex_saldo_dom_dd etc. in oc_claims
-- 18.08.2005 Matjaz; added field kontakt_d at insert into oc_customers
-- 23.08.2005 Vik; added fields to oc_contracts and oc_customers
-- 02.09.2005 Vik; added preparation of data for table oc_contracts_future_by_type
-- 17.11.2005 Vik; Bug id 25727: fixed insert into table oc_contracts_future_by_type (foreign key was failing)
-- 27.01.2006 Vik; Bug id 25819: added claims with empty evident to result (they should be treated as open)
-- 02.01.2006 Natasa; added new field to oc_customers from partner 
-- 16.02.2006 Natasa ; added new tables oc_lsk and oc_gl 
-- 22.02.2006 Natasa; added new fields into oc_contracts: VR_VAL_ZAC, OBR_MERAK_ZAC, FIX_DELK_ZAC, 
--    		      OBR_MERA_ZAC, FIX_DEL_ZAC, DEJ_OBR_ZAC, EF_OBRM_ZAC
-- 03.04.2006 Vik; Maintenance id 1182 - added rounding of small amounts
-- 26.04.2006 Natasa ; modified field ex_max_datum_dok
-- 28.04.2006 Natasa ; while inserting into oc_claims instead planp.* wrote list of columns 
--		added new column ex_dni_zamude into oc_claims = target date - dat_zap
-- 19.05.2006 Vilko; added new field id_odobrit to oc_contracts from pogodba
-- 24.05.2006 Vik; fixed calculation of advances for snapshot variant
-- 11.07.2006 Vik; added parameter @report_desc
-- 30.08.2006 Vilko; Maintenance ID 2253 - added field idkupca_pl into oc_contracts
-- 25.10.2006 Vilko; Maintenance ID 3845 - added fields id_reg, id_reg_d, id_reg_k, id_reg_sed into oc_customers
-- 09.01.2007 Vilko; Bug ID 26273 - added fields ex_instpreTD_DD, ex_instpostTD_DD, ex_net_instpreTD, ex_net_instpostTD, ex_int_instpreTD, ex_int_instpostTD
--                                - snapshot is now prepared for all contracts, not only for active and closed
-- 22.01.2007 Jasna;Bug ID 26443 - added new field to oc_customers from partner 
-- 26.01.2007 Jasna;Bug ID 26466 - added new field to oc_customers from partner (ne_na_bl)
-- 01.02.2007 Jelena; Task ID 4976 - added new field strong_payment into oc_contracts
-- 07.03.2007 Vik; Bug id 26501 - added new field to oc_customers from partner (watch_from)
-- 07.03.2007 Vik; fixed typing errors from bug 26273
-- 24.04.2007 Matjaz; removed check for negative values when virtually opening claims
-- 09.05.2007 Vilko; Bug ID 26605 - fixed calculation of fields max_dd, min_dd, max_dz and min_dz - fixed order of fields in select statement 
-- 14.05.2007 Vik; Bug id 26611 - improved id_terj retrieval for missing claim types
-- 28.05.2007 Matjaz; MR ID 1523 - added field moratorij_mes into oc_contracts
-- 03.10.2007 Natasa; TASK ID 5184 - added new table dbo.oc_contracts_future_details_m and use new settings from oc_settings 
-- 29.10.2007 Natasa; Bug id 26865; added field vr_promb to table oc_contracts 
-- 06.11.2007 Natasa; TASK ID 5184 - use new settings max_year_offset_future_details from oc_settings during prepare of oc_contracts_future_details
-- 08.11.2007 Matjaz; Maintenance ID 11883 - added missing condition for datum_dok at oc_lsk prepare. Also changed date condition from < to <= at oc_gl prepare.
-- 22.11.2007 Jasna; Maintenance ID 11846 - fixed mistake connected with referent_naziv field. Use naziv from dbo.referent table instead previously used poln_naz from dbo.partner tbl
-- 22.11.2007 Jasna; Maintenance ID 11846 - add fields naziv_dob and emso_dob in oc_customers tbl filled with naz_kr_kupca and emso from partner tbl (for supplier) 
-- 28.11.2007 Matjaz; Bug ID 27002 - bugfix changed column order when filling oc_gl table
-- 18.01.2008 Vik; Bug id 27069 - bugfix - advance saldo was not computed correctly (advance invoice was included in sum)
-- 12.03.2008 MatjazB; Bug ID 27217 - add field ex_max_dat_zap in oc_contracts
-- 26.03.2008 MatjazB; Bug ID 27232 - add fields ex_max_dd  and ex_max_dz in oc_contracts
-- 21.04.2008 MatjazB; Bug ID 27217 - combine update state for ex_max_dat_zap and ex_max_datum_dok in oc_contracts
-- 30.04.2008 Vilko; Bug ID 27297 - fixed calculating fields for undue buyout - fixed check of field opc
-- 09.05.2008 Jasna; MID 14004 - added new fields to oc_contracts (kategorija1,2,3)
-- 20.05.2008 Jasna; MID 14844 - added new field to oc_customers (neaktiven)
-- 29.05.2008 Ziga; Task ID 5285 - added fields ex_rint_instpreTD, ex_rint_instpostTD, ex_regist_instpreTD, ex_regist_instpostTD, ex_marza_instpreTD, ex_marza_instpostTD
-- 02.06.2008 MatjazB; Bug ID 27342 - for GL and LSK call gsp_oc_lsk_gl_prepare, added oc_claims_future
-- 03.07.2008 Ziga; Task ID 5285 - changed calculation of fields ex_net_instpreTD and ex_net_instpostTD -> pp.neto instead of pp.debit - pp.davek
-- 25.07.2008 Jasna; MID 16318 - modified calculation of ex_advance_saldo 
-- 25.07.2008 Matjaz; MID 16230 - added columns oc_contracts.ex_debit_sum and oc_contracts.ex_dom_debit_sum
-- 29.07.2008 Jasna; MID 15629 - added new fields to oc_customers (kategorija1,2,3)
-- 03.09.2008 Vik; MID 15768 - added new field to oc_customers (tuja_pio)
-- 11.11.2008 Ziga; Bug ID 27528 - claims for inactive contracts which ARE NOT IN (LOBR, POLO, OPC, DDV, VARS) with evident = '*' are also prepared
-- 28.01.2008 Jure; TASK 5470 - added field ddv_se_ne_odbija into table oc_contracts
-- 04.02.2009 Vik; added logging
-- 27.03.2009 Ziga; MID 19008 - added field ident_stevilka to table oc_customers
-- 21.05.2009 Ziga; Task ID 5531 - added fields povp_dzam and povp_dzam_observer to tables oc_customers and oc_contracts
-- 11.06.2009 Ziga Bug ID 27460 - added field net_nal_zac to oc_contracts
-- 06.08.2009 Matjaz; Task ID 5609 - added parameter daily and ajusted procedure to support prepare of daily snapshot into oc infrastructure
-- 27.08.2009 Ziga; Task ID 5599 - added prepare of tables oc_dokument, oc_frames, oc_frame_pogodba, oc_fa, oc_kred_pog, oc_kred_planp
-- 28.08.2009 Ziga; Task ID 5599 - moved updating contracts with contract coverage value from oc_transfer to this procedure
-- 07.09.2009 PetraR; MID 22202 - repaired updating of ex_coverage_value with s1 for yi < 1
-- 18.10.2009 PetraR; MID 22553 - modified calculation of advances - used temp table
-- 20.10.2009 MatjazB; MID 22445 - fix bug in updating contracts with contract coverage JOIN dav_stop ON p.id_dav_op = ds.id_dav_st
-- 02.11.2009 MatjazB; MID 22847 - added izd_os_izk to oc_customers (izd_os_izk)
-- 13.05.2010 Ziga; Bug ID 28307 - repaired calculation of fields ex_instpostTD, ex_instpreTD, ex_net_instpostTD,...
-- 28.07.2010 Natasa; Task ID 5982 - addded function gsp_oc_lsk_prom_prepare
-- 05.08.2010 Natasa; Task ID 5982 - removed function gsp_oc_lsk_prom_prepare, moved insert to o_lsk_promet to oc_lsk_gl_prepare
-- 10.08.2010 Ziga; MID 26006 - function gfn_GetValueTableFactor is used for calculating ex_factor and ex_coverage_value from vrst_opr
-- 10.09.2010 Natasa; TID 5982, added prepare_oc_lsk_promet to oc_reports
-- 11.04.2011 Natasa; TID 6183, added parameters code and id_oc_settings from oc_settings 
-- 09.05.2011 MatjazB; TID 6262 - added financiranje_zalog into pogodba
-- 10.05.2011 Natasa; TID 6183, check parameters values code and id_oc_settings 
-- 10.05.2011 Natasa; TID 6183, get value for settings daily from oc_settings 
-- 25.08.2011 Jure; MID 29278 - Added fileds ef_obrm_tren and tip_om into contract entity
-- 05.10.2011 Ziga; Task ID 6379 - changed parameters in function gfn_GetValueTableFactor
-- 11.10.2011 Ziga; Bug ID 29055 - frames are prepared before oc_dokument
-- 10.01.2012 MatjazB; Task 6648 - modify advances - use #konti_avansa instead of @kont_avansa
-- 23.02.2012 MatjazB; MID 33582 - modify oc_customers - added kategorija4-6
-- 05.04.2012 MatjazB; Task 6778 - use gsp_oc_customer_prepare for inserting into oc_customer
-- 12.04.2012 Ziga; Bug ID 29374 - added delete of records from oc_claims with saldo = 0 and ex_saldo_val = 0 and ex_saldo_val_claim = 0
-- 06.06.2012 MatjazB; Bug 29433 - handle deleted contracts (Inserting deleted contracts...)
-- 04.07.2012 MatjazB; Bug 29502 - move section for pogodba_deleted to new procedure gsp_oc_deleted_contracts
-- 02.01.2013 Josip; Task ID 7173 - added ol_na_nacin_fl
-- 12.02.2013 Ziga; Bug ID 29298 - changed condition for oc_claims, candidates are also inactive and partially active contracts with non emtpy ddv_id
-- 05.08.2013 Jost; Task ID 7513 - added field 'id_project' while transfering data from 'dbo.oc_contracts'
-- 23.09.2013 Uros; Task 7557 - added default_events handling
-- 13.01.2014 Jost; MID 40192 - set 'ex_coverage_value_zac' with p.vr_val_zac
-- 12.02.2014 Jost; MID 40192 - code refactoring for 'ex_coverage_value_zac'
-- 11.04.2014 Nenad; MID 44970 - changed where clause for oc_claims, POLO AND VARSC FOR OL are added to snapshot if evident = '*'
-- 19.05.2014 Jure; TASK 8055 - Added fields robresti, robresti_zac and robresti_sit on table oc_contracts
-- 26.05.2014 Jure; TASK XXXX - Added missing column id_datum_dok_create_type on table oc_contracts
-- 30.05.2014 IgorS; Task ID 8109 - added function gfn_VrValToNetoInternal for vr_val neto
-- 11.08.2014 Jure; MID 45172 - Added RIND_DAT_NEXT, ID_RIND_STRATEGIJE columns into oc_contract
-- 18.11.2014 Josip; Task ID 8376 - Added fields ex_g1_robresti_opc_nezap and ex_g2_robresti into oc_contracts, oc_contracts_future_details and oc_contracts_future_details_m
-- 15.01.2015 Domen; TaskID 8447 - Optimization: replacing gfn_Xchange with gfn_xchange_table
-- 19.02.2015 MatjazB; Task 8500 - added id_obd_obr, pyr_obr, dan_izr_obr and dni_zap_obr to oc_contracts
-- 12.03.2015 Matjaz; BUG ID 31564 - removed null value records when generating string with listo of advance accounts
-- 19.03.2015 Domen; TaskID 8558 - Speed optimizations: execute dbo.gfn_oc_get_undue_claim_sum only once
-- 20.03.2015 MatjazB; Task 8500 - table oc_contracts - rename dan_izr_obr to dat_obresti; added id_datum_dok_create_type_obr
-- 02.04.2015 Andrej; Task 8589 - added interest_template
-- 25.05.2015 Domen; TaskID 8558 - Speed optimizations: replacing "x in (select y" with "exists"
-- 26.05.2015 Jure: TASK 8680 - Added support for claim OOBR when interpret longterm claims ONLY.
-- 24.09.2015 Domen; MID 52348 - Adding filed dat_del_aktiv into oc_contracts
-- 02.11.2015 Andrej; Task 9031 - added variable @inactive_documents
-- 27.05.2016 Matjaz; modified on site - include option recompile
-- 28.05.2016 Matjaz; extract prepare of delimiting data into separate procedures
-- 21.10.2016 Jure; Task 9700 - removed planp.id_obr
-- 30.11.2016 MatjazB; MID 60218 - new filed user_created in oc_reports and new parameter @username
-- 29.12.2016 JozeM; TID 9809 - added gsp_oc_kategorije_prepare
-- 20.03.2017 Slobodan Vučetić; TID 9986 - now using SCOPE_IDENTITY()
-- 07.06.2017 Domen; BID 33191 - trimming description to 100 characters
-- 31.08.2017 Domen; BID 33307 - adding contracts presend in certain tables but not in oc_contracts
-- 03.11.2017 Matjaž S.&Joze M.& Predrag; zakomentiranje pogoja pri insertu v oc_contracts, tako da se vključijo vse pogodbe
---------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[gsp_oc_prepare]
    @date_to datetime,
    @filter_on_id_kupca bit,
    @id_kupca char(6),
    @prepare_advances bit,
    @prepare_undue_claims bit,
    @report_desc varchar(100),
    @daily bit,
	@code char(4) , 
	@id_oc_settings int = 0, 
    @username char(10) = null, 
    @report_id int output	
WITH RECOMPILE AS
--check settings 
---------------------------------------------------------
if @id_oc_settings <> 0 and @code is null 
	set @code = (select code from dbo.oc_settings where id_oc_settings = @id_oc_settings) 	
if @id_oc_settings = 0 and @code is not null 
	set @id_oc_settings = (select id_oc_settings from dbo.oc_settings where code = @code ) 	
if (@code <> (select code from dbo.oc_settings where id_oc_settings = @id_oc_settings))  
begin 
	RAISERROR('Invalid parameters value @code and @id_oc_settings ', 16, 1)
	return
end 
----------------------------------------------------------
if (@filter_on_id_kupca = 1 and @daily = 1)
begin 
	RAISERROR('Invalid parameter value - @filter_on_id_kupca = 1 and @daily = 1', 16, 1)
    return
end
------------------------------------------------------------------
-- get settings
DECLARE @prepare_oc_contracts_future_details bit -- prepare data for oc_contracts_future_details
DECLARE @max_year_offset_future_details tinyint -- max year offset for oc_contracts_future_details
DECLARE @prepare_oc_contracts_future_details_m bit -- prepare data for oc_contracts_future_details_m
DECLARE @max_month tinyint -- max month offset for oc_contracts_future_details_m
DECLARE @prepare_oc_claims_future bit -- prepare data for oc_claims_future
DECLARE @prepare_delim_part_of_int_in_claims bit -- prepare data for delimiting part of interests in claim
DECLARE @prepare_oc_lsk_and_oc_gl bit -- prepare data for oc_lsk and oc_gl
DECLARE @prepare_oc_contracts_future_by_type bit -- prepare data for oc_contracts_future_by_type
DECLARE @prepare_oc_lsk_promet bit -- prepare data for oc_lsk_promet
-- prepare data for specified tables at snapshot transfer
DECLARE @prepare_oc_dokument bit, @prepare_oc_frames bit, @prepare_oc_fa bit, @prepare_oc_kred_pog bit, @prepare_oc_pop_cashflow bit
DECLARE @recalculate_oc_dokument_at_transfer bit, @recalculate_oc_frames_at_transfer bit, @recalculate_oc_fa_at_transfer bit, @recalculate_oc_kred_pog_at_transfer bit
DECLARE @recalculate_oc_default_events_at_transfer bit, @prepare_oc_default_events bit
DECLARE @dok_list_rule varchar(1500)
DECLARE @id_oc_settings_t int -- values from oc_settings 
DECLARE @inactive_documents varchar(500)
SELECT TOP 1
	@prepare_oc_contracts_future_details = prepare_oc_contracts_future_details,
	@max_year_offset_future_details = max_year_offset_future_details,
	@prepare_oc_contracts_future_details_m = prepare_oc_contracts_future_details_m,
	@max_month = max_month_offset_future_details,
	@prepare_oc_claims_future = prepare_oc_claims_future,
	@prepare_delim_part_of_int_in_claims = prepare_delim_part_of_int_in_claims,
	@prepare_oc_lsk_and_oc_gl = prepare_oc_lsk_and_oc_gl,
	@prepare_oc_contracts_future_by_type = prepare_oc_contracts_future_by_type,
	@prepare_oc_dokument = prepare_oc_dokument,
	@prepare_oc_frames = prepare_oc_frames,
	@prepare_oc_fa = prepare_oc_fa,
	@prepare_oc_kred_pog = prepare_oc_kred_pog,
	@prepare_oc_pop_cashflow = prepare_oc_pop_cashflow,
	@recalculate_oc_dokument_at_transfer = recalculate_oc_dokument_at_transfer,
	@recalculate_oc_frames_at_transfer = recalculate_oc_frames_at_transfer,
	@recalculate_oc_fa_at_transfer = recalculate_oc_fa_at_transfer,
	@recalculate_oc_kred_pog_at_transfer = recalculate_oc_kred_pog_at_transfer,
	@dok_list_rule = dok_list_rule,
	@prepare_oc_lsk_promet = prepare_oc_lsk_promet,	
	@id_oc_settings = id_oc_settings,
	@daily = daily,
	@recalculate_oc_default_events_at_transfer = recalculate_oc_default_events_at_transfer,
	@prepare_oc_default_events = prepare_oc_default_events,
	@inactive_documents = inactive_documents
FROM dbo.oc_settings
WHERE code = @code 
------------------------------------------------------------------
IF @prepare_oc_lsk_and_oc_gl = 1
begin 
	-- check if ku_dnev is empty
	declare @ku_dnev_count int
	set @ku_dnev_count = (
	    select count(*) 
	    from dbo.ku_dnev 
	    where (@filter_on_id_kupca = 0 or id_kupca = @id_kupca)
	)
	if @ku_dnev_count > 0
	begin
	    RAISERROR('EKuDnevNotEmpty', 16, 1)
	    return 
	end
end
------------------------------------------------------------------
-- find unit name
DECLARE @unit_name char(10)
SET @unit_name = (SELECT TOP 1 entity_name FROM dbo.loc_nast)
declare @msg varchar(50)
declare @started_text varchar(max) 
set @started_text = 'Started'
	+ '. @date_to=' + cast(@date_to as varchar)
	+ ', @filter_on_id_kupca=' + cast(@filter_on_id_kupca as varchar)
	+ ', @id_kupca=' + cast(@id_kupca as varchar)
	+ ', @prepare_advances=' + cast(@prepare_advances as varchar)
	+ ', @prepare_undue_claims=' + cast(@prepare_undue_claims as varchar)
	+ ', @daily=' + cast(@daily as varchar)
	+ ', @code=' + cast(@code as varchar)
	+ ', @id_oc_settings=' + cast(@id_oc_settings as varchar)
    + ', @username=' + cast(isnull(@username, 'null') as varchar)
exec dbo.gsp_log_sproc 'gsp_oc_prepare', @started_text
----------------------------------------------------------
--create new report record and store its id
insert into dbo.oc_reports(
    report_name, unit_name, date_to, 
    filter_on_id_kupca, id_kupca,
    prepare_advances, prepare_undue_claims, [description],
    prepare_delim_part_of_int_in_claims,
    prepare_oc_contracts_future_details_m,
	prepare_oc_contracts_future_details,
	prepare_oc_claims_future,
	prepare_oc_lsk_and_oc_gl,
	prepare_oc_contracts_future_by_type,
	daily, recalculate_oc_dokument_at_transfer,
	recalculate_oc_frames_at_transfer,
	recalculate_oc_fa_at_transfer, 
	recalculate_oc_kred_pog_at_transfer,
	prepare_oc_dokument, prepare_oc_frames,
	prepare_oc_fa, prepare_oc_kred_pog,
	dok_list_rule,
	prepare_oc_lsk_promet,	
	code,
	id_oc_settings,
	recalculate_oc_default_events_at_transfer,
	prepare_oc_default_events,
	inactive_documents, 
    user_created 
)
values (
    'OC report',
    @unit_name,
    @date_to, 
    @filter_on_id_kupca, @id_kupca,
    @prepare_advances, @prepare_undue_claims, left(@report_desc, 100),
    @prepare_delim_part_of_int_in_claims,
    @prepare_oc_contracts_future_details_m,
	@prepare_oc_contracts_future_details,
	@prepare_oc_claims_future,
	@prepare_oc_lsk_and_oc_gl,
	@prepare_oc_contracts_future_by_type,
	@daily, @recalculate_oc_dokument_at_transfer,
	@recalculate_oc_frames_at_transfer,
	@recalculate_oc_fa_at_transfer, 
	@recalculate_oc_kred_pog_at_transfer,
	@prepare_oc_dokument, @prepare_oc_frames,
	@prepare_oc_fa, @prepare_oc_kred_pog,
	@dok_list_rule,
	@prepare_oc_lsk_promet,
	@code , 
	@id_oc_settings,
	@recalculate_oc_default_events_at_transfer, 
	@prepare_oc_default_events,
	@inactive_documents, 
    @username 
) 
set @report_id = CAST(SCOPE_IDENTITY() AS int)
set @msg = 'report id = ' + cast(@report_id as char(12))
exec dbo.gsp_log_sproc 'gsp_oc_prepare', @msg
----------------------------------------------------------
-- some commonly used data
declare @id_terj_opc char(2)
declare @id_terj_ddv char(2)
declare @id_terj_lobr char(2)
declare @id_terj_polo char(2)
declare @id_terj_vars char(2)
declare @id_terj_areg char(2)
declare @id_terj_oobr char(2)
set @id_terj_opc = (select id_terj from vrst_ter where sif_terj = 'OPC')
set @id_terj_ddv = (select id_terj from vrst_ter where sif_terj = 'DDV')
set @id_terj_polo = (select id_terj from vrst_ter where sif_terj = 'POLO')
set @id_terj_lobr = (select id_terj from vrst_ter where sif_terj = 'LOBR')
set @id_terj_vars = isnull((select id_terj from vrst_ter where sif_terj = 'VARS'), '!%')
set @id_terj_areg = isnull((select id_terj from vrst_ter where sif_terj = 'AREG'), '!%')
set @id_terj_oobr = (select id_terj from vrst_ter where sif_terj = 'OOBR')
----------------------------------------------------------
-- select candidate claims into table oc_claims
-- in the first step select all claims that are still open on this day
-- or were due after target_date (in that case their datum_dok<=target_date)
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'finding open claims...'
if @filter_on_id_kupca=1
    insert into dbo.oc_claims (
    	ID_CONT, DAT_ZAP, DATUM_DOK, ID_TERJ, ZAP_OBR, NETO, OBRESTI, ROBRESTI, MARZA, 
    	REGIST, DAVEK, DEBIT, KREDIT, SALDO, ZAPRTO, ST_DOK, ID_DAV_ST, DAV_VRED, 
    	ALI_FAK, ID_VAL, ID_TEC, EVIDENT, ID_KUPCA, NACIN_LEAS, DAT_OBR, NA_PLAN_PL, 
    	DAT_REVAL, DDV_ID, DAV_N, DAV_O, DAV_M, DAV_R, DAV_B, VEZA, ex_dni_zamude, id_oc_report
    )
    select 
    	pp.id_cont, pp.dat_zap, pp.datum_dok, pp.id_terj, pp.zap_obr, pp.neto, pp.obresti, pp.robresti, pp.marza, 
    	pp.regist, pp.davek, pp.debit, pp.kredit, pp.saldo, pp.zaprto, pp.st_dok, pp.id_dav_st, pp.dav_vred, 
    	pp.ali_fak, pp.id_val, pp.id_tec, pp.evident, pp.id_kupca, pp.nacin_leas, pp.dat_obr, pp.na_plan_pl, 
    	pp.dat_reval, pp.ddv_id, pp.dav_n, pp.dav_o, pp.dav_m, pp.dav_r, pp.dav_b, pp.veza , datediff(dd, pp.dat_zap, @date_to ), @report_id
    from dbo.planp pp 
    inner join dbo.pogodba po on po.id_cont=pp.id_cont 
    where
        pp.id_kupca=@id_kupca and
	    (po.status_akt in ('A','Z') 
			 or (po.status_akt = 'D' and pp.id_terj not in (@id_terj_opc, @id_terj_ddv, @id_terj_lobr) and pp.evident = '*') 
			 or (po.status_akt = 'N' and pp.id_terj not in (@id_terj_opc, @id_terj_ddv, @id_terj_polo, @id_terj_lobr, @id_terj_vars) and pp.evident = '*') 
			 or po.status_akt in ('N','D') and pp.ddv_id != '') and
		pp.id_terj <> @id_terj_areg and
		pp.datum_dok <= @date_to and
		(pp.saldo > 0 or           -- this claim is still not payed for completely (on this day)
			 pp.dat_zap > @date_to or  -- or it was due after target date, so on target date it was surely open
			 pp.evident = ' '          -- or it was not booked yet (but it can be closed)
			)
else
    
    insert into dbo.oc_claims (
    	ID_CONT, DAT_ZAP, DATUM_DOK, ID_TERJ, ZAP_OBR, NETO, OBRESTI, ROBRESTI, MARZA, 
    	REGIST, DAVEK, DEBIT, KREDIT, SALDO, ZAPRTO, ST_DOK, ID_DAV_ST, DAV_VRED, 
    	ALI_FAK, ID_VAL, ID_TEC, EVIDENT, ID_KUPCA, NACIN_LEAS, DAT_OBR, NA_PLAN_PL, 
    	DAT_REVAL, DDV_ID, DAV_N, DAV_O, DAV_M, DAV_R, DAV_B, VEZA, ex_dni_zamude, id_oc_report
    )
    select 
    	pp.id_cont, pp.dat_zap, pp.datum_dok, pp.id_terj, pp.zap_obr, pp.neto, pp.obresti, pp.robresti, pp.marza, 
    	pp.regist, pp.davek, pp.debit, pp.kredit, pp.saldo, pp.zaprto, pp.st_dok, pp.id_dav_st, pp.dav_vred, 
    	pp.ali_fak, pp.id_val, pp.id_tec, pp.evident, pp.id_kupca, pp.nacin_leas, pp.dat_obr, pp.na_plan_pl, 
    	pp.dat_reval, pp.ddv_id, pp.dav_n, pp.dav_o, pp.dav_m, pp.dav_r, pp.dav_b, pp.veza , datediff(dd, pp.dat_zap, @date_to ), @report_id
    from dbo.planp pp 
    inner join dbo.pogodba po on po.id_cont=pp.id_cont 
    where
		(po.status_akt in ('A','Z') 
		 or (po.status_akt = 'D' and pp.id_terj not in (@id_terj_opc, @id_terj_ddv, @id_terj_lobr) and pp.evident = '*') 
		 or (po.status_akt = 'N' and pp.id_terj not in (@id_terj_opc, @id_terj_ddv, @id_terj_polo, @id_terj_lobr, @id_terj_vars) and pp.evident = '*') 
		 or po.status_akt in ('N','D') and pp.ddv_id != '') and
		pp.id_terj <> @id_terj_areg and
		pp.datum_dok <= @date_to and
		(	pp.saldo > 0 or           -- this claim is still not payed for completely (on this day)
			pp.dat_zap > @date_to or  -- or it was due after target date, so on target date it was surely open
			pp.evident = ' '          -- or it was not booked yet (but it can be closed)
		)
----------------------------------------------------------------------------
-- find advance account
-- we assume(!) there is only one account and it is determined 
-- as the common account in plan_knj for events 'avans' and 'plac_iz_av'
-- if there are more such accounts then an error occurs
-- if there is no such account, variable is NULL, and we throw an exception
-- target account cannot be dependant on claim type ($PKTERJA stuff)
/*
declare @kont_avansa char(8)
set @kont_avansa = (
    select konto
    from dbo.akonplan
    where
    konto in (
            select dbo.gfn_VrniKontoNl(konto, nacin_leas) as konto
            from dbo.plan_knj
            where id_dogodka in ('avans')
            union
            select dbo.gfn_VrniKontoNl(protikonto, nacin_leas) as konto
            from dbo.plan_knj
            where id_dogodka in ('avans')
    ) and 
    konto in (
            select dbo.gfn_VrniKontoNl(konto, nacin_leas) as konto
            from dbo.plan_knj
            where id_dogodka in ('plac_iz_av')
            union
            select dbo.gfn_VrniKontoNl(protikonto, nacin_leas) as konto
            from dbo.plan_knj
            where id_dogodka in ('plac_iz_av')
    )
)
if @kont_avansa is null
begin
    RAISERROR('Advance account not specified.', 16, 1)
    return 
end
*/
-- Začasna tabela za # konte avansa -> DISTINCT ni potrebno, ker se to naredi z UNION-om
SELECT konto AS konto INTO #temp FROM dbo.plan_knj WHERE konto = '#AVANS'
UNION
SELECT protikonto AS konto FROM dbo.plan_knj WHERE protikonto = '#AVANS'
-- Dobimo konte avansa za vsak tip financiranja posebej in null -> DISTINCT ni potrebno, ker se to naredi z UNION-om
SELECT dbo.gfn_VrniKontoNl(k.konto, a.nacin_leas) AS konto 
INTO #konti_avansa
FROM dbo.nacini_l a, #temp k
UNION 
SELECT dbo.gfn_VrniKontoNl(k.konto, null) AS konto
FROM #temp k
DROP TABLE #temp
IF (SELECT count(*) FROM #konti_avansa) = 0
BEGIN
    RAISERROR('Advance account not specified.', 16, 1)
    return 
END
-- Pripravimo string za vse konte
DECLARE @kont_avansa varchar(4000), @konto char(8)
SET @kont_avansa = ''
DECLARE _konto CURSOR FAST_FORWARD FOR SELECT konto FROM #konti_avansa WHERE konto is not null
OPEN _konto
FETCH NEXT FROM _konto INTO @konto
IF @@fetch_status = 0  
BEGIN
    SET @kont_avansa = @kont_avansa + RTRIM(@konto) + ','
    FETCH NEXT FROM _konto INTO @konto
END
CLOSE _konto
DEALLOCATE _konto
SET @kont_avansa = LEFT(@kont_avansa, LEN(@kont_avansa)-1)
set @msg = 'Advance acc: ' + @kont_avansa 
exec dbo.gsp_log_sproc 'gsp_oc_prepare', @msg
 
------------------------------------------------------------
-- select history of events when payments closed claims
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Finding payments...'
select * 
into #payment_history
from dbo.gfn_oc_payment_history(@date_to, @filter_on_id_kupca, @id_kupca, @kont_avansa)
CREATE INDEX payment_history_index ON #payment_history (st_dok)
----------------------------------------------------------------------------
-- insert into oc_claims claims that exist 
-- in payment history and don't exist in oc_candidates
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Opening claims...'
insert into dbo.oc_claims (
	ID_CONT, DAT_ZAP, DATUM_DOK, ID_TERJ, ZAP_OBR, NETO, OBRESTI, ROBRESTI, MARZA, 
	REGIST, DAVEK, DEBIT, KREDIT, SALDO, ZAPRTO, ST_DOK, ID_DAV_ST, DAV_VRED, 
	ALI_FAK, ID_VAL, ID_TEC, EVIDENT, ID_KUPCA, NACIN_LEAS, DAT_OBR, NA_PLAN_PL, 
	DAT_REVAL, DDV_ID, DAV_N, DAV_O, DAV_M, DAV_R, DAV_B, VEZA, ex_dni_zamude, id_oc_report
)
select 
	pp.id_cont, pp.dat_zap, pp.datum_dok, pp.id_terj, pp.zap_obr, pp.neto, pp.obresti, pp.robresti, pp.marza, 
	pp.regist, pp.davek, pp.debit, pp.kredit, pp.saldo, pp.zaprto, pp.st_dok, pp.id_dav_st, pp.dav_vred, 
	pp.ali_fak, pp.id_val, pp.id_tec, pp.evident, pp.id_kupca, pp.nacin_leas, pp.dat_obr, pp.na_plan_pl, 
	pp.dat_reval, pp.ddv_id, pp.dav_n, pp.dav_o, pp.dav_m, pp.dav_r, pp.dav_b, pp.veza , datediff(dd, pp.dat_zap, @date_to ), @report_id
from dbo.planp pp 
where 
    exists (select 1 from #payment_history ph_f where ph_f.st_dok = pp.st_dok)
    and not exists (
        select oc.st_dok 
        from dbo.oc_claims oc 
        where id_oc_report = @report_id and oc.st_dok = pp.st_dok)
----------------------------------------------------------------------------
-- update extended values of claims (these values are changed later on)
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Updating open claims...'
update dbo.oc_claims
set 
	ex_debit_val = debit,
	ex_kredit_val = kredit,
	ex_saldo_val = saldo
where id_oc_report = @report_id
----------------------------------------------------------------------------
-- for all claims update kredit (virtually open these claims)
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'virtually opening claims...'
update dbo.oc_claims
set ex_kredit_val = c.ex_kredit_val - p.delta_kredit_val
from dbo.oc_claims c 
inner join #payment_history p on c.st_dok = p.st_dok
where c.id_oc_report = @report_id
----------------------------------------------------------------------------
-- recalculate saldo for all claims 
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'recalculating saldo...'
update dbo.oc_claims
set ex_saldo_val = ex_debit_val - ex_kredit_val
where id_oc_report = @report_id
-- perform small corrections due to rounding errors
-- we tolerate rounding error that result in amount mismatch
-- that is smaller than 1. otherwise we report an error.
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'oc_claims handle rounding errors...'
update dbo.oc_claims
set 
    ex_saldo_val = 
        case when ex_saldo_val<0 
        then 0 
        else ex_saldo_val end,
    ex_kredit_val = 
        case when ex_kredit_val>ex_debit_val 
        then ex_debit_val 
        else ex_kredit_val end 
where id_oc_report = @report_id
----------------------------------------------------------------------------
-- insert all contracts that exist in oc_claims into table oc_contracts
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Finding contracts...'
insert into dbo.oc_contracts(
    AKC_NAL, AKONT, ALI_PP, ALI_SDR, ANEKS, BEG_END, BREZ_DAVKA_DOM, BRUTO, 
    CENA_DKM, DAKONT, DAT_1OP, DAT_2OP, DAT_3OP, DAT_AKTIV, DAT_ARHIV, DAT_KKF, 
    DAT_OD1, DAT_PODPISA, DAT_POL, DAT_PREDR, DAT_SKLEN, DAT_ZAKL, DATUM_ODOB, DAV_OSNO, 
    DAV_OSNO_DOM, DDV, DDV_DOM, DDV_ID, DEJ_OBR, DISK_R, DISKONT, DNI_FINANC, 
    DNI_ZAP, DOBROCNO, DOVOL_KM, DVA_PP, EF_OBRM, FIX_DEL, ID, ID_CONT, 
    ID_DAV_OP, ID_DAV_ST, ID_DOB, id_grupe, ID_KREDPOG, ID_KUPCA1, ID_KUPCA, ID_OBD, 
    ID_OBRS, ID_OBRV, ID_OC_REPORT, ID_POG, ID_POG_ZAV, ID_PON, ID_POSREDNIK, ID_PROD, ID_REF, 
    ID_RTIP, ID_SKLIC, ID_STRM, ID_SVET, ID_TEC, ID_TECVR, ID_VAL, ID_VRSTE, 
    IZV_KOM, IZV_NAJ, IZVOZ, KASKO, KATEGORIJA, KDO_ODB, KK_MEMO, KON_NAJ, 
    KONSOLID, MAN_STR, MARZA_AV, MARZA_OB, MENIC, MPC, NACIN_LEAS, NACIN_MS, 
    NAZIV_TUJE, NEOBDAV_DOM, NET_NAL, NEXT_RPG_NUM, NJIH_ST, OBL_ZT, OBR_FINANC, OBR_MARZ, 
    OBR_MERA, OBR_MERAK, OBR_VIR1, OBR_VIR, OBROK1, OM_VARSC, OPC_DATZAD, 
    OPC_IMAOBR, OPCIJA, OPIS_PRED, OPOMBE, OST_OBR, OSTSTR, PLAC_ZAC, PO_TECAJU, 
    PRED_DDV, PRED_NAJ, PREDR_DO, PREJME_DO, PRENOS, PREVZETA, PRV_OBR, PRZA_EOM, 
    PSZAV, PYR, PZ_LET, PZ_ZAVAR, RABAT, RABAT_NAM, RABAT_NJIM, REF1, referent_naziv, REFINANC, 
    RIND_DATUM, RIND_FAKTOR, RIND_TDOL, RIND_TGOR, RIND_ZADNJI, RIND_ZAHTE, 
    SE_VARSC, SKLIC, SPL_POG, ID_ODOBRIT,
    ST_OBROK, ST_PREDR, STATUS, STATUS_AKT, STR_FINANC, STROSKI_PZ, STROSKI_X, 
    STROSKI_ZT, SUBLEASING, SYS_TS, TRAJ_NAJ, TROJNA_OPC, VARSCINA, VERIFIED, 
    VNESEL, VR_PROM, VR_SIT, VR_VAL, VRED_VAL, ZA_ODOBRIT, ZAC_NAJ, ZAP_2OB, 
    ZAP_OPC, ZAPADE_PZ, ZAPADE_ZF, ZAPADE_ZT, ZAV_FIN, ZE_AVANSA, ZE_PROVIZ, 
    ZN_REF1, ZN_REFINAN, ZT_ZAVAR,
    VR_VAL_ZAC, OBR_MERAK_ZAC, FIX_DELK_ZAC, 
    OBR_MERA_ZAC, FIX_DEL_ZAC, DEJ_OBR_ZAC, EF_OBRM_ZAC, ID_KUPCA_PL, STRONG_PAYMENT,
    MORATORIJ_MES, VR_PROMB, naziv_dob, emso_dob, kategorija1, kategorija2, kategorija3, 
    ddv_se_ne_odbija, povp_dzam, povp_dzam_observe, net_nal_zac, financiranje_zalog, 
    ef_obrm_tren, tip_om, id_project, id_datum_dok_create_type, robresti_val, robresti_zac, robresti_sit,
	RIND_DAT_NEXT, ID_RIND_STRATEGIJE, id_obd_obr, pyr_obr, dat_obresti, dni_zap_obr, id_datum_dok_create_type_obr, interest_template,
	dat_del_aktiv
)
select 
    po.akc_nal, po.akont, po.ali_pp, po.ali_sdr, po.aneks, po.beg_end, po.brez_davka_dom, po.bruto, 
    po.cena_dkm, po.dakont, po.dat_1op, po.dat_2op, po.dat_3op, po.dat_aktiv, po.dat_arhiv, po.dat_kkf,
    po.dat_od1, po.dat_podpisa, po.dat_pol, po.dat_predr, po.dat_sklen, po.dat_zakl, po.datum_odob, po.dav_osno, 
    po.dav_osno_dom, po.ddv, po.ddv_dom, po.ddv_id, po.dej_obr, po.disk_r, po.diskont, po.dni_financ, 
    po.dni_zap, po.dobrocno, po.dovol_km, po.dva_pp, po.ef_obrm, po.fix_del, po.id, po.id_cont, 
    po.id_dav_op, po.id_dav_st, po.id_dob, vo.id_grupe, po.id_kredpog, po.id_kupca1, po.id_kupca, po.id_obd, 
    po.id_obrs, po.id_obrv, @report_id, po.id_pog, po.id_pog_zav, po.id_pon, po.id_posrednik, po.id_prod, po.id_ref, 
    po.id_rtip, po.id_sklic, po.id_strm, po.id_svet, po.id_tec, po.id_tecvr, po.id_val, po.id_vrste,
    po.izv_kom, po.izv_naj, po.izvoz, po.kasko, po.kategorija, po.kdo_odb, po.kk_memo, po.kon_naj, 
    po.konsolid, po.man_str, po.marza_av, po.marza_ob, po.menic, po.mpc, po.nacin_leas, po.nacin_ms, 
    po.naziv_tuje, po.neobdav_dom, po.net_nal, po.next_rpg_num, po.njih_st, po.obl_zt, po.obr_financ, po.obr_marz, 
    po.obr_mera, po.obr_merak, po.obr_vir1, po.obr_vir, po.obrok1, po.om_varsc, po.opc_datzad, 
    po.opc_imaobr, po.opcija, po.opis_pred, po.opombe, po.ost_obr, po.oststr, po.plac_zac, po.po_tecaju, 
    po.pred_ddv, po.pred_naj, po.predr_do, po.prejme_do, po.prenos, po.prevzeta, po.prv_obr, po.prza_eom, 
    po.pszav, po.pyr, po.pz_let, po.pz_zavar, po.rabat, po.rabat_nam, po.rabat_njim, po.ref1, r.naziv as referent_naziv, po.refinanc,
    po.rind_datum, po.rind_faktor, po.rind_tdol, po.rind_tgor, po.rind_zadnji, po.rind_zahte, 
    po.se_varsc, po.sklic, po.spl_pog, po.id_odobrit,
    po.st_obrok, po.st_predr, po.status, po.status_akt, po.str_financ, po.stroski_pz, po.stroski_x, 
    po.stroski_zt, po.subleasing, cast(po.sys_ts as bigint) as sys_ts, po.traj_naj, po.trojna_opc, po.varscina, po.verified, 
    po.vnesel, po.vr_prom, po.vr_sit, po.vr_val, po.vred_val, po.za_odobrit, po.zac_naj, po.zap_2ob, 
    po.zap_opc, po.zapade_pz, po.zapade_zf, po.zapade_zt, po.zav_fin, po.ze_avansa, po.ze_proviz, 
    po.zn_ref1, po.zn_refinan, po.zt_zavar,
    po.vr_val_zac, pn.obr_merak as obr_merak_zac, pn.obr_merak - (pn.dej_obr - pn.fix_del) as fix_delk_zac, 
    pn.obr_mera as obr_mera_zac, pn.fix_del as fix_del_zac, pn.dej_obr as dej_obr_zac, pn.ef_obrm as ef_obrm_zac, po.id_kupca_pl, po.strong_payment, 
    po.moratorij_mes, po.vr_promb, pa.naz_kr_kup as naziv_dob, pa.emso as emso_dob, po.kategorija1, po.kategorija2, po.kategorija3, 
    po.ddv_se_ne_odbija, wp.povp_dzam, wp.povp_dzam_observe, po.net_nal_zac, po.financiranje_zalog, po.ef_obrm_tren, po.tip_om, po.id_project,
	po.id_datum_dok_create_type, po.robresti_val, po.robresti_zac, po.robresti_sit, 
	RIND_DAT_NEXT, ID_RIND_STRATEGIJE, po.id_obd_obr, po.pyr_obr, po.dat_obresti, po.dni_zap_obr, po.id_datum_dok_create_type_obr, po.interest_template,
	po.dat_del_aktiv
from dbo.pogodba po
inner join dbo.referent r on po.id_ref = r.id_ref
inner join dbo.vrst_opr vo on po.ID_VRSTE = vo.id_vrste
inner join dbo.partner pa on po.id_dob = pa.id_kupca
left join dbo.ponudba pn on po.id_pon = pn.id_pon
left join dbo.wavg_zam_pog wp on po.id_cont = wp.id_cont
where
    (
        (
            (
                @filter_on_id_kupca = 1 
                and 
                po.id_kupca = @id_kupca
            ) or (
                @filter_on_id_kupca = 0 
            )
        ) and 
                po.dat_sklen <= @date_to
    ) or exists (
        select 1
        from dbo.oc_claims c_f
        where c_f.id_cont = po.id_cont and c_f.id_oc_report = @report_id
    )
---------------------------------------------------------------------
--- perform calculation of not-yet-due claims
if @prepare_undue_claims=1 or (@prepare_oc_contracts_future_details_m = 1 AND @filter_on_id_kupca = 0) begin
	-- Make only one execution of dbo.gfn_oc_get_undue_claim_sum
	exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Calculating future claims - #undue_claim_sum'
	select *
	into #undue_claim_sum
	from dbo.gfn_oc_get_undue_claim_sum(@date_to, @filter_on_id_kupca, @id_kupca) a
	
	create clustered index pk on #undue_claim_sum (id_cont, id_terj, year_offset, month_offset)
end
if @prepare_undue_claims=1
begin
    
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Calculating future claims...'
	----------------------------------------------------------------------------
	-- calculate summarized values by claim groups and year offset into temporary table #tmp_future_claims
	exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Calculating future claims - #tmp_future_claims...'
    select 
        a.id_cont,
        sum(case when lobr_opc_polo_ddv = 1 then debit else 0 end) as ex_g1_debit,
        sum(case when lobr_opc_polo_ddv = 1 then neto else 0 end) as ex_g1_neto,
        sum(case when lobr_opc_polo_ddv = 1 then davek else 0 end) as ex_g1_davek,
        sum(case when lobr_opc_polo_ddv = 1 then marza else 0 end) as ex_g1_marza,
        sum(case when lobr_opc_polo_ddv = 1 then obresti else 0 end) as ex_g1_obresti,
        sum(case when lobr_opc_polo_ddv = 1 then a.robresti else 0 end) as ex_g1_robresti,
        sum(case when lobr_opc_polo_ddv = 1 then regist else 0 end) as ex_g1_regist,
        sum(case when lobr_opc_polo_ddv = 0 then debit else 0 end) as ex_g2_debit,
        sum(case when lobr_opc_polo_ddv = 0 then neto else 0 end) as ex_g2_neto,
        sum(case when lobr_opc_polo_ddv = 0 then davek else 0 end) as ex_g2_davek,
        sum(case when lobr_opc_polo_ddv = 0 then robresti else 0 end) as ex_g2_robresti,
        sum(case when lobr_opc_polo_ddv = 0 then debit-neto-davek-robresti else 0 end) as ex_g2_ostalo,
        sum(case when opc = 1 then debit_opc else 0 end) as ex_g1_debit_opc_nezap,
        sum(case when opc = 1 then neto_opc else 0 end) as ex_g1_neto_opc_nezap,
        sum(case when opc = 1 then davek_opc else 0 end) as ex_g1_davek_opc_nezap,
        sum(case when opc = 1 then robresti_opc else 0 end) as ex_g1_robresti_opc_nezap,
        sum(case when lobr_opc_polo_ddv = 1 and p.dobrocno=1 then davek else 0 end) as ex_g1_davek_fin,
        max(max_datum_dok) as ex_max_datum_dok,
        year_offset
    into #tmp_future_claims
    from #undue_claim_sum a
    inner join dbo.pogodba p on p.id_cont = a.id_cont
    group by a.id_cont, year_offset
    
    CREATE INDEX tmp_future_claims_index ON #tmp_future_claims (id_cont)
    CREATE INDEX tmp_future_claims_index2 ON #tmp_future_claims (id_cont, year_offset)
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -- insert all contracts that exist in #tmp_future_claims into table oc_contracts
    -- for snapshot we already insert all contracts
    if @filter_on_id_kupca = 1 
    begin
        insert into dbo.oc_contracts(
            AKC_NAL, AKONT, ALI_PP, ALI_SDR, ANEKS, BEG_END, BREZ_DAVKA_DOM, BRUTO, 
            CENA_DKM, DAKONT, DAT_1OP, DAT_2OP, DAT_3OP, DAT_AKTIV, DAT_ARHIV, DAT_KKF, 
            DAT_OD1, DAT_PODPISA, DAT_POL, DAT_PREDR, DAT_SKLEN, DAT_ZAKL, DATUM_ODOB, DAV_OSNO, 
         DAV_OSNO_DOM, DDV, DDV_DOM, DDV_ID, DEJ_OBR, DISK_R, DISKONT, DNI_FINANC, 
            DNI_ZAP, DOBROCNO, DOVOL_KM, DVA_PP, EF_OBRM, FIX_DEL, ID, ID_CONT, 
            ID_DAV_OP, ID_DAV_ST, ID_DOB, id_grupe, ID_KREDPOG, ID_KUPCA1, ID_KUPCA, ID_OBD, 
            ID_OBRS, ID_OBRV, ID_OC_REPORT, ID_POG, ID_POG_ZAV, ID_PON, ID_POSREDNIK, ID_PROD, ID_REF, 
            ID_RTIP, ID_SKLIC, ID_STRM, ID_SVET, ID_TEC, ID_TECVR, ID_VAL, ID_VRSTE, 
            IZV_KOM, IZV_NAJ, IZVOZ, KASKO, KATEGORIJA, KDO_ODB, KK_MEMO, KON_NAJ, 
            KONSOLID, MAN_STR, MARZA_AV, MARZA_OB, MENIC, MPC, NACIN_LEAS, NACIN_MS, 
            NAZIV_TUJE, NEOBDAV_DOM, NET_NAL, NEXT_RPG_NUM, NJIH_ST, OBL_ZT, OBR_FINANC, OBR_MARZ, 
            OBR_MERA, OBR_MERAK, OBR_VIR1, OBR_VIR, OBROK1, OM_VARSC, OPC_DATZAD, 
            OPC_IMAOBR, OPCIJA, OPIS_PRED, OPOMBE, OST_OBR, OSTSTR, PLAC_ZAC, PO_TECAJU, 
            PRED_DDV, PRED_NAJ, PREDR_DO, PREJME_DO, PRENOS, PREVZETA, PRV_OBR, PRZA_EOM, 
            PSZAV, PYR, PZ_LET, PZ_ZAVAR, RABAT, RABAT_NAM, RABAT_NJIM, REF1, referent_naziv, REFINANC, 
            RIND_DATUM, RIND_FAKTOR, RIND_TDOL, RIND_TGOR, RIND_ZADNJI, RIND_ZAHTE, 
            SE_VARSC, SKLIC, SPL_POG, ID_ODOBRIT,
            ST_OBROK, ST_PREDR, STATUS, STATUS_AKT, STR_FINANC, STROSKI_PZ, STROSKI_X, 
            STROSKI_ZT, SUBLEASING, SYS_TS, TRAJ_NAJ, TROJNA_OPC, VARSCINA, VERIFIED, 
            VNESEL, VR_PROM, VR_SIT, VR_VAL, VRED_VAL, ZA_ODOBRIT, ZAC_NAJ, ZAP_2OB, 
            ZAP_OPC, ZAPADE_PZ, ZAPADE_ZF, ZAPADE_ZT, ZAV_FIN, ZE_AVANSA, ZE_PROVIZ, 
            ZN_REF1, ZN_REFINAN, ZT_ZAVAR,
            VR_VAL_ZAC, OBR_MERAK_ZAC, FIX_DELK_ZAC, 
            OBR_MERA_ZAC, FIX_DEL_ZAC, DEJ_OBR_ZAC, EF_OBRM_ZAC, ID_KUPCA_PL, STRONG_PAYMENT, VR_PROMB,
            naziv_dob, emso_dob, kategorija1, kategorija2, kategorija3, ddv_se_ne_odbija, 
            povp_dzam, povp_dzam_observe, net_nal_zac, financiranje_zalog, EF_OBRM_TREN, tip_om, id_project,
			id_datum_dok_create_type, robresti_val, robresti_zac, robresti_sit,
			RIND_DAT_NEXT, ID_RIND_STRATEGIJE, id_obd_obr, pyr_obr, dat_obresti, dni_zap_obr, id_datum_dok_create_type_obr, interest_template,
			dat_del_aktiv
        )
        select 
            po.akc_nal, po.akont, po.ali_pp, po.ali_sdr, po.aneks, po.beg_end, po.brez_davka_dom, po.bruto, 
            po.cena_dkm, po.dakont, po.dat_1op, po.dat_2op, po.dat_3op, po.dat_aktiv, po.dat_arhiv, po.dat_kkf,
            po.dat_od1, po.dat_podpisa, po.dat_pol, po.dat_predr, po.dat_sklen, po.dat_zakl, po.datum_odob, po.dav_osno, 
            po.dav_osno_dom, po.ddv, po.ddv_dom, po.ddv_id, po.dej_obr, po.disk_r, po.diskont, po.dni_financ, 
            po.dni_zap, po.dobrocno, po.dovol_km, po.dva_pp, po.ef_obrm, po.fix_del, po.id, po.id_cont, 
            po.id_dav_op, po.id_dav_st, po.id_dob, vo.id_grupe, po.id_kredpog, po.id_kupca1, po.id_kupca, po.id_obd, 
            po.id_obrs, po.id_obrv, @report_id, po.id_pog, po.id_pog_zav, po.id_pon, po.id_posrednik, po.id_prod, po.id_ref, 
            po.id_rtip, po.id_sklic, po.id_strm, po.id_svet, po.id_tec, po.id_tecvr, po.id_val, po.id_vrste,
            po.izv_kom, po.izv_naj, po.izvoz, po.kasko, po.kategorija, po.kdo_odb, po.kk_memo, po.kon_naj, 
            po.konsolid, po.man_str, po.marza_av, po.marza_ob, po.menic, po.mpc, po.nacin_leas, po.nacin_ms, 
            po.naziv_tuje, po.neobdav_dom, po.net_nal, po.next_rpg_num, po.njih_st, po.obl_zt, po.obr_financ, po.obr_marz, 
            po.obr_mera, po.obr_merak, po.obr_vir1, po.obr_vir, po.obrok1, po.om_varsc, po.opc_datzad, 
            po.opc_imaobr, po.opcija, po.opis_pred, po.opombe, po.ost_obr, po.oststr, po.plac_zac, po.po_tecaju, 
            po.pred_ddv, po.pred_naj, po.predr_do, po.prejme_do, po.prenos, po.prevzeta, po.prv_obr, po.prza_eom, 
            po.pszav, po.pyr, po.pz_let, po.pz_zavar, po.rabat, po.rabat_nam, po.rabat_njim, po.ref1, r.naziv as referent_naziv, po.refinanc,
   po.rind_datum, po.rind_faktor, po.rind_tdol, po.rind_tgor, po.rind_zadnji, po.rind_zahte, 
            po.se_varsc, po.sklic, po.spl_pog, po.id_odobrit,
            po.st_obrok, po.st_predr, po.status, po.status_akt, po.str_financ, po.stroski_pz, po.stroski_x, 
            po.stroski_zt, po.subleasing, cast(po.sys_ts as bigint) as sys_ts, po.traj_naj, po.trojna_opc, po.varscina, po.verified, 
            po.vnesel, po.vr_prom, po.vr_sit, po.vr_val, po.vred_val, po.za_odobrit, po.zac_naj, po.zap_2ob, 
            po.zap_opc, po.zapade_pz, po.zapade_zf, po.zapade_zt, po.zav_fin, po.ze_avansa, po.ze_proviz, 
            po.zn_ref1, po.zn_refinan, po.zt_zavar,
	        po.VR_VAL_ZAC, pn.obr_merak as OBR_MERAK_ZAC, pn.obr_merak - (pn.dej_obr - pn.fix_del) as FIX_DELK_ZAC, 
	        pn.obr_mera as OBR_MERA_ZAC, pn.fix_del as FIX_DEL_ZAC, pn.dej_obr as DEJ_OBR_ZAC, pn.ef_obrm as EF_OBRM_ZAC, po.id_kupca_pl, po.strong_payment, po.vr_promb,
	        pa.naz_kr_kup as naziv_dob, pa.emso as emso_dob, po.kategorija1, po.kategorija2, po.kategorija3, po.ddv_se_ne_odbija, 
            wp.povp_dzam, wp.povp_dzam_observe, po.net_nal_zac, po.financiranje_zalog, po.EF_OBRM_TREN, po.tip_om, po.id_project,
            po.id_datum_dok_create_type, po.robresti_val, po.robresti_zac, po.robresti_sit, 
            po.RIND_DAT_NEXT, po.ID_RIND_STRATEGIJE, po.id_obd_obr, po.pyr_obr, po.dat_obresti, po.dni_zap_obr, po.id_datum_dok_create_type_obr, po.interest_template,
			po.dat_del_aktiv
        from dbo.pogodba po
        inner join dbo.referent r on po.id_ref = r.id_ref
        inner join dbo.vrst_opr vo on po.ID_VRSTE = vo.id_vrste
		inner join dbo.partner pa on pa.id_kupca = po.id_dob
		left outer join dbo.ponudba pn on po.id_pon = pn.id_pon
    	left join dbo.wavg_zam_pog wp on po.id_cont = wp.id_cont
        where 
            exists (select 1 from #tmp_future_claims fc_f where fc_f.id_cont = po.id_cont) and
            not exists (select 1 from dbo.oc_contracts c_f where c_f.id_cont = po.id_cont and c_f.id_oc_report=@report_id)
    end
	----------------------------------------------------------------------------
    -- update summarized future data
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Update contracts - summarized future data...'
    update dbo.oc_contracts
    set
        ex_g1_debit = a.ex_g1_debit, 
        ex_g1_debit_opc_nezap = a.ex_g1_debit_opc_nezap, 
        ex_g1_neto = a.ex_g1_neto,
        ex_g1_neto_opc_nezap = a.ex_g1_neto_opc_nezap, 
        ex_g1_obresti = a.ex_g1_obresti,
        ex_g1_marza = a.ex_g1_marza,
        ex_g1_davek = a.ex_g1_davek,
        ex_g1_davek_fin = a.ex_g1_davek_fin,
        ex_g1_davek_opc_nezap = a.ex_g1_davek_opc_nezap,
        ex_g1_robresti = a.ex_g1_robresti,
        ex_g1_robresti_opc_nezap = a.ex_g1_robresti_opc_nezap,
        ex_g1_regist = a.ex_g1_regist,
        ex_g2_debit = a.ex_g2_debit,
        ex_g2_neto = a.ex_g2_neto,
        ex_g2_davek = a.ex_g2_davek,
        ex_g2_robresti = a.ex_g2_robresti,
        ex_g2_ostalo = a.ex_g2_ostalo,
        ex_max_datum_dok = a.ex_max_datum_dok
    from 
        dbo.oc_contracts b 
        inner join (
            select 
                id_cont,
                sum(ex_g1_debit) as ex_g1_debit,
                sum(ex_g1_debit_opc_nezap) as ex_g1_debit_opc_nezap,
                sum(ex_g1_neto) as ex_g1_neto,
                sum(ex_g1_neto_opc_nezap) as ex_g1_neto_opc_nezap,
                sum(ex_g1_obresti) as ex_g1_obresti,
                sum(ex_g1_marza) as ex_g1_marza,
                sum(ex_g1_davek) as ex_g1_davek,
                sum(ex_g1_davek_fin) as ex_g1_davek_fin,
                sum(ex_g1_davek_opc_nezap) as ex_g1_davek_opc_nezap,
                sum(ex_g1_robresti) as ex_g1_robresti,
                sum(ex_g1_robresti_opc_nezap) as ex_g1_robresti_opc_nezap,
                sum(ex_g1_regist) as ex_g1_regist,
                sum(ex_g2_debit) as ex_g2_debit,
          sum(ex_g2_neto) as ex_g2_neto,
                sum(ex_g2_davek) as ex_g2_davek,
                sum(ex_g2_robresti) as ex_g2_robresti,
                sum(ex_g2_ostalo) as ex_g2_ostalo,
                max(ex_max_datum_dok) as ex_max_datum_dok
            from #tmp_future_claims 
            group by id_cont
        ) a on a.id_cont=b.id_cont
    where b.id_oc_report = @report_id
	----------------------------------------------------------------------------
	-- calculate summarized values by claim type
	if @prepare_oc_contracts_future_by_type = 1 AND @filter_on_id_kupca = 0 
	begin 
	    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Calculating future claims - oc_contracts_future_by_type...'
	    INSERT INTO dbo.oc_contracts_future_by_type(
	        id_oc_report, id_cont, id_terj, debit, 
	        davek, neto, obresti, marza, regist, robresti, 
	        max_dd, max_dz, min_dd, min_dz, claim_count)
	    select 
	        @report_id as id_oc_report,
	        s.id_cont,
	        id_terj,
	        sum(debit) as debit,
	        sum(davek) as davek,
	        sum(neto) as neto,
	        sum(obresti) as obresti,
	        sum(marza) as marza,
	        sum(regist) as regist,
	        sum(s.robresti) as robresti,
	        max(max_datum_dok) as max_dd,
	        max(max_dat_zap) as max_dz,
	        min(min_datum_dok) as min_dd,
	        min(min_dat_zap) as min_dz,
	        isnull(sum(claim_count), 0) as claim_count
	    from 
	        #undue_claim_sum s
	        inner join dbo.oc_contracts oc on oc.id_cont = s.id_cont and @report_id = oc.id_oc_report
	    group by s.id_cont, id_terj
	end
    
	----------------------------------------------------------------------------
    -- insert detail data into oc_contracts_future_details
	if @prepare_oc_contracts_future_details = 1 
	begin
		exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Calculating future claims - oc_contracts_future_details (step 1)...'
	    insert into dbo.oc_contracts_future_details(
	        id_cont, id_oc_report, year_offset_min, year_offset_max, 
	        ex_g1_debit,
	        ex_g1_debit_opc_nezap, 
	        ex_g1_neto, 
	        ex_g1_neto_opc_nezap, 
	        ex_g1_obresti, 
	        ex_g1_marza, 
	        ex_g1_davek,
	        ex_g1_davek_fin,
	        ex_g1_davek_opc_nezap,  
	        ex_g1_robresti, 
	        ex_g1_robresti_opc_nezap,  
	        ex_g1_regist, 
	        ex_g2_debit, 
	        ex_g2_neto, 
	        ex_g2_davek, 
	        ex_g2_robresti, 
	        ex_g2_ostalo
	    )
	    select 
	        id_cont, @report_id, year_offset, year_offset+1,
	        ex_g1_debit,
	        ex_g1_debit_opc_nezap,
	        ex_g1_neto,
	        ex_g1_neto_opc_nezap,
	        ex_g1_obresti,
	        ex_g1_marza,
	        ex_g1_davek,
	        ex_g1_davek_fin,
	        ex_g1_davek_opc_nezap,
	        ex_g1_robresti,
	        ex_g1_robresti_opc_nezap,
	        ex_g1_regist,
	        ex_g2_debit,
	        ex_g2_neto,
	        ex_g2_davek,
	        ex_g2_robresti,
	        ex_g2_ostalo
	    from #tmp_future_claims 
	    where year_offset < @max_year_offset_future_details -- @max_year
	    
		exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Calculating future claims - oc_contracts_future_details (step 2)...'
	    insert into dbo.oc_contracts_future_details(
	        id_cont, id_oc_report, year_offset_min, year_offset_max, 
	        ex_g1_debit,
	        ex_g1_debit_opc_nezap, 
	        ex_g1_neto, 
	        ex_g1_neto_opc_nezap, 
	        ex_g1_obresti, 
	        ex_g1_marza, 
	        ex_g1_davek,
	        ex_g1_davek_fin,
	        ex_g1_davek_opc_nezap,  
	        ex_g1_robresti, 
	        ex_g1_robresti_opc_nezap,  
	        ex_g1_regist, 
	        ex_g2_debit, 
	        ex_g2_neto, 
	        ex_g2_davek, 
	        ex_g2_robresti, 
	        ex_g2_ostalo
	    )
	    select 
	        id_cont, @report_id, @max_year_offset_future_details, @max_year_offset_future_details+1,
	        sum(ex_g1_debit),
	        sum(ex_g1_debit_opc_nezap),
	        sum(ex_g1_neto),
	        sum(ex_g1_neto_opc_nezap),
	        sum(ex_g1_obresti),
	        sum(ex_g1_marza),
	        sum(ex_g1_davek),
	        sum(ex_g1_davek_fin),
	        sum(ex_g1_davek_opc_nezap),
	        sum(ex_g1_robresti),
	        sum(ex_g1_robresti_opc_nezap),
	        sum(ex_g1_regist),
	        sum(ex_g2_debit),
	        sum(ex_g2_neto),
	        sum(ex_g2_davek),
	        sum(ex_g2_robresti),
	        sum(ex_g2_ostalo)
	    from #tmp_future_claims 
	    where year_offset >= @max_year_offset_future_details
	    group by id_cont
	end
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- insert all future claims that exist into oc_claims_future
IF @prepare_oc_claims_future = 1 AND @filter_on_id_kupca = 0
BEGIN
	exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Calculating future claims - oc_claims_future...'
	INSERT INTO dbo.oc_claims_future(
		   id_oc_report, ID_CONT, DAT_ZAP, DATUM_DOK, ID_TERJ, ZAP_OBR, NETO, OBRESTI, ROBRESTI, MARZA,
		   REGIST, DAVEK, DEBIT, KREDIT, SALDO, ZAPRTO, ST_DOK, ID_DAV_ST, DAV_VRED, ALI_FAK, ID_VAL,
		   ID_TEC, EVIDENT, ID_KUPCA, NACIN_LEAS, DAT_OBR, NA_PLAN_PL, DAT_REVAL, DDV_ID,
		   DAV_N, DAV_O, DAV_M, DAV_R, DAV_B, VEZA)
	SELECT @report_id, ID_CONT, DAT_ZAP, DATUM_DOK, ID_TERJ, ZAP_OBR, NETO, OBRESTI, ROBRESTI, MARZA,
		   REGIST, DAVEK, DEBIT, KREDIT, SALDO, ZAPRTO, ST_DOK, ID_DAV_ST, DAV_VRED, ALI_FAK, ID_VAL,
		   ID_TEC, EVIDENT, ID_KUPCA, NACIN_LEAS, DAT_OBR, NA_PLAN_PL, DAT_REVAL, DDV_ID,
		   DAV_N, DAV_O, DAV_M, DAV_R, DAV_B, VEZA
	  FROM dbo.planp pp
	 WHERE datum_dok > @date_to
	   AND exists (SELECT 1 FROM dbo.oc_contracts c_f WHERE c_f.id_cont = pp.id_cont and c_f.id_oc_report = @report_id)
END
----------------------------------------------------------------------------
-- insert data into oc_contracts_future_details_m
if @prepare_oc_contracts_future_details_m = 1 AND @filter_on_id_kupca = 0 
begin 
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'future claims by month (step 1)'
	insert into dbo.oc_contracts_future_details_m(
		id_cont, id_oc_report, month_offset_min, month_offset_max, 
		ex_g1_debit, 
		ex_g1_debit_opc_nezap, 
		ex_g1_neto, 
		ex_g1_neto_opc_nezap, 
		ex_g1_obresti, 
		ex_g1_marza, 
		ex_g1_davek, 
		ex_g1_davek_fin, 
		ex_g1_davek_opc_nezap, 
		ex_g1_robresti, 
		ex_g1_robresti_opc_nezap, 
		ex_g1_regist, 
		ex_g2_debit, 
		ex_g2_neto, 
		ex_g2_davek, 
		ex_g2_robresti, 
		ex_g2_ostalo)
	select 
		a.id_cont, @report_id, month_offset, month_offset+1,
	        sum(case when lobr_opc_polo_ddv = 1 then debit else 0 end) as ex_g1_debit,
	        sum(case when opc = 1 then debit_opc else 0 end) as ex_g1_debit_opc_nezap,
	        sum(case when lobr_opc_polo_ddv = 1 then neto else 0 end) as ex_g1_neto,
	        sum(case when opc = 1 then neto_opc else 0 end) as ex_g1_neto_opc_nezap,
	        sum(case when lobr_opc_polo_ddv = 1 then obresti else 0 end) as ex_g1_obresti,
	        sum(case when lobr_opc_polo_ddv = 1 then marza else 0 end) as ex_g1_marza,
	        sum(case when lobr_opc_polo_ddv = 1 then davek else 0 end) as ex_g1_davek,
	        sum(case when lobr_opc_polo_ddv = 1 and p.dobrocno=1 then davek else 0 end) as ex_g1_davek_fin,
	        sum(case when opc = 1 then davek_opc else 0 end) as ex_g1_davek_opc_nezap,
	        sum(case when lobr_opc_polo_ddv = 1 then a.robresti else 0 end) as ex_g1_robresti,
	        sum(case when opc = 1 then robresti_opc else 0 end) as ex_g1_robresti_opc_nezap,
	        sum(case when lobr_opc_polo_ddv = 1 then regist else 0 end) as ex_g1_regist,
	        sum(case when lobr_opc_polo_ddv = 0 then debit else 0 end) as ex_g2_debit,
	        sum(case when lobr_opc_polo_ddv = 0 then neto else 0 end) as ex_g2_neto,
	        sum(case when lobr_opc_polo_ddv = 0 then davek else 0 end) as ex_g2_davek,
	        sum(case when lobr_opc_polo_ddv = 0 then robresti else 0 end) as ex_g2_robresti,
	        sum(case when lobr_opc_polo_ddv = 0 then debit-neto-davek-robresti else 0 end) as ex_g2_ostalo
	from #undue_claim_sum a
	inner join dbo.pogodba p on p.id_cont = a.id_cont
	where month_offset < @max_month
	group by a.id_cont, month_offset
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'future claims by month (step 2)'
	insert into dbo.oc_contracts_future_details_m(
		id_cont, id_oc_report, month_offset_min, month_offset_max, 
		ex_g1_debit, 
		ex_g1_debit_opc_nezap, 
		ex_g1_neto, 
		ex_g1_neto_opc_nezap, 
		ex_g1_obresti, 
		ex_g1_marza, 
		ex_g1_davek, 
		ex_g1_davek_fin, 
		ex_g1_davek_opc_nezap, 
		ex_g1_robresti, 
		ex_g1_robresti_opc_nezap, 
		ex_g1_regist, 
		ex_g2_debit, 
		ex_g2_neto, 
		ex_g2_davek, 
		ex_g2_robresti, 
		ex_g2_ostalo)
	select 
		a.id_cont, @report_id, @max_month, @max_month+1,
	        sum(case when lobr_opc_polo_ddv = 1 then debit else 0 end) as ex_g1_debit,
	        sum(case when opc = 1 then debit_opc else 0 end) as ex_g1_debit_opc_nezap,
	        sum(case when lobr_opc_polo_ddv = 1 then neto else 0 end) as ex_g1_neto,
	        sum(case when opc = 1 then neto_opc else 0 end) as ex_g1_neto_opc_nezap,
	        sum(case when lobr_opc_polo_ddv = 1 then obresti else 0 end) as ex_g1_obresti,
	        sum(case when lobr_opc_polo_ddv = 1 then marza else 0 end) as ex_g1_marza,
	        sum(case when lobr_opc_polo_ddv = 1 then davek else 0 end) as ex_g1_davek,
	        sum(case when lobr_opc_polo_ddv = 1 and p.dobrocno=1 then davek else 0 end) as ex_g1_davek_fin,
	        sum(case when opc = 1 then davek_opc else 0 end) as ex_g1_davek_opc_nezap,
	        sum(case when lobr_opc_polo_ddv = 1 then a.robresti else 0 end) as ex_g1_robresti,
	        sum(case when opc = 1 then robresti_opc else 0 end) as ex_g1_robresti_opc_nezap,
	        sum(case when lobr_opc_polo_ddv = 1 then regist else 0 end) as ex_g1_regist,
	        sum(case when lobr_opc_polo_ddv = 0 then debit else 0 end) as ex_g2_debit,
	        sum(case when lobr_opc_polo_ddv = 0 then neto else 0 end) as ex_g2_neto,
	        sum(case when lobr_opc_polo_ddv = 0 then davek else 0 end) as ex_g2_davek,
	        sum(case when lobr_opc_polo_ddv = 0 then robresti else 0 end) as ex_g2_robresti,
	        sum(case when lobr_opc_polo_ddv = 0 then debit-neto-davek-robresti else 0 end) as ex_g2_ostalo
	from #undue_claim_sum a
	inner join dbo.pogodba p on p.id_cont = a.id_cont
	where month_offset >= @max_month
	group by a.id_cont
end 
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- insert customers into table oc_customers
EXEC dbo.gsp_oc_customer_prepare @report_id, @filter_on_id_kupca, @id_kupca, 1
----------------------------------------------------------------------------
-- calculate advances for each such customer
-- scan through lsk and sum all entries to calculate present value.
-- Exclude entries from 
-- (Vik- I guess this could be done faster using avansi table, but.......)
if @prepare_advances = 1
begin
    
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Calculating advances...'
    
    if @filter_on_id_kupca=1
    begin    
       select sum(kredit_dom - debit_dom) as kredit,
              id_kupca
         into #tempLsk
         from dbo.lsk l
        where datum_dok <= @date_to
          and exists (select 1 from #konti_avansa ka_f where ka_f.konto = l.konto)
          and id_kupca = @id_kupca
          and id_dogodka not in ('AVANS_FAKT', 'AV_FAK_AKT')
          and id_plac <> -1 -- s tem izkljucimo vknjižbe nastale kot posledica preknjiženja avansov neaktivih pogodb(za CRO)
		group by id_kupca
       having sum(kredit_dom - debit_dom) > 0
    
        update dbo.oc_customers
        set ex_advance_saldo = a.kredit
        from dbo.oc_customers c
        inner join #tempLsk a on c.id_kupca = a.id_kupca
        where c.id_oc_report = @report_id
        
        drop table #tempLsk
    end
    else
    begin
        select sum(kredit_dom - debit_dom) as kredit, id_kupca
        into #tempLsk1
		from dbo.lsk l with (nolock) --(index (IX_LSK_K_DD_V)) --with (index (ix_lsk_konto))
		where datum_dok <= @date_to 
		  and exists (select 1 from #konti_avansa ka_f where ka_f.konto = l.konto)
		  and id_dogodka not in ('AVANS_FAKT', 'AV_FAK_AKT') 
		  and id_plac <> -1 -- s tem izkljucimo vknjižbe nastale kot posledica preknjiženja avansov neaktivih pogodb(za CRO)
		group by id_kupca
		having sum(kredit_dom - debit_dom) > 0
    
        update dbo.oc_customers
        set ex_advance_saldo = a.kredit
        from dbo.oc_customers c
        inner join #tempLsk1 a on c.id_kupca=a.id_kupca
        where c.id_oc_report = @report_id
        
        drop table #tempLsk1
    end
end
DROP TABLE #konti_avansa
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables'
----------------------------------------------------------------------------
-- store amount to other set of members
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - oc_claims (step 1)'
update dbo.oc_claims
set 
    ex_debit_val_claim = ex_debit_val,
    ex_kredit_val_claim = ex_kredit_val,
    ex_saldo_val_claim = ex_saldo_val
from dbo.oc_claims 
where id_oc_report = @report_id
----------------------------------------------------------------------------
-- insert data from table vrst_ter into oc_claims
-- calculate open amount into contract currency (on datum_dok of claim!!!)
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - oc_claims (step 2)'
update dbo.oc_claims
set 
    ex_vrst_terj_naziv = b.naziv,
    ex_vrst_terj_sif_terj = b.sif_terj,
    ex_debit_val = ed.znesek,
    ex_kredit_val = ek.znesek,
    ex_saldo_val = es.znesek,
    ex_saldo_dom_dd = esdd.znesek,
    ex_saldo_dom = esd.znesek,
    ex_kredit_dom_dd = ekdd.znesek,
    ex_kredit_dom = ekd.znesek,
    ex_debit_dom_dd = eddd.znesek,
    ex_debit_dom = edd.znesek
from dbo.oc_claims a
inner join dbo.oc_contracts c on a.id_cont = c.id_cont
inner join dbo.vrst_ter b on a.id_terj=b.id_terj
outer apply dbo.gfn_xchange_table(c.id_tec, ex_debit_val, a.id_tec, a.datum_dok) ed
outer apply dbo.gfn_xchange_table(c.id_tec, ex_kredit_val, a.id_tec, a.datum_dok) ek
outer apply dbo.gfn_xchange_table(c.id_tec, ex_saldo_val, a.id_tec, a.datum_dok) es
outer apply dbo.gfn_xchange_table('000', ex_saldo_val_claim, a.id_tec, a.datum_dok) esdd
outer apply dbo.gfn_xchange_table('000', ex_saldo_val_claim, a.id_tec, @date_to) esd
outer apply dbo.gfn_xchange_table('000', ex_kredit_val_claim, a.id_tec, a.datum_dok) ekdd
outer apply dbo.gfn_xchange_table('000', ex_kredit_val_claim, a.id_tec, @date_to) ekd
outer apply dbo.gfn_xchange_table('000', ex_debit_val_claim, a.id_tec, a.datum_dok) eddd
outer apply dbo.gfn_xchange_table('000', ex_debit_val_claim, a.id_tec, @date_to) edd
where 
    a.id_oc_report = @report_id and
    c.id_oc_report = @report_id
----------------------------------------------------------------------------
-- calculate percentage of covered amount for each claim
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - oc_claims (step 3)'
update dbo.oc_claims
set 
    ex_procent = ex_kredit_val/ex_debit_val*100
from dbo.oc_claims
where 
    id_oc_report = @report_id and ex_debit_val <> 0
----------------------------------------------------------------------------
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing delete in table - oc_claims'
delete from dbo.oc_claims where id_oc_report = @report_id and saldo = 0 and ex_saldo_val = 0 and ex_saldo_val_claim = 0
----------------------------------------------------------------------------
-- add certain data from table nacini_l into oc_contracts
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - oc_contracts (step 1)'
update dbo.oc_contracts
set 
    ex_vrst_opr_naziv = b.naziv,
    ex_vrst_opr_id_grupe = b.id_grupe,
    ex_nacin_leas_odstej_var = c.odstej_var,
    ex_nacin_leas_finbruto = c.finbruto,
    ex_nacin_leas_fakt_zac = case when rtrim(c.fakt_zac) = '' then 0 else 1 end,
    ex_nacin_leas_leas_kred = c.leas_kred,
    ex_nacin_leas_tip_knjizenja = c.tip_knjizenja,
	ex_factor = dbo.gfn_GetValueTableFactor(a.dat_aktiv, @date_to, a.id_vrste, null, 2)
from 
    dbo.oc_contracts a
    inner join dbo.vrst_opr b on a.id_vrste=b.id_vrste
    inner join dbo.nacini_l c on a.nacin_leas=c.nacin_leas
where 
    a.id_oc_report = @report_id
-----------------------------------------------------------------------------
-- update ex_max_dat_zap
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - oc_contracts (step 2)'
UPDATE dbo.oc_contracts	SET 
	ex_max_dat_zap = A.max_dat_zap, 
	ex_max_datum_dok = A.max_dat_dok,
	ex_debit_sum = A.ex_debit_sum,
	ex_dom_debit_sum = A.ex_dom_debit_sum
FROM 
	dbo.oc_contracts c 
	LEFT JOIN (
		SELECT 
			MAX(c.dat_zap) AS max_dat_zap,
			MAX(c.datum_dok) AS max_dat_dok,
			SUM(ed.znesek) as ex_debit_sum,
			SUM(edd.znesek) as ex_dom_debit_sum,
			p.id_cont
		FROM 
			dbo.oc_contracts p
			LEFT JOIN dbo.planp c ON p.id_cont = c.id_cont 
			OUTER APPLY dbo.gfn_xchange_table(p.id_tec, c.debit, c.id_tec, @date_to) ed
			OUTER APPLY dbo.gfn_xchange_table('000', c.debit, c.id_tec, @date_to) edd
		WHERE 
			p.id_oc_report = @report_id
		GROUP BY p.id_cont, p.status_akt, p.dat_zakl
	) A ON c.id_cont = A.id_cont
WHERE c.id_oc_report = @report_id 
-----------------------------------------------------------------------------
-- update ex_max_dd and ex_max_dz
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - oc_contracts (step 3)'
UPDATE dbo.oc_contracts SET 
	ex_max_dd = A.max_datum_dok, 
	ex_max_dz = A.max_dat_zap
FROM 
	dbo.oc_contracts c 
	LEFT JOIN (
		SELECT 
			MAX(c.dat_zap) AS max_dat_zap, 
			MAX(c.datum_dok) AS max_datum_dok, 
			p.id_cont  
		FROM 
			dbo.oc_contracts p
			INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas
			LEFT JOIN dbo.planp c ON p.id_cont = c.id_cont
			LEFT JOIN dbo.vrst_ter t ON c.id_terj = t.id_terj
		WHERE 
			p.id_oc_report = @report_id
			AND ((n.tip_knjizenja = 2 AND n.ol_na_nacin_fl = 0) OR t.sif_terj <> 'OPC')
		GROUP BY p.id_cont
	) A ON c.id_cont = A.id_cont
WHERE c.id_oc_report = @report_id 
-----------------------------------------------------------------------------
-- prepare data for delimiting part of interests in claim
IF @prepare_delim_part_of_int_in_claims = 1
BEGIN
	exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - delimiting part of interests in claim (step 1)'
	
	exec dbo.gsp_oc_prepare_delim_part1 @id_terj_lobr, @id_terj_oobr, @report_id, @date_to
	exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - delimiting part of interests in claim (step 2)'
	exec dbo.gsp_oc_prepare_delim_part2 @id_terj_lobr, @id_terj_oobr, @report_id, @date_to
END
-- update contract coverage, coverage zac (coverage from lease-object value)
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Updating contracts with contract coverage...'
update dbo.oc_contracts
   set ex_coverage_value = dbo.gfn_VrValToNetoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto) 
							* p.ex_factor / 100,
   ex_coverage_value_zac = dbo.gfn_VrValToNetoInternal(p.vr_val_zac, p.robresti_zac, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto) 
							* p.ex_factor / 100
  from dbo.oc_contracts p
 inner join dbo.dav_stop ds ON p.id_dav_op = ds.id_dav_st
 inner join nacini_l nl on p.nacin_leas = nl.nacin_leas
 where p.id_oc_report = @report_id
 and nl.leas_kred = 'L'
 
-----------------------------------------------------------------------------
IF @filter_on_id_kupca = 0 AND @prepare_oc_lsk_and_oc_gl = 1
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Preparing oc_lsk...'
	EXEC dbo.gsp_oc_lsk_gl_prepare @report_id, @date_to
END
-----------------------------------------------------------------------------
IF @filter_on_id_kupca = 0 AND @prepare_oc_frames = 1
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Preparing oc_frames...'
	EXEC dbo.gsp_oc_frames_prepare @report_id, @date_to
END
-----------------------------------------------------------------------------
IF @filter_on_id_kupca = 0 AND @prepare_oc_dokument = 1
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Preparing oc_dokument...'
	EXEC dbo.gsp_oc_dokument_prepare @report_id, @date_to, @dok_list_rule, @inactive_documents
END
-----------------------------------------------------------------------------
IF @filter_on_id_kupca = 0 AND @prepare_oc_fa = 1
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Preparing oc_fa...'
	EXEC dbo.gsp_oc_fa_prepare @report_id
END
-----------------------------------------------------------------------------
IF @filter_on_id_kupca = 0 AND @prepare_oc_kred_pog = 1
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Preparing oc_kred_pog...'
	EXEC dbo.gsp_oc_kred_pog_prepare @report_id
END
-----------------------------------------------------------------------------
IF @filter_on_id_kupca = 0 AND @prepare_oc_pop_cashflow = 1
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Preparing oc_pop_cashflow tables...'
	EXEC dbo.gsp_oc_pop_cashflow_prepare @report_id
END
-----------------------------------------------------------------------------
IF @filter_on_id_kupca = 0
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Inserting missing contracts into oc_contracts...'
    EXEC dbo.gsp_oc_missing_contracts @report_id with recompile
END
-----------------------------------------------------------------------------
-- insert contracts which was deleted after target date
IF @filter_on_id_kupca = 0
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Inserting deleted contracts into oc_contracts...'
    EXEC dbo.gsp_oc_deleted_contracts @report_id
END
-----------------------------------------------------------------------------
IF @filter_on_id_kupca = 0 AND @prepare_oc_default_events = 1
BEGIN
    exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Preparing oc_default_events...'
    EXEC dbo.gsp_oc_default_events_prepare @report_id
END
-----------------------------------------------------------------------------
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Inserting oc_kategorije*'
exec dbo.gsp_oc_kategorije_prepare @report_id
-----------------------------------------------------------------------------
declare @finished_text varchar(max) 
set @finished_text = 'Finished. @report_id = ' + cast(@report_id as varchar)
exec dbo.gsp_log_sproc 'gsp_oc_prepare', @finished_text