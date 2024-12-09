Ako ćete kod reprograma raditi kao pod točkom 2, u slučaju ciljeva a) i b) po meni nije potrebno proširivati plan otplate, podaci su zapisani analitički u drugoj tabeli i kao takvi se mogu koristiti. 


4. Da li će vam uopće trebati prikaz povijesnih podataka (podaci za ugovor prije reprograma)? Sada za takve slučajeve provjeru stanja ugovora u prošlosti imate snimke stanja, tako da niti ovo ne bi bilo ovakav izvještaj ne bi trebalo biti drugačije evidentiran


Oko vašeg prijedloga rješenja, s obzirom da može biti više (n) vrsta dodatnih troškova, to bi značilo da treba u plan otplate dodati po jednu kolonu za svaki trošak te kada se kreira nova vrsta troška da se onda ponovno doda nova kolona, a kod deaktivacije vrste troška u šifrantu troška se onda ta kolona ne bi više koristila u planu otplate, iz navedenog i općenito smatramo da dodavanje n kolona u plan otplate za svaki trošak nikako nije dobro rješenje jer utječe na strukturu i funkcionalnost cijele aplikacije, praktički bi ta dorada bila veća od dorade koju smo imali kod uvođena PPMVa.
Po meni takva analitika bi se i dalj mogla voditi u odvojenoj tabeli, trebala bi se kreirati veza između pojedine rate i pojedinih troškova. 

(po broju ponude ili u slučaju reprograma po  broju reprograma )




 select   fa.id_cont,sum(dbo.gfn_xchange( '000' ,s.mes_obr,s.id_tec,fa.DATUM_DOK)) as 'RL FM IFA SAMO ZA DIO USLUGA' 
 into #izlaz
 from NAJEM_FA fa
 inner join (select id_cont,id_tec, SUM(mes_obrok) mes_obr from gv_dodstrpogodba where id_vrst_dod_str in ('03','04','12','08','11','13','10','09') group by id_cont,id_tec) s on s.id_cont=fa.id_cont
  where fa.ID_TERJ='21' and fa.DATUM_DOK <= GETDATE() 	
    group by fa.id_cont
	
DATUM_DOK, OSTALI XCHANGE IDE PO DAT_SKLEN



Poštovana/i, 

oko pitanja 
"Postoji li mogućnost selekcije ili grupiranja starih i novih te storniranih podataka radi kontrole?"
na pregledu se po bojama vidi koje su razlike, a u koloni "Uneseno" je prikazan datum kada je trošak unesen (datum unosa) pa možete po tom podatku raditi selekciju (F8) ili sortiranje. Stornirani iznosi imaju negativni predznak pa možete po tome raditi selekciju (F8 - Selekcija), slika u privitku.  
Ovo bi se isto odnosilo i na vaša pitanja u excel datoteci:
"1.grupiranje/selekcija po boji - provjera
2.stara ponuda da se ne vidi, izbriše?
3.zeleno- ispis na rati"
Prikaz takvih troškova ako vam navedeno iznad ne odgovara, onda bi mogli napraviti poseban izvještaj s odgovarajućim kriterijima pretrage pa molimo da nam iste definirate kao i kolone na izvještaju (jer u sistemskom prikazu nije predviđena mogućnost takve selekcije te se u biti prikazuju svi troškovi sa ugovora). 
Dodatno, s obzirom da imate izvještaj "(FM) Fleet izvještaj" da li vam je potrebno takvo isključivanje prikaza starih troškova?

Oko 
"4.postoji li mogućnost da se upiše broj nove ponude pa da se pokupe  svi podaci, a ne pojedinačni upis"
takva mogućnost trenutno ne postoji. Ako ti slučajevi nisu česti, da li ih možete raditi ručno?

Oko 
"Na prozoru Predviđeni troškovi  sada se ne prikazuju predviđeni troškovi koji se odnose na prethodnih 10 mj trajanja ug koje smo klijentu fakturirali u rati, pa se sada dobiva krivi iznos ukupnih predviđenih troškova po ugovoru(3.663,15 vs 5.133,95)." 
na prozoru se prikazuju svi troškovi njih 70 zapisa (i oni stornirani) tako da je ukupna suma sada 3.663,23 što odgovara novom stanju. Stare troškovi bi bili oni uneseni s ponude tj. bijeli zapisi s pregleda Pregled predviđenih dodatnih troškova tj. na olovčica kojima je "Uneseno" 21.09.2020 (novi troškovi su uneseni 21.09.2021 točno godinu dana kasnije).

U excelu u listu "FLEET IZVJEŠTAJ" za kolone (označeno crvenom bojom):
- Početna vrij ppmv (EUR) => tu se prikazuje podatak s ugovora (početna vrijednost). To bi onda trebalo doraditi da ide trenutna vrijednost mada je sam naziv kolone početna vrijednost? 
- Otkup (EUR) => tu se prikazuje podatak s ugovora (početna vrijednost). To bi onda trebalo doraditi da ide trenutna vrijednost iz plana otplate? 
- Leasing rata neto (EUR) i Ppmv rata (EUR) => podaci prve rate iz plana otplate, to bi trebalo doraditi da idu podaci npr. sa zadnje izdane rate?
Da li su ostali podaci u redu?

Oko izvještaja "(FM) Fleet izvještaj" u ovakvim slučajevima ugovora s reprogramom će podaci gledani da današnji dan onda biti dobri? To bi također značilo da ako se ista logika napravi na ispisima računa da će isto tako podaci biti dobri. 
Da li ćete trebati povijesne podatke s tog izvještaja? Ako ćete trebati povijesne podatke, da li možete te podatke periodički prebacivati u excel i raditi backup ili da mi provjerimo oko mogućnosti zapisivanja takvih povijesnih podataka?

$SIGN 

Da testiraju i prolongaciju, bez storna troškova (onda će suma troškova biti ok ali na izvještaju neće) i sa stornom troškova (onda suma troškova neće biti ok ali na izvještaju će biti ok) što će vam više odgovorati.


poseban izvještaj na kojemu bi se stornirali troškovi (više njih odjednom) i dodatna rutina kojom bi se prebacivali troškove s stare ponude
Ili samo prijenos a rutina će istovremeno stornirati sve troškove 


dodatne usluge na ponudi su unijeli u eurima pa je tečaj nebitan.
Nisu unijeli podatke u predviđene troškove tako da ne znamo kako bi se moralo podesiti generiranje tj. koliko da se stornira i koliko je novi zapis, na kraju suma PT bi trebala biti ista kao na novoj ponudi.
Veza između reprograma i ponude 0254671 je broj odobrenja 0037183 (u odobrenjima još ima 0037182, 0037184)                                                          
Jednoznačna veza između st_dok-ova generiranih reprogamom odobrenim 0037183 i tih dodatnih troškova ne postoji. Prvih 5 rata ima troškove po originalnoj ponudi, ostale reprogramirane imaju troškova po novoj 0254671 tj. odobrenju 0037183. 

Mišljenja sam da da bi se takva evidencija/veza mogla uspostaviti u novoj tabeli, slično kao u dbo.zirniki_najem_fa za zbirne račune, prema id_reprogram -a.

TEŠKO JE DOBITI DA SE NOVA EVIDENCJA UKOMPONIRA NEPRIMJETNO SA TRENUTNOM EVIDENCIJOM (slićno se desilo s prodavačima i provizijama gdje je sve pokušano staviti u iste tabele te je dosta zakompliciralo rad).

Već imamo dbo.DOD_STR_POGODBA u kojem imamo id_cont, pa bi mogli dodati kolonu ID_REPROGRAM u kojoj bi se označavalo da ti troškovi su nastali na temelju tog reprograma. Drugi način je prema odobrenju unesenom na reprogramu, ovaj pristup ne zahjteva promejnu tabele DOD_STR_POGODBA.
Funkcije se dorade da prikazuju sve samo kad taj id_reprogram IS NULL.
A klijentu doraditi da u slučaju da imaju troškove kod prikaza usporedbe troškova se prikazuju ....