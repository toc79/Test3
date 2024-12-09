--USE [Nova_hls]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_FrameView_OutgoingPaymentDetails]    Script Date: 8.4.2016. 10:43:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting data for report : Frame View - returns outgoing payments for selected frame
--
-- History:
-- 11.12.2006 Vilko; created
-- 24.04.2009 Vilko; MID 20449 - included partialy activated contracts
-- 07.05.2010 Vilko; MID 23928 - payments for frame_type = 'DOB' are excluded if frame is closed or payment is based on input invoice
-- 09.06.2011 Jasna; MID 30113 - added new frame type called RRE (Retail Risk Exposure)
-- 19.10.2011 Jasna; BUG ID 29064 - added new condition for RRE frame type
-- 26.01.2012 Jasna; BUG 29227 - fix status_placila in RRE part of where clause
-- 24.05.2013 Jelena; MID 40473 - remove condition, for frame_type = 'DOB', that type of payments processed (P - procesirano) is not considered for selected frame
-- 14.03.2014 Jelena; MID 43659 - supported new frame_type DBA, modified frame_type DOB
-- 16.05.2014 Jelena; MID 43659 - refactoring function
-- 05.08.2014 Jelena; Bug ID 31011 - for frame type 'DBA' - added relation between frame_list and plac_izh through id_frame and remove condition for frame activity status 
-- 06.01.2014 Ales; MID 48847 - changed id_plac_izh_tip condition
-- 18.06.2015 Jure; BUG 31753 - Added call of function gfn_SummitPlacIzhData
-- 11.09.2015 Jure & Nataša ; BUG 31845 - Correction off RRE frame calculation
-- 22.01.2016 Jelena; MID 53439 - added case for collection and collection child
-- 10.02.2016 Jelena; Bug 32242 - remove case for collection child
------------------------------------------------------------------------------------------------------------
ALTER    FUNCTION [dbo].[gfn_FrameView_OutgoingPaymentDetails]
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

RETURNS @tab table
(
	id_plac_izh int, 
	id_cont int, 
	id_pog char(11), 
	id_kupca char(6), 
	naz_kr_kup varchar(80), 
	opis varchar(50), 
	datum datetime,
    znesek_dom decimal(18,2), 
	znesek_val decimal(18,2),
	id_val char(3), 
	id_tec char(3)
)  
AS
BEGIN
	DECLARE  @sif_frame_type char(3), @id_parent int, @je_krovni_okvir bit
	SET @sif_frame_type = (SELECT T.sif_frame_type FROM dbo.frame_list F INNER JOIN dbo.frame_type T ON F.frame_type = T.id_frame_type WHERE F.id_frame = @par_frame_number)

	SELECT @sif_frame_type = T.sif_frame_type,  @id_parent = F.id_parent, @je_krovni_okvir = F.je_krovni_okvir 
	FROM dbo.frame_list F 
	INNER JOIN dbo.frame_type T ON F.frame_type = T.id_frame_type WHERE F.id_frame = @par_frame_number


	    --navadni okvir in child od krovnega okvira		
		IF @je_krovni_okvir = 0 BEGIN

			IF @sif_frame_type = 'DBA'
				INSERT INTO @tab
				SELECT PL.id_plac_izh, PL.id_cont, P.id_pog, F.id_kupca, C.naz_kr_kup, PL.opis, PL.datum,
						dbo.gfn_XChange('000', PL.znesek_dom, PL.id_tec, PL.datum) AS znesek_dom, 
						dbo.gfn_XChange(F.id_tec, PL.znesek_dom, PL.id_tec, PL.datum) AS znesek_val,
						T.id_val, F.id_tec
					FROM dbo.frame_list F
					INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type	  
					INNER JOIN dbo.plac_izh PL ON F.id_kupca = PL.id_dob AND PL.id_vrste = 1 AND pl.id_frame = f.id_frame AND PL.status_placila IN ('V','A','E','S','P')
					INNER JOIN dbo.plac_izh_tip PT ON PL.id_plac_izh_tip = PT.id_plac_izh_tip 
					LEFT JOIN dbo.partner C ON F.id_kupca = C.id_kupca
					LEFT JOIN dbo.tecajnic T ON F.id_tec = T.id_tec
					INNER JOIN dbo.pogodba P ON PL.id_cont = P.id_cont 
					INNER JOIN dbo.nacini_l L ON L.nacin_leas = P.nacin_leas
					LEFT OUTER JOIN dbo.frame_list f1 ON f1.id_frame = PL.id_frame
					LEFT OUTER JOIN dbo.frame_type ft1 ON ft1.id_frame_type = f1.frame_type
					WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
						AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
						AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
						AND PT.p1_je_racun = 0
						AND FT.sif_frame_type = 'DBA' and ft1.sif_frame_type = 'DBA'

		    ELSE IF @sif_frame_type = 'DOB'
				INSERT INTO @tab
				SELECT PL.id_plac_izh, PL.id_cont, P.id_pog, F.id_kupca, C.naz_kr_kup, PL.opis, PL.datum,
					dbo.gfn_XChange('000', PL.znesek_dom, PL.id_tec, PL.datum) AS znesek_dom, 
					dbo.gfn_XChange(F.id_tec, PL.znesek_dom, PL.id_tec, PL.datum) AS znesek_val,
					T.id_val, F.id_tec
				FROM dbo.frame_list F
				INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type	  
				INNER JOIN dbo.plac_izh PL ON F.id_kupca = PL.id_dob AND PL.id_vrste = 1 AND PL.status_placila IN ('V','A','E','S','P')
				INNER JOIN dbo.plac_izh_tip PT ON PL.id_plac_izh_tip = PT.id_plac_izh_tip 
				LEFT JOIN dbo.partner C ON F.id_kupca = C.id_kupca
				LEFT JOIN dbo.tecajnic T ON F.id_tec = T.id_tec
				INNER JOIN dbo.pogodba P ON PL.id_cont = P.id_cont 
				INNER JOIN dbo.nacini_l L ON L.nacin_leas = P.nacin_leas
				LEFT OUTER JOIN dbo.frame_list f1 ON f1.id_frame = PL.id_frame
				LEFT OUTER JOIN dbo.frame_type ft1 ON ft1.id_frame_type = f1.frame_type
				WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
					AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
					AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
					AND FT.sif_frame_type = 'DOB'
					AND P.status_akt != 'Z' AND F.status_akt != 'Z' AND PT.p1_je_racun = 0
					AND ft1.sif_frame_type is null AND P.status_akt IN ('D', 'N')


			ELSE IF @sif_frame_type = 'RRE'
				INSERT INTO @tab
				SELECT 
					id_plac_izh, id_cont, id_pog, id_dob, naz_kr_dob, opis, datum,
					dbo.gfn_XChange('000', znesek_dom, id_tec, datum) AS znesek_dom, 
					dbo.gfn_XChange(frame_id_tec, znesek_dom, id_tec, datum) AS znesek_val,
					frame_id_val, frame_id_tec
				FROM 
					dbo.gfn_SummitPlacIzhData(0)
				WHERE 
					(@par_frame_enabled = 0 OR id_frame = @par_frame_number) AND
					(@par_partner_enabled = 0 OR id_dob  = @par_partner_number) AND
					(@par_dat_odobritve_enabled = 0 OR dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
		END
		ELSE

		--krovni okvir
        IF @je_krovni_okvir = 1 BEGIN

			IF @sif_frame_type = 'DBA'
				INSERT INTO @tab
				SELECT PL.id_plac_izh, PL.id_cont, P.id_pog, FL1.id_kupca, C.naz_kr_kup, PL.opis, PL.datum,
						dbo.gfn_XChange('000', PL.znesek_dom, PL.id_tec, PL.datum) AS znesek_dom, 
						dbo.gfn_XChange(FL1.id_tec, PL.znesek_dom, PL.id_tec, PL.datum) AS znesek_val,
						T.id_val, FL1.id_tec
					FROM dbo.frame_list F
					INNER JOIN dbo.frame_list FL1 ON FL1.id_parent = F.id_frame
					INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type	  
					INNER JOIN dbo.plac_izh PL ON FL1.id_kupca = PL.id_dob AND PL.id_vrste = 1 AND pl.id_frame = FL1.id_frame AND PL.status_placila IN ('V','A','E','S','P')
					INNER JOIN dbo.plac_izh_tip PT ON PL.id_plac_izh_tip = PT.id_plac_izh_tip 
					LEFT JOIN dbo.partner C ON FL1.id_kupca = C.id_kupca
					LEFT JOIN dbo.tecajnic T ON FL1.id_tec = T.id_tec
					INNER JOIN dbo.pogodba P ON PL.id_cont = P.id_cont 
					INNER JOIN dbo.nacini_l L ON L.nacin_leas = P.nacin_leas
					LEFT OUTER JOIN dbo.frame_list f1 ON f1.id_frame = PL.id_frame
					LEFT OUTER JOIN dbo.frame_type ft1 ON ft1.id_frame_type = f1.frame_type
					WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
						AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
						AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
						AND PT.p1_je_racun = 0
						AND FT.sif_frame_type = 'DBA' and ft1.sif_frame_type = 'DBA'

		    ELSE IF @sif_frame_type = 'DOB'
				INSERT INTO @tab
				SELECT PL.id_plac_izh, PL.id_cont, P.id_pog, FL1.id_kupca, C.naz_kr_kup, PL.opis, PL.datum,
					dbo.gfn_XChange('000', PL.znesek_dom, PL.id_tec, PL.datum) AS znesek_dom, 
					dbo.gfn_XChange(FL1.id_tec, PL.znesek_dom, PL.id_tec, PL.datum) AS znesek_val,
					T.id_val, FL1.id_tec
				FROM dbo.frame_list F
				INNER JOIN dbo.frame_list FL1 ON FL1.id_parent = F.id_frame
				INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type	  
				INNER JOIN dbo.plac_izh PL ON FL1.id_kupca = PL.id_dob AND PL.id_vrste = 1 AND PL.status_placila IN ('V','A','E','S','P')
				INNER JOIN dbo.plac_izh_tip PT ON PL.id_plac_izh_tip = PT.id_plac_izh_tip 
				LEFT JOIN dbo.partner C ON F.id_kupca = C.id_kupca
				LEFT JOIN dbo.tecajnic T ON FL1.id_tec = T.id_tec
				INNER JOIN dbo.pogodba P ON PL.id_cont = P.id_cont 
				INNER JOIN dbo.nacini_l L ON L.nacin_leas = P.nacin_leas
				LEFT OUTER JOIN dbo.frame_list f1 ON f1.id_frame = PL.id_frame
				LEFT OUTER JOIN dbo.frame_type ft1 ON ft1.id_frame_type = f1.frame_type
				WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
					AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
					AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
					AND FT.sif_frame_type = 'DOB'
					AND P.status_akt != 'Z' AND F.status_akt != 'Z' AND PT.p1_je_racun = 0
					AND ft1.sif_frame_type is null AND P.status_akt IN ('D', 'N')


			ELSE IF @sif_frame_type = 'RRE'
				INSERT INTO @tab
				SELECT 
					pl.id_plac_izh, pl.id_cont, pl.id_pog, pl.id_dob, pl.naz_kr_dob, pl.opis, pl.datum,
					dbo.gfn_XChange('000', pl.znesek_dom, pl.id_tec, pl.datum) AS znesek_dom, 
					dbo.gfn_XChange(frame_id_tec, pl.znesek_dom, pl.id_tec, pl.datum) AS znesek_val,
					pl.frame_id_val, pl.frame_id_tec
				FROM dbo.frame_list F
				LEFT JOIN dbo.frame_list F1 ON F.id_frame = F1.id_parent
				LEFT JOIN dbo.gfn_SummitPlacIzhData(0) pl ON pl.id_frame = F1.id_frame
				WHERE 
					(@par_frame_enabled = 0 OR F.id_frame = @par_frame_number) AND
					(@par_partner_enabled = 0 OR pl.id_dob  = @par_partner_number) AND
					(@par_dat_odobritve_enabled = 0 OR pl.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
		END
	
	RETURN
END
