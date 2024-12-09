select nacin_leas, PREVZETA, OBR_MERA, dej_obr, EF_OBRM, EF_OBRM_TREN, dat_sklen, id_pon, STATUS_AKT
	, pog.* 
from dbo.pogodba pog
join dbo.partner par on pog.id_kupca = par.id_kupca
where dat_sklen >= '20230101' and EF_OBRM_TREN > 7.5 
and par.vr_osebe in ('FO', 'F1', 'FR') 

select  OBR_MERA, dej_obr, EF_OBRM, dat_pon, * from dbo.ponudba where id_pon = '0291349'

select * from dbo.VRST_OSE


--select * from dbo.pogodba where id_cont = 79390
select  OBR_MERA, dej_obr, EF_OBRM, dat_pon, * from dbo.ponudba where id_pon = '0291954'

select PREVZETA, OBR_MERA, dej_obr, EF_OBRM, EF_OBRM_TREN, dat_sklen, id_pon, nacin_leas, * from dbo.arh_pogodba where id_cont = 79390 order by time 
select PREVZETA, OBR_MERA, dej_obr, EF_OBRM, EF_OBRM_TREN, id_pon, * from dbo.arh_pogodba where id_cont = 62151order by time 
