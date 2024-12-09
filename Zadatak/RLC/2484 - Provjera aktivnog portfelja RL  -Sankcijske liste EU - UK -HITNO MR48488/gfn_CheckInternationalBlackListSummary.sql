------------------------------------------------------------------------------------------------------------  
-- Function for getting InternationalBlackList data  
--   
--  
-- History:  
-- 15.12.2011 IgorS; Task ID 6508 - created  
-- 05.01.2012 IgorS; Task ID 6508 - modified  
-- 17.01.2012 IgorS; Task ID 6508 - added replace statement to variables  
-- 25.01.2012 IgorS; Bug ID 29219 - modified function  
------------------------------------------------------------------------------------------------------------  
CREATE FUNCTION [dbo].[gfn_CheckInternationalBlackList](@id_kupca char(6))  
RETURNS bit  
AS    
BEGIN  
 DECLARE @res bit      
 SET @res = (SELECT ZPPDFT_confirmation FROM [dbo].[gfn_CheckInternationalBlackListSummary](@id_kupca))  
    RETURN @res  
END  

------------------------------------------------------------------------------------------------------------  
-- Function for getting InternationalBlackList and partner data   
--   
--  
-- History:  
-- 25.01.2012 IgorS; Bug ID 29219 - created  
-- 06.01.2015 IgorS; MR ID 45686 - added replace of 'dž' to 'dz'  
-- 14.01.2015 IgorS; MR ID 45686 - removed replace of 'dž' to 'dz'  
------------------------------------------------------------------------------------------------------------  
CREATE FUNCTION [dbo].[gfn_CheckInternationalBlackListSummary](@id_kupca char(6))  
RETURNS @BlackList TABLE  
(  
 naziv1_kup varchar(100),  
 id_kupca char(6),  
 ZPPDFT_confirmation bit  
)  
AS  
BEGIN  
 DECLARE @name varchar(100), @address varchar(300), @sifra char(2), @ime varchar(100), @priimek varchar(100), @count int  
    
 SELECT @name = ltrim(rtrim(p.naziv1_kup)),   
        @address = ltrim(rtrim(p.ulica)),  
        @ime = ltrim(rtrim(p.ime)),   
        @priimek = ltrim(rtrim(p.priimek)),  
        @sifra = o.sifra  
  FROM dbo.partner p  
  INNER JOIN dbo.vrst_ose o ON p.vr_osebe = o.vr_osebe  
  WHERE id_kupca = @id_kupca  
    
 IF @sifra = 'FO'  
  BEGIN   
   SET @count = (SELECT COUNT(*) FROM dbo.aml_un_list   
                  WHERE (REPLACE(REPLACE(REPLACE(REPLACE(name,'č','c'),'ć','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@ime, 'č', 'c'), 'ć', 'c'), 'ž', 'z'), 'š', 's') + '%')   
                    AND (REPLACE(REPLACE(REPLACE(REPLACE(name,'č','c'),'ć','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@priimek, 'č', 'c'), 'ć', 'c'), 'ž', 'z'), 'š', 's') + '%')   
                     OR (REPLACE(REPLACE(REPLACE(REPLACE([address],'č','c'),'ć','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@address, 'č', 'c'), 'ć', 'c'), 'ž', 'z'), 'š', 's') + '%'))  
  END  
 ELSE   
  BEGIN  
   SET @count = (SELECT COUNT(*) FROM dbo.aml_un_list   
                           WHERE (REPLACE(REPLACE(REPLACE(REPLACE(name,'č','c'),'ć','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@name, 'č', 'c'), 'ć', 'c'), 'ž', 'z'), 'š', 's') + '%')  
                              OR (REPLACE(REPLACE(REPLACE(REPLACE([address],'č','c'),'ć','c'),'ž','z'),'š','s') LIKE + '%' + REPLACE(REPLACE(REPLACE(REPLACE(@address, 'č', 'c'), 'ć', 'c'), 'ž', 'z'), 'š', 's') + '%'))  
        END   
    
 INSERT @BlackList  
 SELECT @name, @id_kupca, CASE WHEN @count > 0 THEN 1 ELSE 0 END  
 RETURN   
END  