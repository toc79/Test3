-- USE [NOVA_PROD]
-- GO
-- /****** Object:  StoredProcedure [dbo].[gsp_ROL_GetNewObjects]    Script Date: 04.05.2022 11:58:27 ******/
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER OFF
-- GO
-- ALTER PROCEDURE [dbo].[gsp_ROL_GetNewObjects] @user char(10), @session_id char(38) = NULL
AS
BEGIN
	
	Declare @add_objects_document char(2), @add_objects_type int, @correction_value_document char(2), @oprema_tecaj int, @margin_value decimal(18,2), @opis_grupna_stavka varchar(256)
	Declare @zero decimal(18,2)
	SET @zero = 0
		
--	Set @uses_add_objects = (Select Cast(isnull(val,'0') As int) From dbo.custom_settings Where code = 'ROL_USES_ADD_OBJECTS')
	Set @add_objects_document = (Select Cast(isnull(val,'') As char(2)) From dbo.custom_settings Where code = 'ROL_ADD_OBJECT_DOCUMENT')
	Set @add_objects_type = (Select Cast(isnull(val,'') As int) From dbo.custom_settings Where code = 'ROL_ADD_OBJECT_TYPE')
	Set @correction_value_document = (Select Cast(isnull(val,'') As char(2)) From dbo.custom_settings Where code = 'ROL_CORRECTION_VALUE_DOCUMENT')
	Set @oprema_tecaj = (Select Cast(isnull(val,'0') As int) From dbo.custom_settings Where code = 'ROL_OPREMA_TEC')
	Set @margin_value = (Select Cast(isnull(val,'0') As decimal(18,2)) From dbo.custom_settings Where code = 'ROL_MARGIN_VALUE')
	Set @opis_grupna_stavka = (Select Cast(isnull(val,'SKUP OBJEKATA PO UGOVORU {0}') As varchar(256)) From dbo.custom_settings Where code = 'ROL_DESC_SUMMARY')

	Select p.id_cont, p.id_pog, p.id_kupca, p.id_dob, p.vr_val, 
	p.po_tecaju, p.id_tec, p.datum_sklapanja, p.dat_sklen, p.dat_podpisa, p.dat_aktiv, p.status_akt, p.tip_leas, p.davek, p.margin_value,
	p.se_regis, p.id_grupe2, p.id_zapo,
	p.p_dav_stev, p.p_naz_kr_kup, p.p_adresa, p.p_drzava,
	p.d_dav_stev, p.d_naz_kr_kup, p.d_adresa, p.d_drzava,
	p.obrok1, p.startDate, p.endDate, p.kon_naj, p.zac_naj,
	@user As username,	@session_id As session_id
	Into #candidates
	From dbo.gfn_ROL_GetCandidates (1) p
	

	/*ZAP_REG glavni objekti*/
	exec dbo.gsp_log_sproc 'ROL_data_prepare', 'Preparing new objects (ZAP_REG)...'
	Insert Into dbo.ROL_tmp(session_id, Id_object, id_cont, id_zapo, id_dokum, Summary, id_opreme, id_pog, id_kupca, C_type, Object_type, 
	C_begin, C_end, C_duration, 
	Supplier_state, Buyer_state, Object_identity, Object_make, Object_model, Supplier_name, Buyer_name, supplier_oib, 
	Buyer_oib, Net_installment, Supplier_address, Buyer_address, Object_value, Date_prepared, IsActive, username, id_object_tmp, registration, property)
	
	Select t.session_id, null, t.id_cont, t.id_zapo,
	null As id_dokum, 
	Cast(0 As bit) As summary, null, t.id_pog, t.id_kupca, t.tip_leas, 
	t.id_grupe2, 
	
	t.datum_sklapanja, Coalesce(t.endDate, t.kon_naj), DateDiff(m, Coalesce(t.startDate, t.zac_naj), Coalesce(t.endDate, t.kon_naj)),
	
	t.d_drzava, t.p_drzava, 
	Cast(zr.st_sas as varchar(128)) As st_sas, 
	Cast(zr.znamka as varchar(128)) As znamka, 
	Cast(zr.tip as varchar(256)) As tip, 
	t.d_naz_kr_kup, t.p_naz_kr_kup, t.d_dav_stev, t.p_dav_stev, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(t.obrok1, t.po_tecaju) As obrok1, 
	@zero As obrok1,
	t.d_adresa, t.p_adresa, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(Case When dok.id_dokum Is Not Null Then dok.vrednost Else t.vr_val End, t.po_tecaju) As vr_val, 
	@zero As vr_val,
	GetDate(), 1, t.username, 
	'$#&_' + Cast(t.id_cont As varchar(10)) + '_' + RTrim(t.id_zapo) + '_REG'  As id_object_tmp, Cast(1 as bit) as registration, Cast(0 as bit) As property
	From #candidates t
	Inner Join dbo.zap_reg zr On t.id_zapo = zr.id_zapo
	--PROMJENA PREMA PRAVILNIKU 2014.--Left Join dbo.dokument dok On t.id_cont = dok.id_cont And t.id_zapo = dok.id_zapo
	--	And (dok.id_obl_zav = @correction_value_document And dok.status_akt = 'A')
	Where t.id_zapo is not null and t.se_regis = '*' and zr.prodano = Cast(0 as bit) And t.session_id = @session_id --And t.id_grupe2 In ('GOSP','PLOV','LETJ','OSOB')
	Order by t.id_cont

	/*ZAP_REG 2R objekti*/
	exec dbo.gsp_log_sproc 'ROL_data_prepare', 'Preparing new objects (ZAP_REG)...'
	Insert Into dbo.ROL_tmp(session_id, Id_object, id_cont, id_zapo, id_dokum, Summary, id_opreme, id_pog, id_kupca, C_type, Object_type, C_begin, 
	C_end, C_duration, Supplier_state, Buyer_state, Object_identity, Object_make, Object_model, Supplier_name, Buyer_name, supplier_oib, 
	Buyer_oib, Net_installment, Supplier_address, Buyer_address, Object_value, Date_prepared, IsActive, username, id_object_tmp, registration, property)
	
	Select t.session_id, null, t.id_cont, t.id_zapo,
	dok.id_dokum As id_dokum, 
	Cast(0 As bit) As summary, null, t.id_pog, t.id_kupca, t.tip_leas, 
	Cast(dok.kategorija3 as char(4)) as id_grupe2 , 
	t.datum_sklapanja,  Coalesce(t.endDate, t.kon_naj), DateDiff(m, Coalesce(t.startDate, t.zac_naj), Coalesce(t.endDate, t.kon_naj)),
	t.d_drzava, t.p_drzava, 
	Cast(dok.stevilka as varchar(128)) As st_sas, 
	Cast(dok.opis1 as varchar(128)) As znamka, 
	Cast(dok.opombe as varchar(256)) As tip, 
	t.d_naz_kr_kup, t.p_naz_kr_kup, t.d_dav_stev, t.p_dav_stev, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(t.obrok1, t.po_tecaju) As obrok1, 
	@zero As obrok1, 
	t.d_adresa, t.p_adresa, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(dok.vrednost, t.po_tecaju) As vr_val, 
	@zero As vr_val, 
	GetDate(), 1, t.username, 
	'$#&_' + Cast(t.id_cont As varchar(10)) + '_' + RTrim(t.id_zapo) + '_' + RTrim(Cast(dok.id_dokum As varchar(10))) As id_object_tmp,
	Cast(1 as bit) as registration, Cast(0 as bit) As property
	From #candidates t
	Inner Join dbo.zap_reg zr On t.id_zapo = zr.id_zapo
	Inner Join dbo.dokument dok On t.id_cont = dok.id_cont And t.id_zapo = dok.id_zapo
		And (dok.id_obl_zav = @add_objects_document And dok.is_elligible = 0)
	Where t.id_zapo is not null and t.se_regis = '*' And t.session_id = @session_id
	Order by t.id_cont

	/*ZAP_NER pojedinačno*/
	exec dbo.gsp_log_sproc 'ROL_data_prepare', 'Preparing new objects (ZAP_NER)...'
	Insert Into dbo.ROL_tmp(session_id, Id_object, id_cont, id_zapo, Summary, id_opreme, id_pog, id_kupca, C_type, Object_type, C_begin, 
	C_end, C_duration, Supplier_state, Buyer_state, Object_identity, Object_make, Object_model, Supplier_name, Buyer_name, supplier_oib, 
	Buyer_oib, Net_installment, Supplier_address, Buyer_address, Object_value, Date_prepared, IsActive, username, id_object_tmp, registration, property)

	Select t.session_id, null, t.id_cont, o.id_zapo, Cast(0 As bit) As summary, o.id_opreme, t.id_pog, t.id_kupca, t.tip_leas, t.id_grupe2, t.datum_sklapanja, 
	Coalesce(t.endDate, t.kon_naj), DateDiff(m,Coalesce(t.startDate, t.zac_naj), Coalesce(t.endDate, t.kon_naj)), t.d_drzava, t.p_drzava, 
	Cast(IsNull(o.ser_st,'') As varchar(128)), 
	Cast(Coalesce(o.znamka, o.naziv) As varchar(128)) As znamka, 
	Cast(Coalesce(o.tip, o.naziv) As varchar(256)) As tip,
	t.d_naz_kr_kup, t.p_naz_kr_kup, t.d_dav_stev, t.p_dav_stev, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(t.obrok1, t.po_tecaju) As obrok1, 
	@zero As obrok1, 
	t.d_adresa, t.p_adresa, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(IsNull(o.nabav_vred,0), Case When @oprema_tecaj = 0 Then t.po_tecaju Else 1 End) As vr_val, 
	@zero As vr_val, 
	GetDate(), 1, t.username, 
	'$#&_' + Cast(t.id_cont As varchar(10)) + '_' + RTrim(o.id_zapo) + '_' + Cast(o.id_opreme As varchar(10)) As id_object_tmp,
	Cast(0 as bit) as registration, Cast(0 as bit) As property
	From #candidates t
	Inner Join dbo.oprema o On t.id_zapo = o.id_zapo and t.margin_value <= dbo.gfn_xr_val2dom(IsNull(o.nabav_vred,0), Case When @oprema_tecaj = 0 Then t.po_tecaju Else 1 End) And o.prodano = Cast(0 As bit)
	Where t.id_zapo Is Not Null And t.se_regis != '*' And t.id_grupe2 <> 'NEKR' And t.session_id = @session_id
	Order by t.id_cont

	/*ZAP_NER sumarno*/
	exec dbo.gsp_log_sproc 'ROL_data_prepare', 'Preparing new objects (ZAP_NER SUMMARY)...'
	Insert Into dbo.ROL_tmp(session_id, Id_object, id_cont, id_zapo, Summary, id_opreme, id_pog, id_kupca, C_type, Object_type, C_begin, 
	C_end, C_duration, Supplier_state, Buyer_state, Object_identity, Object_make, Object_model, Supplier_name, Buyer_name, supplier_oib, 
	Buyer_oib, Net_installment, Supplier_address, Buyer_address, Object_value, Date_prepared, IsActive, username, id_object_tmp, registration, property)

	Select t.session_id, null, t.id_cont, o.id_zapo, Cast(1 As bit) As summary,
	null, t.id_pog, t.id_kupca, t.tip_leas, t.id_grupe2, t.datum_sklapanja, Coalesce(t.endDate, t.kon_naj), DateDiff(m,Coalesce(t.startDate, t.zac_naj), Coalesce(t.endDate, t.kon_naj)),
	t.d_drzava, t.p_drzava, '', 
	REPLACE(@opis_grupna_stavka,'{0}', RTrim(t.id_pog)) As znamka, 
	REPLACE(@opis_grupna_stavka,'{0}', RTrim(t.id_pog)) As tip, 
	t.d_naz_kr_kup, t.p_naz_kr_kup, t.d_dav_stev, t.p_dav_stev, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(t.obrok1, t.po_tecaju) As obrok1, 
	@zero As obrok1, 
	t.d_adresa, t.p_adresa, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- o.nabav_vred As vr_val, 
	@zero As vr_val,
	GetDate(), 1, t.username, 
	'$#&_' + Cast(t.id_cont As varchar(10)) + '_' + RTRim(o.id_zapo) + '_SUMARRY' As id_object_tmp,
	Cast(0 as bit) as registration, Cast(0 as bit) As property
	From #candidates t
	inner join dbo.gfn_ROL_GetSumForNewSummaryObject(@margin_value, @oprema_tecaj) o On t.id_cont = o.id_cont And t.id_zapo = o.id_zapo
	Where t.id_zapo Is Not Null And t.se_regis != '*' And t.session_id = @session_id And t.id_grupe2 <> 'NEKR'
	Order by t.id_cont
	 
	/*ZAP_NER sumerno - detalji*/
	Insert Into dbo.ROL_details_tmp(session_id, Id_object, Id_object_tmp, Id_cont, Id_zapo, id_opreme, Object_value)
	Select t.session_id, null, '$#&_' + Cast(t.id_cont As varchar(10)) + '_' + RTRim(o.id_zapo) + '_SUMARRY' As id_object_tmp, t.id_cont, t.id_zapo, o.id_opreme, o.nabav_vred
	From #candidates t
	inner join dbo.gfn_ROL_GetOpremaForNewSummaryObject(@margin_value, @oprema_tecaj) o On t.id_cont = o.id_cont And t.id_zapo = o.id_zapo
	Where t.id_zapo Is Not Null And t.se_regis != '*' And t.session_id = @session_id And t.id_grupe2 <> 'NEKR'

	/*ZAP_NER NEKRETNINE*/
	exec dbo.gsp_log_sproc 'ROL_data_prepare', 'Preparing new objects (ZAP_NER NEKR)...'
	Insert Into dbo.ROL_tmp(session_id, Id_object, id_cont, id_zapo, Summary, id_opreme, id_pog, id_kupca, C_type, Object_type, C_begin, 
	C_end, C_duration, Supplier_state, Buyer_state, Object_identity, Object_make, Object_model, Supplier_name, Buyer_name, supplier_oib, 
	Buyer_oib, Net_installment, Supplier_address, Buyer_address, Object_value, Date_prepared, IsActive, username, id_object_tmp, registration, property)

	Select t.session_id, null, t.id_cont, o.id_zapo, Cast(0 As bit) As summary,
	null, t.id_pog, t.id_kupca, t.tip_leas, t.id_grupe2, t.datum_sklapanja, Coalesce(t.endDate, t.kon_naj), DateDiff(m,Coalesce(t.startDate, t.zac_naj), Coalesce(t.endDate, t.kon_naj)),
	t.d_drzava, t.p_drzava, 
	Cast(IsNull(o.st_vlozka,'') As varchar(128)), 
	--PROMJENA PREMA PRAVILNIKU 2014.-- Cast(o.opis as varchar(128)) As znamka, 
	Cast(o.k_o as varchar(128)) As znamka,
	cast(o.opis as varchar(256)) As tip,
	t.d_naz_kr_kup, t.p_naz_kr_kup, t.d_dav_stev, t.p_dav_stev, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(t.obrok1, t.po_tecaju) As obrok1, 
	@zero As obrok1,
	t.d_adresa, t.p_adresa, 
	--PROMJENA PREMA PRAVILNIKU 2014.-- dbo.gfn_xr_val2dom(Coalesce(opc.nabav_vred,t.vr_val), t.po_tecaju) As vr_val, 
	@zero As vr_val,
	GetDate(), 1, t.username, 
	'$#&_' + Cast(t.id_cont As varchar(10)) + '_' + RTrim(o.id_zapo) + '_NEKR' As id_object_tmp,
	Cast(0 as bit) as registration, Cast(1 as bit) As property
	From #candidates t
	Inner Join dbo.zap_ner o On t.id_zapo = o.id_zapo
	--PROMJENA PREMA PRAVILNIKU 2014.-- Left Join (Select a.id_opreme, a.id_zapo, a.nabav_vred
	--			From dbo.oprema a
	--			Inner Join (Select id_zapo, Min(id_opreme) As id_opreme
	--						From dbo.oprema
	--						Where IsNull(nabav_vred,0) <> 0
	--						Group by id_zapo
	--			) b On a.id_zapo = b.id_zapo And a.id_opreme = b.id_opreme
	--) opc On o.id_zapo = opc.id_zapo
	Where t.id_zapo Is Not Null And t.se_regis != '*' And t.id_grupe2 = 'NEKR'
	Order by t.id_cont

	Drop Table #candidates
End

