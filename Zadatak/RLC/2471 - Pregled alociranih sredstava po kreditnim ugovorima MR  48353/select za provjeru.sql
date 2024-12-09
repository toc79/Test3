declare @id_cont int = 72750
select STATUS_AKT, NET_NAL, net_nal_zac, * from dbo.pogodba where id_cont = @id_cont
select * 
from dbo.pogodba_kp_npm a
join dbo.kred_pog_pogodba_allocation b on a.id_pogodba_kp_npm = b.id_pogodba_kp_npm
where a.id_cont = @id_cont



select STATUS_AKT, NET_NAL, net_nal_zac, * from dbo.pogodba where id_cont = 1244
select * from dbo.pogodba_kp_npm where id_cont = 1244
select * from dbo.kred_pog_pogodba_allocation where id_pogodba_kp_npm = 6