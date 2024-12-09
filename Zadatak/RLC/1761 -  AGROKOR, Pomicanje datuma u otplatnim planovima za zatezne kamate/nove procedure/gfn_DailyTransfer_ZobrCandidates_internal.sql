IF EXISTS(SELECT * FROM sys.objects WHERE type IN ('FN', 'TF', 'IF') AND name = 'gfn_DailyTransfer_ZobrCandidates_internal') DROP FUNCTION [dbo].[gfn_DailyTransfer_ZobrCandidates_internal]
GO
----------------------------------------------------------------------------------------------------------
-- This internal function is used by clients to fetch all candidate
-- claims for zobr calculation.
--
-- Parameters:
-- @target_date - payment date
--
-- History:
-- 01.03.2003 Vik; created
-- 19.03.2004 Matjaz; Changes due to id_cont 2 PK transition
-- 18.01.2005 Vik; added gfn_ContractCanCalcZOBR
-- 02.03.2005 Vik; fixed so that also closable claims of partially active contracts are selected
-- 04.03.2005 Vik; common code moved from gfn_DailyTransfer_ZobrCandidates into this method
-- 02.06.2005 Vik; fixed condition of dat_zap (removed grace_zobr value)
-- 25.10.2006 Vik; added fields pogodba.nacin_leas, pogodba.aneks ans pogodba.id_strm to result
-- 23.03.2007 Vik; added contract closing priority to result
-- 04.08.2008 Vik; Bug id 27336 - only booked claims can be closed (evident = '*').
-- 04.08.2008 Vik; Bug id 27336 - claims can be closed after datum_dok or dat_zap (depending on loc_nast.close_on_datum_dok)
-- 13.06.2016 Jure; MID 57018 - Added union all for future cancidates. Only when simulation is triggered.
-- 07.09.2016 Domen; T9605 - Added parameter id_terj_plac for gfn_DailyTransfer_GetClaimsInternal.
-- 27.07.2017 Jure; BUG 33274 - Added source from gfn_DailyTransfer_GetClaimsInternal2 instead of gfn_DailyTransfer_GetClaimsInternal (reason: pog_pos.zam_obr)
----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[gfn_DailyTransfer_ZobrCandidates_internal](@target_date datetime)  
returns table AS

return

	select 
		pp.st_dok
	from         
		dbo.gfn_DailyTransfer_GetClaimsInternal2(@target_date, null) pp 
	where
		dbo.gfn_ContractCanCalcZOBR(pp.id_cont) = 1
	union all
	select 
		pp.st_dok
	from 
		dbo.planp pp
		inner join dbo.pogodba po on po.id_cont = pp.id_cont
		inner join dbo.vrst_ter vt on vt.id_terj = pp.id_terj
	where 
		pp.zaprto = ' ' and 
		pp.datum_dok > dbo.gfn_GetDatePart(getdate()) and pp.DATUM_DOK <= @target_date and -- this is a part of simulation (only when target_date > today). We skip flag evident = *
		pp.saldo > 0 and 
		(((select top 1 close_on_datum_dok from dbo.loc_nast) = 1 and vt.ignore_close_on_datum_dok = 0) or pp.dat_zap <= @target_date) and
		(	
			po.STATUS_AKT='A' or
			(po.STATUS_AKT='D' and (pp.ddv_id<>'' or vt.sif_terj='VARS') and vt.requires_full_activation = 0)
		) and
		dbo.gfn_ContractCanCalcZOBR(pp.id_cont) = 1

