select 
    a.id_pog
    , a.iznos_akolacije
	, pog.id_cont
	, kp.id_kredpog
	, kp.all_in_price_for_NPM
	, kp.all_in_price_for_NPM as all_in_price_for_NPM_zac
	--, * 
from dbo._tmp_alociranje_MR48353 a
join dbo.POGODBA pog on dbo.gfn_Id_cont4Id_pog(a.id_pog) = pog.id_cont
left join dbo.pogodba_kp_npm pkp on pog.ID_CONT = pkp.id_cont
cross join dbo.KRED_POG kp --on kp.id_kred_pog 
where kp.ID_KREDPOG = '0248 21' --'0253 21'
-- provjere
and a.iznos_akolacije = pog.NET_NAL_zac --svi
and pkp.id_cont is null -- ne smije biti alokacije
--and pog.NET_NAL = pog.net_nal_zac -- dva ista, ostalih 40 su promjenjeni
order by pog.id_cont