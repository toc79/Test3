----------------------------------------------------------
-- Updates child tables when contract was inserted or updated.
--
-- Parameters:
--   @par_is_update - flag indicating if contract was updated or inserted
--   @par_id_cont - contract id
--   @par_id_frame - frame id
--   @par_username - username
--
-- History:
-- 07.11.2005 Vilko; created
-- 15.11.2005 Vilko; changed call of gfn_GetStandardDocumentation (removed fourth parameter)
-- 03.01.2006 Vilko; modified adding standard documentation - added insert of field vrst_red_d
-- 11.12.2007 Vilko; MID 12455 - fixed deleting records from table frame_pogodba
-- 31.07.2008 Vilko; MID 16032 - added update of fields popravil and dat_poprave
-- 20.05.2010 Vilko; MID 24130 - added update of field opravi_sam
-- 27.11.2012 Uros; MID 32920 - added call for extended standard documentation
-- 09.04.2014 Jasna; MID 44557 - exclude possible approval documents from standard documentation
-- 15.04.2014 Uros; Mid 42465 - exclude documents already entered for approval or offer 
-- 30.08.2018 Nenad; Bid 34931 - possibility for skipping addition of standard documentation (contract cloning)
-- 07.11.2018 Kristjan; TID 14801 - expanded column range for nacin_leas and za_vrsteos
-- 20.04.2020 MitjaM; BID 38091 - added try catch
----------------------------------------------------------

CREATE PROCEDURE [dbo].[gsp_InsertUpdateContract] (
@par_is_update bit,
@par_id_cont int,
@par_id_frame int,
@par_username char(10),
@par_transf_doc bit,
@par_skip_doc bit
)
AS
BEGIN
  DECLARE 
  @status_akt char(1), @nacin_leas char(2), @id_vrste char(4), 
  @vr_osebe char(2), @today datetime, @id_odobrit int, @id_pon char(7)
  
  SET @today = getdate()

  -- Get data for current contract
  SELECT @status_akt = C.status_akt, 
         @nacin_leas = C.nacin_leas, 
         @id_vrste = C.id_vrste,
         @vr_osebe = P.vr_osebe,
         @id_odobrit = C.id_odobrit,
		 @id_pon = C.id_pon
    FROM dbo.pogodba C
   INNER JOIN dbo.partner P
      ON C.id_kupca = P.id_kupca
   WHERE C.id_cont = @par_id_cont

  -- Delete records from table pog_poro for current contract
  DELETE FROM dbo.pog_poro WHERE id_cont = @par_id_cont

  -- Delete records from table str_dobr for current contract
  IF @par_is_update = 0 OR @status_akt = 'N'
    DELETE FROM dbo.str_dobr WHERE id_cont = @par_id_cont

  -- Delete records from table frame_pogodba and insert new one for current contract
  DELETE FROM dbo.frame_pogodba WHERE id_cont = @par_id_cont
  IF @par_id_frame != 0
    BEGIN
      INSERT INTO dbo.frame_pogodba (id_cont, id_frame, status) VALUES (@par_id_cont, @par_id_frame, 'A')
    END

  -- Insert records into table dokument (standard documentation)
  IF @par_is_update = 0 And @par_skip_doc = 0
  BEGIN

	-- prepare document candidates for standard documentation
    CREATE TABLE #DocListTable (    
        id_dokdef int, id_obl_zav char(2), nacin_leas varchar(250), 
        opis char(50), za_vrsteos varchar(250), potrebno bit, 
        status char(1), za_registr bit, kolicina tinyint, ali_na_pog bit, 
        ali_na_zreg bit, ali_na_zner bit, ali_stand bit, 
        dni_zap tinyint, vrst_red_d char(3), opravi_sam_def_val tinyint
        )
	
	BEGIN TRY
		INSERT INTO #DocListTable(
			id_dokdef, id_obl_zav, nacin_leas, opis, za_vrsteos, potrebno, 
			status, za_registr, kolicina, ali_na_pog, ali_na_zreg, 
			ali_na_zner, ali_stand, dni_zap, vrst_red_d, opravi_sam_def_val
			)
		EXEC dbo.grp_GetDocumentationList 1, @nacin_leas, @vr_osebe, 0, @id_vrste, @par_id_cont
	END TRY
	BEGIN CATCH
		RAISERROR('Napaka v polju "Sql" v šifrantu standardne dokumentacije. Pogodba se ne bo shranila.', 16, 1)
	END CATCH
    
	-- get documents that should be copied and not generated as standard documentation
    CREATE TABLE #OdobCandidates(id_odobrit int, id_pon char(7), id_obl_zav char(2))

	-- prepare list of copy candidates from odobrit_zavar if transfered
    IF @par_transf_doc = 1
    BEGIN
		INSERT INTO #OdobCandidates (id_odobrit, id_obl_zav)
		SELECT id_odobrit, a.id_obl_zav 
		FROM dbo.odobrit_zavar a
		INNER JOIN dbo.dok b ON a.id_obl_zav = b.id_obl_zav
		WHERE id_odobrit = @id_odobrit
		AND (b.ali_na_pog = 0 and b.ali_na_zner = 0 and b.ali_na_zreg = 0)
	END

	-- prepare documents entered for approval or offer
	-- break into two for performance reason
	IF @id_odobrit is not null 
	BEGIN
		INSERT INTO #OdobCandidates (id_odobrit, id_pon, id_obl_zav)
		SELECT id_odobrit, id_pon, id_obl_zav
		FROM dokument
		WHERE id_odobrit = @id_odobrit
	END
	ELSE
	BEGIN
		IF @id_pon is not null 
		BEGIN
			INSERT INTO #OdobCandidates (id_odobrit, id_pon, id_obl_zav)
			SELECT id_odobrit, id_pon, id_obl_zav
			FROM dokument
			WHERE id_pon = @id_pon 
		END
	END

	-- insert standard documentation not allready in other tables
	-- actual copy of documents is in c#
	INSERT INTO dbo.dokument (dat_1op, dat_2op, dat_3op, dat_obv, dat_vink, datum, ddv_id, 
                            id_hipot, id_obl_zav, id_parent, id_cont, id_sdk, id_tec, id_zapo, id_master, id_zav, ima, kolicina, konec, 
                            opis, opis1, opombe, potrebno, opravi_sam, st_nalepke, st_vink, status_akt, stevilka, 
                            velja_do, vrednost, vrst_red_d, vrsta, zacetek, zav_je_on, vnesel, datum_dok, popravil, dat_poprave)
	SELECT null, null, null, null, null, CONVERT(CHAR(8), DATEADD(d, dni_zap, @today), 112), null,
            null, id_obl_zav, null, @par_id_cont, null, null, '', null, null, 0, kolicina, null,
            opis, '', '', potrebno, opravi_sam_def_val, '', '', 'A', '', 
            null, 0, vrst_red_d, '', null, 0, @par_username, @today, @par_username, @today
	FROM #DocListTable
	WHERE id_obl_zav not in (SELECT id_obl_zav FROM #OdobCandidates)
  
  END

END

