 begin tran
 update dokument set OPOMBE= 'test napomena' where id_dokum in( 51305,  51306)
 select OPOMBE, * from dokument where id_dokum in( 51305,  51306)
 --rollback

Poštovani, 

za listu ugovora na slici sam provjerio po jedan ugovor prvih četiri partnera 
38721/11   
43199/13
49269/16
te isti nemaju dokumente ZO (imaju ZN, ZZ, Z1), dok se promjena radi samo na dokumentima ZO. 

Ugovor 53324/17 ima ZO dokument, a kod njega se za dokument 825008 promjena nije napravila zbog "Exception: Ne mogu zaključati trenutni modul. Razlog: modul "Dnevna rutina - prijenos dospijelih potraživanja", korisnik "kristinan"", koja se prikazala nakon promjene krovnog dokumenta ZZ 813837 od strane korisnika borism. Nakon toga se prikazala poruka greške "Greška u izvođenju!", a nakon toga se promjena datuma vraćanja na krovnom dokumentu ZZ uspješno napravila, bez promjene po dokumentaciji tog ugovora.
U takvim slučajevima je bilo potrebno ponovno napraviti promjenu datuma na zadnjem krovnom dokumentu na prazno, spremiti podatke te ponovno unijeti datum vraćanja kako bi se promjena po ZO dokumentima napravila na preostalim ugovorima.

Kako ne bi više dolazilo do ovakvih situacija, napravio sam odgovarajuće poruke obavijesti i upozorenja te se sada u slučaju greške u izvođenju će se zaustaviti spremanje podataka krovnog dokumenta. Slike poruka u grešci šaljem u privitku (kako je vama teže simulirati takav slučaj greške pa da imate primjer). Time će korisnik obavezno morati ponoviti postupak spremanja čime će se ponovno pokrenuti promjena datuma na ZO dokumentima.


$SIGN 

select vrnjen, * from nova_arh.dbo.archive_arh_dokument where id_frame = 1819 order by time
select vrnjen, * from dbo.arh_dokument where id_frame = 1819 order by time

813836
813837

2020-05-28 12:26:07.607
2020-05-28 12:26:29.000

SELECT * FROM dbo.frame_pogodba WHERE id_frame = 1819
DECLARE @lista varchar(max)
SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_KROV_INST_OSIG' and neaktiven = 0) 
		
SELECT vrnjen, * FROM dbo.dokument WHERE id_frame = 1819 AND id_obl_zav IN (SELECT id FROM dbo.gfn_GetTableFromList(@lista))


SELECT fp.id_frame, d.*, CAST(d.sys_ts as bigint) as cast_sys_ts
FROM dbo.frame_pogodba fp 
INNER JOIN dbo.pogodba p ON fp.id_cont = p.id_cont
INNER JOIN dbo.dokument d ON fp.id_cont = d.id_cont 
WHERE fp.id_frame = 1819
AND d.id_obl_zav = 'ZO'
AND d.id_dokum <> 813837
AND d.id_frame IS NULL
AND d.vrnjen IS NULL
AND p.status_akt = 'Z'

select case when (2 - 1) = 1 and 1=1 then 1 else 0 end


 select vrnjen, * from dbo.dokument where id_dokum =   825008
select vrnjen, * from dbo.arh_dokument where id_dokum =   825008 order by time
select vrnjen, * from nova_arh.dbo.archive_arh_dokument where id_dokum =   825008 order by time


select vrnjen, * from dbo.dokument where id_dokum =   813837
select vrnjen, * from dbo.arh_dokument where id_dokum =   813837 order by time
select vrnjen, * from nova_arh.dbo.archive_arh_dokument where id_dokum =   813837 order by time


select vrnjen, * from dbo.dokument where id_dokum =  813836
select vrnjen, * from dbo.arh_dokument where id_dokum =  813836 order by time
select vrnjen, * from nova_arh.dbo.archive_arh_dokument where id_dokum =  813836 order by time

Pokrenuo borism
Exception: Ne mogu zaključati trenutni modul. Razlog: modul "Dnevna rutina - prijenos dospijelih potraživanja", korisnik "kristinan"
za dokument 825008