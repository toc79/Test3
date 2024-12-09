select * from dbo.fakture 
where id_fakt in (select id_fakt from dbo.fak_pos group by id_fakt having count(*)>1
)
 and  ddv_date >'20200101'

and id_fakt in (select id_fakt from dbo.fak_pos where mstr >0)