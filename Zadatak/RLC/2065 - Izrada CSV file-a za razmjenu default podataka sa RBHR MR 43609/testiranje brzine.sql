DECLARE @EFFECTIVE_DATE varchar (10) = dbo.gfn_ConvertDate(getdate(), 9)

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
LEFT JOIN dbo.gv_PEval_LastEvaluation_ByType e ON de.ID_KUPCA = e.id_kupca 
LEFT JOIN dbo.POGODBA u ON de.id_kupca = u.id_kupca
WHERE de.id_d_event = 'MAST' 
AND de.def_end_date IS NULL -- samo aktivni događaji
AND u.status_akt IN ('A', 'Z')
AND e.eval_type = 'E' 
AND LEFT(e.eval_model, 2) = '01'
ORDER BY de.id_kupca, u.id_pog

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
AND exists (select * from dbo.gv_PEval_LastEvaluation_ByType WHERE eval_type = 'E' AND LEFT(eval_model, 2) = '01' AND ID_KUPCA = de.id_kupca)
ORDER BY de.id_kupca, u.id_pog