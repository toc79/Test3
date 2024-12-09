INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) VALUES('NAUTILUS','Channel for Nautilus export','\\RLENOVA\nova_test_io\Nautilus\','',1,'','','')
'
UPDATE dbo.xdoc_template SET channel_code= 'XDOC_SPN'where id_xdoc_template = 39 

INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) VALUES ('XDOC_SPN','Channel for AML(SPN) export','\\RLENOVA\nova_test_io\SPN\','',1,'','','')


'

\\RLENOVA\nova_prod_io\Invoice_spec\
\\RLENOVA\nova_test_io\SPN\

\\RLENOVA\nova_prod_io\SPN\

UPDATE dbo.io_channels SET channel_path = '\\RLENOVA\nova_prod_io\SPN\' where channel_code = 'XDOC_SPN'

'
SELECT *  FROM [BPM_PROD].[dbo].[bpm_def_process]
id	title	date_created	inactive	description	allow_manual_start
zspnft_child_rlhr   	ZSPNFT izložene osobe RLHR	2016-01-05 00:00:00.000	0	ZSPNFT izložene osobe RLHR	0
zspnft_parent_rlhr  	Proces ZSPNFT s provjerom fizičkih osoba u vlasničkoj strukturi RLHR	2016-01-05 00:00:00.000	0	Proces ZSPNFT s provjerom fizičkih osoba u vlasničkoj strukturi RLHR	1

SELECT * FROM [BPM_PROD].[dbo].[bpm_def_process_version]


-- select top 100 * from dbo.bpm_data_field_instance Ti podaci isto postoje u ODSu u XMLu za svaku instancu
select * from dbo.bpm_def_data_field where id_process_version = 16 AND name like 'related_fo_manage_desc_'
select * from dbo.bpm_def_data_field where id_process_version = 16 AND name like 'related_Po_manage_desc_'
select * from dbo.bpm_def_data_field where id_process_version = 16 AND name like 'related_fo_manage%'
select * from dbo.bpm_def_data_field where id_process_version = 16 AND name like 'related_Po_manage%'

[14:55] Nenad Milevoj
    to su ona asainee_desc
​[15:00] Nenad Milevoj
    customer_desc, related_fo_manage_desc1...4, management_desc1...4 itd

<data_field name="management_desc1" type="string" title="1. Ime i prezime" description="1. Ime i prezime" display_to_user="true" display_group="2.3 Uprava društva" />

DV: ne mora svaka fizička osoba koju unesu ujedno biti i partner u IS NOVA, pa ne znam što da im se isporuči kao id_kupca


Nazivi u BPMu

2.1 Vlasnička struktura - pravne osobe
1. Tvrtka društva

2.2 Vlasnička struktura - fizičke osobe
1. Ime i prezime (Vlasnička struktura - fizičke osobe)
1. Šifra partnera


SELECT * from dbo.gv_PEval_LastEvaluation_ByType a
Where a.eval_type = 'Z' AND a.ext_id_type = 'BPM'
AND EXISTS (select * from partner where vr_osebe in ('FO', 'F1') AND id_kupca = a.id_kupca)
AND EXISTS (select * from dbo.pogodba where status_akt = 'A' AND id_kupca = a.id_kupca)



Osim odlomka 2.2. Vlasnička struktura - fizičke osobe potrebno je iz BPM-a povuć ili ti exportirati imena i prezimena iz odlomaka 2.3, 2.4 i 4.

2.3 (u BPM) - Podaci o Upravi društva
2.4 (u BPM) Prokuristi Društva
4 Zakonski zastupnik- punomoćenik


SELECT id_kupca, vr_osebe, * 
FROM dbo.partner a 
INNER JOIN dbo.gv_PEval_LastEvaluation_ByType eval_Z
WHERE eval_Z.eval_type = 'Z' 
AND a.vr_osebe in ('FO', 'F1')
AND (	EXISTS (select * FROM dbo.pogodba b WHERE b.status_akt = 'A' AND b.id_kupca = a.id_kupca)
		OR 
		EXISTS (SELECT * FROM dbo.pog_poro c
				WHERE EXISTS (SELECT * FROM dbo.pogodba d WHERE d.status_akt = 'A' AND d.id_cont = c.id_cont)
				AND c.id_poroka = a.id_kupca)
	)


SELECT id_kupca AS reference, naz_kr_kup AS terms 
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