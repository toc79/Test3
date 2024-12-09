--GDPR
SELECT cs.id as id
INTO #tempVrste
FROM {1}.dbo.gfn_split_ids( (Select [val] FROM {1}.dbo.CUSTOM_SETTINGS WHERE code='Nova.GDPR.ListOfCustomerTypesForAccessLog'), ',') cs

declare @xml as xml
set @xml = 
(
    SELECT * 
    FROM 
    (
        SELECT
            t.id_kupca as '@ID_KUPCA',
            p.vr_osebe as '@vrsta_osebe',
			'' as  '@Additional_desc'
        FROM  #finalBPM t        
        INNER JOIN {1}.dbo.partner p on p.id_kupca=t.id_kupca
        WHERE p.vr_osebe in (SELECT id FROM #tempVrste)    
        GROUP BY t.ID_KUPCA, p.vr_osebe         
    ) as s
    FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();

exec {1}.dbo.gsp_GDPR_LogCustomerDataAccessInternal @time,{@username},null,'Naziv, OIB, JMBG, Adresa, Broj i datum valjanosti osobnog dokumenta','INTERNAL','CUSTOM_REPORT', 'Istek valjanosti osobnog dokumenta BPM ZSPNFT','46897',@xml
drop table #tempVrste
-- KRAJ GDPR    


--FINAL NOVA AND BPM
select * from #finalBPM order by id_kupca, assignee_desc


select * from gdpr_access_log order by Id_access_log desc
--select * from gdpr_access_log_details
select * from gdpr_access_log_details where id_access_log=580916