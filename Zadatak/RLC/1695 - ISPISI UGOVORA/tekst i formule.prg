Poštovani, 
popravili smo kontrolu prvo samo na testu koja postavlja vrijednosti polja 
'Dozvoljen br. km' i 'Cijena dodatnog km' 
u 
35000 i 0,15
nakon odabira broja ponude. 

Prvo samo na testu iz razloga što navedena kontrola je napravljena da sljedećim aktivnim tipovima lesainga 
NF	Zakup/najam nekrenine - vraćeno iz financ. Leasing
NO	Zakup/najam nekrenine - vraćeno iz operat. Leasing
OA	AKONTACIJA - OPERAT.LEAS.                         
OG	OPERATIVNI LEAS.-GRUPA                            
OJ	JAMČEVINA - OPERAT. LEASI                         

podesi te vrijednosti. U kontroli naime nisu navedeni tipovi leasinga nego je napravljeno prema specifičanoj postavki u tabeli tipova leasinga (prema tipu knjiženja koji je specifičan za operativni leasing). Također, navedene vrijednosti polja ne ovise o podacima unesenim na ponudi nego se postavljaju s obzirom na gore navedenu logiku.

S obzirom da tipovi NF i NO to ne bi trebali imati (moja pretpostavka), predlažem da doradimo kontrolu da se navedene vrijednosti polja ostavljaju samo za tipove leasinga OA, OG i OJ.
Druga opcija bi bila da se provjeri mogućnost postavljanja s obzirom na podatke ponude. Onda se na ponudi može napraviti slična kontrola oko broja u nosa u navedenim poljima.

Oko detalja me možete kontaktirati na telefon.

select b.neaktiven, a.* 
from nacini_l a
join KALK_FORM b on a.nacin_leas = b.nacin_leas
where a.tip_knjizenja = 1 
and b.neaktiven = 0
 
select * from arh_ext_func where id_ext_func = 'POGODBA_MASKA_SET_DEF_VALUES' order by DateOfModification 

Diana, 

molim otvoriti novi zahtjev za ispise svih vrsta ugovora kako je dolje priloženo. 

Potrebno je pripremiti: 
1. EIB - operativni i financijski leasing - u word-u 
2. Financijski leasing KTA R1 za potrošače i pravne osobe - word i direktan ispis 
3. Financijski leasing PPOM - word i direktan ispis (F4 koji se printa iz KTA R1) , ali ima uvjetovan članak vezano uz porezni tretman 
4. Financijski leasing KTA R1 - HBOR - HRK - samo u word-u 
4. Operativni leasing - direktan i word ispis, te stimulsoft ispis (NOVO) radi mogućnosti tiska više ugovora odjednom ( uz ovaj zahtjev veže se i zahtjev za OSTATAK VRIJEDNOSTI - prilagodba i ponude i ugovora) 
5. Molim brisati iz izbornika word ispis - KTA R1- EBRD da ne zbunjuje, jer se ne koristi - print screen dolje 
6. Također je potrebno staviti u sustav novi broj općih uvjeta 0317 

Molim posebno obratiti pažnju da ostanu uvjeti kao i do sad: 
- ukoliko se bira EURIBOR - I (izvedeni) tada financijski leasing za pravne osobe ima poseban članak u financijskom leasingu 
- ukoliko se radi o PPOM financijskom leasingu ispisuje se dio koji se odnosi na porezni tretman 
- ukoliko je ugovor s PPMV-om ili bez PPMV-a u ispisu je to izraženo 

Posebno ćemo nakon testiranja dogovarati stavljanje na produkciju u popodnevnim satima kako ne bi došlo do pogreške - novi ugovori i novi opći uvjeti. 


Poštovani, 
u prilogu vam šaljemo ponudu za doradu ispisa (prema promjenama označenim u primjerima u prilogu) od tč. 1 do točke 4.b): 
1. 'Ugovor  - Financijski - KTA R1 - EIB' i 'Ugovor - Operativni leasing EIB'

2. i 3.  'Ugovor - Financijski - KTA R1' i 'UGOVOR' 

4. 'Ugovor - Financijski - KTA R1 - HBOR - HRK'

4. b) (u vašem mailu dvije točke imaju broj 4) 
'Ugovor - Operativni leasing' i 'Ugovor - Stimulsoft'. 
Oko direktnog ispisa, s obzirom da ste potvrdili ispravnost ispisa 'Ugovor - Stimulsoft', predlažem da se onda ne radi dorada direktnog ispisa, nego s podešavanjem ssoft ispisa 'Ugovor - Stimulsoft' na produkciji da se direktni ispis makne. 

5. Ispis 'Ugovor - Financijski - KTA R1 - EBRD' smo maknuli na testu i produkciji.

6. Za nove brojeve općih uvjeta smo vam u Posebnom šifrantu kreirali novi ID šifarnika = 'RLC_OPCI_UVJETI' te ćete moći sami mijenjati te vrijednosti, koje će se onda predlagati kod unosa ugovora. Za posebni šifrant imate sada funkcionalnost pregleda/popravka/brisanja zapisa prema pojedinim korisnicima/rolama. 
Ključ 01 predstavlja opći uvjet F0216, a ključ 02 predstavlja opći uvjet 0216.
Time ćete dakle moći sami promjeniti opće uvjete na željene (F0317 i 0317) te će isto biti vidljivo kod unosa ugovora i spremanja podataka neaktivnog ugovora.

Oko kontrola koje setiraju opće uvjete na ugovoru, da li će uvijek biti takvi opoći uvjeti tj. korisnik nikada ne smije mijenjati iste (ovo pitam iz razloga da odgovorajuće podesim kontorlu).

$SIGN







