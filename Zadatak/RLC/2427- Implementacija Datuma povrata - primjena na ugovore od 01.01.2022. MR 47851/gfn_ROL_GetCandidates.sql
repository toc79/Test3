-- USE [NOVA_PROD]
-- GO
-- /****** Object:  UserDefinedFunction [dbo].[gfn_ROL_GetCandidates]    Script Date: 04.05.2022 12:00:43 ******/
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO

-- ALTER Function [dbo].[gfn_ROL_GetCandidates] (@new int = 0)
Returns @result table
(
	id_cont int, id_pog char(11),
	id_kupca char(6), id_dob char(6),
	vr_val decimal(18,2), po_tecaju decimal(20,10),
	id_tec char(3), datum_sklapanja datetime,
	dat_sklen datetime, dat_podpisa datetime, 
	dat_aktiv datetime, status_akt char(1), 
	nacin_leas char(2), tip_leas char(2),
	davek decimal(5,2), margin_value decimal(18,2),
	se_regis char(1), id_grupe2 char(4),
	id_zapo char(7), p_dav_stev char(11),
	p_naz_kr_kup varchar(128), p_adresa varchar(128), 
	p_drzava char(2), d_dav_stev char(11),
	d_naz_kr_kup varchar(128), d_adresa varchar(128), 
	d_drzava char(2), obrok1 decimal(18,2),
	startDate datetime, endDate datetime,
	kon_naj datetime, zac_naj datetime
)  

Begin

	Declare @id_obl_zav char(2), @start_date int, @end_date int, @value_type int, @margin_value decimal(18,2), @contract_date int, @start_date_claims varchar(100)  
	--Declare @uses_add_objects int, @add_objects_document char(2), @add_objects_type int, @correction_value_document char(2), @oprema_tecaj int
	Declare @reklas_nl_OL char(2), @reklas_nl_FL char(2)
	Declare @zero decimal(18,2)
		
	Set @id_obl_zav = (Select isnull(val,'') From dbo.custom_settings Where code = 'ROL_DOCUMENT_DONT_SEND')
	Set @contract_date = (Select Cast(isnull(val,'0') As int) From dbo.custom_settings Where code = 'ROL_CONTRACT_DATE')
	Set @start_date = (Select Cast(isnull(val,'10') As int) From dbo.custom_settings Where code = 'ROL_START_DATE')
	-- RLC @start_date = 13
	Set @start_date_claims = (Select Cast(isnull(val,'LOBR') As varchar(100)) From dbo.custom_settings Where code = 'ROL_START_DATE_CLAIMS')
	Set @end_date = (Select Cast(isnull(val,'20') As int) From dbo.custom_settings Where code = 'ROL_END_DATE')
	-- RLC @end_date = 22
	Set @value_type = (Select Cast(isnull(val,'0') As int) From dbo.custom_settings Where code = 'ROL_VALUE_TYPE')
	Set @margin_value = (Select Cast(isnull(val,'0') As decimal(18,2)) From dbo.custom_settings Where code = 'ROL_MARGIN_VALUE')
	Set @reklas_nl_OL = 'O9'
	Set @reklas_nl_FL = 'F9'
	SET @zero = 0
	
--	Set @oprema_tecaj = (Select Cast(isnull(val,'0') As int) From dbo.custom_settings Where code = 'ROL_OPREMA_TEC')
--	Set @uses_add_objects = (Select Cast(isnull(val,'0') As int) From dbo.custom_settings Where code = 'ROL_USES_ADD_OBJECTS')
--	Set @add_objects_document = (Select Cast(isnull(val,'') As char(2)) From dbo.custom_settings Where code = 'ROL_ADD_OBJECT_DOCUMENT')
--	Set @add_objects_type = (Select Cast(isnull(val,'') As int) From dbo.custom_settings Where code = 'ROL_ADD_OBJECT_TYPE')
--	Set @correction_value_document = (Select Cast(isnull(val,'') As char(2)) From dbo.custom_settings Where code = 'ROL_CORRECTION_VALUE_DOCUMENT')

	Insert Into @result
	Select p.id_cont, 
		p.id_pog, 
		p.id_kupca, 
		p.id_dob, 
		--PROMJENA PREMA PRAVILNIKU 2014.-- Cast(Round(Case When @value_type = 1 Then p.vr_val_zac Else p.vr_val End / Case When nl.tip = 'F1' Then (1+(dv.davek/100)) Else 1 End,2) As decimal(18,2)) As vr_val, 
		@zero As vr_val, 
		p.po_tecaju, 
		p.id_tec, 
		Case When @contract_date = 0 Then p.dat_sklen
			When @contract_date = 1 Then p.dat_podpisa
			When @contract_date = 2 Then Coalesce(p.dat_podpisa, p.dat_aktiv)
		Else p.dat_sklen End As datum_sklapanja, --B.K. Da li ovdje mijenjati u p.dat_podpisa pošto je sad to propisani datum?
		p.dat_sklen,
		p.dat_podpisa, 
		p.dat_aktiv, 
		p.status_akt, 
		p.nacin_leas,
		nl.tip As tip_leas, 
		dv.davek, 
		Cast(Round(@margin_value / (1+(dv.davek/100)),2) As decimal(18,2)) As margin_value,
		vo.se_regis, 
		Cast(vo.id_grupe2 as char(4)) As id_grupe2, 
		Case When vo.se_regis = '*' Then zr.id_zapo Else zn.id_zapo End As id_zapo,
		Case When pa.drzavljan != 'HR' Then '' Else Cast(pa.dav_stev as char(11)) End As p_dav_stev, 
		pa.naz_kr_kup As p_naz_kr_kup, 
		Cast(RTRIM(pa.ulica_sed) +' '+ RTRIM(pa.mesto_sed) as varchar(128)) As p_adresa, 
		pa.drzavljan As p_drzava, 
		Case When pa1.drzavljan != 'HR' Then '' Else Cast(pa1.dav_stev as char(11)) End As p1_dav_stev, 
		pa1.naz_kr_kup As p1_naz_kr_kup, 
		Cast(RTRIM(pa1.ulica_sed) +' '+ RTRIM(pa1.mesto_sed) as varchar(128)) As p1_adresa, 
		pa1.drzavljan As p1_drzava,
		--PROMJENA PREMA PRAVILNIKU 2014.-- Cast(Round(p.obrok1 / Case When nl.tip = 'OL' Then (1+(dv1.davek/100)) Else 1 End,2) As decimal(18,2)) As obrok1, --B.K. isključenje pripreme rate
		@zero As obrok1,
		Case When @start_date = 10 Then p.dat_podpisa
			When @start_date = 11 Then p.dat_aktiv
			When @start_date = 12 Then pp.min_datum_dok
			When @start_date = 13 Then pp.min_datum_dok_lobr -- RLC = 13
			When @start_date = 14 Then p.zac_naj
			When @start_date = 15 Then pp.min_datum_dok_terj
			--PROMJENA PREMA PRAVILNIKU 2014.--
			When @start_date = 16 Then p.zac_naj --B.K. Ovdje u stvari nije potreban datum jer se neće računati trajanje već će se uzeti sa pogodbe ali mora se popuniti polje 			
		Else p.zac_naj End As startDate,
		Case When @end_date = 20 Then pp.max_datum_dok_lobr_opc
			When @end_date = 21 Then pp.max_datum_dok_lobr
			When @end_date = 22 Then dateadd(m,12/obd.obnaleto,pp.max_datum_dok_lobr)  -- RLC = 22
			When @end_date = 23 Then dateadd(m,12/obd.obnaleto,pp.max_datum_dok_lobr_opc)
			When @end_date = 24 Then pp.max_datum_dok
			When @end_date = 25 Then dateadd(m,12/obd.obnaleto,pp.max_datum_dok)
			When @end_date = 26 Then pp.max_dat_zap_lobr
			When @end_date = 27 Then p.kon_naj
			When @end_date = 28 and p.nacin_leas <> @reklas_nl_OL Then dateadd(m,12/obd.obnaleto,pp.max_datum_dok_lobr1) 
			When @end_date = 28 and p.nacin_leas = @reklas_nl_OL Then dateadd(m,12/obd.obnaleto,pp_reklas_FL.max_datum_dok_lobr1) 
		Else p.kon_naj End As endDate, 
		p.kon_naj, 
		p.zac_naj	 
	From dbo.pogodba p
	Left Join dbo.ROL r On p.id_cont = r.id_cont And @new = 1
	Left Join dbo.vrst_opr vo On p.id_vrste = vo.id_vrste
	Left Join dbo.partner pa On p.id_kupca = pa.id_kupca
	Left Join dbo.partner pa1 On p.id_dob = pa1.id_kupca
	Left Join dbo.dokument d On p.id_cont = d.id_cont And d.id_obl_zav = @id_obl_zav
	Left Join dbo.obdobja obd on p.id_obd = obd.id_obd
	Left Join (Select a.id_cont, a.id_zapo
				From dbo.zap_reg a
				Inner Join (Select id_cont, Min(id_zapo) As id_zapo
							From dbo.zap_reg
							Group by id_cont
				) b On a.id_cont = b.id_cont And a.id_zapo = b.id_zapo
	) zr On p.id_cont = zr.id_cont and vo.se_regis = '*'
	Left Join (Select a.id_cont, a.id_zapo
				From dbo.zap_ner a
				Inner Join (Select id_cont, Min(id_zapo) As id_zapo
							From dbo.zap_ner
							Group by id_cont
				) b On a.id_cont = b.id_cont And a.id_zapo = b.id_zapo
	) zn On p.id_cont = zn.id_cont and vo.se_regis = ''
	Left Join dbo.dav_stop dv On p.id_dav_op = dv.id_dav_st
	Left Join dbo.dav_stop dv1 On p.id_dav_st = dv1.id_dav_st
	Left Join (Select id_cont, Min(a.datum_dok) As min_datum_dok, 
				Min(Case When v.sif_terj = 'LOBR' Then a.datum_dok Else null End) As min_datum_dok_lobr,
				Min(Case When charindex(v.sif_terj, @start_date_claims) > 0 Then a.datum_dok Else null End) As min_datum_dok_terj,
				Max(a.datum_dok) As max_datum_dok, 
				Max(Case When v.sif_terj = 'LOBR' Then a.datum_dok Else null End) As max_datum_dok_lobr,
				Max(Case When v.sif_terj = 'LOBR' And a.obresti <> 0 Then a.datum_dok Else null End) As max_datum_dok_lobr1,
				Max(Case When v.sif_terj = 'OPC' Then a.datum_dok Else null End) As max_datum_dok_opc, 
				Max(Case When v.sif_terj in ('LOBR','OPC') Then a.datum_dok Else null End) As max_datum_dok_lobr_opc,
				Max(Case When v.sif_terj = 'LOBR' Then a.dat_zap Else null End) As max_dat_zap_lobr
				From dbo.planp a
				inner join dbo.vrst_ter v on a.id_terj = v.id_terj
				Group by a.id_cont
	)pp on p.id_cont = pp.id_cont
	Left Join (Select nacin_leas,
				Case When tip_knjizenja = '1' or (tip_knjizenja = '2' and ol_na_nacin_fl = 1) Then 'OL' --or (tip_knjizenja = '2' and ol_na_nacin_fl = 1)
				When tip_knjizenja = '2' and finbruto = 1 and ol_na_nacin_fl = 0 Then 'F1' -- and ol_na_nacin_fl = 0
				When tip_knjizenja = '2' and finbruto = 0 and ol_na_nacin_fl = 0 Then 'FF' -- and ol_na_nacin_fl = 0
				Else 'XX' End As tip
				From nacini_l
				Where leas_kred = 'L'
	) nl on p.nacin_leas = nl.nacin_leas
	left join (Select a.id_cont, b.prevzeta, Min(a.datum_dok) As min_datum_dok, 
				Min(Case When v.sif_terj = 'LOBR' Then a.datum_dok Else null End) As min_datum_dok_lobr,
				Min(Case When charindex(v.sif_terj, @start_date_claims) > 0 Then a.datum_dok Else null End) As min_datum_dok_terj,
				Max(a.datum_dok) As max_datum_dok, 
				Max(Case When v.sif_terj = 'LOBR' Then a.datum_dok Else null End) As max_datum_dok_lobr,
				Max(Case When v.sif_terj = 'LOBR' And a.obresti <> 0 Then a.datum_dok Else null End) As max_datum_dok_lobr1,
				Max(Case When v.sif_terj = 'OPC' Then a.datum_dok Else null End) As max_datum_dok_opc, 
				Max(Case When v.sif_terj in ('LOBR','OPC') Then a.datum_dok Else null End) As max_datum_dok_lobr_opc,
				Max(Case When v.sif_terj = 'LOBR' Then a.dat_zap Else null End) As max_dat_zap_lobr
				From dbo.planp a
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				inner join dbo.vrst_ter v on a.id_terj = v.id_terj
				Where b.nacin_leas = @reklas_nl_FL
				Group by a.id_cont, b.prevzeta
	) pp_reklas_FL on rtrim(p.id_pog) = rtrim(pp_reklas_FL.prevzeta) And p.nacin_leas = @reklas_nl_OL
	left join (Select id_cont, id_zapo
				From dbo.gfn_ROL_GetLatestObjectState()
				Where property = 0
				Group by id_cont, id_zapo
	) xx on @new = 0 and p.id_cont = xx.id_cont and xx.id_zapo = Case When vo.se_regis = '*' Then zr.id_zapo Else zn.id_zapo End
	Where d.id_cont Is Null And
	 
		((@new = 1 And r.id_cont Is Null
			And (
			--(@contract_date = 0 And p.status_akt In ('N','A','D')) OR
			(@contract_date = 1 And p.dat_podpisa Is Not Null And p.status_akt In ('N','A','D')) --Or
			--(@contract_date = 2 And ((p.status_akt = 'N' And p.dat_podpisa is not null) OR p.status_akt IN ('A','D')))
		)
		
		And nl.tip in ('F1','OL','FF')
		And ((vo.se_regis = '*' And zr.id_zapo Is Not Null) Or (vo.se_regis = '' And zn.id_zapo Is Not Null))
		) or (@new = 0 and xx.id_cont is not null))
	
	
	Order by p.id_cont
Return
End

