-- SQL CANDIDATES

--MID 49739 g_vuradin 06.02.2023

declare @export_id as varchar(40)

set @export_id = {@export_id}

select cast(a.id as varchar(30)) as doc_id
from dbo.edoc_exported_files a
where cast(a.export_id as varchar(40)) = @export_id
and a.id_kupca in (Select a.id_kupca From dbo.p_kontakt a inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga Where a.neaktiven = 0 and b.sifra IN ('MAIL') Group by a.id_kupca) 
--and a.id_kupca not in (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' group by id_kupca)
and a.id_edoc_doctype = 'TaxChngIx'


--SQL SHOW
declare  @session_id as char(40)
set @session_id = {@session_id}

select cast(1 as bit) as Selected,
       cast(a.id_kupca as varchar(30)) as doc_id,      
       a.file_name as [Ime fajla],
       d.mail_to
	  -- into #temp20
from dbo.edoc_exported_files a	
INNER JOIN	(Select id_kupca, 
						max(email) as mail_to
                     From dbo.p_kontakt
                     Where id_vloga = '02'
                     Group by id_kupca
)d on a.id_kupca = d.id_kupca
where cast(a.id as varchar(30)) in (SELECT b.doc_id 
                   FROM dbo.xdoc_document_tmp b 
                   WHERE b.session_id = @session_id AND b.filter = 1)
Order by a.id_kupca



--SQL EXPORT 
declare  @session_id as char(40)
set @session_id = {@session_id}

declare @p_podjetje varchar(200), @p_mail varchar(200)
set @p_podjetje = (Select p_podjetje From dbo.nastavit)
set @p_mail = 'Raiffeisen Leasing <leasing.vodjenje@rl-hr.hr>' 
declare @body_text varchar(8000)
set @body_text = '<style>
.p1 {
  font-family: "Amalia",Regular;
  }
</style>
<p class="p1">

Poštovani,
<BR>
<BR>u privitku se nalazi Obavijest o promjeni mjesečne rate/obroka.
<BR>
<BR>S poštovanjem,
<BR>Vaš Raiffeisen Leasing d.o.o.'


------------------------------------------------------
declare @rootPathEdocMain varchar(100), @rootPathEdocAdd varchar(100)
set @rootPathEdocMain = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_MAIN')
set @rootPathEdocAdd = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_ADD')

select 
       cast(a.id_kupca as varchar(10)) as doc_id, 
       @p_mail as [from],
       d.mail_to as [to],
       '' as [cc],
       'Obavijest o promjeni mjesečne rate/obroka' as [subject],
       @body_text as [body],
       cast(1 as bit) as [has_attachment],
       cast(1 as bit) as [is_html],
       cast(1 as bit) as [send_immediately],	
       a.id_kupca as [id_kupca]  
INTO #temp20
	   
from 
       dbo.edoc_exported_files a
       INNER JOIN	(Select a.id_kupca, 
						max(email) as mail_to
                     From dbo.p_kontakt a 
                     inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
                     Where a.neaktiven = 0 and b.sifra IN ('MAIL')
                     Group by id_kupca
		)d on a.id_kupca = d.id_kupca

       inner join dbo.partner p ON a.id_kupca = p.id_kupca
where 
       cast(a.id as varchar(30)) in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
Group by a.id_kupca, d.mail_to

--GDPR LOGIRANJE
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
			p.id_kupca as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'' as  '@Additional_desc'
		FROM #temp20 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.doc_id
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by p.ID_KUPCA, p.vr_osebe 
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();
exec dbo.gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'E-mail','INTERNAL','XDOC', 'eDoc to eMail exporter Obavijesti o promjeni mjesečne rate- Samo mail (01) - SQL Show','20',@xml
drop table #tempVrste
--Kraj GDPR

--first table
select  doc_id, [from], [to], [cc], [subject],
		[body], [has_attachment], [is_html], [send_immediately], [id_kupca]
		from #temp20

--second table
--impossible condition to get the second table empty
select 
       cast(a.id_kupca as char(30)) as doc_id,
       'Dummy' as [report_name],
       '-1' as [report_id],
       'PDF' as [rendering_format],
       'Dummy' as [attachment_name]
from dbo.edoc_exported_files a
where a.id = -1
 
--third table
select cast(a.id_kupca as varchar(10)) as doc_id, @rootPathEdocMain + a.file_name as file_path, 'Obavijest o promjeni mjesečne rate-obroka' as attachment_name
from dbo.edoc_exported_files a
LEFT JOIN dbo.REP_IND  rep on a.document_id  = cast(rep.id_rep_ind as char(50))
where cast(a.id as char(30)) 
in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
Order by a.id_kupca,rep.id_cont asc

drop table #temp20