USE [NOVA_PROD]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_DailyTransfer_GetClaimsInternal]    Script Date: 30.8.2017. 14:50:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- This function is called from daily transfer to select claims for given customer that 
-- can be covered by payments - but their contracts are not marked for strong_payment.
--
-- History:
-- xx.xx.xxxx Vik; created
-- 25.11.2003 Vik; added checking of contract specifics
-- 22.01.2004 Vik; renamed to gfn_DailyTransfer_GetClaimsForCustomer
-- 19.03.2004 Matjaz; Changes due to id_cont 2 PK transition
-- 06.06.2005 Vik; added index hint (ix_planp_ik)
-- 14.07.2005 Vik; small change in join
-- 29.07.2005 Vik; changed index name
-- 01.03.2007 Vik; task id 4977 - added strong payment condition
-- 23.07.2008 Vik; renamed index from IX_PLANP_ik_dz to IX_PLANP_ik_dz_sa
-- 01.08.2008 Vik; Bug id 27336 - only booked claims can be closed (evident = '*').
-- 01.08.2008 Vik; Bug id 27336 - claims can be closed after datum_dok or dat_zap (depending on loc_nast.close_on_datum_dok)
-- 12.09.2008 Vik; Bug id 27336 - types of claims for partially active contracts must be marked  by vrst_ter.requires_full_activation=0
-- 09.11.2012 Jure; TASK 7080 - Added field id_kupca_pog
-- 02.10.2013 IgorS; Task ID 7463 - added condition ignore_close_on_datum_dok
-- 07.09.2016 Domen; T9605 - Filtering with allowed id_terj
-- 24.01.2017 Domen; replacing SELECT pp.* with actual columns
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[gfn_DailyTransfer_GetClaimsInternal] (
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
		dbo.gfn_ContractCanCoverClaims(pp.id_cont) = 1 and
		case
			when isnull(vtp.closing_claims_type, '1') = '1' then 1
			when vtp.closing_claims_type = '2' and vtp.closing_claims_list not like '%,' + vt.id_terj + ',%' then 1
			when vtp.closing_claims_type = '3' and vtp.closing_claims_list like '%,' + vt.id_terj + ',%' then 1
			else 0
			end = 1
)
