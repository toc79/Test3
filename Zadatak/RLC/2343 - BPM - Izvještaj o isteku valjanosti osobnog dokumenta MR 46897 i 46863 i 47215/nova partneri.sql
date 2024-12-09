--Podaci u Nova
--ID klijenta, Naziv klijenta, Status, Broj AD ugovora 
--Ime i prezime, OIB, JMBG, Adresa prebivališta, Mjesto prebivališta
--Uloga, Naziv radnog mjesta
--Vrsta osob. dok., Broj osob. dok., Datum izdavanja osob. dok., Izdavatelj osob. dok., Datum valjanosti
declare @today datetime = (cast(getdate() as date))

select par.id_kupca, par.naz_kr_kup, par.neaktiven as Status, pog.broj_ad_ugovora
	, par.tip_os_izk, gr_os_izk.value as [Vrsta osob. dok.], st_os_izk as [Broj osob. dok.], par.d_os_izk as [Datum izdavanja osob. dok.]
	, par.izd_os_izk as [Idavatelj osob. dok.], par.d_velj_os_izk as [Datum valjanosti]
	--, * 
from dbo.partner par 
outer apply (select * from dbo.general_register where id_register = 'OS_IZK' and id_key = par.tip_os_izk) gr_os_izk
--outer apply (select * from dbo.general_register where id_register = 'p_status' and id_key = par.p_status) gr_p_status
outer apply (select count(*) as broj_ad_ugovora from pogodba where status_akt in ('D', 'A,') and id_kupca = par.id_kupca) pog
where d_velj_os_izk < @today
order by par.id_kupca