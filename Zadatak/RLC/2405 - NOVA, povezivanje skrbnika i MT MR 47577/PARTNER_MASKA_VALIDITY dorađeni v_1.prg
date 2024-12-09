LOCAL loForm, lnI, lcCountry, llPerson, lcStavek1, lcDefault_trr, lcDefault_trr_db, llVrni, lcE, llVrni1, llVrniF, llVrniP, llVrniOIB, lnOdg, lcStavIBAN, llVrniIBAN, lnTestIBAN1, lnTestIBAN2, lnTestIBAN3

loForm = NULL
FOR lnI = 1 TO _Screen.FormCount
	IF UPPER(_Screen.Forms(lnI).Name) == UPPER("frmPartner_maska") THEN
		loForm = _Screen.Forms(lnI)
		EXIT
	ENDIF
NEXT
IF ISNULL(loForm) THEN
	RETURN
ENDIF

lcE = CHR(13) + CHR(10)


**lcCountry = ALLTRIM(GF_LOOKUP("poste.drzava", partner.id_poste_sed, "poste.id_poste"))
**llPerson = IIF(loForm.vrst_ose_sifra = "FO", .T., .F.)
lcStavek1 = ""
llVrni = .T.

** TRR1: preverja transakcijski račun in banko (polje default_trr) - za vse države
IF !ISNULL(partner.zr1) AND !EMPTY(ALLTRIM(partner.zr1)) AND (ISNULL(partner.ban_zr) OR EMPTY(ALLTRIM(partner.ban_zr)))
	llVrni = .F.
	lcStavek1 = lcStavek1 + "Unesite šifru banke kod tekućeg računa 1." + lcE
ENDIF
** TRR1 :preverja transakcijski račun, če se prvi del ujema z predpono od banke (polje default_trr) - za vse države
** MR 39995, 28.03.2018, g_dejank - dodano da se provjera odrađuje samo za račune sa HR prefixom
IF !ISNULL(partner.ban_zr) AND !EMPTY(ALLTRIM(partner.ban_zr)) AND LEFT(ALLTRIM(partner.ban_zr),2) = "HR"
	lcDefault_trr = STRTRAN(STRTRAN(partner.zr1, "-", ""), " ", "")
	lcDefault_trr_db = ALLTRIM(GF_LOOKUP("ban_sdk.default_trr", ALLTRIM(partner.ban_zr), "ban_sdk.id_sdk"))
	IF EMPTY(lcDefault_trr_db) OR !(lcDefault_trr_db == SUBSTR(lcDefault_trr, 5, LEN(lcDefault_trr_db)))
		llVrni = .F.
		lcStavek1 = lcStavek1 + "Tekući račun 1 se ne slaže sa šifrom banke." + lcE
	ENDIF
ENDIF

** TRR2: preverja transakcijski račun in banko (polje default_trr) - za vse države
IF !ISNULL(partner.tr1) AND !EMPTY(ALLTRIM(partner.tr1)) AND (ISNULL(partner.ban_tr1) OR EMPTY(ALLTRIM(partner.ban_tr1)))
	llVrni = .F.
	lcStavek1 = lcStavek1 + "Unesite šifru banke kod tekućeg računa 2." + lcE
ENDIF
** TRR2: preverja transakcijski račun, če se prvi del ujema z predpono od banke (polje default_trr) - za vse države
** MR 39995, 28.03.2018, g_dejank - dodano da se provjera odrađuje samo za račune sa HR prefixom
IF !ISNULL(partner.ban_tr1) AND !EMPTY(ALLTRIM(partner.ban_tr1)) AND LEFT(ALLTRIM(partner.ban_tr1),2) = "HR"
	lcDefault_trr = STRTRAN(STRTRAN(partner.tr1, "-", ""), " ", "")
	lcDefault_trr_db = ALLTRIM(GF_LOOKUP("ban_sdk.default_trr", ALLTRIM(partner.ban_tr1), "ban_sdk.id_sdk"))
	IF EMPTY(lcDefault_trr_db) OR !(lcDefault_trr_db == SUBSTR(lcDefault_trr, 5, LEN(lcDefault_trr_db)))
		llVrni = .F.
		lcStavek1 = lcStavek1 + "Tekući račun 2 se ne slaže sa šifrom banke." + lcE
	ENDIF
ENDIF

** TRR3: preverja transakcijski račun in banko (polje default_trr) - za vse države
IF !ISNULL(partner.tr2) AND !EMPTY(ALLTRIM(partner.tr2)) AND (ISNULL(partner.ban_tr2) OR EMPTY(ALLTRIM(partner.ban_tr2)))
	llVrni = .F.
	lcStavek1 = lcStavek1 + "Unesite šifru banke kod tekoćeg računa 3." + lcE
ENDIF
** TRR3: preverja transakcijski račun, če se prvi del ujema z predpono od banke (polje default_trr) - za vse države
** MR 39995, 28.03.2018, g_dejank - dodano da se provjera odrađuje samo za račune sa HR prefixom
IF !ISNULL(partner.ban_tr2) AND !EMPTY(ALLTRIM(partner.ban_tr2)) AND LEFT(ALLTRIM(partner.ban_tr2),2) = 'HR'
	lcDefault_trr = STRTRAN(STRTRAN(partner.tr2, "-", ""), " ", "")
	lcDefault_trr_db = ALLTRIM(GF_LOOKUP("ban_sdk.default_trr", partner.ban_tr2, "ban_sdk.id_sdk"))
	IF EMPTY(lcDefault_trr_db) OR !(lcDefault_trr_db == SUBSTR(lcDefault_trr, 5, LEN(lcDefault_trr_db)))
		llVrni = .F.
		lcStavek1 = lcStavek1 + "Tekući račun 3 se ne slaže sa šifrom banke." + lcE
	ENDIF
ENDIF

IF llVrni = .F.
	REPLACE ni_napaka WITH llVrni IN cur_extfunc_error
	POZOR(lcStavek1)
ENDIF

**POČETAK POROVJERE IBAN-a
lcStavIBAN = ''
llVrniIBAN = .T.

**Provjera ispravno unšenog IBAN-a ZR1
** TZR1: Provjera da li je unešeni IBAN ispravan
** MR 39995, 28.03.2018, g_dejank - dodano da se provjera odrađuje samo za račune sa HR prefixom
IF !ISNULL(partner.zr1) AND !EMPTY(ALLTRIM(partner.zr1)) AND LEFT(ALLTRIM(partner.zr1),2) = 'HR'
	lnTestIBAN1 = GF_SQLExecScalarNull("select dbo.gfn_CheckIBAN_HR("+GF_QuotedStr(ALLT(partner.zr1))+")")
	IF lnTestIBAN1 = 0
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "Prema kontrolnom izračunu IBAN u broju tekućeg računa 1 nije ispravan!" + lcE
	ENDIF
	IF lnTestIBAN1 = 2
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "IBAN u broju tekućeg računa 1 nije ispravne dužine!" + lcE
	ENDIF
	IF lnTestIBAN1 = 3
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "IBAN u broju tekućeg računa 1 nije ispravno unešen sa početnom oznakom HR!" + lcE
	ENDIF
ENDIF

**Provjera ispravno unšenog IBAN-a TR1
** TTR1: Provjera da li je unešeni IBAN ispravan
** MR 39995, 28.03.2018, g_dejank - dodano da se provjera odrađuje samo za račune sa HR prefixom
IF !ISNULL(partner.tr1) AND !EMPTY(ALLTRIM(partner.tr1)) AND LEFT(ALLTRIM(partner.tr1),2) = 'HR'
	lnTestIBAN2 = GF_SQLExecScalarNull("select dbo.gfn_CheckIBAN_HR("+GF_QuotedStr(ALLT(partner.tr1))+")")
	IF lnTestIBAN2 = 0
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "Prema kontrolnom izračunu IBAN u broju tekućeg računa 2 nije ispravan!" + lcE
	ENDIF
	IF lnTestIBAN2 = 2
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "IBAN u broju tekućeg računa 2 nije ispravne dužine!" + lcE
	ENDIF
	IF lnTestIBAN2 = 3
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "IBAN u broju tekućeg računa 2 nije ispravno unešen sa početnom oznakom HR!" + lcE
	ENDIF
ENDIF

**Provjera ispravno unšenog IBAN-a TR2
** TTR2: Provjera da li je unešeni IBAN ispravan
** MR 39995, 28.03.2018, g_dejank - dodano da se provjera odrađuje samo za račune sa HR prefixom
IF !ISNULL(partner.tr2) AND !EMPTY(ALLTRIM(partner.tr2)) AND LEFT(ALLTRIM(partner.tr2),2) = 'HR'
	lnTestIBAN3 = GF_SQLExecScalarNull("select dbo.gfn_CheckIBAN_HR("+GF_QuotedStr(ALLT(partner.tr2))+")")
	IF lnTestIBAN3 = 0
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "Prema kontrolnom izračunu IBAN u broju tekućeg računa 3 nije ispravan!" + lcE
	ENDIF
	IF lnTestIBAN3 = 2
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "IBAN u broju tekućeg računa 3 nije ispravne dužine!" + lcE
	ENDIF
	IF lnTestIBAN3 = 3
		llVrniIBAN = .F.
		lcStavIBAN = lcStavIBAN + "IBAN u broju tekućeg računa 3 nije ispravno unešen sa početnom oznakom HR!" + lcE
	ENDIF
ENDIF

IF llVrniIBAN = .F.
	REPLACE ni_napaka WITH llVrniIBAN IN cur_extfunc_error
	POZOR(lcStavIBAN)
ENDIF
**KRAJ PROVJERE PODATAKA IBAN

IF ((left(partner.vr_osebe,1)="P" AND partner.p_oblika # "UD")  OR partner.vr_osebe ="SP")
replace dav_obv with .t. In partner
ENDIF

IF partner.vr_osebe ="FO" or partner.vr_osebe ="F1" or left(partner.vr_osebe,1)="B"
replace dav_obv with .f. In partner
ENDIF

**dodavanje kontrole za unos poreznog broja za vrste osoba FO i F1, i 
**dodavanje obavijesti za unos poreznog broja za vrste osoba FO i F1 veličine 13, a za ostale vr. osoba 8 karaktera

llVrni1= .t. 
llVrniF= .t.
llVrniP= .t. 
IF (partner.vr_osebe="FO" or partner.vr_osebe="F1")
    IF (empty(partner.dav_stev) or isnull(partner.dav_stev))
        llVrni1 = .f. 
    ELSE 
        IF len(allt(partner.dav_stev))!=11
            llVrniF = .f.
        ENDIF
	ENDIF
ELSE
    IF len(allt(partner.dav_stev))!=11
	    llVrniP = .f.
	ENDIF
ENDIF


IF llVrni1 = .f.
    REPLACE ni_napaka WITH llVrni1 IN cur_extfunc_error  
    POZOR("Obavezan je unos poreznog broja")
ENDIF

IF llVrniF = .f.  
    IF !POTRJENO("Porezni broj OIB za fizičke osobe treba biti dužine 11 karaktera! Da li želite spremiti podatke?")
	    REPLACE ni_napaka WITH llVrniF IN cur_extfunc_error
    ENDIF
ENDIF

IF llVrniP = .f.
    IF !POTRJENO("Porezni broj OIB za pravne osobe treba biti dužine 11 karaktera! Da li želite spremiti podatke?")
	    REPLACE ni_napaka WITH llVrniP IN cur_extfunc_error
    ENDIF
ENDIF

llVrniOIB = RF_CHECK_OIB(partner.dav_stev)

IF llVrniOIB=.f. AND llVrni1=.t. AND llVrniF=.t. AND llVrniP=.t.
	IF !POTRJENO("Porezni broj OIB je dužine 11 karaktera ali nije ispravan! Da li želite spremiti podatke?")
    REPLACE ni_napaka WITH llVrniOIB IN cur_extfunc_error
    ENDIF
ENDIF

IF ISNULL(partner.p_status) OR EMPTY(partner.p_status)
	replace p_status with '00' In partner
ENDIF

*********************************************
* 24.11.2021 g_tomislav MID 47577 - skrbnik 1 mora imati popunjenu kategoriju 4 (MT). Kategorija 4 mora postojati definiran kao id_strm u šifrantu Mjesta troška

lcId_skrbnik_1 = partner.skrbnik_1

IF !GF_NULLOREMPTY(lcId_skrbnik_1)
	TEXT TO lcSql NOSHOW
		select s1.kategorija4 
		from dbo.partner s1 
		inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT/kategorija4 postoji u dbo.STRM1 da tek onda ide
		where s1.id_kupca =
	ENDTEXT

	lcMT = allt(GF_SQLEXECScalarNull(lcSql +gf_quotedstr(lcId_skrbnik_1)))

	IF GF_NULLOREMPTY(lcMT) 
		POZOR("Skrbnik 1 (" +allt(lcId_skrbnik_1) +") nema unesenu Kategorija 4 (Mj.tr.)! Unos takvog Skrbnika 1 nije dozvoljen.")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF 
ENDIF

lcKategorija4 = partner.kategorija4

IF !GF_NULLOREMPTY(lcKategorija4)
	TEXT TO lcSql NOSHOW
		select id_strm from dbo.strm1 MT where MT.id_strm =  
	ENDTEXT

	lcMT2 = allt(GF_SQLEXECScalarNull(lcSql +gf_quotedstr(lcKategorija4)))

	IF GF_NULLOREMPTY(lcMT2) 
		POZOR("Unesena Kategorija 4 (Mj.tr.) ne postoji u šifrantu Mjesta troška! Potrebno je unijeti takvu šifru (" +allt(lcKategorija4) +") u šifrant Mjesta troška ili odabrati neku drugu odgovarajuću šifru za Kategoriju 4 (Mj.tr.).")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF 
ENDIF
*******END MID 47577***************************