Poštovani, 
u pravu ste, nakon prijenosa podataka o štetama se takvim zapisima ponovno zapiše broj štete.

Oko 3 prefakture iz 4 mj. (28.04.) za koje niste uspjeli napraviti prijenos, s obzirom na postavku datuma, je jedino rješenje da te prefakture mi ubacimo kroz bazu. U prilogu vam šaljemo ponudu za navedeno.
Oko uknjižbe unesenih u GL, vi bi ih nakon toga morali odgovarajuće nulirati (brisanje tih podataka iz pregleda podataka o štetama nije moguće, zato jer one postoje u GL te i ako napravimo brisanje, iste će nakon prijenosa podataka o štetama ponovno prikazati/dodati na štetu).

$SIGN

gsp_ss_odskodr

46484/14
00011839

GL
ZAV uknjižbe
- brisanjem INTERNA VEZA na uknjižbi, u ss_odskodr za ZAV će se ponovno na prethodno razvezenom zapisu zapisati broj štete
- brisanje broja ugovora na uknjižbi, u ss_odskodr za ZAV se na prethodno razvezenom zapisu neće zapisati broj štete -> GLAVNI KRITERIJ JE BROJ UGOVORA TAKO DA JE ZA TRAJNO RAZVEZIVANJE POTREBNO RAZVEZATI BROJ U XXXXXXX I OBRISATI BROJ UGOVORA S TE UKNJIŽBE U GL. To je dogovoreno s Josipom da im to ne nudimo/navodimo zato što će im se povećavati broj tih XXXXX šteta, bolje je da nuliraju te neodgovarajuće uknjižbe i vežu na štetu. Saldo će biti 0 te će se šteta naposlijetku zatvoriti.






imam jedan bedasti zahtjev od rlc gdje su mi javili da stavim u status mirovanje, da ga ostavim paused ili ćemo zatvoriti i ponovno otvarati. S obzirom na povijest problematike oko popunjavanja tog podatka (i Omar je kreirao ext_func u jednom ranijem zahjtevu) mislim da će biti teško napraviti točnu logiku za kontrole (ili kroz doradu njihova tri izvještaja) zato jer uno