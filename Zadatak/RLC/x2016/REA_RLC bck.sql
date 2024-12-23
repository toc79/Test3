USE [Rea_rlc]
GO
/****** Object:  StoredProcedure [dbo].[grp_odr_contract_summary]    Script Date: 15.2.2016. 15:18:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
----------------------------------------------------------------
-- This procedure prepares data about ODR - contract summary.
--
-- History:
-- 28.12.2006 Ziga; created
-- 06.03.2007 Ziga; added criteria for type of financing and for closed contracts (if enabled, also closed contr. are included besides all others)
-- 16.07.2007 MatjazB; Bug ID 26760 - added criteria for STRM
-- 04.02.2007 Ziga; Bug ID 27086 - added fields future_obresti, future_robresti, future_marza, future_regist, future_fin_davek
-- 04.02.2007 Ziga; Bug ID 27086 - added future_fin_davek to calculation of total_exposure
-- 17.03.2008 MatjazB; Maintenance ID 14087 - change CASE for field odr_0_14 and total_odr (before a.ex_dni_zamude>=0) and neto_not_dued (before a.ex_dni_zamude<0)
-- 02.04.2009 Ziga; MID 19898 - changed odr_0_14 into odr_1_14, added new cathegory odr_0 and include odr_0 into total_odr
-- 24.04.2009 Ziga; Bug ID 27827 - repaired calculation of field neto_not_dued - claims with ex_dni_zamude = 0 are not considered anymore
-- 03.12.2009 Ziga; BUG ID 28066 - added criteria for contract and partner and refactor to dynamic execution
-- 24.02.2010 MatjazB; Bug ID 28208 - added fields pog_id_tec and pog_id_val
-- 03.08.2010 MatjazB; Bug ID 28470 - modified field max_due_days (use CASE)
-- 28.12.2010 Ziga; Bug ID 28692 - added fields total_odr_lpod, total_odr_ost, ost_not_dued, future_all_ost
-- 07.01.2011 Ziga; Bug ID 28692 - added field max_due_days_partner
-- 10.10.2011 Ziga; MID 25760 - repaired calculation of fields total_odr, total_odr_lpod, neto_not_dued, ost_not_dued and max_due_days according to new setting zero_days_overdue_is_odr
-- 17.09.2012 IgorS; Bug ID 29568 - added new field davek_not_dued
-- 18.10.2012 Natasa; BUD IF 29568 - added davek_not_dued to total_exposure and repaired calculation of total_exposure, exchange davek to target currency 
-- 19.12.2012 Natasa; MID 37831 - added future_interest_not_dued
-- 20.03.2013 Jost; Bug ID 29982 - modified where condition ('a.status_akt != '''''') - do not display deleted contracts
-- 22.08.2013 Jelena; Bug ID 30294 - remove gfn_xchange for davek_not_dued from fields future_fin_davek and total_exposure
-- 13.01.2014 Jost; MID 40192 - added field 'ex_coverage_value_zac'
-- 14.01.2015 Josip; Task ID 8472 - added fields future_robresti_not_booked, future_robresti_not_dued, future_robresti_total
---------------------------------------------------------------- 

ALTER                                procedure [dbo].[grp_odr_contract_summary]
    @id_oc_report_enabled bit,
    @id_oc_report int,
    @target_id_tec_enabled bit,
    @target_id_tec char(3),
    @target_id_tec_date datetime,
    @id_tec_val char(3),
    @nl_enabled bit,
    @nl_list varchar(8000),
	@id_strm_enabled bit,
	@id_strm_list varchar(8000),
    @zakl_pog_enabled bit,
	@partner_enabled bit,
	@partner_value varchar(100),
	@pogodba_enabled bit,
	@pogodba_value varchar(100)
    
as

SET @id_strm_list = '''' + REPLACE(@id_strm_list, ',', ''',''') + ''''
SET @nl_list = '''' + REPLACE(@nl_list, ',', ''',''') + ''''

DECLARE @cmd1 varchar(8000)
DECLARE @cmd2 varchar(8000)
SET @cmd1 = ''
SET @cmd2 = ''

SET @cmd1 = '
DECLARE @id_oc_report int,
		@target_id_tec char(3),
		@partner_value varchar(100),
		@pogodba_value varchar(100)

SET @id_oc_report = {0}
SET @target_id_tec = {1}
SET @partner_value = {2}
SET @pogodba_value = {3}

DECLARE @target_id_val char(3)
DECLARE @target_date datetime

DECLARE @sporna_potrazivanja char(8)
DECLARE @zero decimal(18,2)
DECLARE @target_tecaj decimal(10,6)
DECLARE @market_value_id char (2)
DECLARE @entity_code char (5)
DECLARE @zero_days_overdue_is_odr bit

SET @target_date = (select date_to from dbo.oc_reports where id_oc_report=@id_oc_report)
SET @target_id_val=(select id_val from dbo.tecajnic where id_tec=@target_id_tec and id_oc_report=@id_oc_report)
SET @target_tecaj = dbo.gfn_VrednostTecaja(@target_id_tec, @target_date,@id_oc_report)
SET @zero = 0
SET @zero_days_overdue_is_odr = (select zero_days_overdue_is_odr from dbo.loc_nast where id_oc_report = @id_oc_report)

SELECT @entity_code = entity_code FROM dbo.oc_reports WHERE id_oc_report = @id_oc_report
'


IF @pogodba_enabled = 1 BEGIN
	SET @cmd1 = @cmd1 + '
DECLARE @tbl_id_cont_list table (id_cont int)

INSERT into @tbl_id_cont_list(id_cont)
SELECT id_cont
FROM dbo.oc_contracts 
WHERE id_oc_report = @id_oc_report AND id_pog LIKE @pogodba_value
'
END


SET @cmd1 = @cmd1 + '
--DOSPJELA NEPLACENA POTRAZIVANJA
select a.id_cont, c.id_kupca,
-- broj otvorenih rata
round(sum(case when b.sif_terj=''LOBR'' then a.ex_saldo_val/a.ex_debit_val else 0 end),2) as no_of_open_installm,
--ODR (overdue receivables) dospjela neplacena potrazivanja za 0 dana
sum(case when a.ex_dni_zamude = 0 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj 
	else @zero end) as odr_0,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 0 do 14 dana
sum(case when a.ex_dni_zamude < 15 and a.ex_dni_zamude>0 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj 
	else @zero end) as odr_1_14,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 15 do 29 dana
sum(case when a.ex_dni_zamude < 30 and a.ex_dni_zamude>=15 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj 
	else @zero end) as odr_15_29,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 30 do 59 dana
sum(case when a.ex_dni_zamude >= 30 and a.ex_dni_zamude < 60 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj 
	else @zero end) as odr_30_59,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 60 do 89 dana
sum(case when a.ex_dni_zamude >= 60 and a.ex_dni_zamude < 90 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as odr_60_89,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 90 do 119 dana
sum(case when a.ex_dni_zamude >= 90 and a.ex_dni_zamude < 120 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as odr_90_119,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 120 do 179 dana
sum(case when a.ex_dni_zamude >= 120 and a.ex_dni_zamude < 180 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as odr_120_179,
--ODR (overdue receivables) dospjela neplacena potrazivanja od 180 do 359 dana
sum(case when a.ex_dni_zamude >= 180 and a.ex_dni_zamude < 360 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as odr_180_359,
--ODR (overdue receivables) dospjela neplacena potrazivanja vise od 360 dana
sum(case when a.ex_dni_zamude >= 360 and a.evident=''*''
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as odr_360,
--ukupni ODR (svi proknjizeni)
sum(case when a.evident=''*'' and ((a.ex_dni_zamude >= 0 and @zero_days_overdue_is_odr = 1) or (a.ex_dni_zamude > 0 and @zero_days_overdue_is_odr = 0))
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as total_odr,
-- ODR - samo obroki
sum(case when a.evident=''*'' and ((a.ex_dni_zamude >= 0 and @zero_days_overdue_is_odr = 1) or (a.ex_dni_zamude > 0 and @zero_days_overdue_is_odr = 0)) and b.sif_terj in (''LOBR'',''OPC'',''POLO'',''DDV'')
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as total_odr_lpod,
--iznos glavnice u neproknjizenim ratama koji se mora spremiti u buduca potrazivanja (buduca glavnica) - nije uknjucen u total ODR
sum(case when a.evident='''' and b.sif_terj in (''LOBR'',''OPC'',''POLO'',''VARS'')
	then (a.ex_debit_dom/@target_tecaj)*(a.neto/a.debit)
	else @zero end) as neto_not_booked,
--iznos glavnice u proknjizenim ratama koji imaju datum dospijeca u buducnosti pa se mora spremiti u buduca potrazivanja (buduca glavnica)- nije uknjucen u total ODR
sum(case when a.evident=''*'' and ((a.ex_dni_zamude < 0 and @zero_days_overdue_is_odr = 1) or (a.ex_dni_zamude <= 0 and @zero_days_overdue_is_odr = 0)) and b.sif_terj in (''LOBR'',''OPC'',''POLO'',''VARS'')
	then (a.ex_debit_dom/@target_tecaj)*(a.neto/a.debit)
	else @zero end) as neto_not_dued,
sum(case when a.evident=''*'' and ((a.ex_dni_zamude < 0 and @zero_days_overdue_is_odr = 1) or (a.ex_dni_zamude <= 0 and @zero_days_overdue_is_odr = 0)) and b.sif_terj in (''LOBR'',''OPC'',''POLO'',''VARS'')
	then (a.ex_debit_dom/@target_tecaj)*((a.obresti + a.regist + a.marza)/a.debit)
	else @zero end) as obresti_not_dued,	
--iznos robresti u neproknjizenim ratama koji se mora spremiti u buduca potrazivanja
sum(case when a.evident='''' and b.sif_terj in (''LOBR'',''OPC'',''POLO'',''VARS'')
	then (a.ex_debit_dom/@target_tecaj)*(a.robresti/a.debit)
	else @zero end) as robresti_not_booked,
--iznos robresti u proknjizenim ratama koji imaju datum dospijeca u buducnosti pa se mora spremiti u buduca potrazivanja
sum(case when a.evident=''*'' and ((a.ex_dni_zamude < 0 and @zero_days_overdue_is_odr = 1) or (a.ex_dni_zamude <= 0 and @zero_days_overdue_is_odr = 0)) and b.sif_terj in (''LOBR'',''OPC'',''POLO'',''VARS'')
	then (a.ex_debit_dom/@target_tecaj)*(a.robresti/a.debit)
	else @zero end) as robresti_not_dued,
--iznos fakturiranog neplacenog otkupa - ukljucen u total ODR
sum(case when a.evident=''*'' and b.sif_terj in (''OPC'')
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as odr_buyout,
--iznos otkupa koji nije proknjizen ali je datumski dospio (u odnosu na target_date) - nije ukljucen u total ODR
sum(case when a.evident='''' and b.sif_terj in (''OPC'')
	then a.ex_saldo_dom/@target_tecaj
	else @zero end) as buyout_not_booked,
-- poknjiženo nezapadlo - ostalo
sum(case when a.evident = ''*'' and ((a.ex_dni_zamude < 0 and @zero_days_overdue_is_odr = 1) or (a.ex_dni_zamude <= 0 and @zero_days_overdue_is_odr = 0)) and b.sif_terj not in (''LOBR'',''OPC'',''POLO'',''DDV'')
	then (a.ex_debit_dom/@target_tecaj)
	else @zero end) as ost_not_dued,
-- iznos davka u proknjiženim ratama koji imaju datum dospijeća u budućnosti pa se mora spremiti u buduća potraživanja (budući davek) - nije uključen u total ODR
sum(case when a.evident = ''*'' and (l.ddv_takoj = 1 or c.dobrocno = 1) and ((a.ex_dni_zamude < 0 and @zero_days_overdue_is_odr = 1) or (a.ex_dni_zamude <= 0 and @zero_days_overdue_is_odr = 0)) and b.sif_terj in (''LOBR'',''OPC'',''POLO'',''DDV'') then (a.ex_debit_dom/@target_tecaj)*(a.davek/a.debit) else @zero end) as davek_not_dued,	
MAX(CASE WHEN a.evident = ''*'' AND a.ex_dni_zamude > 0
    THEN a.ex_dni_zamude
    ELSE 0 END) AS max_due_days
 into #odr_tmp1
 from dbo.oc_claims a 
inner join dbo.vrst_ter b on a.id_terj = b.id_terj and a.id_oc_report = b.id_oc_report
inner join dbo.oc_contracts c on a.id_oc_report = c.id_oc_report and a.id_cont = c.id_cont
inner join dbo.nacini_l l on a.id_oc_report = l.id_oc_report and c.nacin_leas = l.nacin_leas
where a.id_oc_report = @id_oc_report'

IF @partner_enabled = 1 BEGIN
	SET @cmd1 = @cmd1 + CHAR(13) + ' and c.id_kupca = @partner_value'
END

IF @pogodba_enabled = 1 BEGIN
	SET @cmd1 = @cmd1 + CHAR(13) + ' and a.id_cont in (select id_cont from @tbl_id_cont_list)'
END

SET @cmd1 = @cmd1 + CHAR(13) + 'group by a.id_cont, a.id_oc_report, c.id_kupca'

set @cmd1 = @cmd1 + '
select id_kupca, MAX(max_due_days) as max_due_days_partner
into #tmp_partner_dolg
from #odr_tmp1
group by id_kupca'


SET @cmd2 = '
select a.id_pog, 
a.pred_naj, 
a.id_strm,
cast(isnull(c.no_of_open_installm,0) as decimal(18,2)) as no_of_open_installm, 
a.id_kupca,
a.aneks,
a.status_akt,
a.id_dob,
e1.naz_kr_kup as naz_kr_dob,
a.nacin_leas,
d.id_vrste,
isnull(d.id_grupe,'''') as id_grupe,
isnull(d.id_grupe,'''') as opr_id_grupe1,
isnull(d.id_grupe,'''') as opr_id_grupe2,
isnull(d.b2grupa,'''') as opr_b2grupa,
e.naz_kr_kup, 
e.boniteta,
e.vr_osebe,
e.asset_clas as b2_segm,
e.sif_dej,
isnull(f.dej_grupa,'''') as dej_grupa,
isnull(f.dej_grupa1,'''') as dej_grupa1,
isnull(f.dej_grupa2,'''') as dej_grupa2,
--isnull(f.b2_grupa,'''') as dej_b2grupa,
isnull(f.b2grupa,'''') as dej_b2grupa,
@target_id_tec as target_id_tec,
@target_date as target_date,

-- starost najstarejše terjatve iz pogodbe
isnull(c.max_due_days,100000-100000) as max_due_days,

-- starost najstarejše terjatve za partnerja
isnull(pa.max_due_days_partner, 0) as max_due_days_partner,

-- skupen znesek zapadlih neplačanih terjatev
isnull(c.total_odr,@zero) as total_odr,
isnull(c.odr_0,@zero) as odr_0,
isnull(c.odr_1_14,@zero) as odr_1_14,
isnull(c.odr_15_29,@zero) as odr_15_29,
isnull(c.odr_30_59,@zero) as odr_30_59,
isnull(c.odr_60_89,@zero) as odr_60_89,
isnull(c.odr_90_119,@zero) as odr_90_119,
isnull(c.odr_120_179,@zero) as odr_120_179,
isnull(c.odr_180_359,@zero) as odr_180_359,
isnull(c.odr_360,@zero) as odr_360,
isnull(c.total_odr_lpod, @zero) as total_odr_lpod,
isnull(c.total_odr, @zero) - isnull(c.total_odr_lpod, @zero) as total_odr_ost,

-- ako je vrijednost rate = 0 (lizing 50-50 isl) onda se u slucaju kasnjenja ne moze usporediti
-- omjer rate (deljenje sa 0) pa se zato usporedjuje sa minimalnim iznosom 0.01 
case when a.obrok1 != 0 
	then dbo.gfn_xchange(@target_id_tec, a.obrok1, a.id_tec, @target_date, @id_oc_report) 
	else 0.01 end
	as obrok1, 
@target_id_val as target_id_val,

--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC, POLO, LOBR,''VARS''
dbo.gfn_xchange(@target_id_tec, a.ex_g1_neto, a.id_tec, @target_date, @id_oc_report) as future_capital_date,

--dio buduce glavnice koja proizlazi iz naslova dospjelih nefakturiranih potrazivanja OPC, POLO, LOBR,''VARS''
isnull(c.neto_not_booked,@zero) as future_capital_not_booked,

--dio buduce glavnice koja proizlazi iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
isnull(c.neto_not_dued,@zero) as future_capital_not_dued,

--dio buducih kamata koje proizlaze iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
isnull(c.obresti_not_dued,@zero) as future_interest_not_dued, 

-- amount of all booked not dued claims that are not LOBR, OPC, POLO, DDV
isnull(c.ost_not_dued,@zero) as ost_not_dued,

--future_capital_total znesek bodoče glavnice seštevek predhodnjih treh polj
dbo.gfn_xchange(@target_id_tec, a.ex_g1_neto, a.id_tec, @target_date, @id_oc_report)+isnull(c.neto_not_booked,@zero)+isnull(c.neto_not_dued,@zero) as future_capital_total,

--future_fin_dav -> seštevek zneska za bodoči financiran davek v planp kjer je datum_dok > target_date za terjatve OPC, POLO, LOBR, VARS
dbo.gfn_xchange(@target_id_tec, case when nl.ddv_takoj = 1 then a.ex_g1_davek else a.ex_g1_davek_fin end , a.id_tec, @target_date, @id_oc_report) + isnull(c.davek_not_dued, @zero) as future_fin_davek,

--future_obresti -> seštevek bodočih obresti v planp kjer je datum_dok > target_date za terjatve OPC, POLO, LOBR, VARS   
dbo.gfn_xchange(@target_id_tec, a.ex_g1_obresti, a.id_tec, @target_date, @id_oc_report) as future_obresti,

--future_robresti -> seštevek bodočih revaorizacijskih obresti v planp kjer je datum_dok > target_date za terjatve OPC, POLO, LOBR, VARS 
dbo.gfn_xchange(@target_id_tec, a.ex_g1_robresti, a.id_tec, @target_date, @id_oc_report) as future_robresti,

--dio buducih robresti koji proizlaze iz naslova dospjelih nefakturiranih potrazivanja OPC, POLO, LOBR, VARS 
isnull(c.robresti_not_booked,@zero) as future_robresti_not_booked,

--dio buducih robresti koji proizlaze iz naslova fakturiranih potrazivanja OPC, POLO, LOBR koja nisu dospjela do target_date, a datum_dok<target_date
isnull(c.robresti_not_dued,@zero) as future_robresti_not_dued,

--future_robresti_total
dbo.gfn_xchange(@target_id_tec, a.ex_g1_robresti, a.id_tec, @target_date, @id_oc_report)+isnull(c.robresti_not_booked,@zero)+isnull(c.robresti_not_dued,@zero) as future_robresti_total,

--future_marza -> seštevek bodoče marže v planp kjer je datum_dok > target_date za terjatve OPC, POLO, LOBR, VARS
dbo.gfn_xchange(@target_id_tec, a.ex_g1_marza, a.id_tec, @target_date, @id_oc_report) as future_marza,

--future_regist -> seštevek zneska za bodoče dodatne storitve (regist) v planp kjer je datum_dok > target_date za terjatve OPC, POLO, LOBR, VARS
dbo.gfn_xchange(@target_id_tec, a.ex_g1_regist, a.id_tec, @target_date, @id_oc_report) as future_regist,

-- future amount of all claims, that are not LOBR, OPC, POLO, DDV
dbo.gfn_xchange(@target_id_tec, a.ex_g2_debit, a.id_tec, @target_date, @id_oc_report) as future_all_ost,

isnull(c.odr_buyout,@zero) as odr_buyout,
isnull(c.buyout_not_booked,@zero) as buyout_not_booked,


--buduca glavnica iz naslova potrazivanja za otkup 
--zbroj buduce glavnice u planp prema datum_dok>target_date za potrazivanja OPC
dbo.gfn_xchange(@target_id_tec, a.ex_g1_neto_opc_nezap, a.id_tec, @target_date, @id_oc_report)+isnull(c.buyout_not_booked,@zero) as future_buyout_value,

-- št. kreditne pogodbe
a.id_kredpog,

-- total_exposure znpl + bodoča glavnica + bodoči financiran davek
isnull(c.total_odr,@zero) +
dbo.gfn_xchange(@target_id_tec, a.ex_g1_neto, a.id_tec, @target_date, @id_oc_report) + 
isnull(c.neto_not_booked,@zero) + 
isnull(c.neto_not_dued,@zero) +
dbo.gfn_xchange(@target_id_tec, case when nl.ddv_takoj = 1 then a.ex_g1_davek else a.ex_g1_davek_fin end , a.id_tec, @target_date, @id_oc_report) + isnull(c.davek_not_dued, @zero) as total_exposure, 

-- znesek pokritja iz naslova lastništva predmeta
dbo.gfn_xchange(@target_id_tec, a.ex_coverage_value, a.id_tec, @target_date, @id_oc_report) as ex_coverage_value,

-- znesek kritja začetek
dbo.gfn_xchange(@target_id_tec, a.ex_coverage_value_zac, a.id_tec, @target_date, @id_oc_report) as ex_coverage_value_zac,

-- znesek pokritja iz dokumentacije
dbo.gfn_xchange(@target_id_tec, a.ex_coverage_doc, a.id_tec, @target_date, @id_oc_report) as ex_coverage_doc,

-- bianko delež = total_exposure-ex_coverage_value-ex_coverage_doc
isnull(c.total_odr,@zero)+dbo.gfn_xchange(@target_id_tec, a.ex_g1_neto, a.id_tec, @target_date, @id_oc_report)+isnull(c.neto_not_booked,@zero)+isnull(c.neto_not_dued,@zero) 
- dbo.gfn_xchange(@target_id_tec, a.ex_coverage_value, a.id_tec, @target_date, @id_oc_report) - dbo.gfn_xchange(@target_id_tec, a.ex_coverage_doc, a.id_tec, @target_date, @id_oc_report) as bianco_part,

@id_oc_report as id_oc_report,
a.status,
e.p_status,
a.dat_zakl,
a.id_tec AS pog_id_tec,
a.id_val AS pog_id_val
into #odr_tmp2
from dbo.oc_contracts a 
left join #odr_tmp1 c on a.id_cont = c.id_cont
left join dbo.vrst_opr d on a.id_vrste = d.id_vrste and a.id_oc_report = d.id_oc_report
left join dbo.oc_customers e on a.id_kupca = e.id_kupca and a.id_oc_report = e.id_oc_report
left join dbo.oc_customers e1 on a.id_oc_report = e1.id_oc_report and a.id_dob = e1.id_kupca
left join dbo.dejavnos f on e.sif_dej=f.sif_dej and a.id_oc_report=f.id_oc_report
left join dbo.nacini_l nl on a.nacin_leas = nl.nacin_leas and a.id_oc_report = nl.id_oc_report
left join #tmp_partner_dolg pa on pa.id_kupca = a.id_kupca
where a.id_oc_report=@id_oc_report and a.status_akt != '''''


IF @nl_enabled = 1 BEGIN
	SET @cmd2 = @cmd2 + CHAR(13) + ' and a.nacin_leas in (' + @nl_list + ')'
END

IF @zakl_pog_enabled = 0 BEGIN
	SET @cmd2 = @cmd2 + CHAR(13) + ' and (a.status_akt <> ''Z'' OR (a.dat_zakl > @target_date AND a.status_akt = ''Z''))'
END

IF @id_strm_enabled = 1 BEGIN
	SET @cmd2 = @cmd2 + CHAR(13) + ' and a.id_strm in (' + @id_strm_list + ')'
END

IF @partner_enabled = 1 BEGIN
	SET @cmd2 = @cmd2 + CHAR(13) + ' and a.id_kupca = @partner_value'
END

IF @pogodba_enabled = 1 BEGIN
	SET @cmd2 = @cmd2 + CHAR(13) + ' and a.id_cont in (select id_cont from @tbl_id_cont_list)'
END


SET @cmd2 = @cmd2 + CHAR(13) + '
select *
from #odr_tmp2
order by id_pog

drop table #odr_tmp1 
drop table #odr_tmp2
drop table #tmp_partner_dolg'

SET @cmd1 = REPLACE(@cmd1, '{0}', @id_oc_report)
SET @cmd2 = REPLACE(@cmd2, '{0}', @id_oc_report)

SET @cmd1 = REPLACE(@cmd1, '{1}', '''' + @target_id_tec + '''')
SET @cmd2 = REPLACE(@cmd2, '{1}', '''' + @target_id_tec + '''')

SET @cmd1 = REPLACE(@cmd1, '{2}', '''' + @partner_value + '''')
SET @cmd2 = REPLACE(@cmd2, '{2}', '''' + @partner_value + '''')

SET @cmd1 = REPLACE(@cmd1, '{3}', '''' + @pogodba_value + '''')
SET @cmd2 = REPLACE(@cmd2, '{3}', '''' + @pogodba_value + '''')

--print @cmd1
--print @cmd2

exec(@cmd1 + @cmd2)
