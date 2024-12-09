select par.id_kupca, cast(naz_kr_kup as varchar(150)) as naz_kr_kup
	, cast(direktor as varchar(150)) as direktor
	, cast(kontakt as varchar(150)) as kontakt
	, cast(delodajale as varchar(150)) as delodajale
	, cast(kontakt_d as varchar(150)) as kontakt_d
	, cast(ime as varchar(150)) as ime
	, cast(priimek as varchar(150)) as priimek
	, vr_osebe, drzavljan, drzavljanstvo, id_poste_sed, id_poste, id_poste_d, id_poste_k
into #all_partners
from dbo.partner par
where par.neaktiven = 0
and (isnull(drzavljan, 'HR') != 'HR' or isnull(drzavljanstvo, 'HR') != 'HR' 
	or isnull(left(id_poste_sed, 2), 'HR')  != 'HR' or isnull(left(id_poste, 2), 'HR')  != 'HR' or isnull(left(id_poste_d, 2), 'HR')  != 'HR' or isnull(left(id_poste_k, 2), 'HR') != 'HR')
--aktivne partnere koji nisu HR (u NOVA prema podatku Rezident države, pošta sjedišta i pošta za slanje)

select * from #all_partners

select id_kupca, uloga, nazivPartnera
	, ime, priimek, vr_osebe
	, drzavljan, drzavljanstvo, id_poste_sed, id_poste, id_poste_d, id_poste_k
into #all_partners_pivot
from (
	select id_kupca, naz_kr_kup, direktor, kontakt, delodajale, kontakt_d
		, ime, priimek, vr_osebe
		, drzavljan, drzavljanstvo, id_poste_sed, id_poste, id_poste_d, id_poste_k
	from #all_partners
) a
unpivot 
	(nazivPartnera for uloga in ([naz_kr_kup], [direktor], [kontakt], [delodajale], [kontakt_d])
) b
where ltrim(rtrim(nazivPartnera)) != '' or nazivPartnera is null

select * from #all_partners_pivot


select * 
from #all_partners_pivot p
outer apply (  
	select COUNT(*) cnt  
	from B2RL_TEST.dbo.aml_Eu_Uk_list l  
	where  
		/* preverjanje za fizično osebo */  
			( /*o.sifra = 'FO'  
			and*/ (p.ime <> ''  
				and ltrim(rtrim(l.[name])) COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.ime)) + '%') COLLATE Latin1_General_CI_AI)  
			and (p.priimek <> ''  
				and ltrim(rtrim(l.[name])) COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.priimek)) + '%') COLLATE Latin1_General_CI_AI)  
			)
		OR   
		/* preverjanje za ostale osebe */  
			( /*o.sifra != 'FO'  
			and*/ (p.nazivPartnera <> ''  
				and ltrim(rtrim(l.[name])) COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.nazivPartnera)) + '%') COLLATE Latin1_General_CI_AI)  
			)  
		--or   
		--    (p.ulica <> ''  
		--    and l.[address] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.ulica)) + '%') COLLATE Latin1_General_CI_AI)  
	) aml  
where cnt > 0


-- drop table #all_partners
-- drop table #all_partners_pivot



/* 
 select 
	* 
 from #all_partners a
 outer apply (select *, ('%' + a.ime +'%') as test from dbo._tmp_EuUkList_MR48488 l 
				--where charindex(ltrim(rtrim(a.ime)), l.naziv) > 0 
				--where l.naziv like ('%KURINNY%') 
				where (ltrim(rtrim(l.naziv)) like ('%' + ltrim(rtrim(a.ime)) +'%')
					and ltrim(rtrim(l.naziv)) like ('%' + ltrim(rtrim(a.priimek)) +'%'))
				or (ltrim(rtrim(l.naziv)) like ltrim(rtrim(a.naz_kr_kup))
			) lista
 where a.ime != '' and a.priimek != ''
 --and lista.naziv like ('%' + a.ime +'%')
 --and lista.naziv like ('%KURINNY%') and a.ime */