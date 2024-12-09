/*
dogovoriti točku
B. podešavanje automatsko ispisivanje/renderiranje ispisa
za 5 ispisa tj. 6 zbog Invoice i Reminder
=> Da li event ili XDOC? Treba podešavati u dva eventa: Invoice.Issued i ReminderWithNoCostAfterIssue i u oba je onda potrebno podesiti više reporta. Možda je bolje XDOC jer ispis "Obavijest o neplaćenim potraživanjima" svakako mora ići u XDOC jer ispis ide po partneru, a ne po ID_OPOM.
Ili Invoice da ide preko eventa, a ostali ispis da idu preko XDOCa?

Kako poslati notifikaciju => doradi se select da ide ProcessXml Insert_mail umjesto pripreme opomena. Druga opcija bi bila da se doradi ispis da provjerava podatke u ARH_ZA_OPOM pa onda ne treba notifikacija, ali bi to možda moglo usporiti renderiranje ispisa 

Poštovana/i, 

u privitku vam šaljemo ponudu za 
A. podešavanje joba za izdavanje opomena (već imate podešen job za pripremu opomena). Izdavanje opomena bi se izvršavalo prema skadenci definiranoj u izvozu podataka 30 Slanje obavijesti e-mailom o obavezi izdavanja ispisivanja opomena. 
Što se tiče joba koji radi priprema opomena, njega bi podesili da se radi provjera, ako ima izdane a ne ispisana opomena da onda ide obavijest na mail (da priprema neće biti pokrenuta jer postoje izdane neispisane opomene).

B. podešavanje automatsko ispisivanje/renderiranje ispisa
0041 Invoice Račun za opomenu
0042 Reminder Opomena bez troška => za 0041 i 0042 će se podesiti u eventu
0043 guarremind Obavijest jamcu o opomeni
0044 guarremind Obavijest dodatnim jamcima o opomeni
0045 general Obavijest o neplaćenim potraživanjima => ovaj ispis je vezan na točku 5.

te ispis "TEKST OPOMENE TP" koji će se podesiti u stimulsoftu te napraviti edoc podešavanja.

D. Izrada izvoza podataka na mail za sve ispise iz točke B.

E. Dorada izvještaj "(IT-CA) EDOC - Pregled eksporta datoteka" oko prikaza izvoza opomena na mail.

F. podešavanje posebnog izvještaja prema excelu "Izvještaj o poslanim opomenama.xlsx" prema točki 7.

Zadnja stavka ponude "Pomoć korisnicima kod testiranja i nepredviđene situacije" će se naplatiti prema stvarnom utrošenom vremenu ako do njih dođe. 

Točka C. podešavanje edoc kanala prema točki 8. za sve ispise iz točke B., to će se dorađivali u zasebnom zahtjevu koji ćete nam poslati, sukladno dogovoru s Teams sastanka.

$SIGN 


Za ispis "Obavijest o neplaćenim potraživanjima" će se kreirati job koji će pokretati ispisivanje/renderiranje zbog specifičnog načina ispisa koji ide grupiran po partneru (job će pokretati izvoz podataka koji će renderirati ispise).
Svi ostali ispisi će se ispisivati/renderirati koristeći event-e.




Da li ispis TEKST OPOMENE TP" podesiti u OPOMIN? 








Jedno od rješenje bi bilo da se nakon svake akcije izdavanja potraživanja i/ili unosa plaćanja, pokreće priprema opomena => ne bi jer ako se 2 rata prvo proknjiži, dug je 200% i neće biti kandidat za 

Poštovana/i, 

u Teams sastanku sa Sanjom Measrić sam pokazao koje je najbrži način testiranja opomena te smo smo prošli test case vezano na vaš primjer u mailu, u kojemu smo utvrdili da je za promjenu iz 1. u 2. opomenu potreban i odgovarajući materijalni kriterij (iznos duga). Još bih nadodao oko istog vašeg primjera, da je nakon plaćanja koje zatvara cijeli dug bila pokrenuta priprema opomena i nije još bilo izdano novo potraživanje/rata, onda bi se na ugovoru obrisao datum 1. opomene i u polju "Datum do kojeg se ne opominje" zapisao datum 25.1.2024 (datum 1. opomena 15.1.2024. + 10 dana Minimalni broj dana prije ponovne pripreme opomene).

Što se tiče prečestog opominjanja, pokazalo se da u funkcionalnosti pripreme opomena nemamo mogućnost podešavanja za slučaj kako ste objasnili da ponovno opominjanje po istoj opomeni ide svakih 30 dana. Sada ponovno opominjanje za 1. opomenu ide prema parametru "Br. kalendarskih dana dugovanja prije 1. opom.", a u to polje unosite 10 dana (za 2. opomenu ide parametar "Br. kalendarskih dana između 1. i 2. opom." i slično za 3. opomenu ide "Br. kalendarskih dana između 2. i 3. opom.").
Zaključak je da bi bolje najbolje da se automatizam opominjanja podesi prema postojećoj skadenci. 

Molim provjeru i povratnu informaciju. Oko detalja me možete kontaktirati na telefon/mobitel.

$SIGN 




Što se tiče prečestog opominjanja, pokazalo se da u funkcionalnosti pripreme opomena nemamo mogućnost podešavanja za slučaj, kada u istom danu imate plaćanje jedne rate i ponovno izdavanje rate (i obrnuto) jer se u tom slučaju dug ne mijenja i imamo situaciju kao da nije došlo do promjene, jer u međuvremenu te dvije akcije nemate pripremu opomena koja bi promijenila stanje (duga ili broja opomene).

Kada u istom danu imate plaćanje jedne rate i ponovno izdavanje rate (i obrnuto)
AKo je dospječe nove rate + 10, onda to kao i da nije isti dan



Zaključak je da bi bolje najbolje da se automatizam opominjanja podesi prema postojećoj skadenci. 
Druga opvija bi ibla da se Priprema opomena podesi nakon dnevnih rutina Prijenos potraživanja.
Što se tiće izdavanj eostalih općih računa

Eventualno da se u pripremi opomena ne izdaju ponovno ista opomena ako nije prošlo više od 30 dana. => ali to nije dobro rješenje.


Priprema opomena traje 2 minute 

RUčno puštaju prijenos potraživanja provjeriti arh_opravki



Razmotrimo još ovaj realan slučaj ako sam dobro shvatio, da puštamo pripremu opomena 02.09.2024, a ugovor je dužan 100% rate (od prošlog mjeseca) i ima datum 1. opomene 20.08.2024, a za "Min br. dana prije ponovne prip. opomena" je uneseno 30.
Tada npr. nakon dnevne rutine Prijenos potraživanja se ujutro proknjiži nova rata čime se dug povećati tek za 8 dana 09.09.2024 na oko 200%, pa kod Pripreme opomene bi se 2. opomena pripremila tek iza 09.9.2024. nakon dospijeća duga. 
Ako ide prvo plaćanje pa priprema opomena, onda bi recimo dug pao ispod 20% i priprema bi obrisala datum 1. opomene koji je bio npr. 20.8.2024 i popunila "Datum do kojeg se ne opominje" s datumom 02.10.2024 ako bi unijeli 30 dana za parametar. Nakon prijenosa potraživanja bi se proknjižila sljedeća rada koja bi bila dug nakon 10.09.2024 te bi se ponovno pripremila 1. opomena tek 02.10.2024. 

Ako bi podesili Pripemu opomena nakon dnevnih rutina, da li bi vam onda odgovarala takva logika?

Situacija: ugovor je dužan 100% rate (od prošlog mjeseca) i ima datum 1. opomene 20.08.2024, a za "Min br. dana prije ponovne prip. opomena" je uneseno 30.
onda će se 30.8. pripremiti ponovno 1. opomena

Slučaj dana 02.09.2024:
1. knjiženja plaćanja i dospijeća druge rate u istom danu
Kod postojeće pripreme opomena ne bi se desilo ništa jer bi plaćanje zatvorilo jednu ratu i dug bi bio 100% kao da nema promjene.
Ako promijenimo pripremu opomena da ide nakon dnevnih rutina (to znači prije unosa plaćanja), onda će se desiti => ništa jer nije kandidat za 

2. knjiženje plaćanja 10.09.2024 i dospijeće duga
Kod postojeće pripreme opomena ne bi se desilo ništa jer bi plaćanje zatvorilo jednu ratu i dug bi bio 100% kao da nema promjene.
Ako promijenimo pripremu opomena da ide nakon dnevnih rutina (to znači prije unosa plaćanja), onda će se desiti da će se pripremiti 


11.09.2024
nakon 10 dana ide prva opomena npr. 1.9. je rata, dospijeće je 10.9. To znači 1. opomena ide 20.9.
ako se ne plati  + 20 dana od 1. opomene, pripremiti će se 2. opomena
ako plati prije 2. opomene, resetirati će se datum 1. opomene i popuniti "Datum do kojeg se ne opominje"  npr. 30 dana od izdavanja 1.opomene
ako plati isti dan kada je dospjela nova druga rata i onda priprema opomene, neće se desiti ništa (niti resetiranje niti popuniti "Datum do kojeg se ne opominje", a ponovno priprema iste opomene će ići nakon proteka +10 dana od datuma 1. opomene)
ako priprema opomena ide prije plaćanja npr. ujutro, izdala bi se 2. opomena. Drugi dan bi se datum resetirao na 1. opomenu i popunio "Datum do kojeg se ne opominje" => to RLC vjerojatno ne želi zato je job podešen u 14 sati

Ne može se dobiti ono što RLC želi da ponovno opominjanje po istoj opomeni ide svakih 30 dana.
Jer nakon 10 dana ide prva opomena npr. 1.9. je rata, dospijeće je 10.9. To znači 1. opomena ide 20.9.. Onda 2. opomena se priprema za +20 dana što je 10.10.
S postojećim postavkama ponovno opominjanje 1. opomene ide + 10 dana izdavanja 1. opomene što je 30.9.2024.



*/


declare @id_cont int =  70817 --64020/20
select top 10  time, dat_1op, dat_2op, dat_3op, poi.NE_OPOM_DO, poi.*, pog.* 
from dbo.arh_pogodba pog
left join dbo.pogodba_opom_info poi on pog.ID_CONT = poi.ID_CONT
where pog.id_cont = @id_cont order by 1 desc
--select cas_prip, ST_OPOMINA, dok_opom, SALDO_VAL, MIN_TERJ, * 
--from dbo.arh_za_opom azo
--where azo.id_cont = @id_cont order by azo.id_opom desc
--select time as time2, zad_dat_prip, azot.dni_opom, azot.PREPOVED_OPOM_DNI, azot.DNI_1OP, azot.dni_2op, azot.dni_3op, * from dbo.arh_za_opom_type azot where azot.id_za_opom_type = 7 order by time2 desc
select cas_prip, azot.dni_opom, azot.PREPOVED_OPOM_DNI, azot.DNI_1OP, azot.dni_2op, azot.dni_3op, ST_OPOMINA, dok_opom, azo.SALDO_VAL, azo.MIN_TERJ, * 
from dbo.za_opom azo
join dbo.za_opom_type azot on azo.cas_prip = azot.zad_dat_prip and azot.id_za_opom_type = azo.id_za_opom_type
where azo.id_cont = @id_cont order by azo.id_opom desc
select cas_prip, azot.time as time_type,azot.dni_opom, azot.PREPOVED_OPOM_DNI, azot.DNI_1OP, azot.dni_2op, azot.dni_3op, ST_OPOMINA, dok_opom, SALDO_VAL, MIN_TERJ, * 
from dbo.arh_za_opom azo
left join dbo.arh_za_opom_type azot on azo.cas_prip = azot.zad_dat_prip and azot.id_za_opom_type = azo.id_za_opom_type
--left join dbo.ARH_OPOM_TMP aot on azo.id_opom = aot.ID_OPOM
where azo.id_cont = @id_cont order by azo.id_opom desc, time_type desc



--primjer za testiranje Min. br. dana prije ponovne pripreme ponude
--Došla je uplata i NE_OPOM_DO je 2024-05-03, a dat_1op je 2024-04-30 (preslika s dat_2op tj. došlo je do brisanja datuma 2. opomene) tako da je zaključak da se postavlja datum opomene + PREPOVED_OPOM_DNI
declare @id_cont int =  75852 --68370/22
select time, dat_1op, dat_2op, dat_3op, poi.NE_OPOM_DO, poi.*, pog.* 
from dbo.arh_pogodba pog
left join dbo.pogodba_opom_info poi on pog.ID_CONT = poi.ID_CONT
where pog.id_cont = @id_cont order by 1 desc
select cas_prip, azot.dni_opom, azot.PREPOVED_OPOM_DNI, azot.DNI_1OP, azot.dni_2op, azot.dni_3op, ST_OPOMINA, dok_opom, SALDO_VAL, MIN_TERJ, * 
from dbo.arh_za_opom azo
join dbo.arh_za_opom_type azot on azo.cas_prip = azot.zad_dat_prip and azot.id_za_opom_type = azo.id_za_opom_type
--left join dbo.ARH_OPOM_TMP aot on azo.id_opom = aot.ID_OPOM
where azo.id_cont = @id_cont order by azo.id_opom desc



declare @id_cont int = 78605 -- izdana je 2. opomena te unoatoč PREPOVED_OPOM_DNI = 10, ugovor je postao kandidat 2. opomenu nakon 4 dana?? 



<reminders_generate xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:leasing">
<dat_prip>2024-07-05T00:00:00.000</dat_prip>
<reminder_types>
<id_za_opom_type>7</id_za_opom_type>
</reminder_types>
</reminders_generate>



--select dat_1op, dat_2op, dat_3op, poi.NE_OPOM_DO, poi.*, pog.* 
--from NOVA_ARH_int.dbo.archive_arh_pogodba pog
--left join dbo.pogodba_opom_info poi on pog.ID_CONT = poi.ID_CONT
--where pog.id_cont = @id_cont order by time desc

/*
Poštovana/i, 

ispod točaka su naši GMC komentari:
1. Polje &quot; Min. br. dana prije ponov. pripr. opomena&quot;
- u polje &quot;Min. br. dana prije ponov. pripr. opomena&quot; smo unijeli vrijednost 10, međutim opomene su se pripremale neovisno o tome.
Primjer:
67160/22 - 20.05. - 1.opomena
            - 24.05. - 1.opomena - izdana ista vrsta opomene u razmaku manjem od 10 dana


70732/22 - 20.05. - 1.opomena
            - 24.05. - 2.opomena - izdana druga vrsta opomene u razmaku manjem od 10 dana

Dakle ne razumijemo i dalje funkciju tog polja.
GMC:
" Min. br. dana prije ponov. pripr. opomena" - znači da ukoliko klijent ne zadovoljava uvjete za drugu opomenu i stalno duguje isti iznos da mu možete ponovo poslati prvu opomenu, npr. za 20-30 dana jer u vašem slučaju ako mu pošaljete prvu opomenu 12. u mjesecu onda najmoprimac može ponovo dobiti prvu opomenu 22. u mjesecu.
Broj dana između prve i druge opomene obično se koristi barem 20 dana jer npr. možete imati izdanu ratu 1. u mjesecu koja dospijeva 9. te mu šaljete opomenu 12. u mjesecu, ako ste slučajno izdali i prefakturu npr 5. u mjesecu, vama 15. u mjesecu zbog dospijeća prefakture može se ukupni dug povećati da pređe granicu za drugu opomenu te će vam za 3 dana već izaći i druga opomena.

VAŽNO: Spomenuli bi da izdavanje opomena svaki dan ima više smisla u slučajevima kada imate rate na svaki dan u mjesecu (kao rade u Sloveniji), a kada imate rate koje su prvog u mjesecu možda je bolje da podesimo job-ove da se izdaju na iste dane kao što radite ručno.
Ako izdavanje ide svaki dan, onda trebate podesiti pripreme opomena da ne dolazi do slučajeva prečestog opominjanja

Za ugovor 67160/22 datumi opomena u pregledu reprograma ne odgovaraju navedenome pa nisam detaljnije provjeravao ovoj slučaj ugovora već sam provjeravao ugovor/slučaj 70732/22. Ugovor 70732/22 je obrađivala priprema opomena ID 1 &quot;Osnovna priprema&quot;. 2. opomena se pripremila i izdala 23.5.2023.
Provjerio sam objašnjenje u helpu te utvrdio da opis nije dobro objašnjen/preveden. Tekst objašnjenja bi trebao biti: 
&quot;Min. br. dana prije ponovne pripreme opom. - koliko kalendarskih dana najmanje mora proći, prije ponovne pripreme opomena, između izdavanja dvije opomene bez obzira na ostale kriterije. Ako je označeno potvrdno polje Radni dani, polje se preimenuje u Min. br. radnih dana prije ponovne pripreme opom. i određuje koliko radnih dana najmanje mora proći prije ponovne pripreme opomena. Vrijednost u tom polju se koristi samo ako je prije pripreme opomena bilo izvedeno plaćanje za ugovor, naime u tom slučaju na temelju te vrijednosti se izračuna datum u polju &#39;Datum do kojeg se ne opominje&#39; na mapi ugovora. Vrijedi za sve opomene, namijenjeno je za sprječavanje prečestog opominjanja.&quot;
Promjenu objašnjenja sam napravio u našem helpu lokalno te će isti kod Vas biti postavljen pretpostavljam s novom verzijom.

2. Prikaz izdanih opomena na ugovoru se nije poništio zatvaranjem otvorenih potraživanja i to samo za opomene pripremljene po novim pripremama koje smo sami složili (pripreme 10, 11, 12 i 13)
Primjer ugovori 68370/22 i 74421/23 (stara potr.zatvorena 07.05., nova dospijeća 8.5., 10.05. vidljive i dalje stare opomene)
GMC: Za ugovor 68370/22 ide priprema opomena ID 10 Priprema opomena - pomaknuta dospijeća. Ugovor je 7.5. imao popunjen datum 1. i 2. opomene. S pripremom 2024-05-08 15:41:52 je materijalni kriterij/dug &#39;Dug VAL&#39; iznosio 423.83 (zbog potraživanja 68370/22-21-024AVT koje je 8.5., a ulazi u dug jer je parametar &quot;Koliko dana po dospijeću se računa dug&quot; = 0 dana, a prethodnu pripremu je dug iznosio 659.61) te zbog pada duga je na ugovoru obrisan datum 2. opomene, a datum prve opomene je postao 2024-04-30. Iznos duga je postojalo sve do pripreme 2024-05-17 16:02:44 kada je dug iznosio 0 te se datum 1. opomene na ugovoru obrisao (uneseno je plaćanje broj 2026725). Promjene datuma opomena i statusa su vidljive u pregledu reprograma.

3. Na dan novog dospijeća (dug&gt;120%) kada je prema skadenci trebala biti izdana 2.opomena, izdana je opet 1.opomena, tj. nije u obzir uzet i iznos novog dospjelog potraživanja.
GMC: Za ugovor 68370/22 s pripremom 2024-05-24 11:18:29 se dug s 0 povećao na 423.83 te se s izdavanjem opomene zapisao 2024-05-24 u datum 1. opomene (2024-05-24 23:44:07). Promjene datuma opomena i statusa su vidljive u pregledu reprograma.

4. Molimo info koji sve kandidati izlaze na opciji ispisi/Opomene/Obavijesti za neplaćena potraživanja.
GMC: prikazani su svi ugovori koji su obrađeni zadnjom pripremom opomena, a to su znači ugovori koji su kandidati za izdavanje opomena 1., 2. i 3. (tj. isti koji se vide u pregledima 1. 2. i 3. opomene) i uz njih i ostali ugovori koji nisu kandidati za izdavanje opomena (npr. kojima se obrisao datum opomena i sl.). Tako da za njih možete vidjeti stanje duga, potraživanja te ostale podatke. Što se tiče pregleda &quot;Arhiv opomena&quot;, u tom pregledu se mogu pregledavati samo zapisi koji su bili kandidati za izdavanje opomena ili im je izdana opomena (ne prikazuju se podaci ostalih ugovora koji nisu kandidati za izdavanje opomena npr. kojima se obrisao datum opomena i sl.).

5. Zbirne obavijesti bez troška:
Za potpunu automatizaciju opomena bi trebalo podesiti novu pripremu većeg prioriteta za klijente kojima u Kontaktima na Mapi partnera  postoji oznaka O1 (ili prilagoditi Pripremu 6)
Takve opomene bi trebalo pripremiti  na zbirnom ispisu, tj. da svaki klijent dobije samo jedan obrazac.
Napomena: trenutno se zbirne obavijesti ispisuju iz opcije Pregled plaćenosti potraživanja/Sumarni pregled po ugovorima iz dnevne snimke stanja, gdje se mora ručno birati ugovore koji zadovoljavaju uvjete za opomene po skadenci, jer se trenutno postavljenom rutinom prikazuju svi ugovori u dospijeću, bez obzira na protek dana.
GMC: ponovio bih odgovor od ranije da ispis &quot;OBAVIJEST O NEPLAĆENIM POTRAŽIVANJIMA stimulsoft&quot; možemo podesiti na pregledima opomena. Znači taj ispis bi išao za sve partnere kojima je pripremljena i izdana 1, 2 ili 3. opomena za ID pripreme 6 Priprema opomena - O1 opomene bez troška.
Logiku ispisa ne bi mijenjali, ispis ide po partneru (a ne po ugovoru kako je za ostale ispis na pregledu opomena). Za prikaz svih opomena se može koristiti pregled/opcija
Ispisi | Opomene | Obavijesti za neplaćena potraživanja
pa u slučaju ručnog ispisivanja ćete moći na tom mjestu ispisati za sve partnere.
Kod automatizma bi išlo po istoj logici, da se ispiše za sve partnere kojima je pripremljena i izdana 1, 2 ili 3 opomena za ID pripreme 6 Priprema opomena - O1 opomene bez troška (za svaku opomenu je zapisana ID priprema koja je korištena što se također sprema u arhiv opomena).
Da li vam odgovara navedeno rješenje? 
Kada izdate opomene, ti ugovori/zapisi se i dalje ispisuju ispisom &quot;RAČUN ZA OPOMENE I OPOMENE BEZ TROŠKA stimulsoft&quot;?

6. Molimo da neovisno o prva 4 pitanja na NOVA_INT podesite da se priprema  i izdavanje svih opomena izvršavaju svaki radni dan. Koliko se sjećam spominjali smo spajanje pripreme i izdavanja u jedan job.
GMC: možemo podesiti. 

7. Svaki dan bi na mail trebala doći obavijest sa specifikacijom poslanih opomena, uz naznaku kanala kojim je opomena/obavijest otišla.
GMC. oko kanala imate poseban izvještaj &quot;(IT-CA) EDOC - Pregled eksporta datoteka&quot; pa se može doraditi izvještaj ako je prikaz podataka nije odgovarajući. Izvještaj bi trebalo doraditi oko prikaza podataka opomena poslanih na mail.
Ako trebate detaljniju specifikaciju, molim da nam pošaljete izgled iste, u excelu (koji bi išao kao privitak maila) ili kao tijelo teksta maila, s konkretnim podacima kako bi željeli izgled kako bi mogli provjeriti mogućnosti.

8. Pravila za edoc kanale:

Opomene s troškom:
- ukoliko ima FINA ID -&gt; FINA
- ukoliko nema FINA ID, ali ima ulogu 02 -&gt; mail
- ukoliko nema ni FINA ID niti ulogu 02 -&gt; PCK

Opomene bez troška:
- Ukoliko ima ulogu 02 -&gt; mail
- Ukoliko nema ulogu 02 -&gt; PCK

GMC: oko FINA i mail bi podesili pravila za edoc kanale.
Oko maila kanala, za navedeno treba još podesiti novi izvoz podataka koji će slati opomene sa i bez troška na mail prema navedenoj logici.

Sumirao bih onda dorade: 
A. podešavanje joba za izdavanje opomena (uz postojeći za pripremu opomena)
B. automatsko ispisivanje/renderiranje ispisa 
EdocTypeId	EdocTypeName	Title
0041	Invoice	Račun za opomenu
0042	Reminder	Opomena bez troška
0043	guarremind	Obavijest jamcu o opomeni
0044	guarremind	Obavijest dodatnim jamcima o opomeni
0045	general	Obavijest o neplaćenim potraživanjima =&gt; ovaj ispis je vezan na točku 5.

te ispis &quot;TEKST OPOMENE TP&quot; koji će se podesiti u stimulsoftu te napraviti edoc podešavanja.

C. podešavanje edoc kanala prema točki 8. za sve ispise iz točke B.

D. Izrada izvoza podataka na mail za sve ispise iz točke B. 

E. Dorada izvještaj &quot;(IT-CA) EDOC - Pregled eksporta datoteka&quot; oko prikaza izvoza opomena na mail te eventualno detaljnija specifikacija za koju ćete nam poslati primjer izgleda.
Da li želite da ponudu pripremim odmah ili ćete nam prvo poslati izgled za točku 7. specifikacijom poslanih opomena na mail (u excelu kao privitak ili kao tijelo teksta maila)?

Predlažemo da prije navedenih podešavanja osvježimo NOVA_INT s produkcijskim podacima te da napravimo sve dorade na NOVA_INT kako bi mogli lakše testirati jer na NOVA_INT bi onda mogli redovito puštati dnevne rutine, uvesti izvod/plaćanja i onda detaljno pratiti pripremu i izdavanje opomena.



Tomislav Krnjak
Voditelj projekta / Project Manager

Gemicro d.o.o.
Ulica Milana Ogrizovića 28A, HR-10000 Zagreb, Hrvatska
T: +385 (0)1 3688983 
M: +385 (99) 3119157
www.gemicro.hr

*/


/*
HELP
SLO
Min. št. dni pred ponovno pripravo opom. - koliko koledarskih dni najmanj mora pred ponovno pripravo opominov miniti med izdajo dveh opominov ne glede na ostale kriterije. Če je označeno potrditveno polje Delovni dnevi, pa se polje imenuje Min. št. del. dni pred ponovno pripravo opom. in določa, koliko delovnih dni najmanj mora miniti pred ponovno pripravo opominov. Vrednost v tem polju se uporabi samo, če je pred pripravo opominov bilo izvedeno plačilo za pogodbo, in sicer se v tem primeru na podlagi te vrednosti izračuna datum v polju Datum, do katerega se ne opominja na mapi pogodbe. Velja za vse opomine, namenjeno pa je preprečevanju prepogostega opominjanja.

HR
Min. br. dana prije ponovne pripreme opom. - koliko dana najmanje mora proći, prije ponovne pripreme opomena, između izdavanja dvije opomene bez obzira na ostale kriterije. Vrijedi za sve opomene, namijenjeno je za sprječavanje prečestog opominjanja.

NOVI PRIJEVOD 
Min. br. dana prije ponovne pripreme opom. - koliko kalendarskih dana najmanje mora proći, prije ponovne pripreme opomena, između izdavanja dvije opomene bez obzira na ostale kriterije. Ako je označeno potvrdno polje Radni dani, polje se preimenuje u Min. br. radnih dana prije ponovne pripreme opom. i određuje koliko radnih dana najmanje mora proći prije ponovne pripreme opomena. Vrijednost u tom polju se koristi samo ako je prije pripreme opomena bilo izvedeno plaćanje za ugovor, naime u tom slučaju na temelju te vrijednosti se izračuna datum u polju 'Datum do kojeg se ne opominje' na mapi ugovora. Vrijedi za sve opomene, namjenjeno je za sprječavanje prečestog opominjanja.

*/


ID	WorkCode	Description	Unit	Quantity	Price per unit	Free	Sum
18212	Analysis complex level 1 (h)	Analiza zahtjeva oko automatizacije priprema opomena i izvještavanja	h	15	95 € / h		1.425,00 €
18215	Man-day 760	Podešavanje automatizma izdavanja, ispisivanja opomena, slanja na mail prema zahtjevu	€	3	760 € / €		2.280,00 €
18216	Report/template change advanced (min)	Podešavanje stimulsoft ispisa TEKST OPOMENE TP i edoc podešavanje	min	300	79 € / h		395,00 €
18217	Analysis complex level 1 (min)	Pomoć korisnicima kod testiranja i nepredviđene situacije	min	300	95 € / h		475,00 €



Poštovani, 

možemo podesiti i slanje na mail u sklopu ovog zahtjeva.

Ako želite da se sve automatizira, priprema za kanal PCK će se morati doraditi jer uključivanje i isključivanje EOM blokade nije dobro riješenje tj. ne može se na taj način napraviti automatizacija procesa.
Sada je podešeno
- za FINA partnere opomene s troškom (Invoice tj. račun) da ne idu u PCK (u FINA idu samo opomene s troškom (Invoice tj. račun))
a za ostale partnere 
- opomene s troškom (Invoice tj. račun) uvijek idu u PCK
- opomene bez troška (Reminder) ide u PCK kada je uključena EOM blokada, u suprotnom ne.
Možete nam detaljnije objasniti takav postupak/proceduru za opomene bez troška (Reminder)? Da li opomene s troškom trebaju ići u zaseban kanal te opomene bez troška također u zaseban kanal jer ih različito obrađujete?

S mojim predloženim rješenjem bi onda isključili pripremu opomena (sa i bez troška) iz PCK kanala i pripremali ih u novi poseban kanal (sa i bez troška u isti kanal ili svaki u zaseban ovisno kako vam treba). Time više ne bi bilo bitno kada idu edoc obrade jer će se opomene razlikovati od ostalih računa (Invoice) i dopisa time što će se nalaziti u zasebnom kanalu.
MAIL partneri ne bi išli u novi kanal.
Kada je FINA, onda ne bi išli na novi kanal (slično kako je sada za PCK). 
FINA partneri pak trebaju ići na email kao ste naveli. Da li ima potrebe da klijent primi opomene s troškom (Invoice tj. račun) na mail i preko FINA? 
Da li je ipak potrebno samo podesiti da FINA partneri na mail primaju samo opomene bez troška (Reminder) (jer će račun primiti preko FINA), ako uopće imate takvih slučajeva?

Ne znam koji je stručnjak ovo radio s EOM blokadom, ja ne vidim razloga da se opomene ne podese u zaseban kanal....




Da se fokusiramo samo na kanale FINA, PSK I Ne PCK i MAIL

Znači 

Molim da onda definiramo kako će ići na ostale kanale, tako u slučaju kanala 
1. FINA - da li ide na novi kanal za opomene  te da li ide na MAIL (pretpostavljam da ne)
2. 

Dorada bi onda bila 
- automatsko izdavanje opomena za potraživanje kroz job (prema logici u jobu 15 točka 2.) 
- nakon izdavanja automatski ide ispisivanje/renderiranje 
- opomene sa troškom (računi) i bez troška bi se izvezli u za to namijenjen novi kanal/folder. Što se tiče izvoza opomena u ostale kanale/foldere, ide kao i do sada (osim za opomene na mail navedeno u natuknici ispod). Time ćete opomene (računi i obavijesti) imati u zasebon kanalu uz postojeće (DMS, FINA i PCK). 
Ideja je bila da se više 
- slanje opomena na mail te isključivanje tih opomena iz kanala DMS, FINA i PCK (iz svih kanala)

PCK kanal


NE_PCK





if @DocType = 'Reminder'
begin 
	Select '0042' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN @eom_blockade = 0 Then '0' ELSE '1' End [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_kupca) + '_' + '0042' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	
	

Molimo ponudu za automatizaciju procesa sve do točke br.10.
Bitno je voditi računa da se opomene ne pomiješaju sa drugim dokumentima u eDoc obradi.

1. (JOB) - Mail Obavijesti o pripremljenim opomenama - job id 14 -  Automatska priprema opomena - Working days u 14:00
2. (JOB) - Mail podsjetnik o potrebi izdavanja opomena - job id 15 - Slanje obavijesti o obavezi izdavanja/ispisivanja opomena - Daily u 14:30 , ali mail stiže samo prema skadenci i tada se rade sljedeći koraci. Napomena: opomene se trebaju kreirati za sva moguća dospijeća u sustavu.
GMC: job pokreće xdoc 30. U xdocu SQL EXPORT u [body] je definirano kada se koja opomena izdaje => može se podesiti da kada ide mail, da se umjesto maila pokreće izdavanje samo za određene opomene kako je u tekstu napisano.

3. (Naplata) - NOVA Ispisi/Ispisi opomena - Potvrda/Izdavanje opomena
GMC: prema točki 2 se onda izdavaju opomene

4. (IT) Pražnjenje eDoca- koraci 7 i 8 kako bi se odradili dokumenti na čekanju prije nego se kreiraju dokumenti opomena kako se ne bi pomješali.
GMC: kako zabraniti korisnicima da ne rade printanje niti izdavanje računa koje pokreće printanje??
Mislim da to oko kanala se treba riješiti na razini EDOCa u edoc_processing_plugin, onda EDOC obrade se mogu pustiti kada god.

5. (IT) Uključenje blokade - samo za vrijeme blokade je aktivan kanal PCK
GMC: Mislim da to oko kanala se treba riješiti na razini EDOCa u edoc_processing_plugin, onda EDOC obrade se mogu pustiti kada god.
Prema [filter_field] = 1 ide u print centar.
U edoc_processing_plugin
CASE WHEN @is_for_fina = 1 then '0'
            WHEN @eom_blockade = 0 Or @rac_source in ('SPR_DDV','POGODBA', 'OPC_FAKT','GL_OUTPUT_R') Or (f.id_kupca is not null And @rac_source not in ('ZA_OPOM','DOK_OPOM')) or (e.id_kupca is not null And @rac_source = 'NAJEM_FA' And v.sif_terj = 'LOBR') Then '0'
            ELSE '1' End [edoc.filter_field],

Zvao Dalibora, Dalibor uključi @eom_blockade i tako definira na koji kanal ide.
Za opomene sam mu predložio da se otvori zaseban kanal, rekao je da može i takvo riješenje (ostavljeno nama odabir tehničkog rješenja) i da uz opomene ima i druge paketne obrade koje bi onda mogli slati u isti kanal (dopisi i sl.).

6. (Naplata) NOVA Ispisi/Ispisi opomena -  Ispis opomena - Kreiraju se PDF dokumenti na edoc\edoc_dsa  U ovom dijelu molimo da razmislite na koji način će se kreirani fileovi fizički moći odvojiti da se slučajno ne dogodi da se u vrijeme obrade opomena kreira neki drugi dokument koji je nevezan za opomene
GMC: kako zabraniti korisnicima da ne rade printanje niti izdavanje računa koje pokreće printanje??
Ako riješimo kroz drugi kanal, EDOC obrada više neće biti problem.

7. (IT) NOVA eDoc obrade - Prva  eDoc obrada - Kreiraju se XML dokumenti za svaki PDF i prebacuju na edoc\edoc_main
8. (IT) NOVA eDoc obrade - Druga eDoc obrada - Slanje dokumenata na kanale - DMS, PCK, FINA
9. (IT) Isključenje blokade
10 (IT) Priprema za PCK
11. (IT) Slanje u PCK
12. (IT) Mail za PCK  

io_channels 
EDOC_DSA                      	Edoc dsa Folder	d:\nova_prod\IO\edoc\edoc_dsa\		0		EDOC                	
EDOC_EXPORT                   	EXPORT for edoc module	\\rledms-p\eDoc\EXPORT\		1		EDOC                	
EDOC_EXPORT1                  	Edoc export channel for DMS	\\rledms-p\eDoc\DMS\		1		EDOC                	
EDOC_EXPORT2                  	Edoc channel for print center.	\\rledms-p\eDoc\PCK\		1		EDOC                	
EDOC_EXPORT3                  	Edoc channel for export	\\rledms-p\eDoc\Ne PCK\		1		EDOC                	
EDOC_EXPORT4                  	Edoc channel For Web	\\rledms-p\eDoc\WEB\		1		EDOC                	
EDOC_MAIN                     	Edoc main processing folder	d:\nova_prod\IO\edoc\edoc_main\		0		EDOC                	
EDOC_MANAGER                  	Tool for processing electronic documents: compressing, copying and moving files, transfer to FTP, sending mails to designated receivers.			0	NULL	NULL	
EDOC_PS                       	Export postscript reports			1	NULL	EDOC                	NULL

id_edoc_channel description io_channel_code active handler_class handler_params is_batch_export files_must_be_signed GDPR_relevant id_export_destination
EDOC_EX1                       ZA DMS EDOC_EXPORT1                   1 GMI.EdocEngine.SimpleBatchExporter,gmi_edoc_engine filter_metadata_field=edoc.dms;filter_metadata_value=1 1 0 NULL NULL
EDOC_EX2                       ZA PRINT CENTAR EDOC_EXPORT2                   1 GMI.EdocEngine.SimpleBatchExporter,gmi_edoc_engine dont_copy_xml_files=true;destination_must_be_empty=false;ignore_duplicates=false;file_name_metadata=print_centar_name;filter_metadata_field=edoc.filter_field;filter_metadata_value=1 1 0 NULL NULL
EDOC_EX3                       NE ZA PRINT CENTAR EDOC_EXPORT3                   1 GMI.EdocEngine.SimpleBatchExporter,gmi_edoc_engine dont_copy_xml_files=true;destination_must_be_empty=false;ignore_duplicates=false;file_name_metadata=print_centar_name;filter_metadata_field=edoc.not_print;filter_metadata_value=1 1 0 NULL NULL
EDOC_EX4                       ZA WEB (SAMO RATE) EDOC_EXPORT4                   1 GMI.EdocEngine.SimpleBatchExporter,gmi_edoc_engine dont_copy_xml_files=false;destination_must_be_empty=false;ignore_duplicates=false;filter_metadata_field=edoc.for_web;filter_metadata_value=1 1 0 NULL NULL
EDOC_EX5                       Export channel to mail (TaxchngIx) EDOC_EXPORT                   1 GMI.EdocEngine.EdocToXdocExporterBatch,gmi_edoc_engine id_xdoc_template=57; 1 0 NULL NULL
EDOC_EXPORT_FINA               Export channel to FINA HR_SLOG_DSA                   1 GMI.EdocEngine.SimpleBatchExporter, gmi_edoc_engine dont_copy_xml_files=false;destination_must_be_empty=false;ignore_duplicates=false;filter_metadata_field=fina.is_for_fina;filter_metadata_value=true 1 0 0 NULL





title description pre_eval_sql cmd
1. Priprava Opominov 1. Priprava Opominov SELECT dbo.gfn_GetDatePart(GETDATE()) AS TargetDate <reminders_generate xmlns="urn:gmi:nova:leasing">    <dat_prip>${TargetDate}</dat_prip>    <reminder_types>   <id_za_opom_type>1</id_za_opom_type>    </reminder_types>    <reminder_types>   <id_za_opom_type>2</id_za_opom_type>    </reminder_types>       <reminder_types>   <id_za_opom_type>17</id_za_opom_type>    </reminder_types>  </reminders_generate>
2. Izdaja Opominov 2. Izdaja Opominov Select  isnull( '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' +  + '<' + replace(replace(replace(SUBSTRING(  (       SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      FROM  dbo.za_opom    where st_opomina in (1,2,3)    and oznacen = 0    FOR XML PATH('')   ), 2 , 9999),'&lt;','<'),'&gt;','>'),'lt;','') + '</issue_reminders>',  '<issue_reminders_nlb_wrapper xmlns="urn:gmi:nova:si_nlb">  <with_costs>true</with_costs>  <id_opom_list_as_string></id_opom_list_as_string> </issue_reminders_nlb_wrapper>' )
3. dnevna rutina PRIPRAVA DOGODKOV ZA OPOMINE 3. dnevna rutina PRIPRAVA DOGODKOV ZA OPOMINE <?xml version="1.0" encoding="utf-16"?>  <opom_dog xmlns="urn:gmi:nova:si_nlb">    <insert_arh_opravki>true</insert_arh_opravki>  </opom_dog>
4. Edoc izvozi 4. Edoc izvozi select code from ( select '<prepare xmlns="urn:gmi:nova:xdoc"> <xdoc_template_id>3</xdoc_template_id> <perform_commit_automatically>true</perform_commit_automatically> </prepare>' as code, 1 as vrstni_red union select '<prepare xmlns="urn:gmi:nova:xdoc"> <xdoc_template_id>5</xdoc_template_id> <perform_commit_automatically>true</perform_commit_automatically> </prepare>' as code, 2 as vrstni_red union select '<prepare xmlns="urn:gmi:nova:xdoc"> <xdoc_template_id>6</xdoc_template_id> <perform_commit_automatically>true</perform_commit_automatically> </prepare>' as code, 3 as vrstni_red ) a order by a.vrstni_red asc
5. Edoc 1. obdelava 5. Edoc 1. obdelava <split_file xmlns='urn:gmi:nova:edoc-engine' />
6. Edoc 2. obdelava 6. Edoc 2. obdelava <export_file xmlns='urn:gmi:nova:edoc-engine' />
7. Epps izvoz datotek 7. Epps izvoz datotek <epps_zip_and_send_to_ws xmlns="urn:gmi:nova:si_nlb">  <edoc_channels>EDOC_EPPS</edoc_channels>  <edoc_channels>EDOC_EPPS_ODPOVED</edoc_channels>  <edoc_channels>EDOC_EPPS2</edoc_channels>  <mailTo>izterjava@nlbleasego.si</mailTo>  </epps_zip_and_send_to_ws>

1.
Već imaju job
Automatska priprema opomena
DECLARE @target_date datetime, @id_za_opom varchar(1000)

SELECT @target_date = dbo.gfn_GetDatePart(getdate())

SET @id_za_opom = (SELECT id_za_opom_type FROM dbo.za_opom_type FOR XML PATH('reminder_types'))

SELECT
'<reminders_generate xmlns:xsd="http://www.w3.org/2001/XMLSchema"; xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"; xmlns="urn:gmi:nova:leasing">
<dat_prip>' + CONVERT(varchar(100), @target_date, 126) + '</dat_prip>
' + @id_za_opom + '
</reminders_generate>'
WHERE @target_date <> dbo.gfn_FirstWorkDay(dbo.gfn_GetFirstDayOfMonth(@target_date))
<reminders_generate xmlns:xsd="http://www.w3.org/2001/XMLSchema"; xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"; xmlns="urn:gmi:nova:leasing"> <dat_prip>2023-03-13T00:00:00</dat_prip>  <reminder_types><id_za_opom_type>1</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>5</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>6</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>7</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>8</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>9</id_za_opom_type></reminder_types> </reminders_generate>


2.
Da se podesi da se u 2. jobu koji generira opomene, da se pokrene sljedeći job (4. ) koji ispisuje opomene ?
issue_reminders_nlb_wrapper se izvršava ako nema opomena, možda bolje da se okine isti element bez LIST => u oba slučajeva bez liste se javlja ERROR
GMI.Core.GmiException: Error while handling ProcessXml request: The element 'issue_reminders' in namespace 'urn:gmi:nova:leasing' has invalid child element 'id_opom_list_as_string' in namespace 'urn:gmi:nova:leasing'.
pa bi trebalo podesiti da vrati ili prazno (TESTIRATI) ili bez redova (ovo je sigurno u redu)

na kraju liste budu dva znaka <</issue_reminders> => da li je to bug?
Select  isnull( '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>'
+ '<' + replace(replace(replace(SUBSTRING(  
(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
FROM dbo.za_opom    
where st_opomina in (1,2,3)    
and oznacen = 0    
FOR XML PATH('')   )
, 2 , 9999),'&lt;','<'),'&gt;','>'),'lt;','')
+ '</issue_reminders>'
,  '<issue_reminders_nlb_wrapper xmlns="urn:gmi:nova:si_nlb">  <with_costs>true</with_costs>  <id_opom_list_as_string></id_opom_list_as_string> </issue_reminders_nlb_wrapper>' )
<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs><list>17675369</list> <list>17675370</list> <list>17675371</list> <list>17675372</list> <list>17675373</list> <list>17675374</list> <list>17675378</list> <list>17675380</list> <list>17675381</list> <list>17675382</list> <list>17675383</list>
...
<list>17675670</list> <list>17675671</list> <list>17675672</list> <list>17675674</list> <list>17675675</list> <list>17675676</list> <list>17675677</list> <list>17675678</list> <list>17675679</list> <list>17675680</list> <</issue_reminders>

SUBSTRING je do 9999 !? => bolje je koristiti STUFF

Da li se lista cijepa ili idu svi?? ili izdavati jednu po jednu ?
Jer na NOVA_TEST sam imao 7000 zapisa (realno neće nikada biti tako, ali nisu se mogli svi kandidati prikazati u Resolt (samo do 65000 znakova)
=> pogledao u FOXu i lista se kreira za sve (ne cijepa se) pa bi iz kroz SQL trebalo biti ok => TESTIRAO MOŽE PREKO 7000 ZAPISA
=> Testirao i kada nem akandidata za izdavanje, javlja se greška ako nema kandidata jer mora biti neku processXML (ne može biti NULL ili prazan string '' ili bez list elementa npr. <issue_reminders xmlns="urn:gmi:nova:si_nlb">  <with_costs>true</with_costs>  <id_opom_list_as_string></id_opom_list_as_string> </issue_reminders>)
Tako da bi trebalo kroz XDOC ili naći neki Processxml koji "ništa ne radi"
Svakako treba hendlat i takav slučaj da nema ProcessXml-a
--DORAĐENI
declare @broj_opomena int = (SELECT count(*) as broj_opomena FROM dbo.za_opom where st_opomina in (1,2,3) and isnull(dok_opom, '') = '')  --and oznacen = 0

if @broj_opomena > 0
begin
Select  '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>'
+ '<' + replace(replace(replace(STUFF(  
(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
FROM dbo.za_opom    
where st_opomina in (1,2,3)    
--and oznacen = 0
and isnull(dok_opom, '') = ''
order by st_opomina, id_opom
FOR XML PATH(''))
, 1, 1, ''),'&lt;','<'),'&gt;','>'),'lt;','')
+ '</issue_reminders>'
end

-- BEZ STUFF PRIMJER
--declare @broj_opomena int = (SELECT count(*) as broj_opomena FROM dbo.za_opom where st_opomina in (1,2,3) and isnull(dok_opom, '') = '')  --and oznacen = 0

if @broj_opomena > 0
begin
Select  '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>'
+ replace(replace(replace(
(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
FROM dbo.za_opom    
where st_opomina in (1,2,3)    
--and oznacen = 0
and isnull(dok_opom, '') = ''
order by st_opomina, id_opom
FOR XML PATH(''))
,'&lt;','<'),'&gt;','>'),'lt;','')
+ '</issue_reminders>'
end

4.
Nakon izdavanja, renderiranje bi trebalo ići kroz event ili je ipak bolje rješenje XDOC? => ako je Invoice u eventu, onda bi možda bilo bolje da kroz event idu i opomene bez troška (event ReminderWithNoCostAfterIssue )


5. i 6.
za edoc obradu bi bilo najbolje da se pokrene naš job tj. naš ProcessXml
declare @date datetime = dbo.gfn_GetDatePart(getdate())

select '<perform_edoc_processing_simple xmlns="urn:gmi:nova:edoc-engine">' +char(13)
+'<process_pending_docs>true</process_pending_docs>' + char(13)
+'<process_exports>true</process_exports>' +char(13)
+'</perform_edoc_processing_simple>'
from dbo.jm_job
where id_job = 2
and @date != dbo.gfn_FirstWorkDay(dbo.gfn_GetFirstDayOfMonth(@date))

