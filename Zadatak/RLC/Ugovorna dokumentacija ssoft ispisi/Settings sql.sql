select
	a.p_podjetje,
	a.p_dav_stev,
	a.p_naslov,
	a.p_kraj,
	a.p_direktor,
	a.p_posta,
	a.p_emso,
	a.p_reg_stev,
	a.p_tel,
	a.p_fax,
	a.p_email,
	a.p_http,
	a.p_zrac,
	'Raiffeisen leasinga' as RLa, 
	b.data as print_logo1
from dbo.nastavit a
left join dbo.nova_resources b on b.id_resource = 'print_logo1' and b.active=1