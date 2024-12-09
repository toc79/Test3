--------------------------------------------------------------------------------
-- This procedure returns candidates for interest accruals for credit contracts.
--
-- History:
-- 01.09.2008 Ziga; Task ID 5355 - created
-- 21.10.2008 Ziga; Task ID 5355 - added condition for field ne_razmej_obr
-- 28.03.2014 Ziga; Bug ID 30362 - added max_dat_zap_crpanje
--------------------------------------------------------------------------------
CREATE      PROCEDURE [dbo].[grp_InterestAccrualsCandidatesCreditCont] 
@target_date datetime
AS
select
    kp.id_kredpog, o1.obnaleto as obnaleto_razd, o2.obnaleto as obnaleto_obr,
    kppmax.dat_zap as dat_zap_maxpretd,
    kppmin.dat_zap as dat_zap_minposttd,
    kppmax.znes_o as znes_o_maxpretd_VAL,
    kppmin.znes_o as znes_o_minposttd_VAL,
	crp.max_dat_zap_crpanje
from dbo.kred_pog kp
left join dbo.obdobja o1 on kp.id_odplac = o1.id_obd
left join dbo.obdobja o2 on kp.id_odplac2 = o2.id_obd
left join (
    select kpp.*
    from dbo.kred_planp kpp
    inner join (
        select max(kpp.id_kred_planp) as id_kred_planp, kpp.id_kredpog
        from dbo.kred_planp kpp
        inner join dbo.kred_pog kp on kp.id_kredpog = kpp.id_kredpog
        inner join (
            select max(kpp.dat_zap) as dat_zap, kpp.id_kredpog
            from dbo.kred_planp kpp
            inner join dbo.kred_pog kp on kp.id_kredpog = kpp.id_kredpog
            where kpp.dat_zap <= dbo.gfn_GetDatePart(@target_date)
            and kpp.is_event = 0
            and (kp.tip_izracuna = 1 or (kp.tip_izracuna = 2 and kpp.znes_o <> 0))
            group by kpp.id_kredpog
        ) kp1 on kpp.dat_zap = kp1.dat_zap and kpp.id_kredpog = kp1.id_kredpog
        where kpp.is_event = 0
        and (kp.tip_izracuna = 1 or (kp.tip_izracuna = 2 and kpp.znes_o <> 0))
        group by kpp.id_kredpog
    ) kpp1 on kpp.id_kred_planp = kpp1.id_kred_planp
) kppmax on kp.id_kredpog = kppmax.id_kredpog
left join (
    select kpp.*
        from dbo.kred_planp kpp
        inner join (
            select min(kpp.id_kred_planp) as id_kred_planp, kpp.id_kredpog
            from dbo.kred_planp kpp
            inner join dbo.kred_pog kp on kp.id_kredpog = kpp.id_kredpog
            inner join (
                select min(kpp.dat_zap) as dat_zap, kpp.id_kredpog
                from dbo.kred_planp kpp
                inner join dbo.kred_pog kp on kp.id_kredpog = kpp.id_kredpog
                where kpp.dat_zap > dbo.gfn_GetDatePart(@target_date)
                and kpp.is_event = 0
                and (kp.tip_izracuna = 1 or (kp.tip_izracuna = 2 and kpp.znes_o <> 0))
                group by kpp.id_kredpog
            ) kp1 on kpp.dat_zap = kp1.dat_zap and kpp.id_kredpog = kp1.id_kredpog
            where kpp.is_event = 0
            and (kp.tip_izracuna = 1 or (kp.tip_izracuna = 2 and kpp.znes_o <> 0))
            group by kpp.id_kredpog
        ) kpp1 on kpp.id_kred_planp = kpp1.id_kred_planp
) kppmin on kp.id_kredpog = kppmin.id_kredpog
left join (
	select id_kredpog, max(dat_zap) as max_dat_zap_crpanje
	from dbo.kred_planp
	where crpanje > 0
	group by id_kredpog
) crp on crp.id_kredpog = kp.id_kredpog
where (kp.status_akt = 'A' and kp.dat_aktiv <= @target_date)
and not (kppmin.dat_zap is null and kppmax.dat_zap is null)
and kp.ne_razmej_obr = 0