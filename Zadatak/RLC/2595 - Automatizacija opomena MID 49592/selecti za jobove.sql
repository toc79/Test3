--05.09.2024 g_tomislav MID 49592 
TODO iskljuèiti pripremu opomena  ID 6
declare @broj_opomena int = (SELECT count(*) as broj_opomena FROM dbo.za_opom where st_opomina in (1,2,3) and isnull(dok_opom, '') = '')  --and oznacen = 0

if @broj_opomena > 0 
begin
Select  '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' 
		+ replace(replace(replace(
				(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
				FROM dbo.za_opom    
				where st_opomina in (1,2,3)    
				--and oznacen = 0
				and isnull(dok_opom, '') = ''
				order by st_opomina, id_opom
				FOR XML PATH(''))
			,'&lt;','<'),'&gt;','>'),'lt;','') 
		+ '</issue_reminders>'
end




--OLD


DECLARE @target_date datetime, @id_za_opom varchar(1000), @id_job_remiders_generate int

SELECT @target_date = dbo.gfn_GetDatePart(getdate())

SET @id_za_opom = (SELECT id_za_opom_type FROM dbo.za_opom_type FOR XML PATH('reminder_types'))
set @id_job_remiders_generate = 45

SELECT 
'<reminders_generate xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:leasing">
<dat_prip>' + CONVERT(varchar(100), @target_date, 126) + '</dat_prip>
	' + @id_za_opom + '
</reminders_generate>'
WHERE @target_date <> dbo.gfn_FirstWorkDay(dbo.gfn_GetFirstDayOfMonth(@target_date))

union all
--dodati pokretanje joba za izdavanjem opomena
--Da li æe to završiti u beskonaènoj petlji?
select '<?xml version="1.0" encoding="utf-16"?> <job_manager_start_request xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:admin_console">   <single_job_id>' +convert(varchar(30), @id_job_remiders_generate) +'</single_job_id> </job_manager_start_request>'


--Opomene - 2. izdavanje issue_reminders
--DORAÐENI 
declare @broj_opomena int = (SELECT count(*) as broj_opomena FROM dbo.za_opom where st_opomina in (1,2,3) and isnull(dok_opom, '') = '')  --and oznacen = 0

if @broj_opomena > 0 
begin
Select  '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' 
		+ '<' + replace(replace(replace(STUFF(  
				(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
				FROM dbo.za_opom    
				where st_opomina in (1,2,3)    
				--and oznacen = 0
				and isnull(dok_opom, '') = ''
				order by st_opomina, id_opom
				FOR XML PATH(''))
			, 1, 1, ''),'&lt;','<'),'&gt;','>'),'lt;','') 
		+ '</issue_reminders>'
end	
go

--
-- BEZ STUFF PRIMJER
declare @broj_opomena int = (SELECT count(*) as broj_opomena FROM dbo.za_opom where st_opomina in (1,2,3) and isnull(dok_opom, '') = '')  --and oznacen = 0

if @broj_opomena > 0 
begin
Select  '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' 
		+ replace(replace(replace(
				(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
				FROM dbo.za_opom    
				where st_opomina in (1,2,3)    
				--and oznacen = 0
				and isnull(dok_opom, '') = ''
				order by st_opomina, id_opom
				FOR XML PATH(''))
			,'&lt;','<'),'&gt;','>'),'lt;','') 
		+ '</issue_reminders>'
end	