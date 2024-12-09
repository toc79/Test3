-----------------------------------------------------
-- Procedure: Updates exception dates and aneks for given contract
--            - contract exception is inserted, if not exists
--
-- Parameters:
--   @par_Id_cont        - contract id
--   @par_Sif_status_sys - new contract exception status
--   @par_UserName       - user, who make changes
-- History:
-- 24.11.2004 Vilko; created
-- 18.01.2005 Matjaz; added column zam_obr
-- 24.06.2009 PetraR; MID 18401 - added missing columns direct_debit, likvidacija, reprogram, pon_pred_odkup
-- 13.12.2010 Jelena; MID 27577 - remove update field aneks on contract
-- 07.02.2012 Jasna; BUG ID 29255 - added missing field rep_spr_ind
-- 03.06.2015 Andrej; MID 50011 - added call gsp_LogContractExceptionsUpdate
-----------------------------------------------------
CREATE  PROCEDURE [dbo].[gsp_UpdateContractExceptions]
@par_Id_cont as int,
@par_Sif_status_sys as char(3),
@par_UserName char(10)
AS
BEGIN
  DECLARE @Today datetime, @StPog int, @Id_status int
  SET @Today = GETDATE()
  /* Get status information */
  SELECT @Id_status = id_status
    FROM dbo.status_sys 
   WHERE sif_status_sys = @par_Sif_status_sys
  /* Check if contract exception exists */
  SELECT @StPog = COUNT(*) 
    FROM dbo.pog_pos 
   WHERE id_cont = @par_Id_cont
  IF @StPog = 0
    /* Insert exception */
    INSERT INTO dbo.pog_pos (id_cont, id_kupca, kdaj, kdo, status)
      SELECT id_cont, id_kupca, @Today, @par_UserName, @Id_status
        FROM dbo.pogodba
       WHERE id_cont = @par_Id_cont
  ELSE
    /* Update exception status */
    UPDATE dbo.pog_pos 
       SET status = @Id_status,
           kdaj = @Today,
           kdo = @par_UserName
     WHERE id_cont = @par_Id_Cont
    EXEC gsp_LogContractExceptionsUpdate @par_Id_Cont, @par_UserName
  /* Set exception dates */
  UPDATE dbo.pog_pos 
     SET obvestila = (CASE WHEN S.set_datum=1 AND S.obvestila=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.obvestila END),
         opomini = (CASE WHEN S.set_datum=1 AND S.opomini=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.opomini END),
         black_l = (CASE WHEN S.set_datum=1 AND S.black_l=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.black_l END),
         knjizenje = (CASE WHEN S.set_datum=1 AND S.knjizenje=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.knjizenje END),
         zapiranje = (CASE WHEN S.set_datum=1 AND S.zapiranje=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.zapiranje END),
         ne_prek_do = (CASE WHEN S.set_datum=1 AND S.ne_prek_do=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.ne_prek_do END),
         zam_obr = (CASE WHEN S.set_datum=1 AND S.zam_obr=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.zam_obr END),
         direct_debit = (CASE WHEN S.set_datum=1 AND S.direk_brem=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.direct_debit END),
         likvidacija = (CASE WHEN S.set_datum=1 AND S.likvidacija=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.likvidacija END),
         reprogram = (CASE WHEN S.set_datum=1 AND S.reprogram=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.reprogram END),
         pon_pred_odkup = (CASE WHEN S.set_datum=1 AND S.pon_pred_odkup=1 THEN DATEADD(day, S.st_dni ,@Today) ELSE P.pon_pred_odkup END),
         rep_spr_ind = (CASE WHEN S.set_datum = 1 AND S.rep_spr_ind = 1 THEN DATEADD(day, S.st_dni, @Today) ELSE P.rep_spr_ind END)
    FROM dbo.pog_pos P
    LEFT JOIN dbo.status_sys S
      ON P.status = S.id_status
   WHERE P.id_cont = @par_Id_cont
END