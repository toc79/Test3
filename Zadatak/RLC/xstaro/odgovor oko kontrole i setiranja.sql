Poštovani, 
popravili smo kontrolu na testu i produkciji. Poruka se javljala u slučaju ugovora načina leasinga koji nije F1, ali je financijski (npr. F4 ili F5) što pak nije bilo ispravno. Sada je poruka usklađena s logikom koja postavlja podatak općih uvjeta. 

Dodatno oko kontrola u koraku spremanja podataka oko općih uvjeta, 
ona je podešena da još jednom radi provjeru unesenih/postavljenih općih uvjeta u polju 'Opći uvjeti' te ako nije ispravan, ponovno postavlja podatak općih uvjeta (mada to nije vidljivo odmah na masci u polju 'Opći uvjeti' nego tek kada se klikne u to polje, čime će se promijeniti na podatak koji je u "pozadini" zadan te je zato zapis u bazi OK kako ste naveli). 
Ovo dodatno postavljanje i provjera je napravljena iz razloga 
- što ponuda ne mora imati unesenog partner iz šifranta (sa šifrom partnera) i tada prilikom setiranja broja općih uvjeta u kontroli koja se pokreće nakon unosa broja ponude, se ne zna o kojoj vrsti osobe se radi (u takvim slučajevima se postavi vrijednost šifranta 02 (0317)), 
- ili ako se promijeni partner (šifra partnera) kod unosa ugovora nakon unosa ponude. 

S obzirom da se vama uvijek postavlja vrijednost općih uvjeta i pretpostavljam da ne želite da korisnici mogu mijenjati isti, predlažem da se naprave sljedeća podešavanja: 
1. da se polje 'Opći uvjeti' na ugovoru onemogući za unos/promjenu 
2. za slučajeve ponuda koje nemaju unesenu šifru partnera, možemo doraditi postavljanje općih uvjeta u koraku unosa broja ponude:
a) da se provjerava podatak (checkbox) 'Fizička osoba' sa ponude/kalkulacije (tako je označeno na ponudi 0217815) na način da ako je označen, da se početno na ugovoru postavlja vrijednost šifranta 01 (F0317), u suprotnom (02 0317). 
Time će se kod unosa ugovora odmah postaviti ispravna vrijednost. 
b) ako ne želite da se provjerava podatak (checkbox) 'Fizička osoba', tada bi promijenili postojeću funkcionalnost (postavljanje vrijednosti šifranta 02 (0317)) i to da opći uvjeti budu prazni, a njihovo postavljanje će raditi kontrola u koraku spremanja ugovora (kao do sada).

U slučaju kada je na ponudi unesena šifra partnera, postavljanje na ugovoru će raditi ispravno kao do sada. 

3. U slučaju da se promijeni šifra partnera na ugovoru (npr. sa fizičke na pravnu), postojeća kontrola u koraku spremanja podataka će automatski napraviti promjenu i u tom slučaju bi napravili da se prikaže informativna poruka o tome (ili ako želite da se promjena/postavljanje radi bez prikaza poruke čime onda se funkcionalnost se ne bi mijenjala). 
Ova poruka s početka zahtjeva koju smo popravili zapravo nema funkciju zato što se uvijek radi postavljanje pa bi ju maknuli. 

Tomislav Krnjak 
Održavanje / Support 

Gemicro d.o.o. 
Nova cesta 83, HR-10000 Zagreb, Hrvatska 
T: +385 (0)1 3688983 
F: +385 (0)1 3688979 
www.gemicro.hr