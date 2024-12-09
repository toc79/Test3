------------------------------------------------------------------------------------------------------------  
-- Procedure for getting data for intercalary interests (also from ext_func)  
--  
-- History:  
-- 25.11.2010 MatjazB; MID 22632 - created  
-- 09.10.2014 MatjazB; Bug 30585 - added case for st_dni; change dat_do  
-- 09.01.2015 Andrej; MID 48733 - added vrsta_osebe_partner, id_dob, naziv_kr_dob  
-- 25.10.2017 MihaG; BID 33409 - odprava zagona funkcij tudi ko so neaktivne  
-- 08.01.2018 MatjazB; MID 70910 - use custom_settings IntercalaryInt_EndModeAsBeginMode  
-- 20.03.2018 MatjazB; Task 12921 - GDPR  
-- 17.10.2019 MitjaM; BID 37745 - optimization  
-- 17.02.2020 MitjaM; BID 37978 - removed parameters for ext. function  
-- 13.05.2021 MatjazB; MID 96907 - added parameter par_obdobje and add parameter for ext. function  
------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[grp_Int_intr_candidates]  
  
-- Contract  
@par_pogodba_enabled bit = 0,  
@par_pogodba_value varchar(11) = '',  
  
-- Partner  
@id_kupca_enabled bit = 0,  
@id_kupca_value varchar(6) = '',  
  
-- Date of contract activation   
@par_dat_akt_enabled bit = 0,  
@par_dat_akt_od varchar(8) = '',  
@par_dat_akt_do varchar(8) = '',  
  
-- type of financing  
@par_nacinleas_enabled bit = 0,  
@par_nacinleas_nacinleas varchar(500) = '',  
  
-- Contract activity  
@par_status_akt_enabled bit = 0,  
@par_status_akt_akttype int = 0,  
@par_status_akt varchar(500) = '',  
  
-- 1. payment  
@par_izklj_1obrok_mese_akt bit = 0,  
  
-- Aneks  
@par_aneks_enabled bit = 0,  
@par_aneks_type int = 0,  
@par_aneks_value varchar(100) = '',   
  
-- obdobje   
@par_obdobje_enabled bit = 0,  
@par_obdobje_od varchar(8) = '',  
@par_obdobje_do varchar(8) = ''  
  
AS  
BEGIN  
DECLARE @cmd nvarchar(max), @cmd_where nvarchar(max), @top varchar(5), @E varchar(10), @is_ext_func bit, @zap_obr char(1), @id_kupca varchar(8)  
set @is_ext_func = (SELECT count(*) FROM dbo.ext_func WHERE id_ext_func = 'INTERCALARY_INTERESTS' AND id_ext_func_type = 'SQL_RF' AND inactive = 0 and len(rtrim(code)) > 0)  
SET @cmd = ''  
SET @cmd_where = ''  
SET @E = char(13) + char(10)  
set @id_kupca = 'null'  
if @id_kupca_enabled = 1   
    set @id_kupca = '''' + @id_kupca_value + ''''  
SET @top = ''  
IF @is_ext_func = 1   
    SET @top = 'TOP 0'  
  
DECLARE @dat_zak char(8)  
SET @dat_zak = CONVERT(char(8), (SELECT TOP 1 datum_zak FROM dbo.nastavit), 112)  
SET @zap_obr = (SELECT CAST(pol_je_1ob AS char(1)) FROM dbo.nastavit)  
  
IF @par_pogodba_enabled = 1   
    SET @cmd_where = @cmd_where + @E + ' AND id_pog LIKE ''' + @par_pogodba_value + ''''  
  
IF @id_kupca_enabled = 1   
    SET @cmd_where = @cmd_where + @E + ' AND id_kupca = ''' + @id_kupca_value + ''''  
  
IF @par_dat_akt_enabled = 1  
    SET @cmd_where = @cmd_where + @E + ' AND dat_aktiv BETWEEN ''' + @par_dat_akt_od + ''' AND ''' + @par_dat_akt_do + ''''  
  
IF @par_nacinleas_enabled = 1  
BEGIN  
    SET @par_nacinleas_nacinleas = '''' + REPLACE(@par_nacinleas_nacinleas, ',', ''',''') + ''''  
    SET @cmd_where = @cmd_where + @E + ' AND  nacin_leas IN (' + @par_nacinleas_nacinleas + ')'  
END  
  
IF @par_status_akt_enabled = 1  
BEGIN  
    IF @par_status_akt_akttype = 1  
        SET @cmd_where = @cmd_where + @E + ' AND (CHARINDEX(status_akt,''' + RTRIM(@par_status_akt) + ''') = 0)'  
    ELSE  
        SET @cmd_where = @cmd_where + @E + ' AND (CHARINDEX(status_akt,''' + RTRIM(@par_status_akt) + ''') != 0)'  
END  
  
IF @par_izklj_1obrok_mese_akt = 1  
    SET @cmd_where = @cmd_where + @E + ' AND datum_dok > dbo.gfn_GetLastDayOfMonth(dat_aktiv)'  
  
IF @par_aneks_enabled = 1  
BEGIN  
    IF @par_aneks_type = 1  
        SET @cmd_where = @cmd_where + @E + ' AND (CHARINDEX(aneks,''' + RTRIM(@par_aneks_value) + ''') = 0)'  
    ELSE  
        SET @cmd_where = @cmd_where + @E + ' AND (CHARINDEX(aneks,''' + RTRIM(@par_aneks_value) + ''') != 0)'  
END  
  
SET @cmd = '  
    SELECT ' + @top + '  
        id_pog,  
        id_kupca,  
       naz_kr_kup,  
        vrsta_osebe_partner,  
        id_dob,  
        naziv_kr_dob,  
        dat_aktiv,  
        datum_dok,  
        dat_zap,  
        dat_aktiv AS dat_od,  
        case   
            when beg_end = 1 or dbo.gfn_GetCustomSettingsAsBool(''IntercalaryInt_EndModeAsBeginMode'') = 1 then datum_dok   
            else dbo.gfn_MonthAddLastDay(-(12/obnaleto), datum_dok)   
        end AS dat_do,  
        net_nal,  
        id_val,  
        obr_mera,  
        nacin_leas,  
        status_akt,  
        id_cont,  
        id_tec,  
        case when st_dni < 0 then 0 else st_dni end as st_dni,  
        aneks,  
        CAST(0 AS bit) AS oznacen,  
        CAST(CASE  
                WHEN (  
                    datum_dok > ''' + @dat_zak + '''  
                    AND datum_dok <= dat_zap  
                    AND st_dni > 0  
                    AND obr_mera > 0  
                )  
                THEN 1  
                ELSE 0  
                END AS bit  
            ) AS intk_candidat,  
        1 AS tip_izracuna  
    INTO #inter_temp  
    FROM dbo.gfn_get_fin_intr_candidates1(' + @zap_obr + ',' + @id_kupca + ')  
    WHERE 1 = 1 ' + @cmd_where  
  
IF @is_ext_func = 1  
BEGIN  
    SET @cmd = @cmd + @E + '  
        declare @ext_func nvarchar(max)  
        SELECT @ext_func = rtrim(code)   
        FROM dbo.ext_func   
        WHERE id_ext_func = ''INTERCALARY_INTERESTS'' AND id_ext_func_type = ''SQL_RF'' AND inactive = 0   
  
        /* izvede se eksterna funkcija in napolni vrednosti v #inter_temp*/  
        INSERT INTO #inter_temp  
        EXECUTE SP_ExecuteSQL @ext_func,   
        N''@par_pogodba_enabled bit, @par_pogodba_value varchar(11),  
        @id_kupca_enabled bit, @id_kupca_value varchar(6),  
        @par_dat_akt_enabled bit, @par_dat_akt_od varchar(8), @par_dat_akt_do varchar(8),  
        @par_nacinleas_enabled bit, @par_nacinleas_nacinleas varchar(500),  
        @par_status_akt_enabled bit, @par_status_akt_akttype int, @par_status_akt varchar(500),  
        @par_izklj_1obrok_mese_akt bit,  
        @par_aneks_enabled bit, @par_aneks_type int, @par_aneks_value varchar(100),   
        @par_obdobje_enabled bit, @par_obdobje_od varchar(8), @par_obdobje_do varchar(8)'',   
        @par_pogodba_enabled, @par_pogodba_value,  
        @id_kupca_enabled, @id_kupca_value,  
        @par_dat_akt_enabled, @par_dat_akt_od, @par_dat_akt_do,  
        @par_nacinleas_enabled, @par_nacinleas_nacinleas,  
        @par_status_akt_enabled, @par_status_akt_akttype, @par_status_akt,  
        @par_izklj_1obrok_mese_akt,  
        @par_aneks_enabled, @par_aneks_type, @par_aneks_value,   
        @par_obdobje_enabled, @par_obdobje_od, @par_obdobje_do  
    '  
END  
  
SET @cmd = @cmd + @E + '  
    -- dodamo še polja za legendo  
    SELECT   
        *,   
        case   
            when intk_candidat = 0 then dbo.gfn_ColorToInt(''Red'')  
            else dbo.gfn_ColorToInt(''NoColor'')  
        end as parametri_legend  
    FROM #inter_temp WHERE 1 = 1 ' + @cmd_where  
  
SET @cmd = @cmd + @E + 'ORDER BY id_pog'  
  
PRINT(@cmd)  
EXECUTE SP_ExecuteSQL @cmd,   
        N'@par_pogodba_enabled bit, @par_pogodba_value varchar(11),  
        @id_kupca_enabled bit, @id_kupca_value varchar(6),  
        @par_dat_akt_enabled bit, @par_dat_akt_od varchar(8), @par_dat_akt_do varchar(8),  
        @par_nacinleas_enabled bit, @par_nacinleas_nacinleas varchar(500),  
        @par_status_akt_enabled bit, @par_status_akt_akttype int, @par_status_akt varchar(500),  
        @par_izklj_1obrok_mese_akt bit,  
        @par_aneks_enabled bit, @par_aneks_type int, @par_aneks_value varchar(100),   
        @par_obdobje_enabled bit, @par_obdobje_od varchar(8), @par_obdobje_do varchar(8)',   
        @par_pogodba_enabled, @par_pogodba_value,  
        @id_kupca_enabled, @id_kupca_value,  
        @par_dat_akt_enabled, @par_dat_akt_od, @par_dat_akt_do,  
        @par_nacinleas_enabled, @par_nacinleas_nacinleas,  
        @par_status_akt_enabled, @par_status_akt_akttype, @par_status_akt,  
        @par_izklj_1obrok_mese_akt,  
        @par_aneks_enabled, @par_aneks_type, @par_aneks_value,   
        @par_obdobje_enabled, @par_obdobje_od, @par_obdobje_do  
  
END  
  