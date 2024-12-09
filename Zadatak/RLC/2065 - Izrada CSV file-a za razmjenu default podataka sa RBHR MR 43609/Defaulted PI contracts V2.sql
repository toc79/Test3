-- 23.01.2020 g_tomislav 43609

declare @session_id varchar(40)
set @session_id = {@session_id}

DECLARE @EFFECTIVE_DATE varchar (10) = dbo.gfn_ConvertDate(getdate(), 9)

--first table settings
SELECT 'AAA_DEF_TRUE_PI_'+LEFT(@EFFECTIVE_DATE, 2)+'_'+SUBSTRING(@EFFECTIVE_DATE, 4, 2)+'.csv' AS file_name,
'false' AS append,
';' AS delimiter,
--'string_double_quot_mark' AS string_format,
'format_dd_mm_yyyy' AS datetime_format,
'fstrategy_tsql' AS decimal_format,
'true' AS is_header 
FROM dbo.nastavit

DECLARE @asset_class_id char(2) = '01'

SELECT @EFFECTIVE_DATE AS EFFECTIVE_DATE
	, p.ext_id AS COCUNUT_ID
	, p.dav_stev AS REGISTRATION_NUMBER 
	, de.ID_KUPCA AS CUST_ID
	, u.id_pog AS ACC_ID
	, @asset_class_id AS ASSET_CLASS_ID 
	, 'TRUE' AS DEFAULT_STATUS
	, de.def_start_date AS DEFAULT_START_DATE  
	, eba.EBA_DPD 
	, CASE u.status_akt 
		WHEN 'A' THEN 'ACTIVE' 
		WHEN 'Z' THEN 'CLOSED'
	END	AS ACC_STATUS
FROM dbo.default_events de
INNER JOIN dbo.partner p ON de.id_kupca = p.id_kupca
--LEFT JOIN dbo.gv_PEval_LastEvaluation_ByType e ON de.ID_KUPCA = e.id_kupca 
LEFT JOIN dbo.POGODBA u ON de.id_kupca = u.id_kupca
OUTER APPLY (SELECT id_kupca, MAX(CASE WHEN ISNULL(prepare_end, 0) = 0 AND def_end_date IS NULL
					THEN DATEDIFF(dd, def_start_date, dbo.gfn_GetDatePart(GETDATE())) 
					ELSE 0 END) AS EBA_DPD -- active_days
			FROM dbo.default_events 
			WHERE id_d_event = 'EBAD' 
			AND id_kupca = de.id_kupca
			GROUP BY id_kupca ) eba
WHERE de.id_d_event = 'MAST' 
AND de.def_end_date IS NULL -- samo aktivni događaji
AND (u.status_akt = 'A' OR u.STATUS_AKT = 'Z' AND de.def_start_date <= u.dat_zakl)
--AND e.eval_type = 'E' 
--AND LEFT(e.eval_model, 2) = '01'
AND EXISTS (select * from dbo.gv_PEval_LastEvaluation_ByType WHERE eval_type = 'E' AND LEFT(eval_model, 2) = @asset_class_id AND ID_KUPCA = de.id_kupca) --radi brže od LEFT JOIN
ORDER BY de.id_kupca, u.id_pog
