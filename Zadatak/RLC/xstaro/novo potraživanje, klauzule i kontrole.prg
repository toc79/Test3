BEGIN TRAN
INSERT INTO dbo.VRST_TER(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim) VALUES('2D','NAKNADA ŠTETE ZBOG PRIJ. PRESTANKA UG. FL',9,'#KRATTER','#PRIH2DN','','NE',0,'00',0,'','','','','N','N','N','N','N',0,0,0,1,0,0,0,0,0,0,NULL,0,1,0,0,0,0,NULL,NULL,0)

INSERT INTO dbo.VRST_TER(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim) VALUES('2E','NAKNADA ŠTETE ZBOG RASKIDA UG. OL',9,'#KRATTER','#PRIH2EN','','NE',0,'00',0,'','','','','N','N','N','N','N',0,0,0,1,0,0,0,0,0,0,NULL,0,1,0,0,0,0,NULL,NULL,0)
--commit

--FL
-- begin tran
INSERT INTO dbo.konti_nl (nacin_leas, id_konta, konto) 
select nacin_leas, '#PRIH2DN', '770022' from KALK_FORM where LEFT(dbo.gfn_Nacin_leas_HR(nacin_leas), 1) = 'F' AND neaktiven = 0

select * from konti_nl where ID_KONTA = '#PRIH2DN' order by konto--
--commit

--OL
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OA','#PRIH2EN','750105')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OJ','#PRIH2EN','750105')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OG','#PRIH2EN','750105')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OR','#PRIH2EN','770027')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OF','#PRIH2EN','770027')

select * from konti_nl where ID_KONTA = '#PRIH2EN' order by konto--

-- tj. select neaktiven,* from KALK_FORM where (dbo.gfn_Nacin_leas_HR(nacin_leas) = 'OL' AND neaktiven = 0) OR  nacin_leas in ('OR')

--COMMIT


--Klauzule
begin tran
UPDATE dbo.KLAVZULE_SIFR SET opis = '2C, 2D i 2E - Naknada štete' where id_klavzule = 21

INSERT INTO dbo.KLAVZULE_PRAVILA 
select 21, 'LE_FAKTURE_SPL'	, a.nacin_leas, b.id_terj, 'NE', NULL, NULL, NULL,	'2018-03-01',NULL,'SPL', 1,	NULL,NULL,NULL,	0
--select a.*, b.id_terj 
FROM dbo.KONTI_NL a 
JOIN dbo.vrst_ter b ON b.protikonto = a.id_konta
WHERE a.ID_KONTA in ('#PRIH2DN', '#PRIH2EN')

select * from KLAVZULE_SIFR where id_klavzule = 21
select * from KLAVZULE_pravila where id_klavzule = 21 --2018-03-01 00:00:00.000

--commit

-- KONTROLE
*///////////////////////////////
* 20.09.2018 g_tomislav MR 41159
IF fakture.id_terj == "2D" AND ! INLIST(lcNacinLeas, "F1", "F2", "F2", "F4", "F5")
	POZOR("Potraživanje 2D se izdaje samo za ugovore tipa: F1, F2, F2, F4 i F5!")
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

IF fakture.id_terj == "2E" AND ! INLIST(lcNacinLeas, "OA", "OJ", "OG", "OR", "OF")
	POZOR("Potraživanje 2E se izdaje samo za ugovore tipa: OA, OJ, OG, OR i OF!")
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
* KRAJ MR 41159
*///////////////////////////////





local lcNacinLeas, lcTipLeas
lcNacinLeas = GF_LOOKUP('pogodba.nacin_leas',fakture.id_cont,'pogodba.id_cont')
lcTipLeas = RF_TIP_POG(lcNacinLeas)



--SELECTI ZA KONTROLU

select * from VRST_TER where id_terj = '2C'
select * from konti_nl where ID_KONTA = '#KRATTER' order by konto--PRIH2CN

exec dbo.tsp_generate_inserts 'VRST_TER', 'dbo', 'FALSE', '##inserts', 'where id_terj = ''2C'''
select * from ##inserts
--drop table ##inserts

select * from NACINI_L where dbo.gfn_Nacin_leas_HR(nacin_leas) = 'F1'
select * from NACINI_L where dbo.gfn_Nacin_leas_HR(nacin_leas) = 'OL'

select neaktiven,* from KALK_FORM where LEFT(dbo.gfn_Nacin_leas_HR(nacin_leas), 1) = 'F' AND neaktiven = 0
select nacin_leas, COUNT(*) from POGODBA WHERE status_akt != 'Z' AND LEFT(dbo.gfn_Nacin_leas_HR(nacin_leas), 1) = 'F' group by nacin_leas
select nacin_leas, COUNT(*) from POGODBA WHERE  LEFT(dbo.gfn_Nacin_leas_HR(nacin_leas), 1) = 'F' group by nacin_leas