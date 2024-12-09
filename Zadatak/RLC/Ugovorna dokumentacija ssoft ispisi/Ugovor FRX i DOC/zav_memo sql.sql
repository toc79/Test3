DECLARE @id varchar(100)
SET @id = 56149--56217--

DECLARE @tid as int, @obl_zav varchar(100)
SET @tid = @id

Select @obl_zav = REPLACE(value, '''','') from gfn_g_register_active ('RLC Reporting list','') Where id_key = 'RLC_ZBIR_DOK'

Select LTRIM(RTRIM(id)) as id
INTO #DOK
From dbo.gfn_GetTableFromList(@obl_zav)
Order by id

--lista dokumenta bez okvira
SELECT * 
INTO #dok_prije
FROM dbo.gfn_ContractDocumentation(@tid) 
WHERE ali_na_pog = 1 AND dni_zap=0 AND id_obl_zav NOT IN (Select id From #DOK)

--lista dikumenta okvira
SELECT a.opis, a.kolicina, a.velja_do, a.velj_opis, a.naz_kr_kup, b.id_frame
INTO #FrmDok
FROM dbo.gfn_ContractDocumentation (@tid) a
INNER JOIN dbo.frame_pogodba b on a.id_cont = b.id_cont
WHERE a.id_obl_zav IN (Select id From #DOK)

SELECT RTRIM(LTRIM(a.opis)) 
	+ CASE WHEN (ISNULL(a.kolicina,0)<1) THEN '' ELSE SPACE(1) +CAST(CAST(a.kolicina AS int) AS VARCHAR(4)) + ' kom' END --AS količina
	--+ CASE WHEN (ISNULL(a.velj_opis), '') = '' THEN '' ELSE SPACE(1) + velj_opis -- IZBAČENO
	+ CASE WHEN a.velja_do IS NULL THEN '' ELSE SPACE(1) +CONVERT(nvarchar(MAX), a.velja_do, 104) END -- AS velja_do
	+ CASE WHEN a.naz_kr_kup IS NULL THEN '' ELSE SPACE(1) +'(' +RTRIM(LTRIM(a.naz_kr_kup)) +')' END --as naz_kr_kup
AS text 
FROM #dok_prije a

UNION

Select RTRIM(LTRIM(a.opis)) 
	+' BR. ' + CAST(a.id_frame As CHAR(5)) 
	+ CASE WHEN a.naz_kr_kup IS NULL THEN '' ELSE '('+RTRIM(LTRIM(a.naz_kr_kup))+')' END 
AS text
From #FrmDok a

DROP TABLE #DOK
DROP TABLE #dok_prije
DROP TABLE #FrmDok


--*****************************
--STARO
CREATE table #TMP (
	opis char(70), 
	naz_kr_kup varchar(90),
	kolicina char(10)
	) 

DECLARE @tid as int, @obl_zav varchar(50)
SET @tid = @id

Select @obl_zav = REPLACE(value, '''','') from gfn_g_register_active ('RLC Reporting list','') Where id_key = 'RLC_ZBIR_DOK'

Select LTRIM(RTRIM(id)) as id
INTO #DOK
From dbo.gfn_GetTableFromList(@obl_zav)
Order by id


IF EXISTS (select spl_pog from dbo.pogodba where id_cont = @tid and spl_pog='ZO')
	BEGIN
Insert into #tmp
	Select 'ZBIRNI INSTR. OSIGURANJA PREMA ODOBRENJU OKVIRA' as opis, '' as naz_kr_kup ,'' as kolicina 
	END 
ELSE 
	BEGIN
Insert into #tmp
	Select RTRIM(LTRIM(a.opis)) as opis, 
		CASE WHEN a.naz_kr_kup IS NOT NULL THEN '('+RTRIM(LTRIM(a.naz_kr_kup))+')' ELSE NULL END as naz_kr_kup, 
			CASE 
WHEN a.id_obl_zav IN (Select id From #DOK) THEN CASE WHEN ISNULL(b.id_frame,'') = '' THEN '' ELSE ' BR. ' + CAST(b.id_frame As CHAR(5)) END 
				ELSE CASE WHEN (ISNULL(a.kolicina,0)<1) THEN '' ELSE CAST(a.kolicina AS CHAR(2)) + 'kom' 
				END 
			END as kolicina
			From dbo.gfn_ContractDocumentation(@tid) a
			Inner join dbo.frame_pogodba b on a.id_cont = b.id_cont 
			Where a.ali_na_pog = 1 and a.dni_zap = 0
	END	
	
SELECT * FROM #tmp
DROP TABLE  #tmp
DROP TABLE #DOK


strtran(_print1.zav_memo_prije,' 0 kom','') + IIF(GF_NULLOREMPTY(_print1.zav_memo_FrmDok), '', _print1.zav_memo_FrmDok)

*********************************************************************
* this function generates zav_memo memo field from source table into destination table
* tcSourceTbl - source table from whic zav_memo is generated
FUNCTION GF_CreateZav_memo(tcSourceTbl)
IF PCOUNT() # 1 THEN
	GF_NAPAKA(0,GF_CreateZav_memo(),'',LOWPARAMETERS_LOC,1)
	RETURN .F.
ENDIF
IF TYPE(tcSourceTbl+'.opis')='U' OR TYPE(tcSourceTbl+'.kolicina')='U' OR ;
		TYPE(tcSourceTbl+'.velja_do')='U' OR TYPE(tcSourceTbl+'.velj_opis')='U' OR ;
		TYPE(tcSourceTbl+'.naz_kr_kup')='U' THEN
	GF_NAPAKA(0, GF_CreateZav_memo(), '',"Given tables do not contain needed fields.",1)
	RETURN .F.
ENDIF

SELECT opis, kolicina, velja_do, velj_opis, naz_kr_kup FROM (tcSourceTbl) INTO CURSOR _GF_CreateZav_memo

LOCAL lcOpis, lcKolicina, lcVelja_do, lcVelj_opis, lcNaz_kr_kup, lcZav_memo
lcZav_memo = ''
SELECT _GF_CreateZav_memo
SCAN
	lcOpis = _GF_CreateZav_memo.opis
	lcKolicina = STR(_GF_CreateZav_memo.kolicina, 3, 0) + SPACE(1) + "kom" + SPACE(1) && caption
	lcVelj_opis = ALLTRIM(_GF_CreateZav_memo.velj_opis)+SPACE(1)
	lcVelja_do = IIF(ISNULL(_GF_CreateZav_memo.velja_do), '', lcVelj_opis + TRANSFORM(TTOD(_GF_CreateZav_memo.velja_do)))
	lcNaz_kr_kup = IIF(ISNULL(_GF_CreateZav_memo.naz_kr_kup),'',' ('+ALLTRIM(_GF_CreateZav_memo.naz_kr_kup)+')')

	lcZav_memo = lcZav_memo + lcOpis + lcKolicina + lcVelja_do + lcNaz_kr_kup + CHR(13)
ENDSCAN
RETURN lcZav_memo
ENDFUNC

