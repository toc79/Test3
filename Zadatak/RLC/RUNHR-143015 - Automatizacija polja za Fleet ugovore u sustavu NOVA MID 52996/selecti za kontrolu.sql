select * 
from dbo.kategorije_tip kt
left join dbo.kategorije_sifrant ks on coalesce(kt.id_kategorije_tip_p, kt.id_kategorije_tip) = ks.id_kategorije_tip
where kt.sifra = 'TKU'
select * 
from dbo.kategorije_tip kt
left join dbo.kategorije_sifrant ks on coalesce(kt.id_kategorije_tip_p, kt.id_kategorije_tip) = ks.id_kategorije_tip
where kt.sifra = 'TKGU'
select * from dbo.general_register where id_register = 'P_POSREDNIK' --and id_key in ('FLT', 'DOBF')
select * from fields_all where table_name = 'kategorije_sifrant'
select * from dbo.kategorije_tip kt where kt.sifra = 'TKU'
select * from dbo.kategorije_entiteta where id_entiteta = '78945'
select * from dbo.kategorije_entiteta where id_entiteta =  '78948'
 
 
 select top 5 vnesel,  * from dbo.pogodba order by id_cont desc

select * from dbo.fields_all where table_name = 'pogodba' and data_type like 'date%'

select * from dbo.reprogram where id_cont =  78948
