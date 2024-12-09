------------------------------------------------------------------------------------------------------------------------------------
-- Returns all contracts that are candidates for reprogram due to index change
-- History:
-- ????????? Matjaz; created
-- 22.03.2004 Matjaz; Changes due to id_cont 2 PK transition
-- 08.11.2004 Matjaz; added columns p.opcija, p.opc_imaobr, p.dva_pp
-- 08.11.2004 Matjaz; added column po_tecaju and removed join on tecajnic
-- 08.11.2004 Matjaz; removed column datum
-- 09.11.2004 Matjaz; added columns disk_r, opc_datzad, nacin_ms, dat_kkf, ddv_id
-- 10.11.2004 Matjaz; added condition for id_tiprep = 1, added dej_obr
-- 12.11.2004 Matjaz; removed column oznacen
-- 15.11.2004 Matjaz; added columns dav_obv, dav_stev, name_and_address, id_obrs
-- 26.11.2004 Matjaz; removed din_ind and din_pog
-- 26.11.2004 Matjaz; added condition for id_tiprep=1 that summary factor has to be different than 0
-- 29.11.2004 Matjaz; added rind_faktor
-- 23.01.2005 Vik; added pred_ddv
-- 25.01.2005 Matjaz; added obindnaleto
-- 09.02.2006 Matjaz; changed condition for index change from >= to >
-- 02.06.2006 Vilko; added field p.id_strm
-- 18.07.2006 Vilko; added condition for future interests, which should be greater then setting
-- 07.09.2006 Vilko; fixed null value for field bod_obresti_lpod
-- 09.11.2006 Vilko; Maintenance ID 4648 - added fields p.dat_sklen and p.kon_naj
-- 26.03.2007 MatjazB; Maintenance ID 6674 - added condition for id_tiprep = 4
-- 22.06.2007 Vilko; Bug ID 26692 - added case switch due problems with query execution on SQL 2005
-- 05.02.2008 Ziga; Bug ID 13152 - added condition for bod_cnt_lobr > 0 if id_tip_rep <> 2
-- 11.03.2011 Jasna; MID 29163 - added round for l.indeks
-- 31.08.2011 TASK 6401 - Jure; Added support for new calcalation type of installments (tip_om)
-- 13.08.2014 MID 45172 - Jure; Added support for strategy r.fix_dat_rpg of reprogramming (index change => id_rtip = 2)
-- 09.09.2014 MID 45172 - Jure; Tweaking - Added call of function gfn_RindStrat_GetNewIndexDate to choose right index date
-- 02.10.2014 Bug ID 30587 - Jelena; completed indeks_na_dan and added field fix_dat_rpg
-- 24.10.2014 Jure; Task 8293 - Added obnaleto_rtip field
-- 19.01.2015 Jure; Added call of function dbo.gfn_RindStrat_GetCurrentNextRpgDate when calculating rind_dat_next
-- 16.04.2015 Jure; TASK 8629 - Added support for installment credit
-- 04.12.2015 Jure; TASK 9130 - Changed inner join to left join on table planp_ds
-- 05.04.2016 Jure; BUG 32176 - Added bod_cnt_lobr field
-- 05.04.2016 Jure; BUG 32176 - Correction of show only installment credit candidates
-- 04.10.2016 Jure; MID XXXXX - Optimization of view
-- 02.01.2017 Jure; MID 60970 - Corection of condition rep_spr_ind
-- 19.09.2018 MatjazB; Task 14660 - added p.je_nk
-- 17.03.2020 MitjaM; BID 38037 - changed format for opiskup
-- 03.07.2023 MatjazB; MID 123016 - optimization
-- 06.11.2023 MatjazB; TID 27672 - added check for max IR
-- 16.11.2023 MatjazB; TID 27672 - fix parametar gfn_CalculateMaxAllowedIR
-- 06.03.2024 MatjazB; TID 32427 - change parametar gfn_CalculateMaxAllowedIR
------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW [dbo].[gv_RepIndCandidates]
AS

with _cte as (
    select
        pog.id_cont, 
        pog.id_pog, 
        pog.id_kupca, 
        pog.id_rtip, 
        pog.rind_zadnji, 
        pog.id_obd, 
        pog.fix_del, 
        pog.dobrocno, 
        pog.id_val, 
        pog.id_strm,
        pog.rind_datum, 
        pog.obr_mera, 
        pog.nacin_leas,
        pog.id_dav_st, 
        pog.rind_faktor, 
        pog.pred_ddv,
        pog.rind_tgor, 
        pog.beg_end, 
        pog.vr_prom, 
        pog.dej_obr,
        pog.id_dav_op, 
        pog.rind_zahte, 
        pog.id_tec, 
        pog.po_tecaju, 
        pog.opcija, 
        pog.opc_imaobr, 
        pog.dva_pp, 
        pog.disk_r, 
        pog.opc_datzad, 
        pog.nacin_ms, 
        pog.dat_kkf, 
        pog.ddv_id, 
        pog.id_obrs,
        pog.dat_sklen, 
        pog.kon_naj, 
        pog.tip_om,
        pog.obr_merak,
        pog.obrok1, 
        pog.je_nk, 
        pog.id_rind_strategije, 
        pog.vr_val_zac, 
        cast(pog.sys_ts as bigint) sys_ts, 
        cast(case when pog.rind_dat_next is null then 1 else 0 end as bit) isnull_rind_dat_next, 
        case when r.id_tiprep = 1 then dbo.gfn_GetSumIndexFromGivenDate(pog.id_rtip, pog.rind_datum) end as sum_index,
        dbo.gfn_RindStrat_GetCurrentRindDatNext(pog.rind_dat_next, pog.id_rtip, 0) as rind_dat_next,
        dbo.gfn_RindStrat_GetCurrentRindDatNext(pog.rind_dat_next, pog.id_rtip, 1) as rind_dat_next_new,
        cast(cast(getdate() as date) as datetime) as today, 
        r.id_tiprep, r.fix_dat_rpg, 
        l.dat_ind, l.indeks, l.obnaleto, l.obindnaleto
    from 
        dbo.pogodba pog
        inner join dbo.rtip r on pog.id_rtip = r.id_rtip
        inner join dbo.gv_lastindexes l on pog.id_rtip = l.id_rtip
        left join dbo.pog_pos ps on pog.id_cont = ps.id_cont
    where
        -- pogodba mora biti aktivna
        pog.status_akt = 'A'
        -- todo (ustavljenost pogodbe bo v statusu ali posebnostih pogodb - še ni dorečeno)
        and ps.knjizenje is null
        and (ps.rep_spr_ind is null or ps.rep_spr_ind < cast(getdate() as date))
        -- samo za ustrezne tipe indeksov
        and r.id_tiprep <> 0 
        -- ali smo že v novem obdobju plačevanja
        and ((r.fix_dat_rpg = 0 and (12*year(getdate()) + month(getdate())) - (12*year(pog.rind_datum) + month(pog.rind_datum)) >= (12/l.obnaleto)) 
            or 
            (r.fix_dat_rpg = 1 and pog.rind_dat_next <= getdate()))
    )
, _nid as (
    select
        id_cont, 
        case when id_rind_strategije is not null then dbo.gfn_RindStrat_GetNewIndexDate(rind_dat_next, id_rind_strategije) end as new_index_date
    from 
        _cte 
    )
SELECT 
    p.id_cont, 
    p.id_pog, 
    p.id_kupca, 
    p.id_rtip, 
    CASE 
        WHEN p.id_tiprep = 1 THEN p.sum_index 
        ELSE p.rind_zadnji 
    END as rind_zadnji, 
    p.id_obd, 
    p.fix_del, 
    p.dobrocno, 
    p.id_val, 
    p.id_strm,
    p.rind_datum, 
    case when p.id_rind_strategije is null then p.dat_ind else rv.datum end as dat_ind, 
    case when p.id_rind_strategije is null then p.indeks else rv.indeks/100 end as indeks, 
    p.obr_mera, 
    p.nacin_leas,
    p.id_tiprep, 
    p.id_dav_st, 
    p.rind_faktor, 
    p.pred_ddv,
    p.rind_tgor, 
    p.beg_end, 
    p.vr_prom, 
    p.obnaleto, 
    p.obindnaleto, 
    p.dej_obr,
    p.id_dav_op, 
    p.rind_zahte, 
    p.id_tec, 
    p.po_tecaju, 
    p.opcija, 
    p.opc_imaobr, 
    p.dva_pp, 
    p.disk_r, 
    p.opc_datzad, 
    p.nacin_ms, 
    p.dat_kkf, 
    p.ddv_id, 
    p.id_obrs,
    c.dav_obv, 
    c.dav_stev,
    (c.naz_kr_kup + ', ' + c.ulica_sed + ', ' + c.id_poste_sed + ' ' + c.mesto_sed) as name_and_address,
    p.dat_sklen, 
    p.kon_naj, 
    p.tip_om,
    rs.odmik as rind_odmik, 
    rs.working_days as rind_working_days, 
    p.id_rind_strategije, 
    p.rind_dat_next,
    p.rind_dat_next_new,
    CASE 
        WHEN p.isnull_rind_dat_next = 1 and p.id_rind_strategije IS NULL THEN p.today
        ELSE _nid.new_index_date
    END as indeks_na_dan, -- !!! pove na kateri dan BI MORAL biti vnešen indeks !!!
    p.fix_dat_rpg,
    p.obindnaleto as obnaleto_rtip,
    nl.installment_credit,
    p.obr_merak,
    p.obrok1, 
    p.je_nk, 
    p.sys_ts, 
    maxir.interest_rate, 
    maxir.max_allowedIR, 
    maxir.max_allowedDesc, 
    isnull(maxir.max_ir_used, 0) as max_ir_used 
FROM 
    _cte p
    inner join dbo.partner c on p.id_kupca = c.id_kupca
    inner join dbo.nacini_l nl on p.nacin_leas = nl.nacin_leas
    left join _nid on p.id_cont = _nid.id_cont
    left join dbo.rvred as rv on p.id_rind_strategije is not null and 
                                  p.id_rtip = rv.id_rtip and 
                                  _nid.new_index_date = rv.datum
    left join dbo.rind_strategije as rs on p.id_rind_strategije = rs.id_rind_strategije
    outer apply 
        (
            select x.interest_rate, x.max_allowedIR, x.auto_desc_xml as max_allowedDesc, x.max_ir_used 
            from
                dbo.vrst_ose vo 
                cross apply dbo.gfn_CalculateMaxAllowedIR(
                        (isnull(case when p.id_rind_strategije is null then p.indeks*100 else rv.indeks end, 0) + isnull(p.fix_del, 0)), 
                        p.vr_val_zac, 
                        case when vo.sifra = 'FO' then 1 else 0 end, 
                        p.nacin_leas, 
                        cast(cast(getdate() as date) as datetime)
                    ) x
                cross join (select 1 check_max_ir from dbo.nastavit) n
            where
                vo.vr_osebe = c.vr_osebe
                and n.check_max_ir = 1

        ) maxir
where 
    (CASE
        -- pri revalorizaciji glavnice moramo pogledati, 
        -- ce zmnozek vseh indeksov od zadnjega reprograma presega toleranco in je vecji od 0
        WHEN 
            p.id_tiprep = 1 
            and abs(p.sum_index/100) >= abs(p.rind_tgor)/100
            and abs(p.sum_index/100) > 0 THEN 1
        -- pri verižnem indeksu primerjamo 2 indeksa med sabo
        WHEN 
            p.id_tiprep = 4 
            AND ABS(round(p.indeks, 6)/(p.rind_zadnji/100)-1) > ABS(p.rind_tgor)/100 THEN 1
        -- pri ostalih pa razliko med indeksom ob zadnjem reprogramu in trenutnim indeksom 
        WHEN 
            p.id_tiprep not in (1, 4) 
            and (
                (p.fix_dat_rpg = 0 and abs(round(p.indeks, 6) - p.rind_zadnji/100) > abs(p.rind_tgor)/100) 
                or 
                (p.fix_dat_rpg = 1)
                ) THEN 1
        ELSE 0
    END) = 1

