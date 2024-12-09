--SQL Candidates DORAĐENI
declare @datod as datetime
declare @datdo as datetime
declare @id_kupca as char(6)
declare @vloga as bit

set @datod = {@datod}
set @datdo = {@datdo}
set @id_kupca = {@idpar}
set @vloga = (select case when @id_kupca = '' then 1 else 0 end)

--19.06.2018. g_tomislav MR 40655
SELECT a.id_kupca AS doc_id
FROM dbo.najem_fa a
LEFT JOIN (SELECT * FROM dbo.P_KONTAKT WHERE ID_VLOGA = 'SR' AND NEAKTIVEN = 0) b ON a.id_kupca = b.id_kupca
INNER JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
WHERE (@id_kupca = '' OR a.id_kupca = @id_kupca)
AND a.datum_dok BETWEEN @datod and @datdo And v.sif_terj = 'LOBR'
AND (@VLOGA = 0 OR b.id_vloga = 'SR')
AND a.izpisan = 1
GROUP BY a.id_kupca

UNION

SELECT a.id_kupca AS doc_id
FROM dbo.najem_ob a
LEFT JOIN (SELECT * FROM dbo.P_KONTAKT WHERE ID_VLOGA = 'SR' AND NEAKTIVEN = 0) b ON a.id_kupca = b.id_kupca
INNER JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
WHERE (@id_kupca = '' OR a.id_kupca = @id_kupca)
AND a.datum_dok BETWEEN @datod and @datdo And v.sif_terj = 'LOBR'
AND (@VLOGA = 0 OR b.id_vloga = 'SR')
AND a.izpisan = 1
GROUP BY a.id_kupca



--SQL SHOW DORAĐENI 
declare @session_id varchar(40)
declare @datod as datetime
declare @datdo as datetime

set @session_id = {@session_id}
set @datod = {@datod}
set @datdo = {@datdo}

SELECT Selected,
a.id_kupca, Naziv, Oib,
sum(Broj_rata) as Broj_rata_obavijesti, 
doc_id 
INTO #temp18
FROM (
	Select Cast(1 as bit) as Selected,
	a.id_kupca, p.naz_kr_kup as Naziv, p.dav_stev as Oib,
	count(a.ddv_id) as Broj_rata, 
	cast(a.id_kupca+convert(varchar(8), @datod, 112)+convert(varchar(8), @datdo, 112) as varchar(40)) as doc_id

	From dbo.najem_fa a
	inner join dbo.partner p on a.id_kupca = p.id_kupca
	INNER JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
	WHERE a.datum_dok BETWEEN @datod and @datdo 
	AND v.sif_terj = 'LOBR'
	AND a.izpisan = 1
	AND a.id_kupca in (SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
	
	Group by a.id_kupca, p.naz_kr_kup, p.dav_stev

	UNION 

	Select Cast(1 as bit) as Selected,
	a.id_kupca, p.naz_kr_kup as Naziv, p.dav_stev as Oib,
	count(a.st_dok) as Broj_rata, 
	cast(a.id_kupca+convert(varchar(8), @datod, 112)+convert(varchar(8), @datdo, 112) as varchar(40)) as doc_id
	From dbo.najem_ob a
	inner join dbo.partner p on a.id_kupca = p.id_kupca
	INNER JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
	WHERE a.datum_dok BETWEEN @datod and @datdo 
	AND v.sif_terj = 'LOBR'
	AND a.izpisan = 1
	AND a.id_kupca in (SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
	Group by a.id_kupca, p.naz_kr_kup, p.dav_stev
) a
Group by Selected, id_kupca, Naziv, Oib, doc_id

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
		FROM #temp18 t
		INNER JOIN PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.id_kupca, p.vr_osebe
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)


DECLARE @time datetime;
SET @time=GETDATE();
exec gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Kraći naziv, OIB','INTERNAL','XDOC', 'Izvoz specifikacije računa - SQL show',18,@xml

drop table #tempVrste
-- KONEC GDPR

select * from #temp18
drop table #temp18

------------------------------------------------------------------


--SQL EXPORT DORAĐENI
declare @session_id varchar(40)
declare @datod as datetime
declare @datdo as datetime

set @session_id = {@session_id}
set @datod = {@datod}
set @datdo = {@datdo}

Select cast(rtrim(a.id_kupca)+';'+convert(varchar(8), @datod, 112)+';'+convert(varchar(8), @datdo,112) as varchar(40)) as doc_id,
'RLC_XDOC_T1' as report_name,
'MsExcel' as format,
'RLSPEC_'+cast(rtrim(a.naz_kr_kup) as varchar(80))+'_'+convert(varchar(8), @datod,112)+' - '+convert(varchar(8), @datdo,112)+'.xlsx' as file_name, 
a.id_kupca
INTO #temp18
FROM (
	SELECT a.id_kupca, p.naz_kr_kup
	From dbo.najem_fa a
	inner join dbo.partner p on a.id_kupca = p.id_kupca
	INNER JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
	Where a.datum_dok BETWEEN @datod and @datdo 
	And v.sif_terj = 'LOBR'
	AND a.izpisan = 1
	AND a.id_kupca in (SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
	Group by a.id_kupca, p.naz_kr_kup

	UNION 

	Select a.id_kupca, p.naz_kr_kup
	From dbo.najem_ob a
	inner join dbo.partner p on a.id_kupca = p.id_kupca
	INNER JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
	Where a.datum_dok BETWEEN @datod and @datdo 
	And v.sif_terj = 'LOBR'
	AND a.izpisan = 1
	AND a.id_kupca in (SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
	Group by a.id_kupca, p.naz_kr_kup
) a
GROUP BY a.id_kupca, a.naz_kr_kup


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
		FROM #temp18 t
		INNER JOIN PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.id_kupca, p.vr_osebe
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)


DECLARE @time datetime;
SET @time=GETDATE();
exec gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Kraći naziv','INTERNAL','XDOC', 'Izvoz specifikacije računa - SQL export',18,@xml

drop table #tempVrste
-- KONEC GDPR

select 
doc_id, 
report_name, 
format,
file_name from #temp18
drop table #temp18



-------------------------------------------------------------



---SQL Export

declare @session_id varchar(40)

set @session_id = {@session_id}

Select cast(rtrim(a.id_kupca)+';'+convert(varchar(8), min(datum_dok),112)+';'+convert(varchar(8), max(datum_dok),112) as varchar(40)) as doc_id,
'RLC_XDOC_T1' as report_name,
'MsExcel' as format,
'RLSPEC_'+cast(rtrim(p.naz_kr_kup) as varchar(80))+'_'+convert(varchar(8), min(datum_dok),112)+' - '+convert(varchar(8), max(a.datum_dok),112)+'.xlsx' as file_name, a.id_kupca
INTO #temp18
From dbo.najem_fa a
inner join dbo.partner p on a.id_kupca = p.id_kupca
Where a.ddv_id in (SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
Group by a.id_kupca, p.naz_kr_kup, p.dav_stev


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
		FROM #temp18 t
		INNER JOIN PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.id_kupca, p.vr_osebe
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)


DECLARE @time datetime;
SET @time=GETDATE();
exec gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Kraći naziv','INTERNAL','XDOC', 'Izvoz specifikacije računa - SQL export',18,@xml

drop table #tempVrste
-- KONEC GDPR

select 
doc_id, 
report_name, 
format,
file_name from #temp18
drop table #temp18
---------------------------------------------------------------




--SQL SHOW


declare @session_id varchar(40)

set @session_id = {@session_id}

Select Cast(1 as bit) as Selected,
a.id_kupca, p.naz_kr_kup as Naziv, p.dav_stev as Oib,
count(a.ddv_id) as Broj_rata, 
cast(a.id_kupca+convert(varchar(8), min(datum_dok),112)+convert(varchar(8), max(a.datum_dok),112) as varchar(40)) as doc_id
INTO #temp18
From dbo.najem_fa a
inner join dbo.partner p on a.id_kupca = p.id_kupca
Where a.ddv_id in (SELECT doc_id FROM dbo.xdoc_document_tmp WHERE session_id = @session_id AND filter = 1)
Group by a.id_kupca, p.naz_kr_kup, p.dav_stev

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
		FROM #temp18 t
		INNER JOIN PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.id_kupca, p.vr_osebe
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)


DECLARE @time datetime;
SET @time=GETDATE();
exec gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Kraći naziv, OIB','INTERNAL','XDOC', 'Izvoz specifikacije računa - SQL show',18,@xml

drop table #tempVrste
-- KONEC GDPR

select * from #temp18
drop table #temp18


bck up s PROD

--SQL Candidates

declare @datod as datetime
declare @datdo as datetime
declare @id_kupca as char(6)
declare @vloga as bit

set @datod = {@datod}
set @datdo = {@datdo}
set @id_kupca = {@idpar}
set @vloga = (select case when @id_kupca = '' then 1 else 0 end)

SELECT ddv_id AS doc_id
FROM dbo.najem_fa a
LEFT JOIN (SELECT * FROM dbo.P_KONTAKT WHERE ID_VLOGA = 'SR' AND NEAKTIVEN = 0) b ON a.id_kupca = b.id_kupca
INNER JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
WHERE (@id_kupca = '' OR a.id_kupca = @id_kupca)
AND a.datum_dok BETWEEN @datod and @datdo And v.sif_terj = 'LOBR'
AND (@VLOGA = 0 OR b.id_vloga = 'SR')
AND a.izpisan = 1