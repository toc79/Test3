/*INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti) VALUES('66','POTRAŽIVANJA- SS FL',9,'120801','121999','SSFL','00',0,'00',0,'','','','','N','N','N','N','N',0,0,0,1,0,0,0,0,0,0,NULL,0,1,0,0,0,0)
*/
Molim HITNO otvoriti novu vrstu potraživanja: 
30 - Naknada štete kod prijevr.raskida ug. OL 
Navedena naknada nije oporeziva i ulazi u Knjiga IRA neoporezivo ( kao i zatezna kamata i opomene, a ne redovnu), a na računima u napomeni treba navesti: 
Porez na dodanu vrijednost nije obračunat temeljem članka 25. - stavak 6. Pravilnika o porezu na dodanu vrijednost. 
Knjiženja bi bila: duguje 121101- Ostala potraživanja po osnovi operativnog leasinga. 
potražuje 750107 - Naknada štete kod prijevremenih raskida ugovora OL 
Napomena: 750107 je novi konto 
#KRATTER
Leasing	Konto
OA	121101  
OG	140002  
OJ	121101  
OP	121101  
OS	121101  
#PRIH30N
/* PROVJERE KLAUZULE
select * from klavzule_pravila where id_terj is  null
select * from  klavzule_sifr where klavzula like '%6%'
select * from  klavzule_sifr where klavzula like '%25%'
select top 100 * from rac_out where opisdok like '%SS FL%'--'%zatezne%'  --tip_knjige ='INEO' -- id_terj='11' 
order by datum desc  */

--SKRIPTE
INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti) VALUES('30','NAKNADA ŠTETE KOD PRIJEVR.RASKIDA UG. OL',9,'#KRATTER','#PRIH30N','','00',0,'00',0,'','','','','N','N','N','N','N',0,0,0,1,0,0,0,0,0,0,NULL,0,1,0,0,0,0)	
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('BF','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F1','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F2','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('FF','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OA','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OG','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OJ','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OS','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PD','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('ZP','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OP','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F3','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('NF','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('NO','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PF','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PO','#PRIH30N','750107')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F4','#PRIH30N','750107')
--KLAUZULE TREBA PODESITI
INSERT INTO dbo.klavzule_sifr(opis,klavzula,neaktiven) VALUES('30 - Naknada štete kod prijevr.raskida ug. OL','Porez na dodanu vrijednost nije obračunat temeljem članka 25. - stavak 6. Pravilnika o porezu na dodanu vrijednost.',0) 
-- 19 OBRATITI PAŽNJU!!!!!!!!!!!!!!
INSERT INTO dbo.klavzule_pravila(id_klavzule,tip_dogodka,nacin_leas,id_terj,id_dav_st,id_cont,id_kupca,tip_opr,datum_od,datum_do,skupina,prioriteta,dav_obv,tip_rezidentstva,ID_SUBV_SIF,ima_robresti) VALUES(19,'LE_FAKTURE_SPL','OA','30','00',NULL,NULL,NULL,'Mar  1 2016 12:00AM',NULL,'SPL',1,NULL,NULL,NULL,0)
INSERT INTO dbo.klavzule_pravila(id_klavzule,tip_dogodka,nacin_leas,id_terj,id_dav_st,id_cont,id_kupca,tip_opr,datum_od,datum_do,skupina,prioriteta,dav_obv,tip_rezidentstva,ID_SUBV_SIF,ima_robresti) VALUES(19,'LE_FAKTURE_SPL','OG','30','00',NULL,NULL,NULL,'Mar  1 2016 12:00AM',NULL,'SPL',1,NULL,NULL,NULL,0)
INSERT INTO dbo.klavzule_pravila(id_klavzule,tip_dogodka,nacin_leas,id_terj,id_dav_st,id_cont,id_kupca,tip_opr,datum_od,datum_do,skupina,prioriteta,dav_obv,tip_rezidentstva,ID_SUBV_SIF,ima_robresti) VALUES(19,'LE_FAKTURE_SPL','OJ','30','00',NULL,NULL,NULL,'Mar  1 2016 12:00AM',NULL,'SPL',1,NULL,NULL,NULL,0)




