------------------------------------------------------------------------------------------------------------  
-- Function for getting InternationalBlackList and partner data   
--   
--  
-- History:  
-- 25.01.2012 IgorS; Bug ID 29219 - created  
-- 06.01.2015 IgorS; MR ID 45686 - added replace of 'dž' to 'dz'  
-- 14.01.2015 IgorS; MR ID 45686 - removed replace of 'dž' to 'dz'  
-- 21.01.2022 MatjazB, Domen; BID 39372 - check empty and rewrite  
------------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_CheckInternationalBlackListSummary](@id_kupca char(6))  
RETURNS table   
AS    
RETURN(  
    select   
        p.naziv1_kup, p.id_kupca,   
        cast(case when aml.cnt > 0 then 1 else 0 end as bit) ZPPDFT_confirmation  
    from   
        dbo.partner p  
        inner join dbo.vrst_ose o on p.vr_osebe = o.vr_osebe   
        outer apply (  
            select COUNT(*) cnt  
            from dbo.aml_un_list l  
            where  
                /* preverjanje za fizično osebo */  
                    (o.sifra = 'FO'  
                    and (p.ime <> ''  
                        and l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + p.ime + '%') COLLATE Latin1_General_CI_AI)  
                    and (p.priimek <> ''  
                        and l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + p.priimek + '%') COLLATE Latin1_General_CI_AI)  
                    )  
                OR   
                /* preverjanje za ostale osebe */  
                    (o.sifra != 'FO'  
                    and (p.naziv1_kup <> ''  
                        and l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + p.naziv1_kup + '%') COLLATE Latin1_General_CI_AI)  
                    )  
                or   
                    (p.ulica <> ''  
                    and l.[address] COLLATE Latin1_General_CI_AI LIKE ('%' + p.ulica + '%') COLLATE Latin1_General_CI_AI)  
        ) aml  
    where p.id_kupca = @id_kupca  
)  