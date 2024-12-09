--staro 15
INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim,closing_nacin_leas_type,closing_nacin_leas_list,used_as_interests,discont_early_buyout) VALUES('15','KASKO OSIGURANJE',9,'#KRATTER','!!!!!!!!','REG','25',0,'00',0,'','','','','D','D','D','D','D',0,1,0,1,0,0,0,0,0,0,NULL,0,1,0,0,0,0,NULL,NULL,0,NULL,NULL,0,NULL)

INSERT INTO dbo.plan_knj(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES(NULL,'15','#','ZAPADE_OST','NORB','#KRATTER','D','#XAK','C','DOSPIJEĆE OST. POTR.','IFA')
INSERT INTO dbo.plan_knj(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES(NULL,'15','#','ZAPADE_OST','M','#KRATTER','D','#PRIH15M','C','DOSPIJEĆE OST. POTR.','IFA')
INSERT INTO dbo.plan_knj(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES(NULL,'15','-','ZAPADE_OST','D','#KRATTER','D','#PREHDDV','C','DOSPIJEĆE OST. POTR. - POREZ','IFA')
INSERT INTO dbo.plan_knj(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES(NULL,'15','+','ZAPADE_OST','D','#KRATTER','D','$DAVEK','C','DOSPIJEĆE OST. POTR. - POREZ','IFA')

INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('BF','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F1','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F2','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('FF','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OA','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OG','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OJ','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OS','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('ZP','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PD','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OP','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F3','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('NF','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('NO','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PF','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PO','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F4','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F5','#XAK','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('TP','#XAK','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OF','#XAK','762013')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OR','#XAK','762013')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES(NULL,'#PRIH15M','771007')

--novo 
--ili kroz aplikaciju 
update dbo.vrst_ter set naziv='KASKO OSIGURANJE STARO NE KORISTITI!!', sif_terj= '', neaktiven=1 where id_terj='15'

INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim,closing_nacin_leas_type,closing_nacin_leas_list,used_as_interests,discont_early_buyout) VALUES('1P','KASKO OSIGURANJE',9,'#KRATTER','!!!!!!!!','REG','25',0,'00',0,'','','','','N','D','D','D','D',0,1,0,1,0,0,0,0,0,0,NULL,0,1,0,0,0,0,NULL,NULL,0,NULL,NULL,0,NULL)

INSERT INTO dbo.plan_knj(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES(NULL,'1P','#','ZAPADE_OST','NORB','#KRATTER','D','#PRIH1PN','C','DOSPIJEĆE OST. POTR.','IFA')
INSERT INTO dbo.plan_knj(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES(NULL,'1P','#','ZAPADE_OST','M','#KRATTER','D','#PRIH1PM','C','DOSPIJEĆE OST. POTR.','IFA')
INSERT INTO dbo.plan_knj(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES(NULL,'1P','-','ZAPADE_OST','D','#KRATTER','D','#PREHDDV','C','DOSPIJEĆE OST. POTR. - POREZ','IFA')
INSERT INTO dbo.plan_knj(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES(NULL,'1P','+','ZAPADE_OST','D','#KRATTER','D','$DAVEK','C','DOSPIJEĆE OST. POTR. - POREZ','IFA')	

INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('BF','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F1','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F2','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('FF','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OA','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OG','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OJ','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OS','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('ZP','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PD','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OP','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F3','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('NF','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('NO','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PF','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('PO','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F4','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F5','#PRIH1PN','762001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('TP','#PRIH1PN','752001')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OF','#PRIH1PN','762013')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OR','#PRIH1PN','762013')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES(NULL,'#PRIH1PM','771007')