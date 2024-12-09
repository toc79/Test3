-----------------------------------------------------
-- Procedure: Add new insert in dbo.reprogram
--
-- Parameters:
--   @par_Id_cont        - contract id
--   @par_UserName       - user, who make changes
-- History:
-- 03.06.2015 Andrej; MID 50011 - created
-- 10.06.2015 Andrej; MID 50011 - modified to handle pog_pos fields that have value null
-- 13.11.2015 Andrej; MID 53726 - added variable @id_rep_category, @comment. added languages suport for @auto_desc.
-----------------------------------------------------
CREATE  PROCEDURE [dbo].[gsp_LogContractExceptionsUpdate]
	@par_Id_cont as int,
	@par_UserName char(10)
AS
BEGIN
	DECLARE @Today datetime, @auto_desc varchar(max), @id_kupca char(6), @sys_ts bigint,
			@obvestila datetime,
			@opomini datetime,
			@black_l datetime,
			@knjizenje datetime,
			@zapiranje datetime,
			@ne_prek_do datetime,
			@zam_obr datetime,
			@direct_debit datetime,
			@likvidacija datetime,
			@reprogram datetime,
			@pon_pred_odkup datetime,
			@rep_spr_ind datetime,
			@obvestila_old varchar(25),
			@opomini_old varchar(25),
			@black_l_old varchar(25),
			@knjizenje_old varchar(25),
			@zapiranje_old varchar(25),
			@ne_prek_do_old varchar(25),
			@zam_obr_old varchar(25),
			@direct_debit_old varchar(25),
			@likvidacija_old varchar(25),
			@reprogram_old varchar(25),
			@pon_pred_odkup_old varchar(25),
			@rep_spr_ind_old varchar(25),
			@id_rep_category char(3),
			@comment varchar(max)
			
			
		SET @Today = GETDATE()
		
		SELECT @id_kupca = id_kupca, @sys_ts = cast(sys_ts as bigint)
		FROM dbo.pogodba
        WHERE id_cont = @par_Id_cont 
		
		select @id_rep_category = ID_REP_CATEGORY
		from dbo.status_sys 
		where SIF_STATUS_SYS = 'TOZ'
   
	  SELECT @obvestila = (CASE WHEN S.set_datum=1 AND S.obvestila=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @opomini = (CASE WHEN S.set_datum=1 AND S.opomini=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @black_l = (CASE WHEN S.set_datum=1 AND S.black_l=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @knjizenje = (CASE WHEN S.set_datum=1 AND S.knjizenje=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @zapiranje = (CASE WHEN S.set_datum=1 AND S.zapiranje=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @ne_prek_do = (CASE WHEN S.set_datum=1 AND S.ne_prek_do=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @zam_obr = (CASE WHEN S.set_datum=1 AND S.zam_obr=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @direct_debit = (CASE WHEN S.set_datum=1 AND S.direk_brem=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @likvidacija = (CASE WHEN S.set_datum=1 AND S.likvidacija=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @reprogram = (CASE WHEN S.set_datum=1 AND S.reprogram=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @pon_pred_odkup = (CASE WHEN S.set_datum=1 AND S.pon_pred_odkup=1 THEN DATEADD(day, S.st_dni ,@Today) END),
			 @rep_spr_ind = (CASE WHEN S.set_datum = 1 AND S.rep_spr_ind = 1 THEN DATEADD(day, S.st_dni, @Today) END),
			 @obvestila_old = (CASE WHEN P.OBVESTILA IS NOT NULL THEN convert(varchar(25), P.OBVESTILA, 104) ELSE 'null' END),
			 @opomini_old = (CASE WHEN P.OPOMINI IS NOT NULL THEN convert(varchar(25), P.OPOMINI, 104) ELSE 'null' END),
			 @black_l_old = (CASE WHEN P.BLACK_L IS NOT NULL THEN convert(varchar(25), P.BLACK_L, 104) ELSE 'null' END),
			 @knjizenje_old = (CASE WHEN P.KNJIZENJE IS NOT NULL THEN convert(varchar(25), P.KNJIZENJE, 104) ELSE 'null' END),
			 @zapiranje_old = (CASE WHEN P.ZAPIRANJE IS NOT NULL THEN convert(varchar(25), P.ZAPIRANJE, 104) ELSE 'null' END),
			 @ne_prek_do_old = (CASE WHEN P.NE_PREK_DO IS NOT NULL THEN convert(varchar(25), P.NE_PREK_DO, 104) ELSE 'null' END),
			 @zam_obr_old = (CASE WHEN P.ZAM_OBR IS NOT NULL THEN convert(varchar(25), P.ZAM_OBR, 104) ELSE 'null' END),
			 @direct_debit_old = (CASE WHEN P.direct_debit IS NOT NULL THEN convert(varchar(25), P.direct_debit, 104) ELSE 'null' END),
			 @likvidacija_old = (CASE WHEN P.likvidacija IS NOT NULL THEN convert(varchar(25), P.likvidacija, 104) ELSE 'null' END),
			 @reprogram_old = (CASE WHEN P.reprogram IS NOT NULL THEN convert(varchar(25), P.reprogram, 104) ELSE 'null' END),
			 @pon_pred_odkup_old = (CASE WHEN P.pon_pred_odkup IS NOT NULL THEN convert(varchar(25), P.pon_pred_odkup, 104) ELSE 'null' END),
			 @rep_spr_ind_old = (CASE WHEN P.rep_spr_ind IS NOT NULL THEN convert(varchar(25), P.rep_spr_ind, 104) ELSE 'null' END)
		FROM dbo.pog_pos P
		LEFT JOIN dbo.status_sys S
		  ON P.status = S.id_status
	   WHERE P.id_cont = @par_Id_cont
	   
		SET @auto_desc = (SELECT dbo.gfn_GetAppMessageForUsername(@par_UserName, 'CChangedFields'))
		SET @auto_desc = @auto_desc + ': '
		
		IF @obvestila IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.obvestila ['			+ @obvestila_old + ' -> ' + convert(varchar(25), @obvestila, 104) + '], '
		IF @opomini IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.Opomini ['				+ @opomini_old + ' -> ' + convert(varchar(25), @opomini, 104) + '], '
		IF @black_l IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.black_l ['				+ @black_l_old + ' -> ' + convert(varchar(25), @black_l, 104) + '], '
		IF @knjizenje IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.knjizenje ['			+ @knjizenje_old + ' -> ' + convert(varchar(25), @knjizenje, 104) + '], '
		IF @zapiranje IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.zapiranje ['			+ @zapiranje_old + ' -> ' + convert(varchar(25), @zapiranje, 104) + '], '
		IF @ne_prek_do IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.ne_prek_do ['			+ @ne_prek_do_old + ' -> ' + convert(varchar(25), @ne_prek_do, 104) + '], '
		IF @zam_obr IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.zam_obr ['				+ @zam_obr_old + ' -> ' + convert(varchar(25), @zam_obr, 104) + '], '
		IF @direct_debit IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.direk_brem ['		+ @direct_debit_old + ' -> ' + convert(varchar(25), @direct_debit, 104) + '], '
		IF @likvidacija IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.likvidacija ['		+ @likvidacija_old + ' -> ' + convert(varchar(25), @likvidacija, 104) + '], '
		IF @reprogram IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.reprogram ['			+ @reprogram_old + ' -> ' + convert(varchar(25), @reprogram, 104) + '], '
		IF @pon_pred_odkup IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.pon_pred_odkup [' + @pon_pred_odkup_old + ' -> ' + convert(varchar(25), @pon_pred_odkup, 104) + '], '
		IF @rep_spr_ind IS NOT NULL SET @auto_desc = @auto_desc + 'pog_pos.rep_spr_ind ['		+ @rep_spr_ind_old + ' -> ' + convert(varchar(25), @rep_spr_ind, 104) + '], '
		
		SET @comment = (SELECT dbo.gfn_GetAppMessageForUsername(@par_UserName, 'CTransferToCharged'))
		
	  INSERT INTO dbo.reprogram (
		ID_CONT, 
		ID_KUPCA, 
		TIME, 
		ID_REP_TYPE, 
		auto_desc, 
		OLD_SYS_TS, 
		id_rep_category, 
		[USER], 
		COMMENT, 
		auto_desc_xml)
      VALUES(
		@par_Id_cont, 
		@id_kupca, 
		@Today, 
		'POS', 
		@auto_desc, 
		@sys_ts, 
		@id_rep_category, 
		@par_UserName, 
		@comment,
		'') 
END