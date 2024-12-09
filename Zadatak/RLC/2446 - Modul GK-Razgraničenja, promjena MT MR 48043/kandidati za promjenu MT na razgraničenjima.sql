-- candidates	
select c.id_pog Ugovor, c.status_akt, c.id_strm MT_ugovor, r.id_gl_razmej ID_razgranicenja, r.id_strm MT_razgranicenja, r.st_dok Br_dok_raz, r.ddv_id Račun_raz	
	, * 
from dbo.gl_razmej r	
inner join dbo.pogodba c on r.id_cont = c.id_cont	
where id_gl_sifkljuc is null -- razgraničenje bez ključa za raspodjelu po mjestu troška	
and (r.dat_aktiv is null -- neaktivno razgraničenje	
	or r.dat_aktiv is not null and znesek_se != 0) -- aktivna razgraničenja 
and r.id_strm != c.id_strm	
