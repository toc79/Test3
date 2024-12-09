USE [Nova_hls]
GO
/****** Object:  StoredProcedure [dbo].[gsp_EquipmentDocuments]    Script Date: 26.11.2015. 11:18:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------------------------
-- This procedure checks for documents regarding equipment that are due in @days days. 
-- Then it prepares new documents and inserts new notices into za_pz table when necessary.
-- Parameters:
-- @days - for how many days in advance the documents are prepared
-- @user_name - name of the user executing the procedure
--
-- History:
-- 17.01.2003 Matjaz; created
-- 03.03.2004 Matjaz; changed that dokument.datum of newly generated document is inserted value d.velja_do of the old document instead of getdate()
-- 16.03.2004 Matjaz; changed insert of new documents - field velja_do is set to the future for the same period as the previous document was valid
-- 22.03.2004 Matjaz; Changes due to id_cont 2 PK transition
-- 14.04.2004 Matjaz; Bug-fix - new cloumns in za_pz
-- 14.04.2004 Matjaz; Removed columns AKONT and DAT_DOK_A from za_pz table
-- 12.01.2005 Matjaz; added join on zap_reg to get only documents for registration
-- 26.01.2005 Matjaz; added condition k.ali_obv = 1
-- 03.02.2005 Matjaz; modified ON SITE - added condition for contracts that will end soon and to prepare notices only for active contracts
-- 03.02.2005 Matjaz; modified ON SITE - added dni_obv to new value of datum in new document
-- 03.02.2005 Matjaz; modified ON SITE - changed calculation od velja_do in case of zacetek is null
-- 09.08.2005 Matjaz; changed value to be inserted into dokument.datum from velja_do + dni_obv to velja_do + dni_zap
-- 26.08.2005 Matjaz; changes due to new column dokument.reg_stev
-- 28.09.2005 Matjaz; reorganized initial select due to optimization
-- 22.11.2006 Matjaz; [EUR project] - changed that new documents are generated with new_id_tec if one exists
-- 02.03.2007 Vilko; Maintenance ID 7594 - fixed join between za_regis and dokument - added join on id_cont
-- 31.07.2008 Vilko; MID 16032 - added update of fields popravil and dat_poprave
-- 25.03.2010 Jure; BUG 28257 - Added field prv_obr when inserting into za_pz table
-- 08.03.2011 Jasna; MID 28906 -  change left join in #ending_contracts part; using dbo.gv_planp_ds_by_contract
-- 05.07.2011 Jasna; BUG 28930 - deleted condition ima = 1 in #dok_candidates and added new condition for datum in #za_regis_candidates 
-- 13.12.2011 Vilko; Bug ID 29146 - fixed updating field id_master in table dokument in last update statement
-- 25.01.2012 Vilko; Bug ID 29220 - fixed setting velja_do for new document, fixed updating field id_master in table dokument in last update statement
-- 18.09.2012 IgorS; Bug ID 29226 - added new field dni_zap_old
-- 29.01.2013 Josip; GMC MID 25229 - added check into table statusi (Franci; added to HF (MR: 38957))
-- 29.08.2013 Ales; MID 41488 - removed contracts that have debt from ending contracts
-- 02.09.2013 Ales; MID 41488 - removed contracts that have debt from ending contracts
-- 03.01.2014 Ales; MID 43836 - fixed ending contracts select - check if saldo is null; fixed select for candidates for insert into za_pz - check new setting
-- 20.08.2015 Domen; BugID 31895 - inserting additional fields into dbo.dokument
------------------------------------------------------------------------------------------------------------------------------

ALTER            PROCEDURE [dbo].[gsp_EquipmentDocuments] (@days int, @user_name varchar(10))
AS

DECLARE @today datetime
SET @today = getdate()

---------------------------------------------------------------------------------------------------------------------------------
-- get all documents, which are due in @days days and haven't been tranferred yet
-- TODO: if contract ends in 2 months, don't prepare notices

DECLARE @RegWarnOldDebtors bit
SET @RegWarnOldDebtors = (SELECT val FROM dbo.custom_settings WHERE code = 'Nova.LE.DailyRoutines.RegWarnOldDebtors')

IF @RegWarnOldDebtors IS NULL 
BEGIN
	SET @RegWarnOldDebtors = 0
END

-- removed ending contracts that have debt
SELECT distinct a.id_cont INTO #ending_contracts
FROM dbo.pogodba a 
LEFT OUTER JOIN dbo.gv_planp_ds_by_contract b ON a.id_cont = b.id_cont
INNER JOIN dbo.partner c ON c.id_kupca = a.id_kupca
WHERE a.status_akt = 'A' AND
(b.id_cont is null OR b.max_dat_zap <= DATEADD(d, @days, @today)) AND
((@RegWarnOldDebtors = 1 AND ISNULL(b.saldo,0) <= 0 ) OR @RegWarnOldDebtors = 0)

SELECT d.*, k.dni_zap_old
INTO #dok_candidates
FROM dbo.dokument d
INNER JOIN dbo.dok k ON d.id_obl_zav = k.id_obl_zav
INNER JOIN dbo.zap_ner z ON d.id_zapo = z.id_zapo -- to make sure we only get documents for equipment
INNER JOIN dbo.pogodba p ON d.id_cont = p.id_cont
INNER JOIN dbo.statusi st on p.status = st.status
WHERE 
	k.ali_na_zner = 1 AND -- only those, that have to do with equipment
	k.ali_obv = 1 AND -- only those, that are marked for notification
	d.velja_do <= DATEADD(d, @days, @today) AND -- which are due in @days days from today
	d.status_akt = 'A' AND p.status_akt = 'A' AND -- only active ones
	--d.ima = 1 AND --ima is irrelevant BUG 28930
	st.ne_obv_reg = 0 AND -- only those contracts, that do not have blocked reg. notifications via status in table statusi
	d.id_cont NOT IN (SELECT id_cont FROM #ending_contracts)
	-- dbo.gfn_MaxDatZapInPlanP(d.id_cont) > DATEADD(d, @days, getdate()) -- don't prepare notices for contracts that will soon end
---------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------
-- set status of all transferred documents to 'E' (ending) so that we don't tranfer tham again next time
UPDATE dbo.dokument
   SET status_akt = 'E',
       popravil = 'DNEV_RUT',
       dat_poprave = @today
WHERE id_dokum IN (SELECT id_dokum FROM #dok_candidates)
---------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------
-- generate new documents in table dokument
INSERT INTO dbo.dokument
(dat_1op, dat_2op, dat_3op, dat_obv, dat_vink, datum, datum_dok, ddv_id, id_hipot, id_obl_zav, id_parent, 
id_cont, id_sdk, id_tec, id_master, id_zapo, id_zav, ima, kolicina, konec, opis, opis1, opombe, opravi_sam, 
potrebno, reg_stev, st_nalepke, st_vink, status_akt, stevilka, velja_do, vnesel, vrednost, vrst_red_d, 
vrsta, zacetek, zav_je_on, popravil, dat_poprave, rang_hipo, is_elligible, dok_in_safe, status_zk, tip_cen, 
kategorija1, kategorija2, kategorija3, kategorija4, kategorija5, kategorija6)

SELECT 
	null, 		-- DAT_1OP
	null, 		-- DAT_2OP
	null, 		-- DAT_3OP
	null, 		-- DAT_OBV
	null, 		-- DAT_VINK
	d.velja_do + dni_zap_old, 	-- DATUM; due date for new document deliverance is validation date of old document
	@today, 	-- DATUM_DOK
	null, 		-- DDV_ID
	d.id_hipot, 	-- ID_HIPOT
	d.id_obl_zav, 	-- ID_OBL_ZAV
	d.id_dokum,	-- ID_PARENT
	d.id_cont, 	-- ID_CONT
	d.id_sdk, 	-- ID_SDK
	dbo.gfn_GetNewTec(d.id_tec), 	-- ID_TEC
	-1, 		-- ID_MASTER; the value -1 is just temporary, so that we mark all newly generated documents
	d.id_zapo, 	-- ID_ZAPO
	d.id_zav, 	-- ID_ZAV
	0, 		-- IMA
	d.kolicina, 	-- KOLICINA
	d.konec, 	-- KONEC
	d.opis, 		-- OPIS
	d.opis1, 	-- OPIS1
	d.opombe, 	-- OPOMBE
	d.opravi_sam, 	-- OPRAVI_SAM
	d.potrebno, 	-- POTREBNO
	d.reg_stev,	-- REG_STEV
	'', 		-- ST_NALEPKE
	'', 		-- ST_VINK
	'A', 		-- STATUS_AKT
	'', 		-- STEVILKA
	case 
		when d.zacetek is null then DATEADD(yy, 1, d.velja_do)
		else DATEADD(m, DATEDIFF(m, d.zacetek, d.velja_do) + (case when DATEDIFF(m, d.zacetek, d.velja_do) = 0 then 1 else 0 end), d.velja_do) 
	end, 	-- VELJA_DO    is set to the future for the same period as the previous document was valid
	'DNEV_RUT', 	-- VNESEL
	0, 		-- VREDNOST
	d.vrst_red_d, 	-- VRST_RED_D ????
	d.vrsta, 		-- VRSTA ?????
	d.velja_do, 	-- ZACETEK
	d.zav_je_on,	-- ZAV_JE_ON
    'DNEV_RUT',     -- POPRAVIL
    @today,         -- DAT_POPRAVE
	d.rang_hipo,    -- rang_hipo
	d.is_elligible, -- is_elligible
	d.dok_in_safe,  -- dok_in_safe
	d.status_zk,    -- status_zk
	d.tip_cen,      -- tip_cen
	d.kategorija1,  -- kategorija1
	d.kategorija2,  -- kategorija2
	d.kategorija3,  -- kategorija3
	d.kategorija4,  -- kategorija4
	d.kategorija5,  -- kategorija5
	d.kategorija6   -- kategorija6

FROM #dok_candidates d
---------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------
-- get candidates for insert into za_pz
SELECT d.id_zapo, d.opravi_sam, d.id_cont INTO #za_pz_candidates 
FROM dbo.dokument d
WHERE d.id_master = -1 AND -- only newly generated documents

	-- if an active (je_faktura=0) notice (dopis) with same id_zapo and opravi_sam already exists in za_pz, 
	-- then there is no need to insert a new record; a candidate document from table dokument can get
	-- id_master (id_za_pz) of the existing record and thus join the existing record as a new child
	NOT EXISTS (
		SELECT * FROM dbo.za_pz 
		WHERE id_zapo = d.id_zapo 
          AND opravi_sam = d.opravi_sam -- relation to dokument
		  AND je_faktura = 0 -- active notice
          AND id_cont = d.id_cont
	)
	-- to exclude old documents; new generated documents, because of fix in upper code (ima = 1 is out!) can have old date 
	AND (@RegWarnOldDebtors = 1  OR (@RegWarnOldDebtors = 0 AND d.datum > @today))
GROUP BY d.id_zapo, d.opravi_sam, d.id_cont -- for each combination of id_zapo and opravi_sam one record is generated in za_pz
---------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------
-- generate new records in za_pz
INSERT INTO dbo.za_pz (
	avtomatski, brez_davka, dat_dopisa, datum_dok, ddv_date, ddv_id, debit, debit_davek, 
	debit_neto, id_cont, id_dav_st, id_kupca, id_val, id_zapo, izpisan, je_faktura, neobdav, opravi_sam, 
	saldo_dom, saldo_val, st_dok, vnesel, prv_obr	
)
SELECT 
	1, 	-- AVTOMATSKI
	0, 	-- BREZ_DAVKA
	null, 	-- DAT_DOPISA
	null, 	-- DATUM_DOK
	null, 	-- DDV_DATE
	null, 	-- DDV_ID
	0, 	-- DEBIT
	0, 	-- DEBIT_DAVEK
	0, 	-- DEBIT_NETO
	p.id_cont, 	-- ID_CONT	
	dbo.gfn_ClaimTaxRateID('PRZA', p.izvoz, p.id_dav_st), 	-- ID_DAV_ST
	p.id_kupca, 	-- ID_KUPCA
	p.id_val, 	-- ID_VAL
	d.id_zapo, 		-- ID_ZAPO
	null, 	-- IZPISAN
	0, 	-- JE_FAKTURA
	0, 	-- NEOBDAV
	d.opravi_sam, 	-- OPRAVI_SAM
	0, 	-- SALDO_DOM
	0, 	-- SALDO_VAL
	null, 	-- ST_DOK
	@user_name,	-- VNESEL
    0
    
FROM #za_pz_candidates d
INNER JOIN dbo.pogodba p ON d.id_cont = p.id_cont
---------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------
-- mark all new documents with coresponding id_master = id_za_pz in table za_pz
-- if invoice was not generated, id_master should be set to null
UPDATE dbo.dokument
   SET id_master = z.id_za_pz,
       popravil = 'DNEV_RUT',
       dat_poprave = @today 
  FROM dbo.dokument d
 INNER JOIN #dok_candidates c ON d.id_parent = c.id_dokum
  LEFT JOIN dbo.za_pz z ON d.id_zapo = z.id_zapo AND d.opravi_sam = z.opravi_sam AND d.id_cont = z.id_cont AND z.je_faktura = 0 -- only active notices
 WHERE d.id_master = -1 -- only new documents
---------------------------------------------------------------------------------------------------------------------------------
