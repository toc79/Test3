--SELECT * FROM dbo.aml_un_list

select * from dbo.VRST_OSE

select * from dbo.CUSTOM_SETTINGS where code = 'Nova.LE.Partner.Check.Lists'
--MOHAMMAD BAQER
--select dbo.gfn_CheckInternationalBlackList('001519')
select * from dbo.gfn_CheckInternationalBlackListSummary('000197')
declare @id_kupca char(6) = '000197'
--declare @naziv1_kup varchar(100) 
----, @id_kupca char(6)
--,   @ZPPDFT_confirmation bit  
--)  
--AS  
--BEGIN  
 DECLARE @name varchar(100), @address varchar(300), @sifra char(2), @ime varchar(100), @priimek varchar(100), @count int  
    
 SELECT @name = ltrim(rtrim(p.naziv1_kup)),   
        @address = ltrim(rtrim(p.ulica)),  
        @ime = ltrim(rtrim(p.ime)),   
        @priimek = ltrim(rtrim(p.priimek)),  
        @sifra = o.sifra  
  FROM dbo.partner p  
  INNER JOIN dbo.vrst_ose o ON p.vr_osebe = o.vr_osebe  
  WHERE id_kupca = @id_kupca  
 select @sifra   
 IF @sifra = 'FO'  
  BEGIN   
   SET @count = (SELECT COUNT(*) FROM dbo.aml_un_list   
                  WHERE (REPLACE(REPLACE(REPLACE(REPLACE(name,'è','c'),'æ','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@ime, 'è', 'c'), 'æ', 'c'), 'ž', 'z'), 'š', 's') + '%')   
                    AND (REPLACE(REPLACE(REPLACE(REPLACE(name,'è','c'),'æ','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@priimek, 'è', 'c'), 'æ', 'c'), 'ž', 'z'), 'š', 's') + '%')   
                     OR (REPLACE(REPLACE(REPLACE(REPLACE([address],'è','c'),'æ','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@address, 'è', 'c'), 'æ', 'c'), 'ž', 'z'), 'š', 's') + '%'))  
  END  
 ELSE   
  BEGIN  
   SET @count = (SELECT COUNT(*) FROM dbo.aml_un_list   
                           WHERE (REPLACE(REPLACE(REPLACE(REPLACE(name,'è','c'),'æ','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@name, 'è', 'c'), 'æ', 'c'), 'ž', 'z'), 'š', 's') + '%')  
                              OR (REPLACE(REPLACE(REPLACE(REPLACE([address],'è','c'),'æ','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@address, 'è', 'c'), 'æ', 'c'), 'ž', 'z'), 'š', 's') + '%'))  
        END   
    
 --INSERT @BlackList  
 SELECT @name, @id_kupca, CASE WHEN @count > 0 THEN 1 ELSE 0 END  

 select   
        p.naziv1_kup, p.id_kupca,   
        cast(case when aml.cnt > 0 then 1 else 0 end as bit) ZPPDFT_confirmation  
        , o.sifra
    from   
        dbo.partner p  
        inner join dbo.vrst_ose o on p.vr_osebe = o.vr_osebe   
        outer apply (  
            select COUNT(*) cnt  
            from dbo.aml_un_list l  
            where  
                /* preverjanje za fizièno osebo */  
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

-- SA ALL TRIM
 select   
        p.naziv1_kup, p.id_kupca,   
        cast(case when aml.cnt > 0 then 1 else 0 end as bit) ZPPDFT_confirmation  
        , o.sifra
    from   
        dbo.partner p  
        inner join dbo.vrst_ose o on p.vr_osebe = o.vr_osebe   
        outer apply (  
            select COUNT(*) cnt  
            from dbo.aml_un_list l  
            where  
                /* preverjanje za fizièno osebo */  
                    (o.sifra = 'FO'  
                    and (p.ime <> ''  
                        and l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.ime)) + '%') COLLATE Latin1_General_CI_AI)  
                    and (p.priimek <> ''  
                        and l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.priimek)) + '%') COLLATE Latin1_General_CI_AI)  
                    )  
                OR   
                /* preverjanje za ostale osebe */  
                    (o.sifra != 'FO'  
                    and (p.naziv1_kup <> ''  
                        and l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.naziv1_kup)) + '%') COLLATE Latin1_General_CI_AI)  
                    )  
                or   
                    (p.ulica <> ''  
                    and l.[address] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.ulica)) + '%') COLLATE Latin1_General_CI_AI)  
        ) aml  
    where p.id_kupca = @id_kupca  