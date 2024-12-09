--INSERT INTO dbo.USERS_CUSTOM_FUNCS(func_id,username,type,keyid) VALUES(306,'g_tomislav','DocTypes','AK')
--id	name	func_desc	parent
--365	general_register	All activities related to general_register	144
--928	general_registerDelete	All activites related to deleting general register	365
--366	general_registerInsert	All activities related to entering new record into general_register	365
--1091	general_registerMask	All activities related to editing Length and InputMask for ID_REGISTER	365
--367	general_registerUpdate	All activities related to updating existing record in general_register	365
--927	general_registerView	All activites related to viewing general register	365

select * from general_register where ID_REGISTER = 'ID_REGISTER'

select * from functionalities where name like '%general_register%'
select * from users_custom_funcs where type = 'GeneralRegister'

begin tran
INSERT INTO dbo.USERS_CUSTOM_FUNCS(func_id,username,type,keyid) 
SELECT b.id, 'useradmini ', 'GeneralRegister', a.id_key
--select * 
from general_register a, functionalities b 
where a.ID_REGISTER = 'ID_REGISTER'
AND b.id in (928, 366, 367)
AND a.id_key not in (select distinct keyid from dbo.users_custom_funcs where type = 'GeneralRegister')
order by a.id_key, b.name

--commit