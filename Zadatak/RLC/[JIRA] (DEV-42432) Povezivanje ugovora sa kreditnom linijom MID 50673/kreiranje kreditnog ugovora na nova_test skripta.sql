exec dbo.Tsp_generate_inserts 'kred_planp', 'dbo', 'false','##inserts', 'where id_kredpog = ''0274 23''', 0
select * from ##inserts

INSERT INTO dbo.kred_pog(ID_KREDPOG,DAT_SKLEN,ID_KUPCA,VAL_ZNES,ID_TEC,TECAJ,SIT_ZNES,OBRESTI,MANAGMENT,COMM,OSTALI_STR,CRPANJE,ID_ODPLAC,ST_ANUITET,DAT_1OBR,DINAMIKA,ZAM_OBR,GARANCIJE,TIP,DAN_PLAC,DAN_IZRAC,DAN_OBR,VARIANTA,OPOMBE,ANUITETA,END_MODE,DAT_OBR,SOFIN,IZRAC_OBR,NJIH_ST,ZADN_AN,DAT_0OBR,PRVA_AN,UP_GLAV,VKL_1,VKL_2,ZADNJI_MES,REFINANC,ANEKS,OZNAKA,TIP_IZRACUNA,ID_ODPLAC2,ST_OBROKOV2,FIX_DEL,ID_RTIP,KONTODOBV,KONTODRS,DAT_KON,VNESEL,DAT_VNOSA,CRPAN_DAT,CRPAN_ZNES,id_gl_knj_shema,id_strm,status_akt,tip_pog,id_krov_pog,withholding_tax,withholding_tax_net,dat_aktiv,generate_payment,skl_st_do1,skl_st_do2,skupna_cena,id_sklic,ne_razmej_obr,ne_knj_aktivacija,ne_knj_crpanje,ne_knj_glavnica,krov_pog_val_znes,id_obr,ne_preknj_kddo,for_allocation,amount_for_allocation,id_purpose,all_in_price_for_NPM,dat_zakl,dat_poprave,rind_datum,ne_knj_obresti,k_method,OBRESTI_ZAC,FIX_DEL_ZAC,bullet_amount,bullet_date) VALUES('0274 23','Apr 17 2023 12:00AM','000389',20000000.00,'000',1.0000000000,20000000.00,5.180000,0.00,0.00,'','','004',12,'Jul 20 2023 12:00AM','',0.00,'','N','','','','','Ugovor o dugoročnom kreditu sklopljen 17.04.2023. na iznos 20 mn EUR. Datum povlačenja 20.04.2023, kamatna stopa 1,98% + 3 mth euribor, dinamika otplate: 12 jednakih tromjesečnih rata, počevši od 20.07.2023, zadnja rata 20.04.2026.',1666666.67,0,'Jul 20 2023 12:00AM',0.00,'R','',0.00,NULL,0.00,'D',0,0,0,'106','','',2,'004',12,1.9800,'EUR3I',NULL,NULL,'Apr 20 2026 12:00AM','miam','Apr 20 2023 12:00AM','Apr 20 2023 12:00AM',20000000.00,4,'9999','A',3,NULL,0.0000,0,'Apr 20 2023 12:00AM',1,'02','10',2.0675,'000505234',0,0,0,0,0.00,'',0,1,20000000.00,'',2.0675,NULL,NULL,'Apr 19 2023 12:00AM',0,'K360',5.180000,1.9800,NULL,NULL)

INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Apr 20 2023 12:00AM',0.00,0.00,0.00,'Apr 20 2023 12:00AM',20000000.00,0,5.180000,20000000.00,1,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'*',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jul 20 2023 12:00AM',1666666.67,1666666.67,0.00,'Jul 20 2023 12:00AM',18333333.33,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jul 20 2023 12:00AM',261877.78,0.00,261877.78,'Jul 20 2023 12:00AM',18333333.33,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Jul 19 2023 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Oct 20 2023 12:00AM',1666666.67,1666666.67,0.00,'Oct 20 2023 12:00AM',16666666.67,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Oct 20 2023 12:00AM',242692.59,0.00,242692.59,'Oct 20 2023 12:00AM',16666666.67,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Oct 19 2023 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jan 20 2024 12:00AM',1666666.67,1666666.67,0.00,'Jan 20 2024 12:00AM',15000000.00,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jan 20 2024 12:00AM',220629.63,0.00,220629.63,'Jan 20 2024 12:00AM',15000000.00,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Jan 19 2024 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Apr 20 2024 12:00AM',1666666.67,1666666.67,0.00,'Apr 20 2024 12:00AM',13333333.33,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Apr 20 2024 12:00AM',196408.33,0.00,196408.33,'Apr 20 2024 12:00AM',13333333.33,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Apr 19 2024 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jul 20 2024 12:00AM',1666666.67,1666666.67,0.00,'Jul 20 2024 12:00AM',11666666.67,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jul 20 2024 12:00AM',174585.19,0.00,174585.19,'Jul 20 2024 12:00AM',11666666.67,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Jul 19 2024 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Oct 20 2024 12:00AM',1666666.67,1666666.67,0.00,'Oct 20 2024 12:00AM',10000000.00,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Oct 20 2024 12:00AM',154440.74,0.00,154440.74,'Oct 20 2024 12:00AM',10000000.00,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Oct 19 2024 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jan 20 2025 12:00AM',1666666.67,1666666.67,0.00,'Jan 20 2025 12:00AM',8333333.33,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jan 20 2025 12:00AM',132377.78,0.00,132377.78,'Jan 20 2025 12:00AM',8333333.33,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Jan 19 2025 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Apr 20 2025 12:00AM',1666666.67,1666666.67,0.00,'Apr 20 2025 12:00AM',6666666.67,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Apr 20 2025 12:00AM',107916.67,0.00,107916.67,'Apr 20 2025 12:00AM',6666666.67,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Apr 19 2025 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jul 20 2025 12:00AM',1666666.67,1666666.67,0.00,'Jul 20 2025 12:00AM',5000000.00,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jul 20 2025 12:00AM',87292.59,0.00,87292.59,'Jul 20 2025 12:00AM',5000000.00,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Jul 19 2025 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Oct 20 2025 12:00AM',1666666.67,1666666.67,0.00,'Oct 20 2025 12:00AM',3333333.33,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Oct 20 2025 12:00AM',66188.89,0.00,66188.89,'Oct 20 2025 12:00AM',3333333.33,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Oct 19 2025 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jan 20 2026 12:00AM',1666666.67,1666666.67,0.00,'Jan 20 2026 12:00AM',1666666.67,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Jan 20 2026 12:00AM',44125.93,0.00,44125.93,'Jan 20 2026 12:00AM',1666666.67,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Jan 19 2026 12:00AM','')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Apr 20 2026 12:00AM',1666666.67,1666666.67,0.00,'Apr 20 2026 12:00AM',0.00,0,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0274 23','Apr 20 2026 12:00AM',21583.33,0.00,21583.33,'Apr 20 2026 12:00AM',0.00,1,5.180000,0.00,0,'000',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,'Apr 19 2026 12:00AM','')