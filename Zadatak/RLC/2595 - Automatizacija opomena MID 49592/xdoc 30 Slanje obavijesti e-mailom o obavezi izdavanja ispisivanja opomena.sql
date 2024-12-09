--SQL CANDIDATES

DECLARE @id_terj_lobr char(2), @today datetime, @dat_zap_cur_month datetime 
DECLARE @dat_izd_1_opom datetime, @dat_izd_2_opom datetime, @dat_izd_2_nf_opom datetime, @dat_izd_3_opom datetime, @dat_izd_3_nf_opom datetime

SET @id_terj_lobr = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj = 'LOBR')
SET @today = (SELECT dbo.gfn_GetDatePart(getdate()))

SELECT COUNT(*) as br_rata, dat_zap 
INTO #br_rata_mjesec
FROM dbo.planp 
WHERE id_terj = @id_terj_lobr
AND dat_zap BETWEEN dbo.gfn_GetFirstDayOfMonth(@today) AND dbo.gfn_GetLastDayOfMonth(@today)
GROUP BY dat_zap

SET @dat_zap_cur_month = (SELECT dat_zap FROM #br_rata_mjesec WHERE br_rata = (SELECT MAX(br_rata) FROM #br_rata_mjesec))

SELECT MAX(a.datum_izdavanja) as datum_izdavanja, a.st_opomina, a.id_za_opom_type 
INTO #history_za_opom
FROM 
	(SELECT MAX(datum_dok) as datum_izdavanja, st_opomina, id_za_opom_type 
	FROM dbo.za_opom
	WHERE st_opomina IN (1, 2, 3) 
	AND datum_dok IS NOT NULL AND dok_opom IS NOT NULL
	GROUP BY st_opomina, id_za_opom_type 
	UNION ALL 
	SELECT MAX(datum_dok) as datum_izdavanja, st_opomina, id_za_opom_type 
	FROM dbo.arh_za_opom
	WHERE st_opomina IN (1, 2, 3) 
	AND datum_dok IS NOT NULL AND dok_opom IS NOT NULL
	GROUP BY st_opomina, id_za_opom_type) a
GROUP BY a.st_opomina, a.id_za_opom_type 

SET @dat_izd_1_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 1)
SET @dat_izd_2_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 2 AND id_za_opom_type <> 7)
SET @dat_izd_2_nf_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 2 AND id_za_opom_type = 7)
SET @dat_izd_3_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 3 AND id_za_opom_type <> 7)
SET @dat_izd_3_nf_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 3 AND id_za_opom_type = 7)


SELECT TOP 1
CAST(CAST(@today as int) as varchar(40)) as doc_id
FROM dbo.nastavit
WHERE 
(
(DATEDIFF(dd, @dat_zap_cur_month, @today) > 10 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_1_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_1_opom)))
OR (DATEDIFF(dd, @dat_izd_1_opom, @today) > 20 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_2_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_2_opom)))
OR (DATEDIFF(dd, @dat_izd_2_opom, @today) > 30 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_3_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_3_opom)))
OR (DATEDIFF(dd, @dat_izd_2_opom, @today) > 10 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_3_nf_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_3_nf_opom)))
)


DROP TABLE #br_rata_mjesec
DROP TABLE #history_za_opom



--SQL EXPORT 
DECLARE  @session_id as char(40)
SET @session_id = {@session_id}

DECLARE @FromMail varchar(200)
SET @FromMail = (SELECT dbo.gfn_GetCustomSettings('NOVA_SYS_EMAIL_FROM')) 

DECLARE @id_terj_lobr char(2), @today datetime, @dat_zap_cur_month datetime 
DECLARE @dat_izd_1_opom datetime, @dat_izd_2_opom datetime, @dat_izd_2_nf_opom datetime, @dat_izd_3_opom datetime, @dat_izd_3_nf_opom datetime

SET @id_terj_lobr = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj = 'LOBR')
SET @today = (SELECT dbo.gfn_GetDatePart(getdate()))

SELECT COUNT(*) as br_rata, dat_zap 
INTO #br_rata_mjesec
FROM dbo.planp 
WHERE id_terj = @id_terj_lobr
AND dat_zap BETWEEN dbo.gfn_GetFirstDayOfMonth(@today) AND dbo.gfn_GetLastDayOfMonth(@today)
GROUP BY dat_zap

SET @dat_zap_cur_month = (SELECT dat_zap FROM #br_rata_mjesec WHERE br_rata = (SELECT MAX(br_rata) FROM #br_rata_mjesec))

SELECT MAX(a.datum_izdavanja) as datum_izdavanja, a.st_opomina, a.id_za_opom_type 
INTO #history_za_opom
FROM 
	(SELECT MAX(datum_dok) as datum_izdavanja, st_opomina, id_za_opom_type 
	FROM dbo.za_opom
	WHERE st_opomina IN (1, 2, 3) 
	AND datum_dok IS NOT NULL AND dok_opom IS NOT NULL
	GROUP BY st_opomina, id_za_opom_type 
	UNION ALL 
	SELECT MAX(datum_dok) as datum_izdavanja, st_opomina, id_za_opom_type 
	FROM dbo.arh_za_opom
	WHERE st_opomina IN (1, 2, 3) 
	AND datum_dok IS NOT NULL AND dok_opom IS NOT NULL
	GROUP BY st_opomina, id_za_opom_type) a
GROUP BY a.st_opomina, a.id_za_opom_type 

SET @dat_izd_1_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 1)
SET @dat_izd_2_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 2 AND id_za_opom_type <> 7)
SET @dat_izd_2_nf_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 2 AND id_za_opom_type = 7)
SET @dat_izd_3_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 3 AND id_za_opom_type <> 7)
SET @dat_izd_3_nf_opom = (SELECT MAX(datum_izdavanja) FROM #history_za_opom WHERE st_opomina = 3 AND id_za_opom_type = 7)


SELECT TOP 1
CAST(CAST(@today as int) as varchar(40)) as doc_id, 
@FromMail as [from], 
'sanja.mesaric@rl-hr.hr' as [to], 
'' as [cc], 
'' as [bcc],
'Izdavanje opomena na dan ' + CONVERT(varchar(20), @today, 104) as [subject],
'<p>Poštovani,</p><p>potrebno je izdati/ispisati opomene jer su ispunjeni sljedeći uvijeti:<br>' + 
CASE WHEN DATEDIFF(dd, @dat_zap_cur_month, @today) > 10 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_1_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_1_opom)) THEN
	'Dana ' + CONVERT(varchar(20), @today, 104) + ' je od dospjeća rata za najamnine ' + CONVERT(varchar(20), @dat_zap_cur_month, 104) + ' proteklo 10 kalendarskih dana, te je neophodno izdati i ispisati 1. opomene.<br>'
ELSE ''
END
+
CASE WHEN DATEDIFF(dd, @dat_izd_1_opom, @today) > 20 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_2_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_2_opom)) THEN
	'Dana ' + CONVERT(varchar(20), @today, 104) + ' je od izdavanja 1. opomene ' + CONVERT(varchar(20), @dat_izd_1_opom, 104) + ' proteklo 20 kalendarskih dana, te je neophodno izdati i ispisati 2. opomene.<br>'
ELSE ''
END
+
CASE WHEN DATEDIFF(dd, @dat_izd_2_opom, @today) > 30 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_3_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_3_opom)) THEN
	'Dana ' + CONVERT(varchar(20), @today, 104) + ' je od izdavanja 2. opomene ' + CONVERT(varchar(20), @dat_izd_2_opom, 104) + ' proteklo 30 kalendarskih dana, te je neophodno izdati i ispisati 3. opomene.<br>'
ELSE ''
END
+ 
CASE WHEN DATEDIFF(dd, @dat_izd_2_opom, @today) > 10 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_3_nf_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_3_nf_opom)) THEN
	'Dana ' + CONVERT(varchar(20), @today, 104) + ' je od izdavanja 2. opomene ' + CONVERT(varchar(20), @dat_izd_2_opom, 104) + ' proteklo 10 kalendarskih dana, te je neophodno izdati i ispisati opomene za NF ugovore.<br>'
ELSE ''
END
+ '</p>' as [body],
CAST(0 as bit) as [has_attachment],
CAST(1 as bit) as [is_html],
CAST(1 as bit) as [send_immediately]
FROM dbo.nastavit
WHERE 
CAST(CAST(@today as int) as varchar(40)) in (SELECT b.doc_id FROM dbo.xdoc_document_tmp b WHERE b.session_id = @session_id AND b.filter = 1)
AND
(
(DATEDIFF(dd, @dat_zap_cur_month, @today) > 10 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_1_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_1_opom)))
OR (DATEDIFF(dd, @dat_izd_1_opom, @today) > 20 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_2_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_2_opom)))
OR (DATEDIFF(dd, @dat_izd_2_opom, @today) > 30 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_3_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_3_opom)))
OR (DATEDIFF(dd, @dat_izd_2_opom, @today) > 10 AND (DATEPART(mm, @today) > DATEPART (mm, @dat_izd_3_nf_opom) OR DATEPART(yy, @today) > DATEPART (yy, @dat_izd_3_nf_opom)))
)

DROP TABLE #br_rata_mjesec
DROP TABLE #history_za_opom