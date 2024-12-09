--drop table dbo._tmp_alociranje 
create table dbo._tmp_alociranje (
id_pog varchar(30) not null,
net_nal decimal(18,2),
iznos_akolacije decimal(18,2)
)
insert into dbo._tmp_alociranje values ('65644/21', 8968.78, 8968.78)
insert into dbo._tmp_alociranje values ('65645/21', 8968.78, 8968.78)
insert into dbo._tmp_alociranje values ('65646/21', 8968.78, 8968.78)
insert into dbo._tmp_alociranje values ('65647/21', 8968.78, 8968.78)
insert into dbo._tmp_alociranje values ('65648/21', 8968.78, 8968.78)
insert into dbo._tmp_alociranje values ('65649/21', 8968.78, 8968.78)
insert into dbo._tmp_alociranje values ('65650/21', 8968.78, 8968.78)
insert into dbo._tmp_alociranje values ('65651/21', 8968.78, 8968.78)
insert into dbo._tmp_alociranje values ('65653/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65654/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65655/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65656/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65657/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65658/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65659/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65660/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65661/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65662/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65663/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65664/21', 9818.35, 9818.35)
insert into dbo._tmp_alociranje values ('65665/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65666/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65667/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65668/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65669/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65670/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65671/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65672/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65673/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65674/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('65675/21', 12114.19, 12114.19)
insert into dbo._tmp_alociranje values ('66065/21', 11381.59, 11381.59)
insert into dbo._tmp_alociranje values ('66066/21', 11381.59, 11381.59)
insert into dbo._tmp_alociranje values ('66067/21', 11381.59, 11381.59)
insert into dbo._tmp_alociranje values ('66068/21', 11381.59, 11381.59)
insert into dbo._tmp_alociranje values ('66069/21', 11381.59, 11381.59)
insert into dbo._tmp_alociranje values ('66070/21', 11381.59, 11381.59)
insert into dbo._tmp_alociranje values ('66071/21', 11381.59, 11381.59)
insert into dbo._tmp_alociranje values ('65807/21', 16776.54, 16776.54)
insert into dbo._tmp_alociranje values ('65819/21', 9123.18, 9123.18)
insert into dbo._tmp_alociranje values ('65822/21', 15364.24, 15364.24)
insert into dbo._tmp_alociranje values ('65826/21', 26630.05, 26630.05)
select * from dbo._tmp_alociranje

select 
    a.id_pog
    , a.iznos_akolacije
	, pog.net_nal_zac
	, pog.net_nal_zac
    , kp.*
	, * 
from dbo._tmp_alociranje a
join dbo.POGODBA pog on dbo.gfn_Id_cont4Id_pog(a.id_pog) = pog.id_cont
left join dbo.pogodba_kp_npm pkp on pog.ID_CONT = pkp.id_cont
cross join dbo.KRED_POG kp --on kp.id_kred_pog 
where kp.ID_KREDPOG = '0253 21'
-- provjere
and a.iznos_akolacije = pog.NET_NAL_zac 
and pog.NET_NAL = pog.net_nal_zac -- dva ista, ostalih 40 su promjenjeni