----------------------------------------------------------
--gsp_registration
----------------------------------------------------------

IF (EXISTS(SELECT 'x' FROM dbo.sysobjects WHERE name='gsp_registration'))
                    BEGIN DROP procedure gsp_registration END
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
------------------------------------------------------------------------------------------------------------------------------
-- This procedure checks for documents regarding registration that are due in @days days. 
-- Then it prepares new documents and inserts new notices into za_regis table when necessary.
-- Parameters:
-- @days - for how many days in advance the documents are prepared
-- @user_name - name of the user executing the procedure
--
-- History:
-- 15.01.2004 Matjaz; created
-- 19.01.2004 Matjaz; changed name of dokument.id_za_regis to dokument.id_master
-- 20.01.2004 Matjaz; fixed sp due to type change of column izpisan in table za_regis
-- 22.01.2004 Matjaz; added fields to table za_regis
-- 01.03.2004 Matjaz; field datum of new documents is now set to velja_do, field datum_dok is set to getdate()
-- 16.03.2004 Matjaz; fixed bug: datediff was used instead of dateadd for determining the new date for filed velja_do
-- 22.03.2004 Matjaz; Changes due to id_cont 2 PK transition
-- 14.04.2004 Matjaz; Removed columns AKONT and DAT_DOK_A from za_regis table
-- 12.01.2005 Matjaz; added join on zap_reg to get only documents for registration
-- 26.01.2005 Matjaz; added condition k.ali_obv = 1
-- 03.02.2005 Matjaz; modified ON SITE - added condition for contracts that will end soon and to prepare notices only for active contracts
-- 03.02.2005 Matjaz; modified ON SITE - fixed bug in dateadd (it was y instead of yy)
-- 03.02.2005 Matjaz; modified ON SITE - added dni_obv to new value of datum in new document
-- 09.08.2005 Matjaz; changed value to be inserted into dokument.datum from velja_do + dni_obv to velja_do + dni_zap
-- 12.08.2005 Matjaz; bugfix - added dni_into initial select
-- 26.08.2005 Matjaz; changes due to new column dokument.reg_stev
-- 28.09.2005 Matjaz; reorganized initial select due to optimization and added prints for performance control
-- 22.11.2006 Matjaz; [EUR project] - changed that new documents are generated with new_id_tec if one exists
-- 02.03.2007 Vilko; Maintenance ID 7594 - fixed join between za_regis and dokument - added join on id_cont
-- 01.02.2008 Vilko; Bug ID 27121 - fixed insert into za_regis due new fields strosek1 and strosek2
-- 19.02.2008 Jasna; MID 13315 - added new fields, strosek3 and prem_pop
-- 31.07.2008 Vilko; MID 16032 - added update of fields popravil and dat_poprave
-- 14.08.2008 Ziga; MID 16151 - added check for field statusi.ne_obv_reg where preparing document candidates
-- 19.03.2009 Vilko; MID 20023 - changed insert into za_regis due to new field prv_obr
-- 08.03.2011 Jasna; MID 28906 -  change left join in #ending_contracts part; using dbo.gv_planp_ds_by_contract
-- 05.07.2011 Jasna; BUG 28930 - deleted condition ima = 1 in #dok_candidates and added new condition for datum in #za_regis_candidates 
-- 13.12.2011 Vilko; Bug ID 29146 - fixed updating field id_master in table dokument in last update statement
-- 25.01.2012 Vilko; Bug ID 29220 - fixed updating field id_master in table dokument in last update statement
-- 18.09.2012 IgorS; Bug ID 29226 - added new field dni_zap_old
-- 29.08.2013 Ales; MID 41488 - removed contracts that have debt from ending contracts
-- 02.09.2013 Ales; MID 41488 - removed contracts that have debt from ending contracts
-- 03.01.2014 Ales; MID 43836 - fixed ending contracts select - check if saldo is null; fixed select for candidates for insert into za_regis - check new setting
-- 06.03.2014 Jelena; MID 49929 - added insert into fields rang_hipo, is_elligible, dok_in_safe, status_zk, tip_cen, kategorija1, kategorija2, kategorija3 in table dokument
-- 17.12.2015 Andrej; MID 54014 - added transfering fields from old document depending on custom setting 'DueRegistration_dokumentNontransferFields'
------------------------------------------------------------------------------------------------------------------------------

CREATE       PROCEDURE [dbo].[gsp_Registration] (@days int, @user_name varchar(10))
AS

DECLARE @today datetime
SET @today = getdate()
---------------------------------------------------------------------------------------------------------------------------------
print('1: ' + convert(char(100),@today,120))

DECLARE @RegWarnOldDebtors bit
SET @RegWarnOldDebtors = (SELECT val FROM dbo.custom_settings WHERE code = 'Nova.LE.DailyRoutines.RegWarnOldDebtors')

IF @RegWarnOldDebtors IS NULL 
BEGIN
	SET @RegWarnOldDebtors = 0
END

DECLARE @documentFieldsNotTransferFromOld varchar(max)
SET @documentFieldsNotTransferFromOld = (SELECT val FROM dbo.custom_settings WHERE code = 'DueRegistration_dokumentNontransferFields')
declare @documentFieldsNotTransferFromOld_tab table (id varchar(100)) 
insert into @documentFieldsNotTransferFromOld_tab select a.id from dbo.gfn_split_ids(@documentFieldsNotTransferFromOld, ',') a where a.id != '' 

-- get all ending contracts
-- removed ending contracts that have debt
SELECT distinct a.id_cont INTO #ending_contracts
FROM dbo.pogodba a 
LEFT OUTER JOIN dbo.gv_planp_ds_by_contract b ON a.id_cont = b.id_cont
INNER JOIN dbo.partner c ON c.id_kupca = a.id_kupca
WHERE a.status_akt = 'A' AND
(b.id_cont is null OR b.max_dat_zap <= DATEADD(d, @days, @today)) AND
((@RegWarnOldDebtors = 1 AND ISNULL(b.saldo,0) <= 0 ) OR @RegWarnOldDebtors = 0)

print('2: ' + convert(char(100),@today,120))

-- get all documents, which are due in @days days and haven't been tranferred yet
SELECT d.*, k.dni_zap_old INTO #dok_candidates
FROM dbo.dokument d
INNER JOIN dbo.dok k ON d.id_obl_zav = k.id_obl_zav
INNER JOIN dbo.zap_reg z ON d.id_zapo = z.id_zapo -- to make sure we only get documents for registration
INNER JOIN dbo.pogodba p ON p.id_cont = d.id_cont
INNER JOIN dbo.statusi st on p.status = st.status
WHERE 
	k.ali_na_zreg = 1 AND -- only those, that have to do with registration
	k.ali_obv = 1 AND -- only those, that are marked for notification
	d.velja_do <= DATEADD(d, @days, @today) AND -- which are due in @days days from today
	d.status_akt = 'A' AND p.status_akt = 'A' AND -- only for active documents and active contracts
	--d.ima = 1 AND ima is irrelevant 
    st.ne_obv_reg = 0 AND -- only those contracts, that do not have blocked reg. notifications via status in table statusi
	d.id_cont NOT IN (SELECT id_cont FROM #ending_contracts)
--	dbo.gfn_MaxDatZapInPlanP(d.id_cont) > DATEADD(d, @days, getdate()) -- don't prepare notices for contracts that will soon end

print('3: ' + convert(char(100),@today,120))
---------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------
-- set status of all transferred documents to 'E' (ending) so that we don't tranfer tham again next time
UPDATE dbo.dokument 
   SET status_akt = 'E',
       popravil = 'DNEV_RUT',
       dat_poprave = @today
WHERE id_dokum IN (SELECT id_dokum FROM #dok_candidates)

print('4: ' + convert(char(100),@today,120))
---------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------
-- generate new documents in table dokument
INSERT INTO dbo.dokument
(dat_1op, dat_2op, dat_3op, dat_obv, dat_vink, datum, datum_dok, ddv_id, id_hipot, id_obl_zav, id_parent, 
id_cont, id_sdk, id_tec, id_master, id_zapo, id_zav, ima, kolicina, konec, opis, opis1, opombe, opravi_sam, 
potrebno, reg_stev, st_nalepke, st_vink, status_akt, stevilka, velja_do, vnesel, vrednost, vrst_red_d, 
vrsta, zacetek, zav_je_on, popravil, dat_poprave, 
rang_hipo, is_elligible, dok_in_safe, status_zk, tip_cen, kategorija1, kategorija2, kategorija3
)

SELECT 
	null, 			-- DAT_1OP
	null, 			-- DAT_2OP
	null, 			-- DAT_3OP
	null, 			-- DAT_OBV
	null, 			-- DAT_VINK
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'datum') THEN null
		ELSE d.velja_do + dni_zap_old
	END,			-- DATUM
	@today, 		-- DATUM_DOK
	null, 			-- DDV_ID
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'id_hipot') THEN null
		ELSE d.id_hipot
	END,			-- ID_HIPOT
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'id_obl_zav') THEN ''
		ELSE d.id_obl_zav
	END,			-- ID_OBL_ZAV
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'id_parent') THEN null
		ELSE d.id_dokum
	END,			-- ID_PARENT
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'id_cont') THEN null
		ELSE d.id_cont
	END,			-- ID_CONT
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'id_sdk') THEN null
		ELSE d.id_sdk
	END,			-- ID_SDK
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'id_tec') THEN null
		ELSE dbo.gfn_GetNewTec(d.id_tec)
	END,			-- ID_TEC
	-1, 			-- ID_MASTER; the value -1 is just temporary, so that we mark all newly generated documents
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'id_zapo') THEN ''
		ELSE d.id_zapo
	END,			-- ID_ZAPO
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'id_zav') THEN null
		ELSE d.id_zav
	END,			-- ID_ZAV
	0, 				-- IMA
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'kolicina') THEN 0
		ELSE d.kolicina
	END,			-- KOLICINA
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'konec') THEN null
		ELSE d.konec 
	END,			-- KONEC
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'opis') THEN ''
		ELSE d.opis 
	END,			-- OPIS
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'd.opis1') THEN ''
		ELSE d.opis1
	END,			-- OPIS1
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'opombe') THEN ''
		ELSE d.opombe
	END,			-- OPOMBE
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'opravi_sam') THEN 0
		ELSE d.opravi_sam
	END,			-- OPRAVI_SAM
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'potrebno') THEN 0
		ELSE d.potrebno
	END,			-- POTREBNO
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'reg_stev') THEN ''
		ELSE d.reg_stev
	END,			-- REG_STEV
	'', 			-- ST_NALEPKE
	'', 			-- ST_VINK
	'A', 			-- STATUS_AKT
	'', 			-- STEVILKA
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'velja_do') THEN null
		ELSE DATEADD(yy, 1, d.velja_do)
	END,			-- VELJA_DO
	'DNEV_RUT', 	-- VNESEL
	0, 				-- VREDNOST
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'vrst_red_d') THEN ''
		ELSE d.vrst_red_d
	END,			-- VRST_RED_D 
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'vrsta') THEN ''
		ELSE d.vrsta
	END,			-- VRSTA 
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'zacetek') THEN null
		ELSE d.velja_do
	END,			-- ZACETEK
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'zav_je_on') THEN 0
		ELSE d.zav_je_on
	END,			-- ZAV_JE_ON
    'DNEV_RUT',		-- POPRAVIL
    @today,			-- DAT_POPRAVE
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'rang_hipo') THEN 0
		ELSE d.rang_hipo
	END,			-- rang_hipo
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'is_elligible') THEN 0
		ELSE d.is_elligible
	END,			-- is_elligible
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'dok_in_safe') THEN 0
		ELSE d.dok_in_safe
	END,			-- dok_in_safe
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'status_zk') THEN ''
		ELSE d.status_zk
	END,			-- status_zk
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'tip_cen') THEN ''
		ELSE d.tip_cen
	END,			-- tip_cen
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'kategorija1') THEN null
		ELSE d.kategorija1
	END,			-- kategorija1
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'kategorija2') THEN null
		ELSE d.kategorija2
	END,			-- kategorija2
	CASE 
		WHEN exists (SELECT * FROM @documentFieldsNotTransferFromOld_tab WHERE id = 'kategorija3') THEN null
		ELSE d.kategorija3
	END				-- kategorija3

FROM #dok_candidates d

print('5: ' + convert(char(100),getdate(),120))
---------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------
-- get candidates for insert into za_regis
SELECT d.id_zapo, d.opravi_sam, d.id_cont INTO #za_regis_candidates 
FROM dbo.dokument d
WHERE d.id_master = -1 AND -- only newly generated documents

	-- if an active (je_faktura=0) notice (dopis) with same id_zapo and opravi_sam already exists in za_regis, 
	-- then there is no need to insert a new record; a candidate document from table dokument can get
	-- id_za_regis of the existing record and thus join the existing record as a new child
	NOT EXISTS (
		SELECT * FROM dbo.za_regis 
		 WHERE id_zapo = d.id_zapo 
           AND opravi_sam = d.opravi_sam  -- relation to dokument
		   AND je_faktura = 0 -- active notice
           AND id_cont = d.id_cont
           )
    	-- to exclude old documents; new generated documents, because of fix in upper code (ima = 1 is out!) can have old date 
    AND (@RegWarnOldDebtors = 1  OR (@RegWarnOldDebtors = 0 AND d.datum > @today))
GROUP BY d.id_zapo, d.opravi_sam, d.id_cont -- for each combination of id_zapo and opravi_sam one record is generated in za_regis

print('6: ' + convert(char(100),getdate(),120))
---------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------
-- generate new records in za_regis
INSERT INTO dbo.za_regis (
avtomatski, brez_davka, cest, dat_dok_r, dat_dopisa, datum_dok, ddv_date, ddv_id, debit, 
debit_neto, debit_davek, dok_regis, id_dav_st, id_kupca, id_opr, id_cont, id_val, id_zapo, izpisan, je_faktura, 
na_obroke, nacin_leas, neobdav, obresti, obrok, opombe, opravi_sam, ostalo, pp_neto, pp_obresti, pp_marza, 
pp_regist, proc_obr, prom_dov, reg_tabl, regist, saldo_dom, saldo_val, st_obrok, taksa, teh_p, tiskovina, usluga, vnesel,
strosek1, strosek2, strosek3, prem_pop, prv_obr
)
SELECT 
	1,   		--  AVTOMATSKI
	0, 		--  BREZ_DAVKA
	0,   		--  CEST
	null, 		--  DAT_DOK_R
	null, 		--  DAT_DOPISA
	null, 		--  DATUM_DOK
	null, 		--  DDV_DATE
	null, 		--  DDV_ID
	0, 		--  DEBIT
	0, 		--  DEBIT_NETO
	0, 		--  DEBIT_DAVEK
	null, 		--  DOK_REGIS
	dbo.gfn_ClaimTaxRateID('REG ', p.izvoz, p.id_dav_st), 	--  ID_DAV_ST
	p.id_kupca, 	--  ID_KUPCA
	p.id_vrste, 	--  ID_OPR
	p.id_cont, 	--  ID_CONT
	p.id_val,  	--  ID_VAL
	d.id_zapo, 	--  ID_ZAPO
	null, 		--  IZPISAN
	0, 		--  JE_FAKTURA
	0, 		--  NA_OBROKE
	p.nacin_leas, 	--  NACIN_LEAS
	0, 		--  NEOBDAV
	0, 		--  OBRESTI
	0, 		--  OBROK
	'', 		--  OPOMBE
	d.opravi_sam, 	--  OPRAVI_SAM
	0, 		--  OSTALO
	0, 		--  PP_NETO
	0, 		--  PP_OBRESTI
	0, 		--  PP_MARZA
	0, 		--  PP_REGIST
	0, 		--  PROC_OBR
	0, 		--  PROM_DOV
	0, 		--  REG_TABL
	0, 		--  REGIST
	0, 		--  SALDO_DOM
	0, 		--  SALDO_VAL
	0, 		--  ST_OBROK
	0, 		--  TAKSA
	0, 		--  TEH_P
	0, 		--  TISKOVINA
	0, 		--  USLUGA
	@user_name,	--  VNESEL,
    	0,      	-- STROSEK1
    	0,       	-- STROSEK2
	0,		-- STROSEK3
	0,		-- Prem_Pop
    0       -- prv_obr

FROM #za_regis_candidates d
INNER JOIN dbo.pogodba p ON d.id_cont = p.id_cont

print('7: '+convert(char(100),@today,120))
---------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------
-- mark all new documents with coresponding id_master = id_za_regis in table za_regis
-- if invoice was not generated, id_master should be set to null
UPDATE dbo.dokument
   SET id_master = z.id_za_regis,
       popravil = 'DNEV_RUT',
       dat_poprave = @today
  FROM dbo.dokument d
 INNER JOIN #dok_candidates c ON d.id_parent = c.id_dokum
  LEFT JOIN dbo.za_regis z ON d.id_zapo = z.id_zapo AND d.opravi_sam = z.opravi_sam AND d.id_cont = z.id_cont AND z.je_faktura = 0 -- only active notices
 WHERE d.id_master = -1 -- only new documents

print('8: '+convert(char(100),@today,120))
---------------------------------------------------------------------------------------------------------------------------------