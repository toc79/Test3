Poštovani, 

izvještaj iz snimke stanja 367: (AC-IZ) Present Value - sumarni pregled potraživanja po ugovorima (DW) radi iz snimke stanja i kolone: 
"PO - Dat. zadnje rate" - Datum dokumenta zadnje rate iz plana otpl. 
"PO - Br. obroka/rata" - Broj obroka/rata iz plana otplate 
"PO - Dat. Otkupa" - datum dokumenta iz plana otplate 
se ne mogu dobiti iz snimke stanja tako da je jedini način da napravimo izvještaj koji će dobiti dio podataka iz snimke stanja, a dio iz produkcije na dan pokretanja izvještaja. To je ono što vam možemo odmah ponuditi.

Druga varijanta je da tražimo ponudu od kolega iz Slovenije vezanu uz dodavanje kolona koja su vama potrebne u pripremu snimke stanja, o čemu ćemo se javiti povratno nakon što kolege iz Slovenije naprave analizu i provjere da li je takva dorada pripreme za snimku stanja moguća.

Što se tiće ostalih polja/kolona u excelu, ona koja su označena 'Iz ugovora' se mogu dodati na izvještaj.

Oko budućih iznosa za kolone 
"Tren. bud otkup neto" - Iznos otkup bez pdva i bez PPMV iz plana otplate 
"Tren. bud otkup-iznos PPMV" - Iznos PPMV-a iz stavke otkup iz otplatnog plana
ti podaci se mogu dobiti, a u slučaju da je potraživanje dospjelo/zatvoreno/plaćeno, prikazali bi iznos 0. 

$SIGN 







Poštovani, 

a) Za podatak iz Ugovora - "Ostatak vrijednost" - na mapi ugovora se 'Ostatak vrijednosti' izračunava kao 'Otkup' na koji se zbraja 'Jamčevina' u slučaju tipova financiranja (za koje je moguće unijeti jamčevinu na kalkulaciji): OA, OG ,OJ (i OP, koji je neaktivan). Za ostale ne. Tako bi onda i mi podesili na izvještaju i to podatak pod odlomkom 'Kod sklapanja'. 

Nadalje oko ostalih polja u excelu, ona koja su označena 'Iz ugovora' se mogu dodati na izvještaj.
Za ostala polja postoje određena ograničenja s obzirom da se u snimkama ne sprema plan otplate, već se spremaju podaci samo o potraživanjima koja nisu zatvorena (proknjižena i buduća potraživanja), dok potraživanja koja su već zatvorena/plaćena se ne spremaju (u snimci nemamo tih podataka). Zato sam nadalje u tekstu za svako polje naveo koje su mogućnosti tj. koje podatke imamo spremljene u snimci stanja. 
Tako za polje: 
b) 'PO - Dat. zadnje rate - Datum dokumenta zadnje rate iz plana otpl.' 
1) u slučaju da je ugovor istekao (zatvorene su sve rate) ili je zaključen, tada za ugovor nema podataka o potraživanju, pa se ne može dobiti točan podatak. Da li je to u redu da u takvim slučajevima bude prazan podatak na izvještaju? 
Kao treća opcija, postoje još neki podaci ugovora koje se spremaju u snimku i možda bi vam ti odgovarali u slučaju ugovora koji imaju zatvorena sva potraživanja i riječ je o sljedećim: 
2) Zadnji datum dokumenta potraživanja koje nije otkup (Maximum document date (datum_dok) for this contract. Buy out is excluded) - za OL bi to trebao biti datum zadnje rate, ali za FL će to biti praktički otkupna rata zato jer se pod otkup smatra potraživanje 23 pa se ne može koristiti za to; 
3) Zadnji datum dokumenta potraživanja (Maximum document date (datum_dok) for this contract. End date for this contract) - ovo bi za OL i FL trebao biti datum otkupa; 

ali ti podaci imaju mali nedostatak, npr. ako se poslije zadnje rate fakturira zatezna kamata ili 'OBRAČUN za korištena sredstva', tada će se prikazati taj datum (zato što je to zadnje potraživanje), tako da ako se odlučite za neki od navedenih podataka, morate imati na umu logiku po kojoj se on spremio u snimku. 

c) 'PO - Br. obroka/rata - Broj obroka/rata iz plana otplate' - ne može se dobiti točan podatak (zbog razloga navedenih iznad u drugom odlomku). Može se prikazati podatak s ugovora. 

d) 'PO - Dat. Otkupa - datum dokumenta iz plana otplate' - u slučaju ugovora koji imaju zatvorena sva potraživanja se ne može se dobiti točan podatak (zbog razloga navedenih iznad u drugom odlomku). Može se dobiti podatak iz ugovora ili neki od gore navedenih u točkama od 1 do 3. 

e) 'Tren. bud otkup neto - Iznos otkup bez pdva i bez PPMV iz plana otplate' -> iznos budućeg otkupa se može dobiti. U slučaju da je potraživanje zatvoreno/plaćeno, prikazali bi iznos 0. Druga opcija je da se uzme 'Iz ugovora' (ili Iz ugovora samo u slučaju ako je npr. zatvoreno potraživanje), ali u tom slučaju nije moguće dobiti točan iznos bez PDVa i PPMVa. 

f) 'Tren. bud otkup-iznos PPMV - Iznos PPMV-a iz stavke otkup iz otplatnog plana' -> iznos budućeg otkupa i PPMVa u otkupu se može dobiti. U slučaju da je potraživanje zatvoreno, prikazali bi iznos 0. 


Nakon što definiramo logiku prikaza podatka, tada bi vam pripremili ponudu. 

Tomislav Krnjak 
Održavanje / Support 

Gemicro d.o.o. 
Nova cesta 83, HR-10000 Zagreb, Hrvatska 
T: +385 (0)1 3688983 
F: +385 (0)1 3688979 
www.gemicro.hr




Poštovani, 
a) Za podatak iz Ugovora - "Ostatak vrijednost" - na mapi ugovora se 'Ostatak vrijednosti' izračunava kao 'Otkup' na koji se zbraja 'Jamčevina' u slučaju tipova financiranja (za koje je moguće unijeti jamčevinu na kalkulaciji): OA, OG ,OJ (i OP, koji je neaktivan). Za ostale ne. Tako bi onda i mi podesili na izvještaju i to podatak pod odlomkom 'Kod sklapanja'.

Nadalje oko ostalih polja u excelu, ona koja su označena 'Iz ugovora' se mogu dodati na izvještaj, dok za ostala polja postoje određena ograničenja s obzirom da se u snimkama ne sprema plan otplate, već se spremaju podaci samo o potraživanjima koja nisu zatvorena (proknjižena i buduća potraživanja), dok potraživanja koja su već zatvorena/plaćena se ne spremaju (u snimci nemamo tih podataka). Zato sam nadalje u tekstu za svako polje naveo koje su mogućnosti tj. koje podatke imamo spremljene u snimci stanja. 
Tako za polje: 
b) 'PO - Dat. zadnje rate - Datum dokumenta zadnje rate iz plana otpl.' 
1) u slučaju da je ugovor istekao (zatvorena su sva potraživanja) ili je zaključen, tada uz ugovor nema podataka o potraživanju, pa se ne može dobiti taj podatak. Da li je to u redu da u takvim slučajevima bude prazan podatak na izvještaju? Druga opcija je da se uzme 'Iz ugovora' tj. s mape ugovora datum otkupa (koji se sprema u snimku stanja). 
Kao treća opcija, postoje još neki podaci ugovora koje se spremaju u snimku i možda bi vam ti odgovarali u slučaju ugovora koji imaju zatvorena sva potraživanja i riječ je o sljedećim: 
2) Zadnji datum dokumenta potraživanja koje nije otkup (Maximum document date (datum_dok) for this contract. Buy out is excluded) - ovo odgovara za FL 
3) Zadnji datum dokumenta potraživanja (Maximum document date (datum_dok) for this contract. End date for this contract) - ovo odgovara za OL
ali ti podaci imaju mali nedostatak, npr. ako se poslije zadnje rate fakturira zatezna kamata ili 'OBRAČUN za korištena sredstva', tada će se prikazati taj datum (zato što je to zadnje potraživanje), tako da ako se odlučite za neki od navedenih podataka, morate imati na umu logiku po kojoj se on spremio u snimku. 

c) 'PO - Br. obroka/rata - Broj obroka/rata iz plana otplate' - ne može se dobiti točan podatak (zbog razloga navedenih iznad u drugom odlomku). Može se prikazati podatak s ugovora. 

d) 'PO - Dat. Otkupa - datum dokumenta iz plana otplate' -  u slučaju ugovora koji imaju zatvorena sva potraživanja se ne može se dobiti točan podatak (zbog razloga navedenih iznad u drugom odlomku). Može se dobiti podatak iz ugovora ili neki od gore navedenih u točkama od 1 do 3. 

e) 'Tren. bud otkup neto - Iznos otkup bez pdva i bez PPMV iz plana otplate' -> iznos budućeg otkupa se može dobiti. U slučaju da je potraživanje zatvoreno/plaćeno, prikazali bi iznos 0. Druga opcija je da se uzme 'Iz ugovora' (ili Iz ugovora samo u slučaju ako je npr. zatvoreno potraživanje), ali u tom slučaju nije moguće dobiti točan iznos bez PDVa i PPMVa. 

f) 'Tren. bud otkup-iznos PPMV - Iznos PPMV-a iz stavke otkup iz otplatnog plana' -> iznos budućeg otkupa i PPMVa u otkupu se može dobiti. U slučaju da je potraživanje zatvoreno, prikazali bi iznos 0. 

Nakon što definiramo logiku prikaza podatka, tada bi vam pripremili ponudu.



ex_max_dz 	Maximum dat_zap for this contract. (if tip_knjizenja = 1 Buy out is excluded)
ex_max_dat_zap 	Maximum dat_zap for this contract. (Date when last claim is due)
ex_max_dd 	Maximum document date (datum_dok) for this contract. (if tip_knjizenja = 1 Buy out is excluded)
ex_max_datum_dok 	Maximum document date (datum_dok) for this contract. End date for this contract
select ex_max_dz, ex_max_dat_zap, ex_max_dd, ex_max_datum_dok, zap_2ob, zap_opc, nacin_leas  , STATUS_AKT, * from oc_contracts  where id_oc_report = 32 AND STATUS_AKT = 'Z'	
select id_cont,ex_instpreTD_DD, ex_max_dz, ex_max_dat_zap, ex_max_dd, ex_max_datum_dok, zap_2ob, zap_opc, nacin_leas  , STATUS_AKT, * from oc_contracts  where id_oc_report = 32 AND STATUS_AKT = 'A'	

--select * from oc_reports order by date_to desc -- 17270
DECLARE @id_oc_report int = 17270

select id_pog, nacin_leas, status_akt,  ex_max_datum_dok, ex_max_dat_zap, ex_max_dd, ex_max_dz, * from oc_contracts 
where ID_OC_REPORT = @id_oc_report
AND dat_sklen > '20090101' 
AND id_cont = 59405
order by id_cont desc

select a.id_cont, dbo.gfn_Id_pog4Id_cont(a.id_cont), max_datum_dok 
from planp a
join 
(select id_cont, max(datum_dok) max_datum_dok from planp WHERE id_terj in ('21', '23')
group by id_cont ) b on a.ID_CONT = b.ID_CONT 
WHERE datum_dok >= max_datum_dok AND id_terj NOT in ('21', '23')
order by id_cont desc










Poštovani, 
s doradom izvještaja smo planirali pričekati dok ne dogovorimo gdje ćemo zapisati/evidentirati iznos Buybacka na ugovoru (za koji imamo otvoren zahtjev 1805 - Garancija povratnog otkupa) i onda taj podatak prikazati na izvještaju u polju 'Iznos ugovorenog BB'. Podatak BB s ugovora koliko sam shvatio bi bio točniji od podatka na ponudi?

Dodatno molim samo potvrdu, za financijski leasing će se zadnja otkupna rata gledati kao OTKUP (ako na ugovoru postoji otkup), a prezadnja rata će praktički predstavljati "zadnju ratu"?
Za operativni postoji potraživanje za otkup pa postoji jasna razlika između otkupa i zadnje rate.

$SIGN


Poštovani, 
a) s doradom izvještaja smo planirali pričekati dok ne dogovorimo gdje ćemo zapisati/evidentirati iznos Buybacka na ugovoru (za koji imamo otvoren zahtjev 1805 - Garancija povratnog otkupa) i onda taj podatak prikazati na izvještaju u polju 'Iznos ugovorenog BB'. Podatak BB s ugovora koliko sam shvatio bi bio točniji od podatka na ponudi

Nadalje oko ostalih polja, ona koja su označena 'Iz ugovora' se mogu dodati na izvještaj, dok za ostala polja postoje određena ograničenja s obzirom da se u snimkama ne sprema plan otplate, već se spremaju podaci samo o potraživanjima koja nisu zatvorena (proknjižena i buduća potraživanja), dok potraživanja koja su već zatvorena/plaćena se ne spremaju (u snimci nemamo tih podataka). Zato sam nadalje u tekstu za svako polje naveo koje su mogućnosti tj. koje podatke imamo spremljene u snimci stanja. 
Tako za polje:
b) PO - Dat. zadnje rate - Datum dokumenta zadnje rate iz plana otpl. -&GT 
1) u slučaju da je ugovor istekao (zatvorena su sva potraživanja) ili je zaključen, tada uz ugovor nema podataka o potraživanju, pa se ne može dobiti taj podatak. Da li je to u redu da u takvim slučajevima bude prazan podatak na izvještaju? 
Druga opcija je da se uzme 'Iz ugovora' tj. s mape ugovora datum otkupa koji se sprema u snimku stanja.

Kao treća opcija, postoje još neki podaci ugovora koje se spremaju u snimku i možda bi vam ti odgovarali i riječ je o sljedećim: 
4) Zadnji datum dokumenta potraživanja koje nije otkup (Maximum document date (datum_dok) for this contract. Buy out is excluded)
5) Zadnji datum dokumenta potraživanja (Maximum document date (datum_dok) for this contract. End date for this contract)
ali ti podaci imaju mali nedostatak, npr, ako se poslije zadnje rate fakturira zatezna kamata, tada će se prikazati taj podatak zatezne kamate tako da ako se odlučite za neki od navedenih podataka, morate imati na umu logiku po kojoj se on spremio u snimku.

c) PO - Br. obroka/rata - Broj obroka/rata iz plana otplate -&GT se ne može dobiti točan podatak (zbog razloga navedenih iznad). Može se dobiti podatak s ugovora. 

d) PO - Dat. Otkupa  datum dokumenta iz plana otplate -&GT se ne može dobiti točan podatak (zbog razloga navedenih iznad). Može se dobiti podatak s ugovora ili neki od gore navedenih u točkama od 1 do 5.

e) Tren. bud otkup neto - Iznos otkup bez pdva i bez PPMV iz plana otplate -&GT iznos budućeg otkupa se može dobiti. U slučaju da je potraživanje zatvoreno/plaćeno, prikazali bi iznos 0. Druga opcija je da se uzme 'Iz ugovora'.

f) Tren. bud otkup-iznos PPMV - Iznos PPMV-a iz stavke otkup iz otplatnog plana -&GT iznos budućeg otkupa i PPMVa u otkupu se može dobiti. U slučaju da je potraživanje zatvoreno, prikazali bi iznos 0. Druga opcija je da se uzme 'Iz ugovora'.

Nakon što definiramo logiku prkaza podatka bi vam prirpemili ponudu.

$SIGN

Dodatno, molim samo potvrdu, za financijski leasing će se zadnja otkupna rata gledati kao OTKUP, a prezadnja rata će praktički predstavljati zadnju ratu?
Za operativni postoji potraživanje za otkup sa kojeg bi povukli podatke, a zadnja rata predstavlja zadnju ratu (za polje pod b)).
