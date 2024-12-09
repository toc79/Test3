		EXEC dbo.grp_GetReminderData_Claims_Arh
				1,
				'-1',
				1,
				'68370/22',
				0,
				'',
				0,
				'',
				0,
				'',
				'0',
				'0',
				1,
				'20240506',
				'20240612'

------------------------------------------------------------------------------------------------------------
-- This procedure returns claims needed for printing archived reminder 
--
-- History:
-- 19.07.2010 Natasa; created
-- 26.07.2010 Natasa; MID 26205, added criteria date of prepare 
-- 16.11.2011 Jasna; BUG ID 29104 - modified name of parameter @par_izdani_value instead izpisani
-- 28.03.2012 MatjazB; BUG 29346 - added parameter @par_izpisani_value
------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[grp_GetReminderData_Claims_Arh]
    @par_st_opomina_enabled bit,
	@par_st_opomina_value int,
	@par_id_pog_enabled bit,
	@par_id_pog_value char(11),
	@par_id_kupca_enabled bit,
	@par_id_kupca_value char(6),
	@par_id_strm_enabled bit,
	@par_id_strm_value varchar(1000),
	@par_vrsta_osebe_enabled bit,
	@par_vrsta_osebe_value varchar(1000),
	@par_izdani_value bit,
	@par_izpisani_value bit,
	@par_obdobje_enabled int, 
	@par_obdobje_datumod char(8), 
	@par_obdobje_datumdo char(8) 
AS

SELECT 
	A.id_opom, A.dat_zap, A.zap_obr, A.opis_terj, A.id_val, A.dolg_saldo, A.dolg_debit, 
	A.dolg_kredi, A.suma_val, A.dat_obr, A.tecajnica, A.st_dok, A.id_tec, B.naziv,
	dbo.gfn_XChange(O.id_tec, A.suma_val + A.dolg_saldo, A.id_tec, getdate()) AS dolg_val,
	A.debit_orig, A.id_val_orig, A.kredit_orig, A.saldo_orig, A.id_tec_orig, B1.naziv AS naz_tec_orig
FROM dbo.arh_opom_tmp A 
INNER JOIN dbo.tecajnic B ON A.id_tec = B.id_Tec
LEFT JOIN dbo.tecajnic B1 ON A.id_tec_orig = B1.id_Tec
INNER JOIN dbo.arh_za_opom O ON A.id_opom = O.id_opom
INNER JOIN dbo.pogodba P ON O.id_cont = P.id_cont 
INNER JOIN dbo.partner C ON O.id_kupca = C.id_kupca		 
 WHERE (@par_st_opomina_enabled = 0 OR O.st_opomina = @par_st_opomina_value)
   AND (@par_id_pog_enabled = 0 OR P.id_pog = @par_id_pog_value)
   AND (@par_id_kupca_enabled = 0 OR O.id_kupca = @par_id_kupca_value)
   AND (@par_id_strm_enabled = 0 OR CHARINDEX(P.id_strm, @par_id_strm_value) > 0)
   AND (@par_vrsta_osebe_enabled = 0 OR CHARINDEX(C.vr_osebe, @par_vrsta_osebe_value) > 0)  
   AND ((@par_izdani_value = 1 AND RTRIM(O.dok_opom) <> '')
		OR (@par_izdani_value = 0 AND RTRIM(O.dok_opom) = '')) 
   AND o.izpisan = @par_izpisani_value
   AND O.st_opomina <> '-1'
   AND (@par_obdobje_enabled = 0 OR dbo.gfn_ConvertDateTime(O.cas_prip) BETWEEN @par_obdobje_datumod AND @par_obdobje_datumdo)
ORDER BY A.id_opom, A.id_tec
