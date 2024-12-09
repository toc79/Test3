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