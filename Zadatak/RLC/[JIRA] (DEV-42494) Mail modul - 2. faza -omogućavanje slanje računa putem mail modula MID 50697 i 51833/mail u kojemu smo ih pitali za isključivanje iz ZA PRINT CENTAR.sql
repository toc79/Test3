select * from dbo.p_kontakt where id_kupca = '042783'
select * from dbo.p_kontakt_vloga

select rtrim(DDV_ID) as ddv_id2, * from dbo.NAJEM_FA where id_kupca = '042783' and ID_TERJ = '21'

select ic.*, eefc.*, ec.*, eef.* 
from dbo.EDOC_EXPORTED_FILES eef
join dbo.EDOC_EXPORTED_FILES_CHANNELS eefc on eef.id = eefc.id_file
join dbo.EDOC_CHANNEL ec on eefc.id_edoc_channel = ec.id_edoc_channel
left join dbo.io_channels ic on ec.io_channel_code = ic.channel_code
where document_id = '20230099948'


Poštovana,

preduvjet za slanje ispisa putem maila je da je ispis napravljen u Stimulsoftu i da imate Mail server.
S obzirom da već koristite Mail modul i d je ispis računa za rate napravljen u Sitmulsoftu, nema prepreka da se računi za rate šalju mailom.

U slučaju da ih želite i digitalno potpisivati, tada je potrebno s naše strane doraditi:
- eDoc kako bi mogli podesiti automatsko digitalno potpisivanje na računu (računima)
- doraditi Stimulsoft ispise kako bi mogli prikazati digitalni potpis na pdf dokumentima

Uz to, potrebno je reći da li bi to značilo da više ne bi nikome slali račune putem pošte ili samo određenim partnerima s kojima ste sklopili suglasnost da će primati račune putem maila (potrebno onda i napraviti podešavanje da znamo koji us to partneri, te u izvozima podataka izvoziti na različite kanale).


15. 05. 2023 09:36:20

Poštovani,

želimo digitalni potpis.

Nastavno na vaš upit kojim klijentima će se slati računi mailom - samo onim klijentima koji imaju potpisanu suglasnost (uloga 02 u NOVA)

Lijepo molimo i ponudu za sve niže potrebne radnje.

Lp
Suzana 


NEDOVOLJNO DEFINIRANO S NJIHOVE STRANE, ALI NITI SMO MI U IJEDNOM TRENUTKU NAPISALI DA SMO ILI ĆEMO ISKLJUČITI KANAL EDOC_EX2                      	ZA PRINT CENTAR

ponuda
26. 06. 2023 09:46:42

u privitku vam šaljemo ponudu za digitalno potpisivanje PDF dokumenata i za kreiranje slanja računa za rate na email (kroz opciju izvoz podataka).
Na tom reportu na pregledu računa za ratu se ispisuju računi za sljedeća potraživanja:
20     UČEŠĆE/POSEBNA NAJAMNINA
21     RATA/OBROK
12     TROŠAK OBRADE
1G     OBRAČUN za korištena sredstva.
Da li sva šaljemo na mail ili samo za 21 RATA/OBROK?
RLHR :  Slali bismo sve račune za sva gore spomenuta potraživanja jer ih istovremeno i ispisujemo.

Za početak bi onda podesili da se digitalno potpisuje samo ispis računa za ratu tj. dokumenti za potraživanja koje ćemo slati na mail. Ili želite da sve PDF dokumente podesimo da se digitalno potpisuju (oni koji se edoc obrađuju)?
RLHR: Digitalni potpis bismo stavili na sve gore navedene račune.

PDF dokumenti koji su potpisani, za njih će ići slanje jedan mail jedan PDF privitak/dokument. Za njih nije moguće podesiti da se radi merge/spajanje npr. 10 PDF dokumenata u jedan PDF i onda slanje jednog privitka u jednom mailu, eventualno mi možemo provjeriti još na mogućnost da se pošalje npr. 1 mail i 10 PDF privitaka ako vam je to bolje rješenje (to do sada nije nikome podešavano pa to još moramo testirati da li možemo podesiti).
RLHR : Mi bismo išli na opciju slanja 1 maila sa više PDF privitaka. Da li je limitirano na 10 PDF privitaka ili može i više?

Molimo da nam pošaljete izgled/sadržaj e-maila tj. podatke 1. defaultni mail za polje FROM u mail-ovima (za izvoz/slanje na mail "eDoc to eMail exporter Obavijesti o promjeni mjesečne rate" je podešeno "Raiffeisen Leasing <leasing.vodjenje@rl-hr.hr>" pa možemo isto podesiti) Računi Raiffeisen Leasing d.o.o. <racuni@rl-hr.hr>

2. template mail sadržaja (mail body i signature)

Poštovani,

u privitku šaljemo račune kreirane za sklopljene ugovore o leasingu.

Kako bi bez poteškoća mogli pročitati poslane Vam dokumente, molimo slijedeće:
- Na računalu je potrebno imati Adobe Acrobat Reader minimalno ver.6.0, ukoliko navedeno nemate, molimo da instalirate prije pregleda računa (najnoviju verziju možete pronaći ovdje: http://get.adobe.com/reader)

- Ukoliko želite provjeriti autentičnost i konzistentnost računa, potreban je FINA-in RDC certifikat koji je besplatan (korisnici FINA-inih web usluga mogu preskočiti ovaj korak) i možete ga preuzeti ovdje: http://rdc-tdu.fina.hr/CA/RDC-TDUCA.cer. U prilogu ovog e-maila se također nalaze upute za instalaciju kao i upute za provjeru autentičnosti.

- Molimo da održavate svoj poštanski sandučić, odnosno da u istome uvijek postoji minimalno 1 MB slobodnog prostora kako bi Vam računi bili dostavljeni.

Napomena: Raiffeisen Leasing d.o.o. zadržava pravo slanja računa poštom uslijed nepredviđenih događaja.

Ukoliko imate pitanja, molimo pošaljete svoj upit na racuni@rl-hr.hr

S poštovanjem,
Vaš Raiffeisen Leasing d.o.o.


29. 08. 2023 12:31:33
Poštovana/i,
podesio sam slanje računa na e-mail na NOVA_TEST. Slanje se pokreće automatski nakon eDoc obrade (2. obrade), a funkcionalnost je podešena u izvozu podataka 57 "eDoc to eMail exporter - Računi za ratu".
Početno sam podesio da
- FINA partneri nisu kandidati za slanje na mail
- idu samo potraživanja za ratu ID 21 (zbirni računi se ne može ispisati iz opcije računa za ratu pa n eidu)
- partneri koji imaju ulogu šifre 02 MAIL "Klijenti kojima se šalju računi/obavijesti na mail"
- potpisivanje PDF dokumenta ide za tip Invoice (za račune).
Molim testirajte.