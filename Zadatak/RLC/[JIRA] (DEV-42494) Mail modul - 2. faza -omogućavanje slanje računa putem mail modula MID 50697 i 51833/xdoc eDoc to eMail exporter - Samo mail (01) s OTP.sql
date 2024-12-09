--SQL CANDIDATES

-- MID: 41509 g_barbarak - isključivanje iz pripreme SPR_DDV
-- MID: 42631 g_barbarak - uključivanje u pripremu SPR_DDV
-- MID: 45590 g_barbarak - isključivanje tečajnih razlika manjih od 10 kn
-- 24.08.2021 g_tomislav MID 47436 - dodan id_edoc_doctype 'InvoiceCum' za zbirne račune
-- 10.09.2021 g_tomislav MID 47436 - za zbirne račune ide mail i u slučaju da partner ima unesen FINA ID (ident_stevilka)
-- 02.11.2021 g_branisl	MID 47493 - dodavanje uvjeta po ulozi partnera za tečajne razlike - isključivanje granice manje od 10 kn za one koji imaju unesenu ulogu

declare @export_id as varchar(40)
set @export_id = {@export_id}

select a.ddv_id
INTO #tmp_tec_razl
From dbo.rac_out a
inner join (Select ddv_id, sum(ostalo) as ostalo from dbo.tec_razl group by ddv_id) c on a.ddv_id = c.ddv_id
left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'TR' and neaktiven = 0 Group by id_kupca) TR on a.id_kupca = TR.id_kupca
where a.ddv_id in (select document_id from dbo.edoc_exported_files where export_id = @export_id)
and (ABS(a.debit_neto+a.debit_davek+a.brez_davka+a.neobdav+c.ostalo) < 10 and TR.id_kupca IS NULL)

select cast(a.id as varchar(30)) as doc_id
from dbo.edoc_exported_files a
left join #tmp_tec_razl t on a.document_id = t.DDV_ID
where cast(a.export_id as varchar(40)) = @export_id
and a.id_edoc_doctype in ('Invoice', 'InvoiceCum')
and a.id_kupca in (Select a.id_kupca From dbo.p_kontakt a inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga Where a.neaktiven = 0 and b.sifra IN ('MAIL') Group by a.id_kupca) 
and a.id_kupca not in (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' group by id_kupca) 
and (a.id_kupca not in (Select id_kupca From dbo.partner where ident_stevilka is not null and ident_stevilka <> ''))
and t.ddv_id is null

drop table #tmp_tec_razl


--SQL SHOW
declare  @session_id as char(40)
set @session_id = {@session_id}

select cast(1 as bit) as Selected,
       cast(a.id as varchar(30)) as doc_id,
       a.id_kupca,
       dbo.gfn_StringToFox(a.file_name) as [Ime fajla],
       d.mail_to
INTO #temp3
from dbo.edoc_exported_files a	
INNER JOIN	(Select id_kupca, 
						max(email) as mail_to
                     From dbo.p_kontakt
                     Where id_vloga = '01'
                     Group by id_kupca
)d on a.id_kupca = d.id_kupca
where cast(a.id as varchar(30)) in (SELECT b.doc_id 
                   FROM dbo.xdoc_document_tmp b 
                   WHERE b.session_id = @session_id AND b.filter = 1)
Order by a.id_kupca

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
select* from #temp3
drop table #temp3


--SQL EXPORT
-- 31.08.2021 g_tomislav MID 47436 - dodan source 1347 za zbirne račune; zamjenjen je a.document_id sa b.ddv_id za dobivanje source za zbirne račune čiji document_id nije ddv_id već id_zbirnika. TODO: provjeriti da li se može optimizirati da se edoc_exported_files ne zove više puta; g.source = 'GL_OUTPUT_R' nije naveden vjerojatno nisu tražili

declare  @session_id as char(40)
set @session_id = {@session_id}

declare @p_podjetje varchar(200), @p_mail varchar(200)
set @p_podjetje = (Select p_podjetje From dbo.nastavit)
set @p_mail = 'Računi OTP Leasing d.d. <racuni@otpleasing.hr>' 
declare @body_text varchar(8000)
set @body_text = 'Poštovani,
<P>
<BR>U prilogu šaljemo račune kreirane na temelju potpisanog ugovora o leasingu.
<BR><B>Priloženi računi su kopije originala a originale možete preuzeti ili provjeriti ispravnost istih na https://portal.otpleasing.hr/</B>
<BR>Molimo da sukladno prošloj obavijesti, obratite pozornost na prethodno poslane upute i navedene napomene.
<BR>Kako bi bez poteškoća mogli pročitati poslane Vam dokumente, molimo slijedeće:
<BR>- Na računalu je potrebno imati Adobe Acrobat Reader minimalno ver.6.0, ukoliko navedeno nemate, molimo da instalirate prije pregleda računa (najnoviju verziju možete pronaći ovdje: http://get.adobe.com/reader)
<BR>- Ukoliko želite provjeriti autentičnost i konzistentnost računa, potreban je FINA-in RDC certifikat koji je besplatan (korisnici FINA-inih web usluga mogu preskočiti ovaj korak) i možete ga preuzeti ovdje: http://rdc-tdu.fina.hr/CA/RDC-TDUCA.cer. U prilogu ovog e-maila se također nalaze upute za instalaciju kao i upute za provjeru autentičnosti.
<BR><B>- Molimo da održavate svoj poštanski sandučić, odnosno da u istome uvijek postoji minimalno 1 MB slobodnog prostora kako bi Vam računi bili dostavljeni.</B>
<BR><B>Napomena: '+@p_podjetje+' zadržava pravo slanja računa poštom uslijed nepredviđenih događaja.</B>
</P>
<P>
Ukoliko imate pitanja, molimo pošaljete svoj upit na otpleasing@otpleasing.hr.
</P>
<BR>S poštovanjem,
<BR>Vaš '+@p_podjetje+
'<BR>' + @p_mail

------------------------------------------------------
declare @rootPathEdocMain varchar(100), @rootPathEdocAdd varchar(100)
set @rootPathEdocMain = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_MAIN')
set @rootPathEdocAdd = (Select channel_path From dbo.io_channels where channel_code = 'EDOC_ADD')


select 
   cast(a.id as varchar(10)) as doc_id, 
   @p_mail as [from],
   d.mail_to as [to],
   '' as [cc],
   'Automatski ispis računa_'+
	CASE WHEN g.source = 'NAJEM_FA' and g.id_terj = '21' THEN '1321'
	WHEN g.source = 'ZOBR_FA' THEN '1322'
	WHEN g.source = 'TEC_RAZL' THEN '1323'
	WHEN g.source = 'AVANSI' THEN '1324'
	when g.source = 'NAJEM_FA' and g.id_terj = '04' then '1325' 
	when g.source = 'NAJEM_FA' and g.id_terj = '20' then '1326'
	when g.source = 'FAKTURE' then '1327'
	when g.source = 'NAJEM_FA' and g.id_terj = '59' then '1328' 
	when g.source = 'NAJEM_FA' and g.id_terj = '03' then '1329'
	when g.source = 'ZA_OPOM' and g.opom_ddv_id is not null and g.opom_st_opomina = 1 then '1330'
	when g.source = 'ZA_OPOM' and g.opom_ddv_id is not null and g.opom_st_opomina = 2 then '1331'
	when g.source = 'ZA_OPOM' and g.opom_ddv_id is not null and g.opom_st_opomina = 3 then '1332'
	when g.source = 'DOK_OPOM' and g.dok_ddv_id is not null and g.dok_st_opomin = 1 then '1338'
	when g.source = 'DOK_OPOM' and g.dok_ddv_id is not null and g.dok_st_opomin = 2 then '1344'
	when g.source = 'DOK_OPOM' and g.dok_ddv_id is not null and g.dok_st_opomin = 3 then '1345'
	WHEN g.source = 'OPC_FAKT' THEN '1341'
	WHEN g.source = 'POGODBA' THEN '1343'
	WHEN g.source = 'SPR_DDV' THEN '1342'
	when g.source = 'ZBIRNA_FAKTURA' then '1347'
	ELSE '' END
   as [subject],
   @body_text as [body],
   cast(1 as bit) as [has_attachment],
   cast(1 as bit) as [is_html],
   cast(0 as bit) as [send_immediately],
   d.id_kupca as id_kupca
into #temp3
from dbo.edoc_exported_files a
inner join (Select id_kupca, max(email) as mail_to
			From dbo.p_kontakt
			Where id_vloga = '01'
			Group by id_kupca) d on a.id_kupca = d.id_kupca
left join (Select a.id, a.document_id, dbo.gfn_GetInvoiceSource(coalesce(z.ddv_id, a.document_id)) as source, c.id_terj, opom.ddv_id as opom_ddv_id, opom.st_opomina as opom_st_opomina, dok_opom.st_opomin as dok_st_opomin, dok_opom.ddv_id as dok_ddv_id
		   From dbo.edoc_exported_files a  
		   left join dbo.rac_out b on a.document_id = b.ddv_id
		   left join dbo.najem_fa c on b.ddv_id = c.ddv_id 
		   left join dbo.gv_za_opom_with_arh opom on b.ddv_id = opom.ddv_id
		   left join (select ddv_id, st_opomin 
					from dbo.dok_opom 
					where ddv_id in (select document_id from dbo.edoc_exported_files where id in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1))
					union
					select ddv_id, st_opomin 
					from dbo.arh_dok_opom 
					where ddv_id in (select document_id from dbo.edoc_exported_files where id in  (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1))
					) dok_opom on b.ddv_id = dok_opom.ddv_id 
			left join dbo.zbirniki z on a.id_edoc_doctype = 'InvoiceCum' and a.document_id = cast(z.id_zbirnik as varchar(30)) -- ne postoji izravna veza između edoc_exported_files i rac_out za InvoiceCum 
		where cast(a.id as varchar(30)) in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
			) g on a.id = g.id 
where cast(a.id as varchar(30)) in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
Order by a.id_kupca

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
exec dbo.gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'E-mail','INTERNAL','XDOC', 'eDoc to eMail exporter - Samo mail (01) - SQL export','3',@xml
drop table #tempVrste

--first table
select  doc_id, [from], [to], [cc], [subject],
		[body], [has_attachment], [is_html], [send_immediately] 
		from #temp3


--second table
--impossible condition to get the second table empty
select 
       cast(a.id as char(30)) as doc_id,
       'Dummy' as [report_name],
       '-1' as [report_id],
       'PDF' as [rendering_format],
       'Dummy' as [attachment_name]
from dbo.edoc_exported_files a
where a.id = -1
 
--third table
select cast(a.id as varchar(10)) as doc_id, @rootPathEdocMain + a.file_name as file_path, 'Attachment' as attachment_name
into #attach
from dbo.edoc_exported_files a
where cast(a.id as char(30)) 
in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
Order by a.id_kupca

if exists(Select * from general_register where id_register='DODATNI_ATTACHMENT' and neaktiven = 0)
begin
	insert into #attach(doc_id, file_path, attachment_name)
	select cast(a.id as varchar(10)) as doc_id, @rootPathEdocAdd + rtrim(g.id_key) as file_path, 'Dopis' as attachment_name
	from dbo.edoc_exported_files a
	left join dbo.general_register g on g.id_register='DODATNI_ATTACHMENT' and g.neaktiven = 0
	where cast(a.id as char(30)) 
	in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
	And (g.id_key is not null and g.id_key <> '')
	And 1 = (Case when g.value is null or g.value = '' or a.id_kupca is null or a.id_kupca = '' then 1 Else Case When charindex(a.id_kupca, rtrim(g.value)) <> 0 then 1 else 0 end end)
    Order by a.id_kupca
end

Select * from #attach

drop table #attach
drop table #temp3


