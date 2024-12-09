select * from dbo.GL_RAZMEJ where ddv_id = '20210003034'
select * from dbo.ARH_GL_INPUT_R where ddv_id = '20210003034'
select * from dbo.ARH_GL_INPUT_Rk where ID_GL_INPUT_R in (select ID_GL_INPUT_R from dbo.ARH_GL_INPUT_R where ddv_id = '20210003034')

select * from dbo.arh_gl_input_rk 
where id_vrst_dod_str is not null -- 34487
and (id_cont is null or id_cont < 0)
-- sve stavke s vrstom dodatnih troškova imaju popunjem id_cont tako da veza po id_cont bi trebala uvijek biti u redu (nema potrebe auotmastka razgraničenja prvo vezati pa posebno račno unesena razgraničenja)
left join dbo.gl_razmej r on r.id_gl_razmej = rp.id_gl_razmej 
left join dbo.arh_gl_input_r ir on r.ddv_id = ir.ddv_id -- veza broj računa
left join dbo.arh_gl_input_rk irk on ir.id_gl_input_r = irk.id_gl_input_r and r.id_cont = irk.id_cont and r.raz_pkonto = irk.protikonto -- veza broj ugovora i konto razgraničenja -- uknjižbe razgraničenja kreiranog automatski na temelju ulaznog računa -- STARO --r.id_source = irk.id_gl_input_rk and r.source_tbl = 'gl_input_rk'
	
select ddv_id, vrsta_dok, count(*) kom from dbo.gl_razmej group by ddv_id, vrsta_dok having count(*) > 1


begin tran
update dbo.GL_RAZMEJ set vrsta_dok = 'PFA' where ID_GL_RAZMEJ in (
select id_gl_razmej --Br_razgranicenja
	--, case when pas_akt = 1 then konto else raz_pkonto end as konto_razgranicenja
	--, case when pas_akt = 1 then raz_pkonto else konto end as Konto_koristenja_razgranicenja
	--, dbo.gfn_id_pog4id_cont(id_cont) as Ugovor, id_kupca, st_dok Br_dokumenta, ddv_id Br_racuna
	--, vrsta_dok
	--, raz_datum Pocetak
	--, OPIS_DOK
	--, znesek Iznos
	--, r.*
from dbo.gl_razmej r
where 1 = 1 -- idu sva razgraničenja 
--and (r.dat_aktiv is null -- neaktivno razgraničenje
--    or r.dat_aktiv is not null and znesek_se > 0) -- aktivna razgraničenja 
and r.pas_akt = 2 -- pas_akt 1 - Pasivna; 2 - Aktivna => IFA je pasivna 1, PFA je 2 - aktivna
and (source_tbl is null or source_tbl = '') -- nisu pristigla iz ulaznih računa već su ručno unesena
and vrsta_dok = 'IFA' -- treba ih promijneiti u PFA
)
rollback


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
and (source_tbl is null or source_tbl = '') -- nisu pristigla iz ulaznih računa već su ručno unesena
and vrsta_dok = 'IFA' -- treba ih promijneiti u PFA


-- lista za promejnu u uknjižbama 5126 uknjižbi => prije nove godine => 1844
-- lista za promejnu u uknjižbama 616 uknjižbi 
select g.*, rp.* --, r.* 
from dbo.gl g 
inner join dbo.gl_raz_plan rp on g.id_source = rp.id_gl_raz_plan and g.source_tbl = 'gl_raz_plan'
inner join dbo.gl_razmej r on rp.id_gl_razmej = r.id_gl_razmej 
where 1 = 1 -- idu sva razgraničenja 
--and (r.dat_aktiv is null -- neaktivno razgraničenje
--    or r.dat_aktiv is not null and znesek_se > 0) -- aktivna razgraničenja 
and r.pas_akt = 2 -- pas_akt 1 - Pasivna; 2 - Aktivna => IFA je pasivna 1, PFA je 2 - aktivna
and (r.source_tbl is null or r.source_tbl = '') -- nisu pristigla iz ulaznih računa već su ručno unesena
and r.vrsta_dok = 'IFA' -- treba ih promijneiti u PFA
and g.vrsta_dok = 'IFA'

na izvještaju bi za GL_ARHIV trebalo i dalje gledati PAS_AKT = 2 bez obzira na vrstu uknjižbi IFA
-- KONTA IZ ZAHTJEVA SU ZA IZVJEŠTAJ , TREBA PROVJERITI MOŽDA JE DOVOLJNO  PAS_AKT = 2

--GF_SQLEXEC("SELECT * FROM dbo.vrstedok WHERE ali_razmej = 1", "vrstedok")
SELECT COUNT(*) FROM vrstedok WHERE sif_dok = 'PFA'
SELECT ALI_RAZMEJ,* FROM vrstedok --WHERE sif_dok = 'PFA'
update dbo.vrstedok set ALI_RAZMEJ = 1 WHERE sif_dok = 'PFA' -- PODESIO NA PROD

declare @id_source int = 4516001
select * from dbo.gl where id_gl = @id_source
select * from dbo.GL_RAZ_PLAN where ID_GL_RAZ_PLAN in (select id_source from dbo.gl where id_gl = @id_source)--6154-- or ID_GL_RAZMEJ = 2395
select * from dbo.GL_RAZmej where ID_GL_RAZMEJ in (select ID_GL_RAZMEJ from dbo.GL_RAZ_PLAN where ID_GL_RAZ_PLAN in (select id_source from dbo.gl where id_gl = @id_source))
--select * from dbo.rac_in where ddv_id = '20210002169         '
--select * from dbo.rac_out where ddv_id = '20210002169         '
select * from dbo.ARH_GL_INPUT_R where ddv_id = '20210002169         ' --ID_GL_INPUT_R = 182542 
select * from dbo.ARH_GL_INPUT_RK where ID_GL_INPUT_R = 186047     
select * from dbo.GL_RAZmej where ddv_id = '20210002169         '

Poštovana/i, 

1. oko 
"molim da pogledate u podlozi i konto 190002 ne vuku se ni potražni prometi sa vrstom dokumenta PFA"
provjerio sam u excelu prvi zapis ID GL 4260789 iz lista "190002-lsk" te se taj podatak prikazuje na izvještaju, u privitku u prvom listu je vidljiv podatak, ali nema šifru troška pa sam sada popravio izvještaj pa molim provjeru. 
Na izvještaj sam dodao kolonu ID GL što predstavlja jedinstveni broj/id uknjižbe.

2. oko "... fali vrsta dokumenta IFA koja označava uknjižbe koje sa razgraničenja dolaze na trošak ..." 
IFA označava izlazne fakture pa sam provjerio takva razgraničenja te je riječ o podacima razgraničenja ulaznih računa koje ste ručno unijeli u razgraničenjima tj. razgraničenja nisu automatski generirna nakon unosa ulaznog računa. 
Takvi slučajevi nisu podržani na izvještaju (prikazuju se samo razgraničenja generirana iz ulaznih računa jer za njih imamo jednoznačnu vezu: za koju stavku UR je kreirano točno koje razgraničenje) te za njih u biti ne postoji jednoznačna veza pojedine stavke ulaznog računa s pojedinim razgraničenjem te se ne može sa sigurnošću znati koje razgraničenje je za koju stavku/trošak: jedan račun može imati 5 stavaka s dodatnim troškovima i time 5 razgraničenja s istim brojem računa za koje dakle nema jednoznačne veze.
Napravio sam provjeru oko mogućnosti vezanja takvih ručnih razgraničenja sa stavkom (i time prikaz uknjižbi) te bi jedno od rešenja bilo vezivanje preko broja ugovora i po kontu razgraničenja (jedno i drugo) ili npr. po broju ugovora, kontu razgraničenja i po iznosu. U simulaciji prikazanih podataka se pojavio jedan primjer računa 20210002169 koji ima dvije stavke s istim brojem ugovora, slika u privitku u drugom listu, te na ovaj način vezivanja po broju ugovora i kontu bi se ispravno prikazala šifra troška na izvještajima.
Tako da ako vam odgovara takva veza: broj računa, broj ugovora i konto razgraničenja, podesili bi na oba izvještaja takav prikaz. Molim provjeru i povratnu informaciju.

3. Ručno unesena razgraničenja za ulazne račune bi trebala imati iznaku PFA kao i ulazni računi. Sada sam na testu podesio da je na masci za unos razgraničenja omogućena opcija "Iz ulaznih računa", slika u trećem listu. Kod odabira "Ručno" sada se u polju "Vrsta dok." isto tako može odabrati "Ulazni račun". Molim provjeru te povratnu informaciju da li možemo isto podesiti na produkciji.

4. Oko postojećih ručnih razgraničenja ulaznih računa i njihovih uknjižbi, trebalo bi im promijeniti vrstu dokumenta na PFA (umjesto kako su sada IFA).
S doradom u točki 3. će uknjižbe za nova razgraničenja dobiti ispravnu vrstu dokumenta PFA, ali za sve postojeća razgraničenja i uknjižbe (za tekuću godinu) bi se trebala napraviti promjena u PFA kroz bazu.
Kako ih razlikujete od izlaznih računa, da li po kontu razgraničenja i koja su to konta?
Za navedeno bi vam poslali ponudu za promjenu podataka (promjena kroz masku/program nijemoguća, slika u 4 listu "Postojeće uknjižbe").

5. Kod izvještaja "Razgraničenja s dodatnim troškovima" sam podesio da se prikazuje samo ona razgraničenja automatski kreirana iz ulaznih računa (ručno unesena se ne prikazuju). Da bi na izvještaju ispravno prikazali ručno unesena razgraničenja vezana na ulazne račune, trebali bi nam definirati po čemu se razlikuju od ostalih razgraničenja da li po kontu? Ako bi implementirali točku 4, onda bi po tom podatki PFA znali o kojim razgraničenima je riječ. To bi značilo da promjenu treba napraviti i na zaključenim rezgraničenima (uknjižbe bi mijenjali samo u aktivnoj godini, dok u arhivskim ne).

$SIGN 

To su sva konta koja se nalaze na stavkama ulaznih računa

To bi značilo da promjenu treba napraviti i na zaključenim rezgraničenima.

Tako da ćemo na izvještaju morati pripremiti podatake posebno za tako ručno unesene razgraničenja i za automatski generirane

Dodatni problem je što kod ručnog unosa razgraničenja vi ne možete unijeti/odabrati ulazni račun (PFA) već ramo ručno ili izlazni gdje su oba IFA, time u razgraničenjima nije posve jeasno o kakvom računu se radi.

PO ID_CONT i PO IZNOSU => bolje po kontu 

Na izvještj dodati id_gl

20210002169   


Razgraničenja

provjeriti ručno unesena razgraničenja IFA
