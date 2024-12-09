IF EXISTS(SELECT * FROM sys.objects WHERE type IN ('FN', 'TF', 'IF') AND name = 'gfn_DailyTransfer_GetClaimsInternal2') DROP FUNCTION [dbo].[gfn_DailyTransfer_GetClaimsInternal2]
GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- This function is called from daily transfer to select claims for given customer that 
-- can be covered by payments - but their contracts are not marked for strong_payment.
--
-- History:
-- 27.07.2017 Jure; BUG 33274 - Created
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[gfn_DailyTransfer_GetClaimsInternal2] (
	@today datetime,
	@id_terj_plac char(2)
)
RETURNS table AS  


RETURN(
	select 
        pp.ID_CONT,
        pp.DAT_ZAP,
        pp.DATUM_DOK,
        pp.ID_TERJ,
        pp.ZAP_OBR,
        pp.NETO,
        pp.OBRESTI,
        pp.ROBRESTI,
        pp.MARZA,
        pp.REGIST,
        pp.DAVEK,
        pp.DEBIT,
        pp.KREDIT,
        pp.SALDO,
        pp.ZAPRTO,
        pp.ST_DOK,
        pp.ID_DAV_ST,
        pp.DAV_VRED,
        pp.ALI_FAK,
        pp.ID_VAL,
        pp.ID_TEC,
        pp.EVIDENT,
        pp.ID_KUPCA,
        pp.NACIN_LEAS,
        pp.DAT_OBR,
        pp.NA_PLAN_PL,
        pp.DAT_REVAL,
        pp.DDV_ID,
        pp.DAV_N,
        pp.DAV_O,
        pp.DAV_M,
        pp.DAV_R,
        pp.DAV_B,
        pp.VEZA,
        po.strong_payment as pogodba_strong_payment,
        vt.prioriteta as vrst_ter_prioriteta,
        po.id_kupca as id_kupca_pog
	from 
        dbo.planp pp
        inner join dbo.pogodba po on po.id_cont = pp.id_cont
	    inner join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
        inner join dbo.vrst_ter vt on vt.id_terj = pp.id_terj
		outer apply (
			select top 1
				closing_claims_type,
				',' + ltrim(rtrim(isnull(closing_claims_list, ''))) + ',' as closing_claims_list
			from dbo.VRST_TER
			where id_terj = @id_terj_plac
			) vtp
    where 
		pp.zaprto = ' ' and 
        pp.evident = '*' and 
        pp.datum_dok <= @today and -- Vik: this condition is logically the same the evident, but it is easier to include into index
        pp.saldo>0 and 
		(((select top 1 close_on_datum_dok from dbo.loc_nast) = 1 and vt.ignore_close_on_datum_dok = 0) or pp.dat_zap <= @today) and
		(	
            po.STATUS_AKT='A' or
			(po.STATUS_AKT='D' and (pp.ddv_id<>'' or vt.sif_terj='VARS') and vt.requires_full_activation = 0)
        ) and
		case
			when isnull(vtp.closing_claims_type, '1') = '1' then 1
			when vtp.closing_claims_type = '2' and vtp.closing_claims_list not like '%,' + vt.id_terj + ',%' then 1
			when vtp.closing_claims_type = '3' and vtp.closing_claims_list like '%,' + vt.id_terj + ',%' then 1
			else 0
			end = 1
)
GO
