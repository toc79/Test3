select vrnjen-1 as vrnjen2,* from dbo.dokument where id_dokum = 1093119 --select za FOx script



select vrnjen, * from dbo.arh_DOKUMENT where ID_DOKUM = 952426 order by TIME 

select * from dbo.frame_pogodba where id_cont = '63855'

select id_cont, COUNT(*)
from dbo.frame_pogodba 
group by id_cont
having count(*)> 1


select vrnjen, * from dbo.arh_DOKUMENT where id_frame =2107 order by time

Promjena se znači radi kod promjene bilo kojeg dokumenta.


Poštovana/i, 

u slikama koje ste poslali je vidljiv još jedan slučaj kada ne dolazi do promjene datuma vraćanja na ZO dolumentu tj. kada korisnik ima prava za unos/promjenu KL dokumenta a nema prava za promjenu ZO dokument.

Sada sam na testu podesio da se se umjesto zabrane prikaže potvrdna poruka s mogućnosšću spremanja. Molim provjeru.

Navedeni dokumenti iz poruke
952426
952642
sada imaju popunjen datum vraćanja, promjenu je napravio korisnik marijad.


