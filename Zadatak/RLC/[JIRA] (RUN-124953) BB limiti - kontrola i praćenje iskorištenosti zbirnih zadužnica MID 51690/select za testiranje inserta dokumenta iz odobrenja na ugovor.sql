use nova_test --RLC

 
select top 5 * from dbo.odobrit_zavar

declare @id_odobrit int = 51054
declare @today datetime = getdate()

select * from dbo.odobrit_zavar where id_odobrit = @id_odobrit

SELECT null, null, null, null, null, CONVERT(CHAR(8), DATEADD(d, a.dni_zap, @today), 112), null,
        null, a.id_obl_zav, null/*, @id_cont*/, null, null, '', null, null, 0, b.kolicina, null,
        a.opis, '', '', 1, a.opravi_sam_def_val, '', '', 'A', '', 
        null, 0, a.vrst_red_d, '', null, 0/*, @user, @today, @user, @today*/
FROM dbo.dok a
INNER JOIN dbo.odobrit_zavar b on b.id_obl_zav = a.id_obl_zav
WHERE b.id_odobrit = @id_odobrit
and a.ali_na_pog = 0 and a.ali_na_zreg = 0 and a.ali_na_zner = 0

	SELECT null, null, null, null, null, CONVERT(CHAR(8), DATEADD(d, a.dni_zap, @today), 112), null,
          null, a.id_obl_zav, null/*, @id_cont*/, null, b.id_tec, '', null, null, b.ima, b.kolicina, null,
          a.opis, '', '', 1, a.opravi_sam_def_val, '', '', 'A', b.stevilka, 
          b.velja_do, b.id_vr_val, a.vrst_red_d, '', null, 0/*, @user, @today, @user, @today*/,
		  b.id_kupca, b.id_krov_dok
	FROM dbo.dok a
	INNER JOIN dbo.odobrit_zavar b on b.id_obl_zav = a.id_obl_zav
	WHERE b.id_odobrit = @id_odobrit
	and a.ali_na_pog = 0 and a.ali_na_zreg = 0 and a.ali_na_zner = 0
	
	
	



declare     @id_cont int = 78941,
    @user char(10) = 'g_tomislav'
declare @id_odobrit int --= 51054
declare @today datetime = getdate()
--AS
--BEGIN
--	DECLARE @id_odobrit int, @today datetime
	SET @id_odobrit = (SELECT id_odobrit FROM dbo.pogodba WHERE id_cont = @id_cont)
	SET @today = getdate()
	
	INSERT INTO dbo.dokument (dat_1op, dat_2op, dat_3op, dat_obv, dat_vink, datum, ddv_id, 
                              id_hipot, id_obl_zav, id_parent, id_cont, id_sdk, id_tec, id_zapo, id_master, id_zav, ima, kolicina, konec, 
                              opis, opis1, opombe, potrebno, opravi_sam, st_nalepke, st_vink, status_akt, stevilka, 
                              velja_do, vrednost, vrst_red_d, vrsta, zacetek, zav_je_on, vnesel, datum_dok, popravil, dat_poprave,
							  id_kupca, id_krov_dok)
	SELECT null, null, null, null, null, CONVERT(CHAR(8), DATEADD(d, a.dni_zap, @today), 112), null,
          null, a.id_obl_zav, null, @id_cont, null, b.id_tec, '', null, null, b.ima, b.kolicina, null,
          a.opis, '', '', 1, a.opravi_sam_def_val, '', '', 'A', b.stevilka, 
          b.velja_do, b.id_vr_val, a.vrst_red_d, '', null, 0, @user, @today, @user, @today,
		  b.id_kupca, b.id_krov_dok
	FROM dbo.dok a
	INNER JOIN dbo.odobrit_zavar b on b.id_obl_zav = a.id_obl_zav
	WHERE b.id_odobrit = @id_odobrit
	and a.ali_na_pog = 0 and a.ali_na_zreg = 0 and a.ali_na_zner = 0