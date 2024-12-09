-----------------------------------------------------------------  
-- Function returns element value for given element name from given XML  
-- Returns element value if found; otherwise returns null  
-- History:  
-- 31.08.2006 Matjaz; created  
-----------------------------------------------------------------  
CREATE FUNCTION dbo.gfn_GetElementValueFromXMLDesc(@xml varchar(8000), @element varchar(100))  
RETURNS varchar(500)  
AS  
BEGIN  
 declare @beg int, @end int, @result varchar(500)  
 set @xml = ltrim(rtrim(@xml))  
 set @beg = charindex('<'+@element+'>', @xml) + len('<'+@element+'>')  
 set @end = charindex('</'+@element+'>', @xml)  
 if @end > @beg set @result = substring(@xml, @beg, @end - @beg)  
 else set @result = null  
 return @result  
END  