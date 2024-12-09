INSERT INTO dbo.KLAVZULE_SIFR(opis,klavzula,neaktiven) VALUES('1P i 1R - Kasko osiguranje i Osnovno osiguranje','Temeljem odredbi Zakona o PDV-u čl.40 st.1, točka (a) naknada za plaćanje premije osiguranja ne podliježe plaćanju PDV-a.',0)

INSERT INTO dbo.KLAVZULE_pravila(id_klavzule,tip_dogodka,nacin_leas,id_terj,id_dav_st,id_cont,id_kupca,tip_opr,datum_od,datum_do,skupina,prioriteta,dav_obv,tip_rezidentstva,ID_SUBV_SIF,ima_robresti) VALUES(22,'LE_FAKTURE_SPL',NULL,'1P',NULL,NULL,NULL,NULL,'Jun  4 2021 12:00AM',NULL,'SPL',1,0,NULL,NULL,0)
INSERT INTO dbo.KLAVZULE_pravila(id_klavzule,tip_dogodka,nacin_leas,id_terj,id_dav_st,id_cont,id_kupca,tip_opr,datum_od,datum_do,skupina,prioriteta,dav_obv,tip_rezidentstva,ID_SUBV_SIF,ima_robresti) VALUES(22,'LE_FAKTURE_SPL',NULL,'1R',NULL,NULL,NULL,NULL,'Jun  4 2021 12:00AM',NULL,'SPL',1,NULL,NULL,NULL,0)

NA PRODUKCIJI PROVJERITI ŠIFRU

PONOVNO PRIPREMI SKRIPTU 

INSERT INTO dbo.KLAVZULE_SIFR(opis,klavzula,neaktiven) VALUES('1P i 1R - Kasko osiguranje i Osnovno osiguranje','Temeljem odredbi Zakona o PDV-u čl.40 st.1, točka (a) naknada za plaćanje premije osiguranja ne podliježe plaćanju PDV-a.',0)

INSERT INTO dbo.KLAVZULE_pravila(id_klavzule,tip_dogodka,nacin_leas,id_terj,id_dav_st,id_cont,id_kupca,tip_opr,datum_od,datum_do,skupina,prioriteta,dav_obv,tip_rezidentstva,ID_SUBV_SIF,ima_robresti) VALUES(22,'LE_FAKTURE_SPL',NULL,'1P',NULL,NULL,NULL,NULL,'20210824',NULL,'SPL',1,0,NULL,NULL,0)
INSERT INTO dbo.KLAVZULE_pravila(id_klavzule,tip_dogodka,nacin_leas,id_terj,id_dav_st,id_cont,id_kupca,tip_opr,datum_od,datum_do,skupina,prioriteta,dav_obv,tip_rezidentstva,ID_SUBV_SIF,ima_robresti) VALUES(22,'LE_FAKTURE_SPL',NULL,'1R',NULL,NULL,NULL,NULL,'20210824',NULL,'SPL',1,NULL,NULL,NULL,0)


Ručno sam promijenio dav_obv u NULL kroz masku
INSERT INTO dbo.KLAVZULE_pravila(id_klavzule,tip_dogodka,nacin_leas,id_terj,id_dav_st,id_cont,id_kupca,tip_opr,datum_od,datum_do,skupina,prioriteta,dav_obv,tip_rezidentstva,ID_SUBV_SIF,ima_robresti) VALUES(22,'LE_FAKTURE_SPL',NULL,'1P',NULL,NULL,NULL,NULL,'20210824',NULL,'SPL',1,NULL,NULL,NULL,0)


