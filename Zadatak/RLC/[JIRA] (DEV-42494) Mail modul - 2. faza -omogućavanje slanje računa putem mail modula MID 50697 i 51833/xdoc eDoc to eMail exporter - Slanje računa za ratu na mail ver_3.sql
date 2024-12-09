-- PARAMETERS
Red.br.	Ime	Opis	Varijabla	Tip	Preuzeta vrijednost	Omogućen	Vidljiv	Lookup	Lookup SQL naredba	Lookup title column	Lookup value column	Kriterij
1,00000000	export_id	Export_id iz edoc_exported_files	{@export_id}	string		.T.	.T.	.T.	Select top 1000 convert(varchar(10), cast(convert(varchar, eef.date_prepared, 112) as datetime),4) + . količina:   +convert(varchar(30), count(*)) +  . ID:   + rtrim(eef.export_id) as opis  , eef.export_id from dbo.edoc_exported_files eef inner join	opis	export_id	criteria_combobox
--LOOKUP SQL naredba
Select top 100 convert(varchar(10), cast(convert(varchar, eef.date_prepared, 112) as datetime),4) +'. količina: ' +convert(varchar(30), count(*)) + '. ID: ' + rtrim(eef.export_id) as opis
	, eef.export_id
from dbo.edoc_exported_files eef
inner join dbo.najem_fa nf on eef.document_id = nf.ddv_id
where eef.id_edoc_doctype = 'Invoice'
and nf.id_terj = '21'
and exists (Select * 
			From dbo.p_kontakt a 
			inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga 
			Where a.neaktiven = 0 
			and b.sifra IN ('MAIL') 
			and a.id_kupca = eef.id_kupca /*Group by a.id_kupca*/)
Group by eef.export_id, cast(convert(varchar, eef.date_prepared, 112) as datetime)
order by cast(convert(varchar, eef.date_prepared, 112) as datetime) desc


-- SQL CANDIDATES
-- 24.08.2023 g_tomislav MID 50697 - created;

declare @export_id as varchar(40)
set @export_id = {@export_id}

select cast(eef.id as varchar(40)) as doc_id -- ili podesiti nf.ddv_id ovisno kako će se razvijati slanje na mil
from dbo.edoc_exported_files eef
inner join dbo.najem_fa nf on eef.document_id = nf.ddv_id
inner join dbo.vrst_ter vt on nf.id_terj = vt.id_terj
where cast(eef.export_id as varchar(40)) = @export_id
and eef.id_edoc_doctype in ('Invoice')
and exists (Select * 
			From dbo.p_kontakt a 
			inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga 
			Where a.neaktiven = 0 
			and b.sifra IN ('MAIL') 
			and a.id_kupca = eef.id_kupca /*Group by a.id_kupca*/)
and not exists (Select * From dbo.partner where ident_stevilka is not null and ident_stevilka <> '' and id_kupca = eef.id_kupca)
and vt.sif_terj = 'LOBR'

/*
-- SQL SHOW AKO NEĆE RUČNO POKRETATI; TAJ SELECT JE NEPOTREBAN ZAPRAVO NITI MOGU RUČNO POKRETATI JER PATH ZA DATOTEKU VIŠE NE SADRŽI DOKUMENTE NA TOJ LOKACIJI VEĆ U ARCHIVE FOLDERU (moglo bi se podesiti i ručno pokretanje) TAKO DA ĆU TO MAKNUTI
-- EVENTUALNO AKO IM SE PODESI DA DATOTEKE POSTAVE NA NEKU LOKACIJU I DA TO PODRŽOMO U SELECTIMA
-- 24.08.2023 g_tomislav MID 50697 - created;

declare @session_id as char(40)
set @session_id = {@session_id}

select cast(1 as bit) as Selected
	, cast(eef.id as varchar(40)) as doc_id
	, eef.id_kupca
	, dbo.gfn_StringToFox(eef.file_name) as [Ime fajla]
	, d.mail_to
into #temp3
from dbo.edoc_exported_files eef	
inner join (Select a.id_kupca, 
				max(a.email) as mail_to
			From dbo.p_kontakt a 
			inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga 
			Where a.neaktiven = 0 
			and b.sifra IN ('MAIL') 
			Group by a.id_kupca
	) d on eef.id_kupca = d.id_kupca
inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
--where exists (select * from dbo.xdoc_document_tmp b where b.session_id = @session_id and b.filter = 1 and b.doc_id = cast(eef.id as varchar(40)))
order by eef.id_kupca

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
			t.id_kupca as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'' as  '@Additional_desc'
		FROM #temp3 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.ID_KUPCA, p.vr_osebe 
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();
exec dbo.gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'E-mail','INTERNAL','XDOC', 'eDoc to eMail exporter - Samo mail (01) - SQL Show','3',@xml
drop table #tempVrste
--KRAJ GDPR

select * from #temp3
drop table #temp3
*/

--SQL EXPORT
-- 26.09.2023 g_tomislav MID 50697 - created;

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
<BR>u privitku šaljemo račune kreirane za sklopljene ugovore o leasingu.
<BR>
<BR>Kako bi bez poteškoća mogli pročitati poslane Vam dokumente, molimo slijedeće:
<BR>- na računalu je potrebno imati Adobe Acrobat Reader minimalno ver.6.0, ukoliko navedeno nemate, molimo da instalirate prije pregleda računa (najnoviju verziju možete pronaći ovdje: <a href="https://get.adobe.com/reader/">https://get.adobe.com/reader/</a>)
<BR>- ukoliko želite provjeriti autentičnost i konzistentnost računa, potreban je FINA-in certifikat koji je besplatan (korisnici FINA-inih web usluga mogu preskočiti ovaj korak) te ga možete preuzeti na stranicama FINA-e
<BR>- molimo da održavate svoj poštanski sandučić, odnosno da u istome uvijek postoji minimalno 1 MB slobodnog prostora kako bi Vam računi bili dostavljeni.
<BR>
<BR>Napomena: ' +@p_podjetje +'zadržava pravo slanja računa poštom uslijed nepredviđenih događaja.
<BR>
<BR>Ukoliko imate pitanja, molimo pošaljete svoj upit na <a href="mailto:racuni@rl-hr.hr">racuni@rl-hr.hr</a>
<BR>
<BR>S poštovanjem,
<BR>Vaš ' +@p_podjetje

------------------------------------------------------
declare @rootPathEdocMain varchar(100), @rootPathEdocAdd varchar(100)
set @rootPathEdocMain = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_MAIN')
--set @rootPathEdocAdd = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_ADD')

--first table
select 
	cast(eef.id_kupca as varchar(10)) as doc_id, 
	--cast(eef.id as varchar(40)) as doc_id, 
	@p_mail as [from],
	d.mail_to as [to],
	'' as [cc],
	'Račun za mjesečnu ratu/obrok' as [subject],
	@body_text as [body],
	cast(1 as bit) as [has_attachment],
	cast(1 as bit) as [is_html],
	cast(1 as bit) as [send_immediately],	
	eef.id_kupca as [id_kupca]  
from dbo.edoc_exported_files eef
inner join (Select a.id_kupca, 
				max(email) as mail_to
			From dbo.p_kontakt a 
			inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
			Where a.neaktiven = 0 and b.sifra IN ('MAIL')
			Group by id_kupca
	) d on eef.id_kupca = d.id_kupca
--inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
Group by eef.id_kupca, d.mail_to -- zakomentirati ako zbog digitalnog potpisa ide jedan po jedan mail. kasnije se može vidjeti da se grupira po batch/saršama od npr. 10 koristeći row_number
order by eef.id_kupca

--second table - it is used for report rendering
--impossible condition to get the second table empty 
select 
       cast(a.id as char(30)) as doc_id,
       'Dummy' as [report_name],
       '-1' as [report_id],
       'PDF' as [rendering_format],
       'Dummy' as [attachment_name]
from dbo.edoc_exported_files a
where a.id = -1
 
--third table - files from disk
select --cast(eef.id as varchar(40)) as doc_id,  -- bilo varchar(10) po eef.id ide kada se šalje jedan mail jedan privitak
	cast(eef.id_kupca as varchar(40)) as doc_id, 
	@rootPathEdocMain + eef.file_name as file_path, 
	'Račun za ratu ' +rtrim(eef.document_id) as attachment_name
into #attach
from dbo.edoc_exported_files eef
inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
--where cast(eef.id as char(40)) in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
order by eef.id_kupca

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