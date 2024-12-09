18.12.2017

'Ukoliko ne postupite u skladu s ovom obavijesti, biti ćemo prisiljeni naplatu izvšiti putem sredstava osiguranja plaćanja.'
PW:
za_opom.vr_osebe != "FO" AND lc_tipleas != "OZ" AND za_opom.nacin_leas != "OF"

druga
iif(lc_tipleas != "OZ", "Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja."+chr(10), "")+txt1

*NOVO ali ipak nije podešeno
'Ukoliko ne postupite u skladu s ovom obavijesti, biti ćemo prisiljeni naplatu izvšiti putem sredstava osiguranja plaćanja.'
PW:
! INLIST(za_opom.vr_osebe, "FO", "F1") AND lc_tipleas != "OZ"


iif(INLIST(za_opom.vr_osebe, "FO", "F1") AND lc_tipleas != "OZ", "Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja."+chr(10), "")+txt1



Razlika u ova dva primjera je u vrstama osobe. Kod primjera s produkcije je riječ o vrsti osobe FO (FIZIČKE OSOBE, POTROŠAČI) dok na testu o F1 (ZAPOSLENCI-GRUPA RBA).
Ja mogu podesiti da se ta rečenica ne prikazuje za vrstu osobe F1 ZAPOSLENCI-GRUPA RBA, ali moje je mišljenje da bi se s vremenom opet javio neki slučaj i te dvije rečenice bi se opet mogle pojaviti.


 se da bi 

Poštovani, 
na produkciji smo podesili 
1)  '(CA-VO) Ugovori koji ističu sa brojevima polica ' za OF tip leasinga - datum zadnje rate iz otplatnog plana (kao što je za OL).
2) Edoc podešavanje 
4. I) i II) ispise 
'Osiguranje - Interni dopis' .
DOPIS ZA REGISTRACIJU SSOFT  
ISPIS USPOREDBE SA SK 

Nisam podesio na produkciji ispis 
IV)  'TEKST OPOMENE BEZ TROŠKOVA OPOMENE'
iz razloga što prikaz obje rečenice nije povezan s hibridom nego o trenutnim podešavanjima (kakve su na produkciji i testu).
Razlika u ova dva primjera u prilogu je dakle u vrstama osobe. Kod primjera s produkcije je riječ o vrsti osobe FO (FIZIČKE OSOBE, POTROŠAČI) dok na testu o F1 (ZAPOSLENCI-GRUPA RBA), znači radi se o različitim primjerima  i rečenice se prikazuju prema uvjetima kako sam ih naveo u prijašnjim mailovima (tako da se ovaj slučaj može desiti i na produkciji, ali izgleda da do sada niste imali izdanu opomenu na vrstu osobe F1 (ZAPOSLENCI-GRUPA RBA). Ja mogu podesiti da se ta rečenica ne prikazuje za vrstu osobe F1 ZAPOSLENCI-GRUPA RBA, ali moje je mišljenje da bi se s vremenom opet javio neki slučaj i te dvije rečenice bi se opet mogle pojaviti. Pa je moj prijedlog da sada napravimo ispravnu logiku.

Kako mi niste točno definirali logiku koja bi se trebala primjenjivati, u jednom od vaših prošlih malova ste naveli 
 "2 vrste FO (fizičke osobe i djelatnici) i O1, NF, (bez troška po Odluci Uprave i zakupi). Prve u naslovu imaju riječ opomena, a druge obavijest." 
 pa bi ja tako podesio da se za vrste osobe FO i F1 u naslovu prikazuje riječ "OPOMENA", a za sve ostale riječ "OBAVIJEST".
 Isto i za ove dvije rečenice, da se  druga rečenica 
 "Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja."
 ispisuje za vrste osobe FO i F1, a prva rečenica za sve ostače.
 Da li sam dobro pretpostavio logiku ili bi još nešto trebalo uzeti u obzir?
 
 $SIGN


 


 
1.12.2017
Poštovani, 
oko rekapitulacije zahtjeva, prvo bih naveo što sam danas podesio (do sada nije bilo podešeno a bili ste prihvatili ponudu). 
Na testu sam podesio ispise prema zahtjevu: 
4. I) i II) 
'Osiguranje - Interni dopis' - može se testirati na ugovoru 54469/17.
DOPIS ZA REGISTRACIJU SSOFT  
ISPIS USPOREDBE SA SK 
IV)  'TEKST OPOMENE BEZ TROŠKOVA OPOMENE'
Molim provjeru na testu.

Napravljene dorade od ranije su sljedeće (naveo sam samo ono što će trebati podešavati na produkciji, dok ono što ste potvrdili da je u redu za hibrid bez dorada nisam naveo):
1) Podešavanje ispisa '(CA-VO) Ugovori koji ističu sa brojevima polica ' - potvrdili ste da je OK.
 
2) Oko edoc podešavanja, pronađena je jedna greška oko izračuna podatka 'iznos_rate'; riječ je o custom podatku u xml datoteci. Taj iznos se do sada izračunavao posebno samo za F1 i F2 tip leasinga (uzimao se podatak iz polja 'Za plaćanje HRK' s pregleda računa za rate), dok za ostale: F3, F4 i F5 nije, pa samo sada podesili da bude isti za sve navedene tipove financijskog leasinga. Za Hibrid je podešeno da se gleda kao za operativni leasing (tj. kao i do sada) zato što je riječ o ispisima. 
Podešavanje je napravljeno prvo samo na testu pa molim provjeru i potvrdu da li možemo isto podesiti na produkciji. 
-&GT ovo niste odgovorili pa molimo provjeru. Ovo podešavanje je neovisno od hibrida, te nakon potvrde možemo ga odmah napraviti na produkciji.
 
4) III) RAČUNI ZA RATE - BESKONAČNI je maknut na produkciji zato što ga ne koristite.






Poštovani, 
u prilogu vam šaljemo ponudu za doradu ispisa TEKST OPOMENE BEZ TROŠKOVA OPOMENE za 1. opomenu da se za hibrid prikazuje samo druga rečenica "Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.".

$SIGN


'Ukoliko ne postupite u skladu s ovom obavijesti, biti ćemo prisiljeni naplatu izvšiti putem sredstava osiguranja plaćanja.'
PW: 
za_opom.vr_osebe!='FO' and lc_tipleas!='OZ'

* NOVO
*PW: 
za_opom.vr_osebe != "FO" AND lc_tipleas != "OZ" AND za_opom.nacin_leas != "OF"



iif(lc_tipleas != "OZ", "Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja."+chr(10), "")+txt1



*STARO
Oko različitog teksta u naslovi ispisa tj. tekstu 'OBAVIJEST' ili 'OPOMENA', za 'OBAVIJEST' se ispisuje uvijek kada 
iif(lc_tipleas='OZ','OBAVIJEST','OPOMENA')+' ZA NEPLAĆENA POTRAŽIVANJA PO UGOVORU'

lc_tipleas
lookup(_nacinil2.tip_leas,za_opom.nacin_leas,_nacinil2.nacin_leas)

select rf_tip_pog(za_opom.nacin_leas) as tip_leas, za_opom.nacin_leas from za_opom group by za_opom.nacin_leas into cursor _nacinil2

O1 je uloga kontakta za pripremu opomena - 1. opomena klijentima bez troška  

'Ukoliko ne postupite u skladu s ovom obavijesti, biti ćemo prisiljeni naplatu izvšiti putem sredstava osiguranja plaćanja.'
PW:
za_opom.vr_osebe!='FO' and lc_tipleas!='OZ'

iif(lc_tipleas!='OZ','Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.'+chr(10),'')+txt1
txt1
'Opomena je pravovaljana bez pečata i potpisa jer je izrađena upotrebom informacijske tehnologije kao elektronička isprava, sukladno Zakonu o elektroničkoj ispravi.'


27.11.2017
Poštovani, 

4. I) i II) ponovio bih da na ispisima 
'Osiguranje - Interni dopis'
DOPIS ZA REGISTRACIJU SSOFT
ISPIS USPOREDBE SA SK
se na nekim mjestima NE koristi posebna funkcija za koju smo radili doradu navedenu u zahtjevu '1739 - HIBRID - ispisi' (s kojom smo "preslikali" podešavanja), pa se iz tog razloga podaci prikazuju kao takvi na testu za hibrid. Nakon podešavanja hibrida na produkciji, ti će ispisi prikazivati podatke kao što je sada na testu. 
Zbog navedenog je potrebno raditi doradu tih ispisa na način da se na njima podesi navedena posebna funkcija, pa molim provjeru i povratnu informaciju da li je potrebno raditi doradu (ponuda se odnosi na to) ili ne?

III) maknuli smo ispis 'RAČUNI ZA RATE - BESKONAČNI'

IV) oko 'TEKST OPOMENE BEZ TROŠKOVA OPOMENE', postavke očito ne mogu biti kako su bile tj. kako su trenutno (kako ste bili naveli), jer sada s postojećim postavkama za hibrid ne izlaze rečenice ispravno (izlaze dvije rečenice). Tako da je potrebna dorada/promjena postavki na ispisu.
Za hibrid za ispis 1. opomene je dakle onda potrebna samo dorada navedenog ispisa na način da se ispisuje samo druga rečenica -&GT primljeno na znanje.

Oko "2 vrste FO (fizičke osobe i djelatnici) i O1, NF, (bez troška po Odluci Uprave i zakupi). Prve u naslovu imaju riječ opomena, a druge obavijest." 
na navedenom ispisu 'TEKST OPOMENE BEZ TROŠKOVA OPOMENE' samo za 1. opomenu je podešeno da se u naslovu riječ 'OBAVIJEST' ispisuje za Zakup (NF, NO, PF i PO tip leasinga), neovisno o vrsti osobe, neovisno o pripremi opomena za O1 (kako ste bili naveli). Za ostale slučajeve se ispisuje 'OPOMENA' -&GT tako je podešeno na produkciji i testu.
Za 2. i 3. opomenu za ispis 'TEKST OPOMENE BEZ TROŠKOVA OPOMENE', navedena logika ne vrijedi, na njima se u naslovu riječ 'OPOMENA' uvijek.
S obzirom na navedeno, da li je to u redu ili je potrebno mijenjati logiku?

Ako postoje bilo kakvi nesporazumi i/ili se nešto neispravno ispisuje, predlažem da sada to ispravimo i napravimo odgovarajuće podešavanja (za hibrid i za ostale slučajeve).

Oko primjera 42368/13 koji ste priložili, na njemu se prikazuju rečenice prema logici koju sam naveo ranije (prva rečenica se ne ispisuje zato što je ovdje riječ o FO osobi), dok sam vas ja bio tražio primjer gdje se ispisuje drugačije od navedene logike. 

$SIGN


-- 21.11.2017.
Poštovani, 
 
a) 1) Na testu smo podesili '(CA-VO) Ugovori koji ističu sa brojevima polica ' kako se naveli, za OF tip leasinga -  datum zadnje rate iz otplatnog plana (kao što je za OL).
 
3) I) Pošto se navedena kontrola kod spremanja općeg računa više ne koristi, da li bi ju maknuli ili neka ostane?
 
4. I) i II) onda je potrebna dorada ispisa 
'Osiguranje - Interni dopis' 
DOPIS ZA REGISTRACIJU SSOFT  
ISPIS USPOREDBE SA SK 
-&GT u prilogu vam šaljemo ponudu.
 
III) Pošto ispis RAČUNI ZA RATE - BESKONAČNI ne koristite, da li bi ga maknuli ili neka ostane?

IV) Oko ispisa 1. opomene, točnije riječ je o ispisu 'TEKST OPOMENE BEZ TROŠKOVA OPOMENE', provjerio sam ugovor 42386/13 sukladno telefonskom razgovoru, te taj ugovor nema izdane opomene tako da sam vjerojatno krivo zapisao broj ugovora/primjera. Molim da pošaljete primjer ugovora (ili scan) gdje se ispisuje drugačije od logike koju sam naveo u prijašnjem mailu i koji ponovno dajem nadalje u tekstu:
ispis 'TEKST OPOMENE BEZ TROŠKOVA OPOMENE' ima dvije rečenice, prva: 
'Ukoliko ne postupite u skladu s ovom obavijesti, biti ćemo prisiljeni naplatu izvšiti putem sredstava osiguranja plaćanja.' koja se ispisuje za sve vrste osoba koje nisu FO (partner 020843 iz scana je F1 vrsta osobe) i za tipove financiranja koji nisu Zakup (NF, NO, PF i PO). 
i druga: 
'Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.' koja se ispisuje za sve tipove financiranja koji nisu Zakup. 

S obzirom da ipak rečenice nisu skroz identične, molimo da nam definirate konačni izgled rečenice i logiku prikaza. 
Molim provjeru i povratnu informaciju.
Za usporedbu, na ispisu 'RAČUN ZA TROŠKOVE OPOMENA' se uvijek prikazuje rečenica 'Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.' 


b) oko upita "ne znam da li se automatski pokupe u B2 tabele ovi koji imaju oznaku "T" u koloni Koristi se za B2" - dobili smo odgovor od kolega iz Slovenije da je odgovor DA. 

Tomislav Krnjak 
Održavanje / Support 

Gemicro d.o.o. 
Nova cesta 83, HR-10000 Zagreb, Hrvatska 
T: +385 (0)1 3688983 
F: +385 (0)1 3688979 
www.gemicro.hr




 
 
 Oko 1. opomene sam odgovorio
 
 
 BEZOPOMIN1
 
 'Ukoliko ne postupite u skladu s ovom obavijesti, biti ćemo prisiljeni naplatu izvšiti putem sredstava osiguranja plaćanja.'
 PW:
 za_opom.vr_osebe!='FO' and lc_tipleas!='OZ'
 
 select rf_tip_pog(za_opom.nacin_leas) as tip_leas, za_opom.nacin_leas from za_opom group by za_opom.nacin_leas into cursor _nacinil2
 
 iif(lc_tipleas!='OZ','Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.'+chr(10),'')+txt1
 
 lc_tipleas  
 lookup(_nacinil2.tip_leas,za_opom.nacin_leas,_nacinil2.nacin_leas)
 
 txt1
 'Opomena je pravovaljana bez pečata i potpisa jer je izrađena upotrebom informacijske tehnologije kao elektronička isprava, sukladno Zakonu o elektroničkoj ispravi.'
 
 
 




Poštovani, 
a) 1) Kriterij pretrage 'Datum isteka veći od' uzima u obzir da li se radi o financijskom ili operativnom leasingu tako će se za se OL tipove ugovora uspoređivati s datumom zadnje rate iz plana otplate, a za sve ostale tipove tj. ugovore FL će se uspoređivati s podatkom 'Datum dosp. otkupa' s pregleda obavijesti o otkupu.

3) Provjerili smo sve kontrole te je situacija sljedeća:

I) Na masci kod unosa/popravka općeg računa kontrola kod spremanja općeg računa (LE | Ispisi | Opći računi), za OL i sada Hibrid u slučaju potraživanja 1L POSEBAN POREZ NA MOTORNA VOZILA će se prikazati da "Za OL tip leasinga nije dozvoljeno korištenje potraživanja POSEBAN POREZ NA MV!"

II) Na masci za unos/popravak neaktivnog ugovora kontrola kod spremanja, za opće uvjete i strategiju reprograma se Hibrid gleda kao OL.

III) Kod unosa novog ugovora nakon unosa broja ponude se na masci popune opći uvjeti i strategija reprograma, Hibrid se gleda kao OL.

IV) Na kontrolama na kalkulaciji (kod dodavanja nove ponude i kontrola nakon spremanja: "Kalkulacija OL nije udovoljila provjeri tipa financiranja..."), Hibrid se trenutno gleda kao financijski leasing -> to ste potvrdili da je OK.

Dodajem još jednu novu točku oko ispisa: 
4. I) Na word ispisu 'Osiguranje - Interni dopis' provjeriti izračun stavke 
"•	Osigurana svota: "
sada za fizičku osobu ili za ugovor FL i Hibird i za vrstu opreme koja ima tekst 'OV' u posebnom šifrantu 'OSIG_PONUDA' u polju 'Znakovna vrijednost', se prikazuje vrijednost s PDVom, za sve ostale je vrijednost neto.

II) Za stimulsoft ispis DOPIS ZA REGISTRACIJU SSOFT se za kandidate koji će se ispisati (između ostalih uvjeta) uzimaju svi ugovori OL, dok za FL ugovore (i Hibrid) samo ako imaju budućih rata, gdje se Hibrid znači gleda kao FL. 

III) Također molimo da provjerite direktne ispise: 
AMORTIZACIJSKI PLAN (LE | Ugovor | Izračun financiranja)
KALKULACIJA
RAČUNI ZA RATE - BESKONAČNI (LE | Ispisi | Obavijesti/računi za rate | Računi za rate)
ISPIS USPOREDBE SA SK
PLAN OTPLATE (LE | Ugovor | Mapa ugovora)
OBAVIJEST JAMCU O OPOMENI (3 kom) (LE | Ispisi | Opomene | Obavijesti za neplaćena potraživanja)
RAČUN ZA TROŠKOVE OPOMENA (3 kom) (LE | Ispisi | Opomene | 1.opomena)
TEKST OPOMENE BEZ TROŠKOVA OPOMENE (3 kom) (LE | Ispisi | Opomene | Arhiv opomena)
jer se na njima na nekim mjestima ne koristi posebna "funkcija" za koju smo radili doradu navedenu u zahtjevu 1739 - HIBRID - ispisi.

$SIGN

 
Pozdrav, 
testirali smo proceduru tsp_check_string_occurrences_in_nova te bi predložili da se doda provjera i za dbo.REPORT_VARIABLES za polje FORMULA.

Također može se razmisliti da se za dbo.PRINT_SELECTION dodaju još i polja REP_VAR, REP_SCOPE, CODE_VALID. Za njih je mala vjerojatnost da će sadržavati neki dio ključne riječi, ali ta mogućnost ipak postoji.

 select REP_VAR, REP_SCOPE, CODE_VALID, * from PRINT_SELECTION where REP_VAR like '%tip_knjizenja%' OR REP_SCOPE like '%tip_knjizenja%' OR CODE_VALID like '%tip_knjizenja%'
 
 
 tsp_check_string_occurrences_in_nova 'grp_Prepare_st_dok_ZobrCalculation'
NE PROLAZI KROZ 
- dbo.REPORT_VARIABLES u polju FORMULA
select * from report_variables where FORMULA like '%tip_knjizenja%'
- WORD -> da li se FORMULA iz dbo.REPORT_VARIABLES koristi na ispisu
- FRX -> to se analizira u REPORT_COPY
- dbo.PRINT_SELECTION možda dodati još za polja REP_VAR, REP_SCOPE, CODE_VALID
select REP_VAR, REP_SCOPE, CODE_VALID, * from PRINT_SELECTION where REP_VAR like '%RF_TIP_POG%' OR REP_SCOPE like '%RF_TIP_POG%' OR CODE_VALID like '%RF_TIP_POG%'
 
 

*RF_TIP_POG
1. FAKTURE_MASKA_PREVERI_PODATKE      

local lcNacinLeas, lcTipLeas
lcNacinLeas = GF_LOOKUP('pogodba.nacin_leas',fakture.id_cont,'pogodba.id_cont')
lcTipLeas = RF_TIP_POG(lcNacinLeas)

IF lcNacinLeas # 'OP' and fakture.id_terj = '27'
	POZOR("Samo za Ugovore tipa OP izdaje se potraživanja 27!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

IF lcNacinLeas # 'OJ' and fakture.id_terj = '28'
	POZOR("Samo za Ugovore tipa OJ izdaje se potraživanja 28!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

IF lcTipLeas = 'OL' And fakture.id_terj = '1L' THEN
	POZOR("Za OL tip leasinga nije dozvoljeno korištenje potraživanja POSEBAN POREZ NA MV!")

	IF !POTRJENO("Da li unatoč upozorenju želite ispostaviti račun ?")
	  SELECT cur_extfunc_error
	  REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF

IF at(lcNacinLeas, 'NF, NO, PF, PO')=0 and fakture.id_terj = '62'
	POZOR("Samo za Ugovore tipa NF, NO, PF, PO izdaje se potraživanja 62!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF

3) I) Na masci kod unosa/popravka općeg računa, kontrola kod spremanja općeg računa (LE | Ispisi | Opći računi)
Za OL i sada Hibrid u slučaju potraživanja 1L POSEBAN POREZ NA MOTORNA VOZILA će se prikazati da "Za OL tip leasinga nije dozvoljeno korištenje potraživanja POSEBAN POREZ NA MV!"
                                                                  
2. POGODBA_MASKA_PREVERI_PODATKE                                                                       
local loForm, lcSQL, lcSQL1, lcSQL2

loForm = GF_GetFormObject("frmPOGODBA_MASKA") 
lcStariAlias = ALIAS()
*********************************************************** 
* 24.08.2016 g_tomislav - dorada MR 36207
* procedura mora biti na vrhu zato jer RETURN od nižih provjera prekida izvršenje doljnjih dijelova koda u slueaju da se dva puta klikne na save. To bi trebalo pooraviti.
TEXT TO lcSQL NOSHOW 
Select a.dat_nasl_vred
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
AND a.id_kupca = 
ENDTEXT 

TEXT TO lcSQL1 NOSHOW 
Select CAST(count(*) as bit) as ima
From dbo.ss_dogodek
where id_tip_dog = '08' and ID_KUPCA ={0} 
ENDTEXT 

**and ID_CONT = {1}

TEXT TO lcSQL2 NOSHOW 
Select a.ext_id, a.dat_eval, a.dat_nasl_vred, cast('20170425' as datetime) as limit_date
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND a.id_kupca = {0} 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
ENDTEXT 

ldDatEvalZ = GF_SQLExecScalarNull(lcSQL + GF_QuotedStr(pogodba.id_kupca)) 

IF loForm.tip_vnosne_maske # 1 AND !GF_NULLOREMPTY(pogodba.dat_podpisa) AND GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos podatka 'Datum potpisa od strane klijenta' nije dozvoljen zato jer partner nema važeae ZSPNFT vrednovanje."+chr(13)+"Potrebno dodjeliti ocjenu rizika klijenta!") 
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	IF !EMPTY(lcStariAlias) THEN
	 SELECT (lcStariAlias)
	ENDIF
	RETURN .F. 
ENDIF 

IF loForm.tip_vnosne_maske = 1 AND GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos ugovora nije moguć zato jer partner nema važeće ZSPNFT vrednovanje."+chr(13)+"Potrebno dodjeliti ocjenu rizika klijenta!") 
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	IF !EMPTY(lcStariAlias) THEN
	 SELECT (lcStariAlias)
	ENDIF

	RETURN .F. 
ENDIF 
***********************************************************

***********************************************************************************
*** Popravak općih uvjeta prije provjere RLC prijava 1038 *************************
*** provjera općih uvjeta MID 20434, kada se mjenjaju opći uvjeti treba zamijeniti i default values
* 15.03.2017 g_tomislav - dorada Opći uvjeti MR 37651 
***********************************************************************************
local lcTip_leas, lcVr_osebe, lcSpl_pog01, lcSpl_pog02, lcPogoj1

lcTip_leas = RF_TIP_POG(pogodba.nacin_leas)
lcVr_osebe = GF_LOOKUP("partner.vr_osebe",pogodba.id_kupca,"partner.id_kupca")
GF_SQLEXEC("SELECT id_key, value FROM dbo.gfn_g_register('RLC_OPCI_UVJETI') WHERE neaktiven = 0", "_ef_opci_uvijeti")
lcSpl_pog01 = ALLT(LOOK(_ef_opci_uvijeti.value, "01", _ef_opci_uvijeti.id_key))
lcSpl_pog02 = ALLT(LOOK(_ef_opci_uvijeti.value, "02", _ef_opci_uvijeti.id_key))

IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas == 'F1'
	IF pogodba.spl_pog != lcSpl_pog01 THEN 
		REPLACE pogodba.spl_pog WITH lcSpl_pog01 IN pogodba 
	ENDIF
ELSE
	IF pogodba.spl_pog != lcSpl_pog02 THEN
		REPLACE pogodba.spl_pog WITH lcSpl_pog02 IN pogodba 
	ENDIF
ENDIF

USE IN _ef_opci_uvijeti

if used('_ef_partner_list') then
	return
endif
* Komentar: ako se u gornjoj provjeri setira, da li je uopće potrebna donja provjera ?
TEXT TO lcPogoj1 NOSHOW
	select * from partner p
		where p.id_kupca = '{0}'
ENDTEXT
lcPogoj1 = STRTRAN(lcPogoj1, '{0}', pogodba.id_kupca)
gf_sqlexec(lcPogoj1,"_ef_partner_list")
IF ((_ef_partner_list.vr_osebe  == 'FO' or _ef_partner_list.vr_osebe == 'F1') and lcTip_leas == 'F1') 
	IF pogodba.spl_pog != lcSpl_pog01
		if !potrjeno('Nije unešena odgovarajuća vrijednost općih uvjeta! Za tip financiranja F1 i fizičke osobe opći uvjeti trebaju biti '+lcSpl_pog01+', a za sve druge '+lcSpl_pog02+'. Želite li spremiti takav ugovor?')
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		ENDIF
	ENDIF
ELSE
	IF pogodba.spl_pog != lcSpl_pog02
		IF !potrjeno('Nije unešena odgovarajuća vrijednost općih uvjeta! Za tip financiranja F1 i fizičke osobe opći uvjeti trebaju biti '+lcSpl_pog01+', a za sve druge '+lcSpl_pog02+'. Želite li spremiti takav ugovor?')
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		ENDIF
	ENDIF
ENDIF

IF USED("_ef_partner_list")
	USE IN _ef_partner_list
ENDIF
************************** KRAJ PROVJERE *****************************************

***********************************************************************************
* 14.06.2017 g_tomislav MR 36135 - Rind strategije; Sa promjenom kontrole na ovom mjestu, potrebno je promijeniti i POGODBA_MASKA_SET_DEF_VALUES
***********************************************************************************
llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, pogodba.id_rtip, rtip.id_rtip)

IF llfix_dat_rpg 
	LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnStrategija10, lnStrategija25, lnDanUMjesecu, lnId_rind_strategije, ldRind_datum, lnRind_datumMonth, lnRind_datumYear, lcNoviDan, lnRind_dat_next
	lcid_kupca = pogodba.id_kupca
	lcTip_leas = RF_TIP_POG(pogodba.nacin_leas)
	lnObdobje_mes = 12/LOOKUP(obdobja_lookup.obnaleto, LOOKUP(rtip.id_obdrep, pogodba.id_rtip, rtip.id_rtip), obdobja_lookup.id_obd)
	GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
	lcVr_osebe = _ef_vr_osebe.vr_osebe
	USE IN _ef_vr_osebe
	
	lnStrategija10 = 10
	lnStrategija25 = 25
	
	IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas = 'F1' && kao na općim uvjetima
		lnDanUMjesecu = lnStrategija10
	ELSE 
		lnDanUMjesecu = lnStrategija25
	ENDIF

	lnId_rind_strategije = LOOKUP(rind_strategije.id_rind_strategije, lnDanUMjesecu, rind_strategije.odmik)		
	
	ldRind_datum = pogodba.rind_datum
	lnRind_datumMonth = MONTH(ldRind_datum)
	lnRind_datumYear = YEAR(ldRind_datum)
	lcNoviDan = CTOD(ALLTRIM(STR(lnDanUMjesecu)+"/"+ALLTRIM(STR(lnRind_datumMonth))+"/"+ALLTRIM(STR(lnRind_datumYear))))
	lnRind_dat_next = GOMONTH(lcNoviDan, lnObdobje_mes)
	
	IF pogodba.id_rind_strategije != lnId_rind_strategije OR pogodba.Rind_dat_next != lnRind_dat_next
		if !potrjeno("Nije unešena odgovarajuća vrijednost Strategije reprograma. Želite li spremiti takav ugovor?")
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		ENDIF
		*REPLACE pogodba.id_rind_strategije WITH lnId_rind_strategije IN pogodba
		*REPLACE pogodba.Rind_dat_next WITH lnRind_dat_next IN pogodba
		*Pozor("Strategija reprograma je postavljena na "+ALLT(STR(lnDanUMjesecu))+". dan u mjesecu!")
	ENDIF
ENDIF
* KRAJ Rind strategije
*********************

****SLIJEDEĆA PROVJERA UVIJEK MORA BITI ZADNJA************************************
IF loForm.tip_vnosne_maske # 1 then

	lcdat_podpisa = pogodba.dat_podpisa
	lcdat_podpisa1 = _pogodba.dat_podpisa
	lcSQL2 = strtran(lcSQL2, "{0}", gf_quotedstr(pogodba.id_kupca))
	GF_SQLEXEC(lcSQL2, "_pe")

	IF ((gf_nullorempty(lcdat_podpisa1) and !gf_nullorempty(lcdat_podpisa)) or (lcdat_podpisa1 # lcdat_podpisa)) and _pe.dat_eval >= _pe.limit_date then

		lcSQL1 = strtran(lcSQL1, "{0}", gf_quotedstr(pogodba.id_kupca))
		**lcSQL1 = strtran(lcSQL1, "{1}", allt(trans(pogodba.id_cont)))
		llima = GF_SQLExecScalarNull(lcSQL1) 
		if llima = .f. then
			**ako je odgovor NE ne može snimiti ugovora
			**ako je odgovor DA snimi se ugovor i treba pokrenuti novi proces za partnera sa oznakom da nije bio nazočan na potpisu.

			llpotrjeno =POTRJENO("Za partnera ne postoji unesen događaj 'Orginali -Izjava i Identifikacijska isprava'. Želite li svejedno snimiti ugovor? Ukoliko odgovorite sa DA snimit će se ugovor i pokrenuti nova instanca ZSPNFT procesa.")
			if llpotrjeno = .f. then
					POZOR("Unos ugovora nije moguć dok se ne unese događaj 'Orginali -Izjava i Identifikacijska isprava'")
					SELECT cur_extfunc_error
					REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
					IF !EMPTY(lcStariAlias) THEN
					 SELECT (lcStariAlias)
					ENDIF

					RETURN .F. 
			endif

			if llpotrjeno = .t. then
					***izvući zadnji ext_id iz p_eval
					
					lcext_id = altt(_p_eval.ext_id)
					lcXml = "<zspnft_clone_instance_starter xmlns='urn:gmi:nova:integration'>" + gcE
					lcXml = lcXml + "<clone_instance_data>" +gcE
					if gf_nullorempty(lcext_id) then
						lcXml = lcXml + GF_CreateNode("instance_id", -1, "I", 1) +gcE
					else
						lcXml = lcXml + GF_CreateNode("instance_id", allt(lcext_id), "I", 1) +gcE
					endif
					lcXml = lcXml + GF_CreateNode("id_kupca", pogodba.id_kupca , "C", 1) +gcE
					lcxml = lcXml + "<fix_field_value>" + gcE
					lcxml = lcXml + "<name>customer_not_present</name>" + gcE
					lcxml = lcXml + "<value>true</value>" + gcE
					lcxml = lcXml + "</fix_field_value>" + gcE
					lcXml = lcXml + "</clone_instance_data>" +gcE
					lcXml = lcXml + "</zspnft_clone_instance_starter>"


					gf_processxml(lcXML, .f., .f.)
			endif
		endif
	endif
endif

IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF


************************** KRAJ PROVJERE *****************************************

**********************************************************************************
**PROVJERA UNOSA POREZ U MPC U ODNOSU NA STOPU POREZA U MPC NA PONUDI*************
**********************************************************************************
* LOCAL loForm, lcPogoj

* lcPogoj = ""
* loForm = NULL


* FOR lnI = 1 TO _Screen.FormCount
	* IF UPPER(_Screen.Forms(lnI).Name) == UPPER("frmPOGODBA_MASKA") THEN
	* loForm = _Screen.Forms(lnI)
* EXIT
* ENDIF
* NEXT

* IF ISNULL(loForm) THEN
	* RETURN
* ENDIF

* if used('_ponudba_list') then
	* return
* endif

* TEXT TO lcPogoj NOSHOW
	* select * from ponudba pon
		* where pon.id_pon = '{0}'
* ENDTEXT
* lcPogoj = STRTRAN(lcPogoj, '{0}', pogodba.id_pon)

* gf_sqlexec(lcPogoj,"_ponudba_list")
* &&select _test
* &&brow

* if len(alltrim(_ponudba_list.id_pon))>0 and pogodba.id_dav_op!=_ponudba_list.id_dav_op
	* if !potrjeno('Porez u MPC na ugovoru drugaeiji od Poreza u MPC unešenog na ponudi. Želite li spremiti takav ugovor?')
		* SELECT cur_extfunc_error
		* REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		* if used("_ponudba_list")
			* use in _ponudba_list
		* endif
	* endif
* endif
********************************************************** 

**********************************************************************************
**** MR 38358 g_mladens; RLHR Ticket 1752 - Unos ugovora, provjera za ROL*********
**********************************************************************************
IF loForm.tip_vnosne_maske = 1 THEN 
	IF !POTRJENO("Da li ste provjerili ROL?") THEN 
		RETURN .F.
	ENDIF
ENDIF
************************** KRAJ **************************************************
II) Na masci za unos/popravak neaktivnog ugovora, kontrola kod spremanja za opće uvjete i strategiju reprograma se Hibrid gleda kao OL.

3. POGODBA_MASKA_SET_DEF_VALUES   

REPLACE pogodba.rind_tgor WITH 0 IN pogodba 
REPLACE pogodba.rind_zahte WITH .F. IN pogodba 
REPLACE pogodba.opc_datzad WITH 0 IN pogodba

***********************************************************************************
* provjera općih uvjeta MID 20434, kada se mjenjaju opći uvjeti treba uz na ovom mjestu zamijeniti i u PREVERI_PODATKE
* 15.03.2017 g_tomislav - dorada Opći uvjeti MR 37651
***********************************************************************************

LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lcSpl_pog01, lcSpl_pog02
lcid_kupca = ponudba.id_kupca
lcTip_leas = RF_TIP_POG(ponudba.nacin_leas)
GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
GF_SQLEXEC("SELECT id_key, value FROM dbo.gfn_g_register('RLC_OPCI_UVJETI') WHERE neaktiven = 0", "_ef_opci_uvijeti")

lcVr_osebe = _ef_vr_osebe.vr_osebe
lcSpl_pog01 = ALLT(LOOK(_ef_opci_uvijeti.value, "01", _ef_opci_uvijeti.id_key))
lcSpl_pog02 = ALLT(LOOK(_ef_opci_uvijeti.value, "02", _ef_opci_uvijeti.id_key))
USE IN _ef_vr_osebe
USE IN _ef_opci_uvijeti

IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas = 'F1'
	REPLACE pogodba.spl_pog WITH lcSpl_pog01 IN pogodba 
ELSE
	REPLACE pogodba.spl_pog WITH lcSpl_pog02 IN pogodba 
ENDIF

* KRAJ OPĆI UVJETI
*********************

******* DOZVOLJENI BROJ KM ************
* 30.03.2017 g_tomislav - dorada MR 37674 i 37797, da se povlače s ponude
* 08.09.2017 g_barbarak - dorada MR 38852
LOCAL lnDovol_km, lnCena_dkm

lnDovol_km = ponudba.Dovol_km
lnCena_dkm = ponudba.Cena_dkm

IF lnDovol_km = 0
	REPLACE pogodba.dovol_km WITH 25000 IN pogodba
ELSE
	REPLACE pogodba.dovol_km WITH lndovol_km IN pogodba
ENDIF

IF lncena_dkm = 0.00
	REPLACE pogodba.cena_dkm WITH 0.15 IN pogodba
ELSE
	REPLACE pogodba.cena_dkm WITH lncena_dkm IN pogodba
ENDIF

* KRAJ DOZVOLJENI BROJ KM 
**************************

*********************************************
* 16.05.2016 g_tomislav - MR 35121 
local lcId_odobrit 
lcId_odobrit = pogodba.id_odobrit

IF ! gf_nullorempty(lcId_odobrit) 
	GF_SQLEXEC("SELECT a.id_cont, a.id_odobrit FROM dbo.Odobrit a JOIN dbo.pogodba b ON a.id_odobrit=b.ID_ODOBRIT WHERE a.ID_ODOBRIT ="+gf_quotedstr(lcId_odobrit),"_ef_odobrit")
	select _ef_odobrit
	IF RECCOUNT() > 0
		pozor ('Za ovo odobrenje već postoji ugovor. Molim provjeru podataka!')
	ENDIF
	use in _ef_odobrit
ENDIF
*******END MR 35121**************************************
***********************************************************************************
* 14.06.2017 g_tomislav MR 36135 - Rind strategije; Sa promjenom kontrole na ovom mjestu, potrebno je promijeniti i POGODBA_MASKA_PREVERI PODATKE
***********************************************************************************
llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, ponudba.id_rtip, rtip.id_rtip)

IF llfix_dat_rpg 
	LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnStrategija10, lnStrategija25, lnDanUMjesecu, lnId_rind_strategije, ldRind_datum, lnRind_datumMonth, lnRind_datumYear, lcNoviDan, lnRind_dat_next
	lcid_kupca = ponudba.id_kupca
	lcTip_leas = RF_TIP_POG(ponudba.nacin_leas)
	lnObdobje_mes = 12/LOOKUP(obdobja_lookup.obnaleto, LOOKUP(rtip.id_obdrep, ponudba.id_rtip, rtip.id_rtip), obdobja_lookup.id_obd)
	GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
	lcVr_osebe = _ef_vr_osebe.vr_osebe
	USE IN _ef_vr_osebe
	
	lnStrategija10 = 10
	lnStrategija25 = 25
	
	IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1' OR ponudba.je_foseba) and lcTip_leas = 'F1' && kao na općim uvjetima
		lnDanUMjesecu = lnStrategija10
	ELSE 
		lnDanUMjesecu = lnStrategija25
	ENDIF
	
	lnId_rind_strategije = LOOKUP(rind_strategije.id_rind_strategije, lnDanUMjesecu, rind_strategije.odmik)
	
	ldRind_datum = ponudba.rind_datum
	lnRind_datumMonth = MONTH(ldRind_datum)
	lnRind_datumYear = YEAR(ldRind_datum)
	lcNoviDan = CTOD(ALLTRIM(STR(lnDanUMjesecu)+"/"+ALLTRIM(STR(lnRind_datumMonth))+"/"+ALLTRIM(STR(lnRind_datumYear))))
	lnRind_dat_next = GOMONTH(lcNoviDan, lnObdobje_mes)
		
	REPLACE pogodba.id_rind_strategije WITH lnId_rind_strategije IN pogodba
	REPLACE pogodba.Rind_dat_next WITH lnRind_dat_next IN pogodba
		
ENDIF
* KRAJ Rind strategije
*********************

III) Kod unosa novog ugovora nakon unosa broja ponude se na masci popne opći uvjeti i strategija reprograma te se Hibrid gleda kao OL.
                                                                     
4. PON_PRED_ODKUP_ID_POG_VALID                                                                         

LOCAL loForm

loForm = NULL
FOR lnI = 1 TO _Screen.FormCount
	IF UPPER(_Screen.Forms(lnI).Name) == UPPER("pon_pred_odkup") THEN
	loForm = _Screen.Forms(lnI)
EXIT
ENDIF
NEXT

IF ISNULL(loForm) THEN
	RETURN
ENDIF


*** POZIV KALKULKACIJE NAPLAĆENOG PPMVa I PREOSTALOG IZNOSA ZA NAPLATITI - POČETAK ***
* IF RF_TIP_POG(GF_LOOKUP('pogodba.nacin_leas', loForm.pgfPonudba.page1.txtid_pog.value, 'pogodba.id_pog'))='O' THEN
* local lcSqlx, lnId_cont, ldDatIzrPPMV, lnImaPPMV, lnImaDatum_reg 
* ldDatIzrPPMV = Date()
* lnId_cont = GF_LOOKUP('pogodba.id_cont', loForm.pgfPonudba.page1.txtid_pog.value, 'pogodba.id_pog')
* lnImaPPMV =  GF_SQLEXECScalar("select isnull(robresti_sit,0) from dbo.pogodba where id_cont="+allt(trans(lnId_cont)))
* lnImaDatum_reg = GF_SQLEXECScalar("select count(dat_1upor) as broj from dbo.zap_reg where dat_1upor IS NOT NULL and id_cont="+allt(trans(lnId_cont)))

* IF lnImaDatum_reg = 0 AND lnImaPPMV > 0 THEN
	* Obvesti("Pažnja! Ugovor ima PPMV ali u zapisniku nije unesen Datum prve upotrebe! Izračun PPMV-a nije moguć!")
	* loForm.Release
	* RETURN .f.
* ENDIF

* IF lnImaPPMV > 0 THEN
	* TEXT TO lcSqlx NOSHOW
		* exec dbo.grp_ExecuteExtFunc 'HR_SQL_OST_PPMV_KALK', {0}, {1}
	* ENDTEXT
	* lcSqlx = STRTRAN(STRTRAN(lcSQLx,"{0}", trans(lnId_cont)), "{1}", GF_QUOTEDSTR(DTOS(ldDatIzrPPMV)))
	* GF_SQLExec(lcSqlx,"ppmv_kalk")
	* loForm.pgfPonudba.page1.txtVracKaska.value = ppmv_kalk.Oslob_osnova_ppmv_dom

	* Select GF_LOOKUP('pogodba.id_pog', ppmv_kalk.id_cont, 'pogodba.id_cont') as Broj_ugovora, ;
	* dtoc(calc_date) as Datum_izračuna, ;
	* trans(Zac_ppmv_pog_dom, gccif) as Početni_iznos_PPMV_HRK, ;
	* trans(Fakt_ppmv_racout_dom+Fakt_ppmv_tec_raz_dom, gccif) as Naplaceni_PPMV_HRK, ;
	* Traj_upotrebe as Trajanje_upotrebe, ;
	* trans(Calc_preost_ppmv_dom, gccif) as Preostali_dio_PPMV_prema_tabeli, ;
	* trans(Stvar_preost_ppmv_dom, gccif) as Stvarni_preostali_iznos, ;
	* trans(Pdv_osnova_ppmv_dom, gccif) as Osnova_PPMV_za_oporezivanje, ;
	* trans(Oslob_osnova_ppmv_dom, gccif) as Oslobodeni_dio_PPMV ;
	* from ppmv_kalk
* ELSE 
*	 Return .f.
* ENDIF
* ENDIF
*** POZIV KALKULKACIJE NAPLAĆENOG PPMVa I PREOSTALOG IZNOSA ZA NAPLATITI - KRAJ ***

-> NEMA KONTROLE

5. PON_PRED_ODKUP_MASKA_CALC 

LOCAL loForm

loForm = GF_GetFormObject("PON_PRED_ODKUP")

**Kontrola za ugovore s PPMV-om**
**IF RF_TIP_POG(GF_LOOKUP('pogodba.nacin_leas', loForm.pgfPonudba.page1.txtid_pog.value, 'pogodba.id_pog'))='O' THEN

**local lnId_cont, lnImaPPMV, lnImaDatum_reg 
**lnId_cont = GF_LOOKUP('pogodba.id_cont', loForm.pgfPonudba.page1.txtid_pog.value, 'pogodba.id_pog')
**lnImaPPMV =  GF_SQLEXECScalar("select isnull(robresti_sit,0) from dbo.pogodba where id_cont="+allt(trans(lnId_cont)))
**lnImaDatum_reg = GF_SQLEXECScalar("select count(dat_1upor) as broj from dbo.zap_reg where dat_1upor IS NOT NULL and id_cont="+allt(trans(lnId_cont)))

**	IF lnImaDatum_reg = 0 AND lnImaPPMV > 0 THEN
**		Obvesti("Pažnja! Ugovor ima PPMV ali u zapisniku nije unesen Datum prve upotrebe! Izračun PPMV-a nije moguć!")
**		loForm.pgfPonudba.Page1.txtId_pog.Setfocus
**		REPLACE ni_napaka WITH .f. IN cur_extfunc_error
**		loForm.Release
**		RETURN .f.
**	ENDIF
**ENDIF
** KRAJ Kontrole za ugovore s PPMV-om**


FOR i = 1 TO _Screen.FormCount

	IF UPPER(_Screen.Forms(i).Name) == "PON_PRED_ODKUP" THEN
		loForm = _Screen.Forms(i)

		&& Provjera datuma ponude po MR 22954
		IF loForm.pgfPonudba.Page1.txtDatumPonudbe.value != DATE() THEN
			POZOR("Datum ponude ne smije biti različit od današnjeg!")
			loForm.pgfPonudba.Page1.txtDatumPonudbe.Setfocus
			REPLACE ni_napaka WITH .f. IN cur_extfunc_error
		ENDIF

		IF _Screen.Forms(i).pgfPonudba.Page1.txtDodTer.value <> 0 THEN
			LOCAL lcid_pog, lnOld, lnNew, lnOdg, lcVal, lnZrac, lnDej
			lcId_pog = loForm.pgfPonudba.Page1.txtId_pog.value

			&& Poziv funkcije koja priprema pregled troškova
			&& ARG. => IdCont, DatIzrac, ShowForm (.t./.f.), Id_tec, RazlikaBruto (.t./.f.)
			GF_SQLEXEC("select id_cont from pogodba where id_pog = "+gf_quotedstr(lcId_pog),"_POG")
			lnOld = loForm.pgfPonudba.Page1.txtDodTer.value
			lnNew = GF_PrometDodatniStroski(_pog.id_cont, date(), .F., 	loForm.pgfPonudba.Page1.lstTecaj.value,.F.)
			lcVal = loForm.pgfPonudba.Page1.txtValuta.value
			
			&& sumiranje diskontiranih stvarnih troškova
			SELECT _dejan
			GO TOP
			CALCULATE sum(znesek) TO lnZrac
			
			&& sumiranje diskontiranih prihodovanih predviđenih troškova
			SELECT _zarac
			GO TOP
			CALCULATE sum(znesek) TO lnDej
			
			&& sučeljavanje diskontiranih iznosa
			lnNew = lnZrac - lnDej
			
			&& pitaj korniska da li želiš neto sučeljeni iznos ili zadrži ponuđeni iznos
			IF loForm.pgfPonudba.Page1.txtDodTer.value != lnNew and potrjeno('Bruto iznos dodatnih troškova iznosi '+allt(trans(lnold,gccif))+' '+lcVal+', da li želite koristiti neto iznos ('+allt(trans(lnNew,gccif))+' '+lcVal+') dodatnih troškova kod izračuna ponude?') THEN
				loForm.pgfPonudba.Page1.txtDodTer.value = lnNew
			ENDIF

		ENDIF
	ENDIF

NEXT

-> NEMA KONTROLE

* TIP_KNJIZENJA
6. frmOcView	ISPIS IOS OBRASCA    

if !used("cursor_tecajnic") then 
      select * from tecajnic into cursor cursor_tecajnic 
endif

local lcid_oc_contract
lcid_oc_contract=cursor_report.id_oc_report
GF_SQLEXEC("Select a.*, a.ex_g1_davek+a.ex_g1_obresti as k960 From dbo.oc_contracts a where a.id_oc_report="+GF_QuotedStr(lcid_oc_contract),"odprt")

*GF_SQLEXEC("Select a.*, a.ex_k086-a.ex_k050-a.ex_kddv as k960 From dbo.oc_contracts a where a.id_oc_report="+GF_QuotedStr(lcid_oc_contract),"odprtf")

select id_cont, iif(ex_nacin_leas_tip_knjizenja="2",k960,k960-k960) as k960 from odprt into cursor odprtf

*GF_SQLEXEC("Select id_cont, sum(ex_g1_davek+ex_g1_obresti) as k960 From dbo.oc_contracts_future_details  where id_oc_report="+GF_QuotedStr(lcid_oc_contract)+ " group by id_cont","odprtf")

**dbo.oc_contracts_future_details a where 

*m.k086-m.k050-m.kddv

select cursor_claims
index on id_kupca+id_pog+id_tec tag tx11
set order to tx11
go top

GF_SQLEXEC("Select * From dbo.tecajnic","_tecajnic")

-> OK je

7. frmOcView	ISPIS USPOREDBE SA SK - stari   
-> NEAKTIVAN
                  
8. frmPogDashboard	Osiguranje - Interni dopis        

local lcid_cont, lcid_pon
lcid_cont=pogodba.id_cont
lcid_pon=pogodba.id_pon

TEXT TO lcSQL1 NOSHOW
Select a.id_obl_zav, a.opis
From dbo.dokument a 
inner join dbo.pogodba b on a.id_cont=b.id_cont 
inner join general_register c on c.id_register='RLC_LISTA_POLICA' and charindex(a.id_obl_zav,c.value)>0
where a.status_akt='A' and b.id_cont={0}
ENDTEXT

lcSQL1 = STRTRAN(lcSQL1, "{0}", TRANS(lcid_cont))
GF_SQLEXEC(lcSQL1,"_police")

TEXT TO lcSQL3 NOSHOW
select 
dbo.gfn_xchange('000',Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then p.neto*(1+(p.dav_vred_op/100))/*p.bruto*/ Else p.neto End, p.id_tec_n, p.dat_pon) as vrijednost_dom
from dbo.ponudba p
inner join dbo.general_register g on id_register = 'OSIG_PONUDA' AND 0 = g.neaktiven AND p.id_vrste = g.id_key 
inner join dbo.nacini_l nl on p.nacin_leas = nl.nacin_leas
where p.id_pon={0}
ENDTEXT

lcSQL3 = STRTRAN(lcSQL3, "{0}", TRANS(lcid_pon))
GF_SQLEXEC(lcSQL3,"_osiguranja")

IF RECCOUNT("_police")=0 THEN 
APPEND BLANK IN _police
ENDIF

GF_SQLEXEC("select * from ponudba where id_pon="+gf_quotedstr(lcid_pon),"_cur_ponudba")

Na word ispisu 'Osiguranje - Interni dopis' provjeriti izračun stavke 
"•	Osigurana svota: "
sada za fizičku osobu ili za ugovor FL i Hibird i za vrstu opreme koja ima tekst 'OV' u posebnom šifrantu 'OSIG_PONUDA' u polju 'Znakovna vrijednost', se prikazuje vrijednost s PDVom, za sve ostale je vrijednost neto.

9. za_regis_izpisd	DOPIS ZA REGISTRACIJU SSOFT              

private lnOdg, lcText, lnId_za_regis, lcFilter 

lnOdg = rf_msgbox("Pitanje","Želite li ispis svih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")

lcFilter = filter("za_regis")
lcFilter = iif(empty(lcFilter),".t.",lcFilter)

DO CASE 
	CASE lnOdg = 2	&& Trenutnega
		lnId_za_regis = za_regis.id_za_regis
		select * from za_regis where id_za_regis = lnId_za_regis into cursor rezultat1
	CASE lnOdg = 1	&& Vse
		select * from za_regis where &lcFilter into cursor rezultat1
	OTHERWISE
		RETURN .F.
ENDCASE

local lcSQL

TEXT TO lcSql NOSHOW
	SELECT a.id_za_regis
	FROM dbo.gfn_Za_regisSelection (getdate(), 0) a
	LEFT JOIN
		--podaci iz kasko polica
		(SELECT d.id_cont, d.id_master, MIN(d.zacetek) as zacetek, MAX(d.velja_do) as velja_do, MAX(d.konec) as kraj
		FROM dbo.dokument d
		WHERE d.id_obl_zav IN ('AK', 'BK', 'VK', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') 
		AND d.status_akt = 'A' 
		GROUP BY d.id_cont, d.id_master) d ON a.id_za_regis = d.id_master AND a.id_cont = d.id_cont
	LEFT JOIN
		--podaci iz polica osiguranja
		(SELECT d.id_cont, d.id_master, MIN(d.zacetek) as zacetek, MAX(d.velja_do) as velja_do, MAX(d.konec) as kraj
		FROM dbo.dokument d
		WHERE d.id_obl_zav IN ('AO', 'BO', 'VO') 
		AND d.status_akt = 'A' 
		GROUP BY d.id_cont, d.id_master) d2 ON a.id_za_regis = d2.id_master AND a.id_cont = d2.id_cont
	INNER JOIN dbo.pogodba p ON a.id_cont = p.id_cont
	INNER JOIN dbo.nacini_l n ON p.nacin_leas = n.nacin_leas
	LEFT JOIN dbo.p_kontakt pk ON a.id_kupca = pk.id_kupca AND pk.id_vloga = 'DN'
	LEFT JOIN dbo.planp_ds ds ON p.id_cont = ds.id_cont
	WHERE p.status_akt = 'A' 
	AND 
	(d2.id_cont IS NOT NULL
	OR
	(d.id_cont IS NOT NULL 
		AND
		CAST(DATEPART(yy, d.zacetek) as char(4)) + REPLICATE('0', 2 - LEN(CAST(DATEPART(mm, d.zacetek) as char(2)))) + CAST(DATEPART(mm, d.zacetek) as char(2)) > 
		ISNULL(CAST(DATEPART(yy, d.kraj) as char(4)) +  REPLICATE('0', 2 - LEN(CAST(DATEPART(mm, d.kraj) as char(2)))) + CAST(DATEPART(mm, d.kraj) as char(2)), '19000101')
		AND pk.id_kupca IS NULL
		AND (n.tip_knjizenja = '1' OR (n.tip_knjizenja = '2' AND ds.bod_cnt_lobr > 1))
	)
	)
ENDTEXT

GF_SQLEXEC(lcSQL, "_ss_za_regis")

select a.id_za_regis from rezultat1 a inner join _ss_za_regis b on a.id_za_regis = b.id_za_regis into cursor rezultat

use in rezultat1
use in _ss_za_regis



sele rezultat
IF reccount() = 0 THEN
	=POZOR("Nema podataka za ispis!")
	RETURN .F.
endif

OBJ_ReportSelector.PrepareDataForMRT("rezultat", "id_za_regis")         

Za stimulsoft ispis DOPIS ZA REGISTRACIJU SSOFT se za kandidate koji će se ispisati (između ostalih uvjeta) uzimaju svi ugovori OL, dok za FL ugovore (i Hibrid) samo ako imaju budućih rata (2 ili više), gdje se Hibrid znači gleda kao FL. 