-----------------------------------------------------------------------------------------------------------------------------------------------
-- This function returns exposure for all contracts
--
-- History:
-- 23.03.2015 Domen; MID 42463 - Created
-- 25.03.2015 Ziga; MID 42463 - modifications
-- 11.06.2015 Ziga; MID 42463 - added field total_odr
-----------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[gfn_RaiffRegion_Exposure] (
	@target_date datetime
) RETURNS TABLE AS RETURN (
	select
		pp.id_cont,
		pp.id_tec,
		po.id_kupca,
		-- total_odr
		sum(pp.znp_saldo_brut_all) as total_odr,
		-- b2_total_exposure
		sum(case when nl.tip_knjizenja = '1' and dbo.gfn_RaiffRegion_ol2fl(n.entity_name, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, pp.id_cont) = 0
					then
						pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL
					else
						pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod
						+ case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end
			end) + case when dbo.gfn_RaiffRegion_ol2fl(n.entity_name, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, pp.id_cont) = 1 and not(po.status_akt = 'Z' or po.aneks = 'T') and n.entity_name not in ('RLRS','RRRS') then po.varscina else 0 end
		as b2_total_exposure,
		-- provision exposure
		sum(case when nl.tip_knjizenja = '1' and dbo.gfn_RaiffRegion_ol2fl(n.entity_name, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, pp.id_cont) = 0
					then
						pp.znp_saldo_brut_all
				 when dra.id_dokum is not null and (nl.tip_knjizenja = '2' or dbo.gfn_RaiffRegion_ol2fl(n.entity_name, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, pp.id_cont) = 1) and entity_name in ('RLRS','RRRS')
					then
						pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL
					else
						pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod
						+ case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end
			end) + case when dbo.gfn_RaiffRegion_ol2fl(n.entity_name, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, pp.id_cont) = 1 and not(po.status_akt = 'Z' or po.aneks = 'T') and n.entity_name not in ('RLRS','RRRS') then po.varscina else 0 end
		as provision_exposure,
		-- risk exposure
		sum(pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod
			+ case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end) as risk_exposure,
		max(pp.max_dat_zap_total) as ex_max_dat_zap
	from
		dbo.planp_ds pp
		inner join dbo.pogodba po on po.id_cont = pp.id_cont
		inner join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
		inner join dbo.dav_stop ds on ds.id_dav_st = IsNull(po.id_dav_op, po.id_dav_st)
		cross join (select top 1 isnull(entity_name, 'COMPANY_ID') as entity_name from dbo.loc_nast) n
		left join (
			select max(d.id_dokum) as id_dokum, id_cont
			from dbo.dokument d
			inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
			where d.status_akt = 'A'
			and d.ima = 1
			and dk.sifra = 'REAS'
			group by d.id_cont
		) dra on dra.id_cont = pp.id_cont
	group by pp.id_cont, po.id_kupca, pp.id_tec, n.entity_name, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, po.status_akt, po.varscina
)