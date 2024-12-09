--begin tran
--update dbo.custom_settings set val = 'rlenova-test@rl-hr.hr' where code = 'NOVA_SYS_EMAIL_FROM'
--select * from dbo.custom_settings where charindex('rlenova', val) != 0
--commit

select * from dbo.app_channels
select * from dbo.io_channels
select * from dbo.custom_settings where charindex('b2rl', val) != 0
select * from dbo.custom_settings where charindex('esb', val) != 0
select * from dbo.custom_settings where charindex('rlenova', val) != 0

select db_Version from dbo.loc_nast

select * from dbo.jm_job

select ident_stevilka, * from dbo.partner where ident_stevilka is not null and ident_stevilka != ''
