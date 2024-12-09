4. I) i II)

--//////////////////////////////////////////////
21.11.2017 10:32:18
 Interno Self made Hide comment from customer: False Toggle
Poštovani, 

a) 1) Na testu smo podesili '(CA-VO) Ugovori koji ističu sa brojevima polica ' kako se naveli, za OF tip leasinga - datum zadnje rate iz otplatnog plana (kao što je za OL). 

3) I) Pošto se navedena kontrola kod spremanja općeg računa više ne koristi, da li bi ju maknuli ili neka ostane? 

4. I) i II) onda je potrebna dorada ispisa 
'Osiguranje - Interni dopis' 
DOPIS ZA REGISTRACIJU SSOFT 
ISPIS USPOREDBE SA SK 
-> u prilogu vam šaljemo ponudu. 

III) Pošto ispis RAČUNI ZA RATE - BESKONAČNI ne koristite, da li bi ga maknuli ili neka ostane? 

IV) Oko ispisa 1. opomene, točnije riječ je o ispisu 'TEKST OPOMENE BEZ TROŠKOVA OPOMENE', provjerio sam ugovor 42386/13 sukladno telefonskom razgovoru, te taj ugovor nema izdane opomene tako da sam vjerojatno krivo zapisao broj ugovora/primjera. Molim da pošaljete primjer ugovora (ili scan) gdje se ispisuje drugačije od logike koju sam naveo u prijašnjem mailu i koji ponovno dajem nadalje u tekstu: 
ispis 'TEKST OPOMENE BEZ TROŠKOVA OPOMENE' ima dvije rečenice, prva: 
'Ukoliko ne postupite u skladu s ovom obavijesti, biti ćemo prisiljeni naplatu izvšiti putem sredstava osiguranja plaćanja.' koja se ispisuje za sve vrste osoba koje nisu FO (partner 020843 iz scana je F1 vrsta osobe) i za tipove financiranja koji nisu Zakup (NF, NO, PF i PO). 
i druga: 
'Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.' koja se ispisuje za sve tipove financiranja koji nisu Zakup. 

S obzirom da ipak rečenice nisu skroz identične, molimo da nam definirate konačni izgled rečenice i logiku prikaza. 
Molim provjeru i povratnu informaciju. 
Za usporedbu, na ispisu 'RAČUN ZA TROŠKOVE OPOMENA' se uvijek prikazuje rečenica 'Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.' 


b) oko upita "ne znam da li se automatski pokupe u B2 tabele ovi koji imaju oznaku "T" u koloni Koristi se za B2" - dobili smo odgovor od kolega iz Slovenije -odgovor je DA. 

Tomislav Krnjak 
--//////////////////////////////////////////////
14.11.2017 15:55:25
 Interno Self made Hide comment from customer: False Toggle
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
-> sada za fizičku osobu ili za ugovor FL i Hibird i za vrstu opreme koja ima tekst 'OV' u posebnom šifrantu 'OSIG_PONUDA' u polju 'Znakovna vrijednost', se prikazuje vrijednost s PDVom, za sve ostale je vrijednost neto. 

II) Za stimulsoft ispis DOPIS ZA REGISTRACIJU SSOFT se za kandidate koji će se ispisati (između ostalih uvjeta) uzimaju svi ugovori OL, dok za FL ugovore (i Hibrid) samo ako imaju 2 ili više rata u budućnosti, gdje se Hibrid znači gleda kao FL. 

III) Također molimo da provjerite direktne ispise: 
AMORTIZACIJSKI PLAN (LE | Ugovor | Izračun financiranja) 
KALKULACIJA 
RAČUNI ZA RATE - BESKONAČNI (LE | Ispisi | Obavijesti/računi za rate | Računi za rate) 
ISPIS USPOREDBE SA SK 
PLAN OTPLATE (LE | Ugovor | Mapa ugovora) 
OBAVIJEST JAMCU O OPOMENI (3 kom) (LE | Ispisi | Opomene | Obavijesti za neplaćena potraživanja) 
RAČUN ZA TROŠKOVE OPOMENA (3 kom) (LE | Ispisi | Opomene | 1.opomena) 
TEKST OPOMENE BEZ TROŠKOVA OPOMENE (3 kom) (LE | Ispisi | Opomene | Arhiv opomena) 

jer se na njima na nekim mjestima ne koristi posebna funkcija za koju smo radili doradu navedenu u zahtjevu '1739 - HIBRID - ispisi'. 

Tomislav Krnjak 

--//////////////////////////////////////////////
Daniel Vrpoljac
13.11.2017 10:32:44
 Interno Self made Hide comment from customer: False Toggle
Poštovani, 
a) napravili smo analizu svih navedenih izvještaja te smo dodatno napravili i analizu izvoza podataka (opcija Održavanje | Posebne obrade | Izvozi podataka), dodatnih rutina, edoc podešavanja i kontrola na maskama (u eksternim funkcijama). U prilogu vam za analizu šaljemo ponudu u prilogu. 

1) Što se tiče posebnih izvještaja, doradu je potrebno napraviti samo na jednom izvještaju 
'(CA-VO) Ugovori koji ističu sa brojevima polica' (360) 
za koji smo na testu odmah napravili doradu. Za podatak 'Datum isteka' se u ovisnosti o tipu leasinga uzimao različit podatak: do sada se za OL tipove (i za OF) uzimao datum zadnje rate (iz plana otplate), a za sve ostale tipove (FL) se uzima podatak 'Datum dosp. otkupa' s pregleda obavijesti o otkupu. 
Sada smo podesili da se za Hibrid prikazuje kao za FL tip leasinga. To isto se onda odnosi i na kriterij pretrage 'Datum isteka veći od'. 
Za navedenu doradu izvještaja vam šaljemo ponudu u prilogu. 

2) Oko edoc podešavanja, za Hibrid je podešeno da se gleda kao za operativni leasing zato što je riječ o ispisima. 
Podešavanje je napravljeno prvo samo na testu pa molim provjeru i potvrdu da li možemo isto podesiti na produkciji. 

3) Na nekim kontrolama npr. kod spremanja podataka neaktivnog ugovora, da li se Hibrid treba gledati kao financijski leasing? Sada se gleda kao operativni leasing (kao što je na ispisima). 

Na kontrolama na kalkulaciji (kod dodavanja nove ponude i kontrola nakon spremanja: "Kalkulacija OL nije udovoljila provjeri tipa financiranja..."), Hibrid se trenutno gleda kao financijski leasing. 

b) Dobili smo odgovor od kolega iz Slovenije da će se novi tip izvještavati kroz Market Risk i Credit Risk kao i ostali tipovi financijskog leasinga, tako da nije potrebna nikakva dorada s njihove strane zbog novog tipa leasinga. 
Oko navedenog ste otvorili novi zahtjev 1810 - HIBRID - Mapiranje vezano u B2 tabele Credit risk i Market Risk, pa ćemo i na taj zahtjev poslati odgovor. 

Tomislav Krnjak 

