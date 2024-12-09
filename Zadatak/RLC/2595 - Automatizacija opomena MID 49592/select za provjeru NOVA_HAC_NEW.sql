use nova_hac_new
declare @id_cont int =  2485 --000816
select top 10  time, dat_1op, dat_2op, dat_3op, poi.NE_OPOM_DO, poi.*, pog.* 
from dbo.arh_pogodba pog left join dbo.pogodba_opom_info poi on pog.ID_CONT = poi.ID_CONT where pog.id_cont = @id_cont order by 1 desc
--select cas_prip, ST_OPOMINA, dok_opom, SALDO_VAL, MIN_TERJ, * 
--from dbo.arh_za_opom azo
--where azo.id_cont = @id_cont order by azo.id_opom desc
--select time as time2, zad_dat_prip, azot.dni_opom, azot.PREPOVED_OPOM_DNI, azot.DNI_1OP, azot.dni_2op, azot.dni_3op, * from dbo.arh_za_opom_type azot where azot.id_za_opom_type = 7 order by time2 desc
select cas_prip as cas_prip2, cas_prip, azot.dni_opom, azot.PREPOVED_OPOM_DNI, azot.DNI_1OP, azot.dni_2op, azot.dni_3op, ST_OPOMINA, dok_opom, azo.SALDO_VAL, PROC_OBR, azo.MIN_TERJ
	, convert(date, NA_DAN) as NA_DAN, convert(date, dat_1op) as dat_1op, convert(date, dat_2op) as dat_2op, convert(date, dat_3op) as dat_3op
	, * 
from dbo.za_opom azo join dbo.za_opom_type azot on azo.cas_prip = azot.zad_dat_prip and azot.id_za_opom_type = azo.id_za_opom_type where azo.id_cont = @id_cont order by azo.id_opom desc
select azot.time as time_za_opom_type, cas_prip,  azot.dni_opom, azot.PREPOVED_OPOM_DNI, azot.DNI_1OP, azot.dni_2op, azot.dni_3op, ST_OPOMINA, dok_opom, azo.SALDO_VAL, PROC_OBR, azo.MIN_TERJ
	, convert(date, NA_DAN) as NA_DAN, convert(date, dat_1op) as dat_1op, convert(date, dat_2op) as dat_2op, convert(date, dat_3op) as dat_3op
	, * 
from dbo.arh_za_opom azo left join dbo.arh_za_opom_type azot on azo.cas_prip = azot.zad_dat_prip and azot.id_za_opom_type = azo.id_za_opom_type --left join dbo.ARH_OPOM_TMP aot on azo.id_opom = aot.ID_OPOM
where azo.id_cont = @id_cont order by azo.id_opom desc, time_za_opom_type desc
/*komentari
- poèetno je ugovor imao dug preko 10 rata
- dni_3op = 1, onda datum 2. opomene je bio 4.7. , a opomena 3. se nije pripremila. Kada sam podesio 3.7., opomena 3. se pripremila. Isto je i kod je popunjen datum 1. opomene i 3. opomene !! => znaèi gleda se + 1 dan
- ponovna pripema opomene ne gleda PREPOVED_OPOM_DNI veæ DNI_1OP ili DNI_2OP ili DNI_3OP
- s unesenim plaæanjem koje zatvara pola duga se nije popunio datum NE_OPOM_DO cas_prip 2024-07-05 09:59:38.000
- s plaæanjem koje je došlo da bude kandidat za 2. opomenu, podesio se NO_OPOM_DO na datum 2. opomene + 10 dana = 2024-07-03 + 10 = 13.7.2024 => cas_prip 2024-07-05 10:06:40.000. S izdavanjem opomene se promjenio na dat_2op = 2024-07-05
- s plaæanjem koje je došlo da bude kandidat za 1. opomenu, podesio se NO_OPOM_DO na datum 1. opomene + 10 dana = 2024-07-03 + 10 = 13.7.2024 => cas_prip 2024-07-05 10:22:37.000. S izdavanjem opomene se promjenio dat_1op s 2024-07-03 na 2024-07-05. Datum 1. opomene je bio 1.7.2023.
- s plaæanjem koje je došlo da nije kandidat za opomenu, obrisao se datum 1. opomene, st_opomin je dobilo -1, cas_prip 2024-07-05 10:31:39.000

- nisam testirao s poveæanjem duga u koracima (jesam u koracima kada je dug bio veæi od 10 rata)

Zakljuèak je da se NE_OPOM_DO setira kod plaèanja koje smanji dug i smanji broj opomene npr. s 3. na 2. opomenu. (samo smanjenje duga bez brisanja datuma opomena ne setira NE_OPOM_DO)
*/