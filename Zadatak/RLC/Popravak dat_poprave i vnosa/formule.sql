select id_kupca, naz_kr_kup, dat_vnosa,vnesel, dat_poprave 
from partner 
where dat_poprave<'20010101' 
order by dat_poprave 
select id_kupca, naz_kr_kup, dat_vnosa,vnesel, dat_poprave 
from partner 
where dat_vnosa='2000-01-12' 
order by dat_vnosa
select id_kupca, naz_kr_kup, dat_vnosa,vnesel, dat_poprave 
from partner 
where vnesel = ''
order by dat_vnosa
select id_kupca, naz_kr_kup, dat_vnosa,vnesel, dat_poprave 
from dbo.partner 
where ltrim(rtrim(vnesel)) = '' OR vnesel is null
order by id_kupca

select * from ARH_PARTNER where id_kupca = '000103'


select MIN(time) from ARH_PARTNER
select vnesel,* from arh_partner where [TIME] < '2006-10-06 12:50:51.333'

select id_kupca, [time], ROW_NUMBER() OVER (partition by id_kupca order by time desc) as br_retka from ARH_PARTNER where id_kupca = '001034'