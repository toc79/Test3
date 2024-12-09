
--bck s TEST

--INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('0','NEMA NIŠTA','002','001','005',0,0,'','','',1,'',0,0,NULL,NULL,NULL)
--INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('EUR11','1-MJESEČNI EURIBOR','005','001','005',2,1,'','','',3,'',0,1,NULL,NULL,NULL)
--INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('EUR34','3-MJESEČNI EURIBOR','005','004','005',2,1,'','','',3,'',0,0,NULL,NULL,NULL)
--INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('EUR3I','3-MJESEČNI EURIBOR izvedeni','005','004','005',2,1,'','','',2,'',0,0,'EUR34',NULL,-1)
--INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('EUR62','6-MJESEČNI EURIBOR','005','002','005',2,1,'','','',3,'',0,0,NULL,NULL,NULL)
--INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('LCH11','1-MJESEČNI LIBOR','005','001','005',2,1,'','','',3,'',1,0,NULL,NULL,NULL)
--INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('LCH34','3-MJESEČNI LIBOR','005','004','005',2,1,'','','',3,'',1,0,NULL,NULL,NULL)
--INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('LCH62','6-MJESEČNI LIBOR','005','002','005',2,1,'','','',3,'',1,0,NULL,NULL,NULL)


Sve je OK i možete postaviti na PROD. 

Molim na isti način kreirati i ostale IZVEDENE EURIBORe (1-mjesečni i 6-mjesečni). 
Također molimo (jer očito je da na izvedenima rev.indeksima ne možemo raditi nikakve izmjene, pa ni redoslijed) da stavite 
sljedeći redoslijed: 
2. 3-MJESEČNI EURIBOR izvedeni 
3. 6-MJESEČNI EURIBOR-izvedeni 
4. 1-MJESEČNI EURIBOR-izvedeni 
5. 3-MJESEČNI EURIBOR 
6. 6-MJESEČNI EURIBOR 
7. 1-MJESEČNI EURIBOR 

--9
Poštovani 
Možete, za sve izvedene Rev. indekse staviti na kraju naziva glavnog Rev. indeksa -I. 
(napr. 3-mjesečni EURIBOR-I) 
Molim kreirajte sve izvedene indekse, i postavite redoslijed pojavljivanja, kako smo naveli ranije u mailu. 

--UPDATE dbo.rtip SET vrstni_red = 1 WHERE id_rtip = '0' -- 1 nema promjene
BEGIN TRAN
INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) VALUES('EUR3I','3-MJESEČNI EURIBOR-I','005','004','005',2,1,'','','',2,'',0,0,'EUR34',NULL,-1)
INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) 
VALUES('EUR1I','1-MJESEČNI EURIBOR-I','005','001','005',2,1,'','','',4,'',0,1,'EUR11',NULL,-1)
INSERT INTO dbo.rtip(id_rtip,naziv,id_obd,id_obdrep,id_obdfakt,id_tiprep,spr_obrm,naziv_tuj1,naziv_tuj2,naziv_tuj3,vrstni_red,b2grupa,neaktiven,FIX_DAT_RPG,id_rtip_base,rounding_unit,rounding_type) 
VALUES('EUR6I','6-MJESEČNI EURIBOR-I','005','002','005',2,1,'','','',3,'',0,0,'EUR62',NULL,-1)

UPDATE dbo.rtip SET vrstni_red = 7 WHERE id_rtip = 'EUR11' --
UPDATE dbo.rtip SET vrstni_red = 5 WHERE id_rtip = 'EUR34'
--UPDATE dbo.rtip SET vrstni_red = 2, naziv = '3-MJESEČNI EURIBOR-I' WHERE id_rtip = 'EUR3I'
UPDATE dbo.rtip SET vrstni_red = 6 WHERE id_rtip = 'EUR62'
UPDATE dbo.rtip SET vrstni_red = 7 WHERE id_rtip = 'LCH11'
UPDATE dbo.rtip SET vrstni_red = 8 WHERE id_rtip = 'LCH34'
UPDATE dbo.rtip SET vrstni_red = 9 WHERE id_rtip = 'LCH62'
--UPDATE dbo.rtip SET vrstni_red = 3 WHERE id_rtip = 'EUR6I' --
--UPDATE dbo.rtip SET vrstni_red = 4 WHERE id_rtip = 'EUR1I'

--commit
8.3.2016
UPDATE dbo.rtip SET fix_dat_rpg=0  WHERE id_rtip = 'EUR1I' 
