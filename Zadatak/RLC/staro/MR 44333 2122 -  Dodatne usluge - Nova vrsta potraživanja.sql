-- INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim,closing_nacin_leas_type,closing_nacin_leas_list) VALUES('29','NAKNADA - INFORMATIVNA PONUDA',9,'#KRATTER','#PRIH29N','','25',0,'00',0,'','','','','D','D','D','D','D',0,0,0,1,0,0,0,0,0,0,NULL,0,1,0,0,0,0,NULL,NULL,0,NULL,NULL)

select * from dbo.VRST_TER where naziv like '%NAKNAD%'

select * from dbo.KONTI_NL where id_konta = '#KRATTER' order by NACIN_LEAS
select * from dbo.KONTI_NL where id_konta = '#PRIH29N' order by NACIN_LEAS
select * from dbo.KONTI_NL where id_konta = '#PRIH2AN' order by NACIN_LEAS
select * from dbo.KONTI_NL where konto = '752403' order by NACIN_LEAS


--INSERT INTO dbo.AKONPLAN(KONTO,NAZIV,OZNAKA,ALI_KUPEC,NAZIV_TUJ1,NAZIV_TUJ2,NAZIV_TUJ3,PREDP_TEC,STRAN_KNJ,STROS_MES,KNJ_NA_POG,TUJ_KONTO,PRENESI,NEAKTIVEN,PRK_DVRAC,B2_KONTO,IAS_KONTO,KONTO_PRESL,VNOS_INT_VEZA,TUJ_KONTO1,TUJ_KONTO2,TUJ_KONTO3,TUJ_KONTO4,TUJ_KONTO5,B2_ID_KUPCA,module_list,vnos_id_project,TUJ_KONTO6,TUJ_KONTO7,TUJ_KONTO8,TUJ_KONTO9) VALUES('752403','Prihod po konačnom obračunu - FLEET','X',0,'','','',0,'','',0,'',0,0,'','','',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'000',0,NULL,NULL,NULL,NULL)


INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim,closing_nacin_leas_type,closing_nacin_leas_list) VALUES('2I','NAKNADA PO KONAČNOM OBRAČUNU - DODATNE USLUGE',9,'#KRATTER','#PRIH2IN','','25',0,'00',0,'','','','','D','D','D','D','D',0,0,0,1,0,0,0,0,0,0,NULL,0,1,0,0,0,0,NULL,NULL,0,NULL,NULL)

INSERT INTO dbo.konti_nl (id_konta, konto)
VALUES ('#PRIH2IN', '752403')












select * from dbo.VRST_TER where naziv like '%NAKNAD%'

select * from dbo.KONTI_NL where id_konta = '#KRATTER' order by NACIN_LEAS
select * from dbo.KONTI_NL where id_konta = '#PRIH29N' order by NACIN_LEAS
select * from dbo.KONTI_NL where id_konta = '#PRIH2AN' order by NACIN_LEAS
select * from dbo.KONTI_NL where konto = '752403' order by NACIN_LEAS

select * from dbo.AKONPLAN where KONTO = '752403'