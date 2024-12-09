/* Za postavljanje na produkciju
*/
INSERT INTO dbo.dok(ID_OBL_ZAV,SIFRA,OPIS,VELJAVNOST,AVTOM,OPIS_TUJ1,OPIS_TUJ2,PRIORITETA,NE_OPOMIN,VRST_RED_D,DNI_ZAP,VELJ_OPIS,IMA_VINK,ALI_NA_POG,IMA_VRED,IMA_BANKO,IMA_THIPOT,ALI_NA_ZREG,ALI_NA_ZNER,ALI_OBV,DNI_OBV,DNI_OPOM,IMA_PART,JE_COLLAT,is_elligible,eval_frequency,ima_zav,neaktiven,akt_datum,b2grupa,JE_REG_NEPR,opravi_sam_def_val,neak_pog_zakl,ima_kategor1,ima_kategor2,ima_kategor3,za_krov_dok,vez_na_krov_dok,DNI_ZAP_OLD,prenesi_ob_storno,logiraj_spremembe,za_ponudbo,za_odobrit,za_pov_dok,ima_kategor4,ima_kategor5,ima_kategor6,use4eyes,id_gl_knj_shema,ima_cenitev,nacin_izbora_partner,polji_vrednost_obvezni,za_nepopoln,DNI_OPOM2,DNI_OPOM3,DNI_OPOM4) VALUES('NI','','NEMA INTERKALARNIH KAMATA',0,'','','',0,0,'',0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,2,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,NULL,0,NULL,0,0,0,0,0)

INSERT INTO dbo.statusi(STATUS,NAZIV,SIF_STATUS,NE_OPOMIN,b2grupa,NE_OBV_OBR,NE_OBV_REG,NE_OPOM_DOK,NE_FAKT_ODKUP,NE_ZOBR) VALUES('OD','Ne pripremaj opomene za dokumentaciju','',0,'',0,0,1,0,0)

INSERT INTO dbo.STATUS_SYS(ID_STATUS,SIF_STATUS_SYS,NAZIV,OBVESTILA,KNJIZENJE,OPOMINI,ZAPIRANJE,NE_PREK_DO,BLACK_L,ANEKS,ST_DNI,SET_DATUM,ZAM_OBR,DIREK_BREM,likvidacija,reprogram,pon_pred_odkup,status_pog,rep_spr_ind,id_rep_category,AKTIVACIJA,storno_terj,storno_plac,ROC_KNJ,PRENOS_DNEV_VKNJ,SPREMEMBA_DAT_PP,IZDAJA_SPL_FAK) VALUES(4,'','IZUZETAK PO ODOBRENJU',0,0,1,0,0,0,'',36500,1,0,0,0,0,1,'OD',0,'999',0,0,0,0,0,0,0)

/*
KRAJ SKRIPTE ZA POSTAVLJANJE NA PRODUKCIJU
*/


ID šifranta	Ključ	Opisna vrijednost	Logička vrijednost	Brojčana vrijednost	Znakovna vrijednost	Datum	Neaktivan
FRAME_LIST_KATEGORIJA1	0001	Opomene za potraživanja	.F.				.F.
FRAME_LIST_KATEGORIJA1	0010	Opomene za dokumentaciju	.F.				.F.
FRAME_LIST_KATEGORIJA1	0100	Prijevremeni otkup	.F.				.F.
FRAME_LIST_KATEGORIJA1	1000	Interkalarne kamate	.F.				.F.
FRAME_LIST_KATEGORIJA1	0011	Opomene za potraživanja i dokumentaciju	.F.				.F.
itd. ....




select * from dbo.STATUSI

select * from dbo.STATUS_SYS 
--update dbo.status_sys set SIF_STATUS_SYS = 'IPO', naziv = 'IZUZETAK PO ODOBRENJU' where id_status = 4


INSERT INTO dbo.status_sys(ID_STATUS,SIF_STATUS_SYS,NAZIV,OBVESTILA,KNJIZENJE,OPOMINI,ZAPIRANJE,NE_PREK_DO,BLACK_L,ANEKS,ST_DNI,SET_DATUM,ZAM_OBR,DIREK_BREM,likvidacija,reprogram,pon_pred_odkup,status_pog,rep_spr_ind,id_rep_category,AKTIVACIJA,storno_terj,storno_plac,ROC_KNJ,PRENOS_DNEV_VKNJ,SPREMEMBA_DAT_PP,IZDAJA_SPL_FAK) VALUES(0,'OST','OSTALO',0,0,0,1,1,1,'',0,0,0,1,0,0,0,NULL,0,NULL,0,0,0,0,0,0,0)
INSERT INTO dbo.status_sys(ID_STATUS,SIF_STATUS_SYS,NAZIV,OBVESTILA,KNJIZENJE,OPOMINI,ZAPIRANJE,NE_PREK_DO,BLACK_L,ANEKS,ST_DNI,SET_DATUM,ZAM_OBR,DIREK_BREM,likvidacija,reprogram,pon_pred_odkup,status_pog,rep_spr_ind,id_rep_category,AKTIVACIJA,storno_terj,storno_plac,ROC_KNJ,PRENOS_DNEV_VKNJ,SPREMEMBA_DAT_PP,IZDAJA_SPL_FAK) VALUES(1,'TOZ','UTUŽENI UGOVOR',1,1,1,0,1,1,'T',360,0,0,1,0,0,0,NULL,0,'999',0,0,0,0,0,0,0)
INSERT INTO dbo.status_sys(ID_STATUS,SIF_STATUS_SYS,NAZIV,OBVESTILA,KNJIZENJE,OPOMINI,ZAPIRANJE,NE_PREK_DO,BLACK_L,ANEKS,ST_DNI,SET_DATUM,ZAM_OBR,DIREK_BREM,likvidacija,reprogram,pon_pred_odkup,status_pog,rep_spr_ind,id_rep_category,AKTIVACIJA,storno_terj,storno_plac,ROC_KNJ,PRENOS_DNEV_VKNJ,SPREMEMBA_DAT_PP,IZDAJA_SPL_FAK) VALUES(2,'','RASKINUTI UGOVOR',1,1,1,0,1,1,'R',360,1,0,1,0,0,0,NULL,0,NULL,0,0,0,0,0,0,0)
INSERT INTO dbo.status_sys(ID_STATUS,SIF_STATUS_SYS,NAZIV,OBVESTILA,KNJIZENJE,OPOMINI,ZAPIRANJE,NE_PREK_DO,BLACK_L,ANEKS,ST_DNI,SET_DATUM,ZAM_OBR,DIREK_BREM,likvidacija,reprogram,pon_pred_odkup,status_pog,rep_spr_ind,id_rep_category,AKTIVACIJA,storno_terj,storno_plac,ROC_KNJ,PRENOS_DNEV_VKNJ,SPREMEMBA_DAT_PP,IZDAJA_SPL_FAK) VALUES(3,'','TOTALNA ŠTETA',1,1,1,0,1,1,'U',360,1,0,1,0,0,0,NULL,0,NULL,0,0,0,0,0,0,0)

INSERT INTO dbo.status_sys(ID_STATUS,SIF_STATUS_SYS,NAZIV,OBVESTILA,KNJIZENJE,OPOMINI,ZAPIRANJE,NE_PREK_DO,BLACK_L,ANEKS,ST_DNI,SET_DATUM,ZAM_OBR,DIREK_BREM,likvidacija,reprogram,pon_pred_odkup,status_pog,rep_spr_ind,id_rep_category,AKTIVACIJA,storno_terj,storno_plac,ROC_KNJ,PRENOS_DNEV_VKNJ,SPREMEMBA_DAT_PP,IZDAJA_SPL_FAK) VALUES(4,'NOP','Test',0,0,1,0,0,0,'',360,0,0,1,0,0,0,NULL,0,'999',0,0,0,0,0,0,0)


--NOVO
INSERT INTO dbo.status_sys(ID_STATUS,SIF_STATUS_SYS,NAZIV,OBVESTILA,KNJIZENJE,OPOMINI,ZAPIRANJE,NE_PREK_DO,BLACK_L,ANEKS,ST_DNI,SET_DATUM,ZAM_OBR,DIREK_BREM,likvidacija,reprogram,pon_pred_odkup,status_pog,rep_spr_ind,id_rep_category,AKTIVACIJA,storno_terj,storno_plac,ROC_KNJ,PRENOS_DNEV_VKNJ,SPREMEMBA_DAT_PP,IZDAJA_SPL_FAK) VALUES(4,'NOD','TEST',0,0,1,0,0,0,'',36500,1,0,0,0,0,1,'OD',0,'999',0,0,0,0,0,0,0)


/*
kod kopiranja posebnosti se ne kopiraju statusi

Poštovana/i, 

kreirali smo:
- status ugovora OD Ne pripremaj opomene za dokumentaciju.
- predložak posebnosti ugovora IZUZETAK PO ODOBRENJU. Kod odabira predloška u posebnostima će se automatski popuniti datumi "Pripremu opomena do:" i "Priprema ponude za prijevremeni zaključak/opomenu do:". Kod spremanja podataka u posebnostima će se postaviti pitanje da li za taj ugovor želite promijeniti status ugovora na OD Ne pripremaj opomene za dokumentaciju.
- dokument NI NEMA INTERKALARNIH KAMATA. Za dokument je podešeno da se promjene zapisuju/evidentiraju u pregled reprograma (unos dokumenta se ne evidentira dok se promjena ili brisanje evidentira).
- dodatnu rutinu "Dodavanje statusa ugovora Ne pripremaj opomene za dokumentaciju" na pregledu posebnosti ugovora. Dodavanje statusa je moguće i kad partner nema posebnosti ugovora na način da u kriteriju pretrage "Partner" unesete/odaberete željenog partnera i pokrenete obradu za prikaz podataka pa nakon toga kliknete na dodatnu rutinu. Promjena statusa ugovora se zapisuje u pregled reprograma. Za promjenu statusa ugovora korisnik mora imati odgovarajuće pravo (ActiveContractUpdate).
- dodatnu rutinu "Isključivanje obračuna intrerkalarnih kamata dodavanjem NI dokumenta" na pregledu posebnosti ugovora. Dodavanje NI dokumenta je moguće i kad partner nema posebnosti ugovora na način da u kriteriju pretrage "Partner" unesete/odaberete željenog partnera i pokrenete obradu za prikaz podataka pa nakon toga kliknete na dodatnu rutinu. Za promjenu statusa ugovora korisnik mora imati odgovarajuće pravo (ContractDocumentationInsert).
- kontrolu kod spremanja općeg računa da ako ugovor u posebnostima ima zaustavljen automatizam "Priprema ponude za prijevremeni zaključak/opomenu do:", tada se za potraživanja 
2D	NAKNADA ŠTETE ZBOG PRIJ. PRESTANKA UG. FL
2E	NAKNADA ŠTETE ZBOG RASKIDA UG. OL
2H	NAKNADA ZA IZMJENE PO UGOVORIMA 
neće moći spremiti opći račun i prikazati će se poruka.

Dodatne rutine testirajte i na korisnicima koji nemaju prava na promjenu statusa ugovora ili dodavanje dokumenta (NI).
Ako se obje dodatne rutine/akcije uvijek podešavaju zajedno, mogao bih za obje obrade podesiti da se pokreću u jednoj dodatnoj rutini (sada su dvije odvojene).

$SIGN
*/

Poštovana/i, 

oko evidencije tipa događaja opomena za dokumentaciju oko čega sam razgovarao s Janom Mraović, može se napraviti evidencija kako je definirano ranije u zahtjevu u statusima ugovora (kod izdavanja opomene se status ugovora mijenja u npr. 1. OPOMENA samo kad je status BEZ POSEBNOSTI dok kada je u ostalim statusima onda ne dolazi do promjene statusa ugovora).

Dorade bi bile:
- kreiranje novog statusa ugovora na kojemu će se evidentirati posebnost/zaustavljanje opomena za dokumentaciju => PODEŠENO Ne pripremaj opomene za dokumentaciju 
- programiranje dodatne rutine koja će kopirati status ugovora na sve aktivne ugovore partnera  => NAPRAVIO
- kreiranje novog predloška za posebnosti ugovora => kod dodavanja posebnosti na ugovor će se automatski podesiti status ugovora (ako se tako potvrdi na pitanje), ali kod kopiranja posebnosti na sve aktivne ugovore partnera, neće se kopirati status ugovora za opomene za dokumentaciju  pa će se zato raditi dodatna rutina u natuknici iznad => NAPRAVIO
- kreiranje dokumenta "NI – Nema interkalarnih" => NAPRAVIO 
- programiranje dodatne rutina koja bi klonirala dokument "NI – Nema interkalarnih" na sve aktivne ugovore partnera => NAPAVIO
- programiranje kontrola kod izdavanja općih računa prema zahtjevu

U privitku vam šaljemo ponudu za doradu prema zahtjevu.

Dorada 
- programiranje opcije obračuna interkalarnih kamata da se isključuju ugovori s dokumentom "NI – Nema interkalarnih"  => PODEŠENO
će biti naplaćena u sklopu zahtjeva "2427- Implementacija Datuma povrata - primjena na ugovore".
