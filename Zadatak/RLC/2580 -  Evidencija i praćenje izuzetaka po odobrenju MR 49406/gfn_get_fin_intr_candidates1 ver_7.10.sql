----------------------------------------------------------------------------------------------------------  
-- This function is used by client to get all contracts-candidates for calculation of finance interests    
--  
-- History:  
-- 08.01.2008 Natasa; Maintenance id 12551; created  
-- 09.06.2009 MatjazB; MID 21221 - added po.aneks  
-- 25.11.2010 MatjazB; MID 22632 - fix check for first LOBR (added parameter)  
-- 09.10.2014 MatjazB; Bug 30585 - added check for BEG_END; added join dbo.obdobja o; added pp.beg_end and o.obnaleto  
-- 09.01.2015 Andrej; MID 48733 - added 'vop.naziv as vrsta_osebe_partner', 'po.id_dob', 'dob.naz_kr_kup as naziv_kr_dob' and joins for 'vop' and 'dob'  
-- 08.01.2018 MatjazB; MID 70910 - use custom_settings IntercalaryInt_EndModeAsBeginMode  
-- 20.03.2018 MatjazB; Task 12921 - GDPR added parameter  
-- 04.07.2022 MatjazB; TID 25256 - added parameter par_xml  
----------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_get_fin_intr_candidates1](@zap_obr int, @id_kupca char(6), @par_xml xml)  
returns table as  
return(  
  
with _par as (  
    select  
        id_pog = XTbl.value('(*:id_pog)[1]', 'varchar(11)'),   
        akt_od = XTbl.value('(*:akt_od)[1]', 'datetime'),  
        akt_do = XTbl.value('(*:akt_do)[1]', 'datetime')  
    from   
        @par_xml.nodes('/*:params') AS XD(XTbl)  
),  
_strm_par as (  
    select  
        id_strm = XTbl.value('(*:id_strm)[1]', 'varchar(4)')  
    from   
        @par_xml.nodes('/*:params/*:strm_row') AS XD(XTbl)  
),  
_nacini_l_par as (  
    select  
        nacin_leas = XTbl.value('(*:nacin_leas)[1]', 'char(2)')  
    from   
        @par_xml.nodes('/*:params/*:nacini_l_row') AS XD(XTbl)  
)  
SELECT   
    po.id_pog,   
    po.id_kupca,   
    pa.naz_kr_kup,   
    po.dat_aktiv,   
    pp.datum_dok,   
    pp.dat_zap,   
    po.net_nal,  
    po.id_val,   
    po.obr_mera,  
    po.nacin_leas,  
    po.status_akt,  
    po.id_cont,  
    po.id_tec,  
    datediff(day, po.dat_aktiv, case   
                                    when po.beg_end = 1 or dbo.gfn_GetCustomSettingsAsBool('IntercalaryInt_EndModeAsBeginMode') = 1 then pp.datum_dok   
                                    else dbo.gfn_MonthAddLastDay(-(12/o.obnaleto), pp.datum_dok) end  
        ) AS st_dni,  
    po.aneks,   
    po.beg_end,   
    o.obnaleto,  
    vop.naziv as vrsta_osebe_partner,  
    po.id_dob,  
    dob.naz_kr_kup as naziv_kr_dob  
FROM   
    dbo.pogodba po   
    INNER JOIN dbo.gfn_Partner_Pseudo('grp_Int_intr_candidates', @id_kupca) pa ON po.id_kupca = pa.id_kupca   
    inner join dbo.obdobja o ON po.id_obd = o.id_obd  
    LEFT JOIN dbo.planp pp ON po.id_cont = pp.id_cont AND pp.id_terj = dbo.gfn_GetIdForSifTerj('LOBR') AND pp.zap_obr = (1 + @zap_obr)  
    INNER JOIN dbo.VRST_OSE vop ON pa.vr_osebe = vop.VR_OSEBE  
    INNER JOIN dbo.gfn_Partner_Pseudo('grp_Int_intr_candidates', null) dob ON po.id_dob = dob.id_kupca   
    left join _strm_par s on po.id_strm = s.id_strm  
    outer apply (select COUNT(*) cnt from _strm_par) sc  
    left join _nacini_l_par n on po.nacin_leas = n.nacin_leas  
    outer apply (select COUNT(*) cnt from _nacini_l_par) nc  
    outer apply (select * from _par) params  
WHERE   
    NOT EXISTS(SELECT * FROM dbo.gen_interkalarne_obr g WHERE g.id_cont = po.id_cont)  
    and (sc.cnt = 0 or s.id_strm is not null)  
    and (nc.cnt = 0 or n.nacin_leas is not null)  
    and (params.id_pog is null or po.id_pog = params.id_pog)  
    and ((params.akt_od is null and params.akt_do is null) or po.dat_aktiv BETWEEN params.akt_od AND params.akt_do)  
    and (@id_kupca is null or po.id_kupca = @id_kupca)  
)  
  