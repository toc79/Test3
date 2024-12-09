--------------------------------------------------------------------------------------  
-- Function: Calculate the maximum allowed interest rate. Currently only for HR (Croatia)  
-- returns one record with interest_rate, maximum allowed IR and some other fields  
-- Parameters:  
--   @obr_mera - current IR of contract or offer  
--   @vr_val - VR_VAL of contract or offer  
--   @je_foseba - if partner is Natural person on Legal person (fizična ali pravna oseba)  
--   @tip_knjizenja - leasing type  
--   @datum - date for obr_zgod check  
  
  
-- History:   
-- 06.11.2023 MatjazB; TID 27672 - created  
----------------------------------------------------------------------------------------  
CREATE Function [dbo].[gfn_CalculateMaxAllowedIR]   
(  
    @obr_mera decimal(8,4),   
    @vr_val decimal(18,2),   
    @je_foseba bit,   
    @tip_knjizenja char(1),   
    @datum datetime  
      
)  
RETURNS table   
AS  
  
RETURN (  
    with _nastavit as (  
        select top 1 p_sif_slo, zakonzom, ppom, check_max_ir from dbo.nastavit  
    ), _zobr as (  
        select top 1 oz.vrednost, oz.id_obr, oz.datum  
        from   
            dbo.obr_zgod oz  
            inner join _nastavit n on oz.id_obr = n.zakonzom  
        where  
            oz.datum < @datum  
        order by   
            oz.datum desc  
    ), _ppom as (  
        select top 1 oz.vrednost, oz.id_obr, oz.datum  
        from   
            dbo.obr_zgod oz  
            inner join _nastavit n on oz.id_obr = n.ppom  
        where  
            oz.datum < @datum  
        order by   
            oz.datum desc  
    ), _izracun as (  
            select   
            ROUND(  
                -- nastavitve za posamezno državo  
                case  
                    when n.check_max_ir = 0 then   
                        @obr_mera  
  
                    when n.p_sif_slo = 'SI' then   
                        @obr_mera  
  
                    when n.p_sif_slo = 'HR' then   
                        case   
                            -- je PO   
                            when @je_foseba = 0 then _zobr.vrednost * 1.75  
                            -- je FO in vr_val večji od 132723  
                            when @je_foseba = 1 and @vr_val > 132723 then _zobr.vrednost * 1.75  
                            -- je FO in operativni lizing  
                            when @je_foseba = 1 and @tip_knjizenja = '1' then _zobr.vrednost * 1.5  
                            -- ostalo za FO  
                            when @je_foseba = 1 then dbo.gfn_MinDecimal(_ppom.vrednost * 1.5, _zobr.vrednost * 1.5)  
                        end  
  
                    when n.p_sif_slo = 'BA' then   
                        @obr_mera  
  
                    when n.p_sif_slo = 'RS' then   
                        @obr_mera  
  
                    when n.p_sif_slo = 'ME' then   
                        @obr_mera  
  
                    when n.p_sif_slo = 'MK' then   
                        @obr_mera  
                end, 4) max_obr,   
            (select   
                @obr_mera obr_mera, @je_foseba je_foseba, @vr_val vr_val, @tip_knjizenja tip_knjizenja,   
                cast(@datum as date) datum, _zobr.vrednost zobr, cast(_zobr.datum as date) zobr_datum,   
                _ppom.vrednost ppom, cast(_ppom.datum as date) ppom_datum,   
                -- nastavitve za posamezno državo  
                case  
                    when n.check_max_ir = 0 then   
                        ''  
  
                    when n.p_sif_slo = 'SI' then   
                        ''  
  
                    when n.p_sif_slo = 'HR' then   
                        case   
                            -- je PO   
                            when @je_foseba = 0 then 'zobr * 1.75'  
                            -- je FO in vr_val večji od 132723  
                            when @je_foseba = 1 and @vr_val > 132723 then 'zobr * 1.75'  
                            -- je FO in operativni lizing  
                            when @je_foseba = 1 and @tip_knjizenja = '1' then 'zobr * 1.5'  
                            -- ostalo za FO  
                            when @je_foseba = 1 then 'MIN(ppom * 1.5, zobr * 1.5)'  
                        end  
  
                    when n.p_sif_slo = 'BA' then   
                        ''  
  
                    when n.p_sif_slo = 'RS' then   
                        ''  
  
                    when n.p_sif_slo = 'ME' then   
                        ''  
  
                    when n.p_sif_slo = 'MK' then   
                        ''  
                  
                end razlaga  
             for xml raw ('root'), elements) as auto_desc_xml  
        from   
            _zobr   
            cross apply _ppom  
            cross apply _nastavit n  
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