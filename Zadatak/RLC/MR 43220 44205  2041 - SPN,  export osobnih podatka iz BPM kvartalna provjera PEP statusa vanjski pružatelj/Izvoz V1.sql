SELECT t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id,
	isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc1"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc1,
	isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc2"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc2
FROM (
	SELECT cast(val_text as xml) AS val_text_xml--, * --val_text  cast(a.val_text as xml)
	--INTO #gv_ods_data_field_tmp /*Obavezno u # kursor zato što ako se select izvršava unutar DECLARE val_text_cursor CURSOR FOR, tada dolazi do znatno dužeg vremena izvršavanja (par sati)*/
	FROM dbo.gv_ods_data_field a
	WHERE EXISTS (SELECT * FROM (
					SELECT val_int, MAX(id_ods_data_document) AS max_id_ods_data_document /*Jedan EXT_ID može imati više instanca id_ods_data_document, uzima se zadnja*/
					FROM dbo.gv_ods_data_field a 
					WHERE field_sys_id = 'INSTANCE_ID' 
					AND document_sys_id ='ZSPNFT_INSTANCE_DATA'
					AND EXISTS (SELECT * FROM dbo.gv_PEval_LastEvaluation_ByType exists_e
								INNER JOIN dbo.partner exists_p ON exists_e.id_kupca = exists_p.id_kupca
								WHERE exists_e.ext_id IS NOT NULL AND exists_e.eval_type = 'Z' AND exists_e.ext_id_type = 'BPM' AND exists_p.vr_osebe NOT IN ('FO', 'F1') /*Samo za pravne osobe, dok FO i F1 ću povući iz Nova*/
								AND CAST(exists_e.ext_id AS int) = a.val_int
								
								)
					GROUP BY val_int
				) b  WHERE max_id_ods_data_document = a.id_ods_data_document)
	AND field_sys_id = 'instance_xml_data'
) a 
cross apply a.val_text_xml.nodes('/INSTANCE/DATA_FIELDS') t(c)