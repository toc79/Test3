------------------------------------------------------------------------------------------------------------
-- Function for getting data for Approval (odobritve)
-- Complete read consists of these UDF
-- 1. gfn_Odobrit_Main_View (this function)
-- 3. gfn_Odobrit_Stanje_View
-- 2. gfn_Odobrit_Porok_View
-- 4. gfn_Odobrit_Zavar_View

-- History:
-- 07.04.2006 Muri; created
-- 18.10.2006 Vilko; Bug ID 26323 - fixed joins on table partner and tecajnic
-- 25.10.2006 Vilko; Bug ID 26332 - added field kolicina
-- 16.03.2018 Jost; MID 72063 - added fileds: ima, velja_do
-- 03.05.2024 MitjaM; MID 130876 - added fileds: stevilka, id_krov_dok
------------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[gfn_Odobrit_Zavar_View] (
@odobrit_id int
)

RETURNS TABLE
AS

RETURN (

	SELECT	O.id_odobrit_zavar,
		O.id_odobrit,
		O.id_obl_zav,
		O.id_vr_val,
		O.id_val,
		O.id_tec,
		O.id_kupca,
		O.kolicina,
		P.Naz_kr_kup,
		T.Naziv,
		D.Opis,
		O.ima,
		O.velja_do,
        O.stevilka,
        O.id_krov_dok
	  FROM dbo.odobrit_zavar O
	 INNER JOIN dbo.dok D ON O.id_obl_zav = D.id_obl_zav
	  LEFT JOIN dbo.Partner P ON O.ID_kupca = P.ID_Kupca
	  LEFT JOIN dbo.Tecajnic T ON O.ID_tec = T.id_tec
	 WHERE O.id_odobrit = @odobrit_id
)

