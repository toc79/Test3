-- insert into dbo.EXT_FUNC values ('Sys.EventHandler.ProcessXml.Partner.Changed', '', 'SQL_CS', 0, null)
-- select ID_STRM, status_akt,* from dbo.pogodba where id_kupca = '029344' and STATUS_AKT != 'Z'
-- update dbo.pogodba set id_strm = '0903' where id_cont in (72208,72209)
-- update dbo.fa_dnev set id_strm = '0903' where id_cont in ()
--Parameters {X}:
--{0} - 0 - 'g_tomislav'   
--{1} - 1 - 'partner.changed'   
--{2} - 2 - 'id_kupca'  
--{3} - 3 - '000012'
--{4} - 4 - 'changed_fields'
--{5} - 5 - 'SKRBNIK_1,KATEGORIJA4,dat_poprave' - list of changed fields9)

declare @changed_fields varchar(8000) = 'KATEGORIJA4,dat_poprave' --SKRBNIK_1,
declare @changed_Skrbnik_1 bit = case when charindex('SKRBNIK_1', @changed_fields) > 0 then 1 else 0 end
declare @changed_Kategorija4 bit = case when charindex('KATEGORIJA4', @changed_fields) > 0 then 1 else 0 end
--select @changed_Skrbnik_1, @changed_Kategorija4 

if @changed_Skrbnik_1 > 0 or @changed_Kategorija4 > 0
begin
	declare @id_kupca char(6) = '036651' --'000012'
	declare @event_name varchar(40) = 'partner.changed'
	-- Podešavanja na RLC su: je_revalor = 0, TIP_AMORTIZACIJE = 0,  tri_am_st = 1 iz dbo.fa_nastavit
	declare @je_revalor bit = (select je_revalor from dbo.fa_nastavit)
	declare @tip_amortizacije tinyint = (select tip_amortizacije from dbo.fa_nastavit)
	declare @tri_am_st bit = (select tri_am_st from dbo.fa_nastavit)
	declare @daily_amort_enabled bit = 0 -- Nemaju licencu GOBJ_LicenceManager.IsModuleEnabled("FA_DAILY_DEPRECIATION") = .F.

	select pog.id_strm, pog.* 
	from dbo.POGODBA pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	left join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT postoji u dbo.STRM1 da tek onda ide tj. za skrbnika postoji popunjen MT
	where (1 = @changed_Skrbnik_1 and pog.id_kupca = @id_kupca -- kod promjene skrbnika_1 na partneru: provjeravaju se svi partnerovi ugovori
		or 1 = @changed_Kategorija4 and s1.id_kupca = @id_kupca) -- kod promjene kategorije4 na partneru: provjeravaju se za istog svi partneri (te ugovori) gdje je on skrbnik 
	and pog.status_akt != 'Z'
	--and MT.id_strm != pog.id_strm 
	and pog.id_strm = '0901'
	order by pog.id_cont

	-- Fixed assets (OS)
	select fa.* 
	from dbo.POGODBA pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT postoji u dbo.STRM1 da tek onda ide tj. za skrbnika postoji popunjen MT
	inner join dbo.fa fa on pog.id_cont = fa.id_cont
	where (1 = @changed_Skrbnik_1 and pog.id_kupca = @id_kupca -- kod promjene skrbnika_1 na partneru: provjeravaju se svi partnerovi ugovori
		or 1 = @changed_Kategorija4 and s1.id_kupca = @id_kupca) -- kod promjene kategorije4 na partneru: provjeravaju se za istog svi partneri (te ugovori) gdje je on skrbnik
	--and fa.id_strm != MT.id_strm 
	and fa.id_strm = '0901'
	and fa.status in ('A', 'P')
	--and fa.naziv1 like '%&%'
	order by pog.id_cont

	-- New fixed assets (OS) fa_dnev
	select fa.* 
	from dbo.POGODBA pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT postoji u dbo.STRM1 da tek onda ide tj. za skrbnika postoji popunjen MT
	inner join dbo.fa_dnev fa on pog.id_cont = fa.id_cont
	where (1 = @changed_Skrbnik_1 and pog.id_kupca = @id_kupca -- kod promjene skrbnika_1 na partneru: provjeravaju se svi partnerovi ugovoru
		or 1 = @changed_Kategorija4 and s1.id_kupca = @id_kupca) -- kod promjene kategorije4 na partneru: provjeravaju se za istog svi partneri (te ugovori) gdje je on skrbnik
	--and fa.id_strm != MT.id_strm 
	and fa.id_strm = '0901'
	order by pog.id_cont
end 
