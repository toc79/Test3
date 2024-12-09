--SQL CANDIDATES 
select cast(dbo.gfn_getdatepart(getdate()) as int) as doc_id

--SQL EXPORT 
-- 02.01.2020 g_tomislav 43609

declare @session_id varchar(40)
set @session_id = {@session_id}

DECLARE @EFFECTIVE_DATE varchar (10) = dbo.gfn_ConvertDate(getdate(), 9)

--first table settings
SELECT 'Defaulted PI contracts '+@EFFECTIVE_DATE+'.csv' AS file_name,
'false' AS append,
';' AS delimiter,
--'string_double_quot_mark' AS string_format,
'format_dd_mm_yyyy' AS datetime_format,
'fstrategy_tsql' AS decimal_format,
'true' AS is_header,
'' AS oldValue
FROM dbo.nastavit


SELECT @EFFECTIVE_DATE AS EFFECTIVE_DATE
	, p.ext_id AS COCUNUT_ID
	, p.dav_stev AS REGISTRATION_NUMBER 
	, de.ID_KUPCA AS CUST_ID
	, u.id_pog AS ACC_ID
	, '01' AS ASSET_CLASS_ID 
	, 'TRUE' AS DEFAULT_STATUS
	, de.def_start_date AS DEFAULT_START_DATE  
	, CASE WHEN ISNULL(de.prepare_end, 0) = 0 AND de.def_end_date IS NULL
		THEN DATEDIFF(dd, de.def_start_date, dbo.gfn_GetDatePart(GETDATE())) 
		ELSE 0 
	END AS EBA_DPD -- active_days
	, CASE u.status_akt 
		WHEN 'A' THEN 'ACTIVE' 
		WHEN 'Z' THEN 'CLOSED'
	END	AS ACC_STATUS
FROM dbo.default_events de
INNER JOIN dbo.partner p ON de.id_kupca = p.id_kupca
--LEFT JOIN dbo.gv_PEval_LastEvaluation_ByType e ON de.ID_KUPCA = e.id_kupca 
LEFT JOIN dbo.POGODBA u ON de.id_kupca = u.id_kupca
WHERE de.id_d_event = 'MAST' 
AND de.def_end_date IS NULL -- samo aktivni događaji
AND u.status_akt IN ('A', 'Z')
--AND e.eval_type = 'E' 
--AND LEFT(e.eval_model, 2) = '01'
AND EXISTS (select * from dbo.gv_PEval_LastEvaluation_ByType WHERE eval_type = 'E' AND LEFT(eval_model, 2) = '01' AND ID_KUPCA = de.id_kupca) --radi brže od LEFT JOIN
ORDER BY de.id_kupca, u.id_pog



--TEST
INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) VALUES('XDOC_WEBEXPO','Export for internet','\\RLENOVA\nova_test_io\WEBEXPO\ ','',1,'','','')
--NEW
--\\Rlenova\nova_test\IO\MAST

select * from dbo.xdoc_template where id_xdoc_template = 39
select * from dbo.io_channels

--UPDATE dbo.xdoc_template SET channel_code = 'XDOC_MAST' where id_xdoc_template = 39

--XDOC_MAST
--\\RLENOVA\nova_test_io\WEBEXPO\

exec dbo.tsp_generate_inserts 'io_channels', 'dbo', 'FALSE', '##inserts', 'where channel_code=''XDOC_WEBEXPO'''
select * from ##inserts
--drop table ##inserts

INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) VALUES('XDOC_MAST','Export to CSV: MAST default events','\\RLENOVA\nova_test_io\MAST\ ','',1,'','XDOC','')

--PROD
\\RLENOVA\nova_prod_io\Invoice_spec\
INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) VALUES('XDOC_MAST','Export to CSV: MAST default events','\\RLENOVA\nova_prod_io\MAST\ ','',1,'','XDOC','')

DECLARE @EFFECTIVE_DATE varchar (10) = dbo.gfn_ConvertDate(getdate(), 9)

SELECT @EFFECTIVE_DATE AS EFFECTIVE_DATE
	, p.ext_id AS COCUNUT_ID
	, p.dav_stev AS REGISTRATION_NUMBER 
	, de.ID_KUPCA AS CUST_ID
	, u.id_pog AS ACC_ID
	, LEFT(e.eval_model, 2) AS ASSET_CLASS_ID 
	, 'TRUE' AS DEFAULT_STATUS
	, de.def_start_date AS DEFAULT_START_DATE  
	, CASE WHEN ISNULL(de.prepare_end, 0) = 0 AND de.def_end_date IS NULL
		THEN DATEDIFF(dd, de.def_start_date, dbo.gfn_GetDatePart(GETDATE())) 
		ELSE 0 
	END AS EBA_DPD -- active_days
	, CASE u.status_akt 
		WHEN 'A' THEN 'ACTIVE' 
		WHEN 'Z' THEN 'CLOSED'
	END	AS ACC_STATUS
	--, de.* 
FROM dbo.default_events de
INNER JOIN dbo.partner p ON de.id_kupca = p.id_kupca
LEFT JOIN dbo.gv_PEval_LastEvaluation_ByType e ON de.ID_KUPCA = e.id_kupca AND e.eval_type = 'E'
LEFT JOIN dbo.POGODBA u ON de.id_kupca = u.id_kupca
WHERE de.id_d_event = 'MAST' 
AND de.def_end_date IS NULL -- samo aktivni događaji
AND u.status_akt IN ('A', 'Z')
ORDER BY de.id_kupca, u.id_pog



declare @session_id varchar(40)

set @session_id = {@session_id}

SELECT  dav_stev as OIB, id_kupca 
INTO #TempNautilusShow 
FROM dbo.partner
WHERE id_kupca in (SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)


--first table settings
select 'Nautilus.csv' as file_name,
'false' as append,
',' as delimiter,
--'string_double_quot_mark' as string_format,
'format_dd_mm_yyyy' as datetime_format,
'fstrategy_tsql' as decimal_format,
--'true' as is_header,
'' as oldValue
from nastavit

select  OIB  from #TempNautilusShow group by OIB
drop table #TempNautilusShow


--first table settings
SELECT 'Input_file.csv' AS file_name,
'false' AS append,
';' AS delimiter,
--'string_double_quot_mark' AS string_format,
'format_dd_mm_yyyy' AS datetime_format,
'fstrategy_tsql' AS decimal_format,
'true' AS is_header,
'' AS oldValue
FROM dbo.nastavit