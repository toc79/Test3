begin tran
INSERT INTO dbo.kred_pog(ID_KREDPOG,DAT_SKLEN,ID_KUPCA,VAL_ZNES,ID_TEC,TECAJ,SIT_ZNES,OBRESTI,MANAGMENT,COMM,OSTALI_STR,CRPANJE,ID_ODPLAC,ST_ANUITET,DAT_1OBR,DINAMIKA,ZAM_OBR,GARANCIJE,TIP,DAN_PLAC,DAN_IZRAC,DAN_OBR,VARIANTA,OPOMBE,ANUITETA,END_MODE,DAT_OBR,SOFIN,IZRAC_OBR,NJIH_ST,ZADN_AN,DAT_0OBR,PRVA_AN,UP_GLAV,VKL_1,VKL_2,ZADNJI_MES,REFINANC,ANEKS,OZNAKA,TIP_IZRACUNA,ID_ODPLAC2,ST_OBROKOV2,FIX_DEL,ID_RTIP,KONTODOBV,KONTODRS,DAT_KON,VNESEL,DAT_VNOSA,CRPAN_DAT,CRPAN_ZNES,id_gl_knj_shema,id_strm,status_akt,tip_pog,id_krov_pog,withholding_tax,withholding_tax_net,dat_aktiv,generate_payment,skl_st_do1,skl_st_do2,skupna_cena,id_sklic,ne_razmej_obr,ne_knj_aktivacija,ne_knj_crpanje,ne_knj_glavnica,krov_pog_val_znes,id_obr,ne_preknj_kddo,for_allocation,amount_for_allocation,id_purpose,all_in_price_for_NPM,dat_zakl,dat_poprave,rind_datum,ne_knj_obresti,k_method,OBRESTI_ZAC,FIX_DEL_ZAC) VALUES('0236 20','Dec 21 2016 12:00AM','022390',7380292.44,'005',7.5296690000,55571159.20,0.000000,0.00,0.00,'','','002',10,'Jun 15 2020 12:00AM','',0.00,'','N','','','','','potpisan krovni ugovor 21.12.2016, 40 min eur commited
finders fee 0,1%
appraisal fee 26 000.00 eur
fixed rate , plaćanje kamate kvartalno, plaćanje glavnice polugodišnje,
first repavment date 15.06.2020',738029.24,0,'Jun 15 2020 12:00AM',0.00,'R','FI N 86.251(HR)',0.00,NULL,0.00,'D',0,0,0,'','','',2,'004',20,0.0000,'0',NULL,NULL,'Jun 15 2025 12:00AM','anitag','Mar 13 2020 12:00AM','Mar 16 2020 12:00AM',7380292.44,1,'0020','A',2,'0180 16',0.0000,0,'Dec 21 2016 12:00AM',1,'02','97',0.4856,'000405446',0,0,0,0,7380292.44,NULL,0,1,7380292.44,'',0.4856,NULL,'Apr 14 2020  5:57PM',NULL,1,'K360',0.000000,0.0000)
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Mar 16 2020 12:00AM',0.00,0.00,0.00,'Mar 16 2020 12:00AM',7380292.44,0,0.000000,7380292.44,1,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Jun 15 2020 12:00AM',670935.68,670935.68,0.00,'Jun 15 2020 12:00AM',6709356.76,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Dec 15 2020 12:00AM',670935.68,670935.68,0.00,'Dec 15 2020 12:00AM',6038421.08,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Jun 15 2021 12:00AM',670935.68,670935.68,0.00,'Jun 15 2021 12:00AM',5367485.40,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Dec 15 2021 12:00AM',670935.68,670935.68,0.00,'Dec 15 2021 12:00AM',4696549.72,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Jun 15 2022 12:00AM',670935.68,670935.68,0.00,'Jun 15 2022 12:00AM',4025614.04,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Dec 15 2022 12:00AM',670935.68,670935.68,0.00,'Dec 15 2022 12:00AM',3354678.36,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Jun 15 2023 12:00AM',670935.68,670935.68,0.00,'Jun 15 2023 12:00AM',2683742.68,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Dec 15 2023 12:00AM',670935.68,670935.68,0.00,'Dec 15 2023 12:00AM',2012807.00,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Jun 15 2024 12:00AM',670935.68,670935.68,0.00,'Jun 15 2024 12:00AM',1341871.32,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Dec 15 2024 12:00AM',670935.68,670935.68,0.00,'Dec 15 2024 12:00AM',670935.64,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
INSERT INTO dbo.kred_planp(ID_KREDPOG,DAT_ZAP,ANUITETA,ZNES_R,ZNES_O,DAT_OBR,STANJE,RAC_OBRESTI,OBR_MERA,CRPANJE,IS_EVENT,ID_TEC,DAT_PL,SALDO,KOMENTAR,PLAC_SIT,PLAC_TEC,DO_DAN,NOVE_POG,NOVE_POG1,evident,placano,vrac_sred_crpan,fixing_date,evident_obr) VALUES('0236 20','Jun 15 2025 12:00AM',670935.64,670935.64,0.00,'Jun 15 2025 12:00AM',0.00,0,0.000000,0.00,0,'005',NULL,0.00,'',0.00,0.00,NULL,0.00,0.00,'',0,NULL,NULL,'')
--rollback
--commit