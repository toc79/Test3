/* PODEŠAVANJA ZA PRODUKCIJU */

-- 1.  podesiti ZE da ima omogućeno polje Broj krovnog dokumenta, Vrijednost
update dbo.dok set vez_na_krov_dok = 1 where ID_OBL_ZAV in ('ZE')
update dbo.dok set ali_na_pog = 1 where ID_OBL_ZAV in ('ZE') -- da bi se prikazao i prenio na ugovor

-- 2. eksterna funkcija DOUMENT_MASKA_SET_CTRL_MANDATORY

-- 3. eksterna funkcija DOKUMENT_MASKA_PREVERI_PODATKE 

--4. dorade iz GMI treba podesiti eksternu funkciju

/* KRAJ PODEŠAVANJA ZA PRODUKCIJU */




ponuda GMI 3288

2.565,75 potrošeno u GMI

ponuda 	2.844,00 € GMC za GMI doradu

	
1900 ponuda GMC, nepredviđeni 316, u kojem je 760 od GMI za analizu
potrošeno oko 1400

za TOC oko 1140 + 316 za nepredviđene = 1456


ja sam do trenutka slanja ponude imao oko 8 sati analize.
Imamo dvi ponude GMI i GMC
na kraju GMC ponuda nije imala ANalizu, a na GMI ponudu je dodano malo više (2 sata za analizu i oko 1 h za doradu)
GmC ponuda je na oko 12 sati , tako da 5 za analizu, i 7 za doradu
Dorada mi je ibla 


prebacio TC
280601 Programiranje eksterne funkcije, testiranje, dorada procedure
280598 Programiranje eksterne funkcije, testiranje, dorada procedure
na http://gmcv03/support/Maintenance.aspx?ID=52121&ShowAll=True&Tab=Progress


Pozdrav, 
u privitku vam šaljem klijentov zahjtev (RLC) te sam upisao naše GMC komentare plavom bojom fonta (dio bi mi/GMC podesili, a dio vi/GMI).




1.	Dokument ZE:
- Polja partner (dokument.id_kupca) i Br. Krov. Dok (dokument.id_krov_dok) napraviti obaveznima za unos
GMC: možemo podesiti u eksternoj funkciji

- Izmijeniti format polja Br. Krov. Dok (dokument.id_krov_dok) da se upisuje cijeli broj (trenutno je na dvije decimale)
GMC: poslati u GMI popravak

- Podesiti da se prilikom pozicioniranja na polje Br. Krov. Dok (dokument.id_krov_dok) otvara izbornik koji sadržava sve krovne dokumente ZT tog partnera, pa da korisnik samo odabere željeni dokument
GMC: molim detaljnije objašnjenje za kojeg partnera. Treba vjerojatno kod unosa, prvo se unese partner, a onda da se unese broj krovnog dokumenta i da se prikažu krovni dokumenti ZT za tog partnera 019623 TRANS AUTO koji je unesen u polje Partner.
(okvir je na partneru 019623 TRANS AUTO, krovni dokument je vezan na taj okvir i za partnera ima unesen 019623 TRANS AUTO, na taj dokument je vezan dokument ZE za ugovor 70925/23 partnera 001465 SALVIA (na dokumentu nije unesen partner).

- Podesiti kontrolu iznosa na način da nije moguće spojiti novi ZE dokument na zbirni dokument ZT ukoliko je suma svih spojenih AKTIVNIH dokumenata na taj zbirni dokument veća od njegove ukupne vrijednosti, dakle suma iznosa aktivnih ZE dokumenata povezanih za zbirni dokument ZT ne smije prelaziti ukupan iznos zbirnog ZT dokumenta.
GMC: možemo podesiti kontrolu kod klika na gumb spremi. Isto se postiže alokacijom.

2.	Prikaz povezanih dokumenata na zbirnom dokumentu iz limita
- podesiti da sumarni prikaz uzima u obzir samo aktivne dokumente, trenutno prikazuje sumu svih dokumenata kao na slici.
GMC: dorada u GMI, da se početno prikažu samo aktivni dokumenti, a da na pregledu postoji opcija (checkbox) Prikaži neaktivne dokumente? 
Tj. slično kao na pregledu dokumentacije opcija (checkbox) Samo aktivni dokumenti s time da je default-mo označeno i da je omogućemno samo kod tab-a Dokumentacija u vezi s odabranim dokumentom


Napravio slike za decimalni broj u polju 
Slika za grešku kod unosa Br. povezanog dok.
Slika greške kod unosa velikog broja (treba ograničiti na INT veličinu ako je to moguće)

Slika alokacije krovne dokumentacije 
Ovdje bi trebalo evidentirati krovni BB ugovor, koji sada unose kroz okvire ali ugovor ne vežu na okvire => provjeriti s RLC
Zato se ne može koristiti alokacija jer se ne može vezati takav okvir na ugovor => možda kreirati povezane partnere kao BB tip veze => da može se i onda unijeti taj okvir za ugovor čime će alokacija raditi. Alokacija ide na isti dokument ZT. 
Ili nova evidencija krovnog ugovora i sl. novi tip krovnog ugovora koji bi imao malo drugačije kontorle da se može unijeti ugoovr drugih partenra ili barem povezanih partnera po tipu veze BB, i da se na javlja poruka da je ugovor već na drugom okviru. 

Alokacija promjeni tip dokumenta iz ZE u ZT i popuni id_kupca s 019623 TRANS AUTO
select id_kupca, * from dbo.arh_dokument where id_dokum =     1357778 order by time 
select * from dbo.pogodba where id_cont = 78857
select id_kupca, * from dbo.arh_dokument where id_dokum =         1357779 order by time 
select id_kupca, * from dbo.arh_dokument where id_dokum =     1357792 order by time 



