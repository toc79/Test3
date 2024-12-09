/*===============================
19.09.2019 g_tomislav MR 43220 - created; 
===============================*/

SELECT cast(val_text as xml) AS val_text_xml
INTO #gv_ods_data_field_tmp 
FROM dbo.gv_ods_data_field a
WHERE EXISTS (SELECT * FROM (
				SELECT val_int, MAX(id_ods_data_document) AS max_id_ods_data_document /*Jedan EXT_ID može imati više instanca id_ods_data_document, uzima se zadnja*/
				FROM dbo.gv_ods_data_field a 
				WHERE field_sys_id = 'INSTANCE_ID' 
				AND document_sys_id ='ZSPNFT_INSTANCE_DATA'
				AND EXISTS (SELECT * FROM dbo.gv_PEval_LastEvaluation_ByType exists_e
							INNER JOIN dbo.partner exists_p ON exists_e.id_kupca = exists_p.id_kupca
							WHERE exists_e.ext_id IS NOT NULL AND exists_e.eval_type = 'Z' AND exists_e.ext_id_type = 'BPM' 
							/* Za sve  AND exists_p.vr_osebe NOT IN ('FO', 'F1') Samo za pravne osobe, dok FO i F1 će se povući iz Nova */
							AND ( EXISTS (select * FROM dbo.pogodba b WHERE b.status_akt = 'A' AND b.id_kupca = exists_p.id_kupca)
								OR 
								  EXISTS (SELECT * FROM dbo.pog_poro c
										WHERE EXISTS (SELECT * FROM dbo.pogodba d WHERE d.status_akt = 'A' AND d.id_cont = c.id_cont)
										AND c.id_poroka = exists_p.id_kupca)
								)
							AND CAST(exists_e.ext_id AS int) = a.val_int
							)
				GROUP BY val_int
			) b  WHERE max_id_ods_data_document = a.id_ods_data_document)
AND field_sys_id = 'instance_xml_data'


/* Svi FO i F1 vrste osoba kao primatelji leasinga i kao jamci aktivnih ugovora koji imaju Z evaluaciju */
SELECT a.id_kupca AS reference, a.naz_kr_kup AS terms, a.id_kupca 
INTO #tempSNP
FROM dbo.partner a 
INNER JOIN dbo.gv_PEval_LastEvaluation_ByType eval_Z ON a.id_kupca = eval_Z.id_kupca
WHERE eval_Z.eval_type = 'Z' 
AND a.vr_osebe in ('FO', 'F1')
AND (	EXISTS (select * FROM dbo.pogodba b WHERE b.status_akt = 'A' AND b.id_kupca = a.id_kupca)
		OR 
		EXISTS (SELECT * FROM dbo.pog_poro c
				WHERE EXISTS (SELECT * FROM dbo.pogodba d WHERE d.status_akt = 'A' AND d.id_cont = c.id_cont)
				AND c.id_poroka = a.id_kupca)
	)

UNION 

SELECT DISTINCT customer_id AS reference, related_fo_manage_desc1 AS terms, related_fo_manage_nova_id1 AS id_kupca
FROM (
	/* 'related_fo_manage_desc_' 2.2 Vlasnička struktura - fizičke osobe 1 - 4 */
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc1"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc1
		, isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_nova_id1"]/@val_str)[1]', 'varchar(1000)'), '') AS related_fo_manage_nova_id1
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	UNION ALL
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc2"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc2
		, isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_nova_id2"]/@val_str)[1]', 'varchar(1000)'), '') AS related_fo_manage_nova_id2
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	UNION ALL
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc3"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc3
		, isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_nova_id3"]/@val_str)[1]', 'varchar(1000)'), '') AS related_fo_manage_nova_id3
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	UNION ALL
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc4"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc4
		, isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_nova_id4"]/@val_str)[1]', 'varchar(1000)'), '') AS related_fo_manage_nova_id4
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)

	UNION ALL

	/* 'management_desc_' 2.3 Uprava društva 1 - 3 */
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="management_desc1"]/@val_str)[1]', 'varchar(1000)'), '') as management_desc1
		, isnull(t.c.value('(DATA_FIELD[@def_name="management_nova_id1"]/@val_str)[1]', 'varchar(1000)'), '') AS management_nova_id1
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	UNION ALL
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="management_desc2"]/@val_str)[1]', 'varchar(1000)'), '') as management_desc2
		, isnull(t.c.value('(DATA_FIELD[@def_name="management_nova_id2"]/@val_str)[1]', 'varchar(1000)'), '') AS management_nova_id2
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	UNION ALL
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="management_desc3"]/@val_str)[1]', 'varchar(1000)'), '') as management_desc3
		, isnull(t.c.value('(DATA_FIELD[@def_name="management_nova_id3"]/@val_str)[1]', 'varchar(1000)'), '') AS management_nova_id3
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	
	UNION ALL

	/* 'procurator_desc_' 2.4 Prokuristi društva 1 - 3 */
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="procurator_desc1"]/@val_str)[1]', 'varchar(1000)'), '') as procurator_desc1
		, isnull(t.c.value('(DATA_FIELD[@def_name="procurator_nova_id1"]/@val_str)[1]', 'varchar(1000)'), '') AS procurator_nova_id1
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	UNION ALL
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="procurator_desc2"]/@val_str)[1]', 'varchar(1000)'), '') as procurator_desc2
		, isnull(t.c.value('(DATA_FIELD[@def_name="procurator_nova_id2"]/@val_str)[1]', 'varchar(1000)'), '') AS procurator_nova_id2
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	UNION ALL
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="procurator_desc3"]/@val_str)[1]', 'varchar(1000)'), '') as procurator_desc3
		, isnull(t.c.value('(DATA_FIELD[@def_name="procurator_nova_id3"]/@val_str)[1]', 'varchar(1000)'), '') AS procurator_nova_id3
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	
	UNION ALL
	
	/* OR def_name = 'assignee_desc' OR def_name LIKE 'assignee_desc_' 4. Zakonski zastupnik/punomoćenik 1 - 2*/
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="assignee_desc"]/@val_str)[1]', 'varchar(1000)'), '') as assignee_desc
		, isnull(t.c.value('(DATA_FIELD[@def_name="assignee_nova_id1"]/@val_str)[1]', 'varchar(1000)'), '') AS assignee_nova_id1
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	UNION ALL
	SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id
		, isnull(t.c.value('(DATA_FIELD[@def_name="assignee_desc2"]/@val_str)[1]', 'varchar(1000)'), '') as assignee_desc2
		, isnull(t.c.value('(DATA_FIELD[@def_name="assignee_nova_id2"]/@val_str)[1]', 'varchar(1000)'), '') AS assignee_nova_id2
	FROM #gv_ods_data_field_tmp a 
	cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)
	) a
WHERE related_fo_manage_desc1 != ''
ORDER BY reference

DROP TABLE #gv_ods_data_field_tmp 

-- GDPR LOGIRANJE
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
		FROM #tempSNP t
		INNER JOIN PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.id_kupca, p.vr_osebe
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();
exec gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Kraći naziv partnera ili njegovih povezanih osoba iz BPMa','INTERNAL','XDOC', 'SPN export osobnih podatka iz Nova i BPMa',39,@xml

drop table #tempVrste
-- KONEC GDPR

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

SELECT reference, terms FROM #tempSNP
DROP TABLE #tempSNP