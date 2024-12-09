testiranje 
DECLARE @id varchar(100) = '022729;20180201;20180302'

DECLARE @IDKUP VARCHAR(6), @DATOD AS DATETIME, @DATDO AS DATETIME, @LOBR AS CHAR(4)--, @ID AS VARCHAR(24)

--SET @ID = '000005;20120101;20121102'

SET @IDKUP = (Select CAST(SUBSTRING(@ID, 1, 6) AS CHAR(6)))
SET @DATOD = (SELECT CAST(SUBSTRING(@ID, CHARINDEX(';', @ID)+1, 8) AS CHAR(8)))
SET @DATDO = (SELECT CAST(SUBSTRING(@ID, CHARINDEX(';', @ID)+10, 8) AS CHAR(8)))
SET @LOBR = (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'LOBR')

SELECT a.id_cont, b.id_pog, dbo.gfn_TransformDDV_ID_HR(a.ddv_id, a.datum_dok) AS ddv_id, a.datum_dok, a.dat_zap, a.naziv_terj, a.zap_obr, a.id_val, a.nacin_leas, 
	a.debit, a.sdebit, a.sneto, a.sobresti, a.sregist, a.SROBRESTI, a.sdavek, b.pred_naj, a.st_sas, a.sklic, a.naz_kr_kup, @DATOD as Rep_OD, @DATDO as Rep_DO,
	ISNULL(dok.opis1,'') as Print_DU, ISNULL(konp.opis,'') as Print_DP, a.nacin_leas as nleas, dbo.gfn_Nacin_leas_HR(a.nacin_leas) as tip_leas
FROM dbo.pft_Print_InvoiceForInstallments(GETDATE()) a
--dbo.gft_Print_InvoiceForInstallments(GETDATE()) a
INNER JOIN dbo.pogodba b ON a.id_cont = b.id_cont
LEFT JOIN (SELECT a.id_cont, a.id_dokum, a.opis1
	FROM dbo.dokument a
INNER JOIN (SELECT MAX(id_dokum) AS id FROM dbo.dokument WHERE id_obl_zav = 'DU' GROUP BY id_cont) b ON a.id_dokum = b.id
			) dok on a.id_cont = dok.id_cont
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'DP' AND NEAKTIVEN = 0) konp on a.id_kupca = konp.id_kupca
WHERE a.id_kupca = @IDKUP 
AND (a.datum_dok BETWEEN @DATOD AND @DATDO) 
AND a.id_terj = @LOBR 
AND a.izpisan = 1

UNION ALL

SELECT a.id_cont, b.id_pog, NULL as ddv_id, a.datum_dok, a.dat_zap, a.naziv_terj, a.zap_obr, a.id_val, a.nacin_leas, 
	a.debit, 
	dbo.gfn_xchange('000',a.debit,a.id_tec,a.datum_dok) as sdebit, 
	dbo.gfn_xchange('000',a.neto,a.id_tec,a.datum_dok) as sneto, 
	dbo.gfn_xchange('000',a.obresti,a.id_tec,a.datum_dok) as sobresti,
	dbo.gfn_xchange('000',a.regist,a.id_tec,a.datum_dok) as sregist,
	dbo.gfn_xchange('000',a.ROBRESTI,a.id_tec,a.datum_dok) as SROBRESTI,
	dbo.gfn_xchange('000',a.davek,a.id_tec,a.datum_dok) as sdavek,
	b.pred_naj, ISNULL(zap.st_sas,'') as st_sas, a.sklic, a.naz_kr_kup, @DATOD as Rep_OD, @DATDO as Rep_DO,
	ISNULL(dok.opis1,'') as Print_DU, ISNULL(konp.opis,'') as Print_DP, a.nacin_leas as nleas, dbo.gfn_Nacin_leas_HR(a.nacin_leas) as tip_leas
FROM dbo.pft_Print_NoticeForInstallments(GETDATE()) a
--dbo.gft_Print_NoticeForInstallments(GETDATE()) a
INNER JOIN dbo.pogodba b ON a.id_cont = b.id_cont
LEFT JOIN dbo.zap_reg zap ON a.id_cont = zap.id_cont
LEFT JOIN (SELECT a.id_cont, a.id_dokum, a.opis1
	FROM dbo.dokument a
INNER JOIN (SELECT MAX(id_dokum) AS id FROM dbo.dokument WHERE id_obl_zav = 'DU' GROUP BY id_cont) b ON a.id_dokum = b.id
			) dok on a.id_cont = dok.id_cont
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'DP' AND NEAKTIVEN = 0) konp on a.id_kupca = konp.id_kupca
WHERE a.id_kupca = @IDKUP 
AND (a.datum_dok BETWEEN @DATOD AND @DATDO) 
AND a.id_terj = @LOBR 
--AND a.izpisan = 1
ORDER BY a.id_cont, a.datum_dok







ORIGINAL SQL


--EXEC  dbo.grp_Print_InvoiceForInstallments 1,0,'',1,'000005',0,'',0,'','',1,'20120101','20121102',1,'20121102',0,'','' 
DECLARE @IDKUP VARCHAR(6), @DATOD AS DATETIME, @DATDO AS DATETIME, @LOBR AS CHAR(4)--, @ID AS VARCHAR(24)

--SET @ID = '000005;20120101;20121102'

SET @IDKUP = (Select CAST(SUBSTRING(@ID, 1, 6) AS CHAR(6)))
SET @DATOD = (SELECT CAST(SUBSTRING(@ID, CHARINDEX(';', @ID)+1, 8) AS CHAR(8)))
SET @DATDO = (SELECT CAST(SUBSTRING(@ID, CHARINDEX(';', @ID)+10, 8) AS CHAR(8)))
SET @LOBR = (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'LOBR')

SELECT a.id_cont, b.id_pog, dbo.gfn_TransformDDV_ID_HR(a.ddv_id, a.datum_dok) AS ddv_id, a.datum_dok, a.dat_zap, a.naziv_terj, a.zap_obr, a.id_val, a.nacin_leas, 
	a.debit, a.sdebit, a.sneto, a.sobresti, a.sregist, a.SROBRESTI, a.sdavek, b.pred_naj, a.st_sas, a.sklic, a.naz_kr_kup, @DATOD as Rep_OD, @DATDO as Rep_DO,
	ISNULL(dok.opis1,'') as Print_DU, ISNULL(konp.opis,'') as Print_DP, a.nacin_leas as nleas, dbo.gfn_Nacin_leas_HR(a.nacin_leas) as tip_leas
FROM dbo.pft_Print_InvoiceForInstallments(GETDATE()) a
--dbo.gft_Print_InvoiceForInstallments(GETDATE()) a
INNER JOIN dbo.pogodba b ON a.id_cont = b.id_cont
LEFT JOIN (SELECT a.id_cont, a.id_dokum, a.opis1
	FROM dbo.dokument a
INNER JOIN (SELECT MAX(id_dokum) AS id FROM dbo.dokument WHERE id_obl_zav = 'DU' GROUP BY id_cont) b ON a.id_dokum = b.id
			) dok on a.id_cont = dok.id_cont
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'DP' AND NEAKTIVEN = 0) konp on a.id_kupca = konp.id_kupca
WHERE a.id_kupca = @IDKUP 
AND (a.datum_dok BETWEEN @DATOD AND @DATDO) 
AND a.id_terj = @LOBR 
AND a.izpisan = 1

UNION ALL

SELECT a.id_cont, b.id_pog, NULL as ddv_id, a.datum_dok, a.dat_zap, a.naziv_terj, a.zap_obr, a.id_val, a.nacin_leas, 
	a.debit, 
	dbo.gfn_xchange('000',a.debit,a.id_tec,a.datum_dok) as sdebit, 
	dbo.gfn_xchange('000',a.neto,a.id_tec,a.datum_dok) as sneto, 
	dbo.gfn_xchange('000',a.obresti,a.id_tec,a.datum_dok) as sobresti,
	dbo.gfn_xchange('000',a.regist,a.id_tec,a.datum_dok) as sregist,
	dbo.gfn_xchange('000',a.ROBRESTI,a.id_tec,a.datum_dok) as SROBRESTI,
	dbo.gfn_xchange('000',a.davek,a.id_tec,a.datum_dok) as sdavek,
	b.pred_naj, ISNULL(zap.st_sas,'') as st_sas, a.sklic, a.naz_kr_kup, @DATOD as Rep_OD, @DATDO as Rep_DO,
	ISNULL(dok.opis1,'') as Print_DU, ISNULL(konp.opis,'') as Print_DP, a.nacin_leas as nleas, dbo.gfn_Nacin_leas_HR(a.nacin_leas) as tip_leas
FROM dbo.pft_Print_NoticeForInstallments(GETDATE()) a
--dbo.gft_Print_NoticeForInstallments(GETDATE()) a
INNER JOIN dbo.pogodba b ON a.id_cont = b.id_cont
LEFT JOIN dbo.zap_reg zap ON a.id_cont = zap.id_cont
LEFT JOIN (SELECT a.id_cont, a.id_dokum, a.opis1
	FROM dbo.dokument a
INNER JOIN (SELECT MAX(id_dokum) AS id FROM dbo.dokument WHERE id_obl_zav = 'DU' GROUP BY id_cont) b ON a.id_dokum = b.id
			) dok on a.id_cont = dok.id_cont
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'DP' AND NEAKTIVEN = 0) konp on a.id_kupca = konp.id_kupca
WHERE a.id_kupca = @IDKUP 
AND (a.datum_dok BETWEEN @DATOD AND @DATDO) 
AND a.id_terj = @LOBR 
AND a.izpisan = 1
ORDER BY a.id_cont, a.datum_dok