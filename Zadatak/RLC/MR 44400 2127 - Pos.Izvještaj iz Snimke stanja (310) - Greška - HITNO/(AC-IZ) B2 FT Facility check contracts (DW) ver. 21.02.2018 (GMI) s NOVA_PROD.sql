-- 16.05.2007 Vito: Report je namenjen pregledu stanja iz snapshota. 
-- 		Podoben je ODR reportu vendar pa je namenjen pregledovanju podatkov iz snapshota zaradi primerjave z eksportiranimi podatki.
-- 		Podatke prikaze v pogodbeni tecajnici zato se ne sme uporabljati za ostala porocila
-- 17.05.2007 Vito: dodal sem pogoj and @entity_code = 'RLSI' za racunanje tmp_nacin_leas
-- 18.05.2007 Vito: dal sem left join namesto inner join-a pri odr_tmp2
-- 25.05.2007 Vito: Za entity RLSMR - Raiffeisen leasing rent sem zamenjal da jemlje B2RLRENT namesto B2RL
-- 29.05.2007 Vito: Dodal sem da se total_exposure prikaze v EUR in v DOMVAL in dodal se b2collat_value

-- 11.06.2007 Vito Poprava iz RLSMR na RRRS ker je to uradna oznaka za RL Rent
-- 27.06.2007 Vito: spremenil sem za real_oper_leas da je total exposure=ODR+fa.present_value
-- 29.06.2007 Vito: za pravi operativni lizing sem locil zapisa. Dosedanji en zapis iz pogodbe sem razdvojil na dva zapisa enega iz pogodbe (za ODR) in drugega iz FA (present value)
--		    za pogodbe operativnega lizinga ki se javljajo kot financni lizing sem k bodoci glavnici dodal se varscino
-- 05.07.2007 Vito: popravil sem napako da se je pri FA vednos javljal present_val iz pogodbe in pa izkljucil sem sporna 
-- 	potrazivanja
-- 10.07.2007 Vito: popravil da se varscina ne pristeva pri tozenih pogodbah, v total_exposure sem vkljucil se other_not_dued
-- 30.07.2007 Vito: Dodal sem kreiranje rezultatov za KI-light RL SI, popravil sem kreiranje provisionov za tozene pogodbe
-- 28.08.2007 Vito: Dodal sem da se is_retail polje izracuna iz eval_model, popravil da se v bodoco glavnico dodaja tudi financiran davek, dodal individual in general provisions stolpca
--                  dodal sem stolpca status partnerja in status pogodbe
-- 26.10.2007 Vito: spremenil sem da se iz oc claims namesto ex_saldo_val sesteva xchange(ex_saldo_val_claim na target date v pogodbeno tecajnico)
-- 06.11.2007 Vito: dodal sem izracun general_provisions in individual_provisions v pogodbeni,EUR in DOMV tecajnici
--		- dodal sem da se prikazujejo podatki tudi za konta GK (GL-) iz b2glaccounts
--		- dodal sem da se prikazujejo tudi own fixed assets
-- 21.11.2007 Vito: dodal sem da se za partnerja Raiffeisen leasing polni tudi eval_model
-- 10.12.2007 Vito: dodal sem rezultat 9 za KI LIGHT collateral in dopolnil exporte za KILIGHT collaterals
-- 07.01.2008 Vito: dopolnil da se jemljejo tudi pogodbe zakljucene po target_date
-- 17.01.2008 Vito: popravil sem da max_due_days ne more biti negativen, popravil sem da se v b2collat_value vstevajo le elligible kolaterali
-- 19.01.2008 Vito: popravil sem da se vrednost ex_factor deli s 100, ker je sicer izracunana vrednost 100 x preverila
-- 25.01.2008 Vito: popravil pogoj da se pristeva varscina tudi za pogodbe ki so bile zakljucene po target_date
--		- popravil da se v exposure uposteva tudi bodoca terjatev za ddv ex_g1_davek-ex_g1_fin_ddv za tipe nacini_l.ddv_takoj=1
-- 31.01.2008 Vito: V rezultat1 in 2 sem dodal polja individual_provisions,individual_provisions_EUR,individual_provisions_domv
--		- dodal sem polje b2collat_value_est ki je vrednost elligible collateralov brez faktorja 
-- 25.02.2008 Vito : dodal sem kriterij za pravi OL za RRRS
-- 09.05.2008 Vito : razbil sem ltc_180 na ltc_180_364 in ltc_365
-- 28.10.2008 Ziga: Maintenance ID 17695 - reapired field interests_in_odr_90
-- 18.11.2008 Ziga; Maintenance ID 17906 - dodal sem kriterij za pravi operativni lizing za RLBH (nacin_leas = OU or OZ)
-- 30.01.2008 Vito, Ziga; MR ID 18011 popravljen kriterij za real_ol za RLHR - upostevan aneks O
-- 24.06.2009 Ziga; MID 21023 - spremenjen kriterij za pravi OL za RLSI in RLBH
-- 20.07.2009 Ziga; MID 21612 - zopet spremenjen kriterij za pravi OL za RLSI
-- 08.01.2010 Ziga; MID 23664 - dodal poseben case OL transformiran v FL (tip_knjizenja = 1 in aneks = O za RLHR)- v polje total_exposure se javlja tudi znesek davek_not_dued
-- 14.01.2010 Ziga; MID 23883 - dopolnil status aktivnosti pogodbe tako, da je status aktivnosti 'A' za pogodbe, ki imajo datum zaključka > @target_date, saj so bile na @target_date aktivne
-- 31.05.2010 Ziga; MID 25286 - modification for RLSI, leasing types OL and O1 are threated as real operative leasing
-- 03.06.2010 Ziga; MID 24013 - removed interests_in_odr_90 from odr where calculating provision amount
-- 22.02.2011 Ziga; MID 27884 - excluded bail for RRRS and RLRS for modification OL to FL contracts
-- 08.05.2011 Ziga; MID 29389 - moved neto_not_dued and fin_dav_not_dued from future_capital and added separate field booked_not_dued_debit_all and also inclueded booked_not_dued_debit_all to total_exposure and renamed total_exposure to provision_exposure, also added new fields b2_total_exposure and risk_exposure
-- 12.05.2011 Ziga; MID 29389 - removed bail from risk_exposure and future_capital_total and added separate column for bail
-- 20.10.2011 Ziga; MID - repaired case for fin type. OP at generating group_product_type_id
-- 13.12.2013 Ziga; MID 43163 - modification fetching field gams_flag (substring instead of right)
-- 11.11.2014 Ziga; MID 47635 - added support for PPMV
-- 05.12.2014 Jost; optimization: fill temp table #dat_eval instead of selecting max in inner select
-- 30.01.2015 Ziga; MID 49429 - repaired caculation of present_value of fixed assets for RLHR
-- 21.02.2018 GMC B.K. MID 39946 - added special type of claim VOPC for reclasified contracts (ex bail value) - added exclude condition odstej_vaj = 0 for varscina in calculatin of future capital
-- 29.03.2018 GMC Branislav; MID 40182 - replace usage gv_p_eval with function gfn_PEval_LastEvaluationOnTargetDate 

DECLARE	@id_oc_report int
DECLARE @target_date datetime

DECLARE @sporna_potrazivanja char(8)
DECLARE @zero decimal(18,2)
DECLARE @market_value_id char (2)
DECLARE @entity_code char (5)
DECLARE @tec_eur char(3)
DECLARE @domval char(3)

SET @id_oc_report = {1}
SET @target_date = (select date_to from dbo.oc_reports where id_oc_report=@id_oc_report)
SET @zero = 0
SET @market_value_id = (select id_obl_zav from dbo.dok where sifra = 'MVAL' and id_oc_report=@id_oc_report)

SELECT @entity_code = entity_code FROM dbo.oc_reports WHERE id_oc_report = @id_oc_report

select @tec_eur = id_tec from tecajnic where id_oc_report = @id_oc_report and
		vrstni_red in (select min(vrstni_red) as vrstni_red from tecajnic where id_val='EUR' and id_oc_report = @id_oc_report)

select @domval = id_val from tecajnic where id_tec='000' and id_oc_report = @id_oc_report



create table #b2provision_accounts (konto char(8))

create table #b2opprod (leasing_type char(2),id_vrste char(4), nacin_leas char(2), group_product_type_id char(6))

create table #b2collat (naziv_collat varchar(140),id_obl_zav char(2), id_hipot char(5), 
	collat_type_b2 varchar(140),coll_counterp bit)

create table #b2ini (company_id varchar(30),drzava varchar(140),id_val char(3), id_customer_dom varchar(20))

create table #b2glaccount (konto char(8),naziv varchar(100),group_product_type_id char(6),
	table_name varchar(20),saldo_debit bit,customer_id varchar(10))

create table #b2faprod (client_id varchar(50),id_knjizbe varchar(10),naziv varchar(100),group_product_type_id char(6))

insert into #b2faprod 
select client_id,id_knjizbe,naziv,group_product_type_id
from {3}.dbo.b2faprod where client_id = @entity_code

insert into #b2glaccount 
select konto,naziv,group_product_type_id,table_name,saldo_debit,customer_id
from {3}.dbo.b2glaccount where client_id = @entity_code

insert into #b2opprod 
select leasing_type,isnull(id_vrste,'####') as id_vrste,isnull(nacin_leas,'##') as nacin_leas,group_product_type_id
from {3}.dbo.b2opprod where client_id = @entity_code

insert into #b2provision_accounts
select distinct konto 
from {3}.dbo.b2provision_accounts 

insert into #b2collat
select naziv_collat,id_obl_zav, id_hipot, collat_type_b2 ,coll_counterp
from {3}.dbo.b2collat where client_id = @entity_code	

CREATE INDEX IX_B2COLLAT ON #B2COLLAT(id_obl_zav)

insert into #b2ini
select company_id,drzava,id_val,id_customer_dom	
from {3}.dbo.b2ini

DECLARE @id_customer_dom char(6)
set @id_customer_dom = (select top 1 id_customer_dom from #b2ini)

-- sumnjiva i sporna potrazivanja koja su nastala kao posljedica ponovnog uspostavljanja stanja nakon sto su stornirali sve buduce rate (zbog utuzenosti i sl.)
--SET @sporna_potrazivanja = '66,67,68'  

SET @sporna_potrazivanja = ''

--if  RTRIM(@entity_code) = 'RLHR' SET @sporna_potrazivanja = '66,67,68'  


select 	a.id_cont, 
	sum(dbo.gfn_xchange(b.id_tec, a.vrednost, a.id_tec, @target_date, @id_oc_report)) as market_value
into #odr_tmp_dokument
from dbo.dokument a 
left join oc_contracts b on a.id_cont=b.id_cont and a.id_oc_report=b.id_oc_report
where a.id_oc_report=@id_oc_report and a.id_obl_zav=@market_value_id and a.ima=1 and a.status_akt='A'
group by a.id_cont



--DOSPJELA NEPLACENA POTRAZIVANJA
select a.id_cont, 
-- broj otvorenih rata
round(sum(case when b.sif_terj='LOBR' then a.ex_saldo_val/a.ex_debit_val else 0 end),2) as no_of_open_installm,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 0 do 29 dana
sum(case when a.ex_dni_zamude < 30 and a.ex_dni_zamude>=0 and a.evident='*'
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report) 
	else @zero end) as odr_0_29,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 30 do 59 dana
sum(case when a.ex_dni_zamude >= 30 and a.ex_dni_zamude < 60 and a.evident='*'
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report) 
	else @zero end) as odr_30_59,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 60 do 89 dana
sum(case when a.ex_dni_zamude >= 60 and a.ex_dni_zamude < 90 and a.evident='*'
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as odr_60_89,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 90 do 119 dana
sum(case when a.ex_dni_zamude >= 90 and a.ex_dni_zamude < 120 and a.evident='*'
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as odr_90_119,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 120 do 179 dana
sum(case when a.ex_dni_zamude >= 120 and a.ex_dni_zamude < 180 and a.evident='*'
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as odr_120_179,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 180 do 364 dana
sum(case when a.ex_dni_zamude >= 180 and a.ex_dni_zamude < 365 and a.evident='*'
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as odr_180_364,
--ODR (overdue receivables) dospjela neplacena potrazivanja vise od 180 dana
sum(case when a.ex_dni_zamude >= 365 and a.evident='*'
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as odr_365,
--ukupni ODR (svi proknjizeni)
sum(case when a.evident='*' and a.ex_dni_zamude >=0
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as total_odr,
--iznos glavnice u neproknjizenim ratama koji se mora spremiti u buduca potrazivanja (buduca glavnica) - nije uknjucen u total ODR
sum(case when a.evident='' and b.sif_terj in ('LOBR','OPC','POLO','VARS')
	then dbo.gfn_xchange( c.id_tec,(a.ex_debit_val_claim*a.neto/a.debit),a.id_tec,@target_date, @id_oc_report)
	else @zero end) as neto_not_booked,
--iznos robresti (PPMV) u neproknjizenim ratama koji se mora spremiti u buduca potrazivanja (buduce robresti) - nije uknjucen u total ODR
sum(case when a.evident='' and b.sif_terj in ('LOBR','OPC','POLO','VARS')
	then dbo.gfn_xchange( c.id_tec,(a.ex_debit_val_claim*a.robresti/a.debit),a.id_tec,@target_date, @id_oc_report)
	else @zero end) as robresti_not_booked,
sum(case when a.evident='' and b.sif_terj in ('LOBR','OPC','POLO','VARS','DDV') and c.ex_nacin_leas_leas_kred = 'L' and c.ex_nacin_leas_tip_knjizenja = '2' and n.ol_na_nacin_fl = 0
	then dbo.gfn_xchange( c.id_tec,(a.ex_debit_val_claim*a.davek/a.debit),a.id_tec,@target_date, @id_oc_report)
	else @zero end) as fin_dav_not_booked,
--iznos glavnice u proknjizenim ratama koji imaju datum dospijeca u buducnosti pa se mora spremiti u buduca potrazivanja (buduca glavnica)- nije uknjucen u total ODR
sum(case when a.evident='*' and a.ex_dni_zamude<0 and b.sif_terj in ('LOBR','OPC','POLO','VARS')
	then dbo.gfn_xchange( c.id_tec,(a.ex_debit_val_claim*a.neto/a.debit),a.id_tec,@target_date, @id_oc_report)
	else @zero end) as neto_not_dued,
--iznos robresti (PPMV) u proknjizenim ratama koji imaju datum dospijeca u buducnosti pa se mora spremiti u buduca potrazivanja (buduce robresti)- nije uknjucen u total ODR
sum(case when a.evident='*' and a.ex_dni_zamude<0 and b.sif_terj in ('LOBR','OPC','POLO','VARS')
	then dbo.gfn_xchange( c.id_tec,(a.ex_debit_val_claim*a.robresti/a.debit),a.id_tec,@target_date, @id_oc_report)
	else @zero end) as robresti_not_dued,
--iznos PDV-a u proknjizenim ratama koji imaju datum dospijeca u buducnosti
sum(case when a.evident='*' and a.ex_dni_zamude<0 and b.sif_terj in ('LOBR','OPC','POLO','VARS','DDV')
	then dbo.gfn_xchange( c.id_tec,(a.ex_debit_val_claim*a.davek/a.debit),a.id_tec,@target_date, @id_oc_report)
	else @zero end) as davek_not_dued,
sum(case when a.evident='*' and a.ex_dni_zamude<0 and b.sif_terj in ('LOBR','OPC','POLO','VARS','DDV') and c.ex_nacin_leas_leas_kred = 'L' and c.ex_nacin_leas_tip_knjizenja = '2' and n.ol_na_nacin_fl = 0
	then dbo.gfn_xchange( c.id_tec,(a.ex_debit_val_claim*a.davek/a.debit),a.id_tec,@target_date, @id_oc_report)
	else @zero end) as fin_dav_not_dued,
--iznos ostalih proknjizenih rata imaju datum dospijeca u buducnosti pa se mora spremiti u buduca potrazivanja (buduca glavnica)- nije uknjucen u total ODR
sum(case when a.evident='*' and a.ex_dni_zamude<0 and b.sif_terj not in ('LOBR','OPC','POLO','VARS')
	then dbo.gfn_xchange( c.id_tec,a.ex_debit_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as other_not_dued,
-- znesek vseh poknjizenih nezapadlih terjatev
sum(case when a.evident='*' and a.ex_dni_zamude<0
	then dbo.gfn_xchange( c.id_tec,a.ex_debit_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as booked_not_dued_debit_all,
--iznos fakturiranog neplacenog otkupa - ukljucen u total ODR
sum(case when a.evident='*' and b.sif_terj in ('OPC')
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as odr_buyout,
--iznos otkupa koji nije proknjizen ali je datumski dospio (u odnosu na target_date) - nije ukljucen u total ODR
sum(case when a.evident='' and b.sif_terj in ('OPC')
	then dbo.gfn_xchange( c.id_tec,a.ex_saldo_val_claim,a.id_tec,@target_date, @id_oc_report)
	else @zero end) as buyout_not_booked,
--izracun neplecenih kamata u potrazivanjima starijim od 90 dana
sum(case when a.ex_dni_zamude > 90 and a.evident='*'
	then dbo.gfn_xchange( c.id_tec,(a.ex_saldo_val_claim*a.obresti/a.debit),a.id_tec,@target_date, @id_oc_report)
--	then (a.ex_saldo_val)*(a.obresti/a.debit)
	else @zero end) as interests_in_odr_90,
max(case when a.ex_dni_zamude<0 then 0 else a.ex_dni_zamude end) as max_due_days
 into #odr_tmp1
 from dbo.oc_claims a 
inner join dbo.vrst_ter b on a.id_terj=b.id_terj and a.id_oc_report=b.id_oc_report
inner join dbo.oc_contracts c on a.id_cont=c.id_cont and a.id_oc_report=c.id_oc_report
left join dbo.NACINI_L n on a.NACIN_LEAS = n.nacin_leas and a.id_oc_report = n.id_oc_report
where a.id_oc_report=@id_oc_report and charindex(a.id_terj,@sporna_potrazivanja)=0
group by a.id_cont,a.id_oc_report

--BUDUĆA POTRAŽIVANJA GLAVNICE iz VOPC
Select f.id_oc_report, 
	f.id_cont, 
	--iznos buduće glavnice u posebnom potraživanju VOPC kod reklasificiranih OR ugovora
	SUM(dbo.gfn_Xchange(c.id_tec, f.neto, f.id_tec, @target_date, @id_oc_report)) as future_capital_vopc
into #ocf
from dbo.oc_claims_future f
inner join dbo.oc_contracts c on f.id_oc_report = c.ID_OC_REPORT and f.ID_CONT = c.ID_CONT
inner join dbo.VRST_TER v on f.id_oc_report = v.id_oc_report and f.id_terj = v.id_terj
where v.sif_terj = 'VOPC' and f.id_oc_report = @id_oc_report
group by f.id_oc_report, f.id_cont


select a.id_cont, a.id_pog as contract, 
a.pred_naj as object, 
isnull(c.no_of_open_installm,0) as no_of_open_installm, 
a.id_kupca as partner_id,
a.nacin_leas as fin_type, 
left(a.nacin_leas,1) as type1,
d.id_vrste as equipment_type,
d.id_grupe as group_type,
e.naz_kr_kup as partner_name, 
e.boniteta as partner_rating,
e.vr_osebe as partner_type,
e.asset_clas as b2_segm,
e.dav_stev as tax_id_no,
e.ext_id as coconut_no,
e.p_status,
a.status,
/*case when e.asset_clas in ('OR/SME' , 'ORET') then 'Y' else 'N' end as is_retail,*/
isnull(g.b2grupa,'') as nace_code,
isnull(c.max_due_days,100000-100000) as max_due_days,
isnull(c.total_odr,@zero) as total_odr,
isnull(c.odr_0_29,@zero) as odr_0_29,
isnull(c.odr_30_59,@zero) as odr_30_59,
isnull(c.odr_60_89,@zero) as odr_60_89,
isnull(c.odr_90_119,@zero) as odr_90_119,
isnull(c.odr_120_179,@zero) as odr_120_179,
isnull(c.odr_180_364,@zero) as odr_180_364,
isnull(c.odr_365,@zero) as odr_365,
isnull(c.interests_in_odr_90,@zero) as interests_in_odr_90,
isnull(f.market_value,@zero) as market_value,
a.id_tec as exch_rate_id,
@target_date as target_date,
a.aneks as anex,
case when a.status_akt = 'A' or (a.status_akt = 'Z' and a.dat_zakl > @target_date) then 'A' else 'Z' end as status_act,
a.id_dob as supplier_id,
-- ako je vrijednost rate = 0 (lizing 50-50 isl) onda se u slucaju kasnjenja ne moze usporediti
-- omjer rate (deljenje sa 0) pa se zato usporedjuje sa minimalnim iznosom 0.01 
case when a.obrok1 != 0 
	then a.obrok1 
	else 0.01 end
	as installment_value, 
a.id_val as currency,
a.id_strm as cost_centre,
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC, POLO, LOBR,'VARS'
a.ex_g1_neto + a.ex_g1_robresti + isnull(v.future_capital_vopc, @zero) + case when h.leas_kred = 'L' and h.tip_knjizenja = '2' and h.ol_na_nacin_fl = 0 then a.ex_g1_davek else 0 end as future_capital_date,
--dio buduce glavnice koja proizlazi iz naslova dospjelih nefakturiranih potrazivanja OPC, POLO, LOBR,'VARS'
isnull(c.neto_not_booked,@zero) + isnull(c.robresti_not_booked,@zero) + isnull(c.fin_dav_not_booked,@zero) as future_capital_not_booked,
--dio buduce glavnice koja proizlazi iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
isnull(c.neto_not_dued,@zero) + isnull(c.robresti_not_dued,@zero) + isnull(c.fin_dav_not_dued,@zero) as future_capital_not_dued,
isnull(c.other_not_dued,@zero) as future_other_not_dued,
--zbroj prethodna tri polja 
a.ex_g1_neto + a.ex_g1_robresti + isnull(v.future_capital_vopc, @zero) + case when h.leas_kred = 'L' and h.tip_knjizenja = '2' and h.ol_na_nacin_fl = 0 then a.ex_g1_davek else 0 end
	+case when ((a.status_akt='Z' and a.dat_zakl<=@target_date) or a.aneks='T' or (@entity_code in ('RLRS','RRRS') and a.nacin_leas = 'OO') or h.odstej_var = 0) then 0 else a.varscina end
	+isnull(c.neto_not_booked,@zero)
	+isnull(c.robresti_not_booked,@zero)
	+isnull(c.fin_dav_not_booked,@zero)
	as future_capital_total,
a.varscina,
isnull(c.booked_not_dued_debit_all, @zero) as booked_not_dued_debit_all,
isnull(c.odr_buyout,@zero) as odr_buyout,
isnull(c.buyout_not_booked,@zero) as buyout_not_booked,
--buduca glavnica iz naslova potrazivanja za otkup 
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC
a.ex_g1_neto_opc_nezap+isnull(c.buyout_not_booked,@zero) as future_buyout_value,
a.id_kredpog as credit_contract_id,
a.dat_aktiv as activation_date,
a.dat_sklen as foundation_date,
a.ex_max_datum_dok as contract_end,
a.ex_coverage_value,
a.ex_collat_coverage_value,
a.vr_val as contract_value,
a.prv_obr+a.st_obrok*a.ost_obr+a.opcija+a.ddv as contract_claims,
a.net_nal as financed_value,
case when a.ex_nacin_leas_tip_knjizenja = '1' and {3}.dbo.gfn_MR_ol2fl(@entity_code, a.ex_nacin_leas_tip_knjizenja, a.dat_aktiv, a.nacin_leas, a.aneks, a.id_cont) = 0 then 1 else 0 end as real_oper_leas,
case when a.ex_nacin_leas_leas_kred='K' then 'LO' else
	case when @entity_code = 'RLHR' then
		           case when (a.ex_nacin_leas_tip_knjizenja = '1' and a.dat_aktiv >= '20050101' and a.nacin_leas <> 'OP') then 'OL' else 'FL' end
	     when @entity_code = 'RLSI' then
	                 case when a.ex_nacin_leas_tip_knjizenja = '1' AND a.nacin_leas IN ('ON','OL','O1') then 'OL' else 'FL' end
	     when @entity_code = 'RRRS' then
	                 case when a.ex_nacin_leas_tip_knjizenja = '1' AND a.nacin_leas IN ('OX') then 'OL' else 'FL' end
		 when @entity_code = 'RLBH' then
	                 case when a.ex_nacin_leas_tip_knjizenja = '1' AND a.id_cont >= 7133 then 'OL' else 'FL' end
	     else 'FL' end
end
as b2_leasing_type,
a.ex_nacin_leas_tip_knjizenja,
a.ex_nacin_leas_leas_kred,
d.tip_opr, 
case when a.ex_nacin_leas_leas_kred='K' and @entity_code = 'RLSI' then a.nacin_leas else '##' end as tmp_nacin_leas,
case when a.ex_nacin_leas_leas_kred='K' and @entity_code = 'RLSI' then '####' else a.id_vrste end as tmp_id_vrste,
@id_oc_report as id_oc_report,
a.ex_nacin_leas_tip_knjizenja as tip_knjizenja,
c.davek_not_dued as future_tax_not_dued
into #odr_tmp2
from dbo.oc_contracts a 
--left join dbo.oc_claims b on a.id_cont=b.id_cont and a.id_oc_report=b.id_oc_report
-- left join #odr_tmp1 c on a.id_cont=c.id_cont
-- inner join zaradi tega ker mora biti total_odr=0
left join #odr_tmp1 c on a.id_cont=c.id_cont
left join #ocf v on a.id_cont = v.id_cont and a.id_oc_report = v.id_oc_report
left join dbo.vrst_opr d on a.id_vrste=d.id_vrste and a.id_oc_report=d.id_oc_report
left join dbo.oc_customers e on a.id_kupca=e.id_kupca and a.id_oc_report=e.id_oc_report
left join #odr_tmp_dokument f on a.id_cont=f.id_cont 
left join dejavnos g on e.sif_dej=g.sif_dej and a.id_oc_report=g.id_oc_report
left join nacini_l h on a.nacin_leas=h.nacin_leas and a.id_oc_report=h.id_oc_report
where a.id_oc_report=@id_oc_report and 
(a.status_akt = 'A' OR (a.status_akt = 'Z' AND month(a.dat_zakl) = month(@target_date) and year(a.dat_zakl) = year(@target_date))
 OR (a.status_akt = 'Z' and a.dat_zakl>@target_date))




select @id_oc_report as id_oc_report, a.*,isnull(c.value,'') as eval_model_desc,left(a.eval_model,2) as real_eval_model,
substring(rtrim(eval_model),3, 1) as gams_flag 
into #tmp_p_eval
from dbo.gfn_PEval_LastEvaluationOnTargetDate (@target_date, @id_oc_report, NULL) a
left join dbo.general_register c on a.eval_model = c.id_key and @id_oc_report = c.id_oc_report and c.id_register = 'ev_model' 
where c.id_register = 'ev_model' 
order by id_kupca



select id_cont, inv_stev,
		case when @entity_code = 'RLHR' then IsNull(ex_present_val, 0) - prevr_nabv + prevr_odpv + prevr_amor - prevr_spr else IsNull(ex_present_val, 0) end as present_val
into #tmp_fa
from dbo.fa 
where id_oc_report = @id_oc_report and id_cont > 0

select a.id_cont, a.inv_stev,
		case when @entity_code = 'RLHR' then IsNull(a.ex_present_val, 0) - a.prevr_nabv + a.prevr_odpv + a.prevr_amor - a.prevr_spr else IsNull(a.ex_present_val, 0) end as present_val,
		isnull(b.group_product_type_id,'') as group_product_type_id
into #tmp_fa_own 
from dbo.fa a
left join #b2faprod b on a.id_knjizbe=b.id_knjizbe
where a.id_oc_report=@id_oc_report and isnull(a.id_cont,0)=0 and a.ex_present_val>0

SELECT id_cont,sum(kredit_dom - debit_dom) as lsk_prov_amount 
into #lsk_provisions
FROM dbo.oc_lsk 
WHERE id_oc_report = @id_oc_report AND konto IN (SELECT distinct konto FROM #b2provision_accounts)
group by id_cont

CREATE INDEX IX_LSK_PROVISIONS ON #lsk_provisions(id_cont)

select a.id_cont,
-- b2collat_value se izracuna kot dokument.vrednost za vse tipe zavarovanj ki niso RRE in CRE
-- sicer pa se vzame dokument.ocen_vred*dokument.ex_factor
sum (dbo.gfn_xchange( b.id_tec,case when a.is_elligible=1 then
	case when left(a.id_hipot,1) in ('R','C') then a.ocen_vred*(a.ex_factor/100) else a.vrednost end else 0 end,
	a.id_tec,@target_date, @id_oc_report)
     ) as b2collat_value,
sum (dbo.gfn_xchange( b.id_tec,case when a.is_elligible=1 then
	case when left(a.id_hipot,1) in ('R','C') then a.ocen_vred else a.vrednost end else 0 end,
	a.id_tec,@target_date, @id_oc_report)
     ) as b2collat_value_est,
sum (dbo.gfn_xchange( b.id_tec,
	case when left(a.id_hipot,1) in ('R') and a.is_elligible=1 then a.ocen_vred*(a.ex_factor/100) else 0 end,
	a.id_tec,@target_date, @id_oc_report)) as RRE_elligible,
sum (dbo.gfn_xchange( b.id_tec,
	case when left(a.id_hipot,1) in ('R') and a.is_elligible!=1 then a.ocen_vred*(a.ex_factor/100) else 0 end,
	a.id_tec,@target_date, @id_oc_report)) as RRE_non_elligible,
sum (dbo.gfn_xchange( b.id_tec,
	case when left(a.id_hipot,1) in ('C') and a.is_elligible=1 then a.ocen_vred*(a.ex_factor/100) else 0 end,
	a.id_tec,@target_date, @id_oc_report)) as CRE_elligible,
sum (dbo.gfn_xchange( b.id_tec,
	case when left(a.id_hipot,1) in ('C') and a.is_elligible!=1 then a.ocen_vred*(a.ex_factor/100) else 0 end,
	a.id_tec,@target_date, @id_oc_report)) as CRE_non_elligible,
sum (dbo.gfn_xchange( b.id_tec,
	case when c.collat_type_b2='0' and a.is_elligible!=1 then a.vrednost else 0 end,
	a.id_tec,@target_date, @id_oc_report)) as depozits,
sum (dbo.gfn_xchange( b.id_tec,
	case when c.collat_type_b2='9' and a.is_elligible!=1 then a.vrednost else 0 end,
	a.id_tec,@target_date, @id_oc_report)) as guaranties

into #b2_dokument1
from dokument a 
inner join dbo.oc_contracts b on a.id_cont=b.id_cont and a.id_oc_report = b.id_oc_report
inner join #B2COLLAT c ON a.id_obl_zav = c.id_obl_zav and (a.id_hipot=c.id_hipot OR c.id_hipot='*')
--where a.id_obl_zav in (select distinct id_obl_zav from #b2collat) 
where a.status_akt='A' and a.ima=1
and a.id_oc_report = @id_oc_report
group by a.id_cont

select a.id_cont, a.contract, 
a.object, 
a.no_of_open_installm, 
a.partner_id,
a.fin_type, 
a.type1,
a.equipment_type,
a.tip_opr as orig_eq_type,
a.group_type,
a.partner_name, 
a.partner_rating,
a.partner_type,
a.b2_segm,
case when isnull(b.real_eval_model,'') in ('01','20') then 'Y' else 'N' end as is_retail,
a.coconut_no,
a.tax_id_no,
a.anex,
a.status_act,
a.supplier_id,
a.exch_rate_id,
a.target_date,
a.cost_centre,
a.currency,
a.odr_0_29,
a.odr_30_59,
a.odr_60_89,
a.odr_90_119,
a.odr_120_179,
a.odr_180_364,
a.odr_365,
a.total_odr,
a.interests_in_odr_90,
a.market_value,
a.installment_value, 
--future_capital_date+future_capital_not_booked
a.future_capital_total,
a.varscina,
a.booked_not_dued_debit_all,
a.total_odr + a.booked_not_dued_debit_all + case when a.real_oper_leas = 0 then a.future_capital_total else 0 end as b2_total_exposure,
a.total_odr + a.booked_not_dued_debit_all + a.future_capital_total as risk_exposure,
-- lapse of time provision 60_89
case when a.odr_60_89 != 0 and a.odr_90_119 = 0 and a.odr_120_179 = 0 and a.odr_180_364 = 0 and a.odr_365 = 0 and a.anex!='T'
	then (case when (a.odr_60_89/a.installment_value) > 0.5 then 0.5 else 0 end)*a.total_odr
	else 0 end as lt_prov_60_89,
-- lapse of time provision 90_119
case when a.odr_90_119 != 0 and a.odr_120_179 = 0 and a.odr_180_364 = 0 and a.odr_365 = 0 and a.anex!='T' 
	then (case when ((a.odr_90_119+a.odr_120_179)/a.installment_value) > 0.5 then 1 else 0.5 end) * (a.total_odr - a.interests_in_odr_90)
	else 0 end as lt_prov_90_119,
-- lapse of time provision 120_179
case when a.odr_120_179 != 0 and  a.odr_180_364 = 0 and a.odr_365 = 0 and a.anex!='T'
	then (case when ((a.odr_90_119+a.odr_120_179)/a.installment_value) > 0.5 then 1 else 0.5 end) * (a.total_odr - a.interests_in_odr_90)
	else 0 end as lt_prov_120_179,
-- lapse of time provision 180_364
case when a.odr_180_364 != 0 and  a.odr_365 = 0 and a.anex!='T'
	then a.total_odr
	else 0 end as lt_prov_180_364,
-- lapse of time provision over 180
case when a.odr_365 != 0 and a.anex!='T'
	then a.total_odr
	else 0 end as lt_prov_365,
-- after debt of dued liabilities that are older than 90 days exceeds 1 installment
-- termination risk provisions should be calculated as well (odr_180) is in that case only in termination risk provision
-- while other stays in prov_120_179
case when ((a.odr_90_119+a.odr_120_179+a.odr_180_364+a.odr_365)/a.installment_value) >= 1 or a.anex='T'
	then case when a.anex='T' then
	  	(case when (a.total_odr - a.interests_in_odr_90 + a.future_capital_total - a.market_value) > 0 then 
		(a.total_odr - a.interests_in_odr_90 + a.future_capital_total - a.market_value)
		 else 0 end)
	     else
	  	(case when (a.future_capital_total - a.market_value) > 0 then 
		(a.future_capital_total - a.market_value)
		 else 0 end)
	    end
	else 0 end as tr_prov,

--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC, POLO, LOBR
a.future_capital_date,
--dio buduce glavnice koja proizlazi iz naslova dospjelih nefakturiranih potrazivanja OPC, POLO, LOBR
a.future_capital_not_booked,
--dio buduce glavnice koja proizlazi iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
a.future_capital_not_dued,
a.future_other_not_dued,
a.odr_buyout,
a.buyout_not_booked,
--buduca glavnica iz naslova potrazivanja za otkup 
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC
a.future_buyout_value,
a.credit_contract_id,
a.max_due_days,
isnull(b.real_eval_model,'') as eval_model,
case when isnull(b.gams_flag,'') not in ('T','N','Y') then '' else isnull(b.gams_flag,'') end as gams_flag,
isnull(b.eval_model_desc,'') as eval_model_desc,
a.activation_date,
a.foundation_date,
a.contract_end,
a.real_oper_leas,
a.b2_leasing_type,
c.group_product_type_id,
a.tmp_nacin_leas,a.tmp_id_vrste,
a.b2_leasing_type+'-'+a.group_type as product_type,
a.fin_type+'-'+a.equipment_type as product_subtype,
a.ex_coverage_value,
a.ex_collat_coverage_value,
a.contract_value,
a.contract_claims,
a.financed_value,
a.status,
a.p_status,
--isnull(d.lsk_prov_amount,0) as lsk_prov_amount,
dbo.gfn_Xchange(a.exch_rate_id,isnull(d.lsk_prov_amount,0),'000',@target_date,@id_oc_report) as lsk_prov_amount,
isnull(g.present_val,0) as present_val,
isnull(e.id_tec_new,a.exch_rate_id) as id_tec_new,
case when isnull(e.faktor,0)=0 or e.faktor=0 then 1 else e.faktor end as faktor,
isnull(f.b2collat_value,0) as b2collat_value,
isnull(f.b2collat_value_est,0) as b2collat_value_est,
case when a.b2_leasing_type='FL' and a.ex_nacin_leas_tip_knjizenja='1' then 1 else 0 end as ol_reported_as_fl,
case when (a.tip_opr='N' and a.ex_nacin_leas_leas_kred='L') or 
	(isnull(f.rre_elligible,0)+isnull(f.rre_non_elligible,0)+
	 isnull(f.cre_elligible,0)+isnull(f.cre_non_elligible,0))>0 
		then 1 else 0 end as insured_with_realestate,
case when isnull(f.rre_elligible,0)+isnull(f.cre_elligible,0)>0 then 1 else 0 end as realestate_elligible_flag,

@id_oc_report as id_oc_report
into #odr_tmp3
from #odr_tmp2 a 
left join #tmp_p_eval b on a.partner_id = b.id_kupca
left join #b2opprod c on c.leasing_type=a.b2_leasing_type and c.id_vrste=a.tmp_id_vrste and c.nacin_leas=a.tmp_nacin_leas 
left join #lsk_provisions d on d.id_cont=a.id_cont 
left join tecajnic e on a.exch_rate_id=e.id_tec and a.id_oc_report=e.id_oc_report
left join #b2_dokument1 f on f.id_cont=a.id_cont
left join (select id_cont,sum(present_val) as present_val from #tmp_fa group by id_cont) g
     on g.id_cont=a.id_cont

declare @eval_model_dom char(3)
declare @gams_flag_dom char(1)

set @eval_model_dom = (select real_eval_model from #tmp_p_eval where id_kupca=@id_customer_dom)
set @gams_flag_dom = (select gams_flag from #tmp_p_eval where id_kupca=@id_customer_dom)

select a.id_cont, a.contract, 
a.object, 
a.no_of_open_installm, 
a.partner_id,
a.fin_type, 
a.type1,
a.equipment_type,
a.group_type,
a.partner_name, 
a.partner_rating,
a.partner_type,
a.b2_segm,
a.is_retail,
a.coconut_no,
a.tax_id_no,
a.anex,
a.status_act,
a.supplier_id,
case when a.faktor=1 then a.exch_rate_id else a.id_tec_new end as exch_rate_id,
a.target_date,
a.cost_centre,
b.id_val as currency,
a.odr_0_29*a.faktor as odr_0_29,
a.odr_30_59*a.faktor as odr_30_59,
a.odr_60_89*a.faktor as odr_60_89,
a.odr_90_119*a.faktor as odr_90_119,
a.odr_120_179*a.faktor as odr_120_179,
a.odr_180_364*a.faktor as odr_180_364,
a.odr_365*a.faktor as odr_365,
a.total_odr*a.faktor as total_odr,
a.interests_in_odr_90*a.faktor as interests_in_odr_90,
a.market_value*a.faktor as market_value,
a.installment_value*a.faktor as installment_value, 
--future_capital_date+future_capital_not_booked+future_capital_not_dued
a.future_capital_total*a.faktor as future_capital_total,
a.varscina*a.faktor as varscina,
a.booked_not_dued_debit_all*a.faktor as booked_not_dued_debit_all,
a.b2_total_exposure*a.faktor as b2_total_exposure,
a.risk_exposure*a.faktor as risk_exposure,
-- lapse of time provision 60_89
a.lt_prov_60_89*a.faktor as lt_prov_60_89,
-- lapse of time provision 90_119
a.lt_prov_90_119*a.faktor as lt_prov_90_119,
-- lapse of time provision 120_179
a.lt_prov_120_179*a.faktor as lt_prov_120_179,
-- lapse of time provision 180_364
a.lt_prov_180_364*a.faktor as lt_prov_180_364,
-- lapse of time provision over 365
a.lt_prov_365*a.faktor as lt_prov_365,
-- after debt of dued liabilities that are older than 90 days exceeds 1 installment
-- termination risk provisions should be calculated as well (odr_180) is in that case only in termination risk provision
-- while other stays in prov_120_179
a.tr_prov*a.faktor as tr_prov,
case when a.max_due_days >= 60 and a.max_due_days < 90 then 
	a.faktor*(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov) else 0 end as general_provisions,
case when a.max_due_days >= 60 and a.max_due_days < 90 then 
	dbo.gfn_xchange(@tec_eur, a.faktor*(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov), a.id_tec_new, @target_date, @id_oc_report)
	else 0 end as general_provisions_EUR,
case when a.max_due_days >= 60 and a.max_due_days < 90 then 
	dbo.gfn_xchange('000', a.faktor*(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov), a.id_tec_new, @target_date, @id_oc_report)
	else 0 end as general_provisions_domv,
case when a.max_due_days >= 90 then 
	a.faktor*(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov) else 0 end as individual_provisions,
case when a.max_due_days >= 90 then 
	dbo.gfn_xchange(@tec_eur, a.faktor*(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov), a.id_tec_new, @target_date, @id_oc_report)
	else 0 end as individual_provisions_EUR,
case when a.max_due_days >= 90 then 
	dbo.gfn_xchange('000', a.faktor*(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov), a.id_tec_new, @target_date, @id_oc_report)
	else 0 end as individual_provisions_domv,
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC, POLO, LOBR
a.future_capital_date*a.faktor as future_capital_date,
--dio buduce glavnice koja proizlazi iz naslova dospjelih nefakturiranih potrazivanja OPC, POLO, LOBR
a.future_capital_not_booked*a.faktor as future_capital_not_booked,
--dio buduce glavnice koja proizlazi iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
a.future_capital_not_dued*a.faktor as future_capital_not_dued,
a.future_other_not_dued*a.faktor as future_other_not_dued,
a.odr_buyout*a.faktor as odr_buyout,
a.buyout_not_booked*a.faktor as buyout_not_booked,
--buduca glavnica iz naslova potrazivanja za otkup 
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC
a.future_buyout_value*a.faktor as future_buyout_value,
a.credit_contract_id,
a.max_due_days,
a.eval_model,
a.gams_flag,
a.eval_model_desc,
a.activation_date,
a.foundation_date,
a.contract_end,
a.real_oper_leas,
a.b2_leasing_type,
a.group_product_type_id,
a.tmp_nacin_leas,a.tmp_id_vrste,
a.product_type,
a.product_subtype,
a.ex_coverage_value*a.faktor as ex_coverage_value,
a.ex_collat_coverage_value*a.faktor as ex_collat_coverage_value,
a.contract_value*a.faktor as contract_value,
a.contract_claims*a.faktor as contract_claims,
a.financed_value*a.faktor as financed_value,
--isnull(d.lsk_prov_amount,0) as lsk_prov_amount,
a.lsk_prov_amount*a.faktor as lsk_prov_amount,
a.id_tec_new,
a.faktor,
dbo.gfn_xchange(@tec_eur, a.b2_total_exposure*a.faktor, a.id_tec_new, @target_date, @id_oc_report) as b2_total_exposure_EUR,
dbo.gfn_xchange(@tec_eur, a.risk_exposure*a.faktor, a.id_tec_new, @target_date, @id_oc_report) as risk_exposure_EUR,
'EUR' as val_eur,
dbo.gfn_xchange('000', a.b2_total_exposure*a.faktor, a.id_tec_new, @target_date, @id_oc_report) as b2_total_exposure_domv,
dbo.gfn_xchange('000', a.risk_exposure*a.faktor, a.id_tec_new, @target_date, @id_oc_report) as risk_exposure_domv,
@domval as val_domv,
a.b2collat_value*a.faktor as b2collat_value,
dbo.gfn_xchange('000', a.b2collat_value*a.faktor, a.id_tec_new, @target_date, @id_oc_report) as b2collat_value_domv,
dbo.gfn_xchange(@tec_eur, a.b2collat_value*a.faktor, a.id_tec_new, @target_date, @id_oc_report) as b2collat_value_eur,
a.b2collat_value_est*a.faktor as b2collat_value_est,
dbo.gfn_xchange('000', a.b2collat_value_est*a.faktor, a.id_tec_new, @target_date, @id_oc_report) as b2collat_value_est_domv,
dbo.gfn_xchange(@tec_eur, a.b2collat_value_est*a.faktor, a.id_tec_new, @target_date, @id_oc_report) as b2collat_value_est_eur,
a.present_val*a.faktor as fa_present_val, 
a.insured_with_realestate,
a.ol_reported_as_fl,
a.orig_eq_type,
a.realestate_elligible_flag,
a.status,
a.p_status,
@id_oc_report as id_oc_report
into #odr_tmp4
from #odr_tmp3 a
left join tecajnic b on a.id_tec_new=b.id_tec and a.id_oc_report=b.id_oc_report

union 

select a.id_cont, 
'FA-'+fa.inv_stev as contract, 
'' as object, 
0 as no_of_open_installm, 
@id_customer_dom as partner_id,
'' as fin_type, 
a.type1,
a.equipment_type,
a.group_type,
'#RAIFFEISEN LEASING' as partner_name, 
'' as partner_rating,
'' as partner_type,
'' as b2_segm,
'N' as  is_retail,
'' as coconut_no,
'' as tax_id_no,
a.anex,
a.status_act,
a.supplier_id,
'000' as exch_rate_id,
a.target_date,
a.cost_centre,
@domval as currency,
0 as odr_0_29,
0 as odr_30_59,
0 as odr_60_89,
0 as odr_90_119,
0 as odr_120_179,
0 as odr_180_364,
0 as odr_365,
0 as total_odr,
0 as interests_in_odr_90,
0 as market_value,
0 as installment_value, 
--future_capital_date+future_capital_not_booked+future_capital_not_dued
0 as future_capital_total,
0 as varscina,
0 as booked_not_dued_debit_all,
fa.present_val as b2_total_exposure,
fa.present_val as risk_exposure,
-- lapse of time provision 60_89
0 as lt_prov_60_89,
-- lapse of time provision 90_119
0 as lt_prov_90_119,
-- lapse of time provision 120_179
0 as lt_prov_120_179,
0 as lt_prov_180_364,
0 as lt_prov_365,
-- after debt of dued liabilities that are older than 90 days exceeds 1 installment
-- termination risk provisions should be calculated as well (odr_180) is in that case only in termination risk provision
-- while other stays in prov_120_179
0 as tr_prov,
0 as general_provisions,
0 as general_provisions_EUR,
0 as general_provisions_domv,
0 as individual_provisions,
0 as individual_provisions_EUR,
0 as individual_provisions_domv,
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC, POLO, LOBR
0 as future_capital_date,
--dio buduce glavnice koja proizlazi iz naslova dospjelih nefakturiranih potrazivanja OPC, POLO, LOBR
0 as future_capital_not_booked,
--dio buduce glavnice koja proizlazi iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
0 as future_capital_not_dued,
0 as future_other_not_dued,
0 as odr_buyout,
0 as buyout_not_booked,
--buduca glavnica iz naslova potrazivanja za otkup 
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC
0 as future_buyout_value,
a.credit_contract_id,
a.max_due_days,
@eval_model_dom as eval_model,
@gams_flag_dom as gams_flag,
'' as eval_model_desc,
a.activation_date,
a.foundation_date,
a.contract_end,
a.real_oper_leas,
a.b2_leasing_type,
a.group_product_type_id,
a.tmp_nacin_leas,a.tmp_id_vrste,
a.product_type,
a.product_subtype,
0 as ex_coverage_value,
0 as ex_collat_coverage_value,
a.contract_value*a.faktor as contract_value,
a.contract_claims*a.faktor as contract_claims,
a.financed_value*a.faktor as financed_value,
--isnull(d.lsk_prov_amount,0) as lsk_prov_amount,
0 as lsk_prov_amount,
a.id_tec_new,
a.faktor,
dbo.gfn_xchange(@tec_eur, fa.present_val, '000', @target_date, @id_oc_report) as b2_total_exposure_EUR,
dbo.gfn_xchange(@tec_eur, fa.present_val, '000', @target_date, @id_oc_report) as risk_exposure_EUR,
'EUR' as val_eur,
fa.present_val as b2_total_exposure_domv,
fa.present_val as risk_exposure_domv,
@domval as val_domv,
0 as b2collat_value,
0 as b2collat_value_domv,
0 as b2collat_value_eur,
0 as b2collat_value_est,
0 as b2collat_value_est_domv,
0 as b2collat_value_est_eur,
0 as fa_present_val, 
0 as insured_with_realestate,
0 as ol_reported_as_fl,
'#' as orig_eq_type,
0 as realestate_elligible_flag,
'' as status,
'' as p_status,
@id_oc_report as id_oc_report
from #odr_tmp3 a
inner join #tmp_fa fa on a.id_cont=fa.id_cont
where a.present_val != 0 and a.real_oper_leas=1 and fa.present_val != 0

union 
-- lastna OS
select 0 as id_cont, 
'FA-'+fa.inv_stev as contract, 
'' as object, 
0 as no_of_open_installm, 
@id_customer_dom as partner_id,
'' as fin_type, 
'' as type1,
'' as equipment_type,
'' As group_type,
'#RAIFFEISEN LEASING' as partner_name, 
'' as partner_rating,
'' as partner_type,
'' as b2_segm,
'N' as  is_retail,
'' as coconut_no,
'' as tax_id_no,
'' as anex,
'' as status_act,
'' as supplier_id,
'000' as exch_rate_id,
@target_date as target_date,
'' as cost_centre,
@domval as currency,
0 as odr_0_29,
0 as odr_30_59,
0 as odr_60_89,
0 as odr_90_119,
0 as odr_120_179,
0 as odr_180_364,
0 as odr_365,
0 as total_odr,
0 as interests_in_odr_90,
0 as market_value,
0 as installment_value, 
--future_capital_date+future_capital_not_booked+future_capital_not_dued
0 as future_capital_total,
0 as varscina,
0 as booked_not_dued_debit_all,
fa.present_val as b2_total_exposure,
fa.present_val as risk_exposure,
-- lapse of time provision 60_89
0 as lt_prov_60_89,
-- lapse of time provision 90_119
0 as lt_prov_90_119,
-- lapse of time provision 120_179
0 as lt_prov_120_179,
0 as lt_prov_180_364,
0 as lt_prov_365,
-- after debt of dued liabilities that are older than 90 days exceeds 1 installment
-- termination risk provisions should be calculated as well (odr_180) is in that case only in termination risk provision
-- while other stays in prov_120_179
0 as tr_prov,
0 as general_provisions,
0 as general_provisions_EUR,
0 as general_provisions_domv,
0 as individual_provisions,
0 as individual_provisions_EUR,
0 as individual_provisions_domv,
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC, POLO, LOBR
0 as future_capital_date,
--dio buduce glavnice koja proizlazi iz naslova dospjelih nefakturiranih potrazivanja OPC, POLO, LOBR
0 as future_capital_not_booked,
--dio buduce glavnice koja proizlazi iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
0 as future_capital_not_dued,
0 as future_other_not_dued,
0 as odr_buyout,
0 as buyout_not_booked,
--buduca glavnica iz naslova potrazivanja za otkup 
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC
0 as future_buyout_value,
'' as credit_contract_id,
0 as max_due_days,
@eval_model_dom as eval_model,
@gams_flag_dom as gams_flag,
'' as eval_model_desc,
'19000101' as activation_date,
'19000101' as foundation_date,
'19000101' as contract_end,
0 as real_oper_leas,
'' as b2_leasing_type,
fa.group_product_type_id,
'' as tmp_nacin_leas,'' as tmp_id_vrste,
'' as product_type,
'' as product_subtype,
0 as ex_coverage_value,
0 as ex_collat_coverage_value,
0 contract_value,
0 as contract_claims,
0 as financed_value,
--isnull(d.lsk_prov_amount,0) as lsk_prov_amount,
0 as lsk_prov_amount,
'000' as id_tec_new,
1 as faktor,
dbo.gfn_xchange(@tec_eur, fa.present_val, '000', @target_date, @id_oc_report) as b2_total_exposure_EUR,
dbo.gfn_xchange(@tec_eur, fa.present_val, '000', @target_date, @id_oc_report) as risk_exposure_EUR,
'EUR' as val_eur,
fa.present_val as b2_total_exposure_domv,
fa.present_val as risk_exposure_domv,
@domval as val_domv,
0 as b2collat_value,
0 as b2collat_value_domv,
0 as b2collat_value_eur,
0 as b2collat_value_est,
0 as b2collat_value_est_domv,
0 as b2collat_value_est_eur,
0 as fa_present_val, 
0 as insured_with_realestate,
0 as ol_reported_as_fl,
'#' as orig_eq_type,
0 as realestate_elligible_flag,
'' as status,
'' as p_status,
@id_oc_report as id_oc_report
from #tmp_fa_own fa
where fa.present_val != 0

union 

select 0 as id_cont, 
'GL-'+gl.konto as contract, 
'' as object, 
0 as no_of_open_installm, 
@id_customer_dom as partner_id,
'' as fin_type, 
'' as type1,
'' as equipment_type,
'' As group_type,
'#RAIFFEISEN LEASING' as partner_name, 
'' as partner_rating,
'' as partner_type,
'' as b2_segm,
'N' as  is_retail,
'' as coconut_no,
'' as tax_id_no,
'' as anex,
'' as status_act,
'' as supplier_id,
'000' as exch_rate_id,
@target_date as target_date,
'' as cost_centre,
@domval as currency,
0 as odr_0_29,
0 as odr_30_59,
0 as odr_60_89,
0 as odr_90_119,
0 as odr_120_179,
0 as odr_180_364,
0 as odr_365,
0 as total_odr,
0 as interests_in_odr_90,
0 as market_value,
0 as installment_value, 
--future_capital_date+future_capital_not_booked+future_capital_not_dued
0 as future_capital_total,
0 as varscina,
0 as booked_not_dued_debit_all,
gl.saldo as b2_total_exposure,
gl.saldo as risk_exposure,
-- lapse of time provision 60_89
0 as lt_prov_60_89,
-- lapse of time provision 90_119
0 as lt_prov_90_119,
-- lapse of time provision 120_179
0 as lt_prov_120_179,
0 as lt_prov_180_364,
0 as lt_prov_365,
-- after debt of dued liabilities that are older than 90 days exceeds 1 installment
-- termination risk provisions should be calculated as well (odr_180) is in that case only in termination risk provision
-- while other stays in prov_120_179
0 as tr_prov,
0 as general_provisions,
0 as general_provisions_EUR,
0 as general_provisions_domv,
0 as individual_provisions,
0 as individual_provisions_EUR,
0 as individual_provisions_domv,
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC, POLO, LOBR
0 as future_capital_date,
--dio buduce glavnice koja proizlazi iz naslova dospjelih nefakturiranih potrazivanja OPC, POLO, LOBR
0 as future_capital_not_booked,
--dio buduce glavnice koja proizlazi iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
0 as future_capital_not_dued,
0 as future_other_not_dued,
0 as odr_buyout,
0 as buyout_not_booked,
--buduca glavnica iz naslova potrazivanja za otkup 
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC
0 as future_buyout_value,
'' as credit_contract_id,
0 as max_due_days,
'' as eval_model,
'' as gams_flag,
'' as eval_model_desc,
'19000101' as activation_date,
'19000101' as foundation_date,
'19000101' as contract_end,
0 as real_oper_leas,
'' as b2_leasing_type,
b.group_product_type_id,
'' as tmp_nacin_leas,'' as tmp_id_vrste,
'GL-'+gl.konto as product_type,
'GL' as product_subtype,
0 as ex_coverage_value,
0 as ex_collat_coverage_value,
0 as contract_value,
0 as contract_claims,
0 as financed_value,
0 as lsk_prov_amount,
'000' as id_tec_new,
1 as faktor,
dbo.gfn_xchange(@tec_eur, gl.saldo, '000', @target_date, @id_oc_report) as b2_total_exposure_EUR,
dbo.gfn_xchange(@tec_eur, gl.saldo, '000', @target_date, @id_oc_report) as risk_exposure_EUR,
'EUR' as val_eur,
gl.saldo as b2_total_exposure_domv,
gl.saldo as risk_exposure_domv,
@domval as val_domv,
0 as b2collat_value,
0 as b2collat_value_domv,
0 as b2collat_value_eur,
0 as b2collat_value_est,
0 as b2collat_value_est_domv,
0 as b2collat_value_est_eur,
0 as fa_present_val, 
0 as insured_with_realestate,
0 as ol_reported_as_fl,
'#' as orig_eq_type,
0 as realestate_elligible_flag,
'' as status,
'' as p_status,
@id_oc_report as id_oc_report
from (select konto,sum(sum_debit_dom-sum_kredit_dom) as saldo
	from oc_gl where id_oc_report=@id_oc_report group by konto) gl
inner join #b2glaccount b on gl.konto=b.konto

-------    Od tu naprej se kreirajo rezultati ------


--rezultat
select * from #odr_tmp4 order by id_cont asc


-- rezultat 1 izbrana polja iz predhod
select partner_id,coconut_no, eval_model, 
contract,
product_type,
product_subtype,
group_product_type_id,
b2_total_exposure,
risk_exposure,
currency,
b2_total_exposure_eur,
risk_exposure_eur,
val_eur,
b2_total_exposure_domv,
risk_exposure_domv,
val_domv,
b2collat_value,
currency,
b2collat_value_eur,
val_eur,
b2collat_value_domv,
val_domv,
b2collat_value_est,
currency,
b2collat_value_est_eur,
val_eur,
b2collat_value_est_domv,
val_domv,
individual_provisions,
currency,
individual_provisions_EUR,
val_eur,
individual_provisions_domv,
val_domv
from #odr_tmp4


-- rezultat 2 grupirano po eval_model (Tiger class) in GPC
select 
eval_model,
group_product_type_id, 
count(distinct partner_id) as no_of_customers,
count(id_cont) as no_of_contracts,
sum(b2_total_exposure_eur) as b2_total_exposure_eur,
sum(b2_total_exposure_domv) as b2_total_exposure_domv,
sum(risk_exposure_eur) as risk_exposure_eur,
sum(risk_exposure_domv) as risk_exposure_domv,
sum(b2collat_value_eur) as b2collat_value_eur,
sum(b2collat_value_domv) as b2collat_value_domv,
sum(b2collat_value_est_eur) as b2collat_value_est_eur,
sum(b2collat_value_est_domv) as b2collat_value_est_domv,
sum(individual_provisions) as individual_provisions,
sum(individual_provisions_EUR) as individual_provisions_EUR,
sum(individual_provisions_domv) as individual_provisions_domv
from #odr_tmp4
group by eval_model,group_product_type_id

-- rezultat 3 KI Light report za RLSI NR_ACCOUNT
select
contract as account_id,
partner_id as customer_id,
group_product_type_id as group_product_type,
--case when left(contract,2)='FA' then '9999-10-01' else datepart(yyyy,activation_date)+'-'+datepart(mm,activation_date)+'-'+datepart(dd,activation_date) end as date_opened,
case when left(contract,2)='FA' then '99991001' else activation_date end as date_opened,
case when left(contract,2)='FA' then '99991001' else contract_end end as date_closed,
'N' as netting_indicator,
null as provision_amount,
'*nomap*' as provision_currency_iso_code,
case when left(contract,2)='FA' then 0 else max_due_days end as date_since_past_due,
'SI' as country_of_risk_iso_code,
'RLSI_B' as deal_book_id,
b2_total_exposure as cleared_balance,
case when left(contract,2)='FA' then val_domv else currency end as cleared_balance_currency_code,
0 as total_accrual_amount,
'EUR' as total_accrual_currency_code
from #odr_tmp4 where is_retail='N' and b2_leasing_type='OL' and id_cont>0 --real_oper_leas = 1 and b2_total_exposure>0

-- rezultat 4 KI Light report za RLSI NR_LOAN
select
contract as contract_id,
partner_id as customer_id,
group_product_type_id as group_product_type,
activation_date as value_date,
contract_end as maturity_date,
'SI' as country_of_risk_iso_code,
b2_total_exposure as current_principal,
currency as principal_currency_iso_code,
1 as seniority_indicator,
lt_prov_60_89+lt_prov_90_119+lt_prov_120_179+lt_prov_180_364+lt_prov_365+tr_prov as provision_amount,
currency as provision_currency_iso_code,
max_due_days as date_since_past_due,
'N' as netting_indicator,
'RLSI_B' as deal_book_id,
0 as total_accrual_amount,
'EUR' as total_accrual_currency_code
from #odr_tmp4 where  is_retail='N' and b2_leasing_type='LO' and id_cont>0

-- rezultat 5 KI Light report za RLSI NR_LEASING
select
contract as contract_id,
partner_id as customer_id,
group_product_type_id as group_product_type,
activation_date as value_date,
contract_end as maturity_date,
'SI' as country_of_risk_iso_code,
case when left(product_subtype,1) = 'O' then 0 else 1 end as risk_indicator,
lt_prov_60_89+lt_prov_90_119+lt_prov_120_179+lt_prov_180_364+lt_prov_365+tr_prov as provision_amount,
currency as provision_currency_iso_code,
max_due_days as date_since_past_due,
'N' as netting_indicator,
'RLSI_B' as deal_book_id,
case when left(product_subtype,1) = 'O' then b2_total_exposure-future_buyout_value else b2_total_exposure end as leasing_npv_amount,
currency as leasing_npv_currency_iso_code,
case when left(product_subtype,1) = 'O' then future_buyout_value else 0 end as leasing_residual_amount,
currency as leasing_residual_currency_code,
0 as total_accrual_amount,
'EUR' as total_accrual_currency_code
from #odr_tmp4 where  is_retail='N' and b2_leasing_type='FL' and id_cont>0

-- rezultat 6 KI Light report za RLSI RETAIL CR_SA_RETAIL tabela grupirana po eval_model
select
a.eval_model,a.val_EUR,
sum(case when a.insured_with_realestate=1 then 0 else a.b2_total_exposure_eur end) as D13,
sum(0) as D14,
sum(0) as D14_T12,
sum(0) as D14_U12,
sum(0) as D14_V12,
sum(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov) as F24,
sum(isnull(b.depozits,0)) as k24
from #odr_tmp4 a 
left join #b2_dokument1 b on a.id_cont=b.id_cont
where a.is_retail='Y' and a.b2_leasing_type!='OL' and a.insured_with_realestate=0 and a.id_cont>0
group by eval_model,val_eur

-- rezultat 7 KI Light report za RLSI RETAIL CR_SA_MOR tabela grupirana po eval_model
select
a.eval_model,a.val_EUR,
sum(case when a.insured_with_realestate=0 then 0 else a.b2_total_exposure_eur end) as D13,
sum(0) as D14,
sum(0) as D14_T12,
sum(0) as D14_U12,
sum(0) as D14_V12,
sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims
	then a.b2_total_exposure_eur else 0 end) as D21,
sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible>=a.contract_claims
	then b2_total_exposure_eur else 0 end) as D22,
sum(case when a.realestate_elligible_flag=0 or  a.equipment_type not in ('3000','3001','3002') or 
	(a.equipment_type in ('3002') and b.rre_elligible<a.contract_claims) or 
	(a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims)
	then a.b2_total_exposure_eur else 0 end) as D25,

sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims
	then a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov else 0 end) as F21,
sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible>=a.contract_claims
	then a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov else 0 end) as F22,
sum(case when a.realestate_elligible_flag=0 or  a.equipment_type not in ('3000','3001','3002') or 
	(a.equipment_type in ('3002') and b.rre_elligible<a.contract_claims) or 
	(a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims)
	then a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov else 0 end) as F25,

sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims
	then isnull(b.depozits,0) else 0 end) as k21,
sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible>=a.contract_claims
	then isnull(b.depozits,0) else 0 end) as k22,
sum(case when a.realestate_elligible_flag=0 or  a.equipment_type not in ('3000','3001','3002') or 
	(a.equipment_type in ('3002') and b.rre_elligible<a.contract_claims) or 
	(a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims)
	then isnull(b.depozits,0) else 0 end) as k25

from #odr_tmp4 a
left join #b2_dokument1 b on a.id_cont=b.id_cont
where a.is_retail='Y' and a.b2_leasing_type!='OL' and a.insured_with_realestate=1 and a.id_cont>0
group by a.eval_model,a.val_eur

-- rezultat 8 KI Light report za RLSI RETAIL CR_SU_P_DUE tabela grupirana po eval_model
/* VG za vsak slucaj sem zakomentiral prejsnjo verzijo
select
eval_model,val_EUR,
sum(case when insured_with_realestate=0 then 0 else b2_total_exposure_eur end) as D13,
sum(0) as D14,
sum(0) as D14_T12,
sum(0) as D14_U12,
sum(0) as D14_V12,
sum(case when realestate_elligible_flag=1 and  equipment_type in ('3002') 
	then b2_total_exposure_eur else 0 end) as D21,
sum(case when realestate_elligible_flag=1 and  equipment_type in ('3000','3001') 
	then b2_total_exposure_eur else 0 end) as D22,
sum(case when realestate_elligible_flag=0 or  equipment_type not in ('3000','3001','3002') 
	then b2_total_exposure_eur else 0 end) as D25,
sum(case when realestate_elligible_flag=1 and  equipment_type in ('3002') 
	then lt_prov_60_89+lt_prov_90_119+lt_prov_120_179+lt_prov_180+tr_prov else 0 end) as F21,
sum(case when realestate_elligible_flag=1 and  equipment_type in ('3000','3001') 
	then lt_prov_60_89+lt_prov_90_119+lt_prov_120_179+lt_prov_180+tr_prov else 0 end) as F22,
sum(case when realestate_elligible_flag=0 or  equipment_type not in ('3000','3001','3002') 
	then lt_prov_60_89+lt_prov_90_119+lt_prov_120_179+lt_prov_180+tr_prov else 0 end) as F25
from #odr_tmp4 where is_retail='Y' and b2_leasing_type!='OL' and id_cont>0
and partner_id in (select id_kupca from oc_customers where p_status='90D' and id_oc_report=@id_oc_report)
group by eval_model,val_eur*/

select
a.eval_model,a.val_EUR,
sum(case when a.insured_with_realestate=0 then 0 else a.b2_total_exposure_eur end) as D13,
sum(0) as D14,
sum(0) as D14_T12,
sum(0) as D14_U12,
sum(0) as D14_V12,
sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2
	then a.b2_total_exposure_eur else 0 end) as D22,

sum(case when 
	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2) 
or	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible>=a.contract_claims)
or	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims and
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2)
or	(a.realestate_elligible_flag=0 or a.equipment_type not in ('3000','3001','3002')) and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2
	then a.b2_total_exposure_eur else 0 end) as D25,

sum(case when 
	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims and
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2)
or	(a.realestate_elligible_flag=0 or a.equipment_type not in ('3000','3001','3002')) and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2
	then a.b2_total_exposure_eur else 0 end) as D27,

sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2
	then a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov else 0 end) as f22,

sum(case when 
	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2) 
or	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible>=a.contract_claims)
or	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims and
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2)
or	(a.realestate_elligible_flag=0 or a.equipment_type not in ('3000','3001','3002')) and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2
	then a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov else 0 end) as F25,

sum(case when 
	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims and
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2)
or	(a.realestate_elligible_flag=0 or a.equipment_type not in ('3000','3001','3002')) and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2
	then a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov else 0 end) as F27,

sum(case when a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2
	then isnull(b.depozits,0) else 0 end) as K22,

sum(case when 
	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3002') and b.rre_elligible>=a.contract_claims and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2) 
or	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible>=a.contract_claims)
or	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims and
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2)
or	(a.realestate_elligible_flag=0 or a.equipment_type not in ('3000','3001','3002')) and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur>=0.2
	then isnull(b.depozits,0) else 0 end) as K25,

sum(case when 
	(a.realestate_elligible_flag=1 and  a.equipment_type in ('3000','3001') and 0.5*b.cre_elligible<a.contract_claims and
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2)
or	(a.realestate_elligible_flag=0 or a.equipment_type not in ('3000','3001','3002')) and 
	(a.lt_prov_60_89+a.lt_prov_90_119+a.lt_prov_120_179+a.lt_prov_180_364+a.lt_prov_365+a.tr_prov)/a.b2_total_exposure_eur<0.2
	then isnull(b.depozits,0) else 0 end) as K27

from #odr_tmp4 a
left join #b2_dokument1 b on a.id_cont=b.id_cont
where a.is_retail='Y' and a.b2_leasing_type!='OL' and a.id_cont>0 and a.b2_total_exposure>0
and a.partner_id in (select id_kupca from oc_customers where p_status='90D' and id_oc_report=@id_oc_report)
group by a.eval_model,a.val_eur

-- rezultat 9 KI Light collateral report za RLSI Non retail LEASING
select a.id_dokum as collateral_id,
i.collat_type_b2 as collateral_type,
a.zacetek as start_date,
a.velja_do as expiry_date,
case when isnull(i.collat_type_b2,'0') in ('14','10') then a.ocen_vred*(a.ex_factor/100) else a.vrednost end as execution_value,
c.id_val as execution_curr_iso_code,
'Y' as qualit_elligibility_indicator,
case when isnull(i.collat_type_b2,'0') not in ('14','10') then '*n.a.*' else
     case when (i.collat_type_b2='10' and a.ex_value_val_contract>=h.contract_claims) or
	       (i.collat_type_b2='14' and a.ex_value_val_contract*0.5>=h.contract_claims) 
		then 'Y' else 'N' end
end as risk_weight_app_code,
a.d_vrednot as revaluation_date,
d.eval_frequency as revaluation_frequency,
'' as fund_haircut_indicator,
'*n.a.*' as daily_quoting_indicator,
'*n.a.*' as issuer_type,
'' as debt_security_maturity_date,
'1' as seniority_indicator,
'*n.a.*' as elligible_without_rating_ecai,
'' as isin,
case when i.collat_type_b2='0' then 'Y' else '*n.a.*' end as ext_depozit_indicator,
'*n.a.*' as main_index_indicator,
'*n.a.*' as stock_exchange_code,
-- sedaj se swift nahaja se v partner.http, kasneje se bo vlekel iz ban_sdk.swift
case when i.collat_type_b2='0' then e.http else '' end as bank_identifier_code,
case when i.collat_type_b2='0' then a.stevilka else '' end as deposit_reference_number,
'*n.a.*' as credit_derivative_type,
'' as position_to_default,
'N' as restructuring_indicator,
e.ext_id as collat_provider_coconut, 
case when f.ex_nacin_leas_leas_kred='K' then 'L' else 'LS' end as secured_transaction,
f.id_pog as secured_transaction_id
from dokument a
inner join #odr_tmp4 h on a.id_cont=h.id_cont
left join tecajnic c on a.id_tec=c.id_tec and a.id_oc_report=c.id_oc_report
left join dok d on a.id_obl_zav=d.id_obl_zav and a.id_oc_report=d.id_oc_report
-- kasneje se mora narediti povezava na BAN_SDK namesto na partner
left join oc_customers e on a.id_kupca=e.id_kupca and a.id_oc_report=e.id_oc_report
inner join oc_contracts f on a.id_cont=f.id_cont and a.id_oc_report=f.id_oc_report
--left join dbo.ban_sdk g on a.id_sdk=g.id_sdk
left join #B2COLLAT i ON a.id_obl_zav = i.id_obl_zav and (a.id_hipot=i.id_hipot OR i.id_hipot='*')
where 
h.is_retail='N' and h.b2_leasing_type='FL' and h.id_cont>0 and 
a.is_elligible=1 and isnull(i.collat_type_b2,'XX') in ('14','10','9','0') 


drop table #odr_tmp1 
drop table #odr_tmp2
drop table #odr_tmp3
drop table #odr_tmp4
drop table #odr_tmp_dokument
drop table #tmp_p_eval
drop table #b2opprod
drop table #lsk_provisions
drop table #b2provision_Accounts
drop table #b2_dokument1
drop table #b2collat
drop table #b2faprod
drop table #tmp_fa
drop table #tmp_fa_own
drop table #b2ini
drop table #b2glaccount
drop table #ocf