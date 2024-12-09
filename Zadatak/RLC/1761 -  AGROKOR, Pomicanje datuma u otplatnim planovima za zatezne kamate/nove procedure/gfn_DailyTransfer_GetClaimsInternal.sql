IF EXISTS(SELECT * FROM sys.objects WHERE type IN ('FN', 'TF', 'IF') AND name = 'gfn_DailyTransfer_GetClaimsInternal') DROP FUNCTION [dbo].[gfn_DailyTransfer_GetClaimsInternal]
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
-- 24.01.2017 Domen; replacing SELECT * with actual columns
-- 27.07.2017 Jure; BUG 33274 - Added call of function gfn_DailyTransfer_GetClaimsInternal2
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[gfn_DailyTransfer_GetClaimsInternal] (
	@today datetime,
	@id_terj_plac char(2)
)
RETURNS table AS  

RETURN(
	select 
        ID_CONT,
        DAT_ZAP,
        DATUM_DOK,
        ID_TERJ,
        ZAP_OBR,
        NETO,
        OBRESTI,
        ROBRESTI,
        MARZA,
        REGIST,
        DAVEK,
        DEBIT,
        KREDIT,
        SALDO,
        ZAPRTO,
        ST_DOK,
        ID_DAV_ST,
        DAV_VRED,
        ALI_FAK,
        ID_VAL,
        ID_TEC,
        EVIDENT,
        ID_KUPCA,
        NACIN_LEAS,
        DAT_OBR,
        NA_PLAN_PL,
        DAT_REVAL,
        DDV_ID,
        DAV_N,
        DAV_O,
        DAV_M,
        DAV_R,
        DAV_B,
        VEZA,
        pogodba_strong_payment,
        vrst_ter_prioriteta,
        id_kupca_pog
	from 
        dbo.gfn_DailyTransfer_GetClaimsInternal2(@today, @id_terj_plac)
    where 
		dbo.gfn_ContractCanCoverClaims(id_cont) = 1
)
GO
