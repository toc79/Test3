--use mary
select * from odobrit where id_wf_document=3705 --VEZA: id_wf_document
select * from wf_history where id_document=3705

--UPDATE custom_settings set val='mail.gemicro.hr' where code='nova_sys_mail_smtp_server' --192.168.23.1
select * from custom_settings where code like '%nova_sys_%'
select * from custom_settings where code like '%mail%'
INSERT INTO custom_settings values ('NOVA_SYS_MAIL_SERVER_DOMAIN','gemicro.hr','')
INSERT INTO custom_settings values ('NOVA_SYS_MAIL_SERVER_PWD','jKl34%6','')
INSERT INTO custom_settings values ('NOVA_SYS_MAIL_SERVER_UN','gemicro\gmc-batch','')
SELECT * FROM [dbo].[MAIL]
user: gemicro\gmc-batch
password: jKl34%6
select * from dbo.xdoc_run_history Where id_xdoc_template = 15
<?xml version="1.0" encoding="utf-16"?>
<prepare xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="urn:gmi:nova:xdoc">
  <xdoc_template_id>15</xdoc_template_id>
</prepare>
SELECT * FROM dbo.xdoc_document_tmp

/*EXEC  grp_partner_eval_View 0,'',0,'','',1,0,'','',0,'',0,'',0,'',0,'',0,'',0,'',0,'',0,'',0,0,0 
sp_helptext grp_partner_eval_View 

parametar: ID_HISTORY
iznimke ili spec. sluèajevi:
1. kada USER_OLD nije unesen tj. za STATUS_NEW='VNS' ne uzimati 
2. USER_ENTERED = USER_NEW -> netreba, neka uvijek obaviještava.
3. and a.aktivna=1 samo aktivna odobrenja, provjeriti s RLC -> bolje ne jer možda se može desiti sluèaj kada je bilo rada i u meðuvremenu je zakljuèeno
*/
DECLARE @id_history int
SET @id_history=10550

select * 
from dbo.wf_history 
where id_history > @id_history
	and id_status_new != 'VNS' --ne gleda novo unesen zahtjeve
	and id_document in (
		select id_wf_document from dbo.odobrit where id_kupca in (
		select a.id_kupca from p_eval a
		--zadnja unesena
		LEFT JOIN (SELECT id_kupca, MAX(dat_eval) as max_dat_eval, eval_type FROM dbo.p_eval GROUP BY id_kupca, eval_type) j ON a.id_kupca = j.id_kupca AND a.eval_type = j.eval_type
		where a.eval_type='E' 
		and a.eval_model in ('01N','20N') 
		)
	)

--ZADNJI
--SQL EXPORT
declare  @session_id as char(40)
set @session_id = '81c58557-cc96-474b-b697-0cb27a16d929    '

DECLARE @id_xdoc_template int, @FromMail varchar(200), @ToMail varchar(200) --, @body_text varchar(8000)
SET @id_xdoc_template = 15
SET @FromMail = 'tomislav.krnjak@gemicro.hr' -- u sluèaju da nije unesen email u dbo.users za korisnika
SET @ToMail = 'tomislav.krnjak@gemicro.hr' -- u sluèaju da nije unesen email u dbo.users za korisnika
------------------------------------------------------
--first table
select 
       cast(a.id_history as varchar(10)) as doc_id, 
		CASE WHEN ltrim(rtrim(g.email)) = '' THEN @FromMail ELSE g.email END as [from], -- korisnik koji je promjenio status
        CASE WHEN ltrim(rtrim(c.email)) = '' THEN @ToMail ELSE c.email END as [to], -- (novi) korisnik na koga je dodjeljen zahtje
		CASE WHEN ltrim(rtrim(f.email)) = '' THEN @FromMail ELSE f.email END as [cc], -- korisnik koji je unio zahtjev
	   --CASE WHEN ltrim(rtrim(g.email)) = '' THEN @FromMail ELSE b.email END as [bcc], -- korisnik koji je promjenio status
	   '' as [bcc],
       'Klijent '+ltrim(rtrim(e.naz_kr_kup))+
		CASE a.id_status_new 
			WHEN 'ODO' THEN ' odobren '
			WHEN 'ZAV' THEN ' je neodobren '
			ELSE ' èeka na odobrenje '
		END +cast(d.id_doc as varchar(10)) as [subject],
       '<p>Poštovani,</p><p>klijent '+ltrim(rtrim(e.naz_kr_kup))+
		 CASE a.id_status_new 
			WHEN 'ODO' THEN ' odobren - zahtjev '
			WHEN 'ZAV' THEN ' je neodobren - zahtjev '
			ELSE ' èeka na odobrenje leasing zahtjeva '
		END +cast(d.id_doc as varchar(10))+'.</p>'  as [body],
	   cast(0 as bit) as [has_attachment],
       cast(1 as bit) as [is_html],
       cast(1 as bit) as [send_immediately]
from dbo.wf_history a
--join dbo.users b on a.user_old=b.username -- (stari) korisnik sa koga je dodjeljen zahtjev
join dbo.users c on a.user_new=c.username -- (novi) korisnik na koga je dodjeljen zahtjev
join dbo.odobrit d on a.id_document=d.id_wf_document
join dbo.partner e on d.id_kupca=e.id_kupca
join dbo.users f on d.referent=f.username -- korisnik koji je unio zahtjev
join dbo.users g on a.user_entered=g.username -- korisnik koji je promjenio status
WHERE a.id_history IN
(SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
and
a.date_entered >= (select ISNULL(min(date_inserted),getdate()) as max_date_inserted from dbo.xdoc_run_history Where id_xdoc_template = @id_xdoc_template)
and a.id_status_old != '' --ne šalji za zahtjeve u statusu VNS tj. koji su samo uneseni
	and a.id_document in (
		select id_wf_document from dbo.odobrit where 
		-- kupci koji nemaju evaluaciju
		id_kupca not in (select distinct id_kupca from dbo.p_eval where eval_type='E')
		
		-- ili kupci u statusima evaluacija ('01N','20N')
		or id_kupca in (
		select a.id_kupca from p_eval a
		--zadnja unesena
		LEFT JOIN (SELECT id_kupca, MAX(dat_eval) as max_dat_eval, eval_type FROM dbo.p_eval GROUP BY id_kupca, eval_type) j ON a.id_kupca = j.id_kupca AND a.eval_type = j.eval_type
		where a.eval_type='E' 
		and a.eval_model in ('01N','20N') 
		)
	)
		

	INSERT INTO custom_settings values ('NOVA_SYS_MAIL_SERVER_DOMAIN','gemicro.hr','')
INSERT INTO custom_settings values ('NOVA_SYS_MAIL_SERVER_PWD','','')
INSERT INTO custom_settings values ('NOVA_SYS_MAIL_SERVER_UN','','')
select * from custom_settings where code like '%mail%'