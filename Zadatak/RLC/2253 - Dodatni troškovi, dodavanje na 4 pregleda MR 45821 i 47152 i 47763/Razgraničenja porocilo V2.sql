-- 14.09.2021 g_tomislav MID 47152 - created based on gfn_Gl_Razmej_View

declare @from datetime = {1} --'20210101'
declare @to datetime = {2} --'20211001'
declare @enabled_konto bit = {3}
declare @konto char(8) = {4} 
declare @enabled_id_vrst_dod_str bit = {5}
declare @id_vrst_dod_str varchar(200) = {6}

SELECT a.id_gl_razmej
	, a.konto
	, a.raz_pkonto
	, ISNULL(C.id_pog, pd.id_pog) AS id_pog
	, a.id_kupca
	, par.naz_kr_kup
	, a.st_dok
	, a.ddv_id
	, a.id_strm
	, irk.id_vrst_dod_str
	, vds.naziv as vrst_dod_str_naziv
	, a.znesek
	, a.znesek_se
	, a.opis_dok
	, a.raz_datum 
	, a.raz_st_obr
	, a.obrokov_se
	, obd.naziv as dinamika
	, status = (CASE WHEN a.dat_aktiv is null THEN 'N'  
				WHEN a.dat_aktiv is not null and znesek_se=0 THEN 'Z'  
				ELSE 'A'  
				END)
	, raz_tip_opis = CAST(CASE WHEN raz_tip=1   
						THEN UPPER(dbo.gfn_GetAppMessageByLang(NULL, 'CAccrualsTypeL'))   
						ELSE UPPER(dbo.gfn_GetAppMessageByLang(NULL, 'CAccrualsTypeLD'))  
					END AS varchar(239))
	, pas_akt_opis = (CASE WHEN A.pas_akt=1 THEN 'Pas.' ELSE 'Akt.' END)
	, a.veza_ni_ok
	, a.vrsta_dok
	, c.status_akt as pogodba_status_akt
	, ddv_date = (CASE WHEN a.vrsta_dok = 'IFA' THEN ro.ddv_date   
					WHEN a.vrsta_dok = 'PFA' THEN ri.ddv_date  
					ELSE NULL  
					END)
	, a.interna_veza
	, a.dat_aktiv
	, CASE WHEN a.veza_l4 = 1 THEN pp.st_nezap_le ELSE 0 END as nezapadlo_le 
into #temp471521 
FROM dbo.gl_razmej AS A   
LEFT JOIN dbo.partner par ON a.id_kupca = par.id_kupca   
LEFT JOIN dbo.pogodba AS C ON A.id_cont = C.id_cont  
LEFT JOIN dbo.rac_out ro ON ro.ddv_id = a.ddv_id AND a.vrsta_dok = 'IFA'  
LEFT JOIN (SELECT ddv_id, MAX(ddv_date) AS ddv_date   
			FROM dbo.rac_in   
			GROUP BY ddv_id) ri ON ri.ddv_id = a.ddv_id AND a.vrsta_dok = 'PFA'  
LEFT JOIN dbo.pogodba_deleted pd ON A.id_cont = pd.id_cont  
LEFT JOIN dbo.obdobja AS OBD ON A.raz_obdobj = OBD.id_obd  
LEFT JOIN (SELECT pp.id_cont, count(*) as st_nezap_le  
			FROM dbo.planp pp  
			left join dbo.vrst_ter vt on pp.id_terj=vt.id_terj  
			WHERE RTRIM(pp.evident)= '' AND vt.sif_terj='LOBR'  
			GROUP BY pp.id_cont) pp on a.id_cont = pp.id_cont
inner join dbo.ARH_GL_INPUT_RK irk on a.id_source = irk.ID_GL_INPUT_RK
inner join dbo.vrst_dod_str vds on irk.id_vrst_dod_str = vds.id_vrst_dod_str
where a.source_tbl = 'gl_input_rk'
and irk.id_vrst_dod_str is not null
and a.dat_aktiv between @from and @to
and (0 = @enabled_konto OR a.konto = @konto)
and (0 = @enabled_id_vrst_dod_str OR charindex(irk.id_vrst_dod_str, @id_vrst_dod_str) > 0)

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
		FROM #temp471521 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.ID_KUPCA, p.vr_osebe 
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();
exec dbo.gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null, 'Kraći naziv', 'INTERNAL', 'CUSTOM_REPORT', 'Razgraničenja s dodatnim troškovima', '471521', @xml
drop table #tempVrste
-- KONEC GDPR

select * from #temp471521 order by id_gl_razmej
drop table #temp471521