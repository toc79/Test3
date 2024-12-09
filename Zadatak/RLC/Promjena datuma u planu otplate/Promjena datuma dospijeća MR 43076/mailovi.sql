Poštovana, 

u zahtjevu od 4.7.2019 tražili ste: 
=> za 932 ugovora dospijeće je potrebno izmijeniti na 16.07.(+15 dana od izdavanja fakture) 
GMC: ok, podesit ćemo broj dana između datuma dokumenta i datuma dospijeća na 15 dana i sukladno tome generirati buduće planove otplate. 

=> za 542 ugovora dospijeće je potrebno izmijeniti na 23.07. (+22 dana od izdavanja faktura) 
GMC: ok, podesit ćemo broj dana između datuma dokumenta i datuma dospijeća na 22 dana i sukladno tome generirati buduće planove otplate. 

=> za 407 ugovora dospijeće je potrebno izmijeniti na 30.07. (zadnji radni dan u mjesecu) 
GMC: nije moguće podesiti datum dospijeća da se gleda zadnji radni dan u mjesecu s obzirom da prilikom unosa ugovora vi definirate broj dana između datuma dokumenta i datuma dospijeća. Npr. ako podesiti 30 dana, tada će vam u slučaju veljače datum dospijeća otići na slijedeći mjesec, a isto tako i kod svih mjeseci kod kojih je 30-ti neradni dan, datum dospijeća će se pomaknuti na prvi slijedeći radni dan. 
Molim za povratnu informaciju kako podesiti ove ugovore? 

Poštovana, 

da li to znači da za 
=> za 407 ugovora dospijeće je potrebno izmijeniti na 30.07. (zadnji radni dan u mjesecu) - ne mijenjamo ništa? 
Ako je potrebno i za njih mijenjati, molim da definirate broj dana kako bi mogli krenuti s pripremom skripti.


On Jul 29, 2019 @ 10:55, Sanja Žnidarec wrote: 
Poštovani, 
Za 407 ugovora je potrebno izmijeniti datume dospijeća na + 29 dana od dana izdavanja, znači, ne zadnji radni dan već baš 29 dana od izdavanja. 
A za 542 ugovora dospijeće je potrebno izmijeniti na 23.07. , odnosno +22 dana od izdavanja faktura. 
U slučaju pitanja, stojim na raspolaganju. 


[08:28] Daniel Vrpoljac
    UCLC su jučer napsialid a hoće za 407 ugovora na 29 dana
​[08:28] Daniel Vrpoljac
    treba im napisati da će im veljača otići u slijedeći mjesec
​[08:28] Daniel Vrpoljac
    kad će imati 28 dana
(Broj sviđanja: 1)


SELECT a.id_cont, dni_zap FROM dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_cont = b.id_cont --1881 na testu

SELECT a.id_cont, a.dni_zap, a.dni_zap + (DATEPART(dd, b.dat_zap_new) - DATEPART(dd, b.dat_zap)) as dni_zap_new
--	,  dbo.gfn_GetContractDataHash(a.id_cont) as pogodba_hash 
FROM dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_cont = b.id_cont


select  dni_zap_new, count(*), dni_zap
FROM ( 
	SELECT a.id_cont, a.dni_zap, a.dni_zap + (DATEPART(dd, b.dat_zap_new) - DATEPART(dd, b.dat_zap)) as dni_zap_new
	--	,  dbo.gfn_GetContractDataHash(a.id_cont) as pogodba_hash 
	FROM dbo.pogodba a
	JOIN dbo._tmp_ugovori b ON a.id_cont = b.id_cont
) a
group by dni_zap_new, a.dni_zap order by 1

