--use nova_rlc

--select * from dbo.CUSTOM_SETTINGS where code like '%mail%'

--select * from dbo.general_register where ID_REGISTER = 'ID_REGISTER'

--INSERT INTO dbo.ext_func(ID_EXT_FUNC,CODE,id_ext_func_type,inactive,onform) VALUES('Sys.EventHandler.ProcessXml.Contract.Activated','','SQL_CS',0,NULL)

--insert into dbo.GENERAL_REGISTER values ('ID_REGISTER', 'RLC_AKTIVACIJA', 'Lista korisnika za slanje maila nakon aktivacije ugovora', NULL, NULL, NULL, 0, NULL) 
--INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_AKTIVACIJA','bcc','BCC email adrese',0,NULL,'',1,NULL)
--INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_AKTIVACIJA','cc','CC email adrese',0,NULL,'',0,NULL)
--INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_AKTIVACIJA','to','TO email adrese TEST',0,NULL,'diana.burazer-delalic@rl-hr.hr',0,NULL)

--INSERT INTO dbo.ext_func(ID_EXT_FUNC,CODE,id_ext_func_type,inactive,onform) VALUES('Sys.EventHandler.ProcessXml.Contract.Activated','','SQL_CS',0,NULL)

--select top 1 * 	from dbo.arh_gl_input_r order by 1 desc

--MOlimo da ne unosite prazne redove u polje "Znakovna vrijednost"

--Obavezno moraju biti popunjene email adrese

--Parameters {X}:
-- 0 - {0} 
-- 1 - {1} 
-- 2 - {2}
-- 3 - {3}
-- 4 - {4}
-- imamo Event Contract.Activated raised with event data: [Key: [id_cont], Value: [2246]; ]
-- Parameters {X}:    -- 0 - 'g_tomislav'   -- 1 - 'contract.activated'   -- 2 - 'id_cont'  -- 3 - '2246'

--27.09.2021 g_tomislav MID 47343 - created;

declare @id_cont int = {3}

declare @from varchar(1000) = (select dbo.gfn_GetCustomSettings('NOVA_SYS_EMAIL_FROM')) --ili NOVA_SYS_EMAIL_ADMIN          
declare @to varchar(4000) = (select ltrim(rtrim(val_char)) from dbo.general_register where id_register = 'RLC_AKTIVACIJA' and id_key = 'to')
declare @cc varchar(4000) = (select ltrim(rtrim(val_char)) from dbo.general_register where id_register = 'RLC_AKTIVACIJA' and id_key = 'cc' and neaktiven = 0)
declare @bcc varchar(4000) = (select ltrim(rtrim(val_char)) from dbo.general_register where id_register = 'RLC_AKTIVACIJA' and id_key = 'bcc' and neaktiven = 0)

select '<insert_mail xmlns="urn:gmi:nova:core">' 
			+'<from>' +@from +'</from>'
			+'<to>' +@to +'</to>'
			+'<cc>' +case when @cc is null or @cc = '' then '' else +@cc end +'</cc>'
			+case when @bcc is null or @bcc = '' then '' else '<bcc>' +@bcc +'</bcc>' end 
			+'<subject>Aktiviran ugovor ' +ltrim(rtrim(pog.id_pog)) +', tip '+pog.nacin_leas +', sa datumom ' +dbo.gfn_ConvertDate(isnull(pog.dat_aktiv, ''), 9) +', URA ' +case when agir.DDV_ID is null or agir.DDV_ID = '' then '(nema)' else ltrim(rtrim(agir.ddv_id)) end +'</subject>'
			+'<body>Aktiviran ugovor ' +ltrim(rtrim(pog.id_pog)) +', tip '+pog.NACIN_LEAS +', sa datumom ' +dbo.gfn_ConvertDate(isnull(pog.dat_aktiv, ''), 9) +', URA ' +case when agir.DDV_ID is null or agir.DDV_ID = '' then '(nema)' else ltrim(rtrim(agir.ddv_id)) end +'</body>'
			+'<body_is_html>true</body_is_html>'
			+'<send_immediately>true</send_immediately>'
		+'</insert_mail>' as xml
	, cast(0 as bit) as via_queue
	, 300 as delay
	, cast(0 as bit) as via_esb
	, 'nova.le' as esb_target
from dbo.pogodba pog 
outer apply (select top 1 id_cont, ddv_id 
			from dbo.arh_gl_input_r
			where id_gl_tipi_rac in (26, 27, 28, 29, 31, 35, 36)
			and id_cont = pog.id_cont) agir
where pog.id_cont = @id_cont
and pog.status_akt = 'A'


INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('ID_REGISTER','RLC_AKTIVACIJA','Lista korisnika za slanje maila nakon aktivacije ugovora',NULL,NULL,NULL,0,NULL)

INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_AKTIVACIJA','bcc','BCC email adrese',0,NULL,'',1,NULL)
INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_AKTIVACIJA','cc','CC email adrese',0,NULL,'tatjana.berdik@rl-hr.hr;nelly.brkic@rl-hr.hr;ljiljana.susnjar@rl-hr.hr;zrinka.kantoci@rl-hr.hr;iva.cvitanic@rl-hr.hr',0,NULL)
INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_AKTIVACIJA','to','TO email adrese TEST',0,NULL,'diana.burazer-delalic@rl-hr.hr',0,NULL)








