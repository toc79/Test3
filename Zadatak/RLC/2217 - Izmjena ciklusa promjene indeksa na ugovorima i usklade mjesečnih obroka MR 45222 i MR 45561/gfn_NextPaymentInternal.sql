-----------------------------------------------------------------------------------------------------------------------------------  
-- Returns date of installment with index p_Indeks, with regard to date of first installment and payment dynamics  
-- @p_DatumPrvega - first installment date  
-- @p_Dinamika - number of payments per year  
-- @p_Indeks - installment index  
-- @p_PrviDelovni - should we return the first working day or just calculated date  
-- @p_DatumDokType - register for setting installment date  
--  
-- History:  
-- XX.XX.XXXX YYYY; created  
-- 12.12.2013 Jasna; MID 41892 - added new parameter @id_datum_dok_create_type  
-- 18.12.2013 Jasna; MID 41892 - added LastWorkDay function  
-- 13.01.2017 MatjazB; Bug 32715 - create function gfn_NextPaymentInternal  
-----------------------------------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_NextPayment] (  
    @p_DatumPrvega datetime,   
    @p_Dinamika decimal(6,2),   
    @p_Indeks smallint,   
    @p_PrviDelovni bit,  
    @p_DatumDokType int)    
RETURNS datetime   
AS    
BEGIN   
 RETURN (select dbo.gfn_NextPaymentInternal(@p_DatumPrvega, @p_Dinamika, @p_Indeks, @p_PrviDelovni, @p_DatumDokType, 0))  
END  
  
 
-----------------------------------------------------------------------------------------------------------------------------------  
-- Returns date of installment with index p_Indeks, with regard to date of first installment and payment dynamics  
-- @p_DatumPrvega - first installment date  
-- @p_Dinamika - number of payments per year  
-- @p_Indeks - installment index  
-- @p_PrviDelovni - should we return the first working day or just calculated date (if @p_DatumDokType is set, then this parameter is not used)  
-- @p_DatumDokType - register for setting installment date  
-- @p_NePreverjajDelovniDan - can handle if @p_DatumDokType is set and we need fix date  
--  
-- History:  
-- 13.01.2017 MatjazB; Bug 32715 - created (code moved from gfn_NextPayment) and added new parameter @p_NePreverjajDelovniDan  
-- 20.07.2017 Domen; TID 10321 - Removing "SET ANSI_NULLS OFF"  
-----------------------------------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_NextPaymentInternal] (  
    @p_DatumPrvega datetime,   
    @p_Dinamika decimal(6,2),   
    @p_Indeks smallint,   
    @p_PrviDelovni bit,  
    @p_DatumDokType int,   
    @p_NePreverjajDelovniDan bit)  
RETURNS datetime   
AS    
BEGIN   
    DECLARE @NP datetime, @odmik int, @delovni_dan bit  
      
    /*podatki za datum dok iz šifranta*/  
    IF @p_DatumDokType is not null  
    BEGIN  
        SET @odmik = (SELECT odmik FROM dbo.datum_dok_create_type WHERE id_datum_dok_create_type = @p_DatumDokType)  
        SET @delovni_dan = (SELECT delovni_dan FROM dbo.datum_dok_create_type WHERE id_datum_dok_create_type = @p_DatumDokType)  
    END  
    --/* če se ne sme preverjati delonvi dan */  
    IF @p_NePreverjajDelovniDan = 1  
    BEGIN  
        SET @delovni_dan = 0  
    END  
    /*  
    - datum dok tip ni definiran,   
    - ko je odmik 0 - kar pomeni, da ne bo vpliva na datum_dok razenv kolikor je setan bit delovni_dan (datum_dok premaknjen na prvi delovni dan)  
    - če ne preverja delonvi dan, kar je vedno pri vnosu datuma prvega obroka   
    */  
    IF @p_DatumDokType is null OR @odmik = 0   
    BEGIN  
        IF @delovni_dan is not null  
            set @NP = case   
                        when @delovni_dan = 0 then dateadd(m, 12 / @p_Dinamika * (@p_Indeks - 1), @p_DatumPrvega)  
                        else dbo.gfn_FirstWorkDay(dateadd(m, 12 / @p_Dinamika * (@p_Indeks - 1), @p_DatumPrvega))   
                       end  
        ELSE  
            set @NP = case   
                        when @p_PrviDelovni = 0 then dateadd(m, 12 / @p_Dinamika * (@p_Indeks - 1), @p_DatumPrvega)  
                        else dbo.gfn_FirstWorkDay(dateadd(m, 12 / @p_Dinamika * (@p_Indeks - 1), @p_DatumPrvega))  
                      end  
    END  
    ELSE -- IF @p_DatumDokType is null OR @odmik = 0  
    BEGIN  
        SET @NP = dateadd(m, 12 / @p_Dinamika * (@p_Indeks - 1), @p_DatumPrvega)  
        /* odmik = -n pomeni, da gre za -n +1 dan od konca meseca; odmik = -1 pomeni zadnji dan v mesecu */  
        IF @odmik < 0  
            set @NP = case   
                        when @delovni_dan = 1 then (SELECT dbo.gfn_LastWorkDay(dateadd(day, @odmik + 1, (SELECT dbo.gfn_GetLastDayOfMonth(@NP)))))  
                        else (dateadd(day, @odmik + 1, (SELECT dbo.gfn_GetLastDayOfMonth(@NP))))  
                      end   
        ELSE  
            /* odmik = n pomeni, da gre za n - 1 dan od začetka meseca; odmik = 1 pomeni prvi dan v mesecu */  
            set @NP = case   
                        when @delovni_dan = 1 then (SELECT dbo.gfn_FirstWorkDay(dateadd(day, @odmik - 1, (SELECT dbo.gfn_GetFirstDayOfMonth(@NP)))))  
                        else (SELECT dateadd(day, @odmik - 1, (SELECT dbo.gfn_GetFirstDayOfMonth(@NP))))  
                      end   
    END -- IF @p_DatumDokType is null OR @odmik = 0  
    RETURN @NP  
END  
  