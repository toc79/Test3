-- 03.01.2020 g_tomislav 43609

declare @session_id varchar(40)
set @session_id = {@session_id}

DECLARE @EFFECTIVE_DATE varchar (10) = dbo.gfn_ConvertDate(getdate(), 9)

--first table settings
SELECT 'AAA_DEF_TRUE_MI_'+LEFT(@EFFECTIVE_DATE, 2)+'_'+SUBSTRING(@EFFECTIVE_DATE, 4, 2)+'.csv' AS file_name,
'false' AS append,
';' AS delimiter,
--'string_double_quot_mark' AS string_format,
'format_dd_mm_yyyy' AS datetime_format,
'fstrategy_tsql' AS decimal_format,
'true' AS is_header 
FROM dbo.nastavit


SELECT @EFFECTIVE_DATE AS EFFECTIVE_DATE
	, p.ext_id AS COCUNUT_ID
	, p.dav_stev AS REGISTRATION_NUMBER 
	, de.ID_KUPCA AS CUST_ID
	, u.id_pog AS ACC_ID
	, LEFT(e.eval_model, 2) AS ASSET_CLASS_ID 
	, 'FALSE' AS DEFAULT_STATUS
	, de.def_start_date AS DEFAULT_START_DATE 
	, de.def_end_date AS DEFAULT_END_DATE
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
INNER JOIN dbo.gv_PEval_LastEvaluation_ByType e ON de.ID_KUPCA = e.id_kupca 
LEFT JOIN dbo.POGODBA u ON de.id_kupca = u.id_kupca
WHERE de.id_d_event = 'MAST' 
AND de.def_end_date IS NOT NULL -- samo zaključene
AND u.status_akt IN ('A', 'Z')
AND e.eval_type = 'E' 
AND LEFT(e.eval_model, 2) IN ('01', '20')
AND DATEDIFF(dd, de.def_end_date, dbo.gfn_GetDatePart(GETDATE())) <= 30 --koji su izašli iz defaulta u zadnjih 30 dana od effective_date-a (kojima je DEFAULT_END_DATE mlađi od 30 dana)
ORDER BY de.id_kupca, u.id_pog
