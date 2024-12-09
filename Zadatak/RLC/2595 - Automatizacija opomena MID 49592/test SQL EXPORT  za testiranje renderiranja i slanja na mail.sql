--SQL EXPORT
-- 06.09.2024 g_tomislav MID 49592 - created;

declare  @session_id as char(40)
set @session_id = {@session_id}

declare @p_podjetje varchar(200), @p_mail varchar(200)
set @p_podjetje = (Select p_podjetje From dbo.nastavit)
set @p_mail = 'Raiffeisen Leasing_Racuni <racuni@rl-hr.hr>' 
declare @body_text varchar(8000)
set @body_text = '<style>
.p1 {
  font-family: "Amalia",Regular;
  }
</style>
<p class="p1">

Poštovani,
<BR>
<BR>test GMC.'

------------------------------------------------------
declare @rootPathEdocMain varchar(100), @rootPathEdocAdd varchar(100)
set @rootPathEdocMain = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_MAIN')
--set @rootPathEdocAdd = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_ADD')

--first table
select 
	'000012' as doc_id, 
	--cast(eef.id as varchar(40)) as doc_id, 
	@p_mail as [from],
	'tomislav.krnjak@gemicro.hr' as [to],
	'' as [cc],
	'Račun za mjesečnu ratu/obrok' as [subject],
	@body_text as [body],
	cast(1 as bit) as [has_attachment],
	cast(1 as bit) as [is_html],
	cast(0 as bit) as [send_immediately],	
	eef.id_kupca as [id_kupca] 
from dbo.partner eef
where id_kupca = '000012'
-- from dbo.edoc_exported_files eef
-- inner join (Select a.id_kupca, 
				-- max(email) as mail_to
			-- From dbo.p_kontakt a 
			-- inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
			-- Where a.neaktiven = 0 and b.sifra IN ('MAIL')
			-- Group by id_kupca
	-- ) d on eef.id_kupca = d.id_kupca
-- inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
-- Group by eef.id_kupca, d.mail_to -- zakomentirati ako zbog digitalnog potpisa ide jedan po jedan mail. kasnije se može vidjeti da se grupira po batch/saršama od npr. 10 koristeći row_number
-- order by eef.id_kupca

--second table - it is used for report rendering
select 
       cast(a.id_kupca as char(30)) as doc_id,
       'OBV_POR_SSOFT_RLC' as [report_name],
       '19658689;041416' as [report_id],
       'PDF' as [rendering_format],
       'Dummy' as [attachment_name]
from dbo.partner a
where id_kupca = '000012'
--from dbo.edoc_exported_files a
--where a.id = -1
 
--third table - files from disk
--impossible condition to get the third table empty 
select --cast(eef.id as varchar(40)) as doc_id,  -- bilo varchar(10) po eef.id ide kada se šalje jedan mail jedan privitak
	cast(eef.id_kupca as varchar(40)) as doc_id, 
	@rootPathEdocMain + eef.file_name as file_path, 
	'Račun za ratu ' +rtrim(eef.document_id) as attachment_name
into #attach
from dbo.edoc_exported_files eef
inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
--where cast(eef.id as char(40)) in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
where 1=0 --imposible condition 
order by eef.id_kupca

--Dodatni attachment ako za to ima potrebe
-- if exists(Select * from general_register where id_register='DODATNI_ATTACHMENT' and neaktiven = 0)
-- begin
	-- insert into #attach(doc_id, file_path, attachment_name)
	-- select cast(a.id as varchar(10)) as doc_id, @rootPathEdocAdd + rtrim(g.id_key) as file_path, 'Dopis' as attachment_name
	-- from dbo.edoc_exported_files a
	-- left join dbo.general_register g on g.id_register='DODATNI_ATTACHMENT' and g.neaktiven = 0
	-- where cast(a.id as char(30)) 
	-- in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
	-- And (g.id_key is not null and g.id_key <> '')
	-- And 1 = (Case when g.value is null or g.value = '' or a.id_kupca is null or a.id_kupca = '' then 1 Else Case When charindex(a.id_kupca, rtrim(g.value)) <> 0 then 1 else 0 end end)
    -- Order by a.id_kupca
-- end

Select * from #attach

drop table #attach