----------------------------------------------------------------------------------
-- This script sets up default users in leasing database.
-- Before you run this script, select appropriate database (the script assumes
-- that the current database schema is the target one).
--
-- History: 
-- 04.11.2003 Vik; created
-- 06.11.2003 Vik; added code for granting permissions to full-access user
-- 10.11.2003 Vik; added code for denying access to certain tables to user nova_userr
-- 12.11.2003 Vik; removed code for denying access to tables
-- 08.03.2004 Vik; default users are now nova_user and nova_user_r
-- 27.07.2004 Vik; added code for denying access (update, delete) to user_nova for specific tables
-- 25.08.2004 Vik; akonplan - update and delete are possible
-- 17.08.2004 Vik; added grp_* stored procedure permissions to nova_user_r
-- 26.10.2004 Vik; removed table app_nast_pog from restricted table group (nova_user can delete and update)
-- 08.12.2004 Vik; removed table kljucost from restricted table group (nova_user can delete and update)
-- 10.01.2005 Vik; added update permission to nova_user for debugging fields in loc_nast
-- 02.09.2005 Vik; added gcu_* stored procedure permissions to nova_user_r
-- 08.09.2005 Vik; fixed statement that sets permissions for grp_* and gcu_*
-- 12.01.2006 Vik; user nova_r can change settings tables
-- 09.06.2006 Vik; user nova_r can change tables kalk_form and kalk_def
-- 10.07.2006 Vik; changed default passwords for system users
-- 13.10.2006 Ziga; lsk, lgk, autols1, akonplan_ex_le - updates are possible from now on (needed for account change)
-- 24.07.2008 Vilko; removed deny permission on update for table app_channels
-- 07.09.2009 IgorS; added a new user with name nova_user_archive that is in db_datareader,  db_datawriter and db_ddladmin database role
-- 03.02.2010 Ziga; Bug ID 28162 - fixed user language to us_english
-- 27.03.2012 PetraR; Bug id 29348 - removed deny permission on update for table arh_za_opom
-- 23.01.2013 MatjazS; Task ID 7210 - modified script so that it does not report errors on alternate database schemas (rea, archive, ...)
-- 01.06.2015 Ziga; modified parameter length @name from 50 to 100
-- 20.10.2015 IgorS; modified permissions for tables on REA & COMMMON databases(used check for dbo.db_settings table that exists only in REA & COMMMON databases - delete snapshot problem due to deny 	rights for delete on tables dbo.nastavit, dbo.loc_nast in REA)
-- 19.01.2016 IgorS; modified script due to higher security context on SQL server level
----------------------------------------------------------------------------------

-- First check if users exist in server list



-- NOVA_USER_R
if not exists (select * from master.dbo.syslogins where loginname = N'nova_user_r')
BEGIN
	print 'Creating user nova_user_r in system user list'
	declare @logindb nvarchar(132) select @logindb = N'leasing'
	if @logindb is null or not exists (select * from master.dbo.sysdatabases where name = @logindb)
		select @logindb = N'master'
	exec sp_addlogin N'nova_user_r', N'N0V@uz3rR', @logindb, N'us_english'
	print 'Done.'
END
ELSE
	if ((select language from master.dbo.syslogins where loginname = N'nova_user_r') <> N'us_english')
	BEGIN
		EXEC sp_defaultlanguage N'nova_user_r', N'us_english'
	END
GO



print 'Adding user nova_user_r to database'
if exists (select * from dbo.sysusers where name = N'nova_user_r')
	EXEC sp_revokedbaccess N'nova_user_r'
GO
EXEC sp_grantdbaccess N'nova_user_r', N'nova_user_r'
GO
print 'Done.'




exec sp_addrolemember N'db_datareader', N'nova_user_r'
GO


-------------------------------------------------------------------
-- Add access rights to read-only user for user-defined functions of scalar type
-- and to certain stored procedures 
print 'Adding execute permissions for scalar functions to user nova_user_r.....'
DECLARE tmp_cur CURSOR FOR
	select [name] from sysobjects where xtype='FN' or (xtype='P' and (left(name, 4) in ('grp_', 'gcu_')))
	
declare @name varchar(100), @cmd varchar(8000)
open tmp_cur
FETCH NEXT FROM tmp_cur INTO @name
WHILE @@fetch_status=0
BEGIN
	set @cmd = 'GRANT  EXECUTE  ON [dbo].[' + @name + ']  TO [nova_user_r]'
	exec(@cmd)
	FETCH NEXT FROM tmp_cur INTO @name
END
close tmp_cur
deallocate tmp_cur
print 'Done.'
GO







print 'End of script.'