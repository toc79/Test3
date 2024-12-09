-- Selecti za dobivanje kandidata
--select top 100 * from dbo.reports_log where id_report = 'OBV_ISTEK_SSOFT_RLC' order by 1 desc
--select top 100 * from dbo.EDOC_EXPORTED_FILES order by 1 desc

-- Popunjavanje kandidata varijabli - dovoljno je popuniti jednu varijablu koja nam odgovara
declare @id_reports_log_candidate int --= 2802435
declare @id_object_candidate varchar(40) = '20230021298' --id s kojim se pokreće report najčešće ddv_id ili id_cont
declare @id_eef_candidate int --= 1472405

-- Sistemske varijable
-- SET @id = {0}
-- string sql_header_template = @"
declare @Id varchar(100); --set @Id = {0} ;
declare @DocType varchar(100); --set @DocType = {1} ;
declare @ReportName varchar(100); --set @ReportName = {2} ;
declare @Barcode varchar(200); --set @Barcode = {3} ;
declare @BarcodeSubtype varchar(200); --set @BarcodeSubtype = {5} ;
declare @OriginalFileName varchar(200);-- set @OriginalFileName = {4} ;

SELECT rl.id_object_edoc as id, rl.doc_type AS doctype, edoc_file_name AS original_file_name, rl.barcode, eef.subtype_code AS barcode_subtype, rl.id_report AS report_name 
	, rl.*, eef.*
FROM dbo.REPORTS_LOG rl
left join dbo.EDOC_EXPORTED_FILES eef ON rl.doc_type = eef.id_edoc_doctype and rl.id_reports_log = eef.id_reports_log --and rl.id_object = eef.document_id
WHERE 1=1 
and (@id_reports_log_candidate is not null and rl.id_reports_log = @id_reports_log_candidate -- is not null je dodan radi brzine izvršavanja
	or @id_object_candidate is not null and rl.id_object = @id_object_candidate
	or @id_eef_candidate is not null and eef.id = @id_eef_candidate)

SELECT TOP 1 @id = rl.id_object_edoc, @DocType = rl.doc_type, @OriginalFileName = rl.edoc_file_name, @Barcode = rl.barcode, @BarcodeSubtype = eef.subtype_code, @ReportName = rl.id_report
FROM dbo.REPORTS_LOG rl
left join dbo.EDOC_EXPORTED_FILES eef ON rl.doc_type = eef.id_edoc_doctype and rl.id_object_edoc = eef.document_id --rl.id_reports_log = eef.id_reports_log
WHERE 1=1 
and (@id_reports_log_candidate is not null and rl.id_reports_log = @id_reports_log_candidate -- is not null je dodan radi brzine izvršavanja
	or @id_object_candidate is not null and rl.id_object = @id_object_candidate
	or @id_eef_candidate is not null and eef.id = @id_eef_candidate)
/*
Nema podatka id_reports_log pa veza između reports_log i edoc_exported_files ide ili po svim zajedničkim kolonama ili po @OriginalFileName, a ovo potonje @OriginalFileName je po meni dovoljno (na koj koloni postoji INDEKS)
*/