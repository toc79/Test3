DECLARE @id varchar(100)
SET @id = 56149-- 56195

DECLARE @obl_zav varchar(100)
Select @obl_zav = REPLACE(value, '''','') from gfn_g_register_active ('RLC Reporting list','') Where id_key = 'RLC_ZBIR_DOK'

Select LTRIM(RTRIM(id)) as id
INTO #DOK
From dbo.gfn_GetTableFromList(@obl_zav)
Order by id

SELECT RTRIM(LTRIM(a.opis)) 
	+ CASE WHEN (ISNULL(a.kolicina,0)<1) THEN '' ELSE SPACE(1) +CAST(CAST(a.kolicina AS int) AS VARCHAR(4)) + ' kom' END --AS količina
	--+ CASE WHEN (ISNULL(a.velj_opis), '') = '' THEN '' ELSE SPACE(1) + velj_opis -- IZBAČENO
	+ CASE WHEN a.velja_do IS NULL THEN '' ELSE SPACE(1) +CONVERT(nvarchar(MAX), a.velja_do, 104) END -- AS velja_do
	+ CASE WHEN a.naz_kr_kup IS NULL THEN '' ELSE SPACE(1) +'(' +RTRIM(LTRIM(a.naz_kr_kup)) +')' END --as naz_kr_kup
AS text 	
FROM dbo.gfn_ContractDocumentation(@id) a 
WHERE ali_na_pog = 1 AND dni_zap > 0 AND id_obl_zav NOT IN (Select id From #DOK)

DROP TABLE #DOK



--STARO
CREATE table #TMP (
	opis char(70), 
	naz_kr_kup varchar(90),
	kolicina varchar (10)
	) 

DECLARE @tid as int
SET @tid = @id

--Select CAST('' as char(70)) as opis, CAST('' as Varchar(90)) as naz_kr_kup, CAST('' as Char(10)) as kolicina into #tmp

IF NOT EXISTS (select spl_pog from dbo.pogodba where id_cont = @tid and spl_pog='ZO')
BEGIN
IF EXISTS (Select opis From dbo.gfn_ContractDocumentation(@tid) Where ali_na_pog = 1 and dni_zap > 0)
		BEGIN
Insert into #tmp (opis, naz_kr_kup, kolicina) 
	Select RTRIM(LTRIM(opis)) as opis, 
		CASE WHEN naz_kr_kup is not NULL THEN '('+RTRIM(LTRIM(naz_kr_kup))+')' ELSE NULL END as naz_kr_kup, 
			CASE WHEN (isnull(kolicina,0)<1) THEN '' ELSE RTRIM(LTRIM(CAST(CAST(kolicina as int) as varchar(10)))) + ' kom' END as kolicina
		From dbo.gfn_ContractDocumentation(@tid) 
		Where ali_na_pog = 1 and dni_zap > 0
	END
END

select * from #tmp
drop table  #tmp