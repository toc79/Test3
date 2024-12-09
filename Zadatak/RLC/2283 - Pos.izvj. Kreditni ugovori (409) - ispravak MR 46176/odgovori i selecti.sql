Poštovani, 

ti slučajevi nisu bili navedeni pa nisu uzimani u obzir kod pripreme ponude i podešavanja izvještaja. 
Napravio sam provjeru planova otplata takvih ugovora, da li se mogu dobiti ti podaci datuma za zapise kamata koji su iznos 0.
Kod obročnih izračuna, riječ o zapisisma koji imaju sve iznose 0: glavnica, kamata i korištenje. Pa bih onda napravio doradu da su zapisi kamata oni koji imaju kamatu veću od 0 ili imaju sve iznose 0: glavnica, kamata i korištenje.
Kod anuitetnog izračuna za npr. 0236 20 ne možemo sa sigurnošću ralikovati jer ne postoji talav podatak na kreditnom ugovoru koliko sam vidio, za takve ugovore planiram uzeti podatak datuma glavnice (po logici ako nemaju kamate ali imaju buduću glavnicu, riječ je o ugovorima s kamatom 0).
U privitku vam šaljemo ponudu za dodatnu doradu izvještaja. 

1 h

metoda eliminacije: oni koji nemaju datuma (datum imaju oni koji imaju iznosa kamate ili sva tri iznosa 0), njima gledati prema glavnici


kod obročnog, nema kamate, ali ima kamatne stope na ugovoru tako da ne možemo po tome 
posebno da prikažemo planove otpalte 

select * from dbo.kred_planp where ID_KREDPOG='0164 16'
select obresti_zac, obresti, fix_del_zac,fix_del, ID_RTIP, ST_ANUITET, ST_OBROKOV2, rind_datum, * from kred_pog where ID_KREDPOG='0164 16'

select * from dbo.kred_planp where ID_KREDPOG='0232 19'
select obresti_zac, obresti, fix_del_zac,fix_del, ID_RTIP, ST_ANUITET, ST_OBROKOV2, rind_datum, * from kred_pog where ID_KREDPOG='0232 19'

--anuitetni
select * from dbo.kred_planp where ID_KREDPOG='0236 20'
select obresti_zac, obresti, fix_del_zac,fix_del, ID_RTIP, ST_ANUITET, ST_OBROKOV2, rind_datum, * from kred_pog where ID_KREDPOG='0236 20'



select obresti_zac, obresti, fix_del_zac,fix_del, ID_RTIP, ST_ANUITET, ST_OBROKOV2, rind_datum, * from kred_pog where (OBRESTI = 0 or OBRESTI_ZAC=0) and tip_pog != 1



