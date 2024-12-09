Za podatak 'Datum isteka' se u ovisnosti o tipu leasinga uzimao različit podatak: do sada se za OL tipove (i za OF) uzimao datum zadnje rate (iz plana otplate), a za sve ostale tipove (FL) se uzima podatak 'Datum dosp. otkupa' s pregleda obavijesti o otkupu.
Sada smo podesili da se za hibrid prikazuje kao za FL tip leasinga. To isto se onda odnosi i na kriterij pretrage 'Datum isteka veći od'.


popraviti i format datuma 
--NOVO
-- 13.11.2017 g_tomislav MR 39200 - dorada
DECLARE @par_date_enabled int
DECLARE @par_date datetime
DECLARE	@par_id_tip int
DECLARE @par_nacin_leas char(100)

SET @par_date_enabled = {0}
SET @par_date = {1}
SET @par_id_tip = {2}
SET @par_nacin_leas = {3}

SELECT o.*, 
  p.id_pog, p.pred_naj, p.nacin_leas, 
  k.naz_kr_kup, k.naziv1_kup, k.ulica, k.mesto, k.naziv2_kup, k.polni_naz, 
  k.ulica_sed, k.id_poste_sed, k.mesto_sed, k.emso, k.vr_osebe,
  r.st_sas, r.reg_stev, 
  d.id_obl_zav, d.opis, d.id_zav, d.status_akt, d.stevilka, d.velja_do, d.id_dokum,
  z.naziv,
  --CASE WHEN dbo.gfn_Nacin_leas_HR(p.nacin_leas) = 'OL' THEN a.datum_dok ELSE o.dat_zap END AS dat_zap_new_old, 
  CASE WHEN c.tip_knjizenja = 1 THEN a.datum_dok ELSE o.dat_zap END AS dat_zap_new
FROM dbo.odgnaopc o 
INNER JOIN dbo.pogodba p on o.id_cont=p.id_cont 
INNER JOIN dbo.partner k on p.id_kupca=k.id_kupca
Left outer join dbo.gv_Zapisniki r on o.id_cont=r.id_cont
Left outer join (Select id_zapo, id_obl_zav, opis, id_zav, status_akt, stevilka, velja_do, id_dokum
					From dbo.dokument Where /*status_akt!='N' and*/ id_zav is not null) d on r.id_zapo=d.id_zapo
Left outer join dbo.zavarova z on d.id_zav=z.id_zav
INNER JOIN (Select a.id_cont, MAX(a.datum_dok) as datum_dok
			From dbo.planp a
			INNER JOIN dbo.vrst_ter b on a.id_terj = b.id_terj and b.sif_terj = 'LOBR'
			Group by a.id_cont) a on o.id_cont = a.id_cont 
INNER JOIN dbo.nacini_l c ON p.nacin_leas = c.nacin_leas
--Where 1 = (CASE WHEN @par_date_enabled = 1 THEN (CASE WHEN CASE WHEN dbo.gfn_Nacin_leas_HR(p.nacin_leas) = 'OL' THEN a.datum_dok ELSE o.dat_zap END >= @par_date THEN 1 ELSE 0 END) ELSE 1 END)
WHERE 1 = (CASE WHEN @par_date_enabled = 1 THEN (CASE WHEN CASE WHEN c.tip_knjizenja = 1 THEN a.datum_dok ELSE o.dat_zap END >= @par_date THEN 1 ELSE 0 END) ELSE 1 END)
  and p.status_akt!='Z' and (@par_id_tip = 0 OR charindex(p.nacin_leas,@par_nacin_leas)!=0)
Order By p.id_pog




--STARO 
DECLARE @par_date_enabled int
DECLARE @par_date datetime
DECLARE	@par_id_tip int
DECLARE @par_nacin_leas char(100)

SET @par_date_enabled = {0}
SET @par_date = {1}
SET @par_id_tip = {2}
SET @par_nacin_leas = {3}

Select o.*, 
  p.id_pog, p.pred_naj, p.nacin_leas, 
  k.naz_kr_kup, k.naziv1_kup, k.ulica, k.mesto, k.naziv2_kup, k.polni_naz, 
  k.ulica_sed, k.id_poste_sed, k.mesto_sed, k.emso, k.vr_osebe,
  r.st_sas, r.reg_stev, 
  d.id_obl_zav, d.opis, d.id_zav, d.status_akt, d.stevilka, d.velja_do, d.id_dokum,
  z.naziv,
  CASE WHEN dbo.gfn_Nacin_leas_HR(p.nacin_leas) = 'OL' THEN a.datum_dok ELSE o.dat_zap END AS dat_zap_new
From dbo.odgnaopc o inner join dbo.pogodba p on o.id_cont=p.id_cont 
Inner join dbo.partner k on p.id_kupca=k.id_kupca
Left outer join dbo.gv_Zapisniki r on o.id_cont=r.id_cont
Left outer join (Select id_zapo, id_obl_zav, opis, id_zav, status_akt, stevilka, velja_do, id_dokum
					From dbo.dokument Where /*status_akt!='N' and*/ id_zav is not null) d on r.id_zapo=d.id_zapo
Left outer join dbo.zavarova z on d.id_zav=z.id_zav
Inner join (Select a.id_cont, MAX(a.datum_dok) as datum_dok
			From dbo.planp a
			Inner join dbo.vrst_ter b on a.id_terj = b.id_terj and b.sif_terj = 'LOBR'
			Group by a.id_cont) a on o.id_cont = a.id_cont 
INNER JOIN dbo.nacini_l c ON 
Where 1 = (CASE WHEN @par_date_enabled = 1 THEN (CASE WHEN CASE WHEN dbo.gfn_Nacin_leas_HR(p.nacin_leas) = 'OL' THEN a.datum_dok ELSE o.dat_zap END >= @par_date THEN 1 ELSE 0 END) ELSE 1 END)
  and p.status_akt!='Z' and (@par_id_tip = 0 OR charindex(p.nacin_leas,@par_nacin_leas)!=0)
Order By p.id_pog



