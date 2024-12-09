USE [Nova_hls]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_FrameView_StockDetails]    Script Date: 8.4.2016. 10:48:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting data for report : Frame View - returns stock transfers for selected frame
--
-- History:
-- 20.05.2005 TASK 5282 - Jure; created
------------------------------------------------------------------------------------------------------------
ALTER      FUNCTION [dbo].[gfn_FrameView_StockDetails]
(
@par_id_frame_enabled bit,
@par_id_frame int,
@par_trenutnidatum_enabled int,
@par_trenutnidatum datetime
)  
RETURNS TABLE
AS  
RETURN(
    SELECT Z.id_frame, Z.frame_opis, Z.st_dok, Z.nab_vred_neto, Z.datum_dok, Z.status_akt,
		   Z.id_dob, Z.naz_kr_dob, Z.id_skladisca, Z.vnesel, U.user_desc AS users_vnesel
	  FROM (
			SELECT p.id_frame, f.opis as frame_opis, p.st_prevzema as st_dok, 
				   dbo.gfn_Xchange(f.id_tec,pa.nab_vred_neto, '000', @par_trenutnidatum) as nab_vred_neto, 
				   p.dat_prevzema as datum_dok,
				   p.status_akt, p.id_dob, k.naz_kr_kup as naz_kr_dob, 
				   p.id_skladisca, p.vnesel
			  FROM dbo.stk_prevz_art as pa
			 INNER JOIN dbo.stk_prevzem as p ON pa.id_prevzema = p.id_prevzema
			 INNER JOIN dbo.partner as k ON p.id_dob = k.id_kupca
			 INNER JOIN dbo.stk_skladisce as s ON p.id_skladisca = s.id_skladisca
			 INNER JOIN dbo.frame_list as f ON p.id_frame = f.id_frame
			 UNION ALL
			SELECT p.id_frame, f.opis as frame_opis, d.st_dobave as st_dok, 
				   dbo.gfn_Xchange(f.id_tec, pa.nab_vred_neto / pa.kolicina * da.kolicina * -1, '000', @par_trenutnidatum) as nab_vred_neto, 
				   d.dat_dobave as dat_dok,
				   d.status_akt, s.id_kupca as id_dob, k.naz_kr_kup as naz_kr_dob, 
				   d.id_skladisca, d.vnesel
			  FROM dbo.stk_dob_art as da
			 INNER JOIN dbo.stk_prevzem as p ON da.id_prevzema = p.id_prevzema
             INNER JOIN dbo.stk_prevz_art as pa ON da.id_prevzema = pa.id_prevzema AND da.id_artikla = pa.id_artikla
			 INNER JOIN dbo.stk_dobava as d ON da.id_dobave = d.id_dobave
			 INNER JOIN dbo.stk_skladisce as s ON d.id_skladisca = s.id_skladisca
			 INNER JOIN dbo.partner as k ON S.id_kupca = k.id_kupca
			 INNER JOIN dbo.partner as k1 ON d.id_kupca = k1.id_kupca
			 INNER JOIN dbo.frame_list as f ON p.id_frame = f.id_frame
			 WHERE da.id_prevzema in (SELECT id_prevzema
									    FROM dbo.stk_prevzem
								       WHERE id_frame is not null)
			   AND p.status_akt IN ('A', 'Z')
		   ) as Z
     LEFT JOIN dbo.users U ON Z.vnesel = U.username
	WHERE (@par_id_frame_enabled = 0 OR Z.id_frame = @par_id_frame)
)
