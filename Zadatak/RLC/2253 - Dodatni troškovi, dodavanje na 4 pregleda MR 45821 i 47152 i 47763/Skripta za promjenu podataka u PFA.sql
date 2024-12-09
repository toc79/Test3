-- lista za promejnu razgraničeničenja 1562 zapisa razgraničenja => 1563
-- da li samo aktivna razgraičenja? => da tako sam napisao u odgovoru
select id_gl_razmej Br_razgranicenja
	, case when pas_akt = 1 then konto else raz_pkonto end as konto
	, case when pas_akt = 1 then raz_pkonto else konto end as Konto_koristenja_razgranicenja
	, dbo.gfn_id_pog4id_cont(id_cont) as Ugovor, id_kupca, st_dok Br_dokumenta, ddv_id Br_racuna
	, vrsta_dok
	, raz_datum Pocetak
	, OPIS_DOK
	, CASE WHEN r.pas_akt=1 THEN 'Pas.' ELSE 'Akt.' END as [Pas./Akt.] -- pas_akt 1 - Pasivna; 2 - Aktivna  --case when r.pas_akt = 2 then 'Aktivna' else 'Pasivna' end 
	, znesek Iznos
	, r.*
from dbo.gl_razmej r
where 1 = 1 -- idu sva razgraničenja 
--and (r.dat_aktiv is null -- neaktivno razgraničenje
--    or r.dat_aktiv is not null and znesek_se > 0) -- aktivna razgraničenja 
and r.pas_akt = 2 -- pas_akt 1 - Pasivna; 2 - Aktivna => IFA je pasivna 1, PFA je 2 - aktivna
--and (source_tbl is null or source_tbl = '') -- nisu pristigla iz ulaznih računa već su ručno unesena
and vrsta_dok = 'IFA' -- treba ih promijneiti u PFA

update dbo.gl_razmej set vrsta_dok = 'PFA' -- na TESTU 1500
where 1 = 1 -- idu sva razgraničenja 
--and (r.dat_aktiv is null -- neaktivno razgraničenje
--    or r.dat_aktiv is not null and znesek_se > 0) -- aktivna razgraničenja 
and pas_akt = 2 -- pas_akt 1 - Pasivna; 2 - Aktivna => IFA je pasivna 1, PFA je 2 - aktivna
--Uvjet je nepotreban and (r.source_tbl is null or source_tbl = '') -- nisu pristigla iz ulaznih računa već su ručno unesena
and vrsta_dok = 'IFA' -- treba ih promijneiti u PFA

begin tran
-- lista na testu 6748
select g.*, rp.* --, r.* 
from dbo.gl g 
inner join dbo.gl_raz_plan rp on g.id_source = rp.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan'
inner join dbo.gl_razmej r on rp.id_gl_razmej = r.id_gl_razmej 
where 1 = 1 -- idu sva razgraničenja 
--and (r.dat_aktiv is null -- neaktivno razgraničenje
--    or r.dat_aktiv is not null and znesek_se > 0) -- aktivna razgraničenja 
and r.pas_akt = 2 -- pas_akt 1 - Pasivna; 2 - Aktivna => IFA je pasivna 1, PFA je 2 - aktivna
and (r.source_tbl is null or r.source_tbl = '') -- nisu pristigla iz ulaznih računa već su ručno unesena
and r.vrsta_dok = 'PFA' -- treba ih promijneiti u PFA
and g.vrsta_dok = 'IFA'

update dbo.gl set vrsta_dok = 'PFA'
from dbo.gl g 
inner join dbo.gl_raz_plan rp on g.id_source = rp.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan'
inner join dbo.gl_razmej r on rp.id_gl_razmej = r.id_gl_razmej 
where 1 = 1 -- idu sva razgraničenja 
--and (r.dat_aktiv is null -- neaktivno razgraničenje
--    or r.dat_aktiv is not null and znesek_se > 0) -- aktivna razgraničenja 
and r.pas_akt = 2 -- pas_akt 1 - Pasivna; 2 - Aktivna => IFA je pasivna 1, PFA je 2 - aktivna
and (r.source_tbl is null or r.source_tbl = '') -- nisu pristigla iz ulaznih računa već su ručno unesena
and r.vrsta_dok = 'PFA' -- treba ih promijneiti u PFA
and g.vrsta_dok = 'IFA'

select g.*, rp.* --, r.* 
from dbo.gl g 
inner join dbo.gl_raz_plan rp on g.id_source = rp.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan'
inner join dbo.gl_razmej r on rp.id_gl_razmej = r.id_gl_razmej 
where 1 = 1 -- idu sva razgraničenja 
--and (r.dat_aktiv is null -- neaktivno razgraničenje
--    or r.dat_aktiv is not null and znesek_se > 0) -- aktivna razgraničenja 
and r.pas_akt = 2 -- pas_akt 1 - Pasivna; 2 - Aktivna => IFA je pasivna 1, PFA je 2 - aktivna
and (r.source_tbl is null or r.source_tbl = '') -- nisu pristigla iz ulaznih računa već su ručno unesena
and r.vrsta_dok = 'PFA' -- treba ih promijneiti u PFA
and g.vrsta_dok = 'IFA'
--commit