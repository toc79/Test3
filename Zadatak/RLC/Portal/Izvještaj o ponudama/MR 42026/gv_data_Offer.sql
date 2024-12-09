
---------------------------------------------------------------------------------------------
-- This view prepares commonly used data about offers.
--
-- History;
-- xx.xx.xxxx Vik; created
-- 19.01.2009 Vik; added field lease_type_leas_kred
-- 19.02.2011 MatjazB; Taks id 6180 - added fields dpr.id_pro_reg and dpr.pro_reg_count
-- 21.04.2011 Vik; Task id 6285 - added field dat_offer.id_cm_definition
-- 02.08.2011 Vilko; MID 31154 - added field au.phone as user_phone
-- 15.09.2011 Ales; Task id 6454 - added field au.user_type 
-- 23.04.2013 MatjazB; Task 7236 - added do.moratorium_months 
-- 30.08.2013 Ales; added field scoring_status
-- 23.09.2013 Ales; Task id 7619 - added field legal type from data offer
-- 01.10.2013 Ales; Task id 7620 - added field xml_additional_data
-- 17.10.2013 Ales; Task id 7442 - added object_type_name, object_model_name, object_make_name, object_category_name, object_group_name and object_equipment_name
-- 09.06.2014 PetraR; Task id 8129 - added r_interests
-- 18.06.2014 Ales; Task id 8129 - added show_r_interests
-- 11.07.2014 Jost; MID: 44767 - left join on dbo.ODS (read xml from there, not from do.xml_additional_data anymore)
-- 12.11.2014 Jost; TID: 8343 - added field stock_funding
-- 31.03.2015 PetraR; TID 8343 - added selection from ODS for stock_funding
-- 07.04.2016 Ales; MR 56486 - rebuild view for field full_name
-- 05.08.2016 Ales; MID 56082 - added column zap_2ob
-- 23.03.2017 Ales; BID 32880 - alter columns rebate_percent_total and rebate_percent_customer
-- 05.10.2017 Blaz; MID 67048 - added column hide_commission
---------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[gv_data_Offer]
AS
SELECT     
	do.id_data_offer, do.core_id, do.username, do.id_calc_customer, do.id_object, do.id_f_conditions, do.id_product, do.lease_type, do.offer_date, 
	do.customer_short_name, do.object_description, do.equipment_type_id, do.supplier_proforma_invoice_number, do.supplier_proforma_invoice_date, 
	do.supplier_proforma_invoice_valid_to, do.lease_period, do.price, do.lease_tax_rate_id, do.equipment_tax_rate_id, do.installment_count, do.bail_amount_net, 
	do.downpayment_amount_brut, do.downpayment_amount_net, do.installment_amount, do.interest_rate, do.initial_interest_rate, do.ir_index_id, do.ppyr_id, 
	do.residual_value_amount_brut, do.residual_value_amount_net, do.discount_interest_rate, do.rebate_percent_total, do.rebate_percent_customer, 
	do.claim_insurance_amount_brut, do.property_insurance_amount_brut, do.manipulative_costs_amount_brut, do.exchange_rate_id, do.currency_id, 
	do.finance_insurance_amount_brut, do.claim_insurance_percent, do.property_insurance_percent, do.finance_insurance_percent, do.supplier_short_name, 
	do.begin_end_mode, do.finance_interest_rate, do.finance_days, do.finance_cost_amount_brut, do.allowed_km, do.price_per_additional_km, do.date_inserted, 
	do.remarks, do.registration_advance_costs, do.notary_costs, do.actual_interest_rate, do.interest_margin, do.ir_index_date, do.tax_amount, do.vat_in_installments, 
	do.effective_interest_rate, do.customer_is_private_person, do.additional_costs_amount, do.x_costs_amount_brut, do.x_costs_percent, 
	do.manipulative_costs_percent, do.residual_value_percent, do.installment_brut, do.installment_net, do.downpayment_percent, do.ppyr, 
	do.payments_at_start_percent, do.bail_percent, do.price_brut, do.price_net, do.net_investment, do.payments_at_start_amount, do.discount_rv, do.mf_type, 
	do.rv_on_last_date, do.rv_has_interests, do.object_additional_desc, do.inactive, do.id_vendor, do.workflow_doc_id, do.id_cm_definition, do.moratorium_months, 
	lt.naziv AS lease_type_title, 
	lt.tip_knjizenja as lease_type_tip_knjizenja, 
	lt.eom_neto as lease_type_eom_neto,
	lt.dav_n as lease_type_dav_n,
	lt.dav_o as lease_type_dav_o,
	lt.leas_kred as lease_type_leas_kred,
	co.description AS calc_object_description, cet.naziv AS equip_type_title, cc.first_name AS customer_first_name, cc.last_name AS customer_last_name, 
	ISNULL(cc.full_name, do.customer_short_name) AS customer_full_name, cc.street AS customer_street, cc.town AS customer_town, cc.post_id AS customer_post_id, 
	cc.tax_id AS customer_tax_id, cc.legal_type AS customer_legal_type, cc.core_id AS customer_core_id, cp.name AS product_name, ppyr.naziv AS ppyr_title, 
	ppyr.obnaleto AS ppyr_ppyr, ciit.naziv AS ir_index_type_title, cex.naziv AS ex_rate_title, cex.id_val AS ex_rate_currency, au.userdesc AS user_userdesc, 
	au.email AS user_email, au.phone as user_phone, au.partner_core_id as user_core_id, av.core_id as vendor_core_id,
	cc2.core_id as customer_as_vendor_core_id,
	cc2.full_name AS customer_as_vendor_full_name,
	cc2.street + ', ' + cc2.town as customer_as_vendor_street,
	tr1.opis AS tr1_opis, tr1.davek AS tr1_davek, av.vendor_name, av.vendor_address, fc.display_name AS fin_cond_display_name, 
	fc.sys_name AS fin_cond_sys_name, fc.remarks AS fin_cond_remarks, tr2.davek AS tr2_davek, tr2.opis AS tr2_opis, do.uses_another_vendor, do.uses_another_vendor_id,
	dpr.id_pro_reg, dpr.pro_reg_count, au.user_type,
	do.scoring_status, do.legal_type, do.scoring_status_new, 
	ods.xml as xml_additional_data,
	co.type_name AS object_type_name, co.model_name AS object_model_name, co.make_name AS object_make_name, co.category_name AS object_category_name,
	co.group_name AS object_group_name, co.equipment_title AS object_equipment_name, do.r_interests,
	case when fc.r_interests_visible = 1 and lt.ima_robresti = 1 then cast(1 as bit)
	     else cast(0 as bit) end as show_r_interests,
    fc.stock_funding as stock_funding,
	do.zap_2ob as zap_2ob, do.hide_commission as hide_commission
FROM        
	dbo.data_Offer AS do 
	INNER JOIN dbo.admin_User AS au ON do.username = au.username 
	INNER JOIN dbo.admin_Vendor AS av ON do.id_vendor = av.id_vendor 
	INNER JOIN dbo.calc_FinConditions AS fc ON do.id_f_conditions = fc.id_f_conditions 
	--INNER JOIN dbo.calc_Object AS co ON do.id_object = co.id_object 
	INNER JOIN dbo.gv_calc_Object AS co ON do.id_object = co.id_object 
	INNER JOIN dbo.calc_Product AS cp ON do.id_product = cp.id_product 
	INNER JOIN dbo.core_EquipType AS cet ON do.equipment_type_id = cet.id_vrste 
	INNER JOIN dbo.core_ExRateId AS cex ON do.exchange_rate_id = cex.id_tec 
	INNER JOIN dbo.core_IrIndexType AS ciit ON do.ir_index_id = ciit.id_rtip 
	INNER JOIN dbo.core_LeaseType AS lt ON do.lease_type = lt.nacin_leas 
	INNER JOIN dbo.core_Ppyr AS ppyr ON do.ppyr_id = ppyr.id_obd 
	INNER JOIN dbo.core_TaxRates AS tr1 ON tr1.id_dav_st = do.lease_tax_rate_id 
	INNER JOIN dbo.core_TaxRates AS tr2 ON tr2.id_dav_st = do.equipment_tax_rate_id 
	LEFT OUTER JOIN dbo.data_Customer AS cc ON do.id_calc_customer = cc.id_customer 
	LEFT OUTER JOIN dbo.data_Customer AS cc2 ON do.uses_another_vendor_id = cc2.id_customer
	LEFT OUTER JOIN (
	    SELECT MAX(id_pro_reg) id_pro_reg, id_data_offer, COUNT(*) pro_reg_count
	    FROM dbo.data_ProtocolRegistration
	    GROUP BY id_data_offer
	    ) AS dpr ON do.id_data_offer = dpr.id_data_offer
	LEFT JOIN dbo.ODS ods on ods.id = do.id_data_Offer and ods.source in ('offer_scoring', 'offer_stockfunding')
