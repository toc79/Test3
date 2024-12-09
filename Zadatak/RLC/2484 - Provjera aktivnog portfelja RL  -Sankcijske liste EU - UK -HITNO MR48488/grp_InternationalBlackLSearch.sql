------------------------------------------------------------------------------------------------------------  
-- Procedure for getting duplicate vins  
--   
--  
-- History:  
-- 11.04.2011 JozeM; Task ID 5914 - created  
-- 07.06.2011 JozeM; BID 28884 - čšćž  
-- 16.12.2011 IgorS; Task ID 6508 - modified and to or, added alias column  
-- 06.01.2015 IgorS; MR ID 45686 - added replace of 'dž' to 'dz'  
-- 15.01.2015 IgorS; MR ID 45686 - removed replace of 'dž' to 'dz'  
-- 28.11.2018 KlemenV; BID 36126 - added gfn_StringToFOX  
------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[grp_InternationalBlackLSearch]  
 @name_enabled bit,  
 @name varchar(200),  
 @address_enabled bit,  
 @address varchar(200)  
AS  
BEGIN  
  
DECLARE @sql varchar(8000)  
SET @sql = 'SELECT a.id, dbo.gfn_StringToFOX(a.name) AS name, dbo.gfn_StringToFOX(a.address) AS address, a.list_id, dbo.gfn_StringToFOX(a.description) AS description, dbo.gfn_StringToFOX(a.alias) AS alias FROM dbo.aml_un_list a'  
  
/*********************************************/  
  
IF (@name_enabled = 1)  
BEGIN  
  
    DECLARE @names TABLE (id varchar(100))  
    INSERT INTO @names  
        SELECT id FROM dbo.gfn_split_ids(@name, ' ')  
  
    DECLARE c CURSOR FAST_FORWARD FOR  
        SELECT id FROM @names  
  
    DECLARE @name_a varchar(100)  
    OPEN c  
  
    FETCH NEXT FROM c INTO @name_a  
    IF (@@FETCH_STATUS = 0 AND LEN(LTRIM(RTRIM(@name_a))) > 0)   
        SET @sql = @sql + ' WHERE ('  
  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
     IF (LEN(LTRIM(RTRIM(@name_a))) > 0)  
            SET @sql = @sql + ' REPLACE(REPLACE(REPLACE(REPLACE(a.name,''č'',''c''),''ć'',''c''),''ž'',''z''),''š'',''s'') LIKE ''%' + REPLACE(REPLACE(REPLACE(REPLACE(@name_a,'č','c'),'ć','c'),'ž','z'),'š','s') + '%'' AND '  
       
     FETCH NEXT FROM c INTO @name_a  
    END  
  
    CLOSE c  
    DEALLOCATE c  
  
    SET @sql = SUBSTRING(@sql, 0, LEN(@sql) - 3)  
    SET @sql = @sql + ')'  
END  
  
/*******************************************************/  
  
IF (@address_enabled = 1)  
BEGIN  
  
    DECLARE @adresses TABLE (id varchar(100))  
    INSERT INTO @adresses  
        SELECT id FROM dbo.gfn_split_ids(@address, ' ')  
  
    DECLARE a CURSOR FAST_FORWARD FOR  
    SELECT id FROM @adresses  
  
    DECLARE @address_a varchar(200)  
    OPEN a  
  
    FETCH NEXT FROM a INTO @address_a  
    IF (@@FETCH_STATUS = 0 AND CHARINDEX('WHERE', @sql) <> 0 AND LEN(LTRIM(RTRIM(@address_a))) > 0)  
     SET @sql = @sql + ' OR ('   
  
    IF (@@FETCH_STATUS = 0 AND CHARINDEX('WHERE', @sql) = 0 AND LEN(LTRIM(RTRIM(@address_a))) > 0)  
     SET @sql = @sql + ' WHERE ('  
  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
     IF (LEN(LTRIM(RTRIM(@address_a))) > 0)  
      SET @sql = @sql + ' REPLACE(REPLACE(REPLACE(REPLACE(a.address,''č'',''c''),''ć'',''c''),''ž'',''z''),''š'',''s'') LIKE ''%' + REPLACE(REPLACE(REPLACE(REPLACE(@address_a,'č','c'),'ć','c'),'ž','z'),'š','s') + '%'' AND '  
  
        FETCH NEXT FROM a INTO @address_a  
    END  
  
    CLOSE a  
    DEALLOCATE a  
    SET @sql = SUBSTRING(@sql, 0, LEN(@sql) - 3)  
    SET @sql = @sql + ')'  
END  
  
PRINT @sql  
EXEC(@sql)  
  
END  
  