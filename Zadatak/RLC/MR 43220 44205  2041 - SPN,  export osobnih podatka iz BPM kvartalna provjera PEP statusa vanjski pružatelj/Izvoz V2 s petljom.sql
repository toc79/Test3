/*===============================
17.09.2019 g_tomislav MR 43220 - created;
===============================*/

CREATE TABLE #OwnershipStructure (NovaNumber CHAR(6), [Owner] VARCHAR(80))

DECLARE @xml as xml, @val_text varchar(max)

SELECT val_text
INTO #gv_ods_data_field_tmp /*Obavezno u # kursor zato što ako se select izvršava unutar DECLARE val_text_cursor CURSOR FOR, tada dolazi do znatno dužeg vremena izvršavanja (par sati)*/
FROM dbo.gv_ods_data_field a
WHERE EXISTS (SELECT * FROM (
				SELECT val_int, MAX(id_ods_data_document) AS max_id_ods_data_document /*Jedan EXT_ID može imati više instanca id_ods_data_document, uzima se zadnja*/
				FROM dbo.gv_ods_data_field a 
				WHERE field_sys_id = 'INSTANCE_ID' 
				AND document_sys_id ='ZSPNFT_INSTANCE_DATA'
				AND EXISTS (SELECT * FROM dbo.gv_PEval_LastEvaluation_ByType exists_e
							INNER JOIN dbo.partner exists_p ON exists_e.id_kupca = exists_p.id_kupca
							WHERE exists_e.ext_id IS NOT NULL AND exists_e.eval_type = 'Z' AND exists_e.ext_id_type = 'BPM' 
							AND exists_p.vr_osebe NOT IN ('FO', 'F1') /*Samo za pravne osobe, dok FO i F1 ću povući iz Nova*/
							AND CAST(exists_e.ext_id AS int) = a.val_int
							)
				GROUP BY val_int
			) b  WHERE max_id_ods_data_document = a.id_ods_data_document)
AND field_sys_id = 'instance_xml_data'

DECLARE val_text_cursor CURSOR FOR 
	SELECT * FROM #gv_ods_data_field_tmp
OPEN val_text_cursor
FETCH NEXT FROM val_text_cursor INTO  @val_text

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @xml = CAST(@val_text as xml)
	
	SELECT * 
	INTO #tabela1
	FROM (
		SELECT t.c.value('@def_name', 'varchar(100)') as def_name,
			/* t.c.value('@val_str', 'varchar(max)') as val_str, */
			COALESCE(t.c.value('@val_str', 'varchar(max)'), t.c.value('@val_text', 'varchar(max)')) as val_str, /*U slučaju teksta dužeg od 500 znakova, sadržaj se zapisuje u @val_text*/
			/* t.c.value('@val_text', 'varchar(max)') as val_text, */
			t.c.value('@is_set', 'bit') as is_set
			/* t.c.value('@def_type', 'varchar(100)') as def_type */
		FROM @xml.nodes('INSTANCE/DATA_FIELDS/DATA_FIELD') t(c)
		) a 
	WHERE is_set = 1 /* For numeric values that can be empty string*/
	AND (def_name = 'customer_id'
		OR def_name LIKE 'related_fo_manage_desc_' --2.2 Vlasnička struktura - fizičke osobe 1 - 4
		OR def_name LIKE 'management_desc_' --2.3 Uprava društva 1 - 3
		OR def_name LIKE 'procurator_desc_' --2.4 Prokuristi društva 1- 3
		OR def_name = 'assignee_desc' OR def_name LIKE 'assignee_desc_' --4. Zakonski zastupnik/punomoćenik 1 - 2
		)
	
	IF EXISTS (SELECT * FROM #tabela1 WHERE	def_name LIKE 'related_fo_manage_desc_' 
											OR def_name LIKE 'management_desc_'
											OR def_name LIKE 'procurator_desc_'
											OR def_name = 'assignee_desc' OR def_name LIKE 'assignee_desc_'
											)
	BEGIN 		
		INSERT INTO #OwnershipStructure (NovaNumber, [Owner]) --, [Share]) 
		SELECT customer_id AS NovaNumber, LEFT(manage_desc, 80) AS [Owner] --, ISNULL(manage_percentage_of_shares, 0) AS [Share]
		-- INTO #OwnershipStructure
		FROM ( 		
			/* 1 FO */
			SELECT p.[customer_id], p.[related_fo_manage_desc1] AS manage_desc --, p.[related_fo_manage_percentage_of_shares1] AS manage_percentage_of_shares
			FROM ( SELECT val_str, def_name	FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [related_fo_manage_desc1]) --, [related_fo_manage_percentage_of_shares1] )
				) AS p  WHERE p.[related_fo_manage_desc1] != '' AND p.[related_fo_manage_desc1] IS NOT NULL
			UNION ALL
			/* 2 FO */
			SELECT p.[customer_id], p.[related_fo_manage_desc2] --, p.[related_fo_manage_percentage_of_shares2]
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [related_fo_manage_desc2]) --, [related_fo_manage_percentage_of_shares2])
				) AS p WHERE p.[related_fo_manage_desc2] != '' AND p.[related_fo_manage_desc2] IS NOT NULL
			UNION ALL
			/* 3 FO */
			SELECT p.[customer_id], p.[related_fo_manage_desc3] --, p.[related_fo_manage_percentage_of_shares3]
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [related_fo_manage_desc3]) --, [related_fo_manage_percentage_of_shares3])
				) AS p  WHERE p.[related_fo_manage_desc3] != '' AND p.[related_fo_manage_desc3] IS NOT NULL
			UNION ALL
			/* 4 FO */
			SELECT p.[customer_id], p.[related_fo_manage_desc4] --, p.[related_fo_manage_percentage_of_shares4]
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [related_fo_manage_desc4]) --, [related_fo_manage_percentage_of_shares4])
				) AS p WHERE p.[related_fo_manage_desc4] != '' AND p.[related_fo_manage_desc4] IS NOT NULL
			UNION ALL
			
			/* 2.3 Uprava društva 1 */
			SELECT p.[customer_id], p.[management_desc1] 
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [management_desc1]) 
				) AS p WHERE p.[management_desc1] != '' AND p.[management_desc1] IS NOT NULL
			UNION ALL
			/* 2.3 Uprava društva 2 */
			SELECT p.[customer_id], p.[management_desc2] 
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [management_desc2]) 
				) AS p WHERE p.[management_desc2] != '' AND p.[management_desc2] IS NOT NULL
			UNION ALL
			/* 2.3 Uprava društva 3 */
			SELECT p.[customer_id], p.[management_desc3] 
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [management_desc3]) 
				) AS p WHERE p.[management_desc3] != '' AND p.[management_desc3] IS NOT NULL
			
			--'procurator_desc_' -- 2.4 Prokuristi društva 1
			SELECT p.[customer_id], p.[procurator_desc1] 
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [procurator_desc1]) 
				) AS p WHERE p.[procurator_desc1] != '' AND p.[procurator_desc1] IS NOT NULL
			UNION ALL
			/* 2.4 Prokuristi društva 2 */
			SELECT p.[customer_id], p.[procurator_desc2] 
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [procurator_desc2]) 
				) AS p WHERE p.[procurator_desc2] != '' AND p.[procurator_desc2] IS NOT NULL
			UNION ALL
			/* 2.4 Prokuristi društva 3 */
			SELECT p.[customer_id], p.[procurator_desc3] 
			FROM (SELECT val_str, def_name FROM #tabela1) AS j
			PIVOT
				( MAX(val_str) FOR def_name IN ([customer_id], [procurator_desc3]) 
				) AS p WHERE p.[procurator_desc3] != '' AND p.[procurator_desc3] IS NOT NULL
			) a		
		
		-- INSERT INTO #OwnershipStructure 
		-- (NovaNumber, [Owner], [Share]) 
		-- SELECT NovaNumber, [Owner], [Share] FROM #OwnershipStructure_tmp
		
		-- DROP TABLE #OwnershipStructure_tmp
	END
	
	DROP TABLE #tabela1

	FETCH NEXT FROM val_text_cursor INTO @val_text
END
CLOSE val_text_cursor
DEALLOCATE val_text_cursor 

SELECT * FROM #OwnershipStructure

DROP TABLE #gv_ods_data_field_tmp
DROP TABLE #OwnershipStructure