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

DECLARE	@id_oc_report int
DECLARE @id_tec char(3)
DECLARE @id_val char(3)
DECLARE @target_date datetime
DECLARE @entity_code char (5)
DECLARE @target_tecaj decimal (10,6)
DECLARE @sporna_potrazivanja char(8)

SET    	@id_oc_report = {1}
SET     @id_tec= {3}
SET     @id_val = {5}

SELECT @entity_code = entity_code FROM dbo.gv_OcReports WHERE id_oc_report = @id_oc_report

Select @target_date=date_to from dbo.gv_OcReports Where id_oc_report=@id_oc_report
SET @target_tecaj = dbo.gfn_VrednostTecaja(@id_tec, @target_date,@id_oc_report)

Select @target_date=date_to from dbo.gv_OcReports Where id_oc_report=@id_oc_report
create table #b2opprod (leasing_type char(2),id_vrste char(4), nacin_leas char(2), group_product_type_id char(6))

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
	from b2rl.dbo.b2opprod where client_id = @entity_code
end

Select a.id_cont,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) <= 3 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_do_3m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 4 And 12 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_3m_do_12m,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) between 13 And 60 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_1g_do_5g,
sum(case when v.sif_terj <> 'OPC' AND NOT(v.sif_terj = 'LOBR' And a.obresti = 0) And datediff(m, @target_date, a.datum_dok) >= 61 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as g_preko_5g,
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
sum(case when (v.sif_terj = 'OPC' OR (v.sif_terj = 'LOBR' And a.obresti = 0)) And datediff(m, @target_date, a.datum_dok) >= 61 then dbo.gfn_xchange(@id_tec, a.neto, a.id_tec, @target_date, @id_oc_report) else 0 end) as opc_preko_5g
INTO #futureclaims
from dbo.oc_claims_future a
inner join dbo.vrst_ter v on a.id_terj = v.id_terj And a.id_oc_report = v.id_oc_report
Where a.id_oc_report = @id_oc_report And v.sif_terj in ('POLO','LOBR','OPC','DDV') And a.datum_dok > @target_date
Group by a.id_cont

--	Dodavanje DPD countera prema zahtjevu RLC-a 1252
Declare @DefEvent as char(200)
Set @DefEvent = 'DC3,DCR'

Select a.*, b.dni_zamude_start
INTO #default_events
From (Select a.id_oc_report, MAX(a.id_default_events) as id_default_events, 
			a.id_d_event, a.id_kupca, a.id_cont, b.sif_d_event
		From dbo.default_events a
		inner join (Select id_d_event, id_oc_report, sif_d_event
						From dbo.default_events_register Where CHARINDEX(sif_d_event, @DefEvent)> 0) b on a.id_oc_report = b.id_oc_report and a.id_d_event = b.id_d_event
		Where a.id_oc_report = @id_oc_report
		Group by a.id_oc_report, a.id_d_event, a.id_kupca, a.id_cont, b.sif_d_event) a
Inner join dbo.default_events b on a.id_oc_report = b.id_oc_report and a.id_default_events = b.id_default_events


Select x.*, 
CASE WHEN ltrim(rtrim(x.p_status))='90D' or left(ltrim(rtrim(x.p_status)),1)='D' THEN 'YES' ELSE 'NO' END AS ODR,
b2op.group_product_type_id as GPC,
ROUND(x.vrijed_ug / CASE WHEN nl.finbruto = 1 THEN (1 + (ds.davek/100)) ELSE 1 END
                        * (CASE WHEN x.koef < 1 THEN 1 ELSE 0 END +
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
isnull(fc.o_do_3m,0) + x.kamata_neproknj as o_do_3m, isnull(fc.o_3m_do_12m,0) as o_3m_do_12m, isnull(fc.o_1g_do_5g,0) as o_1g_do_5g, isnull(fc.o_preko_5g,0) as o_preko_5g,
isnull(fc.p_do_3m,0) + x.porez_neproknj as p_do_3m, isnull(fc.p_3m_do_12m,0) as p_3m_do_12m, isnull(fc.p_1g_do_5g,0) as p_1g_do_5g, isnull(fc.p_preko_5g,0) as p_preko_5g,
isnull(fc.du_do_3m,0) + x.dodusl_neproknj as du_do_3m, isnull(fc.du_3m_do_12m,0) as du_3m_do_12m, isnull(fc.du_1g_do_5g,0) as du_1g_do_5g, isnull(fc.du_preko_5g,0) as du_preko_5g,
isnull(fc.opc_do_3m,0) + x.otkup_neproknj as opc_do_3m, isnull(fc.opc_3m_do_12m,0) as opc_3m_do_12m, isnull(fc.opc_1g_do_5g,0) as opc_1g_do_5g, isnull(fc.opc_preko_5g,0) as opc_preko_5g,
ug_sta.naziv as ug_sta_naziv,
p_kateg.naziv as p_kateg_naziv,
dbo.gfn_xchange(@id_tec, abs(isnull(pllp.debit_dom,0) - isnull(pllp.kredit_dom,0)) , '000', @target_date, @id_oc_report) as pllp,
dbo.gfn_xchange(@id_tec, abs(isnull(illp.debit_dom,0) - isnull(illp.kredit_dom,0)), '000', @target_date, @id_oc_report) as illp,
CASE WHEN x.oznaka1 = 'R' THEN ISNULL(DE_R.dni_zamude_start, 0) ELSE ISNULL(DE_NR.dni_zamude_start, 0) END AS DPD_Counter
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
	case when oc.ex_nacin_leas_tip_knjizenja = '1' and b2rl.dbo.gfn_MR_ol2fl(@entity_code, oc.ex_nacin_leas_tip_knjizenja, oc.dat_aktiv, oc.nacin_leas, oc.aneks, oc.id_cont) = 0 then 1 else 0 end as real_oper_leas,

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
	isnull(dbo.gfn_Xchange(@id_tec,oc.net_nal,oc.id_tec,@target_date,@id_oc_report),0) as iznos_financ,
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto,oc.id_tec,@target_date,@id_oc_report),0) +isnull(odr.uk_glavnica_nedospj, 0)+isnull(odr.uk_glavnica_neproknj, 0) END as glavnicaPV,
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(odr.uk_glavnica_neproknj, 0) END as glavnica,
	isnull(odr.ost_nedospj,0) as ost_nedospj,
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_regist,oc.id_tec,@target_date,@id_oc_report),0) end as ostalo,
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto_opc_nezap,oc.id_tec,@target_date,@id_oc_report),0) + isnull(odr.otkup_nedospj,0) + isnull(odr.otkup_neproknj, 0) End as x, 
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_obresti,oc.id_tec,@target_date,@id_oc_report),0)+ isnull(odr.uk_kamata_neproknj,0) End as kamate, --+ isnull(odr.uk_kamata_nedospj,0)
	case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_davek,oc.id_tec,@target_date,@id_oc_report),0) End as porez,
	isnull(odr.otv_glav,0) as otv_glav, 
	isnull(odr.otv_kamata,0) as otv_kamat,
	isnull(odr.otv_ostalo,0) as otv_ost,
	isnull(odr.otv_porez,0) as otv_porez,
	isnull(odr.otv_dodusl,0) as otv_dodusl,
	isnull(odr.uk_glavnica_neproknj,0) as glav_neproknj, 
	isnull(odr.uk_glavnica_nedospj,0) as glav_nedospj,
	isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin+case when ((oc.status_akt='Z' and oc.dat_zakl<=@target_date) or oc.aneks='T') then 0 else oc.varscina end,oc.id_tec,@target_date,@id_oc_report),0) as glav_oc_contract,	 
	isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin+case when ((oc.status_akt='Z' and oc.dat_zakl<=@target_date) or oc.aneks='T') then 0 else oc.varscina end, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(odr.uk_glavnica_nedospj, 0)+isnull(odr.uk_glavnica_neproknj, 0)+isnull(odr.otv_ostalo, 0)+isnull(odr.overdue, 0) as obligo,	
	--prema RL ODR izvješću suma svih otvorenih potraživanja osim spornih potraživanja
	isnull(odr.otv_ostalo,0)+isnull(odr.overdue,0) as tot_odr,
	-- leasing NPV amount (RISK EXPOSURE) (total ODR + bodoca glavnica + poknjizeno nezapadlo)
	/*MID 10115 Booked not dued, kolone Glavnica PV i Total ODR: zbroj sve tri kolone mora davati Risk exposure za sve vrste leasinga */
	isnull(odr.debit_nedospj,0) + isnull(odr.ost_debit_nedospj1,0) --book_not_dued
	+ isnull(odr.otv_ostalo,0)+ isnull(odr.overdue,0) --total_odr
	+ case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(odr.uk_glavnica_neproknj, 0) end  --glavnica PV
	as risk_exposure,
	-- B2 EXPOSURE (za real OL = total_odr + ost_nedospj, za FL i OL 2 FL = total_odr + ost_nedospj + buduca glavnica + jamcevina)
	/*MID 10115 zbroj nove kolone Booked not dued, kolone Glavnica PV i Total ODR treba biti jednaka koloni B2 exposure za FL i Zajam, a zbroj Booked not dued+Total ODR treba biti B2 exposure za operativni leasing i OP ugovore*/
	isnull(odr.debit_nedospj,0) + isnull(odr.ost_debit_nedospj1,0) --book_not_dued
	+ isnull(odr.otv_ostalo,0)+ isnull(odr.overdue,0) --total_odr
	+ case when oc.ex_nacin_leas_tip_knjizenja = '2' Then 
		case when oc.status_akt in ('N','D') THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(odr.uk_glavnica_neproknj, 0) end  --glavnica PV
	  else 0 end
	as b2_total_exposure, 
	isnull(dbo.gfn_Xchange(@id_tec,os.ex_present_val,'000',@target_date,@id_oc_report),0) as sad_vrij_fa,
	isnull(os.broj_os,0) as broj_os, @id_val as report_idval, oc.id_val, op.ext_id,eval.model_naziv,
	op.p_status, left(rtrim(gr.value), 254) as p_status_opis, oc.status,--coconut_mother.grupa_opis,
	case when oc.dat_aktiv is null or oc.dat_aktiv='' Then 0 
	ELSE case when ceiling(datediff(d, oc.dat_aktiv, @target_date)/365.00)=0 then 1 else ceiling(datediff(d, oc.dat_aktiv, @target_date)/365.00) end end as koef,
	oc.id_dav_op, oc.id_oc_report, op.p_kateg, oc.obr_mera,
	case when isnull(odr.max_dni_zamude, 0) < 0 OR (isnull(odr.otv_ostalo,0)+isnull(odr.overdue,0)) <= 0 then 0 else isnull(odr.max_dni_zamude,0) end as max_dni_zamude,
	isnull(odr.debit_nedospj,0) + isnull(odr.ost_debit_nedospj1,0) as book_not_dued,
	isnull(odr.glavnica_neproknj,0) as glavnica_neproknj,
	isnull(odr.kamata_neproknj,0) as kamata_neproknj,
	isnull(odr.dodusl_neproknj,0) as dodusl_neproknj,
	isnull(odr.porez_neproknj,0) as porez_neproknj,
	isnull(odr.otkup_neproknj,0) as otkup_neproknj,
	isnull(odr.otkup_nedospj,0) as otkup_nedospj,
	oc.dat_podpisa
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

		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as debit_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_glavnica_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_kamata_nedospj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as debit_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_glavnica_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_kamata_neproknj,

		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as glavnica_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as kamata_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.regist, cl.id_tec, @target_date, @id_oc_report) else 0 end) as dodusl_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.davek, cl.id_tec, @target_date, @id_oc_report) else 0 end) as porez_neproknj,
		
		sum(case when cl.evident='' and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as otkup_neproknj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as otkup_nedospj,

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
	LEFT JOIN ( Select gv_p_eval.id_oc_report, gv_p_eval.id_kupca, gv_p_eval.dat_eval, 
		    	LEFT(gv_p_eval.eval_model,2) AS EVAL_MODEL,
			right(rtrim(gv_p_eval.eval_model),1) as gams_flag, gv_p_eval.cust_ratin,
			gv_p_eval.coll_ratin,gv_p_eval.oall_ratin,y.value as model_naziv
			From dbo.gv_p_eval
			INNER JOIN (SELECT id_oc_report, id_kupca, max(dat_eval) as max_dat_eval
					FROM dbo.gv_p_eval
					WHERE id_oc_report= @id_oc_report 
					group by id_oc_report, id_kupca
			) pp_eval ON gv_p_eval.id_oc_report=pp_eval.id_oc_report AND gv_p_eval.id_kupca=pp_eval.id_kupca
			left join ( Select id_oc_report,id_register, id_key, value
					From dbo.general_register
					where id_oc_report=@id_oc_report and id_register='ev_model'
			) y on gv_p_eval.id_oc_report=y.id_oc_report and gv_p_eval.eval_model=y.id_key and y.id_register='ev_model'
			WHERE gv_p_eval.dat_eval=pp_eval.max_dat_eval AND gv_p_eval.id_oc_report=@id_oc_report
		   )eval ON oc.id_kupca = eval.id_kupca
	LEFT JOIN (Select id_oc_report,id_cont,Sum(ex_present_val) as ex_present_val,count(*) as broj_os
				From dbo.fa 
				Where id_oc_report=@id_oc_report
				Group By id_oc_report,id_cont			
	)os ON oc.id_oc_report = os.id_oc_report AND oc.id_cont = os.id_cont
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
left join ( Select id_cont, sum(debit_dom) debit_dom, sum(kredit_dom) kredit_dom
			From dbo.oc_lsk
			Where id_oc_report = @id_oc_report And konto in ('116918','116919','116925','120918','120919','120925')
			Group by id_cont
) pllp on x.id_cont = pllp.id_cont
left join ( Select id_cont, sum(debit_dom) debit_dom, sum(kredit_dom) kredit_dom
			From dbo.oc_lsk
			Where id_oc_report = @id_oc_report 
			And konto in ('116920','036902','116923','116926','120920','040902','120923','120926','121925','150910') 
			Group by id_cont
) illp on x.id_cont = illp.id_cont
left join #default_events DE_NR on x.id_oc_report = DE_NR.id_oc_report and x.id_kupca = DE_NR.id_kupca and DE_NR.sif_d_event = 'DC3'
left join #default_events DE_R on x.id_oc_report = DE_R.id_oc_report and x.id_cont = DE_R.id_cont and x.id_kupca = DE_R.id_kupca and DE_R.sif_d_event = 'DCR'
order by x.id_pog

drop table #b2opprod
drop table #futureclaims
drop table #default_events

	--	case when oc.status_akt = 'D' THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(claims.glav_nedospj, 0)+isnull(claims.glav_neproknj, 0) END as glavnica,	
	--	isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g2_neto,oc.id_tec,@target_date,@id_oc_report),0) as ostalo,
    --isnull(claims.opc_neproknj, 0 ) as opc_neproknj,
	--obligo = ODR+future_capital =glavnica+otv_kamat+otv_glav+otv_ost+glav_nedospj+glav_neproknj  
	--obligo = TOTAL_ODR + glavnica
	--isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto,oc.id_tec,@target_date,@id_oc_report),0)+isnull(claims1.otv_ostalo,0)+isnull(claims.overdue,0) as obligo,
/*
	isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto,oc.id_tec,@target_date,@id_oc_report),0) + isnull(claims.overdue,0) + isnull(claims1.otv_ostalo,0) + isnull(claims.glav_neproknj,0) + isnull(claims.glav_nedospj,0) as obligo,
*/
/*
	isnull(claims1.otv_ostalo,0)+isnull(claims.overdue,0) + 
	case when oc.status_akt = 'D' THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin, oc.id_tec, @target_date, @id_oc_report), 0)+isnull(claims.glav_nedospj, 0)+isnull(claims.glav_neproknj, 0)+isnull(conp.ost_nedospj,0) END as risk_exposure,
*/
/*	
	case when oc.ex_nacin_leas_tip_knjizenja = '1' and {7}.dbo.gfn_MR_ol2fl(@entity_code, oc.ex_nacin_leas_tip_knjizenja, oc.dat_aktiv, oc.nacin_leas, oc.aneks, oc.id_cont) = 0
			then isnull(claims1.otv_ostalo,0)+isnull(claims.overdue,0) 
				 + case when oc.status_akt = 'D' THEN 0 ELSE Isnull(conp.ost_nedospj,0) END
		 else 
			isnull(claims1.otv_ostalo,0)+isnull(claims.overdue,0)
			+ case when oc.status_akt = 'D' THEN 0 ELSE isnull(dbo.gfn_Xchange(@id_tec,oc.ex_g1_neto+oc.ex_g1_davek_fin+case when ((oc.status_akt='Z' and oc.dat_zakl<=@target_date) or oc.aneks='T') then 0 else oc.varscina end, oc.id_tec, @target_date, @id_oc_report), 0)
			+ isnull(claims.glav_nedospj, 0)
			+ isnull(claims.glav_neproknj, 0) 
			+ Isnull(conp.ost_nedospj,0)
			end
	end as b2_total_exposure,
*/

	--	LEFT JOIN dbo.vrst_opr vr ON oc.id_oc_report = vr.id_oc_report AND oc.id_vrste = vr.id_vrste
	/*LEFT JOIN (SELECT nacin_leas,CASE WHEN tip_knjizenja = '2' THEN CASE WHEN leas_kred='L' THEN 'FL' ELSE 'ZP' END  
			ELSE 'OL' END AS tip_leas, finbruto
			FROM dbo.nacini_l
			WHERE id_oc_report=@id_oc_report
		   ) nl ON oc.nacin_leas = nl.nacin_leas
	LEFT JOIN dbo.dav_stop ds ON oc.id_oc_report = ds.id_oc_report AND oc.id_dav_st = ds.id_dav_st
	*/

	--and oc.status_akt not in ('N','Z')
	--AND oc.status_akt='A' and oc.dat_aktiv <= @target_date and oc.aneks <> 'T'