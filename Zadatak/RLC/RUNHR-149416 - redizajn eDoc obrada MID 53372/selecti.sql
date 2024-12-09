select * from dbo.EDOC_DOCTYPE
select * from dbo.custom_settings where val like '%first%'
select * from dbo.reports_edoc_settings
Select CAST(~inactive as bit), inactive , * From dbo.users Where username = 'sys_eom'