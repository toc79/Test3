USE [Nova_hls]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_FrameView_PaymentDetails]    Script Date: 8.4.2016. 10:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting data for report : Frame View - returns payments for selected frame
--
-- History:
-- 22.07.2005 Vilko; created
-- 13.10.2005 Vilko; currency value - znesek_val is recalculated in frame currency 
-- 28.10.2005 Vilko; added recalculation of odbitni_ddv in frame currency
-- 06.02.2006 Vilko; added new parameter for username
-- 22.01.2016 Jelena; added case for collection frame and collection child frame
-- 10.02.2016 Jelena; Bug 32242 - remove case for collection child
------------------------------------------------------------------------------------------------------------
ALTER  FUNCTION [dbo].[gfn_FrameView_PaymentDetails]  
(  
@par_frame_enabled int,
@par_frame_number int, 
@par_partner_enabled int,
@par_partner_number varchar(6),
@par_dat_odobritve_enabled int,
@par_dat_odobritve_from datetime,
@par_dat_odobritve_to datetime,
@par_razlika bit,
@par_username_enabled int,
@par_username_value char(10)
)  
RETURNS 
@result TABLE (
			id_plac int, 
			namen_pl varchar(50), 
			datum_pl datetime, 
			znesek_pl decimal(18,2), 
			ddv_id_veza char(14), 
			odbitni_ddv decimal(18,2), 
			znesek_val decimal(18,2), 
			odbitni_ddv_val decimal(18,2), 
			id_kupca char(6),
			id_tec char(3),
			naz_kr_kup varchar(80),
			id_val char(3)
    )
AS  
	BEGIN	
	DECLARE  @id_parent int, @je_krovni_okvir bit

	SELECT @id_parent = F.id_parent, @je_krovni_okvir = F.je_krovni_okvir 
	FROM dbo.frame_list F
	WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
			AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
			AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)


	 --navadni okvir in child od krovnega okvira	
	IF @je_krovni_okvir = 0 
		INSERT INTO @result
			SELECT FP.id_plac, FP.namen_pl, FP.datum_pl, FP.znesek_pl, FP.ddv_id_veza, FP.odbitni_ddv, 
				   dbo.gfn_XChange(F.id_tec, FP.znesek_pl, '000', FP.datum_pl) AS znesek_val,
				   dbo.gfn_XChange(F.id_tec, FP.odbitni_ddv, '000', FP.datum_pl) AS odbitni_ddv_val,
				   F.id_kupca, F.id_tec,
				   C.naz_kr_kup,
				   T.id_val
			  FROM dbo.frame_list F
			 INNER JOIN dbo.frame_plac FP ON F.id_frame = FP.id_frame
			  LEFT JOIN dbo.partner C ON F.id_kupca = C.id_kupca
			  LEFT JOIN dbo.tecajnic T ON F.id_tec = T.id_tec
			 WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
			   AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
			   AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
	ELSE
	--krovni okvir
    IF @je_krovni_okvir = 1 
		INSERT INTO @result
			SELECT FP1.id_plac, FP1.namen_pl, FP1.datum_pl, FP1.znesek_pl, FP1.ddv_id_veza, FP1.odbitni_ddv, 
				   dbo.gfn_XChange(F.id_tec, FP1.znesek_pl, '000', FP1.datum_pl) AS znesek_val,
				   dbo.gfn_XChange(F.id_tec, FP1.odbitni_ddv, '000', FP1.datum_pl) AS odbitni_ddv_val,
				   F.id_kupca, F.id_tec,
				   C1.naz_kr_kup,
				   T1.id_val
			  FROM dbo.frame_list F
			  INNER JOIN dbo.frame_list F1 ON F1.id_parent= F.id_frame
			  INNER JOIN dbo.frame_plac FP1 ON F1.id_frame = FP1.id_frame
			  INNER JOIN dbo.partner C1 ON F1.id_kupca = C1.id_kupca
			  INNER JOIN dbo.tecajnic T1 ON F1.id_tec = T1.id_tec
			 WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
			   AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
			   AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)

RETURN 
END
