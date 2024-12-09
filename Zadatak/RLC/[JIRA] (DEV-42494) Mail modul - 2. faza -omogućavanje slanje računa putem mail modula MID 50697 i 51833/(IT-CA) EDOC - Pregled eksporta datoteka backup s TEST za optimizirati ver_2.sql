--08.07.2022 g_vuradin MR49157 - dodavanje BPM scoring view
--03.04.2023 g_vuradin -dodavanje email
--27.11.2023 g_tomislav - dorada logike za kolonu email. Optimizacija selecta

--KREIRATI NOVI IZVJEŠTAJ I NA NJEMU NAPRAVITI DORADE I OPTIMIZIRATI
--gv_edoc_exported_files_channels

--za kolonu E-MAIL - veza između edoc_exported_files i xdoc_document 
--jako mala vjerojatnost je da postoje dva ista DOC_ID-a tj. da je jedan DOC_ID poslan na mail dva puta => tako da ćemo uzimati sve podatke (možda bi se moglo i i to razlučiti ali na prvu to je kompliciranije za izvesti pa to neću dorađivati)
select top 20 * 
from dbo.edoc_exported_files eef
inner join dbo.xdoc_document xdd on eef.id = xdd.doc_id
where xdd.id_xdoc_template = 57
order by id desc

DECLARE @export_id varchar(100)
SET @export_id = {1}

-- Select b.id_file, sum(case when b.id_edoc_channel = 'EDOC_EX1' and was_ignored = 0 THEN 1 ELSE 0 END) as DMS,
-- sum(case when b.id_edoc_channel = 'EDOC_EX2' and was_ignored = 0 THEN 1 ELSE 0 END) AS PC,
-- sum(case when b.id_edoc_channel = 'EDOC_EX3' and was_ignored = 0 THEN 1 ELSE 0 END) AS NE_PC,
-- sum(case when b.id_edoc_channel = 'EDOC_EX4' and was_ignored = 0 THEN 1 ELSE 0 END) AS WEB,
-- sum(case when b.id_edoc_channel = 'EDOC_EX5' and was_ignored = 0 THEN 1 ELSE 0 END) AS EMAIL,
-- sum(case when b.id_edoc_channel = 'EDOC_EXPORT_FINA' and was_ignored = 0 THEN 1 ELSE 0 END) AS FINA
-- into #datoteke
-- From dbo.edoc_exported_files_channels b
-- where b.id_file in (Select id From dbo.edoc_exported_files a Where a.export_id = @export_id)
-- Group by b.id_file

-- select convert(varchar(30), dbo.gfn_GetDatePart(date_prepared), 104) as date_prepared, export_id, COUNT(*) as rows from dbo.EDOC_EXPORTED_FILES group by dbo.gfn_GetDatePart(date_prepared), export_id order by 1 desc

--select id_file, doc_date_prepared as date_prepared, doc_document_id as document_id, doc_id_edoc_doctype as id_edoc_doctype, doc_id_kupca as id_kupca, id_reports_log, id_edoc_channel, was_ignored
--    --, *
--into #candidates
--from dbo.gv_edoc_exported_files_channels eefc
--where doc_export_id = 'F5EC7977-CFDD-4CE7-9BEB-7ADD67FFA6D2'
----and eefc.was_ignored = 0
----group by eefc.id_file, eefc.id_edoc_channel 


DECLARE @export_id varchar(100)
SET @export_id = 'F5EC7977-CFDD-4CE7-9BEB-7ADD67FFA6D2'

select * 
    , case when id_edoc_doctype = 'Invoice' Then dbo.gfn_GetInvoiceSource(document_id) else null end as izvor_racuna
into #main
from (
    select id_file, doc_date_prepared as date_prepared, doc_document_id as document_id, doc_id_edoc_doctype as id_edoc_doctype, doc_id_kupca as id_kupca, id_reports_log, id_edoc_channel, convert(int, was_ignored) as was_ignored
    from dbo.gv_edoc_exported_files_channels eefc
    where doc_export_id = @export_id
    ) as SourceTable
pivot 
    (
    sum(was_ignored)
    --for id_edoc_channel in ([EDOC_EX1], [EDOC_EX2], [EDOC_EX3], [EDOC_EX4], [EDOC_EX5], [EDOC_EXPORT_FINA]) 
    for id_edoc_channel in ([EDOC_ARH], [EDOC_EXPORT_FINA]) 
    ) as PivotTable

Select a.*,
    CASE 
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(rl.id_report)) = 'VARSCINA_SSOFT_RLC' THEN 'Jamčevina'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(rl.id_report)) = 'OBVREG_SSOFT' THEN 'Dopis za registraciju'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(rl.id_report)) = 'OBV_O1_SSOFT_RLC' THEN 'Obavijest o neplaćenim potraživanjima'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(rl.id_report)) = 'OBV_OPC_SSOFT_RLC' THEN 'Obavijest za otkup'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(rl.id_report)) = 'KU_DNEV_SSOFT_RLC' THEN 'Dnevnik kupaca LSK'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(rl.id_report)) = 'GL_K_DNEV_SSOFT_RLC' THEN 'Dnevmnik GK'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(rl.id_report)) = 'OTHER2GK_SSOFT_RLC' THEN 'Dnevnik prijenosa iz FA'	
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(rl.id_report)) = 'BPM_SCORING_VIEW' THEN 'BPM scoring view'
	    WHEN a.id_edoc_doctype = 'Notif' THEN 'Obavijest za ratu'
	    WHEN a.id_edoc_doctype = 'TaxChngIx' THEN 'Obavijest o promjeni indeksa'
	    WHEN a.id_edoc_doctype = 'InvoiceCum' THEN 'Zbirni računi za rate'
	    WHEN a.id_edoc_doctype = 'Reminder' THEN 'Opomene po ugovoru bez troška'
	    WHEN a.id_edoc_doctype = 'RmndrDoc' THEN 'Opomene za dokumentaciju bez troška'
	    WHEN a.id_edoc_doctype = 'GuarRemind' AND LTRIM(RTRIM(rl.id_report)) = 'OPOMJAM_SSOFT_RLC' THEN 'Obavijest dodatnim jamcima o opomeni'
	    WHEN a.id_edoc_doctype = 'GuarRemind' AND LTRIM(RTRIM(rl.id_report)) = 'OBV_POR_SSOFT_RLC' THEN 'Obavijest jamcu o opomeni'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(rl.id_report)) = 'NAL_PL_SSOFT_RLC' THEN 'Nalog za plaćanje'
	    WHEN a.id_edoc_doctype = 'Approval' THEN 'Odobrenje financiranja'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(rl.id_report)) = 'PLANP_SSOFT_RLC' THEN 'Plan otplate'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(rl.id_report)) = 'PROM_OTPL_FL_SSOFT_RLC' THEN 'Dopis o promj. sadr. otpl. tablice FL'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(rl.id_report)) = 'PROM_OTPL_OL1_SSOFT_RLC' THEN 'Obavijest o izmjeni visine obroka OL'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(rl.id_report)) = 'ZAH_UK_REG_SSOFT_RLC' THEN 'Zahtjev za ukidanjem registracije'
	    ELSE  --Invoice
		    CASE WHEN a.izvor_racuna = 'NAJEM_FA' and c.sif_terj = 'LOBR' THEN 'Računi za rate' 
		    WHEN a.izvor_racuna = 'NAJEM_FA' and c.sif_terj = 'MSTR' THEN 'Troškovi obrade' 
		    WHEN a.izvor_racuna = 'NAJEM_FA' and c.sif_terj = 'POLO' THEN 'Posebna najamnina'
		    WHEN a.izvor_racuna = 'NAJEM_FA' and c.sif_terj = 'SFIN' THEN 'Interkalarne' 
		    WHEN a.izvor_racuna = 'NAJEM_FA' and c.sif_terj = 'REG' THEN 'Registracije' 
		    WHEN a.izvor_racuna = 'ZOBR_FA' THEN 'Zatezne'
		    WHEN a.izvor_racuna = 'AVANSI' THEN 'Predujmovi'
		    WHEN a.izvor_racuna = 'TEC_RAZL' THEN 'Tečajne'
		    WHEN a.izvor_racuna = 'PLANP' and d.sif_terj = 'MSTR' THEN 'Troškovi obrade'
		    WHEN a.izvor_racuna = 'PLANP' and d.sif_terj = 'POLO' THEN 'Posebna najamnina'
		    WHEN a.izvor_racuna = 'PLANP' and d.sif_terj = 'VARS' THEN 'Jamčevina'
		    WHEN a.izvor_racuna = 'FAKTURE' and fak.id_terj in ('1I','1J') THEN 'Računi za kazne'
		    WHEN a.izvor_racuna = 'FAKTURE' and fak.id_terj = '13' THEN 'Porez na motorna vozila'
		    WHEN a.izvor_racuna = 'FAKTURE' and fak.id_terj not in ('1I','1J','13') THEN 'Opći računi'
		    WHEN a.izvor_racuna = 'SPR_DDV' THEN 'Promjena porezne osnovice'
		    WHEN a.izvor_racuna = 'POGODBA' THEN 'Računi za financijski leasing'
		    WHEN a.izvor_racuna = 'OPC_FAKT' THEN 'Račun za otkup'
		    WHEN a.izvor_racuna = 'GL_OUTPUT_R' THEN 'Račun iz GK'
		    WHEN a.izvor_racuna = 'ZA_OPOM' /*and opom.ddv_id is not null*/ THEN 'Opomene po ugovoru'
		    WHEN a.izvor_racuna = 'DOK_OPOM' /*and dok_opom.ddv_id is not null*/ THEN 'Opomene za dokumentaciju'
		    ELSE 'XXXX' END 
    END AS tip,
    CASE WHEN pk.id_kupca IS NOT NULL THEN 1 ELSE 0 END AS xw_racun
INTO #final
From #main a
left join dbo.najem_fa b on a.document_id = b.ddv_id And a.id_edoc_doctype = 'Invoice' And a.izvor_racuna = 'NAJEM_FA' --NIJE POTREBNO ?? ili ipak je potrebno zbog id_terj ili je mogao biti jedan LEFT JOIN na PLANP jer su tamo sva potraživanja osima ako su stornirana Ako se stornom brišu zapisi i u najem_fa, onda se može promjeniti/zakomentirati
left join dbo.vrst_ter c on b.id_terj = c.id_terj
left join dbo.planp n on a.document_id = n.ddv_id and a.id_edoc_doctype = 'Invoice' And a.izvor_racuna = 'PLANP'
left join dbo.vrst_ter d on n.id_terj = d.id_terj 
left join dbo.fakture fak on a.document_id = fak.ddv_id
left join dbo.p_kontakt pk on b.id_kupca = pk.id_kupca And c.sif_terj = 'LOBR' And pk.id_vloga = 'XW' And pk.dat_vnosa <= a.date_prepared
left join dbo.reports_log rl on a.id_reports_log = rl.id_reports_log

--Provjera podataka 
--Select * From #final Where tip = 'XXXX'

Select tip, count(*) as broj
    --, sum(dms) as dms, sum(pc) as pc, sum(ne_pc) as ne_pc, sum(web) as web,sum(email) as email, sum(xw_racun) as xw_racun, sum(fina) as fina
    , sum([EDOC_ARH]) as arh, sum([EDOC_EXPORT_FINA]) as fina
From #final
Group by tip

--drop table #datoteke
drop table #main
drop table #final