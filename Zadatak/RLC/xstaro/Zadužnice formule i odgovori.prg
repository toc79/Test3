Zadužnica - Obična ZADUZ.DOC (na 4. mjesta)
ZADUZ_J1.DOC

Zadužnica - Obična za okvir                       
ZADUZ_FRAME.DOC

polni naz


Zadužnica - Izjava o suglasnosti ZAD_IZJ_2014_1.DOC

Zadužnica - Izjava o suglasnosti Jamac ZAD_IZJ_JAM_2014_1.DOC

naz_kr_kup

Poštovani, 
na ispisima 
'Zadužnica - Obična' (dva odvojena ispisa za primatelja i jamca) 
'Zadužnica - Obična za okvir' 
se naziv partnera povlači iz polja 'Potpuni naziv'. Možemo podesiti da za vrstu osobe 
F1	ZAPOSLENCI-GRUPA RBA
FO	FIZIČKE OSOBE, POTROŠAČI
da se ispisuje Ime pa Prezime.

Za ispise 
'Zadužnica - Izjava o suglasnosti' 
'Zadužnica - Izjava o suglasnosti Jamac' 
se naziv partnera povlači iz polja 'Kraći naziv'. Možemo podesiti kao i gore navedeno da se ispisuje Ime pa Prezime.
Dodatno, da li želite da se za sve ostale za naziv partnera povlači i dalje iz polja 'Kraći naziv' ili da podesimo povlačenje iz polja 'Potpuni naziv'?
U sklopu ove dorade ćemo napraviti oko brisanja praznih redova u donjem paragrafu. Zahtjev '1789 - Izjava o zapljeni dužnika (a 2 stranice)' bi zatvorili a dorade bi napravili po ovom zahtjevu. 

U prilogu vam šaljemo ponudu za navedeno. 

$SIGN

* ZAD_IZJ_2014_1
allt(partner.naz_kr_kup)

* novo
IIF(INLIST(partner.vr_osebe, "FO", "F1"), allt(partner.ime) +" " +allt(partner.priimek), allt(partner.naz_kr_kup))

*  ZADUZ
iif(partner.vr_osebe="SP",allt(partner.direktor)+" kao vlasnik obrta ","")+allt(partner.polni_naz)

*NOVO
iif(partner.vr_osebe="SP",allt(partner.direktor)+" kao vlasnik obrta ","")+IIF(INLIST(partner.vr_osebe, "FO", "F1"), allt(partner.ime) +" " +allt(partner.priimek), allt(partner.polni_naz))

*porok 1
IIF(EMPTY(_JAM.VLOGA) OR ISNULL(_JAM.VLOGA), iif(_DOD1.vr_osebe="SP",allt(_DOD1.direktor)+" kao vlasnik obrta ","")+ALLT(_DOD1.polni_naz),iif(_JAM.vr_osebe="SP",allt(_JAM.direktor)+" kao vlasnik obrta ","")+ALLT(_JAM.polni_naz))

*novo
IIF(EMPTY(_JAM.VLOGA) OR ISNULL(_JAM.VLOGA), iif(_DOD1.vr_osebe="SP",allt(_DOD1.direktor)+" kao vlasnik obrta ","")+IIF(INLIST(_DOD1.vr_osebe, "FO", "F1"), allt(GF_LOOKUP("partner.ime", _DOD1.id_kupca, "partner.id_kupca")) +" " +allt(GF_LOOKUP("partner.priimek", _DOD1.id_kupca, "partner.id_kupca")), ALLT(_DOD1.polni_naz)), iif(_JAM.vr_osebe="SP",allt(_JAM.direktor)+" kao vlasnik obrta ","")+IIF(INLIST(_JAM.vr_osebe, "FO", "F1"), allt(GF_LOOKUP("partner.ime", _JAM.id_kupca, "partner.id_kupca")) +" " +allt(GF_LOOKUP("partner.priimek", _JAM.id_kupca, "partner.id_kupca")), ALLT(_JAM.polni_naz)))

*porok 2
IIF(EMPTY(_JAM.VLOGA) OR ISNULL(_JAM.VLOGA),iif(_DOD2.vr_osebe="SP",allt(_DOD2.direktor)+" kao vlasnik obrta ","")+ALLT(_DOD2.polni_naz),iif(_DOD1.vr_osebe="SP",allt(_DOD1.direktor)+" kao vlasnik obrta ","")+ALLT(_DOD1.polni_naz))

* novo
IIF(EMPTY(_JAM.VLOGA) OR ISNULL(_JAM.VLOGA),iif(_DOD2.vr_osebe="SP",allt(_DOD2.direktor)+" kao vlasnik obrta ","")+IIF(INLIST(_DOD2.vr_osebe, "FO", "F1"), allt(GF_LOOKUP("partner.ime", _DOD2.id_kupca, "partner.id_kupca")) +" " +allt(GF_LOOKUP("partner.priimek", _DOD2.id_kupca, "partner.id_kupca")), ALLT(_DOD2.polni_naz)), iif(_DOD1.vr_osebe="SP", allt(_DOD1.direktor)+" kao vlasnik obrta ","")+IIF(INLIST(_DOD1.vr_osebe, "FO", "F1"), allt(GF_LOOKUP("partner.ime", _DOD1.id_kupca, "partner.id_kupca")) +" " +allt(GF_LOOKUP("partner.priimek", _DOD1.id_kupca, "partner.id_kupca")), ALLT(_DOD1.polni_naz)))

* porok 3
IIF(EMPTY(_JAM.VLOGA) OR ISNULL(_JAM.VLOGA), "",iif(_DOD2.vr_osebe="SP",allt(_DOD2.direktor)+" kao vlasnik obrta ","")+ALLT(_DOD2.polni_naz))

* novo
IIF(EMPTY(_JAM.VLOGA) OR ISNULL(_JAM.VLOGA), "",iif(_DOD2.vr_osebe="SP",allt(_DOD2.direktor)+" kao vlasnik obrta ","")+IIF(INLIST(_DOD2.vr_osebe, "FO", "F1"), allt(GF_LOOKUP("partner.ime", _DOD2.id_kupca, "partner.id_kupca")) +" " +allt(GF_LOOKUP("partner.priimek", _DOD2.id_kupca, "partner.id_kupca")), ALLT(_DOD2.polni_naz)))

* ZADZ_J1
iif(pog_poro.vr_osebe="SP",allt(pog_poro.direktor)+" kao vlasnik obrta ","")+allt(POG_PORO.polni_naz)

* novo
iif(pog_poro.vr_osebe="SP",allt(pog_poro.direktor)+" kao vlasnik obrta ","")+IIF(INLIST(POG_PORO.vr_osebe, "FO", "F1"), allt(GF_LOOKUP("partner.ime", POG_PORO.id_kupca, "partner.id_kupca")) +" " +allt(GF_LOOKUP("partner.priimek", POG_PORO.id_kupca, "partner.id_kupca")), allt(POG_PORO.polni_naz))


* ZAD_IZJ_JAM_2014_1
allt(pog_poro.naz_kr_kup)

* NOVO
IIF(INLIST(POG_PORO.vr_osebe, "FO", "F1"), allt(GF_LOOKUP("partner.ime", POG_PORO.id_kupca, "partner.id_kupca")) +" " +allt(GF_LOOKUP("partner.priimek", POG_PORO.id_kupca, "partner.id_kupca")), allt(pog_poro.naz_kr_kup))


* OKVIR
allt(_partner.polni_naz)

* NOVO
IIF(INLIST(_partner.vr_osebe, "FO", "F1"), allt(_partner.ime) +" " +allt(_partner.priimek), allt(_partner.polni_naz))