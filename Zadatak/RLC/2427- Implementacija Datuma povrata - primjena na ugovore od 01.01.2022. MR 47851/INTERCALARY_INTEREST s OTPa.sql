--01.12.2020 g_josip MID 45864 - new calculation for contracts only with month installments

DECLARE @td datetime
SET @td = dbo.gfn_GetDatePart(GETDATE())

DECLARE @this_month datetime, @previous_month datetime, @zap_obr char(1)
SET @this_month = dbo.gfn_GenerateDateTime(YEAR(@td), MONTH(@td), 1)
SET @previous_month = DATEADD(mm, -1, @this_month)

SET @zap_obr = (SELECT CAST(pol_je_1ob AS char(1)) FROM dbo.nastavit)

SELECT
    p.id_pog,
    p.id_kupca,
    par.naz_kr_kup,
    vop.naziv as vrsta_osebe_partner,
    p.id_dob,
    dob.naz_kr_kup as naziv_kr_dob,
    p.dat_aktiv,
    DATEADD(dd, -1, @this_month) AS datum_dok,
    DATEADD(dd, 10, @this_month) AS dat_zap,
    p.dat_aktiv AS dat_od,
    pp.datum_dok AS dat_do,
    p.net_nal as net_nal,
    p.id_val,
    p.obr_mera,
    p.nacin_leas,
    p.status_akt,
    p.id_cont,
    p.id_tec,
    0 AS st_dni,
    p.aneks,
    CAST(0 AS bit) AS oznacen,
    CAST(0 AS bit) AS intk_candidat,
    3 AS tip_izracuna,
    p.prv_obr AS polog,
    case when n.odstej_var = 1 then p.varscina else 0 end as varscina
INTO #temp
FROM dbo.pogodba p
    INNER JOIN dbo.partner par ON p.id_kupca = par.id_kupca
    INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas
    LEFT JOIN (SELECT id_cont, MIN(datum_dok) AS datum_dok FROM dbo.planp 
        WHERE (id_terj = dbo.gfn_GetIdForSifTerj('LOBR') AND zap_obr = (1 + @zap_obr))
			OR (id_terj = dbo.gfn_GetIdForSifTerj('NAPO') AND zap_obr = 1)
			GROUP BY id_cont) pp on p.id_cont = pp.id_cont
    INNER JOIN dbo.VRST_OSE vop ON par.vr_osebe = vop.VR_OSEBE
    INNER JOIN dbo.partner dob ON p.id_dob = dob.id_kupca
	INNER JOIN dbo.kategor k on p.KATEGORIJA = k.kategorija
WHERE p.status_akt != 'Z'
	and p.id_cont not in (select id_cont from dbo.dokument where id_obl_zav = 'NK' and id_cont is not null group by id_cont)
	and isnull(k.opis,'0') != 'JN'
	and not (p.NACIN_LEAS in('F1','F3') and vop.SIFRA = 'FO' )
	and p.id_obd = '001' --samo za mjesečne jer je end mode i treba doraditi datum prve rate za ostala radoblja obračuna
--	and p.id_pog = '1053353'

-- Creatin table
SELECT TOP 0
    t.id_pog,
    t.id_kupca,
    t.naz_kr_kup,
	t.vrsta_osebe_partner,
    t.id_dob,
    t.naziv_kr_dob,
    t.dat_aktiv,
    t.datum_dok,
    t.dat_zap,
    t.dat_od,
    t.dat_do,
    t.net_nal,
    t.id_val,
    t.obr_mera,
    t.nacin_leas,
    t.status_akt,
    t.id_cont,
    t.id_tec,
    t.st_dni,
    t.aneks,
    t.oznacen,
    t.intk_candidat,
    t.tip_izracuna
INTO #candidates
FROM #temp t

-- Creatin data for cusror
SELECT
    t.id_pog,
    t.id_kupca,
    t.naz_kr_kup,
	t.vrsta_osebe_partner,
    t.id_dob,
    t.naziv_kr_dob,
    t.dat_aktiv,
    t.datum_dok,
    t.dat_zap,
    z.datum AS dat_od,
	CASE WHEN DATEADD(dd, 1, dbo.gfn_GetLastDayOfMonth(z.datum)) > t.dat_do and t.status_akt = 'A' THEN t.dat_do else DATEADD(dd, 1, dbo.gfn_GetLastDayOfMonth(z.datum)) END AS dat_do,
    z.znesek_val AS net_nal,
    t.id_val,
    t.obr_mera,
    t.nacin_leas,
    t.status_akt,
    t.id_cont,
    t.id_tec,
    t.aneks,
    t.polog,
    t.varscina
INTO #prev_month
FROM
    #temp t
    INNER JOIN (
        SELECT sum(pl.znesek_val) AS znesek_val, pl.id_cont, pl.datum
        FROM
            dbo.plac_izh pl
            INNER JOIN dbo.plac_izh_tip tip ON pl.id_plac_izh_tip = tip.id_plac_izh_tip --AND tip.sf_tip = 'PLAC'
        WHERE pl.status_placila = 'S' AND pl.datum < @this_month
GROUP BY pl.id_cont, pl.datum
        ) z ON t.id_cont = z.id_cont
ORDER BY t.id_cont, t.datum_dok, z.datum

-- Variable
DECLARE @id_cont_old int, @sum_plac decimal(18,2), @ze_dodana bit, @znesek decimal(18,2),
    @recnum int, @cnt int

SET @id_cont_old = 0
SET @sum_plac = 0
SET @ze_dodana = 0
SET @znesek = 0
SET @cnt = 0

-- Variable for cursor
DECLARE
    @id_pog char(11), @id_kupca char(6), @naz_kr_kup varchar(80), @dat_aktiv datetime,
    @datum_dok datetime, @dat_zap datetime, @dat_od datetime, @dat_do datetime,
    @net_nal decimal(18,2), @id_val char(3), @obr_mera decimal(7,4), @nacin_leas varchar(2),
    @status_akt char(1), @id_cont int, @id_tec char(3), @aneks char(1), @polog decimal(18,2),
	@varscina decimal(18,2), @vrsta_osebe_partner varchar(100), @id_dob char(6), @naziv_kr_dob varchar(80),
	@dat_dok_pp datetime, @net_nal_pog decimal (18,2), @prev_payment decimal(18,2)

DECLARE _cur CURSOR FAST_FORWARD FOR 
	SELECT * FROM #prev_month order by id_cont, datum_dok, dat_od

OPEN _cur
FETCH NEXT FROM _cur INTO 
    @id_pog, @id_kupca, @naz_kr_kup, 
    @vrsta_osebe_partner, @id_dob, @naziv_kr_dob,
    @dat_aktiv, @datum_dok, @dat_zap, @dat_od, @dat_do,
    @net_nal, @id_val, @obr_mera, @nacin_leas,
    @status_akt, @id_cont, @id_tec, @aneks, @polog, @varscina
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Different contract
    IF @id_cont_old != @id_cont
    BEGIN
		-- Cursor
		SELECT @recnum = count(*) FROM #prev_month WHERE id_cont = @id_cont
		SELECT @dat_dok_pp = ISNULL(dat_do,'20000101') FROM #temp WHERE id_cont = @id_cont
		SELECT @net_nal_pog = ISNULL(net_nal,0) FROM #temp WHERE id_cont = @id_cont
		SET @cnt = 1
        SET @sum_plac = 0
        SET @ze_dodana = 0
        SET @znesek = 0
		SET @prev_payment = 0
	END

	-- remove records which are after installments    
	IF @status_akt IN ('N','D')
	BEGIN
		SET @dat_dok_pp = DATEADD(dd, 1, dbo.gfn_GetLastDayOfMonth(@previous_month))
	END

	IF @previous_month >= @dat_dok_pp
	BEGIN
		GOTO naslednji
	END

    SET @sum_plac = @sum_plac + @net_nal

    -- for previous months
    IF @dat_od < @previous_month
    BEGIN
        SET @znesek = @sum_plac - (@polog + @varscina)

		-- control for one payment 100%
		IF @znesek > @net_nal_pog
		BEGIN
			SET @znesek = @net_nal_pog
		END

        IF @cnt <> @recnum
            GOTO naslednji
    END
    
    -- add record for previous month
    IF (@dat_od >= @previous_month OR (@cnt = @recnum AND @dat_od < @previous_month)) AND @znesek > 0
    BEGIN
        INSERT INTO #candidates (
                id_pog, id_kupca, naz_kr_kup, vrsta_osebe_partner, id_dob, naziv_kr_dob,
                dat_aktiv, datum_dok, t.dat_zap, dat_od, dat_do,
                net_nal, id_val, obr_mera, nacin_leas, status_akt, id_cont, id_tec, st_dni,
                aneks, oznacen, intk_candidat, tip_izracuna)
            VALUES(
                @id_pog, @id_kupca, @naz_kr_kup, @vrsta_osebe_partner, @id_dob, @naziv_kr_dob,
                @dat_aktiv, @datum_dok, @dat_zap, @previous_month, 
				CASE WHEN @dat_dok_pp < DATEADD(dd, 1, dbo.gfn_GetLastDayOfMonth(@previous_month)) THEN @dat_dok_pp ELSE DATEADD(dd, 1, dbo.gfn_GetLastDayOfMonth(@previous_month)) END,
                @znesek, @id_val, @obr_mera, @nacin_leas, @status_akt, @id_cont, @id_tec, 0,
                @aneks, 0, 0, 3)
        
		SET @prev_payment = @prev_payment + @znesek
        IF @cnt = @recnum AND @dat_od < @previous_month
            GOTO naslednji

        SET @ze_dodana = 1
        SET @znesek = 0
    END
    
    -- Payment (sum) smaller or equal then downpayment and bail
    IF @ze_dodana = 0 AND @sum_plac <= (@polog + @varscina)
    BEGIN
        GOTO naslednji
    END
    
    -- Payment (sum) bigger then downpayment and bail
    IF @ze_dodana = 0 AND @sum_plac > (@polog + @varscina)
    BEGIN
        SET @znesek = @sum_plac - (@polog + @varscina)

		-- control for one payment 100%
		IF @znesek > @net_nal_pog
		BEGIN
			SET @znesek = @net_nal_pog
		END

        SET @ze_dodana = 1
        GOTO insert_record
    END
    
    -- Payment (sum) bigger then downpayment
    IF @ze_dodana = 1
    BEGIN
        SET @znesek = @net_nal
        GOTO insert_record
    END
    
    insert_record:

	-- control for sum payments > net_nal pogodba
	IF @znesek + @prev_payment > @net_nal_pog
	BEGIN
		SET @znesek = @net_nal_pog - @prev_payment
	END

	IF @znesek > 0
	BEGIN
		INSERT INTO #candidates (
				id_pog, id_kupca, naz_kr_kup, vrsta_osebe_partner, id_dob, naziv_kr_dob,
				dat_aktiv, datum_dok, t.dat_zap, dat_od, dat_do,
				net_nal, id_val, obr_mera, nacin_leas, status_akt, id_cont, id_tec, st_dni,
				aneks, oznacen, intk_candidat, tip_izracuna)
			VALUES(
				@id_pog, @id_kupca, @naz_kr_kup, @vrsta_osebe_partner, @id_dob, @naziv_kr_dob,
				@dat_aktiv, @datum_dok, @dat_zap, @dat_od, @dat_do,
				@znesek, @id_val, @obr_mera, @nacin_leas, @status_akt, @id_cont, @id_tec, 0,
				@aneks, 0, 0, 3)
		
		SET @prev_payment = @prev_payment + @znesek --added 20.04.2016
	END
    SET @znesek = 0
    
    naslednji:

    SET @id_cont_old = @id_cont
	SET @cnt = @cnt + 1

    FETCH NEXT FROM _cur INTO 
    @id_pog, @id_kupca, @naz_kr_kup, 
    @vrsta_osebe_partner, @id_dob, @naziv_kr_dob,
    @dat_aktiv, @datum_dok, @dat_zap, @dat_od, @dat_do,
    @net_nal, @id_val, @obr_mera, @nacin_leas,
    @status_akt, @id_cont, @id_tec, @aneks, @polog, @varscina
END
CLOSE _cur
DEALLOCATE _cur

-- Update
UPDATE #candidates
    SET st_dni = datediff(dd, dat_od, dat_do),
    intk_candidat = CASE WHEN (datediff(dd, dat_od, dat_do) > 0 AND obr_mera > 0) THEN 1 ELSE 0 END

-- Return select
SELECT c.* FROM #candidates c
WHERE NOT EXISTS (
    SELECT *
    FROM
        dbo.gen_interkalarne_obr_child g
        INNER JOIN dbo.gen_interkalarne_obr gp ON g.id_intk = gp.id_intk
    WHERE gp.id_cont = c.id_cont AND g.dat_od = c.dat_od AND g.dat_do = c.dat_do
        AND g.osnova_izrac = c.net_nal)

--select * from #temp
--select * from #candidates
--select * from #prev_month

DROP TABLE #temp
DROP TABLE #candidates
DROP TABLE #prev_month
