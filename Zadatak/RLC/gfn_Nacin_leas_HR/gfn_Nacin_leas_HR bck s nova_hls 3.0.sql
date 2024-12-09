USE [Nova_hls]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_Nacin_leas_HR]    Script Date: 29.5.2017. 13:05:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------
-- Function returns Leasing type (OL, FF, F1, ZP, NA, ZA or XX) for given nacin_leas
--
-- History:
-- 04.12.2013 Mladen; Created due to hybrid leasing type (dbo.nacini_l.ol_na_nacin_fl).
-- 24.06.2015 Mladen; Added support for renting financing type's (NA and ZA).
--------------------------------------------------------------------------------


ALTER FUNCTION [dbo].[gfn_Nacin_leas_HR](
	@nacin_leas char(2)
)
RETURNS char(2)
AS
BEGIN
	DECLARE @result char(2), @Najam char(250), @Zakup char(250)
	SET @result = ''
	
	Select @Najam = dbo.gfn_GetCustomSettings('Nova.LE.Najam.Nekretnina'), @Zakup = dbo.gfn_GetCustomSettings('Nova.LE.Zakup.Nekretnina')

	SET @result = (Select
						CASE WHEN tip_knjizenja = '1' AND CHARINDEX(@nacin_leas, @Najam) > 0 THEN 'NA'
							 WHEN tip_knjizenja = '1' AND CHARINDEX(@nacin_leas, @Zakup) > 0 THEN 'ZA'
							 WHEN tip_knjizenja = '1' OR ol_na_nacin_fl = 1 THEN 'OL'
							 WHEN tip_knjizenja = '2' AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
							 WHEN tip_knjizenja = '2' AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
							 WHEN tip_knjizenja = '2' AND LEAS_KRED = 'K' THEN 'ZP'
							 ELSE 'XX' 
						END as tip_leas
					From dbo.nacini_l Where nacin_leas = @nacin_leas)

	RETURN @result
END