------------------------------------------------------------------  
-- Function for getting summed data of undue claims for oc report  
--  
-- History:  
-- 02.12.2004 Vik; created  
-- 02.09.2005 Vik; added claim_count, min_datum_dok, max_dat_zap and min_dat_zap  
-- 11.09.2006 Vik; MODIFIED ON-SITE - Raiffeisen - year_offset is shifted by one day   
--                 if snapshot is prepared on 31.8.2006, then an installment on 31.8.2007 falls into 0-1 interval, not 1-2  
-- 12.09.2006 Vik; Bug id 26211 - we now use special function for calculating year-difference (see also previous change)  
-- 03.10.2007 Natasa; Task ID 5184 - added month offset   
-- 03.02.2009 Ziga; MID 18977 - replaced function gfn_DiffMonths with gfn_DiffMonths2  
-- 18.11.2014 Josip; Task ID 8376 - Added field robresti_opc  
-- 03.03.2015 Domen; TaskID 8558 - Using gfn_xchange_table instead of gfn_xchange  
-- 26.05.2015 Jure: TASK 8680 - Added support for claim OOBR when interpret longterm claims ONLY.  
------------------------------------------------------------------  
CREATE         function [dbo].[gfn_oc_get_undue_claim_sum](  
    @date_to datetime,  
    @filter_on_id_kupca bit,  
    @id_kupca char(6)  
)  
returns @Result table (  
    id_cont int,  
    id_terj char(2),  
    debit decimal(18,2),  
    neto decimal(18,2),  
    marza decimal(18,2),  
    obresti decimal(18,2),  
    robresti decimal(18,2),  
    regist decimal(18,2),  
    davek decimal(18,2),  
    debit_opc decimal(18,2),  
    neto_opc decimal(18,2),  
    davek_opc decimal(18,2),  
    robresti_opc decimal(18,2),  
    lobr_opc_polo_ddv bit,  
    opc bit,  
    max_datum_dok datetime,  
    min_datum_dok datetime,  
    max_dat_zap datetime,  
    min_dat_zap datetime,  
    year_offset int,  
    month_offset int,   
    claim_count int  
)  
as  
begin  
    declare @id_terj_opc char(2)  
    declare @id_terj_ddv char(2)  
    declare @id_terj_lobr char(2)  
    declare @id_terj_polo char(2)  
 declare @id_terj_oobr char(2)  
    set @id_terj_opc = (select id_terj from vrst_ter where sif_terj='OPC')  
    set @id_terj_ddv = (select id_terj from vrst_ter where sif_terj='DDV')  
    set @id_terj_polo = (select id_terj from vrst_ter where sif_terj='POLO')  
    set @id_terj_lobr = (select id_terj from vrst_ter where sif_terj='LOBR')  
 set @id_terj_oobr = (select id_terj from vrst_ter where sif_terj='OOBR')  
  
    if @filter_on_id_kupca=1  
        INSERT INTO @Result         
            select   
                a.id_cont,  
                a.id_terj,  
                sum(x_debit.znesek) as debit,  
                sum(x_neto.znesek) as neto,  
                sum(x_marza.znesek) as marza,  
                sum(x_obresti.znesek) as obresti,  
                sum(x_robresti.znesek) as robresti,  
                sum(x_regist.znesek) as regist,  
                sum(x_davek.znesek) as davek,  
                sum(x_debit_opc.znesek) as debit_opc,  
                sum(x_neto_opc.znesek) as neto_opc,  
                sum(x_davek_opc.znesek) as davek_opc,  
                sum(x_robresti_opc.znesek) as robresti_opc,  
                case when a.id_terj in (@id_terj_opc, @id_terj_ddv, @id_terj_lobr, @id_terj_polo, @id_terj_oobr) then 1 else 0 end as lobr_opc_polo_ddv,  
                case when a.id_terj = @id_terj_opc then 1 else 0 end as opc,  
                max(max_datum_dok) as max_datum_dok,  
                min(min_datum_dok) as min_datum_dok,  
                max(max_dat_zap) as max_dat_zap,  
                min(min_dat_zap) as min_dat_zap,  
                year_offset,   
                month_offset,   
                sum(claim_count) as claim_count                  
            from (  
                select                      
                    pp.id_cont,  
                    po.id_tec as pogodba_id_tec,  
                    pp.id_tec,  
                    pp.id_terj,  
                    sum(pp.debit) as debit,  
                    sum(pp.neto) as neto,  
                    sum(pp.marza) as marza,  
                    sum(pp.obresti) as obresti,  
                    sum(pp.robresti) as robresti,  
                    sum(pp.regist) as regist,  
                    sum(pp.davek) as davek,  
                    sum(case when pp.zaprto='*' and pp.id_terj = @id_terj_opc then pp.debit else 0 end) as debit_opc,  
                    sum(case when pp.zaprto='*' and pp.id_terj = @id_terj_opc then pp.neto else 0 end) as neto_opc,  
                    sum(case when pp.zaprto='*' and pp.id_terj = @id_terj_opc then pp.davek else 0 end) as davek_opc,  
                    sum(case when pp.zaprto='*' and pp.id_terj = @id_terj_opc then pp.robresti else 0 end) as robresti_opc,  
                    max(pp.datum_dok) as max_datum_dok,  
                    min(pp.datum_dok) as min_datum_dok,  
                    max(pp.dat_zap) as max_dat_zap,  
                    min(pp.dat_zap) as min_dat_zap,  
                    dbo.gfn_DiffYears(@date_to, pp.datum_dok - 1) as year_offset,  
                    dbo.gfn_DiffMonths2(@date_to, pp.datum_dok) as month_offset,  
                    count(*) as claim_count  
                from dbo.planp pp  
                inner join dbo.pogodba po on pp.id_cont = po.id_cont  
                where   
                    po.status_akt in ('A', 'Z') and                         -- only active or already closed contracts  
                    po.dat_aktiv <= @date_to and                            -- activated before target date  
                    pp.id_kupca=@id_kupca and                               -- filter on customer if needed  
                    pp.datum_dok > @date_to                                 -- claim is due after target date  
                group by pp.id_cont, po.id_tec, pp.id_tec, pp.id_terj, dbo.gfn_DiffYears(@date_to, pp.datum_dok - 1), dbo.gfn_DiffMonths2(@date_to, pp.datum_dok)  
            ) a   
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.debit, a.id_tec, @date_to) as x_debit  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.neto, a.id_tec, @date_to) as x_neto  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.marza, a.id_tec, @date_to) as x_marza  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.obresti, a.id_tec, @date_to) as x_obresti  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.robresti, a.id_tec, @date_to) as x_robresti  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.regist, a.id_tec, @date_to) as x_regist  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.davek, a.id_tec, @date_to) as x_davek  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.debit_opc, a.id_tec, @date_to) as x_debit_opc  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.neto_opc, a.id_tec, @date_to) as x_neto_opc  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.davek_opc, a.id_tec, @date_to) as x_davek_opc  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.robresti_opc, a.id_tec, @date_to) as x_robresti_opc  
            group by a.id_cont, a.id_terj, year_offset, month_offset  
    else  
        INSERT INTO @Result         
            select   
                a.id_cont,  
                a.id_terj,  
                sum(x_debit.znesek) as debit,  
                sum(x_neto.znesek) as neto,  
                sum(x_marza.znesek) as marza,  
                sum(x_obresti.znesek) as obresti,  
                sum(x_robresti.znesek) as robresti,  
                sum(x_regist.znesek) as regist,  
                sum(x_davek.znesek) as davek,  
                sum(x_debit_opc.znesek) as debit_opc,  
                sum(x_neto_opc.znesek) as neto_opc,  
                sum(x_davek_opc.znesek) as davek_opc,  
                sum(x_robresti_opc.znesek) as robresti_opc,  
                case when a.id_terj in (@id_terj_opc, @id_terj_ddv, @id_terj_lobr, @id_terj_polo, @id_terj_oobr) then 1 else 0 end as lobr_opc_polo_ddv,  
                case when a.id_terj = @id_terj_opc then 1 else 0 end as opc,  
                max(max_datum_dok) as max_datum_dok,  
                min(min_datum_dok) as min_datum_dok,  
                max(max_dat_zap) as max_dat_zap,  
                min(min_dat_zap) as min_dat_zap,  
                year_offset,  
                month_offset,  
                sum(claim_count) as claim_count                  
            from (  
                select   
                     
                    pp.id_cont,  
                    po.id_tec as pogodba_id_tec,  
                    pp.id_tec,  
                    pp.id_terj,  
                    sum(pp.debit) as debit,  
                    sum(pp.neto) as neto,  
                    sum(pp.marza) as marza,  
                    sum(pp.obresti) as obresti,  
                    sum(pp.robresti) as robresti,  
                    sum(pp.regist) as regist,  
                    sum(pp.davek) as davek,  
                    sum(case when pp.zaprto='*' and pp.id_terj = @id_terj_opc then pp.debit else 0 end) as debit_opc,  
                    sum(case when pp.zaprto='*' and pp.id_terj = @id_terj_opc then pp.neto else 0 end) as neto_opc,  
                    sum(case when pp.zaprto='*' and pp.id_terj = @id_terj_opc then pp.davek else 0 end) as davek_opc,  
                    sum(case when pp.zaprto='*' and pp.id_terj = @id_terj_opc then pp.robresti else 0 end) as robresti_opc,  
                    max(pp.datum_dok) as max_datum_dok,  
                    min(pp.datum_dok) as min_datum_dok,  
                    max(pp.dat_zap) as max_dat_zap,  
                    min(pp.dat_zap) as min_dat_zap,  
                    dbo.gfn_DiffYears(@date_to, pp.datum_dok - 1) as year_offset,  
                    dbo.gfn_DiffMonths2(@date_to, pp.datum_dok) as month_offset,  
                    count(*) as claim_count  
                from dbo.planp pp  
                inner join dbo.pogodba po on pp.id_cont = po.id_cont  
                where   
                    po.status_akt in ('A', 'Z') and                         -- only active or already closed contracts  
                    po.dat_aktiv <= @date_to and                            -- activated before target date  
                    pp.datum_dok > @date_to                                 -- claim is due after target date  
                group by pp.id_cont, po.id_tec, pp.id_tec, pp.id_terj, dbo.gfn_DiffYears(@date_to, pp.datum_dok - 1), dbo.gfn_DiffMonths2(@date_to, pp.datum_dok)  
            ) a   
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.debit, a.id_tec, @date_to) as x_debit  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.neto, a.id_tec, @date_to) as x_neto  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.marza, a.id_tec, @date_to) as x_marza  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.obresti, a.id_tec, @date_to) as x_obresti  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.robresti, a.id_tec, @date_to) as x_robresti  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.regist, a.id_tec, @date_to) as x_regist  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.davek, a.id_tec, @date_to) as x_davek  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.debit_opc, a.id_tec, @date_to) as x_debit_opc  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.neto_opc, a.id_tec, @date_to) as x_neto_opc  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.davek_opc, a.id_tec, @date_to) as x_davek_opc  
            outer apply dbo.gfn_xchange_table(a.pogodba_id_tec, a.robresti_opc, a.id_tec, @date_to) as x_robresti_opc  
            group by a.id_cont, a.id_terj, year_offset, month_offset   
    return  
end  