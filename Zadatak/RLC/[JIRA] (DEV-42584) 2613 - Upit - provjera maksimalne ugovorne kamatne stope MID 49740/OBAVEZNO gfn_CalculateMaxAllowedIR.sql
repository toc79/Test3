PRINT 'Upgrading gfn_CalculateMaxAllowedIR'
IF EXISTS(SELECT * FROM sys.objects WHERE type IN ('FN', 'TF', 'IF') AND name = 'gfn_CalculateMaxAllowedIR') DROP FUNCTION [dbo].[gfn_CalculateMaxAllowedIR]
GO

/****** Object:  UserDefinedFunction [dbo].[gfn_CalculateMaxAllowedIR]    Script Date: 4/23/2024 2:53:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------
-- Function: Calculate the maximum allowed interest rate. Currently only for HR (Croatia)
-- returns one record with interest_rate, maximum allowed IR and some other fields
-- Parameters:
--   @obr_mera - current IR of contract or offer
--   @vr_val - VR_VAL of contract or offer
--   @je_foseba - if partner is Natural person (Individual) on Legal person (fizična ali pravna oseba)
--   @nacin_leas - leasing type
--   @datum - date for obr_zgod check


-- History: 
-- 06.11.2023 MatjazB; TID 27671 - created
-- 04.12.2023 MatjazB; TID 27671 - use drzava instead p_sif_slo
-- 06.03.2024 MatjazB; TID 32427 - fix date check; change @tip_knjizenja to @nacin_leas
-- 23.04.2024 g_tomislav; MID 49712 - bugfix on site
----------------------------------------------------------------------------------------
CREATE Function [dbo].[gfn_CalculateMaxAllowedIR] 
(
    @obr_mera decimal(8,4), 
    @vr_val decimal(18,2), 
    @je_foseba bit, 
    @nacin_leas char(2), 
    @datum datetime
    
)
RETURNS table 
AS

RETURN (
    with _nastavit as (
        select top 1 drzava, zakonzom, ppom, max_ir, check_max_ir from dbo.nastavit
    ), _maxir as (
        select top 1 oz.vrednost, oz.id_obr, oz.datum
        from 
            dbo.obr_zgod oz
            inner join _nastavit n on oz.id_obr = n.max_ir
        where
            oz.datum <= @datum
        order by 
            oz.datum desc
    ), _zobr as (
        select top 1 oz.vrednost, oz.id_obr, oz.datum
        from 
            dbo.obr_zgod oz
            inner join _nastavit n on oz.id_obr = n.zakonzom
        where
            oz.datum <= @datum
        order by 
            oz.datum desc
    ), _ppom as (
        select top 1 oz.vrednost, oz.id_obr, oz.datum
        from 
            dbo.obr_zgod oz
            inner join _nastavit n on oz.id_obr = n.ppom
        where
            oz.datum <= @datum
        order by 
            oz.datum desc
    ), _nl as (
        /* trenutno potrebujemo samo zaradi HR */
        select top 1 case when nl.tip_knjizenja = 1 or nl.ol_na_nacin_fl = 1 then 1 else 0 end as is_OL
        from 
            dbo.nacini_l nl
            cross join (select drzava from _nastavit ) n
        where
            nl.nacin_leas = @nacin_leas
            and n.drzava = 'HR'
    ), _izracun as (
            select 
            ROUND(
                -- nastavitve za posamezno državo
                case
                    when n.check_max_ir = 0 then 
                        @obr_mera

                    when n.drzava = 'SI' then 
                        @obr_mera

                    when n.drzava = 'HR' then 
                        case 
                            -- je PO 
                            when @je_foseba = 0 then _zobr.vrednost * 1.75
                            -- je FO in vr_val večji od 132723
                            when @je_foseba = 1 and @vr_val > 132723 then _maxir.vrednost * 1.75
                            -- je FO in operativni lizing
                            when @je_foseba = 1 and _nl.is_OL = 1 then _maxir.vrednost * 1.5
                            -- ostalo za FO
                            when @je_foseba = 1 then dbo.gfn_MinDecimal(_ppom.vrednost * 1.5, _maxir.vrednost * 1.5)
                        end

                    when n.drzava = 'BA' then 
                        @obr_mera

                    when n.drzava = 'RS' then 
                        @obr_mera

                    when n.drzava = 'ME' then 
                        @obr_mera

                    when n.drzava = 'MK' then 
                        @obr_mera
                end, 4) max_obr, 
            (select 
                @obr_mera obr_mera, @je_foseba je_foseba, @vr_val vr_val, @nacin_leas nacin_leas, 
                cast(@datum as date) datum, IIF(@je_foseba = 0, _zobr.vrednost, _maxir.vrednost) zobr, cast(_zobr.datum as date) zobr_datum, 
                _ppom.vrednost ppom, cast(_ppom.datum as date) ppom_datum, 
                -- nastavitve za posamezno državo
                case
                    when n.check_max_ir = 0 then 
                        ''

                    when n.drzava = 'SI' then 
                        ''

                    when n.drzava = 'HR' then 
                        case 
                            -- je PO 
                            when @je_foseba = 0 then 'ZZK * 1.75'
                            -- je FO in vr_val večji od 132723
                            when @je_foseba = 1 and @vr_val > 132723 then 'ZZK * 1.75'
                            -- je FO in operativni lizing
                            when @je_foseba = 1 and _nl.is_OL = 1 then 'ZZK * 1.5'
                            -- ostalo za FO
                            when @je_foseba = 1 then 'MIN(PPKS * 1.5, ZZK * 1.5)'
                        end

                    when n.drzava = 'BA' then 
                        ''

                    when n.drzava = 'RS' then 
                        ''

                    when n.drzava = 'ME' then 
                        ''

                    when n.drzava = 'MK' then 
                        ''
                
                end razlaga
             for xml raw ('root'), elements) as auto_desc_xml
        from 
            _nastavit n
            outer apply _zobr 
            outer apply _ppom 
            outer apply _maxir
            outer apply _nl
    )
    select 
        cast(iif(i.max_obr < @obr_mera, i.max_obr, @obr_mera) as decimal(8,4)) interest_rate, 
        cast(i.max_obr as decimal(8,4)) max_allowedIR, 
        cast(iif(n.check_max_ir = 0, '', i.auto_desc_xml) as varchar(4000)) auto_desc_xml, 
        cast(iif(i.max_obr < @obr_mera, 1, 0) as bit) max_ir_used 
    from 
        _izracun i
        cross apply _nastavit n
)
 GO
