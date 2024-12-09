Pozdrav, 

F) na testu vam je podešena verzija 6.16 pa smo sada podesili i kontrole navedene pod 
"- dorada IS NOVA (stavka kod koje piše GMI) kako bi u dvije opcije u programu (kod unosa ugovora i kod popravka aktivnog ugovora) mogli programirati i prikazati predefinirani datum u polju Predviđeni datum slijedeće usklade indeksa kamata (rok izrade: verziji 6.16)"

S obzirom na te nove kontrole/automatizam, smatram da je kontrola podešena pod A) suvišna (riječ je o 
"A) kod unosa ugovora će se automatski popuniti strategija reprograma i datum sljedećeg reprograma s obzirom na kupca s ponude. Podržali smo 3-mjesečni i 6-mjesečni indeks tj. razdoblje (1-mjesečno razdoblje nije podržano). Polje/datum "Slje. repr." sljedećeg reprograma smo na toj masci onemogućili za promjenu.")
tako da bi ju mogli maknuti. Tako u budućnosti ćete imati jednu kontrolu manje za za doradu i trošak u slučaju promjene.
Kao još jedan razlog zašto bi se kontrola pod A) mogla maknuti je sljedeći slučaj koji mi se desio prilikom testiranja na testu, da kod unosa novog ugovora s brojem ponude 0263376 se strategija postavi na 10. dan u razdoblju/mjesecu (10.12.2020), dok kod prolaska kroz polje Strategija reprograma zbog nove kontrole pod F) se postavi na zadnji radni dan u razdoblju/mjesecu (31.12.2020). Tomu je razlog zato što je partner 000973 sa ponude vrsta osobe FR FIZIČKE OSOBE, POTROŠAČI U RETENCIJI tako da je točnija podešena nova kontrola.
Kod unosa ugovora i postavljanja na 10. dan u razdoblju, do ovog slučaja dolazi zato što se uz provjere vrste osobe FO i F1 (kao na općim uvjetima) provjerava da li je na ponudi označeno polje "Fizička osoba" koje je pak podešeno za slučaj kada ponuda ne sadrži šifru kupca (ponuda se može unijeti bez unesene šifre kupca te se za naziv partnera unese opisno ime).
Još je bitno naglasiti da vrste osobe
FR FIZIČKE OSOBE, POTROŠAČI U RETENCIJI
R1 ZAPOSLENCI-GRUPA RBA U RETENCIJI
se ne prikazuju kod unosa novog partnera, dok kod popravka partnera se prikazuju kada se ide na opciju promjene vrste osobe partnera. Nemaju aktivnih ugovora.

Molim provjeru i povratnu informaciju oko kontrola podešenih pod F) i oko micanja kontrole pod A).

$SIGN


select * from vrst_ose

select * from dbo.partner where vr_osebe in ('FR', 'R1')

select * from dbo.pogodba pog where exists (select * from dbo.partner where vr_osebe in ('FR', 'R1') and id_kupca = pog.id_kupca ) and status_akt !='Z'

Poštovani, 

na produkciji se još uvijek nalaze stare kontrole/automatizmi, svi novi automatizmi i kontrole su vam podešene na testu (nova_test) 23.9.2020 (A, B i C) i 24.9.2020 (D), koje trebate provjeriti/testirati a na produkciji ćemo ih podesiti kada nam to javite. 
Trenutno na produkciji za pravne osobe možete vi sami promijeniti strategiju na zadnji radni dan u mjesecu s početno podešene, po potrebi promijenite datum, kod spremanja će se javiti (stara) kontrolna poruka "Nije unešena odgovarajuća vrijednost Strategije reprograma. Želite li spremiti takav ugovor?" na koju potvrdno odgovorite te će biti spremljena odabrana strategija reprograma. Za fizičke osobe FL će se setirati ispravna strategija, te ćete morati po potrebi promijeniti datum sljedećeg reprograma na odgovarajući.

U nastavku još jednom šaljem tekst maila oko novo podešenih kontrola/automatizma na nova_test-u:
"Pozdrav,

na testu smo napravili sljedeće kontrole:
A) kod unosa ugovora će se automatski popuniti strategija reprograma i datum sljedećeg reprograma s obzirom na kupca s ponude. Podržali smo 3-mjesečni i 6-mjesečni indeks tj. razdoblje (1-mjesečno razdoblje nije podržano). Polje/datum "Slje. repr." sljedećeg reprograma smo na toj masci onemogućili za promjenu.

B) kako je nakon unosa ugovora moguće promijeniti partnera od onog na ponudi tj. na ponudi ne mora biti unesen, kod spremanja podataka neaktivnog ugovora smo podesili da se ponovno provjerava strategija reprograma i datum te automatsko postavljanje.
Za ovakav slučaj kada se promijeni kupac kod unosa ugovora ćemo podesiti kontrolu navedenu u natuknici
"- dorada IS NOVA (stavka kod koje piše GMI) kako bi u dvije opcije u programu (kod unosa ugovora i kod popravka aktivnog ugovora) mogli programirati i prikazati predefinirani datum u polju Predviđeni datum slijedeće usklade indeksa kamata (rok izrade: verziji 6.16)"

C) kod aktivnog ugovora u koraku spremanja ugovora kao u točki B). Dodatno će se s verzijom 6.16 podesiti dodatna kontrola navedena u natuknici iznad.

Kod navedenih kontrola kao referentni će se uzimati današnji dan i s obzirom na isti će se prikazivati kontrole.
Npr. 23.9.2020 unosite ugovor za fizičku osobu, predloženo razdoblje za 3-mj. bi bilo 10.9.2020 pa s obzirom da je taj datum u prošlosti, za datum sljedećeg reprograma će biti ponuđen 10.12.2020. Za pravnu osobu će biti 30.9.2020, a za 6.-mj. će biti 31.12.2020.
Testirati možete tako i da unesete npr. 30.9.2020 kao praznik u šifrant praznika i sl.

D) "- kod ulaska u opciju Reprogram zbog promjene indeksa napravit ćemo kontrolu koja će prikazati obavijest korisniku (ako se slučajno gore navedeni job nije izvršio iz nekog razloga) da postoje ugovori koji nemaju ispravan Predviđeni datum slijedeće usklade indeksa kamata i da je potrebno prije puštanja reprograma pokrenuti rutinu za osvježavanje datuma u polju Predviđeni datum slijedeće usklade indeksa kamata (rok izrade: 23.09.2020)".
Ova kontrola bi prikazivala slučajeve kada datum sljedećeg reprograma nije 10. ili zadnji radni dan tekućeg mjeseca (ovisno o vrsti osobe kao u i ostalim kontrolama). Takvi slučajevi bi mogli biti 
- ako se danas unese ugovor, postaviti će se datum 30.9.2020., ako se aktivira 1.10.2020 odmah će biti ponuđen za reprogram, ali će se sada prikazati poruka kontrole
- ako se napravi promjena vrste osobe za partnera iz fizičke u pravnu i sl.
- ako job nije napravio promjenu datuma na zadnji radni dan u mjesecu zbog greške itd.
Molim provjeru na nova_test svih kontrola.
"
Molimo provjeru na nova_test.

E) Na testu (nova_test) sam sada podesio automatizam naveden u natuknicama 

"- napraviti dodatnu rutinu koja će popravljati ugovorima Predviđeni datum slijedeće usklade indeksa kamata na zadnji radni dan u mjesecu (zapisivat će se promjena u reprogram). To znači da bi nakon reprograma zbog promjene indeksa ova rutina provjerila koji je zadnji radni dan u 12-om mjesecu i umjesto 30.12.2020 promijenila datum na 31.12.2020. Na taj način imamo kontrolu da se ti ugovori neće moći reprogramirati bilo koji dan, nego upravo zadnji radni dan u tim mjesecima. Trenutno reprogram zbog promjene indeksa radi na način da datum 30.09.2020 nakon reprograma popravi na 30.12.2020, a ne na 31.12.2020. Iz tog razloga ćemo napraviti dodatnu rutinu. (rok izrade: 23.09.2020)
- podesit ćemo automatski job kako bi bili sigurni da se gore navedena rutina izvršila i popravila datume, da ne mora ovisiti o tome da li ju je korisnik pustio ili nije (rok izrade: 30.09.2020)"

na način da se automatski job pokreće jedno mjesečno. 
Radi testiranja sam podesio da se na nova_test pokrene job danas u 15 sati, na testu ima  2703 ugovora na kojima će se napraviti promjena, na produkciji trenutno nema takvih slučajeva. Zbog testiranja, job 
"Promjena datuma sljedećeg reprograma za strategiju Zadnji radni dan u mjesecu"
možemo drugačije podesiti. Rezultat promjene će se moći vidjeti u pregledu reprograma. 
Kandidati za promjenu su svi aktivni (A) ugovori kojima datum sljedećeg reprograma nije na zadnji radni dan mjeseca. Ugovori koji imaju posebnosti isto tako su kandidati za promjenu datuma sljedećeg reprograma, oni će se pak moći reprogramirati nakon što se maknu posebnosti.

Oko detalja me slobodno kontaktirajte na telefon.



