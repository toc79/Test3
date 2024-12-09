-- fix: all data is FROM snapshot
--SELECT * FROM oc_reports
--23.04.2015. B.K. dodani uvjet za OF tip leasinga da nedospjela proknjižena rata ulazi u DNPL
--12.06.2015. B.K. promjena za RLC za se grupa djelatnosti koristi iz polja dej_grupa1
--12.06.2015. B.K. promjena za RCL izračun vrijednosti ispravaka vrijednosti po kontima
--12.06.2015. B.K. promjena za RCL izračun DNPL ukupno i po bucketima te nedospjelo za FL, korekcija vrijednosti po kontima
--27.06.2015. B.K. dorada pripreme podataka za Z-N 
--27.07.2015. B.K. dorada za parametriziranu pripremu podatka o PPMV-u
--14.08.2015. B.K. dorada za pripremu PPMV-a u RS-IO Ostala imovina
--22.10.2015. B.K. korekcija izračuna budućih vrijednosti za OL tipove leasinga - iznos PPMV-a u otkupu se nije oduzimao 
--28.01.2016. B.K. ispravak izračuna ugovorenih vrijednosti na SP_OL izvještaju
--29.01.2016. B.K. ispravak pripreme zaključenih ugovora s graničnim datumom -nisu se uzimali u obzir
--11.02.2016. B.K. dorada pripreme RS-IO i SFI izvještaja da se ovino o parametrima za izuzimanje PPMV-a iz glavnih podataka izvještaja on se priprema u redak Ostala imovina
--15.02.2016. B.K. promjena za RLC dorada pripreme RS-IO da se umanjuju vrijednosti za vrijednosti ispravaka i razgraničenja
--15.02.2016. B.K. korekcija rasporeda jamčevine i depozita kod RS-IO izvještaja do_1_god i 1_do_3god
--01.03.2016. B.K. ispravak izračuna RS-IO izvještaja zbog slučajeva podataka bez vrijednosti u ispravcima i/ili korekcijama (SVI)
------------------ Napravljena dodada da se u RS-IO izvještaju pripremaju vrijednosti umanjene za iznose ispravaka/korekcija (neto) 
--01.03.2016. B.K. dopuna RS-IO da se za O3 (jamčevina i depoziti) priprema za U i N tipove (zakup i najam) (SVI)
--08.03.2016. B.K. privremena dorada da se podaci za SP izvještaje pripremaju ovisno o polju Aneks ugovora odnosno isključuju se ugvori s aneksom S
--25.04.2016. B.K. promjena pripreme novozaključenih ugovora ovisno o datumu potpisa (dat_potpisa) (SVI)
--25.04.2016. B.K. korekcija u SFI izvještaju da se za OL tip ugovora ne priprema Nedospjelo (SVI)
--10.10.2016. B.K. dodani uvjeti da se podešavanja iz General_register gledaju i ovisno o postavci NEAKTIVEN
--14.07.2017. B.K. dodatna priprema korekcija izravn iz LSK po kontu 120301, vrsti dokumetna OST i samo po ugovoru 18010/06 -- PRIVREMENO RJEŠENJE (MID: 38352)
--25.10.2017. B.K. isključena priprema TP ugovora iz čitave pripreme podataka
--15.02.2018. B.K. -- Verzija 6.8 --- dodavanje potrebnih promjena za HIBRID i REKLASIFICIRANE ugovore - MID: 38352
--23.04.2018. B.K. -- dorade za jamčevinu kod OR koja je dodana kao potraživanje 23 - OTKUPA
--21.05.2020. D.K. -- dorada bud_potr i bud_potr_ppmv po MR 44801

DECLARE @datum datetime, @datum2 datetime, @kvartal int, @kvartal2 int
DECLARE @dat2a datetime, @dat2b datetime, @dat1a datetime, @dat1b datetime
DECLARE @id_oc_report1 int, @id_oc_report2 int, @dod_usl_enabled int
DECLARE @FO varchar(200), @SP varchar(200), @PO varchar(200), @DJ varchar(200), @NO varchar(200)
DECLARE @FO2 varchar(200), @SP2 varchar(200), @PO2 varchar(200), @DJ2 varchar(200), @NO2 varchar(200)
DECLARE @nezap_proknj_is_odr int, @use_nezap_proknj_is_odr int
DECLARE @lcSQL varchar(max), @main_db varchar(100)
DECLARE @Zakupi varchar(200), @Najmovi varchar(200)
DECLARE @Custom_SEKTOR int, @Custom_SEKTOR2 bit
DECLARE @future_PPMV int
DECLARE @dnpl_PPMV int
DECLARE @value_with_PPMV int
DECLARE @use_dat_podpisa1 datetime, @use_dat_podpisa2 datetime
DECLARE @OF_Book_All bit


SET @id_oc_report1 = {1}
SET @id_oc_report2 = {3}
SET @dod_usl_enabled = {4}
SET @use_nezap_proknj_is_odr = {5}
SET @nezap_proknj_is_odr = {7}

SET @OF_Book_All = (Select CAST(count(*) as bit) from dbo.CUSTOM_SETTINGS where code = 'BOOKING_CRO_OF_BOOK_ALL' and  (val = '1' OR LOWER(val) = 'true'))

SET @main_db = REPLACE(DB_NAME(),'rea','nova')

SET @FO = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report1 AND id_key='FO') 
SET @SP = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report1 AND id_key='SP') 
SET @PO = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report1 AND id_key='PO') 
SET @DJ = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report1 AND id_key='DJ') 
SET @NO = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report1 AND id_key='NO') 

SET @FO2 = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report2 AND id_key='FO') 
SET @SP2 = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report2 AND id_key='SP') 
SET @PO2 = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report2 AND id_key='PO') 
SET @DJ2 = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report2 AND id_key='JS') 
SET @NO2 = (SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_VROSEBE' AND id_oc_report = @id_oc_report1 AND id_key='NO') 

SET @Zakupi = COALESCE((SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_ZAKUPI' AND id_oc_report = @id_oc_report1),'')
SET @Najmovi = COALESCE((SELECT value FROM dbo.general_register WHERE id_register = 'HANFA_SP_NAJMOVI' AND id_oc_report = @id_oc_report1),'')

SET @Custom_SEKTOR = COALESCE((SELECT val_bit FROM dbo.general_register WHERE id_register = 'HANFA_SP_ENABLE_CUSTOM_SEKTOR' AND id_oc_report = @id_oc_report1),0)
SET @Custom_SEKTOR2 = COALESCE((SELECT val_bit FROM dbo.general_register WHERE id_register = 'HANFA_SP_ENABLE_CUSTOM_SEKTOR' AND id_oc_report = @id_oc_report2),0)

SET @future_PPMV = COALESCE((SELECT val_num FROM dbo.general_register WHERE id_register = 'HANFA_SP_FUTURE_PPMV' AND id_oc_report = @id_oc_report1),0)
SET @dnpl_PPMV = COALESCE((SELECT val_num FROM dbo.general_register WHERE id_register = 'HANFA_SP_DNPL_PPMV' AND id_oc_report = @id_oc_report1),0)
SET @value_with_PPMV = COALESCE((SELECT val_num FROM dbo.general_register WHERE id_register = 'HANFA_SP_VALUE_WITH_PPMV' AND id_oc_report = @id_oc_report1),0)

SET @use_dat_podpisa1 = COALESCE((SELECT val_bit FROM dbo.general_register WHERE id_register = 'HANFA_SP_USE_DAT_POTPISA' AND id_oc_report = @id_oc_report1),0)
SET @use_dat_podpisa2 = COALESCE((SELECT val_bit FROM dbo.general_register WHERE id_register = 'HANFA_SP_USE_DAT_POTPISA' AND id_oc_report = @id_oc_report2),0)
SET @datum = (SELECT date_to FROM dbo.oc_reports WHERE id_oc_report = @id_oc_report1)
SET @datum2 = (SELECT date_to FROM dbo.oc_reports WHERE id_oc_report = @id_oc_report2)

SET @kvartal = DATEPART(qq, @datum)
--SET @dat1a = DATEADD(qq, DATEDIFF(qq, 0, @datum), 0)     --'20060101'
SET @dat1a = DATEADD(yyyy, DATEDIFF(yyyy, 0, @datum), 0)
SET @dat1b = DATEADD(qq, DATEDIFF(qq, -1, @datum), -1)   --'20060930'

SET @kvartal2 = DATEPART(qq, @datum2)
--SET @dat2a = DATEADD(qq, DATEDIFF(qq, 0, @datum2), 0)    --'20050101'
SET @dat2a = DATEADD(yyyy, DATEDIFF(yyyy, 0, @datum2), 0)
SET @dat2b = DATEADD(qq, DATEDIFF(qq, -1, @datum2), -1)  --'20050930'

IF @use_nezap_proknj_is_odr = 0
BEGIN
	SET @nezap_proknj_is_odr = 0
END


/*Priprema tabele sa tipovima leasinga*/
-- O - Operativni tip leasinga
-- F - Financiski tipovi leasinga
-- Z - Zajam - stari tip leasigna 
-- N - Najam nekretnina
-- U - ZakUp nekretnina 

Select CASE WHEN n.leas_kred = 'K' THEN 'Z'
			WHEN n.leas_kred = 'L' AND n.tip_knjizenja = '2' THEN 'F'
			WHEN n.leas_kred = 'L' AND n.tip_knjizenja = '1' AND CHARINDEX(n.nacin_leas, @Najmovi) = 0 AND CHARINDEX(n.nacin_leas, @Zakupi) = 0 THEN 'O'
			WHEN n.leas_kred = 'L' AND n.tip_knjizenja = '1' AND CHARINDEX(n.nacin_leas, @Najmovi) > 0 THEN 'N'
			WHEN n.leas_kred = 'L' AND n.tip_knjizenja = '1' AND CHARINDEX(n.nacin_leas, @Zakupi) > 0 THEN 'U'
			ELSE 'X' END as tip_ugovora 
, n.* 
INTO #NACINI_L
From dbo.NACINI_L n
Where n.id_oc_report IN (@id_oc_report1, @id_oc_report2)
AND n.nacin_leas NOT in ('TP')
/*KRAJ Priprema tabele sa tipovima leasigna*/




/*POČETAK Određivanje SEKTORA po zasebnom algoritmu*/
CREATE TABLE #PARTNER_SEKTOR ([id_kupca] [char](6),
			[vr_osebe] [char](2),
			[p_kateg] [char](2),
			[sektor] [varchar](20),
			[id_oc_report] [int])

INSERT into #PARTNER_SEKTOR (id_kupca, vr_osebe, p_kateg, sektor, id_oc_report)
Select p.id_kupca, p.vr_osebe, p.p_kateg, 
ISNULL(SUBSTRING(g.ID_KEY,0,LEN(g.ID_KEY)),'NEFINANCIJSKE') as sektor, p.id_oc_report
From dbo.oc_customers p
Left Join dbo.GENERAL_REGISTER g ON p.vr_osebe = g.VALUE AND p.p_kateg = g.VAL_CHAR and g.ID_REGISTER = 'HANFA_SP_SEKTOR_CUSTOM_RLC' and p.id_oc_report = g.id_oc_report
Where p.id_oc_report IN (@id_oc_report1, @id_oc_report2)
/*KRAJ Određivanje SEKTORA po zasebnom algoritmu*/



SELECT a.id_oc_report, a.id_cont,

/*ZA OPERATIVNI LEASING PO DATUMU DOKUMENTA; RAZLIKA SAMO U PERIODU MANJEM OD 30 DANA I UKUPNOM IZNOSU*/
SUM(CASE WHEN a.evident = '*' THEN a.ex_saldo_dom ELSE 0 END) as total_odr_dd,
SUM(CASE WHEN a.evident = '*' AND v.sif_terj in ('LOBR','OPC','POLO','VARS') THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as total_odr_dd_PPMV,

SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude <= 30 THEN a.ex_saldo_dom ELSE 0 END) as odr_30_dd,
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude <= 30 AND v.sif_terj in ('LOBR','OPC','POLO','VARS') THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_30_dd_PPMV,


/*ZA FINANCIJSKI LEASING PO DATUMU DOSPIJEĆA; RAZLIKA SAMO U PERIODU MANJEM OD 30 DANA I UKUPNOM IZNOSU*/
SUM(CASE WHEN a.evident = '*' AND a.ex_dni_zamude >= 0 And v.sif_terj IN ('LOBR', 'POLO') THEN a.ex_saldo_dom ELSE 0 END) as total_odr_dz,
SUM(CASE WHEN a.evident = '*' AND a.ex_dni_zamude >= 0 And v.sif_terj IN ('LOBR', 'POLO') THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as total_odr_dz_PPMV,

SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 0 and 30 And v.sif_terj IN ('LOBR', 'POLO') THEN a.ex_saldo_dom ELSE 0 END) as odr_30_dz,
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 0 and 30 And v.sif_terj IN ('LOBR', 'POLO') THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_30_dz_PPMV,

SUM(CASE WHEN a.evident = '*' AND v.sif_terj NOT IN ('LOBR', 'POLO') THEN a.ex_saldo_dom ELSE 0 END) as total_odr_dd_kp,
SUM(CASE WHEN a.evident = '*' AND v.sif_terj NOT IN ('LOBR', 'POLO') and a.ex_dni_zamude <= 30 THEN a.ex_saldo_dom ELSE 0 END) as odr_30_dd_kp,



/*I ZA FL I ZA OL*/ 
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 31 and 60 THEN a.ex_saldo_dom ELSE 0 END) as odr_31_60,
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 31 and 60 THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_31_60_PPMV,

SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 61 and 90 THEN a.ex_saldo_dom ELSE 0 END) as odr_61_90,
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 61 and 90 THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_61_90_PPMV,

SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 91 and 120 THEN a.ex_saldo_dom ELSE 0 END) as odr_91_120,
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 91 and 120 THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_91_120_PPMV,

SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 121 and 180 THEN a.ex_saldo_dom ELSE 0 END) as odr_121_180,
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 121 and 180 THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_121_180_PPMV,

SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 181 and 365 THEN a.ex_saldo_dom ELSE 0 END) as odr_181_365,
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude between 181 and 365 THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_181_365_PPMV,

SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude >= 366 THEN a.ex_saldo_dom ELSE 0 END) as odr_366,
SUM(CASE WHEN a.evident = '*' and a.ex_dni_zamude >= 366 THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_366_PPMV,

/*BUDUĆA POTRAŽIVANJA*/
SUM(CASE WHEN a.evident = '' AND v.sif_terj IN ('LOBR','POLO',CASE WHEN n.ol_na_nacin_fl = 1 THEN 'OPC' END) THEN a.ex_saldo_dom * (a.neto / a.debit) ELSE 0 END) as neto_not_booked,
SUM(CASE WHEN a.evident = '' AND v.sif_terj IN ('LOBR','POLO') THEN a.ex_saldo_dom * (a.obresti / a.debit) ELSE 0 END) as obresti_not_booked,
SUM(CASE WHEN a.evident = '' AND v.sif_terj IN ('LOBR','POLO') THEN a.ex_saldo_dom * (a.regist / a.debit) ELSE 0 END) as regist_not_booked,
SUM(CASE WHEN a.evident = '' AND v.sif_terj IN ('LOBR','POLO') THEN a.ex_saldo_dom * (a.robresti / a.debit) ELSE 0 END) as robresti_not_booked,
SUM(CASE WHEN a.evident = '*' AND a.ex_dni_zamude < 0 AND v.sif_terj IN ('LOBR','OPC','POLO','VARS') THEN a.ex_saldo_dom * (a.neto / a.debit)ELSE 0 END) as neto_not_dued,
SUM(CASE WHEN a.evident = '*' AND a.ex_dni_zamude < 0 AND v.sif_terj IN ('LOBR','OPC','POLO','VARS') THEN a.ex_saldo_dom * (a.robresti / a.debit)ELSE 0 END) as robresti_not_dued,

SUM(CASE WHEN n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 AND @nezap_proknj_is_odr = 0 and a.evident = '*' THEN a.ex_saldo_dom ELSE 0 END) 
-
SUM(CASE WHEN n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 AND @nezap_proknj_is_odr = 0 and a.evident = '*' AND a.ex_dni_zamude < 0 AND v.sif_terj IN ('LOBR','OPC','POLO','VARS') 
	THEN a.ex_saldo_dom * (a.robresti / a.debit)ELSE 0 END)
as total_odr_OF,

SUM(CASE WHEN n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 AND @nezap_proknj_is_odr = 0 and a.evident = '*' AND a.ex_dni_zamude >= 0 And v.sif_terj IN ('LOBR', 'POLO') 
	THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as total_odr_OF_PPMV,


SUM(CASE WHEN n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 AND @nezap_proknj_is_odr = 0 and a.evident = '*' and a.ex_dni_zamude <= 30 THEN a.ex_saldo_dom ELSE 0 END) 
-
SUM(CASE WHEN n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 AND @nezap_proknj_is_odr = 0 and a.evident = '*' AND a.ex_dni_zamude < 0 AND v.sif_terj IN ('LOBR','OPC','POLO','VARS') 
	THEN a.ex_saldo_dom * (a.robresti / a.debit)ELSE 0 END)
as odr_30_of,

SUM(CASE WHEN n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 AND @nezap_proknj_is_odr = 0 and a.evident = '*' and a.ex_dni_zamude between 0 and 30 And v.sif_terj IN ('LOBR', 'POLO') 
	THEN a.ex_saldo_dom * (a.robresti/a.debit) ELSE 0 END) as odr_30_OF_PPMV,

MAX(a.ex_dni_zamude) as odr_max_days
INTO #oc_claims
FROM dbo.oc_claims a
LEFT JOIN dbo.vrst_ter v on a.id_oc_report = v.id_oc_report AND a.id_terj = v.id_terj
LEFT JOIN dbo.nacini_l n on a.id_oc_report = n.id_oc_report AND a.nacin_leas = n.nacin_leas  
WHERE a.id_oc_report IN (@id_oc_report1, @id_oc_report2)
GROUP BY a.id_cont, a.id_oc_report


--ako se PPMV isključuje iz DNPL tada se izvršava ovaj dio oviso o podešavanju
IF @dnpl_PPMV = 0  
BEGIN 
UPDATE #oc_claims 
SET total_odr_dd = total_odr_dd - total_odr_dd_PPMV,
	odr_30_dd = odr_30_dd - odr_30_dd_PPMV,
	total_odr_dz = total_odr_dz - total_odr_dz_PPMV,
	odr_30_dz = odr_30_dz - odr_30_dz_PPMV,
	odr_31_60 = odr_31_60 - odr_31_60_PPMV,
	odr_61_90 = odr_61_90 - odr_61_90_PPMV,
	odr_91_120 = odr_91_120 - odr_91_120_PPMV,
	odr_121_180 = odr_121_180 - odr_121_180_PPMV,
	odr_181_365 = odr_181_365 - odr_181_365_PPMV,
	odr_366 = odr_366 - odr_366_PPMV,
	total_odr_OF = total_odr_OF - total_odr_OF_PPMV,
	odr_30_of = odr_30_of - odr_30_OF_PPMV
END



--specifično potraživanje VOPC
Select f.id_oc_report, f.id_cont, SUM(f.neto) as glav_vopc,
	(dbo.gfn_DiffYears(r.date_to, f.datum_dok - 1) + 1) as year_offset_max
INTO #OCF	
From dbo.oc_claims_future f
	INNER JOIN dbo.VRST_TER v on f.id_oc_report = v.id_oc_report and f.id_terj = v.id_terj
	INNER JOIN dbo.oc_reports r on f.id_oc_report = r.id_oc_report 
Where v.sif_terj = 'VOPC'
	  AND f.id_oc_report in (@id_oc_report1, @id_oc_report2)
Group By f.id_oc_report, f.id_cont, dbo.gfn_DiffYears(r.date_to, f.datum_dok - 1)


/*BUDUĆA POTRAŽIVANJA*/
Select a.id_oc_report, a.id_cont,
SUM(CASE WHEN a.year_offset_max = 1 THEN 
	dbo.gfn_XChange('000',a.ex_g1_neto + (a.ex_g1_robresti * @future_PPMV) + CASE WHEN n.tip_knjizenja = '1' 
			THEN a.ex_g1_obresti + CASE WHEN @dod_usl_enabled = 1 THEN a.ex_g1_regist ELSE 0 END 
				- (a.ex_g1_debit_opc_nezap - a.ex_g1_davek_opc_nezap - CASE WHEN @future_PPMV = 0 THEN ISNULL(a.ex_g1_robresti_opc_nezap,0) ELSE 0 END) ELSE 0 END, b.id_tec, r.date_to, a.id_oc_report) 
		+ IsNull(CASE WHEN ocf.year_offset_max = 1 THEN dbo.gfn_XChange('000', ocf.glav_vopc, b.id_tec, r.date_to, a.id_oc_report) ELSE 0 END, 0.00)
		ELSE 0 END)  as do_1_godine,

SUM(CASE WHEN a.year_offset_max = 1 THEN 
	dbo.gfn_XChange('000',a.ex_g1_robresti, b.id_tec, r.date_to, a.id_oc_report) 
		ELSE 0 END) as do_1_godine_PPMV,

SUM(CASE WHEN a.year_offset_min >= 1 AND a.year_offset_max <= 3 THEN 
	dbo.gfn_XChange('000',a.ex_g1_neto + (a.ex_g1_robresti * @future_PPMV) + CASE WHEN n.tip_knjizenja = '1' 
			THEN a.ex_g1_obresti + CASE WHEN @dod_usl_enabled = 1 THEN a.ex_g1_regist ELSE 0 END 
			- (a.ex_g1_debit_opc_nezap - a.ex_g1_davek_opc_nezap - CASE WHEN @future_PPMV = 0 THEN ISNULL(a.ex_g1_robresti_opc_nezap,0) ELSE 0 END) ELSE 0 END, b.id_tec, r.date_to, a.id_oc_report) 
		+ IsNull(CASE WHEN ocf.year_offset_max > 1 AND ocf.year_offset_max <= 3 THEN dbo.gfn_XChange('000', ocf.glav_vopc, b.id_tec, r.date_to, a.id_oc_report) ELSE 0 END, 0.00)
		ELSE 0 END) as od_1_do_3_godine,

SUM(CASE WHEN a.year_offset_min >= 1 AND a.year_offset_max <= 3 THEN 
	dbo.gfn_XChange('000', a.ex_g1_robresti, b.id_tec, r.date_to, a.id_oc_report) 
		ELSE 0 END) as od_1_do_3_godine_PPMV,

SUM(CASE WHEN a.year_offset_min >= 3 AND a.year_offset_max <= 5 THEN 
	dbo.gfn_XChange('000',a.ex_g1_neto + (a.ex_g1_robresti * @future_PPMV) + CASE WHEN n.tip_knjizenja = '1' 
			THEN a.ex_g1_obresti + CASE WHEN @dod_usl_enabled = 1 THEN a.ex_g1_regist ELSE 0 END 
			- (a.ex_g1_debit_opc_nezap - a.ex_g1_davek_opc_nezap - CASE WHEN @future_PPMV = 0 THEN ISNULL(a.ex_g1_robresti_opc_nezap,0) ELSE 0 END) ELSE 0 END, b.id_tec, r.date_to, a.id_oc_report) 
		+ IsNull(CASE WHEN ocf.year_offset_max > 3 AND ocf.year_offset_max <= 5 THEN dbo.gfn_XChange('000', ocf.glav_vopc, b.id_tec, r.date_to, a.id_oc_report) ELSE 0 END, 0.00)
		ELSE 0 END) as od_3_do_5_godine,

SUM(CASE WHEN a.year_offset_min >= 3 AND a.year_offset_max <= 5 THEN 
	dbo.gfn_XChange('000', a.ex_g1_robresti, b.id_tec, r.date_to, a.id_oc_report) 
		ELSE 0 END) as od_3_do_5_godine_PPMV,

SUM(CASE WHEN a.year_offset_min >= 5 THEN 
	dbo.gfn_XChange('000',a.ex_g1_neto + (a.ex_g1_robresti * @future_PPMV) 
			+ CASE WHEN n.tip_knjizenja = '1' 
				THEN a.ex_g1_obresti 
					+ CASE WHEN @dod_usl_enabled = 1 THEN a.ex_g1_regist ELSE 0 END 
					- (a.ex_g1_debit_opc_nezap - a.ex_g1_davek_opc_nezap 
						- CASE WHEN @future_PPMV = 0 THEN ISNULL(a.ex_g1_robresti_opc_nezap,0) ELSE 0 END) 
					ELSE 0 END, b.id_tec, r.date_to, a.id_oc_report) 
		+ IsNull(CASE WHEN ocf.year_offset_max > 5  THEN dbo.gfn_XChange('000', ocf.glav_vopc, b.id_tec, r.date_to, a.id_oc_report) ELSE 0 END, 0.00)	
		ELSE 0 END) as preko_5_godina,

SUM(CASE WHEN a.year_offset_min >= 5 THEN 
	dbo.gfn_XChange('000', a.ex_g1_robresti, b.id_tec, r.date_to, a.id_oc_report) 
		ELSE 0 END) as preko_5_godina_PPMV
INTO #FUTURE_DETAILS
From dbo.oc_contracts_future_details a
INNER JOIN dbo.oc_contracts b on a.id_oc_report = b.id_oc_report and a.id_cont = b.id_cont
INNER JOIN #NACINI_L n on b.nacin_leas = n.nacin_leas and b.id_oc_report = n.id_oc_report
INNER JOIN dbo.oc_reports r on a.id_oc_report = r.id_oc_report 
LEFT JOIN #OCF ocf on a.ID_CONT = ocf.ID_CONT and a.ID_OC_REPORT = ocf.id_oc_report 
Where a.id_oc_report = @id_oc_report1
--And n.tip_knjizenja = '2'
Group By a.id_oc_report, a.id_cont



/*REZERVACIJE PO SVIM UGOVORIMA PO OBJE SNIMKE*/
CREATE TABLE #rezervacije(id_cont int, id_oc_report int, rezervacije_dnpl decimal (18,2), rezervacije_bud decimal (18,2))


INSERT INTO #REZERVACIJE
Select x.id_cont, x.id_oc_report,
sum(case when x.tip = 'DNPL' then (x.saldo_dom * x.predznak) else 0 end) as rezervacije_dnpl,
sum(case when x.tip = 'BUD' then  (x.saldo_dom * x.predznak) else 0 end) as rezervacije_bud

From (
	Select a.id_oc_report, a.id_cont, a.konto, 
	SUM(a.debit_dom-a.kredit_dom) as saldo_dom,
	g.val_num as predznak,
	'DNPL' as tip
	From dbo.oc_lsk a
	Inner Join dbo.GENERAL_REGISTER g on a.id_oc_report = g.id_oc_report AND a.konto = g.id_key
	Where ID_REGISTER = 'HANFA_SP_KONTO_ISP_DNPL' AND Isnull(g.neaktiven, 0) = 0 AND a.id_oc_report in (@id_oc_report1, @id_oc_report2)
	Group by a.id_oc_report, a.id_cont, a.konto, g.val_num 

	UNION ALL

	Select a.id_oc_report, a.id_cont, a.konto, 
	SUM(a.debit_dom-a.kredit_dom) as saldo_dom,
	g.val_num as predznak,
	'BUD' as tip
	From dbo.oc_lsk a
	Inner Join dbo.GENERAL_REGISTER g on a.id_oc_report = g.id_oc_report AND a.konto = g.id_key
	Where ID_REGISTER = 'HANFA_SP_KONTO_ISP_BUD' AND Isnull(g.neaktiven, 0) = 0 AND a.id_oc_report in (@id_oc_report1, @id_oc_report2)
	Group by a.id_oc_report, a.id_cont, a.konto, g.val_num 
) x
inner join dbo.oc_contracts c on x.id_oc_report = c.ID_OC_REPORT and x.id_cont = c.id_cont
group by x.id_cont, x.id_oc_report
/* KRAJ REZERVACIJE PO SVIM UGOVORIMA PO OBJE SNIMKE*/



/*STANJA ZA KOREKCIJE DNPL i BUD KOD FL PO KONTIMA RAZGRANIČENJA */
CREATE TABLE #KOREKCIJE(id_cont int, id_oc_report int, korekcije_dnpl decimal (18,2), korekcije_bud decimal (18,2))

INSERT INTO #KOREKCIJE
Select x.id_cont, x.id_oc_report,
sum(case when x.tip = 'DNPL' then (x.saldo_dom * x.predznak) else 0 end) as korekcije_dnpl,
sum(case when x.tip = 'BUD' then  (x.saldo_dom * x.predznak) else 0 end) as korekcije_bud
From (
	Select a.id_oc_report, a.id_cont, a.konto, 
	SUM(a.debit_dom-a.kredit_dom) as saldo_dom,
	g.val_num as predznak,
	'DNPL' as tip
	From dbo.oc_lsk a
	Inner Join dbo.GENERAL_REGISTER g on a.id_oc_report = g.id_oc_report AND a.konto = g.id_key
	Where g.ID_REGISTER = 'HANFA_SP_KONTO_RAZGR_DNPL' AND Isnull(g.neaktiven,0) = 0 AND a.id_oc_report in (@id_oc_report1, @id_oc_report2)
	Group by a.id_oc_report, a.id_cont, a.konto, g.val_num 

	UNION ALL

	Select a.id_oc_report, a.id_cont, a.konto, 
	SUM(a.debit_dom-a.kredit_dom) as saldo_dom,
	g.val_num as predznak,
	'BUD' as tip
	From dbo.oc_lsk a
	Inner Join dbo.GENERAL_REGISTER g on a.id_oc_report = g.id_oc_report AND a.konto = g.id_key
	Where g.ID_REGISTER = 'HANFA_SP_KONTO_RAZGR_BUD' AND Isnull(g.neaktiven,0) = 0 AND a.id_oc_report in (@id_oc_report1, @id_oc_report2)
	Group by a.id_oc_report, a.id_cont, a.konto, g.val_num 
	
	UNION ALL
	
	Select @id_oc_report1 as id_oc_report, a.id_cont, a.konto, 
	SUM(a.debit_dom-a.kredit_dom) as saldo_dom,
	(-1) as predznak,
	'DNPL' as tip
	From nova_prod.dbo.lsk a
	Where a.id_cont = 19460 AND a.konto = '120301' and a.vrsta_dok = 'OST'
	Group by a.id_cont, a.konto 
) x
Inner join dbo.oc_contracts c on x.id_oc_report = c.ID_OC_REPORT and x.id_cont = c.id_cont
Group by x.id_cont, x.id_oc_report
/*KRAJ STANJA ZA KOREKCIJE DNPL i BUD KOD FL PO KONTIMA RAZGRANIČENJA */


SELECT a.id_oc_report, r.date_to, 
CASE WHEN a.id_oc_report = @id_oc_report1 THEN @kvartal ELSE @kvartal2 END as kvartal, 
CASE WHEN a.id_oc_report = @id_oc_report1 THEN @dat1a ELSE @dat2a END as kvartal_pd, 
CASE WHEN a.id_oc_report = @id_oc_report1 THEN @dat1b ELSE @dat2b END as kvartal_kd, 
/* PODACI O UGOVORU I PARTNERU*/
a.id_cont, a.id_pog, a.dat_sklen, a.dat_aktiv, a.dat_zakl, a.DAT_PODPISA, a.status_akt, a.id_kupca, p.naz_kr_kup, 

/*VRSTA OSOBE PREMA PODEŠAVANJIMA*/
CASE WHEN (CHARINDEX(p.vr_osebe, @FO) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @FO2) <> 0 AND a.id_oc_report = @id_oc_report2) THEN 'FO' 
	WHEN (CHARINDEX(p.vr_osebe, @SP) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @SP2) <> 0 AND a.id_oc_report = @id_oc_report2) THEN 'SP' 
	WHEN (CHARINDEX(p.vr_osebe, @PO) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @PO2) <> 0 AND a.id_oc_report = @id_oc_report2) THEN 'PO' 
	WHEN (CHARINDEX(p.vr_osebe, @DJ) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @DJ2) <> 0 AND a.id_oc_report = @id_oc_report2) THEN 'DJ' 
	WHEN (CHARINDEX(p.vr_osebe, @NO) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @NO2) <> 0 AND a.id_oc_report = @id_oc_report2) THEN 'NO' 
ELSE 'PO' END as vr_osebe, 

/*PREMA OBJEKTU LEASINGA dbo.vrst_opr.id_grupe2 mora biti u HANFA_SP_OBJEKT šifrantu*/
CASE WHEN v.id_grupe2 NOT IN ('NEKR', 'GOSP', 'OSOB', 'PLOV', 'OPRE', 'OSTA', 'LETJ') THEN 'OSTA' ELSE v.id_grupe2 END as vrsta,

/*PREMA ROČNOSTI*/
CASE WHEN a.traj_naj <= 12 THEN '1'
	WHEN a.traj_naj between 13 and 60 THEN '2'
	ELSE '3' END as rocnost, 
	
/*SEKTOR PREMA VRSTI OSOBE I GRUPI DJELATNOSTI*/
CASE WHEN @Custom_SEKTOR = 1 THEN IsNull(ps.sektor,'NEFINANCIJSKE')
ELSE (CASE 
		WHEN p.id_poste_sed not like 'HR%'  THEN 'NEREZIDENTI'
	
		WHEN ((CHARINDEX(p.vr_osebe, @FO) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @FO2) <> 0 AND a.id_oc_report = @id_oc_report2))
			   AND p.id_poste_sed like 'HR%' THEN 'STANOVNIŠTVO'
	
		WHEN ((CHARINDEX(p.vr_osebe, @PO) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @PO2) <> 0 AND a.id_oc_report = @id_oc_report2))
				AND p.id_poste_sed like 'HR%' AND d.dej_grupa = 'K' THEN 'FINANCIJSKE'
	
		WHEN ((CHARINDEX(p.vr_osebe, @PO) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @PO2) <> 0 AND a.id_oc_report = @id_oc_report2)) 
			AND p.id_poste_sed like 'HR%'  AND d.dej_grupa <> 'K' THEN 'NEFINANCIJSKE'
	
		WHEN ((CHARINDEX(p.vr_osebe, @DJ) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @DJ2) <> 0 AND a.id_oc_report = @id_oc_report2))
			AND p.id_poste_sed like 'HR%' THEN 'DRŽAVNE'
		
		WHEN ((CHARINDEX(p.vr_osebe, @NO) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @NO2) <> 0 AND a.id_oc_report = @id_oc_report2))
			AND p.id_poste_sed like 'HR%' THEN 'NEPROFITNE'
	ELSE 'NEFINANCIJSKE' END)
END as sektor, 

/*PREMA DJELATNOSTI*/
d.sif_dej as djelatnost,
CASE WHEN ((CHARINDEX(p.vr_osebe, @FO) <> 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @FO2) <> 0 AND a.id_oc_report = @id_oc_report2))
		AND d.DEJ_GRUPA1 <> 'T' THEN 'T'
	WHEN ((CHARINDEX(p.vr_osebe, @FO) = 0 AND a.id_oc_report = @id_oc_report1) OR (CHARINDEX(p.vr_osebe, @FO2) = 0 AND a.id_oc_report = @id_oc_report2))
		AND (d.dej_grupa1 = 'T' OR d.dej_grupa1 IS NULL OR RTRIM(d.DEJ_GRUPA1) = '' OR LEN(RTRIM(d.DEJ_GRUPA1)) > 1) THEN 'S'
ELSE RTRIM(d.DEJ_GRUPA1) END as djelatnost_grupa,

/*TIP FINANCIRANJA*/
--CASE WHEN n.leas_kred = 'K' THEN 'Z'
--	WHEN n.leas_kred != 'K' AND n.tip_knjizenja = '1' THEN 'O'
--	WHEN n.leas_kred != 'K' AND n.tip_knjizenja = '2' THEN 'F'
--END 
n.tip_ugovora as tip,

/*NOVO AKTIVIRANI U KVARTALU*/
CASE WHEN (a.id_oc_report = @id_oc_report1 AND CASE WHEN @use_dat_podpisa1 = 1 THEN a.dat_podpisa ELSE a.dat_aktiv END BETWEEN @dat1a AND @dat1b) 
		OR (a.id_oc_report = @id_oc_report2 AND CASE WHEN @use_dat_podpisa2 = 1 THEN a.dat_podpisa ELSE a.dat_aktiv END BETWEEN @dat2a AND @dat2b) THEN 1 ELSE 0 END as novo_aktivirani,

/*VRIJEDNOST UGOVORA; OPERATIVCI BEZ JAMČEVINE I OTKUPA*/
dbo.gfn_xchange('000', CASE WHEN n.tip_knjizenja = '1' 
	THEN ((dbo.gfn_OstObrToNeto(r.id_oc_report, a.id_cont, CASE WHEN @value_with_PPMV = 1 THEN 0 ELSE 1 END) * st_obrok) - CASE WHEN @dod_usl_enabled = 0 THEN a.oststr ELSE 0 END)
		 + dbo.gfn_PrvObrToNeto(a.vr_val_zac, a.prv_obr, a.robresti_zac, ds.davek, n.ima_robresti, n.dav_b, n.finbruto, n.dav_n, CASE WHEN @value_with_PPMV = 1 THEN 0 ELSE 1 END) 
	ELSE a.vr_val_zac - (CASE WHEN @value_with_PPMV = 0 THEN a.robresti_zac ELSE 0 END) END, a.id_tec, r.date_to, r.id_oc_report) as vr_val_zac,
dbo.gfn_xchange('000', CASE WHEN n.tip_knjizenja = '1' 
	THEN ((dbo.gfn_OstObrToNeto(r.id_oc_report, a.id_cont, CASE WHEN @value_with_PPMV = 1 THEN 0 ELSE 1 END) * st_obrok) - CASE WHEN @dod_usl_enabled = 0 THEN a.oststr ELSE 0 END)
		 + dbo.gfn_PrvObrToNeto(a.vr_val, a.prv_obr, CASE WHEN @value_with_PPMV = 1 THEN a.robresti_val ELSE 0 END, ds.davek, n.ima_robresti, n.dav_b, n.finbruto, n.dav_n, CASE WHEN @value_with_PPMV = 1 THEN 0 ELSE 1 END) 
	ELSE a.VR_VAL - (CASE WHEN @value_with_PPMV = 0 THEN a.robresti_val ELSE 0 END) END, a.id_tec,  r.date_to, r.id_oc_report) as vr_val,

/*IZNOS FINANCIRANJA; KORISTI SE SAMO ZA FL*/
dbo.gfn_xchange('000', a.net_nal_zac - CASE WHEN @value_with_PPMV = 0 THEN a.robresti_zac ELSE 0 END, a.id_tec,  r.date_to, r.id_oc_report) as net_nal_zac,
dbo.gfn_xchange('000', a.net_nal - CASE WHEN @value_with_PPMV = 0 THEN a.robresti_val ELSE 0 END, a.id_tec,  r.date_to, r.id_oc_report) as net_nal,

/*DOSPJELO NEPLAĆENO*/
CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND (n.ol_na_nacin_fl = 0 OR @OF_Book_All = 1) THEN ISNULL(cl.total_odr_dz,0) + ISNULL(cl.total_odr_dd_kp,0) 
	 WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 THEN ISNULL(cl.total_odr_OF,0) 
ELSE ISNULL(cl.total_odr_dd, 0) END as DNPL,

CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND (n.ol_na_nacin_fl = 0 OR @OF_Book_All = 1) THEN ISNULL(cl.total_odr_dz_PPMV,0) 
	 WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 THEN ISNULL(cl.total_odr_OF_PPMV,0) 
ELSE ISNULL(cl.total_odr_dd_PPMV, 0) END as DNPL_PPMV,

CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND (n.ol_na_nacin_fl = 0 OR @OF_Book_All = 1) THEN ISNULL(cl.odr_30_dz,0) + ISNULL(cl.odr_30_dd_kp,0) 
	 WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 THEN ISNULL(cl.odr_30_of,0) 
ELSE ISNULL(cl.odr_30_dd, 0) END as DNPL_30,

CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND (n.ol_na_nacin_fl = 0 OR @OF_Book_All = 1) THEN ISNULL(cl.odr_30_dz_PPMV,0) 
	 WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND n.ol_na_nacin_fl = 1 AND @OF_Book_All = 0 THEN ISNULL(cl.odr_30_OF_PPMV,0) 
ELSE ISNULL(cl.odr_30_dd_PPMV, 0) END as DNPL_30_PPMV,

ISNULL(cl.odr_31_60,0) AS DNPL_31_60,
ISNULL(cl.odr_31_60_PPMV,0) AS DNPL_31_60_PPMV,
ISNULL(cl.odr_61_90,0) AS DNPL_61_90,
ISNULL(cl.odr_61_90_PPMV,0) AS DNPL_61_90_PPMV,
ISNULL(cl.odr_91_120,0) AS DNPL_91_120,
ISNULL(cl.odr_91_120_PPMV,0) AS DNPL_91_120_PPMV,
ISNULL(cl.odr_121_180,0) AS DNPL_121_180,
ISNULL(cl.odr_121_180_PPMV,0) AS DNPL_121_180_PPMV,
ISNULL(cl.odr_181_365,0) AS DNPL_181_365,
ISNULL(cl.odr_181_365_PPMV,0) AS DNPL_181_365_PPMV,
ISNULL(cl.odr_366,0) AS DNPL_366,
ISNULL(cl.odr_366_PPMV,0) AS DNPL_366_PPMV,

/*NEDOSPJELO*/
dbo.gfn_xchange('000', a.ex_g1_neto + IsNull(ocf.glav_vopc, 0.00), a.id_tec, r.date_to,r.id_oc_report) 
+ dbo.gfn_xchange('000', CASE WHEN @future_PPMV = 1 THEN ISNULL(a.ex_g1_robresti,0) ELSE 0 END, a.id_tec, r.date_to,r.id_oc_report) 
	+ ISNULL(cl.neto_not_booked,0) 
	+ ISNULL(cl.robresti_not_booked * @future_PPMV, 0)

	+ CASE WHEN n.tip_knjizenja = '1' THEN isnull(cl.obresti_not_booked,0) 
										+ dbo.gfn_xchange('000',a.ex_g1_obresti,a.id_tec,r.date_to,r.id_oc_report) 
										+ CASE WHEN @dod_usl_enabled = 1 THEN dbo.gfn_xchange('000',a.ex_g1_regist,a.id_tec,r.date_to,r.id_oc_report) + isnull(cl.regist_not_booked,0) ELSE 0 END
										- dbo.gfn_xchange('000',ISNULL(a.ex_g1_debit_opc_nezap,0) - ISNULL(a.ex_g1_davek_opc_nezap,0) 
												- CASE WHEN @future_PPMV = 0 THEN ISNULL(a.ex_g1_robresti_opc_nezap,0) ELSE 0 END,a.id_tec,r.date_to,r.id_oc_report) 
	  ELSE 0 END 
	+ CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND (n.ol_na_nacin_fl = 0 OR @OF_Book_All = 1) THEN ISNULL(cl.neto_not_dued,0) ELSE 0 END 
	+ CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 THEN ISNULL(cl.robresti_not_dued * @future_PPMV,0) ELSE 0 END 
	as BUD_POTR,

dbo.gfn_xchange('000', ISNULL(a.ex_g1_robresti,0), a.id_tec, r.date_to,r.id_oc_report) 
	+ ISNULL(cl.robresti_not_booked, 0)
	+ CASE WHEN n.tip_knjizenja = '1' THEN - dbo.gfn_xchange('000', ISNULL(a.ex_g1_robresti_opc_nezap,0), a.id_tec,r.date_to,r.id_oc_report) ELSE 0 END 
	+ CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 THEN ISNULL(cl.robresti_not_dued,0) ELSE 0 END as BUD_POTR_PPMV,	
	
/*TRENUTNA VRIJEDNOST OS*/
ISNULL(fa.ex_present_val,0) as ex_present_val,
ISNULL(fa.ex_present_val_RLC,0) as ex_present_val_RLC,
/*STAROST,KORISTI SE U RS-IO ZA OL*/
CASE WHEN a.id_oc_report = @id_oc_report1 and a.status_akt = 'A' THEN DATEDIFF(m, r.date_to, a.ex_max_datum_dok) ELSE 0 END as kraj,

/*OBVEZE PO JAMČEVINI; KORISTI SE U RS-IO ZA OBVEZE*/
CASE WHEN a.id_oc_report = @id_oc_report1 and (a.status_akt = 'A' OR (a.status_akt = 'Z' AND a.dat_zakl > r.date_to))
		THEN dbo.gfn_xchange('000', a.se_varsc, a.id_tec, r.date_to, r.id_oc_report) ELSE 0 END as se_varsc,

/*BUDUĆA POTRAŽIVANJA ZA RS-IO i NKV-OL*/
ISNULL(cl.neto_not_booked,0) as neto_not_booked,
ISNULL(cl.robresti_not_booked,0) as robresti_not_booked,
CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 AND (n.ol_na_nacin_fl = 0 OR @OF_Book_All = 1) THEN ISNULL(cl.neto_not_dued,0) ELSE 0 END as neto_not_dued,
CASE WHEN n.tip_knjizenja = '2' And @nezap_proknj_is_odr = 0 THEN ISNULL(cl.robresti_not_dued,0) ELSE 0 END as robresti_not_dued,
ISNULL(fd.do_1_godine,0) as do_1_godine,
ISNULL(fd.do_1_godine_PPMV,0) as do_1_godine_PPMV,
ISNULL(fd.od_1_do_3_godine,0) as od_1_do_3_godine,
ISNULL(fd.od_1_do_3_godine_PPMV,0) as od_1_do_3_godine_PPMV,
ISNULL(fd.od_3_do_5_godine,0) as od_3_do_5_godina,
ISNULL(fd.od_3_do_5_godine_PPMV,0) as od_3_do_5_godina_PPMV,
ISNULL(fd.preko_5_godina,0) as preko_5_godina,
ISNULL(fd.preko_5_godina_PPMV,0) as preko_5_godina_PPMV,
CASE WHEN n.tip_knjizenja = '1' THEN isnull(cl.obresti_not_booked,0) ELSE 0 END as obresti_not_booked,
CASE WHEN n.tip_knjizenja = '1' And @dod_usl_enabled = 1 THEN isnull(cl.regist_not_booked,0) ELSE 0 END as regist_not_booked,
ISNULL(re.rezervacije_dnpl, 0) as rezervacije_dnpl,
ISNULL(re.rezervacije_bud, 0) as rezervacije_bud,
ISNULL(cl.odr_max_days, 0) as odr_max_days,
ISNULL(a.aneks,'') as aneks
INTO #CONTRACTS
FROM dbo.oc_contracts a
LEFT JOIN dbo.oc_reports r on a.id_oc_report = r.id_oc_report
LEFT JOIN dbo.vrst_opr v on a.id_vrste = v.id_vrste AND a.id_oc_report = v.id_oc_report
LEFT JOIN dbo.oc_customers p on a.id_kupca = p.id_kupca AND a.id_oc_report = p.id_oc_report
LEFT JOIN dbo.dejavnos d on p.sif_dej = d.sif_dej AND p.id_oc_report = d.id_oc_report
INNER JOIN #NACINI_L n on a.nacin_leas = n.nacin_leas AND a.id_oc_report = n.id_oc_report
LEFT JOIN #oc_claims cl on a.id_cont = cl.id_cont AND a.id_oc_report = cl.id_oc_report
LEFT JOIN (SELECT id_oc_report, id_cont, SUM(ex_present_val) as ex_present_val,
			SUM(nabav_vred + rev_osnove + spr_osnove - (odpis_vred + (mes_amort - prevr_amor) + spr_odpisa + rev_odpisa + iztrz_vred - ucinek_odp + (prevr_spr + prevr_nabv)) + prevr_odpv) as ex_present_val_RLC
			FROM dbo.fa 
			WHERE id_oc_report IN (@id_oc_report1,@id_oc_report2) 
			GROUP BY id_oc_report, id_cont
			) fa on a.id_cont = fa.id_cont AND a.id_oc_report = fa.id_oc_report
LEFT JOIN dbo.dav_stop ds on a.id_dav_st = ds.id_dav_st AND a.id_oc_report = ds.id_oc_report
LEFT JOIN #future_details fd on a.id_oc_report = fd.id_oc_report and a.id_cont = fd.id_cont 
LEFT JOIN #OCF ocf on a.id_oc_report = ocf.id_oc_report and a.id_cont = ocf.id_cont 
LEFT JOIN #rezervacije re on a.id_cont = re.id_cont AND a.id_oc_report = re.id_oc_report
LEFT JOIN #PARTNER_SEKTOR ps on  a.id_kupca = ps.id_kupca AND a.id_oc_report = ps.id_oc_report
WHERE 
a.id_oc_report IN (@id_oc_report1,@id_oc_report2)
AND (a.status_akt = 'A' 
	 OR (a.status_akt = 'Z' AND a.dat_zakl > r.date_to)
	 OR (a.status_akt = 'Z' AND a.dat_zakl <= r.date_to 
			AND (
					(a.id_oc_report = @id_oc_report1 AND a.dat_aktiv  BETWEEN @dat1a AND @dat1b)
					OR 
					(a.id_oc_report = @id_oc_report2 AND a.dat_aktiv BETWEEN @dat2a AND @dat2b)
				)
		 )
	OR (a.status_akt in ('N','D') 
			AND (
					(a.id_oc_report = @id_oc_report1 AND @use_dat_podpisa1 = 1 AND a.DAT_PODPISA IS NOT NULL AND a.dat_podpisa BETWEEN @dat1a AND @dat1b)
					OR
					(a.id_oc_report = @id_oc_report2 AND @use_dat_podpisa2 = 1 AND a.DAT_PODPISA IS NOT NULL AND a.dat_podpisa BETWEEN @dat2a AND @dat2b)
				)
		)
	)
ORDER BY a.id_cont ASC, a.id_oc_report ASC


/*POČETAK Ispravak pripremljenih podataka prema #KOREKCIJAMA za DNPL kupno i DNPL po bucketoma i ispravak nedospjelih potraživanja za FL*/
UPDATE #CONTRACTS set DNPL_30 = c.DNPL_30 - (c.DNPL_30/c.DNPL) * k.korekcije_DNPL, 
DNPL_31_60 = c.DNPL_31_60 - ((c.DNPL_31_60/c.DNPL) * k.korekcije_DNPL),
DNPL_61_90 = c.DNPL_61_90 - ((c.DNPL_61_90/c.DNPL) * k.korekcije_DNPL),
DNPL_91_120 = c.DNPL_91_120 - ((c.DNPL_91_120/c.DNPL) * k.korekcije_DNPL),
DNPL_121_180 = c.DNPL_121_180 - ((c.DNPL_121_180/c.DNPL) * k.korekcije_DNPL),
DNPL_181_365 = c.DNPL_181_365 - ((c.DNPL_181_365/c.DNPL) * k.korekcije_DNPL),
DNPL_366 = c.DNPL_366 - ((c.DNPL_366/c.DNPL) * k.korekcije_DNPL),
DNPL = c.DNPL - k.korekcije_DNPL--,
--OVDJE TREBA VIDJETI DA LI ĆE TREBATI KORIGIRATI I KOLONE do_1_godine, od_1_do_3_godine, od_3_do_5_godina i preko_5_godina
--do_1_godine = c.do_1_godine - (c.do_1_godine/(c.do_1_godine+c.od_1_do_3_godine+c.od_3_do_5_godina+c.preko_5_godina)*k.korekcije_DNPL),
--od_1_do_3_godine = c.od_1_do_3_godine - (c.do_1_godine/(c.do_1_godine+c.od_1_do_3_godine+c.od_3_do_5_godina+c.preko_5_godina)*k.korekcije_DNPL),
--od_3_do_5_godina = c.od_3_do_5_godina - (c.do_1_godine/(c.do_1_godine+c.od_1_do_3_godine+c.od_3_do_5_godina+c.preko_5_godina)*k.korekcije_DNPL),
--preko_5_godina = c.preko_5_godina - (c.do_1_godine/(c.do_1_godine+c.od_1_do_3_godine+c.od_3_do_5_godina+c.preko_5_godina)*k.korekcije_DNPL)
From #CONTRACTS c
INNER JOIN #KOREKCIJE k on c.ID_OC_REPORT = k.id_oc_report AND c.ID_CONT = k.id_cont
WHERE c.DNPL <> 0.00


UPDATE #CONTRACTS set BUD_POTR = c.BUD_POTR - k.korekcije_bud
From #CONTRACTS c
INNER JOIN #KOREKCIJE k on c.ID_OC_REPORT = k.id_oc_report AND c.ID_CONT = k.id_cont
WHERE c.BUD_POTR <> 0.00
/*KRAJ Ispravak pripremljenih podataka prema #KOREKCIJAMA za DNPL kupno i DNPL po bucketoma i ispravak nedospjelih potraživanja za FL*/

/*update prema MR 44801, bud_potr i bud_potr_ppmv na 0 */
UPDATE #CONTRACTS set
BUD_POTR = 0,
BUD_POTR_PPMV = 0
WHERE tip='O' and aneks in ('P','R','S','T','U')


/*OSNOVNA SREDSTVA KOJA NISU VEZANA NA UGOVOR*/
Select 'E' as tip, id_fa, inv_stev, ex_present_val
INTO #FA 
From dbo.fa 
Where id_oc_report = @id_oc_report1 
and status = 'A'
and id_cont is null



/*PREMA OBJEKTU LEASINGA*/
CREATE TABLE #OBJEKT(tip char(1),opis varchar(200), id_key varchar(100), sort int, 
					br_n_akt_pp int DEFAULT(0), br_n_akt_tp int DEFAULT(0), 
					ug_vr_n_pp decimal(18,2) DEFAULT(0), ug_vr_n_tp decimal(18,2) DEFAULT(0),
					ug_izn_fin_n_pp decimal(18,2) DEFAULT(0), ug_izn_fin_n_tp decimal(18,2) DEFAULT(0),
					br_akt_pp int DEFAULT(0), br_akt_tp int DEFAULT(0), 
					dnpl_pp decimal(18,2) DEFAULT(0), dnpl_tp decimal(18,2) DEFAULT(0),
					bud_potr_pp decimal(18,2) DEFAULT(0), bud_potr_tp decimal(18,2) DEFAULT(0),
					os_present_val_pp decimal(18,2) DEFAULT(0), os_present_val_tp decimal(18,2) DEFAULT(0),
					rezervacije_pp decimal(18,2) DEFAULT(0), rezervacije_tp decimal(18,2) DEFAULT(0)
					CONSTRAINT [PK_OBJEKT] PRIMARY KEY 
					(
						tip ASC, sort ASC, id_key ASC
					)
)

INSERT INTO #OBJEKT (tip,opis,id_key,sort)
Select a.tip, b.value, b.id_key, b.val_num
From dbo.general_register b, (Select a.tip
From #contracts a
Group by a.tip) a
Where b.id_register = 'HANFA_SP_OBJEKT'
and id_oc_report = @id_oc_report1
Order by a.tip,b.val_num

UPDATE #OBJEKT 
SET br_n_akt_pp = b.nz_pp, 
	br_n_akt_tp = b.nz_tp, 
	ug_vr_n_pp = b.nz_vr_pp, ug_vr_n_tp = b.nz_vr_tp,
	ug_izn_fin_n_pp = b.nz_fin_pp, ug_izn_fin_n_tp = b.nz_fin_tp,
	br_akt_pp = b.portfelj_broj_ug_pp, br_akt_tp = b.portfelj_broj_ug_tp, 
	dnpl_pp = b.portfelj_dnpl_pp, dnpl_tp = b.portfelj_dnpl_tp,
	bud_potr_pp = b.portfelj_bud_pp, bud_potr_tp = b.portfelj_bud_tp,
	os_present_val_pp = b.portfelj_vr_os_pp, os_present_val_tp = b.portfelj_vr_os_tp,
	rezervacije_pp = b.rezervacije_pp, rezervacije_tp = b.rezervacije_tp
FROM #OBJEKT a
INNER JOIN 
(
Select b.tip, a.value, a.id_key, cast(a.val_num as int) sort,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN 1 ELSE 0 END) as nz_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN 1 ELSE 0 END) as nz_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN b.vr_val_zac ELSE 0 END) as nz_vr_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN b.vr_val_zac ELSE 0 END) as nz_vr_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN b.net_nal_zac ELSE 0 END) as nz_fin_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN b.net_nal_zac ELSE 0 END) as nz_fin_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN  b.bud_potr ELSE 0 END) as portfelj_bud_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.bud_potr ELSE 0 END) as portfelj_bud_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val ELSE 0 END) as portfelj_vr_os_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val ELSE 0 END) as portfelj_vr_os_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN (b.rezervacije_dnpl + b.rezervacije_bud) ELSE 0 END) as rezervacije_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN (b.rezervacije_dnpl + b.rezervacije_bud) ELSE 0 END) as rezervacije_tp
From dbo.general_register a 
INNER join #contracts b on a.id_oc_report = b.id_oc_report and a.id_key = b.vrsta
Where a.id_oc_report in (@id_oc_report1, @id_oc_report2)
AND b.aneks <> 'S'
AND a.id_register = 'HANFA_SP_OBJEKT'
Group by b.tip, a.value, a.id_key, a.val_num ) b on a.tip = b.tip AND a.id_key = b.id_key

INSERT INTO #OBJEKT
Select tip,'Prema objektu leasinga', '', 0,
SUM(br_n_akt_pp), SUM(br_n_akt_tp), 
SUM(ug_vr_n_pp), SUM(ug_vr_n_tp),
SUM(ug_izn_fin_n_pp), SUM(ug_izn_fin_n_tp),
SUM(br_akt_pp), SUM(br_akt_tp), 
SUM(dnpl_pp), SUM(dnpl_tp),
SUM(bud_potr_pp), SUM(bud_potr_tp),
SUM(os_present_val_pp), SUM(os_present_val_tp),
SUM(rezervacije_pp), SUM(rezervacije_tp)
From #objekt
Group by tip

/*PREMA ROCNOSTI*/
CREATE TABLE #ROCNOST(tip char(1),opis varchar(200), id_key varchar(100), sort int, 
					br_n_akt_pp int DEFAULT(0), br_n_akt_tp int DEFAULT(0), 
					ug_vr_n_pp decimal(18,2) DEFAULT(0), ug_vr_n_tp decimal(18,2) DEFAULT(0),
					ug_izn_fin_n_pp decimal(18,2) DEFAULT(0), ug_izn_fin_n_tp decimal(18,2) DEFAULT(0),
					br_akt_pp int DEFAULT(0), br_akt_tp int DEFAULT(0), 
					dnpl_pp decimal(18,2) DEFAULT(0), dnpl_tp decimal(18,2) DEFAULT(0),
					bud_potr_pp decimal(18,2) DEFAULT(0), bud_potr_tp decimal(18,2) DEFAULT(0),
					os_present_val_pp decimal(18,2) DEFAULT(0), os_present_val_tp decimal(18,2) DEFAULT(0),
					rezervacije_pp decimal(18,2) DEFAULT(0), rezervacije_tp decimal(18,2) DEFAULT(0)
					CONSTRAINT [PK_ROCNOST] PRIMARY KEY 
					(
						tip ASC, sort ASC, id_key ASC
					)
)

INSERT INTO #ROCNOST (tip,opis,id_key,sort)
Select a.tip, b.value, b.id_key, b.val_num
From dbo.general_register b, (Select a.tip
From #contracts a
Group by a.tip) a
Where b.id_register = 'HANFA_SP_ROCNOST'
and id_oc_report = @id_oc_report1
Order by a.tip,b.val_num

UPDATE #ROCNOST 
SET br_n_akt_pp = b.nz_pp, 
	br_n_akt_tp = b.nz_tp, 
	ug_vr_n_pp = b.nz_vr_pp, ug_vr_n_tp = b.nz_vr_tp,
	ug_izn_fin_n_pp = b.nz_fin_pp, ug_izn_fin_n_tp = b.nz_fin_tp,
	br_akt_pp = b.portfelj_broj_ug_pp, br_akt_tp = b.portfelj_broj_ug_tp, 
	dnpl_pp = b.portfelj_dnpl_pp, dnpl_tp = b.portfelj_dnpl_tp,
	bud_potr_pp = b.portfelj_bud_pp, bud_potr_tp = b.portfelj_bud_tp,
	os_present_val_pp = b.portfelj_vr_os_pp, os_present_val_tp = b.portfelj_vr_os_tp,
	rezervacije_pp = b.rezervacije_pp, rezervacije_tp = b.rezervacije_tp
FROM #ROCNOST a
INNER JOIN 
(
Select b.tip, a.value,  a.id_key, cast(a.val_num as int) sort,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN 1 ELSE 0 END) as nz_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN 1 ELSE 0 END) as nz_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN b.vr_val_zac ELSE 0 END) as nz_vr_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN b.vr_val_zac ELSE 0 END) as nz_vr_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN b.net_nal_zac ELSE 0 END) as nz_fin_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN b.net_nal_zac ELSE 0 END) as nz_fin_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.bud_potr ELSE 0 END) as portfelj_bud_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN  b.bud_potr ELSE 0 END) as portfelj_bud_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val ELSE 0 END) as portfelj_vr_os_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val ELSE 0 END) as portfelj_vr_os_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN (b.rezervacije_dnpl + b.rezervacije_bud) ELSE 0 END) as rezervacije_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN (b.rezervacije_dnpl + b.rezervacije_bud) ELSE 0 END) as rezervacije_tp
From dbo.general_register a 
inner join #contracts b on a.id_oc_report = b.id_oc_report and a.id_key = b.rocnost
Where a.id_oc_report in (@id_oc_report1, @id_oc_report2)
AND b.aneks <> 'S'
AND a.id_register = 'HANFA_SP_ROCNOST'
Group by b.tip, a.value, a.id_key, a.val_num ) b on a.tip = b.tip AND a.id_key = b.id_key

INSERT INTO #ROCNOST
Select tip,'Prema izvornom dospijeću', '', 0,
SUM(br_n_akt_pp), SUM(br_n_akt_tp), 
SUM(ug_vr_n_pp), SUM(ug_vr_n_tp),
SUM(ug_izn_fin_n_pp), SUM(ug_izn_fin_n_tp),
SUM(br_akt_pp), SUM(br_akt_tp), 
SUM(dnpl_pp), SUM(dnpl_tp),
SUM(bud_potr_pp), SUM(bud_potr_tp),
SUM(os_present_val_pp), SUM(os_present_val_tp),
SUM(rezervacije_pp), SUM(rezervacije_tp)
From #ROCNOST
Group by tip

/*PREMA SEKTORU*/
CREATE TABLE #SEKTOR(tip char(1),opis varchar(200), id_key varchar(100), sort int, 
					br_n_akt_pp int DEFAULT(0), br_n_akt_tp int DEFAULT(0), 
					ug_vr_n_pp decimal(18,2) DEFAULT(0), ug_vr_n_tp decimal(18,2) DEFAULT(0),
					ug_izn_fin_n_pp decimal(18,2) DEFAULT(0), ug_izn_fin_n_tp decimal(18,2) DEFAULT(0),
					br_akt_pp int DEFAULT(0), br_akt_tp int DEFAULT(0), 
					dnpl_pp decimal(18,2) DEFAULT(0), dnpl_tp decimal(18,2) DEFAULT(0),
					bud_potr_pp decimal(18,2) DEFAULT(0), bud_potr_tp decimal(18,2) DEFAULT(0),
					os_present_val_pp decimal(18,2) DEFAULT(0), os_present_val_tp decimal(18,2) DEFAULT(0),
					rezervacije_pp decimal(18,2) DEFAULT(0), rezervacije_tp decimal(18,2) DEFAULT(0)
					CONSTRAINT [PK_SEKTOR] PRIMARY KEY 
					(
						tip ASC, sort ASC, id_key ASC
					)
)

INSERT INTO #SEKTOR (tip,opis,id_key,sort)
Select a.tip, b.value, b.id_key, b.val_num
From dbo.general_register b, (Select a.tip
From #contracts a
Group by a.tip) a
Where b.id_register = 'HANFA_SP_SEKTOR'
and id_oc_report = @id_oc_report1
Order by a.tip,b.val_num

UPDATE #SEKTOR 
SET br_n_akt_pp = b.nz_pp, 
	br_n_akt_tp = b.nz_tp, 
	ug_vr_n_pp = b.nz_vr_pp, ug_vr_n_tp = b.nz_vr_tp,
	ug_izn_fin_n_pp = b.nz_fin_pp, ug_izn_fin_n_tp = b.nz_fin_tp,
	br_akt_pp = b.portfelj_broj_ug_pp, br_akt_tp = b.portfelj_broj_ug_tp, 
	dnpl_pp = b.portfelj_dnpl_pp, dnpl_tp = b.portfelj_dnpl_tp,
	bud_potr_pp = b.portfelj_bud_pp, bud_potr_tp = b.portfelj_bud_tp,
	os_present_val_pp = b.portfelj_vr_os_pp, os_present_val_tp = b.portfelj_vr_os_tp,
	rezervacije_pp = b.rezervacije_pp, rezervacije_tp = b.rezervacije_tp
FROM #SEKTOR a
INNER JOIN 
(				
Select b.tip, a.value, a.id_key, cast(a.val_num as int) sort,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN 1 ELSE 0 END) as nz_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN 1 ELSE 0 END) as nz_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN b.vr_val_zac ELSE 0 END) as nz_vr_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN b.vr_val_zac ELSE 0 END) as nz_vr_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN b.net_nal_zac ELSE 0 END) as nz_fin_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN b.net_nal_zac ELSE 0 END) as nz_fin_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.vr_val_zac ELSE 0 END) as portfelj_vr_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.vr_val_zac ELSE 0 END) as portfelj_vr_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.net_nal_zac ELSE 0 END) as portfelj_fin_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.net_nal_zac ELSE 0 END) as portfelj_fin_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.bud_potr ELSE 0 END) as portfelj_bud_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN  b.bud_potr ELSE 0 END) as portfelj_bud_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val ELSE 0 END) as portfelj_vr_os_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val ELSE 0 END) as portfelj_vr_os_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN (b.rezervacije_dnpl + b.rezervacije_bud) ELSE 0 END) as rezervacije_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN (b.rezervacije_dnpl + b.rezervacije_bud) ELSE 0 END) as rezervacije_tp
From dbo.general_register a
inner join #contracts b on a.id_oc_report = b.id_oc_report and a.id_key = b.sektor
Where a.id_oc_report in (@id_oc_report1, @id_oc_report2)
AND b.aneks <> 'S'
AND a.id_register = 'HANFA_SP_SEKTOR'
Group by b.tip, a.value, a.id_key, a.val_num ) b on a.tip = b.tip AND a.id_key = b.id_key


INSERT INTO #SEKTOR
Select tip,'Prema sektorima', '', 0,
SUM(br_n_akt_pp), SUM(br_n_akt_tp),
SUM(ug_vr_n_pp), SUM(ug_vr_n_tp),
SUM(ug_izn_fin_n_pp), SUM(ug_izn_fin_n_tp),
SUM(br_akt_pp), SUM(br_akt_tp),
SUM(dnpl_pp), SUM(dnpl_tp),
SUM(bud_potr_pp), SUM(bud_potr_tp),
SUM(os_present_val_pp), SUM(os_present_val_tp),
SUM(rezervacije_pp), SUM(rezervacije_tp)
From #SEKTOR
Group by tip

/*PREMA DJELATNOSTI*/
CREATE TABLE #DJELATNOST(tip char(1),opis varchar(200), id_key varchar(100), sort int,
					br_n_akt_pp int DEFAULT(0), br_n_akt_tp int DEFAULT(0),
					ug_vr_n_pp decimal(18,2) DEFAULT(0), ug_vr_n_tp decimal(18,2) DEFAULT(0),
					ug_izn_fin_n_pp decimal(18,2) DEFAULT(0), ug_izn_fin_n_tp decimal(18,2) DEFAULT(0),
					br_akt_pp int DEFAULT(0), br_akt_tp int DEFAULT(0),
					dnpl_pp decimal(18,2) DEFAULT(0), dnpl_tp decimal(18,2) DEFAULT(0),
					bud_potr_pp decimal(18,2) DEFAULT(0), bud_potr_tp decimal(18,2) DEFAULT(0),
					os_present_val_pp decimal(18,2) DEFAULT(0), os_present_val_tp decimal(18,2) DEFAULT(0),
					rezervacije_pp decimal(18,2) DEFAULT(0), rezervacije_tp decimal(18,2) DEFAULT(0)
					CONSTRAINT [PK_DJELATNOST] PRIMARY KEY
					(
						tip ASC, sort ASC, id_key ASC
					)
)

INSERT INTO #DJELATNOST (tip,opis,id_key,sort)
Select a.tip, b.value, b.id_key, b.val_num
From dbo.general_register b, (Select a.tip
From #contracts a
Group by a.tip) a
Where b.id_register = 'HANFA_SP_DJELATNOST'
and id_oc_report = @id_oc_report1
Order by a.tip,b.val_num

UPDATE #DJELATNOST
SET br_n_akt_pp = b.nz_pp,
	br_n_akt_tp = b.nz_tp,
	ug_vr_n_pp = b.nz_vr_pp, ug_vr_n_tp = b.nz_vr_tp,
	ug_izn_fin_n_pp = b.nz_fin_pp, ug_izn_fin_n_tp = b.nz_fin_tp,
	br_akt_pp = b.portfelj_broj_ug_pp, br_akt_tp = b.portfelj_broj_ug_tp,
	dnpl_pp = b.portfelj_dnpl_pp, dnpl_tp = b.portfelj_dnpl_tp,
	bud_potr_pp = b.portfelj_bud_pp, bud_potr_tp = b.portfelj_bud_tp,
	os_present_val_pp = b.portfelj_vr_os_pp, os_present_val_tp = b.portfelj_vr_os_tp,
	rezervacije_pp = b.rezervacije_pp, rezervacije_tp = b.rezervacije_tp

FROM #DJELATNOST a
INNER JOIN
(
Select b.tip, a.value, a.id_key, cast(a.val_num as int) sort,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN 1 ELSE 0 END) as nz_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN 1 ELSE 0 END) as nz_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN b.vr_val_zac ELSE 0 END) as nz_vr_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN b.vr_val_zac ELSE 0 END) as nz_vr_pp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report1 THEN b.net_nal_zac ELSE 0 END) as nz_fin_tp,
SUM(CASE WHEN b.novo_aktivirani = 1 and b.id_oc_report = @id_oc_report2 THEN b.net_nal_zac ELSE 0 END) as nz_fin_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.vr_val_zac ELSE 0 END) as portfelj_vr_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.vr_val_zac ELSE 0 END) as portfelj_vr_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.net_nal_zac ELSE 0 END) as portfelj_fin_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.net_nal_zac ELSE 0 END) as portfelj_fin_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.bud_potr ELSE 0 END) as portfelj_bud_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN  b.bud_potr ELSE 0 END) as portfelj_bud_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val ELSE 0 END) as portfelj_vr_os_tp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val ELSE 0 END) as portfelj_vr_os_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report2 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN (b.rezervacije_dnpl + b.rezervacije_bud) ELSE 0 END) as rezervacije_pp,
SUM(CASE WHEN b.id_oc_report = @id_oc_report1 AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN (b.rezervacije_dnpl + b.rezervacije_bud) ELSE 0 END) as rezervacije_tp
From dbo.general_register a
inner join #contracts b on a.id_oc_report = b.id_oc_report and charindex(b.djelatnost_grupa,a.id_key)<>0
Where a.id_oc_report in (@id_oc_report1, @id_oc_report2)
AND b.aneks <> 'S'
AND a.id_register = 'HANFA_SP_DJELATNOST'
Group by b.tip, a.value, a.id_key, a.val_num ) b on a.tip = b.tip AND a.id_key = b.id_key

INSERT INTO #DJELATNOST
Select tip,'Po djelatnosti transaktora', '', 0,
SUM(br_n_akt_pp), SUM(br_n_akt_tp),
SUM(ug_vr_n_pp), SUM(ug_vr_n_tp),
SUM(ug_izn_fin_n_pp), SUM(ug_izn_fin_n_tp),
SUM(br_akt_pp), SUM(br_akt_tp),
SUM(dnpl_pp), SUM(dnpl_tp),
SUM(bud_potr_pp), SUM(bud_potr_tp),
SUM(os_present_val_pp), SUM(os_present_val_tp),
SUM(rezervacije_pp), SUM(rezervacije_tp)
From #DJELATNOST
Group by tip

--Isključen redak iz izvještaja
--INSERT INTO #DJELATNOST
--Select tip,'Ukupno pravne osobe i obrtnici', '', 11,
--SUM(br_n_akt_pp), SUM(br_n_akt_tp),
--SUM(ug_vr_n_pp), SUM(ug_vr_n_tp),
--SUM(ug_izn_fin_n_pp), SUM(ug_izn_fin_n_tp),
--SUM(br_akt_pp), SUM(br_akt_tp),
--SUM(dnpl_pp), SUM(dnpl_tp),
--SUM(bud_potr_pp), SUM(bud_potr_tp),
--SUM(os_present_val_pp), SUM(os_present_val_tp)
--From #DJELATNOST
--Where id_key <> 'T' and id_key <> ''
--Group by tip

/*SFI IZVJEŠTAJ*/
CREATE TABLE #SFI(tip char(1),opis varchar(200), id_key varchar(100), sort int,
					dnpl_30 decimal(18,2) DEFAULT(0), dnpl_31_60 decimal(18,2) DEFAULT(0),
					dnpl_61_90 decimal(18,2) DEFAULT(0), dnpl_91_120 decimal(18,2) DEFAULT(0), dnpl_121_180 decimal(18,2) DEFAULT(0),
					dnpl_181_365 decimal(18,2) DEFAULT(0), dnpl_366 decimal(18,2) DEFAULT(0),
					uk_dnpl decimal(18,2) DEFAULT(0), nedosp decimal(18,2) DEFAULT(0),
					uk_portfelj decimal(18,2) DEFAULT(0),
					uk_rezervacije decimal(18,2) DEFAULT(0)
					 CONSTRAINT [PK_SFI] PRIMARY KEY
					(
						tip ASC, sort ASC, id_key ASC
					)
)

INSERT INTO #SFI (tip,opis,id_key,sort)
Select a.tip, b.value, b.id_key, b.val_num
From dbo.general_register b, (Select a.tip
From #contracts a Where a.tip in ('O','F','Z')
Group by a.tip) a
Where b.id_register = 'HANFA_SP_SEKTOR'
and id_oc_report = @id_oc_report1
Order by a.tip,b.val_num

UPDATE #SFI
SET dnpl_30 = b.dnpl_30, dnpl_31_60 = b.dnpl_31_60,
	dnpl_61_90 = b.dnpl_61_90, dnpl_91_120 = b.dnpl_91_120, dnpl_121_180 = b.dnpl_121_180,
	dnpl_181_365 = b.dnpl_181_365, dnpl_366 = b.dnpl_366,
	uk_dnpl = b.uk_dnpl, nedosp = b.bud_potr,
	uk_portfelj = b.uk_portfelj,
	uk_rezervacije = b.uk_rezervacije

FROM #SFI a
INNER JOIN
(
Select b.tip, a.value, a.id_key, cast(a.val_num as int) sort,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_30 ELSE 0 END) as dnpl_30,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_31_60 ELSE 0 END) as dnpl_31_60,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_61_90 ELSE 0 END) as dnpl_61_90,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_91_120 ELSE 0 END) as dnpl_91_120,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_121_180 ELSE 0 END) as dnpl_121_180,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_181_365 ELSE 0 END) as dnpl_181_365,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_366 ELSE 0 END) as dnpl_366,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl ELSE 0 END) as uk_dnpl,
SUM(CASE WHEN (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) AND b.tip <> 'O' THEN b.bud_potr ELSE 0 END) as bud_potr,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl + CASE WHEN b.tip <> 'O' THEN b.bud_potr ELSE 0 END ELSE 0 END) as uk_portfelj,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.rezervacije_dnpl + b.rezervacije_bud ELSE 0 END) as uk_rezervacije
From dbo.general_register a
inner join #contracts b on a.id_oc_report = b.id_oc_report and a.id_key = b.sektor
Where a.id_oc_report = @id_oc_report1
AND a.id_register = 'HANFA_SP_SEKTOR'
Group by b.tip, a.value, a.id_key, a.val_num ) b on a.tip = b.tip AND a.id_key = b.id_key

INSERT INTO #SFI
Select tip,
CASE WHEN tip = 'F' THEN 'Financijski leasing'
	WHEN tip = 'O' THEN 'Operativni leasing'
	WHEN tip = 'Z' THEN 'Zajam' END
, '', 0,
SUM(dnpl_30), SUM(dnpl_31_60),
SUM(dnpl_61_90), SUM(dnpl_91_120), SUM(dnpl_121_180),
SUM(dnpl_181_365), SUM(dnpl_366),
SUM(uk_dnpl), SUM(nedosp),
SUM(uk_portfelj), SUM(uk_rezervacije)
From #SFI
Group by tip


--Dodavanje zapisa o Zakupima i najmovima u redak Ostala financijska imovina
INSERT INTO #SFI
Select 'Ž' as tip,
'Ostala financijska imovina'
, '', 0,
SUM(IsNull(dnpl_30,0)), SUM(IsNull(dnpl_31_60,0)),
SUM(IsNull(dnpl_61_90,0)), SUM(IsNull(dnpl_91_120,0)), SUM(IsNull(dnpl_121_180,0)),
SUM(IsNull(dnpl_181_365,0)), SUM(IsNull(dnpl_366,0)),
SUM(IsNull(uk_dnpl,0)), SUM(IsNull(bud_potr,0)),
SUM(IsNull(uk_portfelj,0)), SUM(IsNull(uk_rezervacije,0))
From
(
Select b.tip, a.value, a.id_key, 9 as sort,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_30 ELSE 0 END) as dnpl_30,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_31_60 ELSE 0 END) as dnpl_31_60,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_61_90 ELSE 0 END) as dnpl_61_90,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_91_120 ELSE 0 END) as dnpl_91_120,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_121_180 ELSE 0 END) as dnpl_121_180,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_181_365 ELSE 0 END) as dnpl_181_365,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_366 ELSE 0 END) as dnpl_366,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl ELSE 0 END) as uk_dnpl,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.bud_potr ELSE 0 END) as bud_potr,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl + b.bud_potr ELSE 0 END) as uk_portfelj,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.rezervacije_dnpl + b.rezervacije_bud ELSE 0 END) as uk_rezervacije
From dbo.general_register a
inner join #contracts b on a.id_oc_report = b.id_oc_report and a.id_key = b.sektor
Where a.id_oc_report = @id_oc_report1
AND a.id_register = 'HANFA_SP_SEKTOR'
and b.tip in ('U','N')
Group by b.tip, a.value, a.id_key, a.val_num) a


--Prema zahtjevu HLS ako se PPMV izbija iz DNPL tada se treba staviti u 22 Ostala financijka imovina
/*
IF @dnpl_PPMV = 0  
BEGIN 
UPDATE #SFI
SET dnpl_30 = Isnull(a.dnpl_30,0) + b.dnpl_30, 
	dnpl_31_60 = Isnull(a.dnpl_31_60,0) + b.dnpl_31_60,
	dnpl_61_90 = Isnull(a.dnpl_61_90,0) + b.dnpl_61_90, 
	dnpl_91_120 = Isnull(a.dnpl_91_120,0) + b.dnpl_91_120, 
	dnpl_121_180 = Isnull(a.dnpl_121_180,0) + b.dnpl_121_180,
	dnpl_181_365 = Isnull(a.dnpl_181_365,0) + b.dnpl_181_365, 
	dnpl_366 = Isnull(a.dnpl_366,0) + b.dnpl_366,
	uk_dnpl = Isnull(a.uk_dnpl,0) + b.uk_dnpl, 
	nedosp = Isnull(a.nedosp,0) + b.bud_potr,
	uk_portfelj = Isnull(a.uk_portfelj,0) + b.uk_portfelj,
	uk_rezervacije = IsNull(a.uk_rezervacije,0) 
FROM #SFI a
INNER JOIN
(
Select 'Ž' as tip, 
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_30_PPMV ELSE 0 END) as dnpl_30,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_31_60_PPMV ELSE 0 END) as dnpl_31_60,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_61_90_PPMV ELSE 0 END) as dnpl_61_90,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_91_120_PPMV ELSE 0 END) as dnpl_91_120,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_121_180_PPMV ELSE 0 END) as dnpl_121_180,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_181_365_PPMV ELSE 0 END) as dnpl_181_365,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_366_PPMV ELSE 0 END) as dnpl_366,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_PPMV ELSE 0 END) as uk_dnpl,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.bud_potr_PPMV ELSE 0 END) as bud_potr,
SUM(CASE WHEN b.status_akt = 'A' OR (b.dat_zakl > b.date_to) THEN b.dnpl_PPMV + b.bud_potr_PPMV ELSE 0 END) as uk_portfelj
From #contracts b 
Where b.id_oc_report = @id_oc_report1
AND b.tip in ('F','O')
Group by b.id_oc_report) b on a.tip = b.tip
END
*/

/*RSIO IZVJEŠTAJ*/
CREATE TABLE #RSIO(tip char(1),opis varchar(200), id_key varchar(100), sort int,
					do_3_m decimal(18,2) DEFAULT(0), do_1 decimal(18,2) DEFAULT(0),
					od_1_do_3 decimal(18,2) DEFAULT(0), od_3_do_5 decimal(18,2) DEFAULT(0),
					preko_5 decimal(18,2) DEFAULT(0), nedefinirano decimal(18,2) DEFAULT(0),
					ukupno decimal(18,2) DEFAULT(0)
					 CONSTRAINT [PK_RSIO] PRIMARY KEY
					(
						tip ASC, sort ASC, id_key ASC
					)
)

INSERT INTO #RSIO (tip,opis,id_key,sort)
Select LEFT(b.id_key,1), b.value, b.id_key, b.val_num
From dbo.general_register b
Where b.id_register = 'HANFA_SP_RSIO'
and id_oc_report = @id_oc_report1
Order by b.id_key,b.val_num


UPDATE #RSIO 
SET do_3_m = c.do_3_mjeseca, do_1  = c.do_1,
od_1_do_3 = c.od_1_do_3, od_3_do_5 = c.od_3_do_5,
preko_5  = c.preko_5, ukupno = c.do_3_mjeseca + c.do_1 + c.od_1_do_3 + c.od_3_do_5 + c.preko_5
FROM #RSIO d
INNER JOIN (
			Select b.tip,
			SUM(b.do_3_mjeseca - (b.do_3_mjeseca/b.Ukupno)*(b.korekcije_dnpl+b.korekcije_bud+b.rezervacije_dnpl+b.rezervacije_bud)) as do_3_mjeseca,
			SUM(b.do_1 - (b.do_1/b.Ukupno)*(b.korekcije_dnpl+b.korekcije_bud+b.rezervacije_dnpl+b.rezervacije_bud)) as do_1,
			SUM(b.od_1_do_3 - (b.od_1_do_3/b.Ukupno)*(b.korekcije_dnpl+b.korekcije_bud+b.rezervacije_dnpl+b.rezervacije_bud)) as od_1_do_3,
			SUM(b.od_3_do_5 - (b.od_3_do_5/b.Ukupno)*(b.korekcije_dnpl+b.korekcije_bud+b.rezervacije_dnpl+b.rezervacije_bud)) as od_3_do_5,
			SUM(b.preko_5 - (b.preko_5/b.Ukupno)*(b.korekcije_dnpl+b.korekcije_bud+b.rezervacije_dnpl+b.rezervacije_bud)) as preko_5,
			SUM(b.nedefinirano) as nedefinirano
			From				
				(Select a.tip, a.id_cont, a.id_oc_report, a.status_akt, 
					a.dnpl + a.neto_not_booked + a.neto_not_dued + ((a.robresti_not_booked + a.robresti_not_dued) * @future_PPMV) as do_3_mjeseca,
					a.do_1_godine as do_1,
					a.od_1_do_3_godine as od_1_do_3, 
					a.od_3_do_5_godina as od_3_do_5, 
					a.preko_5_godina as preko_5, 
					0 as nedefinirano,
					a.dnpl + a.neto_not_booked + a.neto_not_dued + ((a.robresti_not_booked + a.robresti_not_dued) * @future_PPMV) + a.do_1_godine + a.od_1_do_3_godine + a.od_3_do_5_godina + a.preko_5_godina as Ukupno,
					Isnull(k.korekcije_dnpl,0) as korekcije_dnpl,
					Isnull(k.korekcije_bud,0) as korekcije_bud,
					Isnull(r.rezervacije_dnpl,0) as rezervacije_dnpl,
					Isnull(r.rezervacije_bud,0) as rezervacije_bud
				From #contracts a
				Left Join #korekcije k on a.id_cont = k.id_cont and a.id_oc_report = k.id_oc_report
				Left Join #rezervacije r on a.id_cont = r.id_cont and a.id_oc_report = r.id_oc_report
				Where a.id_oc_report = @id_oc_report1 And a.tip  in ('F','Z') And (a.status_akt = 'A' OR (a.dat_zakl > date_to))) b
		Where b.ukupno <> 0
		Group by b.tip
) c on d.id_key = c.tip 
WHERE d.id_key in ('F','Z')


UPDATE #RSIO 
SET do_3_m = b.do_3_mjeseca, ukupno = b.do_3_mjeseca
From #RSIO a
INNER JOIN ( Select a.tip+'1' as tip,
			SUM(a.dnpl - (Isnull(k.korekcije_dnpl,0)+ Isnull(k.korekcije_bud,0)+ Isnull(r.rezervacije_dnpl,0)+ Isnull(r.rezervacije_bud,0))) as do_3_mjeseca
		From #contracts a
		Left Join #korekcije k on a.id_cont = k.id_cont and a.id_oc_report = k.id_oc_report
		Left Join #rezervacije r on a.id_cont = r.id_cont and a.id_oc_report = r.id_oc_report
		Where a.id_oc_report = @id_oc_report1
			And a.tip = 'O'
			And (a.status_akt = 'A' OR (a.dat_zakl > date_to))
		Group by a.tip
) b on a.id_key = b.tip 
Where a.id_key = 'O1'


UPDATE #RSIO 
SET do_3_m = b.do_3_mjeseca, do_1  = b.do_1,
od_1_do_3 = b.od_1_do_3, od_3_do_5 = b.od_3_do_5,
preko_5  = b.preko_5, 
ukupno = b.do_3_mjeseca + b.do_1 + b.od_1_do_3 + b.od_3_do_5 + b.preko_5
From #RSIO a
INNER JOIN ( Select a.tip+'2' as tip,
			SUM(CASE WHEN a.kraj <= 3 then a.ex_present_val_RLC else 0 end) as do_3_mjeseca, 
			SUM(CASE WHEN a.kraj between 4 and 12 then a.ex_present_val_RLC else 0 end) as do_1,
			SUM(CASE WHEN a.kraj between 13 and 36 then a.ex_present_val_RLC else 0 end) as od_1_do_3, 
			SUM(CASE WHEN a.kraj between 37 and 60 then a.ex_present_val_RLC else 0 end) as od_3_do_5, 
			SUM(CASE WHEN a.kraj > 60 then a.ex_present_val_RLC else 0 end) as preko_5, 
			SUM(a.ex_present_val_RLC) as Ukupno
		From #contracts a
		Where a.id_oc_report = @id_oc_report1
			And a.tip = 'O'
			And (a.status_akt = 'A' OR (a.dat_zakl > date_to))
		Group by a.tip
) b on a.id_key = b.tip 
Where a.id_key = 'O2'



UPDATE #RSIO
SET nedefinirano = b.ex_present_val, ukupno = b.ex_present_val
From #RSIO a
inner join (Select a.tip, Sum(a.ex_present_val) as ex_present_val
			From #FA a
			Group by a.tip
) b on a.id_key = b.tip
Where a.id_key = 'E'


--Dodano prema zahtjevu HLS - PPMV ako ne ide u buduća potraživanja i dospjela neplaćena tada treba ići u ostalo
UPDATE #RSIO 
SET do_3_m = b.do_3_mjeseca, do_1  = b.do_1,
od_1_do_3 = b.od_1_do_3, od_3_do_5 = b.od_3_do_5,
preko_5  = b.preko_5, ukupno = ukupno + b.do_3_mjeseca + b.do_1 + b.od_1_do_3 + b.od_3_do_5 + b.preko_5
FROM #RSIO a
INNER JOIN (Select 'E' as tip, 
			SUM(CASE WHEN @dnpl_PPMV = 0 THEN a.dnpl_PPMV ELSE 0 END + CASE WHEN @future_PPMV = 0 THEN a.robresti_not_booked + a.robresti_not_dued ELSE 0 END) as do_3_mjeseca, sum(a.do_1_godine_PPMV) as do_1,
			sum(a.od_1_do_3_godine_PPMV) as od_1_do_3, sum(a.od_3_do_5_godina_PPMV) as od_3_do_5, sum(a.preko_5_godina_PPMV) as preko_5, 0 as nedefinirano
			--,sum(a.dnpl_PPMV + CASE WHEN @DNPL_PPMV = 0 THEN a.dnpl_PPMV ELSE 0 END + CASE WHEN @future_PPMV = 0 THEN a.robresti_not_booked + a.robresti_not_dued ELSE 0 END + a.do_1_godine_PPMV + a.od_1_do_3_godine_PPMV + a.od_3_do_5_godina_PPMV + a.preko_5_godina_PPMV) as Ukupno
		From #contracts a
		Where a.id_oc_report = @id_oc_report1 And a.tip  in ('F','Z','O') And (a.status_akt = 'A' OR (a.dat_zakl > date_to))
		--Group by a.tip
) b on a.id_key = b.tip 
WHERE a.id_key = 'E'


UPDATE #RSIO 
SET do_3_m = b.do_3_mjeseca, do_1  = b.do_1,
od_1_do_3 = b.od_1_do_3, od_3_do_5 = b.od_3_do_5,
preko_5  = b.preko_5, 
ukupno = b.do_3_mjeseca + b.do_1 + b.od_1_do_3 + b.od_3_do_5 + b.preko_5
From #RSIO a
INNER JOIN (Select 'O3' as tip,
			SUM(CASE WHEN a.kraj <= 3 then a.se_varsc else 0 end) as do_3_mjeseca, 
			SUM(CASE WHEN a.kraj between 4 and 12 then a.se_varsc else 0 end) as do_1,
			SUM(CASE WHEN a.kraj between 13 and 36 then a.se_varsc else 0 end) as od_1_do_3, 
			SUM(CASE WHEN a.kraj between 37 and 60 then a.se_varsc else 0 end) as od_3_do_5, 
			SUM(CASE WHEN a.kraj > 60 then a.se_varsc else 0 end) as preko_5, 
			SUM(a.se_varsc) as Ukupno
		From #contracts a
		Where a.id_oc_report = @id_oc_report1
			And a.tip in ('O','U','N')
			and (a.status_akt = 'A' OR (a.dat_zakl > date_to))
		Group by a.id_oc_report
) b on a.id_key = b.tip 
Where a.id_key = 'O3'


/*NKV-OL  IZVJEŠTAJ*/
CREATE TABLE #NKVOL(tip char(1),opis varchar(200), id_key varchar(100), sort int,
					iznos decimal(18,2) DEFAULT(0)
					 CONSTRAINT [PK_NKVOL] PRIMARY KEY
					(
						tip ASC, sort ASC, id_key ASC
					)
)


--INSERT INTO #NKVOL(tip,opis,id_key,sort)
--Select 'O', b.value, b.id_key, b.val_num
--From dbo.general_register b
--Where b.id_register = 'HANFA_SP_NKVOL'
--and id_oc_report = @id_oc_report1
--Order by b.id_key,b.val_num

--UPDATE #NKVOL
--SET iznos = b.iznos
--From #NKVOL a
--INNER JOIN (Select c.id_key, c.iznos 
--			From ( 
--					Select '1' as id_key, sum(do_1_godine + neto_not_booked + obresti_not_booked + regist_not_booked + robresti_not_booked) as iznos From #contracts Where tip = 'O' and id_oc_report = @id_oc_report1 and (status_akt = 'A' OR (dat_zakl > date_to))
--					UNION ALL
--					Select '2' as id_key, sum(od_1_do_3_godine + od_3_do_5_godina) as iznos From #contracts Where tip = 'O' and id_oc_report = @id_oc_report1 and (status_akt = 'A' OR (dat_zakl > date_to))
--					UNION ALL			
--					Select '3' as id_key, sum(preko_5_godina) as iznos From #contracts Where tip = 'O' and id_oc_report = @id_oc_report1 and (status_akt = 'A' OR (dat_zakl > date_to))
--					UNION ALL			
--					Select '4' as id_key, sum(do_1_godine + neto_not_booked + obresti_not_booked + regist_not_booked + robresti_not_booked + od_1_do_3_godine + od_3_do_5_godina + preko_5_godina) as iznos From #contracts Where tip = 'O' and id_oc_report = @id_oc_report1 and (status_akt = 'A' OR (dat_zakl > date_to))
--				) c
--) b on RTRIM(a.id_key) = b.id_key



/*KP IZVJEŠTAJ*/
CREATE TABLE #KP(tip char(1),opis varchar(200), id_key varchar(100), sort int,
					dnpl_90 decimal(18,2) DEFAULT(0), rezervacije_90 decimal(18,2) DEFAULT(0),
					dnpl_91_180 decimal(18,2) DEFAULT(0), rezervacije_91_180 decimal(18,2) DEFAULT(0),
					dnpl_181_270 decimal(18,2) DEFAULT(0), rezervacije_181_270 decimal(18,2) DEFAULT(0),
					dnpl_271_365 decimal(18,2) DEFAULT(0), rezervacije_271_365 decimal(18,2) DEFAULT(0),
					dnpl_366 decimal(18,2) DEFAULT(0), rezervacije_366 decimal(18,2) DEFAULT(0),
					uk_dnpl decimal(18,2) DEFAULT(0), uk_rezervacije decimal(18,2) DEFAULT(0),
					dnpl_restru decimal(18,2) DEFAULT(0), rezervacije_restru decimal(18,2) DEFAULT(0)
					CONSTRAINT [PK_KP] PRIMARY KEY
					(
						tip ASC, sort ASC, id_key ASC
					)
)

INSERT INTO #KP (tip,opis,id_key,sort)
Select a.tip, b.value, b.id_key, b.val_num
From dbo.general_register b, (Select a.tip
From #contracts a Where a.tip in ('O','F','Z')
Group by a.tip) a
Where b.id_register = 'HANFA_SP_OBJEKT'
and id_oc_report = @id_oc_report1
Order by a.tip,b.val_num


UPDATE #KP
SET dnpl_90 = b.dnpl_90, rezervacije_90 = b.rezervacije_90,
	dnpl_91_180 = b.dnpl_91_180, rezervacije_91_180 = b.rezervacije_91_180, 
	dnpl_181_270 = b.dnpl_181_270, rezervacije_181_270 = b.rezervacije_181_270,
	dnpl_271_365 = b.dnpl_271_365, rezervacije_271_365 = b.rezervacije_271_365,
	dnpl_366 = b.dnpl_366, rezervacije_366 = b.rezervacije_366,
	uk_dnpl = b.uk_dnpl, uk_rezervacije = b.uk_rezervacije,
	dnpl_restru = b.dnpl_restru, rezervacije_restru = b.rezervacije_restru
FROM #KP a
INNER JOIN
(
Select b.tip, a.value, a.id_key, cast(a.val_num as int) sort,
SUM(CASE WHEN b.odr_max_days <= 90 THEN b.dnpl + b.BUD_POTR ELSE 0 END) as dnpl_90,
SUM(CASE WHEN b.odr_max_days <= 90 THEN b.rezervacije_dnpl + b.rezervacije_bud ELSE 0 END) as rezervacije_90,
SUM(CASE WHEN b.odr_max_days between 91 and 180 THEN b.dnpl + b.BUD_POTR ELSE 0 END) as dnpl_91_180,
SUM(CASE WHEN b.odr_max_days between 91 and 180 THEN b.rezervacije_dnpl + b.rezervacije_bud ELSE 0 END) as rezervacije_91_180,
SUM(CASE WHEN b.odr_max_days between 181 and 270 THEN b.dnpl + b.BUD_POTR ELSE 0 END) as dnpl_181_270,
SUM(CASE WHEN b.odr_max_days between 181 and 270 THEN b.rezervacije_dnpl + b.rezervacije_bud ELSE 0 END) as rezervacije_181_270,
SUM(CASE WHEN b.odr_max_days between 271 and 365 THEN b.dnpl + b.BUD_POTR ELSE 0 END) as dnpl_271_365,
SUM(CASE WHEN b.odr_max_days between 271 and 365 THEN b.rezervacije_dnpl + b.rezervacije_bud ELSE 0 END) as rezervacije_271_365,
SUM(CASE WHEN b.odr_max_days >= 366 THEN b.dnpl + b.BUD_POTR ELSE 0 END) as dnpl_366,
SUM(CASE WHEN b.odr_max_days >= 366 THEN b.rezervacije_dnpl + b.rezervacije_bud ELSE 0 END) as rezervacije_366,
SUM(b.dnpl + b.BUD_POTR) as uk_dnpl,
SUM(b.rezervacije_dnpl + b.rezervacije_bud) as uk_rezervacije,
0 as dnpl_restru, 0 as rezervacije_restru
From dbo.general_register a
inner join #contracts b on a.id_oc_report = b.id_oc_report and a.id_key = b.vrsta
Where a.id_oc_report = @id_oc_report1
AND a.id_register = 'HANFA_SP_OBJEKT'
AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to))
Group by b.tip, a.value, a.id_key, a.val_num ) b on a.tip = b.tip AND a.id_key = b.id_key

INSERT INTO #KP
Select tip,
CASE WHEN tip = 'F' THEN 'Financijski leasing'
	WHEN tip = 'O' THEN 'Operativni leasing'
	WHEN tip = 'Z' THEN 'Zajam' END
, '', 0,
SUM(dnpl_90), SUM(rezervacije_90),
SUM(dnpl_91_180), SUM(rezervacije_91_180), 
SUM(dnpl_181_270), SUM(rezervacije_181_270),
SUM(dnpl_271_365), SUM(rezervacije_271_365),
SUM(dnpl_366), SUM(rezervacije_366),
SUM(uk_dnpl), SUM(uk_rezervacije),
SUM(dnpl_restru), SUM(rezervacije_restru)
From #KP
Group by tip


/*Izvještaj Z-N*/
CREATE TABLE #ZN(opis varchar(200), id_key varchar(100), sort int, 
					br_akt_ZA int DEFAULT(0), vrijed_imo_ZA decimal(18,2) DEFAULT(0), dnpl_ZA decimal(18,2) DEFAULT(0),
					br_akt_NA int DEFAULT(0), vrijed_imo_NA decimal(18,2) DEFAULT(0), dnpl_NA decimal(18,2) DEFAULT(0),
					br_akt_uk int DEFAULT(0), vrijed_imo_uk decimal(18,2) DEFAULT(0), dnpl_uk decimal(18,2) DEFAULT(0),
					CONSTRAINT [PK_ZN] PRIMARY KEY 
					(
						sort ASC, id_key ASC
					)
)

INSERT INTO #ZN (opis,id_key,sort)
Select b.value, b.id_key, b.val_num
From dbo.general_register b
Where b.id_register = 'HANFA_SP_OBJEKT'
and id_oc_report = @id_oc_report1
Order by b.val_num

UPDATE #ZN
SET br_akt_ZA = b.portfelj_broj_ug_ZA, 
	vrijed_imo_ZA = b.portfelj_vr_os_ZA, 
	dnpl_ZA	= b.portfelj_dnpl_ZA,
	br_akt_NA = b.portfelj_broj_ug_NA,
	vrijed_imo_NA = b.portfelj_vr_os_NA,
	dnpl_NA = b.portfelj_dnpl_NA,
	br_akt_uk = (b.portfelj_broj_ug_ZA + b.portfelj_broj_ug_NA),
	vrijed_imo_uk = (b.portfelj_vr_os_ZA + b.portfelj_vr_os_NA),
	dnpl_uk = (b.portfelj_dnpl_ZA + b.portfelj_dnpl_NA)
FROM #ZN a
INNER JOIN 
(Select a.value, a.id_key, cast(a.val_num as int) sort,
SUM(CASE WHEN b.tip = 'U' AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_ZA,
SUM(CASE WHEN b.tip = 'U' AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val_RLC ELSE 0 END) as portfelj_vr_os_ZA,
SUM(CASE WHEN b.tip = 'U' AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_ZA,
SUM(CASE WHEN b.tip = 'N' AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN 1 ELSE 0 END) as portfelj_broj_ug_NA,
SUM(CASE WHEN b.tip = 'N' AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.ex_present_val_RLC ELSE 0 END) as portfelj_vr_os_NA,
SUM(CASE WHEN b.tip = 'N' AND (b.status_akt = 'A' OR (b.dat_zakl > b.date_to)) THEN b.dnpl ELSE 0 END) as portfelj_dnpl_NA
From dbo.general_register a 
INNER join #contracts b on a.id_oc_report = b.id_oc_report and a.id_key = b.vrsta
Where a.id_oc_report = @id_oc_report1
AND a.id_register = 'HANFA_SP_OBJEKT'
AND b.tip in ('U','Z')
Group by a.value, a.id_key, a.val_num) b on a.id_key = b.id_key


/*REZULTAT DETALJNO*/
SELECT a.*, isnull(k.korekcije_dnpl, 0) as korekcije_dnpl, isnull(k.korekcije_bud, 0) as korekcije_bud
FROM #contracts a 
LEFT JOIN #KOREKCIJE k on a.id_oc_report = k.id_oc_report and a.id_cont = k.id_cont
ORDER BY a.id_cont ASC, a.id_oc_report DESC 

/*REZULTAT1 SP-FL*/
Select tip, opis, sort, br_n_akt_pp, br_n_akt_tp, ug_izn_fin_n_pp, ug_izn_fin_n_tp, br_akt_pp, br_akt_tp, dnpl_pp, dnpl_tp, bud_potr_pp, bud_potr_tp, rezervacije_pp, rezervacije_tp
From ( 
Select * from #objekt Where tip = 'F' --Order by tip, sort
UNION ALL
Select * from #rocnost Where tip = 'F' --Order by tip, sort
UNION ALL
Select * from #sektor Where tip = 'F' --Order by tip, sort
UNION ALL
select * from #djelatnost Where tip = 'F' --Order by tip, sort
) a

/*REZULTAT2 SP-OL*/

Select tip, opis, sort, br_n_akt_pp, br_n_akt_tp, ug_vr_n_pp, ug_vr_n_tp, br_akt_pp, br_akt_tp, dnpl_pp, dnpl_tp, rezervacije_pp, rezervacije_tp, bud_potr_pp, bud_potr_tp--, os_present_val_pp, os_present_val_tp, 
From (
Select * from #objekt Where tip = 'O' --Order by tip, sort
UNION ALL
Select * from #rocnost Where tip = 'O' --Order by tip, sort
UNION ALL
Select * from #sektor Where tip = 'O' --Order by tip, sort
UNION ALL
select * from #djelatnost Where tip = 'O' --Order by tip, sort
) a


/*REZULTAT3 SP-ZAJ*/

Select tip, opis, sort, br_akt_pp, br_akt_tp, dnpl_pp, dnpl_tp, bud_potr_pp, bud_potr_tp, rezervacije_pp, rezervacije_tp 
From ( 
Select * from #objekt Where tip = 'Z' --Order by tip, sort
UNION ALL
--Select * from #rocnost Where tip = 'Z' --Order by tip, sort  --skomentiran dio jer je obrisana podjela po ročnosti 
--UNION ALL
Select * from #sektor Where tip = 'Z' --Order by tip, sort
UNION ALL
select * from #djelatnost Where tip = 'Z' --Order by tip, sort
) a


/*REZULTAT4 SFI*/
Select * from #SFI order by tip, sort 

/*REZULTAT5 RS-IO*/
Select * From #rsio order by sort

/*REZULTAT6 NKV-OL*/
Select * From #NKVOL Order by sort

/*REZULTAT7 KP*/
Select * from #KP

/*REZULTAT8 Z-N*/
Select * from #ZN

/*REZULTAT9 oc_reports*/
Select * from dbo.oc_reports where id_oc_report = @id_oc_report1


DROP TABLE #oc_claims
DROP TABLE #FUTURE_DETAILS
DROP TABLE #REZERVACIJE
DROP TABLE #CONTRACTS
DROP TABLE #NACINI_L	
DROP TABLE #FA
DROP TABLE #OBJEKT
DROP TABLE #ROCNOST
DROP TABLE #SEKTOR
DROP TABLE #DJELATNOST
DROP TABLE #SFI
DROP TABLE #RSIO
DROP TABLE #NKVOL
DROP TABLE #KP
DROP TABLE #ZN
DROP TABLE #PARTNER_SEKTOR
DROP TABLE #KOREKCIJE
DROP TABLE #OCF