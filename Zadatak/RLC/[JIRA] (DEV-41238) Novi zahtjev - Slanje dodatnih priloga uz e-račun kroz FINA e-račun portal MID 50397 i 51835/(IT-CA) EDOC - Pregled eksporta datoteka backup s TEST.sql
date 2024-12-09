-- PROMJENITI ID IZVOZA PODATAKA XDOC na produkciji

--08.07.2022 g_vuradin MR49157 - dodavanje BPM scoring view
--03.04.2023 g_vuradin -dodavanje email
--01.12.2023 g_tomislav MID 50397 i 50697 - dorada logike za kolonu email. Optimizacija #main i #final 
--25.01.2024 g_igorp MR51943 podrška za OBV_ISTEK_SSOFT_RLC
--01.02.2024 g_tomislav MR 52115 - popravak ID izvoza podataka na produkciji


DECLARE @export_id varchar(100)
SET @export_id = {1}

select * 
    , case when id_edoc_doctype = 'Invoice' Then dbo.gfn_GetInvoiceSource(document_id) else null end as izvor_racuna
into #main
from (
    select id_file, doc_date_prepared as date_prepared, doc_document_id as document_id, doc_id_edoc_doctype as id_edoc_doctype, doc_id_kupca as id_kupca, id_reports_log, id_report, id_edoc_channel, convert(int, iif(was_ignored = 0, 1, 0)) as exported_to_channel
    from dbo.gv_edoc_exported_files_channels eefc
    where doc_export_id = @export_id
	--where doc_date_prepared >='20230301' za testiranje
    ) as SourceTable
pivot 
    (
    sum(exported_to_channel)
    for id_edoc_channel in ([EDOC_EX1], [EDOC_EX2], [EDOC_EX3], [EDOC_EX4], [EDOC_EX5], [EDOC_EX6], [EDOC_EXPORT_FINA]) --, [EDOC_EX5], [EDOC_EX6] bi se možda mogli isključiti jer za tu statistiku se uzimaju podaci iz xdoc_document
    ) as PivotTable

Select a.*,
    CASE 	-- moglo bi se maknuti id_edoc_doctype za uvjete gdje se gleda/provjerava id_report, Invoice treba detaljnije provjeriti
			-- svugdje gdje je pojedini ispis bi se moglo prikazati naziv reporta print_selection.rep_name što je velika većina
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(a.id_report)) = 'VARSCINA_SSOFT_RLC' THEN 'Jamčevina'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(a.id_report)) = 'OBVREG_SSOFT' THEN 'Dopis za registraciju'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(a.id_report)) = 'OBV_O1_SSOFT_RLC' THEN 'Obavijest o neplaćenim potraživanjima'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(a.id_report)) = 'OBV_OPC_SSOFT_RLC' THEN 'Obavijest za otkup'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(a.id_report)) = 'KU_DNEV_SSOFT_RLC' THEN 'Dnevnik kupaca LSK'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(a.id_report)) = 'GL_K_DNEV_SSOFT_RLC' THEN 'Dnevnik GK'
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(a.id_report)) = 'OTHER2GK_SSOFT_RLC' THEN 'Dnevnik prijenosa iz FA'	
	    WHEN a.id_edoc_doctype = 'General' AND LTRIM(RTRIM(a.id_report)) = 'BPM_SCORING_VIEW' THEN 'BPM scoring view'
	    WHEN a.id_edoc_doctype = 'Approval' THEN 'Odobrenje financiranja'
	    WHEN a.id_edoc_doctype = 'Notif' THEN 'Obavijest za ratu'
	    WHEN a.id_edoc_doctype = 'TaxChngIx' THEN 'Obavijest o promjeni indeksa'
	    WHEN a.id_edoc_doctype = 'InvoiceCum' THEN 'Zbirni računi za rate'
	    WHEN a.id_edoc_doctype = 'Reminder' THEN 'Opomene po ugovoru bez troška'
	    WHEN a.id_edoc_doctype = 'RmndrDoc' THEN 'Opomene za dokumentaciju bez troška'
	    WHEN a.id_edoc_doctype = 'GuarRemind' AND LTRIM(RTRIM(a.id_report)) = 'OPOMJAM_SSOFT_RLC' THEN 'Obavijest dodatnim jamcima o opomeni'
	    WHEN a.id_edoc_doctype = 'GuarRemind' AND LTRIM(RTRIM(a.id_report)) = 'OBV_POR_SSOFT_RLC' THEN 'Obavijest jamcu o opomeni'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(a.id_report)) = 'NAL_PL_SSOFT_RLC' THEN 'Nalog za plaćanje'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(a.id_report)) = 'PLANP_SSOFT_RLC' THEN 'Plan otplate'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(a.id_report)) = 'PROM_OTPL_FL_SSOFT_RLC' THEN 'Dopis o promj. sadr. otpl. tablice FL'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(a.id_report)) = 'PROM_OTPL_OL1_SSOFT_RLC' THEN 'Obavijest o izmjeni visine obroka OL'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(a.id_report)) = 'ZAH_UK_REG_SSOFT_RLC' THEN 'Zahtjev za ukidanjem registracije'
	    WHEN a.id_edoc_doctype = 'Contract' AND LTRIM(RTRIM(a.id_report)) = 'OBV_ISTEK_SSOFT_RLC' THEN 'Obavijest o isteku FL 6.mj'
		--WHEN a.id_edoc_doctype = 'Invoice' 
		--THEN CASE 
		WHEN a.izvor_racuna = 'NAJEM_FA' and c.sif_terj = 'LOBR' THEN 'Računi za rate' 
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
		ELSE isnull(ltrim(rtrim(ps.rep_name)), 'Report nema opciju ispisivanja: ') +' ' + ltrim(rtrim(a.id_report)) +' ' +a.id_edoc_doctype --XXXX
	  END AS tip,
    CASE WHEN pk.id_kupca IS NOT NULL THEN 1 ELSE 0 END AS xw_racun
	, convert(int, case when xdd_OBV_IND.doc_id is not null and a.EDOC_EX5 > 0 then 1 else 0 end) as email_OBV_IND
    , convert(int, case when xdd_LOBR.doc_id is not null and a.EDOC_EX6 > 0 then 1 else 0 end) as email_LOBR
	, convert(int, case when fina_rep_ind.id_rep_ind is not null then 1 else 0 end) as fina_rep_ind
	--, convert(int, case when par.ident_stevilka is not null and par.ident_stevilka <> '' then 1 else 0 end) as fina_partner 
INTO #final
From #main a
left join dbo.najem_fa b on a.document_id = b.ddv_id And a.id_edoc_doctype = 'Invoice' And a.izvor_racuna = 'NAJEM_FA' --nije potrebno ili ipak je potrebno zbog id_terj ili je mogao biti jedan LEFT JOIN na PLANP jer su tamo sva potraživanja osima ako su stornirana Ako se stornom brišu zapisi i u najem_fa, onda se može promjeniti/zakomentirati
left join dbo.vrst_ter c on b.id_terj = c.id_terj
left join dbo.planp n on a.document_id = n.ddv_id and a.id_edoc_doctype = 'Invoice' And a.izvor_racuna = 'PLANP'
left join dbo.vrst_ter d on n.id_terj = d.id_terj 
left join dbo.fakture fak on a.document_id = fak.ddv_id
left join dbo.p_kontakt pk on b.id_kupca = pk.id_kupca And c.sif_terj = 'LOBR' And pk.id_vloga = 'XW' And pk.dat_vnosa <= a.date_prepared
outer apply (select top 1 rep_name from dbo.print_selection where rep_key = a.id_report) ps
--left join dbo.partner par on par.id_kupca = a.id_kupca 
left join dbo.xdoc_document xdd_OBV_IND on a.id_file = xdd_OBV_IND.doc_id and xdd_OBV_IND.id_xdoc_template = 54 and xdd_OBV_IND.date_exported >= a.date_prepared
left join dbo.xdoc_document xdd_LOBR on a.id_file = xdd_LOBR.doc_id and xdd_LOBR.id_xdoc_template = 57 and xdd_LOBR.date_exported >= a.date_prepared
outer apply ( -- obavijesti s DDV_ID u napomeni (ne provjerava se za sada FINA ID (ident_stevilka))
			select id_rep_ind  
			from dbo.rep_ind ri 
			--inner join #main m on m.izvor_racuna = 'NAJEM_FA' and charindex(m.document_id, ri.opombe) > 0 -- ili najem_fa ili edoc_exported_files
			inner join dbo.edoc_exported_files eef on eef.id_edoc_doctype = 'Invoice' and left(ri.opombe, 11) = eef.document_id --charindex(eef.document_id, ri.opombe) > 0 -- traje otprilike 9 puta duže 
			where a.id_edoc_doctype = 'TaxChngIx'
			and ri.id_rep_ind = try_convert(int, a.document_id)
	) fina_rep_ind

select tip, count(*) as broj
    , sum(EDOC_EX1) as dms
	, sum(EDOC_EX2) as pc
	, sum(EDOC_EX3) as ne_pc
	, sum(EDOC_EX4) as web
	, sum(xw_racun) as xw_racun
	, sum(EDOC_EXPORT_FINA) + sum(fina_rep_ind) as fina
	--, sum(EDOC_EX5) as email
	, sum(email_OBV_IND) + sum(email_LOBR) as email
	, sum(email_OBV_IND) as email_OBV_IND
	, sum(email_LOBR) as email_LOBR
	, sum(fina_rep_ind) as fina_rep_ind
	--, sum(fina_partner) as fina_partner
from #final
group by tip
order by tip

drop table #main
drop table #final