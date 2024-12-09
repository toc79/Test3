--02.11.2006 Nenad Milevoj prema zahtjevu Antonele
--07.06.2007 Vito Ispravak:
	 -- prilagođenje radi uzimanja pravilne baze brrlxx po različitim zemljama ovisno od entity_code 
	 -- pravilno označavanje retail / non retail s obzirom na asset_clas ne vezano za eval_model koji se zamjenio radi gams flaga
	 -- dodao sam gams_flag 
         -- popravio pravilno prikazivanje localproducttype-a s obzirom da se mora OL javljati samo za OL ugovore koji se ne modificiraju u FL   
	 -- popravio pravilno izračunavanje odr u CLAIMS te dodao polja glav_nedospj i glav_neproknj koji se moraju pribrojiti glavnica za NPV
--13.08.2007 Nenad Milevoj preinake prema zahtjevu Ane Dorić i Ivane
	-- dodana kolona Total_ODR, zahtjev za istovjetnosti podataka kao u izvještaju RL ODR
		-- uveden je @target_tecaj kako bi se istovjetno računao ex_saldo_val_target
			--sad se računa kao i u RL ODR: ex_saldo_val_target = ex_saldo_dom/@target_tecaj
		-- kako bi rerzultat bio isti u oba izvještaja još je napravljeno:
			/*
			1. uvedena su @sporna_potrazivanja='66,67,68'
			2. uvjeti su promjenjeni: trebaju i djelomično aktivni ugovori status_akt not in ('N','Z')
			3. maknut uvjet aneks#'T' te je maknut uvjet dat_aktiv < @target_date
			4. svi iznosi se preračunavaju na @target_date ili sa @target_tecaj
			*/
	-- promjenjen izračun NPV, sad je NPV=total_odr+glavnica (buduća glavnica)
		--promjenjen izračun kolone obligo
--28.08.2007 Vito: dodao sam status ugovora i promjenio klasifikaciju za retail (da se dobije iz eval_model)
--11.05.2011 Ziga; MID 29389 - added new field ost_nepoknj which is insluded in field NPV amount which is renamed to Risk exposure, added new column b2_total_exposure
--12.05.2011 Ziga; MID 29389 - removed bail from risk_exposure
--06.01.2012 Ziga; MID 33171 - added condition that only partialy active contracts with activation date in month of report are candidates
--12.10.2012 Nenad; MID 24361 - added new fields
--17.12.2012 Nenad; MID 24361 - added inacitve contracts, changed way of getting amounts from oc_claims
--29.10.2014 Josip; added fields for PPMV
--30.12.2014 Mladen; added rlc_present_val field in capital assets (custom calculation od present values of capital asset), changed field value sad_vrij_fa from ex_present_val in to rlc_present_val
--MID 33144 03.11.2015 OB poseban izračun pojedinih kolona za ugovore zakupa i najma
--MID 35559 17.05.2016 OB dodavanje kolone EWS dani i izmjenu izračuna kolone DPD counter
--28.02.2017 Jost; MID 61691 - fix: use new provisions implementation 
--08.03.2017 Jost; MID 61691 - combine logic for provisions (new and old)
--17.03.2017 Jost; MID 61691 - workaround: (oc_report on which provisions were calculated, is not always transfered in REA, therefore we take the lastest report with same target_date)
--MID 39560 16.01.2018 g_dejank, dodan id i naziv skis-a za partnera
--25.01.2018. Omar; MID 39767 - kreiranje izvještaja (AC-IZ) Present Value - sumarni pregled potraživanja po ugovorima IFRS9 (DW) ver 31.01.2018 
--29.03.2018 GMC Branislav; MID 40181 - replace usage gv_p_eval with function gfn_PEval_LastEvaluationOnTargetDate
--05.09.2018 g_tomislav; MID 39253 - added criteria db_name and new fields
--05.06.2019 Jadranka; MID 80421 - change due to new EBA methodology 
--03.12.2019 Jadranka; MID 80421 - correction retail counters
--11.12.2019 Jadranka; MID 80421 - correction dpd counters
--17.03.2021. g_vuradin; MID 46415 changed Risk Exposure
--02.04.2021. g_andrijap; MID 46007 dodana konta '150904', '189001', '282001', '282002'
--09.04.2021. g_vuradin; MID 46701 added PROVISION TYPE
--19.04.2021. g_vuradin; MID46701 izmjena PROVISION TYPE for CALCULATION TYPE i promjena konta za stage 1 i stage2
--19.04.2021. g_vuradin; MID47010 ograničenje opisnih kolona na 250 znakova
--05.01.2022. g_andrijap; MID 48121 dodno 
--02.04.2021. g_andrijap; MID 46007 dodano and b.booked = 1
--04.03.2022. g_tkovacev; MID 48459 dodavanje kolona obd.naziv i x.asset_clas
--16.02.2024. g_nenadm; MID - optimization for faster running
--31.05.2024. g_tomislav; MID 52290 - optimization for faster running

DECLARE	@id_oc_report int
DECLARE @id_tec char(3)
DECLARE @id_val char(3)
DECLARE @target_date datetime
DECLARE @entity_code char (5)
DECLARE @target_tecaj decimal (10,6)
DECLARE @sporna_potrazivanja char(8)

DECLARE @id_oc_report_orig int
DECLARE @id_prov_report_NRT int
DECLARE @id_prov_report_RET int
--DECLARE @db_name varchar(20)

SET    	@id_oc_report = {1}
SET     @id_tec= {3}
SET     @id_val = {5}
--SET     @db_name = '{9}' it is used directly in SELECT

DECLARE @odjel VARCHAR(100)
SET @odjel='{11}'

SELECT @entity_code = entity_code FROM dbo.gv_OcReports WHERE id_oc_report = @id_oc_report

Select @target_date=date_to from dbo.gv_OcReports Where id_oc_report=@id_oc_report
SET @target_tecaj = dbo.gfn_VrednostTecaja(@id_tec, @target_date,@id_oc_report)

Select @target_date=date_to, @id_oc_report_orig = id_oc_report_orig from dbo.gv_OcReports Where id_oc_report=@id_oc_report
create table #b2opprod (leasing_type char(2),id_vrste char(4), nacin_leas char(2), group_product_type_id char(6))


select top 1 @id_prov_report_NRT = id_prov_report
from {7}.dbo.PROVISIONS_REPORTS
where booked = 1 and report_type = 'NRT' 
	--and id_oc_report = @id_oc_report_orig
	and target_date = @target_date
order by id_prov_report desc

select top 1 @id_prov_report_RET = id_prov_report
from {7}.dbo.PROVISIONS_REPORTS
where booked = 1 and report_type = 'RET' 
	--and id_oc_report = @id_oc_report_orig
	and target_date = @target_date
order by id_prov_report desc


--PROVISION TYPE po OC_REPORTU

select distinct id_cont,calculation_type,a.id_oc_report 
into #PROVISION_TYPE_RET
from {7}.dbo.PROVISIONS_NON_RETAIL a
inner join {7}.dbo.PROVISIONS_REPORTS b on a.id_oc_report=b.id_oc_report 
   where report_type= 'NRT_IFRS9' and b.target_date=@target_date
	and b.booked = 1
   
select distinct id_cont,calculation_type,a.id_oc_report 
into #PROVISION_TYPE_NRT
from {7}.dbo.PROVISIONS_RETAIL a
inner join {7}.dbo.PROVISIONS_REPORTS b on a.id_oc_report=b.id_oc_report 
   where report_type= 'RET_IFRS9' and b.target_date=@target_date
	and b.booked = 1
   

-- EXCLUDE LEASE TYPES
SELECT id_key as nacin_leas
INTO #exclude_lease_types
FROM dbo.general_register
WHERE id_oc_report = @id_oc_report
AND id_register = 'RL_REGION_EXCLUDE_LEASE_TYPES'
AND neaktiven = 0


-- sumnjiva i sporna potrazivanja koja su nastala kao posljedica ponovnog uspostavljanja stanja nakon sto su stornirali sve buduce rate (zbog utuzenosti i sl.)
--SET @sporna_potrazivanja = '66,67,68'  

SET @sporna_potrazivanja = ''

--if  RTRIM(@entity_code) = 'RLHR' SET @sporna_potrazivanja = '66,67,68'  

if @entity_code = 'RRRS' 
begin
   insert into #b2opprod 
	select leasing_type,isnull(id_vrste,'####') as id_vrste,isnull(nacin_leas,'##') as nacin_leas,group_product_type_id
	from b2rlrent.dbo.b2opprod where client_id = @entity_code
end
else
begin
   insert into #b2opprod 
	select leasing_type,isnull(id_vrste,'####') as id_vrste,isnull(nacin_leas,'##') as nacin_leas,group_product_type_id
	from {7}.dbo.b2opprod where client_id = @entity_code
end

Select a.id_cont,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) <= 3 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_do_3m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 4 And 12 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_3m_do_12m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 13 And 60 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_1g_do_5g,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) >= 61 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_preko_5g,

sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) <= 3 then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ro_do_3m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 4 And 12 then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ro_3m_do_12m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 13 And 60 then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ro_1g_do_5g,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) >= 61 then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ro_preko_5g,

sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) <= 3 then dbo.gfn_xchange(@id_tec, a.obresti, a.id_tec, @target_date, @id_oc_report)  else 0 end) as o_do_3m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 4 And 12 then dbo.gfn_xchange(@id_tec, a.obresti, a.id_tec, @target_date, @id_oc_report)  else 0 end) as o_3m_do_12m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 13 And 60 then dbo.gfn_xchange(@id_tec, a.obresti, a.id_tec, @target_date, @id_oc_report)  else 0 end) as o_1g_do_5g,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) >= 61  then dbo.gfn_xchange(@id_tec, a.obresti, a.id_tec, @target_date, @id_oc_report)  else 0 end) as o_preko_5g,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) <= 3 then dbo.gfn_xchange(@id_tec, a.davek, a.id_tec, @target_date, @id_oc_report)  else 0 end) as p_do_3m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 4 And 12 then dbo.gfn_xchange(@id_tec, a.davek, a.id_tec, @target_date, @id_oc_report)  else 0 end) as p_3m_do_12m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 13 And 60 then dbo.gfn_xchange(@id_tec, a.davek, a.id_tec, @target_date, @id_oc_report)  else 0 end) as p_1g_do_5g,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) >= 61 then dbo.gfn_xchange(@id_tec, a.davek, a.id_tec, @target_date, @id_oc_report)  else 0 end) as p_preko_5g,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) <= 3 then dbo.gfn_xchange(@id_tec, a.regist, a.id_tec, @target_date, @id_oc_report)  else 0 end) as du_do_3m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 4 And 12 then dbo.gfn_xchange(@id_tec, a.regist, a.id_tec, @target_date, @id_oc_report)  else 0 end) as du_3m_do_12m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 13 And 60 then dbo.gfn_xchange(@id_tec, a.regist, a.id_tec, @target_date, @id_oc_report)  else 0 end) as du_1g_do_5g,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) >= 61 then dbo.gfn_xchange(@id_tec, a.regist, a.id_tec, @target_date, @id_oc_report)  else 0 end) as du_preko_5g,
sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) <= 3 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as opc_do_3m,
sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) between 4 And 12 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as opc_3m_do_12m,
sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) between 13 And 60 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as opc_1g_do_5g,
sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) >= 61 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as opc_preko_5g,

sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) <= 3 then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ropc_do_3m,
sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) between 4 And 12 then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ropc_3m_do_12m,
sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) between 13 And 60 then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ropc_1g_do_5g,
sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) >= 61 then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ropc_preko_5g,
sum(case when v.sif_terj = 'OPC' then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_opc,
sum(case when v.sif_terj = 'OPC' then dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) else 0 end) as ropc

INTO #futureclaims
from dbo.oc_claims_future a
inner join dbo.vrst_ter v on a.id_terj = v.id_terj And a.id_oc_report = v.id_oc_report
Where a.id_oc_report = @id_oc_report And v.sif_terj in ('POLO','LOBR','OPC','DDV') And a.datum_dok > @target_date
Group by a.id_cont

/*
Dodavanje DPD countera prema zahtjevu RLC-a 1252
	- DC3 ide prema partneru (id_kupca)
	- DCR ide prema ugovoru (id_cont)
*/
--NON RETAIL DPD COUNTER
Select 'EBS' as sif_d_event, NULL as id_cont, def_ev.def_start_date, def_ev.def_end_date, DATEDIFF(d, def_ev.def_start_date,@target_date) as dpd_counter, def_ev.id_kupca 
INTO #default_events
From dbo.default_events def_ev
Inner join dbo.default_events_register def_ev_r ON def_ev_r.id_oc_report = def_ev.id_oc_report
													AND def_ev.id_d_event = def_ev_r.id_d_event 
													AND def_ev_r.sif_d_event = 'EBS'
Where def_ev.id_oc_report = @id_oc_report
AND (def_ev.def_end_date IS NULL OR def_ev.def_end_date > @target_date)

--RETAL DPD COUNTER
INSERT INTO #default_events
Select 'EBD' as sif_d_event, null as id_cont, def_ev.def_start_date, def_ev.def_end_date, DATEDIFF(d, def_ev.def_start_date,@target_date) as dpd_counter, def_ev.id_kupca
From dbo.default_events def_ev
Inner join dbo.default_events_register def_ev_r ON def_ev_r.id_oc_report = def_ev.id_oc_report
													AND def_ev.id_d_event = def_ev_r.id_d_event 
													AND def_ev_r.sif_d_event = 'EBD'
Where def_ev.id_oc_report = @id_oc_report
AND (def_ev.def_end_date IS NULL OR def_ev.def_end_date > @target_date)

--MID 35559
UPDATE #default_events SET dpd_counter = 0 WHERE dpd_counter < 0

DECLARE @FixMargineTec AS CHAR(3), @FixMargine AS DECIMAL(18,2), @Margin AS DECIMAL(4,2)

SET @FixMargineTec = '006'
SET @FixMargine = 250
SET @Margin = 30

Select a.id_kupca, a.dat_zap, SUM(dbo.gfn_xchange(@FixMargineTec, a.saldo, a.id_tec, a.datum_dok, @id_oc_report)) as saldo
INTO #CLAIMS
From dbo.oc_claims a
Inner join dbo.oc_contracts b on a.id_cont = b.id_cont and b.status_akt = 'A' AND a.id_oc_report = b.id_oc_report
Where a.id_oc_report = @id_oc_report
AND a.dat_zap <= @target_date
AND a.evident = '*' AND  a.saldo > 0
Group by a.id_kupca, a.dat_zap	

Select a.id_kupca, a.dat_zap, a.saldo, RunningTotal = a.saldo + COALESCE(
			(SELECT SUM(i.saldo)
				FROM #CLAIMS i
				WHERE i.dat_zap < a.dat_zap AND i.id_kupca = a.id_kupca
				Group by i.id_kupca)
			, 0)
	, CAST((d.Obrok1/100)*@Margin AS DECIMAL(18,2)) AS Margin
	, @FixMargine as Fix_Margin
INTO #PP1
From #CLAIMS a
Inner join (Select id_kupca, SUM(dbo.gfn_Xchange(@FixMargineTec, obrok1, id_tec, @target_date, @id_oc_report)) as Obrok1
			From dbo.oc_contracts Where id_oc_report = @id_oc_report AND status_akt = 'A' Group by ID_KUPCA) d on a.ID_KUPCA = d.ID_KUPCA


Select id_kupca, MIN(dat_zap) as dat_zap,  DATEDIFF(dd, MIN(dat_zap), @target_date) AS EWS_O2_Counter
INTO #EWSO2
From #PP1 
Where RunningTotal >= Margin OR RunningTotal >= Fix_Margin 
Group by ID_KUPCA

--///////////////////////////////////////////////////
--g_tomislav MID 39253
--Datum dokumenta predzadnje rate i otkupa 
SELECT occ.id_cont, occ.nacin_leas, occ.ex_nacin_leas_tip_knjizenja 
into #id_contFromOc_contracts
FROM dbo.oc_contracts occ
WHERE occ.id_oc_report = @id_oc_report
and occ.nacin_leas != 'TP'
and (occ.status_akt = 'A' 
	or (occ.status_akt = 'D' and occ.dat_aktiv <= @target_date) 
	or (occ.status_akt = 'N' And occ.dat_podpisa is not null And occ.dat_podpisa <= @target_date) 
	or (occ.status_akt='Z' and occ.dat_zakl>@target_date)
	)

SELECT id_cont, {9}.dbo.gfn_GetOpcSt_dok(id_cont, nacin_leas) AS OpcSt_dok 
INTO #OPCST_DOKS_FL
FROM #id_contFromOc_contracts
where ex_nacin_leas_tip_knjizenja = 2 and nacin_leas != 'OF'

--Datum dokumenta otkupa
SELECT pp.id_cont, pp.datum_dok, pp.st_dok
INTO #OPCST_DOKS_DATUM_DOK
FROM {9}.dbo.planp pp
inner join #OPCST_DOKS_FL on OpcSt_dok = pp.st_dok
UNION ALL
SELECT pp.id_cont, max(pp.datum_dok) as datum_dok, max(pp.st_dok) as datum_dok
FROM {9}.dbo.planp pp
inner join #id_contFromOc_contracts ic on pp.id_cont = ic.id_cont
WHERE pp.id_terj = '23' 
and (ic.ex_nacin_leas_tip_knjizenja = 1 or ic.nacin_leas = 'OF')
group by pp.id_cont

--Datum zadnje rate za ugovore bez otkupa i s otkupom
SELECT pp.id_cont, max(pp.datum_dok) max_datum_dok 
INTO #PLANP_LOBR_MAX_DATUM_DOK
FROM {9}.dbo.planp pp
inner join #id_contFromOc_contracts ic on pp.id_cont = ic.id_cont
WHERE NOT EXISTS (SELECT * FROM #OPCST_DOKS_DATUM_DOK WHERE st_dok = pp.st_dok)
AND pp.id_terj = '21' --sif_terj = 'LOBR' -- za svaki slučaj ako OL ima dva otkupa 
GROUP BY pp.id_cont 

drop table #OPCST_DOKS_FL

-- Broj rate iz plana otplate
SELECT pp.id_cont, count(*) st_obrok 
INTO #PLANP_ST_OBROK
FROM {9}.dbo.planp pp
inner join {9}.dbo.vrst_ter vt on pp.id_terj = vt.id_terj 
inner join (Select id_cont From dbo.oc_contracts 
			Where id_oc_report  = @id_oc_report and 
			(status_akt = 'A' 
			or (status_akt = 'D' and dat_aktiv <= @target_date) 
			or (status_akt = 'N' And dat_podpisa is not null And dat_podpisa <= @target_date) 
			or (status_akt='Z' and dat_zakl>@target_date))
) b on pp.id_cont = b.id_cont
WHERE vt.sif_terj = 'LOBR' 
GROUP BY pp.id_cont

--Trenutni budući otkup za financijski leasing (za OL je izračunato u #futureclaims.g_opc i #futureclaims.ropc)
SELECT a.id_cont, a.datum_dok, a.zap_obr, a.neto, a.robresti, a.id_tec -- , a.st_dok
INTO #OC_CLAIMS_FUTURE_FL
FROM dbo.oc_claims_future a 
INNER JOIN dbo.nacini_l b ON a.nacin_leas = b.nacin_leas AND b.tip_knjizenja = '2' AND b.ol_na_nacin_fl = 0 AND a.id_oc_report = b.id_oc_report -- samo FL leas
INNER JOIN dbo.vrst_ter c ON a.id_terj = c.id_terj AND a.id_oc_report = c.id_oc_report
AND a.id_oc_report = @id_oc_report 
AND a.obresti = 0 
AND c.sif_terj = 'LOBR'

SELECT a.id_cont
	, dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) AS g_opc
	, dbo.gfn_xchange(@id_tec, a.robresti, a.id_tec, @target_date, @id_oc_report) AS ropc
INTO #OC_CLAIMS_FUTURE_FL_OTKUP
FROM (
	SELECT ROW_NUMBER () OVER(PARTITION BY a.id_cont ORDER BY zap_obr DESC) AS br_retka, 	--top 1  
	a.id_cont, a.datum_dok, a.zap_obr, a.neto, a.robresti, a.id_tec --, b.max_datum_dok 
	FROM #oc_claims_future_FL a
	INNER JOIN (SELECT id_cont, MAX(datum_dok) as max_datum_dok 
					FROM #oc_claims_future_FL
					GROUP BY id_cont) 
				b ON a.id_cont = b.id_cont AND a.datum_dok = b.max_datum_dok
) a
WHERE a.br_retka = 1
--MID 39253 KRAJ
--///////////////////////////////////////////////////


--FINAL
Select x.*, 
CASE WHEN ltrim(rtrim(x.p_status))='90D' or left(ltrim(rtrim(x.p_status)),1)='D' THEN 'YES' ELSE 'NO' END AS ODR,
b2op.group_product_type_id as GPC,
ROUND(dbo.gfn_VrValToNetoInternal(x.vrijed_ug, x.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto) * 
			(CASE WHEN x.koef < 1 THEN 1 ELSE 0 END +
				CASE WHEN x.koef = 1 THEN v.s1 ELSE 0 END +
				CASE WHEN x.koef = 2 THEN v.s2 ELSE 0 END +
				CASE WHEN x.koef = 3 THEN v.s3 ELSE 0 END +
				CASE WHEN x.koef = 4 THEN v.s4 ELSE 0 END +
				CASE WHEN x.koef = 5 THEN v.s5 ELSE 0 END +
				CASE WHEN x.koef = 6 THEN v.s6 ELSE 0 END +
				CASE WHEN x.koef = 7 THEN v.s7 ELSE 0 END +
				CASE WHEN x.koef = 8 THEN v.s8 ELSE 0 END +
				CASE WHEN x.koef = 9 THEN v.s9 ELSE 0 END +
				CASE WHEN x.koef > 9 THEN v.s10 ELSE 0 END), 2)/100 as trz_vrij_neto,
isnull(fc.g_do_3m,0) + x.glavnica_neproknj as g_do_3m, isnull(fc.g_3m_do_12m,0) as g_3m_do_12m, isnull(fc.g_1g_do_5g,0) as g_1g_do_5g, isnull(fc.g_preko_5g,0) as g_preko_5g,
isnull(fc.ro_do_3m,0) + x.robresti_neproknj as ro_do_3m, isnull(fc.ro_3m_do_12m,0) as ro_3m_do_12m, isnull(fc.ro_1g_do_5g,0) as ro_1g_do_5g, isnull(fc.ro_preko_5g,0) as ro_preko_5g,
isnull(fc.o_do_3m,0) + x.kamata_neproknj as o_do_3m, isnull(fc.o_3m_do_12m,0) as o_3m_do_12m, isnull(fc.o_1g_do_5g,0) as o_1g_do_5g, isnull(fc.o_preko_5g,0) as o_preko_5g,
isnull(fc.p_do_3m,0) + x.porez_neproknj as p_do_3m, isnull(fc.p_3m_do_12m,0) as p_3m_do_12m, isnull(fc.p_1g_do_5g,0) as p_1g_do_5g, isnull(fc.p_preko_5g,0) as p_preko_5g,
isnull(fc.du_do_3m,0) + x.dodusl_neproknj as du_do_3m, isnull(fc.du_3m_do_12m,0) as du_3m_do_12m, isnull(fc.du_1g_do_5g,0) as du_1g_do_5g, isnull(fc.du_preko_5g,0) as du_preko_5g,
isnull(fc.opc_do_3m,0) + x.otkup_neproknj as opc_do_3m, isnull(fc.opc_3m_do_12m,0) as opc_3m_do_12m, isnull(fc.opc_1g_do_5g,0) as opc_1g_do_5g, isnull(fc.opc_preko_5g,0) as opc_preko_5g,
isnull(fc.ropc_do_3m,0) + x.rotkup_neproknj as ropc_do_3m, isnull(fc.ropc_3m_do_12m,0) as ropc_3m_do_12m, isnull(fc.ropc_1g_do_5g,0) as ropc_1g_do_5g, isnull(fc.ropc_preko_5g,0) as ropc_preko_5g,
ug_sta.naziv as ug_sta_naziv,
p_kateg.naziv as p_kateg_naziv,
--case when @id_prov_report_NRT is null and @id_prov_report_RET is null 
--	then dbo.gfn_xchange(@id_tec, abs(isnull(pllp_old.debit_dom,0) - isnull(pllp_old.kredit_dom,0)) , '000', @target_date, @id_oc_report)	-- OLD Provisions
--	else isnull(pllp.provision_amount,0) -- NEW Provisions																				
--end as pllp,
--case when @id_prov_report_NRT is null and @id_prov_report_RET is null
--	then dbo.gfn_xchange(@id_tec, abs(isnull(illp_old.debit_dom,0) - isnull(illp_old.kredit_dom,0)), '000', @target_date, @id_oc_report)	-- OLD Provisions
--	else isnull(illp.provision_amount,0)	-- NEW Provisions
--end as illp,
dbo.gfn_xchange(@id_tec, abs(isnull(rrob.debit_dom,0) - isnull(rrob.kredit_dom,0)), '000', @target_date, @id_oc_report) as rrob,
CASE WHEN x.oznaka1 = 'R' THEN ISNULL(DE_R.dpd_counter, 0) ELSE ISNULL(DE_NR.dpd_counter, 0) END AS DPD_Counter, 
ISNULL(ew.EWS_O2_Counter, 0) as EWS_O2_Counter,
ss.id_skis, ss.opis as skis_opis, 
dbo.gfn_xchange(@id_tec, abs(isnull(ifrs9_1.debit_dom,0) - isnull(ifrs9_1.kredit_dom,0)) , '000', @target_date, @id_oc_report) as ifrs_stage1, 
dbo.gfn_xchange(@id_tec, abs(isnull(ifrs9_2.debit_dom,0) - isnull(ifrs9_2.kredit_dom,0)) , '000', @target_date, @id_oc_report) as ifrs_stage2, 
dbo.gfn_xchange(@id_tec, abs(isnull(ifrs9_3.debit_dom,0) - isnull(ifrs9_3.kredit_dom,0)) , '000', @target_date, @id_oc_report) as ifrs_stage3,
x.otkup + case when nl.odstej_var = 1 then x.jamcevina else 0 end ost_vred,
PLANP_LOBR_MAX_DATUM_DOK.max_datum_dok AS datum_dok_zadnje_rate,
PLANP_ST_OBROK.st_obrok AS planp_st_obrok,
OPCST_DOKS_DATUM_DOK.datum_dok AS opc_datum_dok,
COALESCE(fc.g_opc, OC_CLAIMS_FUTURE_FL_OTKUP.g_opc, 0.00) AS g_opc, COALESCE(fc.ropc, OC_CLAIMS_FUTURE_FL_OTKUP.ropc, 0.00) AS ropc,
COALESCE( ret.calculation_type, nrt.calculation_type, '') PROVISION_TYPE,
obd.naziv, x.asset_clas

FROM 
(
	Select 
	oc.id_pog, 
	oc.dat_aktiv, 
	oc.id_kupca, 
	op.polni_naz,op.sif_dej, dj.b2grupa, op.vr_osebe, op.asset_clas, op.naz_kr_kup,
	case when eval.eval_model in ('01','20') then 'R' else 'N' end as oznaka1,
	eval.eval_model as eval_model,
	eval.gams_flag,
	eval.cust_ratin, eval.coll_ratin, eval.oall_ratin,
	CASE WHEN oc.status_akt= 'Z' and oc.dat_zakl>@target_Date then 'A' ELSE oc.status_akt END as status_akt, 
--	nl.tip_leas+'-'+oc.id_grupe as lpi, 
	/*
	case when @entity_code = 'RLHR' then
		           case when (oc.ex_nacin_leas_tip_knjizenja = '1' and oc.dat_aktiv >= '20050101' and oc.nacin_leas <> 'OP') then 1
	                                                else 0 end
	        else case when @entity_code = 'RLSI' then
	                 case when oc.ex_nacin_leas_tip_knjizenja = '1' AND oc.nacin_leas IN ('ON') then 1 else 0 end
		     else 0 end
	        end 
	as real_oper_leas,
	*/
	case when oc.ex_nacin_leas_tip_knjizenja = '1' and {7}.dbo.gfn_MR_ol2fl(@entity_code, oc.ex_nacin_leas_tip_knjizenja, oc.dat_aktiv, oc.nacin_leas, oc.aneks, oc.id_cont) = 0 then 1 else 0 end as real_oper_leas,

	case when oc.ex_nacin_leas_leas_kred='K' then 'LO' else
		case when @entity_code = 'RLHR' then
			           case when (oc.ex_nacin_leas_tip_knjizenja = '1' and oc.dat_aktiv >= '20050101' and oc.nacin_leas <> 'OP') then 'OL'
		                                                else 'FL' end
		        else case when @entity_code = 'RLSI' then
		                 case when oc.ex_nacin_leas_tip_knjizenja = '1' AND oc.nacin_leas IN ('ON') then 'OL' else 'FL' end
			     else 'FL' end
		end 
	end
	as b2_leasing_type,
	
	
	case when oc.ex_nacin_leas_leas_kred='K' then 'LO' else
		case when @entity_code = 'RLHR' then
			           case when (oc.ex_nacin_leas_tip_knjizenja = '1' and oc.dat_aktiv >= '20050101' and oc.nacin_leas <> 'OP') then 'OL'
		                                                else 'FL' end
		        else case when @entity_code = 'RLSI' then
		                 case when oc.ex_nacin_leas_tip_knjizenja = '1' AND oc.nacin_leas IN ('ON') then 'OL' else 'FL' end
			     else 'FL' end
		end 
	end+'-'+oc.id_grupe as lpi,
	case when OC.ex_nacin_leas_leas_kred='K' and @entity_code = 'RLSI' then OC.nacin_leas else '##' end as tmp_nacin_leas,
	case when OC.ex_nacin_leas_leas_kred='K' and @entity_code = 'RLSI' then '####' else OC.id_vrste end as tmp_id_vrste,
	oc.nacin_leas+'-'+oc.id_vrste lspi, oc.ex_max_datum_dok,
	oc.nacin_leas, oc.id_vrste, oc.ex_vrst_opr_naziv As naz_id_vrste, oc.id_grupe,
	oc.st_obrok, oc.traj_naj,oc.aneks, oc.id_dav_st, oc.id_strm, oc.id_cont,oc.kon_naj,
	isnull(dbo.gfn_Xchange(@id_tec,oc.varscina,oc.id_tec,@target_date,@id_oc_report),0) as jamcevina,
	isnull(dbo.gfn_Xchange(@id_tec,oc.se_varsc,oc.id_tec,@target_date,@id_oc_report),0) as se_varsc,	
	isnull(dbo.gfn_Xchange(@id_tec,oc.prv_obr,oc.id_tec,@target_date,@id_oc_report),0) as akontacija,
	isnull(dbo.gfn_Xchange(@id_tec,oc.opcija,oc.id_tec,@target_date,@id_oc_report),0) as otkup,
	isnull(dbo.gfn_Xchange(@id_tec,oc.vr_val,oc.id_tec,@target_date,@id_oc_report),0) as vrijed_ug,
	isnull(dbo.gfn_Xchange(@id_tec,oc.robresti_val,oc.id_tec,@target_date,@id_oc_report),0) as robresti_val,
	isnull(dbo.gfn_Xchange(@id_tec,oc.net_nal,oc.id_tec,@target_date,@id_oc_report),0) as iznos_financ,
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto,oc.id_tec,@target_date,@id_oc_report),0) +isnull(odr.uk_glavnica_nedospj, 0)+isnull(odr.uk_glavnica_neproknj, 0) END as glavnicaPV,
	case when oc.status_akt in ('N','D') OR oc.nacin_leas IN (SELECT nacin_leas FROM #exclude_lease_types) THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(odr.uk_glavnica_neproknj, 0) END as glavnica,
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_robresti, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(odr.uk_robresti_neproknj, 0) END as robresti,
	isnull(odr.ost_nedospj,0) as ost_nedospj,
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_regist,oc.id_tec,@target_date,@id_oc_report),0) end as ostalo,
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto_opc_nezap,oc.id_tec,@target_date,@id_oc_report),0) + isnull(odr.otkup_nedospj,0) + isnull(odr.otkup_neproknj, 0) End as x, 
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_obresti,oc.id_tec,@target_date,@id_oc_report),0)+ isnull(odr.uk_kamata_neproknj,0) End as kamate, --+ isnull(odr.uk_kamata_nedospj,0)
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_davek,oc.id_tec,@target_date,@id_oc_report),0) End as porez,
	CASE WHEN oc.nacin_leas IN (SELECT nacin_leas FROM #exclude_lease_types) THEN 0 ELSE isnull(odr.otv_glav,0) END as otv_glav, 
	isnull(odr.otv_kamata,0) as otv_kamat,
	isnull(odr.otv_ostalo,0) as otv_ost,
	isnull(odr.otv_porez,0) as otv_porez,
	isnull(odr.otv_dodusl,0) as otv_dodusl,
	isnull(odr.otv_robresti,0) as otv_robresti,
	isnull(odr.uk_glavnica_neproknj,0) as glav_neproknj, 
	isnull(odr.uk_glavnica_nedospj,0) as glav_nedospj,
	
	isnull(odr.uk_robresti_neproknj,0) as robr_neproknj, 
	isnull(odr.uk_robresti_nedospj,0) as robr_nedospj,
	 
	isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin+case when ((oc.status_akt='Z' and oc.dat_zakl<=@target_date) or oc.aneks='T') then 0 else oc.varscina end,oc.id_tec,@target_date,@id_oc_report),0) as glav_oc_contract,	 
	isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin+case when ((oc.status_akt='Z' and oc.dat_zakl<=@target_date) or oc.aneks='T') then 0 else oc.varscina end, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(odr.uk_glavnica_nedospj, 0)+isnull(odr.uk_glavnica_neproknj, 0)+isnull(odr.otv_ostalo, 0)+isnull(odr.overdue, 0) as obligo,	
	--prema RL ODR izvješau suma svih otvorenih potraživanja osim spornih potraživanja
	isnull(odr.otv_ostalo,0)+isnull(odr.overdue,0) as tot_odr,
	-- leasing NPV amount (RISK EXPOSURE) (total ODR + bodoca glavnica + poknjizeno nezapadlo)
	/*MID 10115 Booked not dued, kolone Glavnica PV i Total ODR: zbroj sve tri kolone mora davati Risk exposure za sve vrste leasinga */
  --g_vuradin maknut CASE WHEN oc.nacin_leas IN (SELECT nacin_leas FROM #exclude_lease_types) THEN isnull(odr.otv_ostalo,0)+isnull(odr.overdue,0)
		isnull(odr.debit_nedospj,0) + isnull(odr.ost_debit_nedospj1,0) --book_not_dued
		+ isnull(odr.otv_ostalo,0)+ isnull(odr.overdue,0) --total_odr
		+ case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin+oc.ex_g1_robresti, oc.id_tec, @target_date, @id_oc_report), 0)
			+isnull(odr.uk_glavnica_neproknj, 0)+isnull(odr.uk_robresti_neproknj, 0)end  --glavnica PV
	 as risk_exposure,
	 oc.ex_g1_neto,
	 oc.ex_g1_davek_fin,
	 oc.ex_g1_robresti,
	 isnull(odr.otv_ostalo,0) as otv_ostalo,
	 isnull(odr.overdue,0)  as overdue,			
	-- B2 EXPOSURE (za real OL = total_odr + ost_nedospj, za FL i OL 2 FL = total_odr + ost_nedospj + buduca glavnica + jamcevina)
	/*MID 10115 zbroj nove kolone Booked not dued, kolone Glavnica PV i Total ODR treba biti jednaka koloni B2 exposure za FL i Zajam, a zbroj Booked not dued+Total ODR treba biti B2 exposure za operativni leasing i OP ugovore*/
	isnull(odr.debit_nedospj,0) + isnull(odr.ost_debit_nedospj1,0) --book_not_dued
	+ isnull(odr.otv_ostalo,0)+ isnull(odr.overdue,0) --total_odr
	+ case when oc.ex_nacin_leas_tip_knjizenja = '2' Then 
		case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin+oc.ex_g1_robresti, oc.id_tec, @target_date, @id_oc_report), 0)
			+isnull(odr.uk_glavnica_neproknj, 0)+isnull(odr.uk_robresti_neproknj, 0) end  --glavnica PV
	  else 0 end
	as b2_total_exposure, 
	isnull(dbo.gfn_Xchange(@id_tec,os.rlc_present_val,'000',@target_date,@id_oc_report),0) as sad_vrij_fa,
	isnull(os.broj_os,0) as broj_os, @id_val as report_idval, oc.id_val, op.ext_id,eval.model_naziv,
	op.p_status, cast(gr.value as char(250)) as p_status_opis, oc.status,--coconut_mother.grupa_opis,
	case when oc.dat_aktiv is null or oc.dat_aktiv='' Then 0 
	ELSE case when ceiling(datediff(d, oc.dat_aktiv, @target_date)/365.00)=0 then 1 else ceiling(datediff(d, oc.dat_aktiv, @target_date)/365.00) end end as koef,
	oc.id_dav_op, oc.id_oc_report, op.p_kateg, oc.obr_mera, oc.id_obd,
	case when isnull(odr.max_dni_zamude, 0) < 0 OR (isnull(odr.otv_ostalo,0)+isnull(odr.overdue,0)) <= 0 then 0 else isnull(odr.max_dni_zamude,0) end as max_dni_zamude,
	isnull(odr.debit_nedospj,0) + isnull(odr.ost_debit_nedospj1,0) as book_not_dued,
	isnull(odr.glavnica_neproknj,0) as glavnica_neproknj,
	isnull(odr.robresti_neproknj,0) as robresti_neproknj,
	isnull(odr.kamata_neproknj,0) as kamata_neproknj,
	isnull(odr.dodusl_neproknj,0) as dodusl_neproknj,
	isnull(odr.porez_neproknj,0) as porez_neproknj,
	isnull(odr.otkup_neproknj,0) as otkup_neproknj,
	isnull(odr.otkup_nedospj,0) as otkup_nedospj,
	isnull(odr.rotkup_neproknj,0) as rotkup_neproknj,
	isnull(odr.rotkup_nedospj,0) as rotkup_nedospj,
	oc.dat_podpisa,	oc.pred_naj, oc.id_dob, oc.kategorija, 
	kategor.naziv AS kategor_naziv, dob.naz_kr_kup AS dob_naz_kr_kup, zap_reg.reg_stev, COALESCE( zap_reg.st_sas, zap_ner.ser_st, '') st_sas


	From oc_contracts oc
	LEFT JOIN
	(
		select cl.id_oc_report, cl.id_cont,
		--POTRAŽIVANJA 'POLO','OPC','LOBR','VARS'
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj),2) else 0 end) as overdue,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.neto/cl.debit),2) else 0 end) as otv_glav,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.obresti/cl.debit),2) else 0 end) as otv_kamata,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.regist/cl.debit),2) else 0 end) as otv_dodusl,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.davek/cl.debit),2) else 0 end) as otv_porez,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.robresti/cl.debit),2) else 0 end) as otv_robresti,

		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as debit_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_glavnica_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_kamata_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_robresti_nedospj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as debit_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_glavnica_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_robresti_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_kamata_neproknj,

		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as glavnica_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as kamata_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.regist, cl.id_tec, @target_date, @id_oc_report) else 0 end) as dodusl_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.davek, cl.id_tec, @target_date, @id_oc_report) else 0 end) as porez_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as robresti_neproknj,
		
		sum(case when cl.evident='' and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as otkup_neproknj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as otkup_nedospj,

		sum(case when cl.evident='' and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as rotkup_neproknj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as rotkup_nedospj,

		--OSTALA POTRAŽIVANJA
		sum(case when cl.evident = '*' and cl.dat_zap > @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.ex_debit_val_claim, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_nedospj,
		sum(case when cl.evident = '*' and cl.dat_zap > @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_debit_nedospj1,		
		sum(case when cl.evident = '' And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_neproknj,
		sum(case when cl.evident = '*' and cl.dat_zap <= @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj),2) else 0 end) as otv_ostalo,
		--SVA POTRAŽIVANJA
		max(Case when cl.evident = '*' And cl.dat_zap <= @target_date then cl.ex_dni_zamude else 0 end) as max_dni_zamude
		from dbo.oc_claims cl
		inner join dbo.vrst_ter vt on vt.id_oc_report = cl.id_oc_report and vt.id_terj = cl.id_terj
		where cl.id_oc_report = @id_oc_report
		and charindex(cl.id_terj,@sporna_potrazivanja)=0
		group by cl.id_cont, cl.id_oc_report
	) odr on oc.id_oc_report = odr.id_oc_report and oc.id_cont = odr.id_cont
	LEFT JOIN oc_customers op ON oc.id_oc_report = op.id_oc_report AND oc.id_kupca = op.id_kupca
	LEFT JOIN dbo.general_register gr ON op.id_oc_report = gr.id_oc_report And gr.id_register = 'P_STATUS' And rtrim(op.p_status) = rtrim(gr.id_key)
	LEFT JOIN dbo.dejavnos dj ON op.id_oc_report = dj.id_oc_report AND op.sif_dej = dj.sif_dej
	LEFT JOIN (Select @id_oc_report as id_oc_report, e.id_kupca, e.dat_eval, 
					LEFT(e.eval_model,2) AS EVAL_MODEL,
					right(rtrim(e.eval_model),1) as gams_flag, e.cust_ratin,
					e.coll_ratin, e.oall_ratin, cast(y.value as char(250)) as model_naziv
			   From dbo.gfn_PEval_LastEvaluationOnTargetDate (@target_date, @id_oc_report, NULL) e
			   Left join (Select id_oc_report, id_register, id_key, value
							From dbo.general_register
							Where id_oc_report = @id_oc_report and id_register = 'ev_model') y 
			   On @id_oc_report = y.id_oc_report and e.eval_model = y.id_key and y.id_register = 'ev_model') eval
			 ON oc.id_kupca = eval.id_kupca
	LEFT JOIN (Select id_oc_report, id_cont, count(*) as broj_os, Sum(ex_present_val) as ex_present_val
				, SUM(nabav_vred + rev_osnove + spr_osnove - (odpis_vred + (mes_amort - prevr_amor) + spr_odpisa + rev_odpisa + iztrz_vred - ucinek_odp + (prevr_spr + prevr_nabv)) + prevr_odpv) as rlc_present_val
				From dbo.fa 
				Where id_oc_report= @id_oc_report
				Group By id_oc_report,id_cont
				)os ON oc.id_oc_report = os.id_oc_report AND oc.id_cont = os.id_cont
	LEFT JOIN dbo.oc_customers dob ON oc.id_oc_report = dob.id_oc_report AND oc.id_dob = dob.id_kupca
	OUTER APPLY (SELECT top 1 reg_stev, st_sas FROM dbo.zap_reg WHERE id_cont = oc.id_cont AND id_oc_report = oc.id_oc_report) zap_reg
	OUTER APPLY (SELECT top 1 ser_st FROM dbo.zap_ner WHERE id_cont = oc.id_cont AND id_oc_report = oc.id_oc_report) zap_ner
	LEFT JOIN dbo.kategor ON oc.id_oc_report = kategor.id_oc_report AND oc.kategorija = kategor.kategorija
	--IZBACUJEMO POVEZANE PARTNERE NENAD 23.07.2013
	/*LEFT JOIN
		--(Select p.id_kupca,a.id_kupca as Mother_id,
		--Case When p1.ext_id = '' THEN 'Nema upisan coconut' ELSE p1.ext_id END As Mother_Coconut
		--From oc_customers p
		--LEFT JOIN 
		--	(Select id_oc_report,id_kupca,id_kupcab
		--	From pov_part 
		--	Where tip_pov='K1' and id_oc_report=@id_oc_report
		--	) a On p.id_kupca=a.id_kupcab and p.id_oc_report=a.id_oc_report
		--LEFT JOIN 
		--	(Select id_kupca,ext_id,id_oc_report
		--	From oc_customers
		--	Where id_oc_report=@id_oc_report
		--	)p1 On a.id_kupca=p1.id_kupca and a.id_oc_report=p1.id_oc_report
		--Where p.id_oc_report=@id_oc_report and  p1.ext_id Is Not Null
		Select a.*, b.id_oc_report, b.opis, cast(a.id_grupe as varchar(10)) +  ' - ' + left(b.opis,241) as grupa_opis
		From (
			Select id_grupe, id_kupcab
			From dbo.pov_part
			Where id_oc_report = @id_oc_report And tip_pov = 'K1'
			Group by id_grupe, id_kupcab
		) a
		Left join dbo.grupe_p b on a.id_grupe = b.id_grupe and b.id_oc_report = @id_oc_report
	)coconut_mother on op.id_kupca = coconut_mother.id_kupcab*/
	Where oc.id_oc_report = @id_oc_report  

	and (oc.status_akt = 'A' 
		or (oc.status_akt = 'D' and oc.dat_aktiv <= @target_date) 
		or (oc.status_akt = 'N' And oc.dat_podpisa is not null And oc.dat_podpisa <= @target_date) 
		or (oc.status_akt='Z' and oc.dat_zakl>@target_date)
		)
)x
left join #b2opprod b2op on b2op.leasing_type=x.b2_leasing_type and b2op.id_vrste=x.tmp_id_vrste and b2op.nacin_leas=x.tmp_nacin_leas 
left join dbo.dav_stop ds on x.id_dav_op = ds.id_dav_st and x.id_oc_report = ds.id_oc_report
left join dbo.nacini_l nl on x.nacin_leas = nl.nacin_leas and x.id_oc_report = nl.id_oc_report
left join dbo.vrst_opr v on x.id_vrste = v.id_vrste and x.id_oc_report = v.id_oc_report
left join #futureclaims fc on x.id_cont = fc.id_cont And x.status_akt In ('Z','A')
left join dbo.statusi ug_sta on x.id_oc_report = ug_sta.id_oc_report And x.status = ug_sta.status
left join dbo.p_kateg on x.id_oc_report = p_kateg.id_oc_report And x.p_kateg = p_kateg.p_kateg
left join #PROVISION_TYPE_RET ret on x.ID_CONT=ret.id_cont
left join #PROVISION_TYPE_NRT nrt on x.ID_CONT=nrt.id_cont
--left join (
--	Select id_cont, sum(debit_dom) debit_dom, sum(kredit_dom) kredit_dom
--	From dbo.oc_lsk
--	Where id_oc_report = @id_oc_report And konto in ('116918','116919','116925','120918','120919','120925')
--	Group by id_cont
--)  pllp_old on x.id_cont = pllp_old.id_cont and (@id_prov_report_NRT is null and @id_prov_report_RET is null)
--left join ( 
--	select 
--		a.id_cont,
--		sum(dbo.gfn_xchange(@id_tec, a.provision_amount, a.id_tec, @target_date, @id_oc_report)) as provision_amount
--	from(
--		select 
--			nrt.provision_amount, 
--			nrt.id_cont, 
--			nrt.id_tec
--		from {7}.dbo.PROVISIONS_NON_RETAIL nrt
--		where nrt.id_prov_report = @id_prov_report_NRT
--			and nrt.provision_type = 'PLLP'
--		union
--		select 
--			rt.provision_amount, 
--			rt.id_cont, 
--			rt.id_tec
--		from {7}.dbo.PROVISIONS_RETAIL rt
--		where rt.id_prov_report = @id_prov_report_RET
--			and rt.provision_cathegory = 'PLLP'
--	) a
--	group by a.id_cont
--) pllp on x.id_cont = pllp.id_cont
--left join (
--	Select id_cont, sum(debit_dom) debit_dom, sum(kredit_dom) kredit_dom
--	From dbo.oc_lsk
--	Where id_oc_report = @id_oc_report 
--	And konto in ('116920','036902','116923','116926','120920','040902','120923','120926','121925','150910') 
--	Group by id_cont
--) illp_old on x.id_cont = illp_old.id_cont and (@id_prov_report_NRT is null and @id_prov_report_RET is null)
--left join ( 
--	select 
--		a.id_cont,
--		sum(dbo.gfn_xchange(@id_tec, a.provision_amount, a.id_tec, @target_date, @id_oc_report)) as provision_amount
--	from(
--		select 
--			nrt.provision_amount, 
--			nrt.id_cont, 
--			nrt.id_tec
--		from {7}.dbo.PROVISIONS_NON_RETAIL nrt
--		where nrt.id_prov_report = @id_prov_report_NRT
--			and nrt.provision_type = 'ILLP'
--		union
--		select 
--			rt.provision_amount, 
--			rt.id_cont, 
--			rt.id_tec
--		from {7}.dbo.PROVISIONS_RETAIL rt
--		where rt.id_prov_report = @id_prov_report_RET
--			and rt.provision_cathegory = 'ILLP'
--	) a
--	group by a.id_cont
--) illp on x.id_cont = illp.id_cont
left join ( Select id_cont, sum(debit_dom) debit_dom, sum(kredit_dom) kredit_dom
			From dbo.oc_lsk
			Where id_oc_report = @id_oc_report 
			And konto = '193101' 
			Group by id_cont
) rrob on x.id_cont = rrob.id_cont
left join #default_events DE_R on x.ID_KUPCA = DE_R.ID_KUPCA and DE_R.sif_d_event = 'EBD'
left join #default_events DE_NR on x.id_kupca = DE_NR.id_kupca and DE_NR.sif_d_event = 'EBS'
LEFT JOIN #EWSO2 ew ON x.id_kupca = ew.id_kupca
left join oc_customers part on x.id_kupca=part.id_kupca and part.id_oc_report=@id_oc_report
left join sif_skis ss on part.id_skis=ss.id_skis and ss.id_oc_report=@id_oc_report
join obdobja obd on x.id_obd = obd.id_obd and obd.id_oc_report = @id_oc_report
left join (
	Select id_cont, sum(debit_dom) debit_dom, sum(kredit_dom) kredit_dom
	From dbo.oc_lsk
	Where id_oc_report = @id_oc_report And konto in ('120933', '120936', '120951', '120945', '116931', '116934','282001')
	Group by id_cont
)  ifrs9_1 on x.id_cont = ifrs9_1.id_cont 
left join (
	Select id_cont, sum(debit_dom) debit_dom, sum(kredit_dom) kredit_dom
	From dbo.oc_lsk
	Where id_oc_report = @id_oc_report And konto in ('120934', '120937', '120952', '120946', '116932', '116935','282002')
	Group by id_cont
)  ifrs9_2 on x.id_cont = ifrs9_2.id_cont 
left join (
	Select id_cont, sum(debit_dom) debit_dom, sum(kredit_dom) kredit_dom
	From dbo.oc_lsk
	Where id_oc_report = @id_oc_report And konto in ('120935', '120938', '120953', '120947', '121927', '121928', '116933', '116936', '116938', '116940', '120940', '120942', '120949', '120955', '121929', '121930', '120939', '120941',
	'116937', '116939', '120954', '120948', '150904', '189001')
	Group by id_cont
)  ifrs9_3 on x.id_cont = ifrs9_3.id_cont 
LEFT JOIN #PLANP_LOBR_MAX_DATUM_DOK PLANP_LOBR_MAX_DATUM_DOK ON PLANP_LOBR_MAX_DATUM_DOK.id_cont = x.id_cont
LEFT JOIN #PLANP_ST_OBROK PLANP_ST_OBROK ON PLANP_ST_OBROK.id_cont = x.id_cont
LEFT JOIN #OPCST_DOKS_DATUM_DOK OPCST_DOKS_DATUM_DOK ON OPCST_DOKS_DATUM_DOK.id_cont = x.id_cont
LEFT JOIN #OC_CLAIMS_FUTURE_FL_OTKUP OC_CLAIMS_FUTURE_FL_OTKUP ON OC_CLAIMS_FUTURE_FL_OTKUP.id_cont = x.id_cont
order by x.id_pog

drop table #b2opprod
drop table #futureclaims
drop table #default_events
DROP TABLE #exclude_lease_types
DROP TABLE #PP1
DROP TABLE #CLAIMS
DROP TABLE #EWSO2

DROP TABLE #OPCST_DOKS_DATUM_DOK
DROP TABLE #PLANP_LOBR_MAX_DATUM_DOK
DROP TABLE #PLANP_ST_OBROK
DROP TABLE #OC_CLAIMS_FUTURE_FL
DROP TABLE #OC_CLAIMS_FUTURE_FL_OTKUP
DROP TABLE #PROVISION_TYPE_NRT
DROP TABLE #PROVISION_TYPE_RET
