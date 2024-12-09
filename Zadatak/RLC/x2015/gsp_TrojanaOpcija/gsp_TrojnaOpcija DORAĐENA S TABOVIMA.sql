--USE [Mary]
--GO
/****** Object:  StoredProcedure [dbo].[gsp_TrojnaOpcija]    Script Date: 2.10.2015. 14:44:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------									
-- Procedura pripravi obvestila (v tabelo odgnaopc) in fakture (v tabelo opc_fakt) ob izteku financiranja									
-- Procedura se izvede samo za pogodbe, ki so aktivne in obvestila/fakture za njih še niso pripravljene 									
-- ter se iztečejo v roku do števila dni, podanih s parametrom.									
-- Input parameters: st_dni - število dni, ki določa obdobje za katerega se pripravijo obvestila/fakture									
-- 									
-- Pseudo koda:									
-- 									
-- FAKTURE									
-- IF (tip_knjizenja = '1' AND ima_opcijo) OR (pred_ddv and leasing) THEN									
-- 	IF v tabeli planp obstaja terjatev za opcijo THEN zapis v OPC_FAKT								
--	ELSE zapis v OPC_FAKT za zadnji obrok 								
--		if ima_opcijo then vrednosti iz obroka							
--		else z zneski 0 in id_terj = opcija in st_dok = id_pog-id_terj za opcijo-število obrokov+1 END							
-- END									
--									
-- OBVESTILA									
-- IF obv_zakl THEN									
--	IF v tabeli planp obstaja terjatev za opcijo THEN zapis v ODGNAOPC								
--	ELSE zapis zadnjega obroka v ODGNAOPC END								
-- END									
--									
-- History:									
-- xx.xx.xxxx Matjaz: Created									
-- 15.09.2003; Vik; removed transaction									
-- 22.03.2004 Matjaz; Changes due to id_cont 2 PK transition									
-- 15.10.2004 Matjaz; changed insert into opc_fakt (pog_kupec must be null, because a constraint has been added)									
-- 30.11.2004 Matjaz; changed insert into opc_fakt added regist									
-- 07.12.2004 Matjaz; optimized and reorganized procedure									
-- 16.12.2004 Matjaz; added deleting of records that will be prepared again from odgnaopc									
-- and prevented inserting of more than one record per contract									
-- 06.04.2005 Matjaz; changed insert into opc_fakt regarding contracts before VAT (pred_ddv)									
-- 06.04.2005 Matjaz; changed insert into opc_fakt - davek and debit are not recalculated, 									
-- because they should already have correct values									
-- 18.03.2006 Darko; maintenance ID 205: added filling of column id_zapo at inserting into opc_fakt table									
-- 05.02.2007 Vilko; Maintenance ID 7168 - fixed condition for buyout claim - invoice should not be issued									
-- 25.04.2007 Jasna; MID 7381 - changes due to new added parameter vnesel in opc_fakt tbl									
-- 11.02.2008 Vilko; Bug ID 27134 - fixed preparing buyout notices - now is looked for last claim and not for last instalment as before									
-- 17.06.2008 Jasna; MID 15377 - modif. of insert into dbo.opc_fakt - datum_dok fill with dat_zap instead null									
-- 01.07.2008 Jasna; MID 14941 - modif. insert into dbo.opc_fakt, in case of 'OO' when nacini_l.odstej_var = 1 									
--			caution money will be added to neto and debit amounts.						
-- 14.08.2008 Ziga; MID 16151 - added check for field status.ne_fakt_odkup = 0 for invoices and notifications									
-- 21.09.2010 MatjazB; MID 26740 - added check for contract exceptions - dbo.gfn_ContractCanBookDueClaims(pp.id_cont) = 1 and AND dbo.gfn_ContractCanPrepareInstallmentNotifications(pp.id_cont) = 1									
-- 31.08.2011 MatjazB; MID 31505 - change pog.varscina with tv.varscila (added logic for tv.varscina - #tmp_vars_lobr and #tmp_vars_opc)									
-- 03.11.2011 Neno&Josip (MatjazB) - samo modification on previous change									
-- 02.01.2013 Josip; Task ID 7173 - added ol_na_nacin_fl									
-- 19.12.2013 Ales; MID 42652 - added id_terj and use_dat_dok; if Nova.LE.TrojnaOpcija.UseDatumDok is set to 1 datum_dok will be used, if not dat_zap will be used;									
--            if Nova.LE.TrojnaOpcija.IdTerj is set id_terj from setting is used for notifications and invoices, if not program works as before									
-- 21.01.2014 Ales; MID 42652 - added group by on last insert									
-- 17.07.2014 Ales; MID 46595 - fixed odgnaopc insert when Nova.LE.TrojnaOpcija.IdTerj is set									
-- 18.07.2014 Ales; MID 46595 - fixed opc_fakt insert when Nova.LE.TrojnaOpcija.IdTerj is set									
-- 23.10.2014 MatjazB; Bug 30309 - added check if ST_DOK exists in dbo.OPC_FAKT									
-- 03.02.2015 Jost; MID 49518 - exclude inserting into odgnaopc for contract that has at least one of document declared in custom setting 'Nova.Exclude.TrojnaOpcija_Obvestila'									
-- 30.09.2015 Josip; Modify on site - insert into dbo.opc_fakt from @opc_fakt									
---------------------------------------------------------------------------------------------------------------------------------------------------------------------									
ALTER       PROCEDURE [dbo].[gsp_TrojnaOpcija] @st_dni smallint									
AS									
									
DECLARE @ter_opc char(2), @ter_lobr char(2), @datum_prenosa datetime, @datum datetime, @ter_vars char(2), @use_dat_dok bit, @id_terj varchar(50)									
									
SET @datum = convert(char(10),getdate() + @st_dni,112)									
SET @datum_prenosa = getdate()									
SET @ter_opc = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj = 'OPC')									
SET @ter_lobr = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj = 'LOBR')									
SET @ter_vars = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj = 'VARS')									
									
SET @use_dat_dok = (SELECT val FROM dbo.custom_settings WHERE code = 'Nova.LE.TrojnaOpcija.UseDatumDok')									
SET @use_dat_dok = ISNULL(@use_dat_dok, 0)									
									
SET @id_terj = (SELECT val FROM dbo.custom_settings WHERE code = 'Nova.LE.TrojnaOpcija.IdTerj')									
SET @id_terj = LTRIM(RTRIM(ISNULL(@id_terj, '')))									
									
IF (SELECT RIGHT(@id_terj, len(@id_terj) - (len(@id_terj) - 1))) = ','									
BEGIN									
	SET @id_terj = LEFT(@id_terj, LEN(@id_terj) - 1)								
END									
									
SELECT b.id_terj AS id_terj									
INTO #id_terj									
FROM dbo.gfn_split_ids(@id_terj , ',' ) a									
INNER JOIN vrst_ter b ON a.id = b.sif_terj									
									
									
--- 1. reminders should not be prepared for contract, that has at least one of document declared in custom_setting - it's later used in WHERE condition									
DECLARE @cs VARCHAR(max)									
SET @cs = (SELECT val FROM dbo.custom_settings WHERE code = 'Nova.Exclude.TrojnaOpcija_Obvestila') 									
									
SELECT DISTINCT a.ID_CONT									
INTO #excluded_contracts									
FROM dbo.DOKUMENT a									
INNER JOIN dbo.gfn_GetTableFromList(@cs) as exc ON exc.id = a.ID_OBL_ZAV 									
WHERE a.status_akt='A'									
									
CREATE INDEX IDX_excluded_contracts ON #excluded_contracts(id_cont)									
									
/******************************* INSERT INTO ODGNAOPC - obvestila ***********************************/									
									
IF @id_terj = ''									
BEGIN									
	-- st_dok-i terjatev za opcijo, ki so kandidati za obvestila								
	SELECT pp.st_dok, pp.id_cont 								
	INTO #tmp_opc 								
	FROM dbo.planp pp								
	INNER JOIN dbo.pogodba p ON pp.id_cont = p.id_cont								
	INNER JOIN dbo.statusi st ON p.status = st.status								
	INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas 								
	WHERE pp.id_terj = @ter_opc 								
		AND ((@use_dat_dok = 1 AND pp.datum_dok <= @datum) OR (@use_dat_dok = 0 AND pp.dat_zap <= @datum))							
	    AND p.status_akt = 'A' 								
	    AND p.trojna_opc = 0 								
	    AND n.obv_zakl = 1 								
	    AND pp.ddv_id = ''								
	    AND st.ne_fakt_odkup = 0								
	    AND dbo.gfn_ContractCanPrepareInstallmentNotifications(pp.id_cont) = 1								
									
	-- vse zadnje (lobr) terjatve pogodb, ki nimajo opcije in pridejo v postev								
	SELECT CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)								
				ELSE MAX(dat_zap) END AS dat_zap, 					
		    pp.id_cont 							
	INTO #tmp_lobr								
	FROM dbo.planp pp WITH (INDEX(ix_planp_icitdz))								
	INNER JOIN dbo.pogodba p ON pp.id_cont = p.id_cont								
	INNER JOIN dbo.statusi st ON p.status = st.status								
	INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas 								
	WHERE p.status_akt = 'A' 								
		AND p.trojna_opc = 0 							
	    AND n.obv_zakl = 1								
	    AND st.ne_fakt_odkup = 0 								
	-- AND pp.id_terj = @ter_lobr								
	    AND NOT EXISTS (SELECT id_cont FROM dbo.planp WHERE id_cont = pp.id_cont AND id_terj = @ter_opc)								
	    AND dbo.gfn_ContractCanPrepareInstallmentNotifications(pp.id_cont) = 1								
	GROUP BY pp.id_cont HAVING CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)								
									ELSE MAX(dat_zap) END <= @datum
									
	-- delete records from odgnaopc for contracts, that are in the list for new record preparation								
	DELETE FROM dbo.odgnaopc								
	WHERE id_cont IN (SELECT id_cont FROM #tmp_opc UNION SELECT id_cont FROM #tmp_lobr)								
		AND id_cont not in (SELECT ID_CONT FROM  #excluded_contracts )							
									
	-- insert into ODGNAOPC								
	INSERT INTO dbo.odgnaopc 								
		(id_cont, dat_zap, znesek, odgovor, id_kupca, izpisan, id_val, id_tec, 							
		id_dav_st, pred_naj, id_vrste, se_regis, ugodnost, id_terj, dat_pren)							
	SELECT pp.id_cont, 								
		CASE WHEN (@use_dat_dok = 1) THEN pp.datum_dok							
			 ELSE pp.dat_zap END AS dat_zap, 						
		pp.debit as znesek, ' ' as odgovor, pp.id_kupca, 0 as izpisan,							
		pp.id_val, pp.id_tec, pp.id_dav_st, pog.pred_naj, pog.id_vrste, vo.se_regis, ' ' as ugodnost,							
		pp.id_terj, @datum_prenosa as datum_prenosa							
	FROM dbo.planp pp								
	INNER JOIN dbo.pogodba pog ON pp.id_cont = pog.id_cont 								
	INNER JOIN dbo.vrst_opr vo ON pog.id_vrste = vo.id_vrste								
	LEFT JOIN #excluded_contracts exc ON exc.id_cont = pog.id_cont								
	WHERE st_dok in (								
		SELECT max(p.st_dok) from #tmp_lobr t 							
		INNER JOIN dbo.planp p ON p.id_cont = t.id_cont and ((@use_dat_dok = 1 AND p.datum_dok = t.dat_zap) OR (@use_dat_dok = 0 AND p.dat_zap = t.dat_zap))							
		WHERE p.id_terj = @ter_lobr							
		GROUP BY t.id_cont							
		UNION							
		SELECT st_dok from #tmp_opc							
	) 								
	AND exc.id_cont IS NULL		-- exclude all documents for contract, that has at least one active document, that is specified in custom_setting 						
	order by pp.id_cont								
									
	drop table #tmp_lobr								
	drop table #tmp_opc								
END									
ELSE									
BEGIN									
	--*****************************************OPC*******************************************************--								
									
	-- kandidati terjatev za opcijo, ki so kandidati za obvestila								
	SELECT pp.id_cont,								
		   pp.st_dok, 							
		   CASE WHEN pp2.dat_zap is not null THEN pp2.dat_zap							
				WHEN @use_dat_dok = 1 THEN pp.datum_dok					
				ELSE pp.dat_zap END AS dat_zap					
	INTO #tmp_opc_candidates								
	FROM dbo.planp pp								
	INNER JOIN dbo.pogodba p ON pp.id_cont = p.id_cont								
	INNER JOIN dbo.statusi st ON p.status = st.status								
	INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas								
	LEFT JOIN (								
		SELECT CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)							
					ELSE MAX(dat_zap) END AS dat_zap,				
			   id_cont						
		FROM dbo.planp							
		WHERE id_terj in (SELECT id_terj FROM #id_terj)							
		GROUP BY id_cont							
	) AS pp2 ON pp.id_cont = pp2.id_cont								
	WHERE pp.id_terj = @ter_opc 								
		AND ((@use_dat_dok = 1 AND pp.datum_dok <= @datum) OR (@use_dat_dok = 0 AND pp.dat_zap <= @datum))							
		AND p.status_akt = 'A' 							
		AND p.trojna_opc = 0 							
		AND n.obv_zakl = 1 							
		AND pp.ddv_id = ''							
		AND st.ne_fakt_odkup = 0							
		AND dbo.gfn_ContractCanPrepareInstallmentNotifications(pp.id_cont) = 1							
									
	-- delete records from odgnaopc for candidates with OPC								
	DELETE FROM dbo.odgnaopc								
	WHERE id_cont IN (SELECT id_cont FROM #tmp_opc_candidates)								
		AND id_cont not in (SELECT ID_CONT FROM  #excluded_contracts )							
									
	-- insert into ODGNAOPC candidates with OPC								
	INSERT INTO dbo.odgnaopc 								
		(id_cont, dat_zap, znesek, odgovor, id_kupca, izpisan, id_val, id_tec, 							
		id_dav_st, pred_naj, id_vrste, se_regis, ugodnost, id_terj, dat_pren)							
	SELECT pp.id_cont, 								
		   c.dat_zap, 							
		   pp.debit as znesek, ' ' as odgovor, pp.id_kupca, 0 as izpisan,							
		   pp.id_val, pp.id_tec, pp.id_dav_st, pog.pred_naj, pog.id_vrste, vo.se_regis, ' ' as ugodnost,							
		   pp.id_terj, @datum_prenosa as datum_prenosa							
	FROM dbo.planp pp								
	INNER JOIN #tmp_opc_candidates c ON c.st_dok = pp.st_dok								
	INNER JOIN dbo.pogodba pog ON pp.id_cont = pog.id_cont 								
	INNER JOIN dbo.vrst_opr vo ON pog.id_vrste = vo.id_vrste								
	LEFT JOIN #excluded_contracts exc ON exc.id_cont = pog.id_cont								
		AND exc.id_cont IS NULL		-- exclude all documents for contract, that has at least one active document, that is specified in custom_setting 					
									
	DROP TABLE #tmp_opc_candidates								
									
	--*****************************************LOBR*******************************************************--								
									
	-- kandidati, ki nimajo opcije in pridejo v postev								
	SELECT pp.id_cont 								
	INTO #tmp_lobr_candidates								
	FROM dbo.planp pp WITH (INDEX(ix_planp_icitdz))								
	INNER JOIN dbo.pogodba p ON pp.id_cont = p.id_cont								
	INNER JOIN dbo.statusi st ON p.status = st.status								
	INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas 								
	WHERE p.status_akt = 'A' 								
		AND p.trojna_opc = 0 							
		AND n.obv_zakl = 1							
		AND st.ne_fakt_odkup = 0 							
		AND NOT EXISTS (SELECT id_cont FROM dbo.planp WHERE id_cont = pp.id_cont AND id_terj = @ter_opc)							
		AND dbo.gfn_ContractCanPrepareInstallmentNotifications(pp.id_cont) = 1							
	GROUP BY pp.id_cont HAVING CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)								
									ELSE MAX(dat_zap) END <= @datum
									
	-- kandidati, ki imajo že izračunan dat_zap								
	SELECT pp.id_cont,								
		   CASE WHEN MAX(pp2.dat_zap) is not null THEN MAX(pp2.dat_zap)							
				WHEN @use_dat_dok = 1 THEN MAX(pp.datum_dok)					
				ELSE MAX(pp.dat_zap) END AS dat_zap,					
		   MAX(st_dok) as st_dok							
	INTO #tmp_lobr_candidates_with_dat_zap								
	FROM #tmp_lobr_candidates c								
	INNER JOIN dbo.planp pp ON c.id_cont = pp.id_cont								
	LEFT JOIN (								
		SELECT CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)							
					ELSE MAX(dat_zap) END AS dat_zap,				
			   id_cont						
		FROM dbo.planp							
		WHERE id_terj in (SELECT id_terj FROM #id_terj)							
		GROUP BY id_cont							
	) AS pp2 ON pp.id_cont = pp2.id_cont								
	GROUP BY pp.id_cont								
									
	-- delete records from odgnaopc for LOBR candidates								
	DELETE FROM dbo.odgnaopc								
	WHERE id_cont IN (SELECT id_cont FROM #tmp_lobr_candidates_with_dat_zap)								
		AND id_cont not in (SELECT ID_CONT FROM  #excluded_contracts )							
									
	-- insert into ODGNAOPC LOBR candidates								
	INSERT INTO dbo.odgnaopc 								
		(id_cont, dat_zap, znesek, odgovor, id_kupca, izpisan, id_val, id_tec, 							
		id_dav_st, pred_naj, id_vrste, se_regis, ugodnost, id_terj, dat_pren)							
	SELECT pp.id_cont, 								
		   c.dat_zap, 							
		   pp.debit as znesek, ' ' as odgovor, pp.id_kupca, 0 as izpisan,							
		   pp.id_val, pp.id_tec, pp.id_dav_st, pog.pred_naj, pog.id_vrste, vo.se_regis, ' ' as ugodnost,							
		   pp.id_terj, @datum_prenosa as datum_prenosa							
	FROM dbo.planp pp								
	INNER JOIN #tmp_lobr_candidates_with_dat_zap c ON c.st_dok = pp.st_dok								
	INNER JOIN dbo.pogodba pog ON pp.id_cont = pog.id_cont 								
	INNER JOIN dbo.vrst_opr vo ON pog.id_vrste = vo.id_vrste								
	LEFT JOIN #excluded_contracts exc ON exc.id_cont = pog.id_cont								
		AND exc.id_cont IS NULL		-- exclude all documents for contract, that has at least one active document, that is specified in custom_setting 					
									
	DROP TABLE #tmp_lobr_candidates								
	DROP TABLE #tmp_lobr_candidates_with_dat_zap								
END									
/*********************************************************************************************************************************************/									
IF @@Error <> 0 									
BEGIN									
	RETURN								
END									
									
/*************************************** INSERT INTO OPC_FAKT - fakture ****************************************************/									
									
-- temp table @opc_fakt									
declare @opc_fakt table (									
    id_cont int, id_kupca char(6), id_dav_st char(2), datum_dok datetime, dat_zap datetime, neto decimal(18,2), 									
    obresti decimal(18,2), robresti decimal(18,2), marza decimal(18,2), regist decimal(18,2), davek decimal(18,2), 									
    debit decimal(18,2), id_tec char(3), id_val char(3), st_dok char(21), izpisan bit, id_vrste char(4), 									
    se_regis char(1), opombe varchar(3000), st_kup_pog char(7), pog_kupec char(6) NULL, st_naroc char(20), 									
    ddv_date datetime NULL, ddv_id char(14) NULL, id_terj char(2), dat_pren datetime, id_zapo char(7) NULL, 									
    vnesel char(10) NULL)									
									
									
IF @id_terj = ''									
BEGIN									
	-- st_dok-i terjatev za opcijo, ki so kandidati za fakture								
	SELECT pp.st_dok, pp.id_cont, pp.id_tec INTO #tmp_opc1 FROM dbo.planp pp								
		INNER JOIN dbo.pogodba p on pp.id_cont = p.id_cont							
		INNER JOIN dbo.statusi st ON p.status = st.status							
		INNER JOIN dbo.nacini_l n on p.nacin_leas = n.nacin_leas 							
	WHERE pp.id_terj = @ter_opc AND ((@use_dat_dok = 1 AND pp.datum_dok <= @datum) OR (@use_dat_dok = 0 AND pp.dat_zap <= @datum))								
		AND p.status_akt='A'  AND p.trojna_opc = 0 							
		AND (((n.tip_knjizenja = 1 OR n.ol_na_nacin_fl = 1) AND n.ima_opcijo = 1) OR (p.pred_ddv=1 AND n.leas_kred = 'L')) 							
		AND pp.ddv_id = ''							
		AND st.ne_fakt_odkup = 0 							
		AND dbo.gfn_ContractCanBookDueClaims(pp.id_cont) = 1							
									
	-- vse zadnje (lobr) terjatve pogodb, ki nimajo opcije in pridejo v postev								
	SELECT CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)								
				ELSE MAX(dat_zap) END AS dat_zap, 					
		   pp.id_cont 							
	INTO #tmp_lobr1								
	FROM 								
		dbo.planp pp WITH (INDEX(ix_planp_icitdz))							
		INNER JOIN dbo.pogodba p on pp.id_cont = p.id_cont							
		INNER JOIN dbo.statusi st ON p.status = st.status							
		INNER JOIN dbo.nacini_l n on p.nacin_leas = n.nacin_leas 							
	where p.status_akt = 'A' and p.trojna_opc = 0 AND pp.id_terj = @ter_lobr								
		AND st.ne_fakt_odkup = 0 							
		--AND (p.pred_ddv=1 AND n.leas_kred = 'L')							
		AND (((n.tip_knjizenja = 1 OR n.ol_na_nacin_fl = 1) AND n.ima_opcijo = 1) OR (p.pred_ddv=1 AND n.leas_kred = 'L')) 							
		and not exists (select id_cont from dbo.planp where id_cont = pp.id_cont and id_terj = @ter_opc)							
		AND dbo.gfn_ContractCanBookDueClaims(pp.id_cont) = 1							
	group by pp.id_cont HAVING CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)								
									ELSE MAX(dat_zap) END <= @datum
									
	-- vse terjatve varscine za pogodbe, ki imajo OPC								
	SELECT SUM(dbo.gfn_XChange(tmp.id_tec, pp.debit, pp.id_tec, getdate())) AS varscina, pp.id_cont								
	INTO #tmp_vars_opc								
	FROM 								
		dbo.planp pp							
		INNER JOIN #tmp_opc1 tmp ON pp.id_cont = tmp.id_cont							
	WHERE pp.id_terj = @ter_vars 								
	GROUP BY pp.id_cont								
									
	-- vse terjatve varscine za pogodbe, za vse zadnje (lobr) terjatve pogodb, ki nimajo opcije in pridejo v postev								
	SELECT SUM(dbo.gfn_XChange(tmp.id_tec, pp.debit, pp.id_tec, getdate())) AS varscina, pp.id_cont								
	INTO #tmp_vars_lobr								
	FROM 								
		dbo.planp pp							
		INNER JOIN (							
			SELECT t.id_cont, pp1.id_tec						
			FROM 						
				#tmp_lobr1 t					
				INNER JOIN dbo.planp pp1 ON pp1.id_cont = t.id_cont AND ((@use_dat_dok = 1 AND pp1.datum_dok = t.dat_zap) OR (@use_dat_dok = 0 AND pp1.dat_zap = t.dat_zap))					
			) tmp ON pp.id_cont = tmp.id_cont						
	WHERE pp.id_terj = @ter_vars 								
	GROUP BY pp.id_cont								
									
	-- Insert OPC_FAKT								
	INSERT INTO @opc_fakt 								
		(id_cont, id_kupca, id_dav_st, datum_dok, dat_zap, neto, obresti, robresti, marza, regist, 							
		davek, debit, id_tec, id_val, st_dok, izpisan, id_vrste, se_regis, opombe, st_kup_pog, 							
		pog_kupec, st_naroc, ddv_date, ddv_id, id_terj, dat_pren, id_zapo, vnesel)							
									
	-- terjatve za opcijo (sif_terj='OPC')								
	SELECT pp.id_cont, pp.id_kupca, pp.id_dav_st, 								
	    CASE WHEN (@use_dat_dok = 1) THEN pp.datum_dok								
			 ELSE pp.dat_zap END AS datum_dok,						
		CASE WHEN (@use_dat_dok = 1) THEN pp.datum_dok							
			 ELSE pp.dat_zap END AS dat_zap, 						
		pp.neto + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) ELSE 0 END) AS neto, 							
		pp.obresti, pp.robresti, pp.marza, pp.regist,							
		pp.davek + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) * (pp.dav_vred/100) ELSE 0 END) AS davek,							
		pp.debit + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) * (1 + (pp.dav_vred/100)) ELSE 0 END) AS debit,							
		pp.id_tec, pp.id_val, pp.st_dok, 0 as izpisan,							
		pog.id_vrste, vo.se_regis, '' as opombe, '' as st_kup_pog, null as pog_kupec, '' as st_naroc, 							
		null as ddv_date, null as ddv_id, pp.id_terj, @datum_prenosa,							
		i.id_zapo, 'DNEV_RUT'							
	FROM 								
		dbo.planp pp							
		INNER JOIN dbo.pogodba pog ON pp.id_cont = pog.id_cont 							
		INNER JOIN dbo.nacini_l n ON pp.nacin_leas = n.nacin_leas 							
		INNER JOIN dbo.vrst_opr vo ON pog.id_vrste = vo.id_vrste							
		LEFT JOIN (SELECT MAX(id_zapo) AS id_zapo,id_cont FROM dbo.gv_zapisniki GROUP BY id_cont) i ON pog.id_cont = i.id_cont							
		LEFT JOIN #tmp_vars_opc tv ON pp.id_cont = tv.id_cont							
	WHERE pp.st_dok IN (SELECT st_dok FROM #tmp_opc1)								
									
	UNION								
									
	-- terjatve za zadnji obrok če ni terjatve za opcijo (izključuje zgornji select)								
	SELECT pp.id_cont, pp.id_kupca, pp.id_dav_st,								
		CASE WHEN (@use_dat_dok = 1) THEN pp.datum_dok							
			 ELSE pp.dat_zap END AS datum_dok,						
		CASE WHEN (@use_dat_dok = 1) THEN pp.datum_dok							
			 ELSE pp.dat_zap END AS dat_zap,						
		case when n.ima_opcijo = 1 then 0 + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0)  ELSE 0 END) else pp.neto end  AS neto, 							
		case when n.ima_opcijo = 1 then 0 else pp.obresti end as obresti,							
		case when n.ima_opcijo = 1 then 0 else pp.robresti end as robresti, 							
		case when n.ima_opcijo = 1 then 0 else pp.marza end as marza, 							
		case when n.ima_opcijo = 1 then 0 else pp.regist end as regist, 							
		case when n.ima_opcijo = 1 then 0 + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) * (pp.dav_vred/100)  ELSE 0 END) else pp.davek end  as davek, 							
		case when n.ima_opcijo = 1 then 0 + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) * (1 + (pp.dav_vred/100)) ELSE 0 END) else pp.debit end AS debit, 							
		pp.id_tec, pp.id_val, 							
		case when n.ima_opcijo = 1 							
			then left(rtrim(pog.id_pog) + '-' + @ter_opc + '-' + replicate('0', 3-len(cast(pp.zap_obr + 1 as char(3)))) + cast(pp.zap_obr + 1 as char(3)), 21) 						
			else pp.st_dok end as st_dok,						
		0 as izpisan, pog.id_vrste, vo.se_regis, '' as opombe, '' as st_kup_pog, null as pog_kupec, '' as st_naroc, 							
		null as ddv_date, null as ddv_id, @ter_opc as id_terj, @datum_prenosa,							
		i.id_zapo, 'DNEV_RUT'							
	FROM 								
		dbo.planp pp							
		INNER JOIN dbo.pogodba pog ON pp.id_cont = pog.id_cont 							
		INNER JOIN dbo.nacini_l n ON pp.nacin_leas = n.nacin_leas 							
		INNER JOIN dbo.vrst_opr vo ON pog.id_vrste = vo.id_vrste							
		LEFT JOIN (SELECT MAX(id_zapo) AS id_zapo,id_cont FROM dbo.gv_zapisniki GROUP BY id_cont) i ON pog.id_cont = i.id_cont							
		LEFT JOIN #tmp_vars_lobr tv ON pp.id_cont = tv.id_cont							
	WHERE pp.st_dok IN (								
		SELECT p.st_dok from #tmp_lobr1 t 							
		INNER JOIN dbo.planp p ON p.id_cont = t.id_cont and ((@use_dat_dok = 1 AND p.datum_dok = t.dat_zap) OR (@use_dat_dok = 0 AND p.dat_zap = t.dat_zap))							
		WHERE p.id_terj = @ter_lobr							
	)								
									
	drop table #tmp_lobr1								
	drop table #tmp_opc1								
	DROP TABLE #tmp_vars_opc								
	DROP TABLE #tmp_vars_lobr								
END									
ELSE									
BEGIN									
	--***************************************************OPC***********************************************************************--								
									
	-- kandidati terjatev za opcijo, ki so kandidati za fakture								
	SELECT pp.id_cont, 								
		   pp.st_dok, 							
		   pp.id_tec,							
		   CASE WHEN pp2.dat_zap is not null THEN pp2.dat_zap							
				WHEN @use_dat_dok = 1 THEN pp.datum_dok					
				ELSE pp.dat_zap END AS dat_zap					
	INTO #tmp_opc1_candidates 								
	FROM dbo.planp pp								
	INNER JOIN dbo.pogodba p on pp.id_cont = p.id_cont								
	INNER JOIN dbo.statusi st ON p.status = st.status								
	INNER JOIN dbo.nacini_l n on p.nacin_leas = n.nacin_leas 								
	LEFT JOIN (								
		SELECT CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)							
					ELSE MAX(dat_zap) END AS dat_zap,				
			   id_cont						
		FROM dbo.planp							
		WHERE id_terj in (SELECT id_terj FROM #id_terj)							
		GROUP BY id_cont							
	) AS pp2 ON pp.id_cont = pp2.id_cont								
	WHERE pp.id_terj = @ter_opc AND ((@use_dat_dok = 1 AND pp.datum_dok <= @datum) OR (@use_dat_dok = 0 AND pp.dat_zap <= @datum))								
		AND p.status_akt='A'  AND p.trojna_opc = 0 							
		AND (((n.tip_knjizenja = 1 OR n.ol_na_nacin_fl = 1) AND n.ima_opcijo = 1) OR (p.pred_ddv=1 AND n.leas_kred = 'L')) 							
		AND pp.ddv_id = ''							
		AND st.ne_fakt_odkup = 0 							
		AND dbo.gfn_ContractCanBookDueClaims(pp.id_cont) = 1							
									
	-- vse terjatve varscine za pogodbe, ki imajo OPC								
	SELECT SUM(dbo.gfn_XChange(tmp.id_tec, pp.debit, pp.id_tec, getdate())) AS varscina, pp.id_cont								
	INTO #tmp_vars_opc1								
	FROM 								
		dbo.planp pp							
		INNER JOIN #tmp_opc1_candidates  tmp ON pp.id_cont = tmp.id_cont							
	WHERE pp.id_terj = @ter_vars 								
	GROUP BY pp.id_cont								
									
	-- Insert OPC in OPC_FAKT								
	INSERT INTO @opc_fakt 								
		(id_cont, id_kupca, id_dav_st, datum_dok, dat_zap, neto, obresti, robresti, marza, regist, 							
		davek, debit, id_tec, id_val, st_dok, izpisan, id_vrste, se_regis, opombe, st_kup_pog, 							
		pog_kupec, st_naroc, ddv_date, ddv_id, id_terj, dat_pren, id_zapo, vnesel)							
	SELECT pp.id_cont, pp.id_kupca, pp.id_dav_st, 								
		c.dat_zap as dat_dok, c.dat_zap as dat_zap,							
		pp.neto + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) ELSE 0 END) AS neto, 							
		pp.obresti, pp.robresti, pp.marza, pp.regist,							
		pp.davek + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) * (pp.dav_vred/100) ELSE 0 END) AS davek,							
		pp.debit + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) * (1 + (pp.dav_vred/100)) ELSE 0 END) AS debit,							
		pp.id_tec, pp.id_val, pp.st_dok, 0 as izpisan,							
		pog.id_vrste, vo.se_regis, '' as opombe, '' as st_kup_pog, null as pog_kupec, '' as st_naroc, 							
		null as ddv_date, null as ddv_id, pp.id_terj, @datum_prenosa,							
		i.id_zapo, 'DNEV_RUT'							
	FROM 								
		dbo.planp pp							
		INNER JOIN #tmp_opc1_candidates c ON c.st_dok = pp.st_dok							
		INNER JOIN dbo.pogodba pog ON pp.id_cont = pog.id_cont 							
		INNER JOIN dbo.nacini_l n ON pp.nacin_leas = n.nacin_leas 							
		INNER JOIN dbo.vrst_opr vo ON pog.id_vrste = vo.id_vrste							
		LEFT JOIN (SELECT MAX(id_zapo) AS id_zapo,id_cont FROM dbo.gv_zapisniki GROUP BY id_cont) i ON pog.id_cont = i.id_cont							
		LEFT JOIN #tmp_vars_opc1 tv ON pp.id_cont = tv.id_cont							
									
	DROP TABLE #tmp_opc1_candidates 								
	DROP TABLE #tmp_vars_opc1								
									
	--***************************************************LOBR***********************************************************************--								
	-- kandidati, ki nimajo opcije in pridejo v postev								
	SELECT pp.id_cont								
	INTO #tmp_lobr1_candidates								
	FROM 								
		dbo.planp pp WITH (INDEX(ix_planp_icitdz))							
		INNER JOIN dbo.pogodba p on pp.id_cont = p.id_cont							
		INNER JOIN dbo.statusi st ON p.status = st.status							
		INNER JOIN dbo.nacini_l n on p.nacin_leas = n.nacin_leas 							
	where p.status_akt = 'A' and p.trojna_opc = 0 AND pp.id_terj = @ter_lobr								
		AND st.ne_fakt_odkup = 0 							
		--AND (p.pred_ddv=1 AND n.leas_kred = 'L')							
		AND (((n.tip_knjizenja = 1 OR n.ol_na_nacin_fl = 1) AND n.ima_opcijo = 1) OR (p.pred_ddv=1 AND n.leas_kred = 'L')) 							
		and not exists (select id_cont from dbo.planp where id_cont = pp.id_cont and id_terj = @ter_opc)							
		AND dbo.gfn_ContractCanBookDueClaims(pp.id_cont) = 1							
	group by pp.id_cont HAVING CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)								
									ELSE MAX(dat_zap) END <= @datum
									
	-- kandidati, ki imajo že izračunan dat_zap								
	SELECT pp.id_cont,								
	   CASE WHEN MAX(pp2.dat_zap) is not null THEN MAX(pp2.dat_zap)								
            WHEN @use_dat_dok = 1 THEN MAX(pp.datum_dok)									
            ELSE MAX(pp.dat_zap) END AS dat_zap,									
		    MAX(st_dok) as st_dok							
	INTO #tmp_lobr_candidates1_with_dat_zap								
	FROM #tmp_lobr1_candidates c								
	INNER JOIN dbo.planp pp ON c.id_cont = pp.id_cont								
	LEFT JOIN (								
		SELECT CASE WHEN (@use_dat_dok = 1) THEN MAX(datum_dok)							
					ELSE MAX(dat_zap) END AS dat_zap,				
			   id_cont						
		FROM dbo.planp							
		WHERE id_terj in (SELECT id_terj FROM #id_terj)							
		GROUP BY id_cont							
	) AS pp2 ON pp.id_cont = pp2.id_cont								
	GROUP BY pp.id_cont								
									
	-- vse terjatve varscine za pogodbe, ki so brez OPC (LOBR)								
	SELECT SUM(dbo.gfn_XChange(tmp.id_tec, pp.debit, pp.id_tec, getdate())) AS varscina, pp.id_cont								
	INTO #tmp_vars_lobr1								
	FROM 								
		dbo.planp pp							
		INNER JOIN (							
			SELECT t.id_cont, pp1.id_tec						
			FROM 						
				#tmp_lobr_candidates1_with_dat_zap t					
				INNER JOIN dbo.planp pp1 ON pp1.st_dok = t.st_dok					
			) tmp ON pp.id_cont = tmp.id_cont						
	WHERE pp.id_terj = @ter_vars 								
	GROUP BY pp.id_cont								
									
	-- Insert OPC in OPC_FAKT								
	INSERT INTO @opc_fakt 								
		(id_cont, id_kupca, id_dav_st, datum_dok, dat_zap, neto, obresti, robresti, marza, regist, 							
		davek, debit, id_tec, id_val, st_dok, izpisan, id_vrste, se_regis, opombe, st_kup_pog, 							
		pog_kupec, st_naroc, ddv_date, ddv_id, id_terj, dat_pren, id_zapo, vnesel)							
	SELECT pp.id_cont, pp.id_kupca, pp.id_dav_st,								
		c.dat_zap as dat_dok, c.dat_zap as dat_zap,							
		case when n.ima_opcijo = 1 then 0 + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0)  ELSE 0 END) else pp.neto end  AS neto, 							
		case when n.ima_opcijo = 1 then 0 else pp.obresti end as obresti,							
		case when n.ima_opcijo = 1 then 0 else pp.robresti end as robresti, 							
		case when n.ima_opcijo = 1 then 0 else pp.marza end as marza, 							
		case when n.ima_opcijo = 1 then 0 else pp.regist end as regist, 							
		case when n.ima_opcijo = 1 then 0 + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) * (pp.dav_vred/100)  ELSE 0 END) else pp.davek end  as davek, 							
		case when n.ima_opcijo = 1 then 0 + (CASE WHEN n.odstej_var = 1 THEN ISNULL(tv.varscina, 0) * (1 + (pp.dav_vred/100)) ELSE 0 END) else pp.debit end AS debit, 							
		pp.id_tec, pp.id_val, 							
		case when n.ima_opcijo = 1 							
			then left(rtrim(pog.id_pog) + '-' + @ter_opc + '-' + replicate('0', 3-len(cast(pp.zap_obr + 1 as char(3)))) + cast(pp.zap_obr + 1 as char(3)), 21) 						
			else pp.st_dok end as st_dok,						
		0 as izpisan, pog.id_vrste, vo.se_regis, '' as opombe, '' as st_kup_pog, null as pog_kupec, '' as st_naroc, 							
		null as ddv_date, null as ddv_id, @ter_opc as id_terj, @datum_prenosa,							
		i.id_zapo, 'DNEV_RUT'							
	FROM 								
		dbo.planp pp							
		INNER JOIN #tmp_lobr_candidates1_with_dat_zap c ON c.st_dok = pp.st_dok							
		INNER JOIN dbo.pogodba pog ON pp.id_cont = pog.id_cont 							
		INNER JOIN dbo.nacini_l n ON pp.nacin_leas = n.nacin_leas 							
		INNER JOIN dbo.vrst_opr vo ON pog.id_vrste = vo.id_vrste							
		LEFT JOIN (SELECT MAX(id_zapo) AS id_zapo,id_cont FROM dbo.gv_zapisniki GROUP BY id_cont) i ON pog.id_cont = i.id_cont							
		LEFT JOIN #tmp_vars_lobr1 tv ON pp.id_cont = tv.id_cont							
									
	DROP TABLE #tmp_lobr1_candidates								
	DROP TABLE #tmp_lobr_candidates1_with_dat_zap								
	DROP TABLE #tmp_vars_lobr1								
END									
									
DROP TABLE #id_terj									
									
-- check if st_dok exists in opc_fakt									
select a.st_dok, dbo.gfn_id_pog4id_cont(a.id_cont) id_pog, isnull(a.id_zapo, '/') id_zapo 									
into #tmp									
from @opc_fakt a									
where a.st_dok in (select b.st_dok from dbo.opc_fakt b)									
									
IF (select count(*) from #tmp) <> 0									
BEGIN									
    DECLARE @error_string varchar(4000), @st_dok varchar(21), @id_pog varchar(8), @id_zapo varchar(7)									
    SET @error_string = 'E_RoutineStDokExistsBuyoutInvoice|'									
        									
    DECLARE _ErrTab CURSOR FAST_FORWARD FOR									
    SELECT st_dok, id_pog, id_zapo FROM #tmp ORDER BY id_pog, st_dok									
									
    OPEN _ErrTab									
    FETCH NEXT FROM _ErrTab INTO @st_dok, @id_pog, @id_zapo									
									
    WHILE @@FETCH_STATUS = 0									
    BEGIN									
        set @error_string = @error_string + @st_dok + '; ' + @id_pog + '; ' + @id_zapo + char(13) + char(10)									
        FETCH NEXT FROM _ErrTab INTO @st_dok, @id_pog, @id_zapo									
    END									
									
    CLOSE _ErrTab									
    DEALLOCATE _ErrTab									
									
    RAISERROR(@error_string, 16, 1)									
	RETURN									
END									

drop table #tmp										
DROP TABLE #excluded_contracts									
/**************************************************************************************************/									
IF @@Error <> 0 									
BEGIN									
	RETURN								
END									

-- INSERT INTO OPC_FAKT FROM CURSOR WHERE ST_DOK NOT IN OPC_FAKT									
INSERT INTO dbo.opc_fakt 									
	(id_cont, id_kupca, id_dav_st, datum_dok, dat_zap, neto, obresti, robresti, marza, regist, 								
	davek, debit, id_tec, id_val, st_dok, izpisan, id_vrste, se_regis, opombe, st_kup_pog, 								
	pog_kupec, st_naroc, ddv_date, ddv_id, id_terj, dat_pren, id_zapo, vnesel)								
SELECT id_cont, id_kupca, id_dav_st, datum_dok, dat_zap, neto, obresti, robresti, marza, regist, 									
		davek, debit, id_tec, id_val, st_dok, izpisan, id_vrste, se_regis, opombe, st_kup_pog, 							
		pog_kupec, st_naroc, ddv_date, ddv_id, id_terj, dat_pren, id_zapo, vnesel 							
FROM @opc_fakt									
WHERE st_dok NOT IN (SELECT st_dok FROM dbo.opc_fakt)									


-- označimo v pogodbah, da je so bile opcije prenešene									
UPDATE dbo.pogodba SET trojna_opc = 1 WHERE id_cont IN 									
	(SELECT id_cont FROM dbo.odgnaopc WHERE dat_pren = @datum_prenosa								
	 UNION								
	 SELECT id_cont FROM dbo.opc_fakt WHERE dat_pren = @datum_prenosa)								
IF @@Error <> 0 									
BEGIN									
	RETURN								
END									
