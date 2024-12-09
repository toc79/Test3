-- 23.03.2022 g_tomislav MID 48488 - created. Final check is based by gfn_CheckInternationalBlackListSummary

select par.id_kupca, cast(naziv1_kup as varchar(150)) as [Naziv 1 partnera]
	, cast(direktor as varchar(150)) as Direktor
	, cast(kontakt as varchar(150)) as [Kontakt osoba]
	, cast(delodajale as varchar(150)) as [Poslodavac]
	, cast(kontakt_d as varchar(150)) as [Poslodavac - Kontakt]
	, cast(ime as varchar(150)) as ime
	, cast(priimek as varchar(150)) as priimek
	, vr_osebe, drzavljan, drzavljanstvo, id_poste_sed, id_poste, id_poste_d, id_poste_k
into #all_partners
from dbo.partner par
where par.neaktiven = 0
and (isnull(drzavljan, 'HR') != 'HR' or isnull(drzavljanstvo, 'HR') != 'HR' 
	or isnull(left(id_poste_sed, 2), 'HR')  != 'HR' or isnull(left(id_poste, 2), 'HR')  != 'HR' or isnull(left(id_poste_d, 2), 'HR')  != 'HR' or isnull(left(id_poste_k, 2), 'HR') != 'HR')
--aktivne partnere koji nisu HR (u NOVA prema podatku Rezident države, pošta sjedišta, pošta za slanje i sl.)

select id_kupca, polje, nazivPartnera
	, ime, priimek, vr_osebe
	, drzavljan, drzavljanstvo, id_poste_sed, id_poste, id_poste_d, id_poste_k
into #all_partners_pivot
from (
	select id_kupca, [Naziv 1 partnera], Direktor, [Kontakt osoba], [Poslodavac], [Poslodavac - Kontakt]
		, ime, priimek, vr_osebe
		, drzavljan, drzavljanstvo, id_poste_sed, id_poste, id_poste_d, id_poste_k
	from #all_partners
) a
unpivot 
	(nazivPartnera for polje in ([Naziv 1 partnera], [Direktor], [Kontakt osoba], [Poslodavac], [Poslodavac - Kontakt])
) b
where ltrim(rtrim(nazivPartnera)) != '' or nazivPartnera is null

select par.id_kupca, p.Polje, p.nazivPartnera as Naziv_partnera
	, par.ime as Ime, par.priimek as Prezime, par.vr_osebe as Vr_osobe
	, par.drzavljan as Rezident_drzave, par.drzavljanstvo as Drzavljanstvo
	, par.id_poste_sed as Posta_sjedista, par.id_poste as Posta_za_slanje, par.id_poste_d as Posta_Poslodavac, par.id_poste_k as Posta_Kontakt_osoba
	, dbo.gfn_StringToFOX([name]) as Naziv_s_EU_UK_liste
into #temp48488
from #all_partners_pivot p
inner join #all_partners par on p.id_kupca = par.id_kupca 
outer apply (  
	select l.[name]  
	from ${db:snapshots_b2rl}.dbo.aml_Eu_Uk_list l  
	where  
		/* preverjanje za fizično osebo */  
			( /*o.sifra = 'FO'  
			and*/ (p.ime <> ''  
				and l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.ime)) + '%') COLLATE Latin1_General_CI_AI)  
			and (p.priimek <> ''  
				and l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.priimek)) + '%') COLLATE Latin1_General_CI_AI)  
			)
		OR   
		/* preverjanje za ostale osebe */  
			( /*o.sifra != 'FO'  
			and*/ (p.nazivPartnera <> ''  
				and (l.[name] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.nazivPartnera)) + '%') COLLATE Latin1_General_CI_AI)  
				)
			)
		--or   
		--    (p.ulica <> ''  
		--    and l.[address] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.ulica)) + '%') COLLATE Latin1_General_CI_AI)  
	) aml  
where [name] is not null

-- GDPR LOGIRANJE
SELECT cs.id as id
INTO #tempVrste
FROM dbo.gfn_split_ids( (Select [val] FROM dbo.CUSTOM_SETTINGS WHERE code='Nova.GDPR.ListOfCustomerTypesForAccessLog'),',') cs

declare @xml as xml
set @xml = 
(
	SELECT * 
	FROM 
	(
		SELECT
			t.id_kupca as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'' as  '@Additional_desc'
		FROM #temp48488 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		GROUP BY t.ID_KUPCA, p.vr_osebe 
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();
exec dbo.gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null, 'Naziv 1, Ime i prezime, Pošta', 'INTERNAL', 'CUSTOM_REPORT', 'Provjera aktivnog portfelja - Sankcijske liste EU - UK', '48488', @xml
drop table #tempVrste
-- KONEC GDPR

select * from #temp48488 order by id_kupca
drop table #temp48488

drop table #all_partners
drop table #all_partners_pivot