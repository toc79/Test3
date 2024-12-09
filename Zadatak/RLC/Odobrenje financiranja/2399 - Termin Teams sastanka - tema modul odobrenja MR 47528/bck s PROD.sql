DECLARE @id_xdoc_template int
SET @id_xdoc_template = 22

select cast(id_history as char(30)) as doc_id
from dbo.wf_history 
WHERE date_entered >= (select ISNULL(max(date_inserted),getdate()-1) as max_date_inserted from dbo.xdoc_run_history Where status='C' and id_xdoc_template = @id_xdoc_template)



--SQL SHOW
--MID 42243, 14.03.2019, Omar - uključivanje retail partnera, dodavanje cc e-mail adrese, i izmjene teksta e-maila
declare  @session_id as char(40)
set @session_id = {@session_id}

DECLARE @id_xdoc_template int, @FromMail varchar(200)
SET @id_xdoc_template = 22
SET @FromMail = (select dbo.gfn_GetCustomSettings('NOVA_SYS_EMAIL_FROM'))

			 
select 
  cast(1 as bit) as Selected,
  cast(a.id_history as char(30)) as doc_id,
  CASE WHEN ltrim(rtrim(g.email)) = '' THEN @FromMail ELSE g.email END as [from], -- korisnik koji je promjenio status
  CASE WHEN ltrim(rtrim(c.email)) = '' THEN @FromMail ELSE c.email END as [to], -- (novi) korisnik na koga je dodjeljen zahtjev
  CASE WHEN a.id_status_new IN ('ODO', 'ZAV') AND d.kategorija1 != '07' THEN 'leasing.odobrenja@rl-hr.hr;' ELSE '' END + CASE WHEN ltrim(rtrim(f.email)) = '' THEN @FromMail ELSE f.email END as [cc], -- korisnik koji je unio zahtjev
   '' as [bcc],
   'Klijent '+ltrim(rtrim(e.naz_kr_kup))+
	CASE a.id_status_new 
		WHEN 'ODO' THEN ' odobren '
		WHEN 'ZAV' THEN ' je neodobren '
		ELSE ' čeka na odobrenje '
	END +cast(d.id_doc as varchar(10)) as [subject],
   '<p>Poštovani,</p><p>klijent '+ltrim(rtrim(e.naz_kr_kup))+
	 CASE a.id_status_new 
		WHEN 'ODO' THEN ' odobren - zahtjev ' +cast(d.id_doc as varchar(10))+ '.</p>'
		WHEN 'ZAV' THEN ' je neodobren - zahtjev ' +cast(d.id_doc as varchar(10)) + '.</p>'
		ELSE ' čeka na odobrenje leasing zahtjeva ' +cast(d.id_doc as varchar(10)) + '.</p>'
		+ '<p>Stari status: ' + RTRIM(sold.title) + '.</p>'
		+ '<p>Novi status: ' + RTRIM(snew.title) + '.</p>'
	END as [body],
   cast(0 as bit) as [has_attachment],
   cast(1 as bit) as [is_html],
   cast(1 as bit) as [send_immediately],
   e.id_kupca as id_kupca
INTO #temp22
from dbo.wf_history a
--join dbo.users b on a.user_old=b.username -- (stari) korisnik sa koga je dodjeljen zahtjev
join dbo.users c on a.user_new=c.username -- (novi) korisnik na koga je dodjeljen zahtjev
join dbo.odobrit d on a.id_document=d.id_wf_document
join dbo.partner e on d.id_kupca=e.id_kupca
join dbo.users f on d.referent=f.username -- korisnik koji je unio zahtjev
join dbo.users g on a.user_entered=g.username -- korisnik koji je promjenio status
LEFT JOIN dbo.wf_status sold ON a.id_status_old = sold.id_status
LEFT JOIN dbo.wf_status snew ON a.id_status_new = snew.id_status
WHERE a.id_history IN
(SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
and
a.date_entered >= (select ISNULL(max(date_inserted),getdate()-1) as max_date_inserted from dbo.xdoc_run_history Where status='C' and id_xdoc_template = @id_xdoc_template)
and a.id_status_old != '' --ne šalji za zahtjeve u statusu VNS tj. koji su tek uneseni
and a.id_document in (
		select id_wf_document from dbo.odobrit where 
		-- kupci koji nemaju E evaluaciju
		id_kupca not in (select distinct id_kupca from dbo.p_eval where eval_type='E')
		
		-- ili kupci sa zadnjim statusima E evaluacija ('01N','20N')
		or id_kupca in (
		select id_kupca from dbo.gv_PEval_LastEvaluation_ByType
        where eval_type='E' 
		--and eval_model in ('01N','20N') 
		)
	)

SELECT cs.id as id
INTO #tempVrste
FROM dbo.gfn_split_ids( (Select [val] FROM dbo.CUSTOM_SETTINGS WHERE code='Nova.GDPR.ListOfCustomerTypesForAccessLog'),',') cs

declare @xml as xml
set @xml = 
(
	SELECT * 
	FROM 
	(
		SELECT
			t.id_kupca as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'' as  '@Additional_desc'
		FROM #temp22 t
		INNER JOIN PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.id_kupca, p.vr_osebe
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)


DECLARE @time datetime;
SET @time=GETDATE();
exec gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Kraći naziv, EMAIL','INTERNAL','XDOC', 'Izvoz podataka za Mail modul - odobrenje financiranja promjena statusa  - SQL show',22,@xml

drop table #tempVrste
-- KONEC GDPR

select 
Selected,
doc_id,
[from], 
[to], 
[cc],  
[bcc], 
[subject], 
[body], 
[has_attachment], 
[is_html], 
[send_immediately]
from #temp22
drop table #temp22


--SQL EXPORT
--MID 42243, 14.03.2019, Omar - uključivanje retail partnera, dodavanje cc e-mail adrese, i izmjene teksta e-maila
-- 17.09.2021 g_tomislav MID 47528 - removing condition d.kategorija1 != '07'; removing unnecessary code; removing hardcode id_xdoc_template = 22 with variable; replacing NOVA_SYS_EMAIL_FROM to NOVA_SYS_EMAIL_ADMIN 

declare  @session_id as char(40)
set @session_id = {@session_id}

DECLARE @id_xdoc_template int, @AdminMail varchar(200)
SET @id_xdoc_template = {@id_template}
SET @AdminMail = (select dbo.gfn_GetCustomSettings('NOVA_SYS_EMAIL_ADMIN')) -- u slučaju da nije unesen email u dbo.users za korisnika
------------------------------------------------------
--first table
select 
   cast(a.id_history as varchar(10)) as doc_id, 
   CASE WHEN ltrim(rtrim(g.email)) = '' THEN @AdminMail ELSE g.email END as [from], -- korisnik koji je promjenio status
   CASE WHEN ltrim(rtrim(c.email)) = '' THEN @AdminMail ELSE c.email END as [to], -- (novi) korisnik na koga je dodjeljen zahtjev
   CASE WHEN a.id_status_new IN ('ODO', 'ZAV') THEN 'leasing.odobrenja@rl-hr.hr;' ELSE '' END + CASE WHEN ltrim(rtrim(f.email)) = '' THEN @AdminMail ELSE f.email END as [cc], -- korisnik koji je unio zahtjev
   '' as [bcc],
   'Klijent '+ltrim(rtrim(e.naz_kr_kup))+
	CASE a.id_status_new 
		WHEN 'ODO' THEN ' odobren '
		WHEN 'ZAV' THEN ' je neodobren '
		ELSE ' čeka na odobrenje '
	END +cast(d.id_doc as varchar(10)) as [subject],
   '<p>Poštovani,</p><p>klijent '+ltrim(rtrim(e.naz_kr_kup))+
	 CASE a.id_status_new 
		WHEN 'ODO' THEN ' odobren - zahtjev ' +cast(d.id_doc as varchar(10))+ '.</p>'
		WHEN 'ZAV' THEN ' je neodobren - zahtjev ' +cast(d.id_doc as varchar(10)) + '.</p>'
		ELSE ' čeka na odobrenje leasing zahtjeva ' +cast(d.id_doc as varchar(10)) + '.</p>'
		+ '<p>Stari status: ' + RTRIM(sold.title) + '.</p>'
		+ '<p>Novi status: ' + RTRIM(snew.title) + '.</p>'
	END as [body],
   cast(0 as bit) as [has_attachment],
   cast(1 as bit) as [is_html],
   cast(1 as bit) as [send_immediately],
   e.id_kupca as id_kupca
INTO #temp22
from dbo.wf_history a
--join dbo.users b on a.user_old=b.username -- (stari) korisnik sa koga je dodjeljen zahtjev
join dbo.users c on a.user_new=c.username -- (novi) korisnik na koga je dodjeljen zahtjev
join dbo.odobrit d on a.id_document=d.id_wf_document
join dbo.partner e on d.id_kupca=e.id_kupca
join dbo.users f on d.referent=f.username -- korisnik koji je unio zahtjev
join dbo.users g on a.user_entered=g.username -- korisnik koji je promjenio status
LEFT JOIN dbo.wf_status sold ON a.id_status_old = sold.id_status
LEFT JOIN dbo.wf_status snew ON a.id_status_new = snew.id_status
WHERE a.id_history IN (SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
and a.id_status_old != '' --ne šalji za zahtjeve u statusu VNS tj. koji su tek uneseni

-- GDPR LOGIRANJE
SELECT cs.id as id
INTO #tempVrste
FROM dbo.gfn_split_ids( (Select [val] FROM dbo.CUSTOM_SETTINGS WHERE code='Nova.GDPR.ListOfCustomerTypesForAccessLog'),',') cs

declare @xml as xml
set @xml = 
(
	SELECT * 
	FROM 
	(
		SELECT
			t.id_kupca as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'' as  '@Additional_desc'
		FROM #temp22 t
		INNER JOIN PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.id_kupca, p.vr_osebe
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)


DECLARE @time datetime;
SET @time=GETDATE();
exec gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Kraći naziv, EMAIL','INTERNAL','XDOC', 'Izvoz podataka za Mail modul - odobrenje financiranja promjena statusa - SQL export',22,@xml

drop table #tempVrste
-- KONEC GDPR

select  
		 
doc_id,
[from], 
[to], 
[cc],  
[bcc], 
[subject], 
[body], 
[has_attachment], 
[is_html], 
[send_immediately]
 from #temp22
drop table #temp22