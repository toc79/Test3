--17.09.2024 TREBA KREIRATI NOVI XDOC KOJI ĆE ISPISIVATI REPORTE

--SQL EXPORT
-- 09.09.2024 g_tomislav MID 49592 - created;
--TODO isključiti zapise s ID pripreme 6 =A to još provjeriti s RLC da li idu opomene jamcima

declare  @session_id as char(40)
set @session_id = {@session_id}

declare @p_podjetje varchar(200), @p_mail varchar(200)
set @p_podjetje = (Select p_podjetje From dbo.nastavit)
set @p_mail = 'Raiffeisen Leasing_Racuni <racuni@rl-hr.hr>' -- TODO PROMIJENITI EMAIL ADRESU
declare @body_text varchar(8000)
set @body_text = '<style>
.p1 {
  font-family: "Amalia",Regular;
  }
</style>
<p class="p1">

Poštovani,
<BR>
<BR>u privitku Vam šaljemo opomenu za neplaćena potraživanja za ugovor na kojemu ste jamac.
<BR>
<BR>Kako bi bez poteškoća mogli pročitati poslane Vam dokumente, molimo slijedeće:
<BR>- na računalu je potrebno imati Adobe Acrobat Reader minimalno ver.6.0, ukoliko navedeno nemate, molimo da instalirate prije pregleda računa (najnoviju verziju možete pronaći ovdje: <a href="https://get.adobe.com/reader/">https://get.adobe.com/reader/</a>)
<BR>- ukoliko želite provjeriti autentičnost i konzistentnost računa, potreban je FINA-in certifikat koji je besplatan (korisnici FINA-inih web usluga mogu preskočiti ovaj korak) te ga možete preuzeti na stranicama FINA-e
<BR>- molimo da održavate svoj poštanski sandučić, odnosno da u istome uvijek osigurate dovoljno slobodnog prostora kako bi Vam računi bili dostavljeni.
<BR>
<BR>Napomena: ' +@p_podjetje +'zadržava pravo slanja računa poštom uslijed nepredviđenih događaja.
<BR>
<BR>Ukoliko imate pitanja, molimo pošaljete svoj upit na <a href="mailto:racuni@rl-hr.hr">racuni@rl-hr.hr</a> TODO PROMIJENITI EMAIL ADRESU
<BR>
<BR>S poštovanjem,
<BR>Vaš ' +@p_podjetje

------------------------------------------------------
-- declare @rootPathEdocMain varchar(100), @rootPathEdocAdd varchar(100)
-- set @rootPathEdocMain = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_MAIN')
--set @rootPathEdocAdd = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_ADD')

--first table
--računi i opomene bez troška primatelji

union all

--obavijesti jamcima
select 
	cast(pogp.id_poroka as varchar(10)) as doc_id, 
	@p_mail as [from],
	d.mail_to as [to],
	'' as [cc],
	'Opomena jamcu za neplaćena potraživanja' as [subject],
	@body_text as [body],
	cast(1 as bit) as [has_attachment],
	cast(1 as bit) as [is_html],
	cast(0 as bit) as [send_immediately],	
	pogp.id_poroka as [id_kupca]  
from dbo.za_opom zo
	--inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
	inner join dbo.pog_poro pogp on zo.id_cont = pogp.id_cont
	inner join 
		(	Select a.id_kupca, max(email) as mail_to
			From dbo.p_kontakt a 
				inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
			Where a.neaktiven = 0 and b.sifra IN ('MAIL')
			Group by a.id_kupca
		) d on pogp.id_poroka = d.id_kupca
where zo.st_opomina in (1,2,3)
	and isnull(zo.dok_opom, '') != ''
	and pogp.neaktiven = 0
	and pogp.oznaka in ('0', '1', 'A')
group by pogp.id_poroka, d.mail_to -- zakomentirati ako zbog digitalnog potpisa ide jedan po jedan mail. kasnije se može vidjeti da se grupira po batch/saršama od npr. 10 koristeći row_number

--isključiti ID pripreme 6 za sve iznad

union all
--ID pripreme 6

select 
	cast(zo.id_kupca as varchar(10)) as doc_id, 
	@p_mail as [from],
	d.mail_to as [to],
	'' as [cc],
	'Obavijest o neplaćenim potraživanjima' as [subject],
	@body_text as [body],
	cast(1 as bit) as [has_attachment],
	cast(1 as bit) as [is_html],
	cast(0 as bit) as [send_immediately],	
	zo.id_kupca as [id_kupca]  
from dbo.za_opom zo
	inner join 
		(	Select a.id_kupca, max(email) as mail_to
			From dbo.p_kontakt a 
				inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
			Where a.neaktiven = 0 and b.sifra IN ('MAIL')
			Group by a.id_kupca
		) d on zo.id_kupca = d.id_kupca
where zo.st_opomina in (1,2,3)
group by zo.id_kupca, d.mail_to -- zakomentirati ako zbog digitalnog potpisa ide jedan po jedan mail. kasnije se može vidjeti da se grupira po batch/saršama od npr. 10 koristeći row_number


order by id_kupca

--second table - it is used for report rendering
-- select 
	-- cast(a.id as char(30)) as doc_id,
	-- 'Dummy' as [report_name],
	-- '-1' as [report_id],
	-- 'PDF' as [rendering_format],
	-- 'Dummy' as [attachment_name]
-- from dbo.edoc_exported_files a
-- where a.id = -1

select cast(pogp.id_poroka as char(30)) as doc_id,
	'OBV_POR_SSOFT_RLC' as [report_name],
	convert(varchar(30), zo.id_opom) + ';' + pogp.id_poroka as [report_id],
	'PDF' as [rendering_format],
	'Opomena jamcu za neplaćena potraživanja' as [attachment_name]
from dbo.za_opom zo
	--inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
	inner join dbo.pog_poro pogp on zo.id_cont = pogp.id_cont
	inner join 
		(	Select a.id_kupca, max(email) as mail_to
			From dbo.p_kontakt a 
				inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
			Where a.neaktiven = 0 and b.sifra IN ('MAIL')
			Group by a.id_kupca
		) d on pogp.id_poroka = d.id_kupca
where zo.st_opomina in (1,2,3)
	and isnull(zo.dok_opom, '') != ''
	and pogp.neaktiven = 0
	and pogp.oznaka in ('0', '1')
	
union all 

select cast(pogp.id_poroka as char(30)) as doc_id,
	'OPOMJAM_SSOFT_RLC' as [report_name],
	convert(varchar(30), zo.id_opom) + ';' + pogp.id_poroka as [report_id],
	'PDF' as [rendering_format],
	'Obavijest o neplaćenim potraživanjima' as [attachment_name]
from dbo.za_opom zo
	--inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
	inner join dbo.pog_poro pogp on zo.id_cont = pogp.id_cont
	inner join 
		(	Select a.id_kupca, max(email) as mail_to
			From dbo.p_kontakt a 
				inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
			Where a.neaktiven = 0 and b.sifra IN ('MAIL')
			Group by a.id_kupca
		) d on pogp.id_poroka = d.id_kupca
where zo.st_opomina in (1,2,3)
	and isnull(zo.dok_opom, '') != ''
	and pogp.neaktiven = 0
	and pogp.oznaka in ('A')
	
 
--third table - files from disk
-- select --cast(eef.id as varchar(40)) as doc_id,  -- bilo varchar(10) po eef.id ide kada se šalje jedan mail jedan privitak
	-- cast(eef.id_kupca as varchar(40)) as doc_id, 
	-- @rootPathEdocMain + eef.file_name as file_path, 
	-- 'Račun za ratu ' +rtrim(eef.document_id) as attachment_name
-- into #attach
-- from dbo.edoc_exported_files eef
	-- inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
----where cast(eef.id as char(40)) in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
-- where 1= 0
-- order by eef.id_kupca

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

-- Select * from #attach

-- drop table #attach