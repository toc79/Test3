*NOVO
private lnOdg, lcText, lnId_za_regis, lcFilter 

lnOdg = rf_msgbox("Pitanje","Želite li ispis svih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")

lcFilter = filter("za_regis")
lcFilter = iif(empty(lcFilter),".t.",lcFilter)

DO CASE 
	CASE lnOdg = 2	&& Trenutnega
		lnId_za_regis = za_regis.id_za_regis
		select * from za_regis where id_za_regis = lnId_za_regis into cursor rezultat1
	CASE lnOdg = 1	&& Vse
		select * from za_regis where &lcFilter into cursor rezultat1
	OTHERWISE
		RETURN .F.
ENDCASE

local lcSQL

TEXT TO lcSql NOSHOW
	SELECT a.id_za_regis
	FROM dbo.gfn_Za_regisSelection (getdate(), 0) a
	LEFT JOIN
		--podaci iz kasko polica
		(SELECT d.id_cont, d.id_master, MIN(d.zacetek) as zacetek, MAX(d.velja_do) as velja_do, MAX(d.konec) as kraj
		FROM dbo.dokument d
		WHERE d.id_obl_zav IN ('AK', 'BK', 'VK', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') 
		AND d.status_akt = 'A' 
		GROUP BY d.id_cont, d.id_master) d ON a.id_za_regis = d.id_master AND a.id_cont = d.id_cont
	LEFT JOIN
		--podaci iz polica osiguranja
		(SELECT d.id_cont, d.id_master, MIN(d.zacetek) as zacetek, MAX(d.velja_do) as velja_do, MAX(d.konec) as kraj
		FROM dbo.dokument d
		WHERE d.id_obl_zav IN ('AO', 'BO', 'VO') 
		AND d.status_akt = 'A' 
		GROUP BY d.id_cont, d.id_master) d2 ON a.id_za_regis = d2.id_master AND a.id_cont = d2.id_cont
	INNER JOIN dbo.pogodba p ON a.id_cont = p.id_cont
	INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas
	LEFT JOIN dbo.p_kontakt pk ON a.id_kupca = pk.id_kupca AND pk.id_vloga = 'DN'
	LEFT JOIN dbo.planp_ds ds ON p.id_cont = ds.id_cont
	WHERE p.status_akt = 'A' 
	AND 
	(d2.id_cont IS NOT NULL
	OR
	(d.id_cont IS NOT NULL 
		AND
		CAST(DATEPART(yy, d.zacetek) as char(4)) + REPLICATE('0', 2 - LEN(CAST(DATEPART(mm, d.zacetek) as char(2)))) + CAST(DATEPART(mm, d.zacetek) as char(2)) > 
		ISNULL(CAST(DATEPART(yy, d.kraj) as char(4)) +  REPLICATE('0', 2 - LEN(CAST(DATEPART(mm, d.kraj) as char(2)))) + CAST(DATEPART(mm, d.kraj) as char(2)), '19000101')
		AND pk.id_kupca IS NULL
		--AND (n.tip_knjizenja = '1' OR (n.tip_knjizenja = '2' AND ds.bod_cnt_lobr > 1)) MR 39200
		AND (n.tip_knjizenja = '1' OR ol_na_nacin_fl = 1 OR (n.tip_knjizenja = '2' AND ds.bod_cnt_lobr > 1))
			--(n.tip_knjizenja = '2' AND dbo.gfn_Nacin_leas_HR(p.nacin_leas)= 'OL') drugi način za hibrid OF
	)
	)
ENDTEXT

GF_SQLEXEC(lcSQL, "_ss_za_regis")

select a.id_za_regis from rezultat1 a inner join _ss_za_regis b on a.id_za_regis = b.id_za_regis into cursor rezultat

use in rezultat1
use in _ss_za_regis



sele rezultat
IF reccount() = 0 THEN
	=POZOR("Nema podataka za ispis!")
	RETURN .F.
endif

OBJ_ReportSelector.PrepareDataForMRT("rezultat", "id_za_regis")




*STARO
private lnOdg, lcText, lnId_za_regis, lcFilter 

lnOdg = rf_msgbox("Pitanje","Želite li ispis svih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")

lcFilter = filter("za_regis")
lcFilter = iif(empty(lcFilter),".t.",lcFilter)

DO CASE 
	CASE lnOdg = 2	&& Trenutnega
		lnId_za_regis = za_regis.id_za_regis
		select * from za_regis where id_za_regis = lnId_za_regis into cursor rezultat1
	CASE lnOdg = 1	&& Vse
		select * from za_regis where &lcFilter into cursor rezultat1
	OTHERWISE
		RETURN .F.
ENDCASE

local lcSQL

TEXT TO lcSql NOSHOW
	SELECT a.id_za_regis
	FROM dbo.gfn_Za_regisSelection (getdate(), 0) a
	LEFT JOIN
		--podaci iz kasko polica
		(SELECT d.id_cont, d.id_master, MIN(d.zacetek) as zacetek, MAX(d.velja_do) as velja_do, MAX(d.konec) as kraj
		FROM dbo.dokument d
		WHERE d.id_obl_zav IN ('AK', 'BK', 'VK', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') 
		AND d.status_akt = 'A' 
		GROUP BY d.id_cont, d.id_master) d ON a.id_za_regis = d.id_master AND a.id_cont = d.id_cont
	LEFT JOIN
		--podaci iz polica osiguranja
		(SELECT d.id_cont, d.id_master, MIN(d.zacetek) as zacetek, MAX(d.velja_do) as velja_do, MAX(d.konec) as kraj
		FROM dbo.dokument d
		WHERE d.id_obl_zav IN ('AO', 'BO', 'VO') 
		AND d.status_akt = 'A' 
		GROUP BY d.id_cont, d.id_master) d2 ON a.id_za_regis = d2.id_master AND a.id_cont = d2.id_cont
	INNER JOIN dbo.pogodba p ON a.id_cont = p.id_cont
	INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas
	LEFT JOIN dbo.p_kontakt pk ON a.id_kupca = pk.id_kupca AND pk.id_vloga = 'DN'
	LEFT JOIN dbo.planp_ds ds ON p.id_cont = ds.id_cont
	WHERE p.status_akt = 'A' 
	AND 
	(d2.id_cont IS NOT NULL
	OR
	(d.id_cont IS NOT NULL 
		AND
		CAST(DATEPART(yy, d.zacetek) as char(4)) + REPLICATE('0', 2 - LEN(CAST(DATEPART(mm, d.zacetek) as char(2)))) + CAST(DATEPART(mm, d.zacetek) as char(2)) > 
		ISNULL(CAST(DATEPART(yy, d.kraj) as char(4)) +  REPLICATE('0', 2 - LEN(CAST(DATEPART(mm, d.kraj) as char(2)))) + CAST(DATEPART(mm, d.kraj) as char(2)), '19000101')
		AND pk.id_kupca IS NULL
		AND (n.tip_knjizenja = '1' OR (n.tip_knjizenja = '2' AND ds.bod_cnt_lobr > 1))
	)
	)
ENDTEXT

GF_SQLEXEC(lcSQL, "_ss_za_regis")

select a.id_za_regis from rezultat1 a inner join _ss_za_regis b on a.id_za_regis = b.id_za_regis into cursor rezultat

use in rezultat1
use in _ss_za_regis



sele rezultat
IF reccount() = 0 THEN
	=POZOR("Nema podataka za ispis!")
	RETURN .F.
endif

OBJ_ReportSelector.PrepareDataForMRT("rezultat", "id_za_regis")