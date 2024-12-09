DECLARE @date datetime = dbo.gfn_GetDatePart(getdate())

SELECT '<prepare xmlns="urn:gmi:nova:xdoc">' --'<!-- XDoc id to be executed -->' +CHAR(13)+
+ ' <xdoc_template_id>'+CAST(id_xdoc_template AS varchar(4))+'</xdoc_template_id>' 
+ ' <perform_commit_automatically>true</perform_commit_automatically>' --'<!-- This flag forces auto-commit of prepared candidates  -->' +CHAR(13)+
+ '</prepare>'
FROM dbo.xdoc_template WHERE id_xdoc_template IN (39, 40, 41) 
AND (@date = dbo.gfn_FirstWorkDay(DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, @date), DATEDIFF(dd, 0, @date)))) -- first work day of a week
	OR 
	@date = dbo.gfn_GetLastDayOfMonth(@date) ) -- OR last day of month



--select @@DATEFIRST
--select dbo.gfn_GetWorkDay(0,'20200101'), dbo.gfn_FirstWorkDay('20200106')
DECLARE @date datetime = '20191222'
DECLARE @date2 datetime = '20200115'
WHILE @date <= @date2
BEGIN
--SELECT dbo.gfn_FirstWorkDay(@date), dbo.gfn_FirstWorkDay(DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, @date), DATEDIFF(dd, 0, @date))) )
SELECT DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, @date), DATEDIFF(dd, 0, @date))) [first day current week]
, dbo.gfn_FirstWorkDay(DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, @date), DATEDIFF(dd, 0, @date))) )
, @date AS Na_dan
, CASE WHEN @date = dbo.gfn_FirstWorkDay(DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, @date), DATEDIFF(dd, 0, @date))) ) 
 THEN 'DA' ELSE 'NE' END AS pokreni
 SET @date = DATEADD(dd, 1, @date)
 print dbo.gfn_ConvertDate(@date, 9)
END


--SELECT DATEADD(wk, -1, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) +1 [first day previous week]
--SELECT DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) +1 [first day current week]
--SELECT DATEADD(wk, 1, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) +1 [first day next week]

--SELECT DATEADD(wk, 0, DATEADD(DAY, 0-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE())))+1 [last day previous week]
--SELECT DATEADD(wk, 1, DATEADD(DAY, 0-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE())))+1 [last day current week]
--SELECT DATEADD(wk, 2, DATEADD(DAY, 0-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE())))+1 [last day next week]

--------------------------------------------------------------------------  
-- This function add month and handle last day of month  
--  
-- History:  
-- 09.10.2014 MatjazB; created  
--------------------------------------------------------------------------  
CREATE function [dbo].[gfn_MonthAddLastDay](@AddMonth int, @Date datetime)  
returns datetime as  
begin  
    declare @IsLastDay bit, @AddedDate datetime, @Return datetime  
    set @IsLastDay = case when dbo.gfn_GetLastDayOfMonth(@Date) = @Date then 1 else 0 end  
    set @AddedDate = dateadd(mm, @AddMonth, @Date)  
  
    if @IsLastDay = 1  
        set @Return = dbo.gfn_GetLastDayOfMonth(@AddedDate)  
    else  
        set @Return = @AddedDate  
  
    return @Return  
end  

--------------------------------------------------------------------------  
-- This function returns last day of month date for given date  
--  
-- History:  
-- 25.09.2008 Ziga; created  
--------------------------------------------------------------------------  
  
CREATE   function dbo.gfn_GetLastDayOfMonth(@InputDate datetime)  
returns datetime as  
begin  
    declare @FirstDay datetime  
  
    set @FirstDay = dateadd(dd, -datepart(dd, @InputDate) + 1, @InputDate )  
    return DATEADD(DD, -1, DATEADD(M, 1, @FirstDay))  
  
  
end  