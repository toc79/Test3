declare @id_register varchar(100) = 'PART_KATEG4'
declare @id_kupca char(6) = '029344'
declare @skrbnik_1 varchar(100) = '000012' --id_key
declare @MT varchar(100) = (select rtrim(kategorija4) from dbo.partner where id_kupca = @id_kupca) --and id_key= @skrbnik_1)
--select * from dbo.general_register where id_register = @id_register-- and id_key= @skrbnik_1
--select @id_kupca, @id_register, @skrbnik_1, @MT
select skrbnik_1, kategorija4,* from dbo.partner where kategorija4 is not null and kategorija4 != ''
select skrbnik_1, kategorija4,* from dbo.partner where kategorija4 is not null and kategorija4 != ''

select pog.id_pon, pog.id_odobrit, pog.id_kupca, par.naz_kr_kup, par.skrbnik_1, s1.kategorija4, pog.STATUS_AKT, pog.id_strm
	,* 
from dbo.POGODBA pog
inner join dbo.partner par on pog.id_kupca = par.id_kupca
left join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm --Podesiti da ako MT postoji u dbo.STRM1 da tek onda ide
where 1=1
and pog.id_kupca = @id_kupca 
and pog.status_akt != 'Z'
and MT.id_strm != pog.id_strm --and isnull(s1.kategorija4, '') != '' -- za skrbnika postoji popunjen MT

select pog.id_pon, pog.id_odobrit, pog.id_kupca, par.naz_kr_kup, par.skrbnik_1, s1.kategorija4, pog.STATUS_AKT, pog.id_strm
	,* 
from dbo.POGODBA pog
inner join dbo.partner par on pog.id_kupca = par.id_kupca
left join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm --Podesiti da ako MT postoji u dbo.STRM1 da tek onda ide
where 1=1
and s1.id_kupca = @skrbnik_1 
and pog.status_akt != 'Z'
and MT.id_strm = pog.id_strm 

-- Fixed assets (OS)
select par.skrbnik_1, pog.STATUS_AKT, pog.id_strm, fa.id_strm fa_id_strm
	, fa.status
	, fa.* 
from dbo.POGODBA pog
inner join dbo.partner par on pog.id_kupca = par.id_kupca
inner join dbo.fa fa on pog.id_cont = fa.id_cont
where par.skrbnik_1 = @skrbnik_1
and pog.status_akt != 'Z'
--and pog.id_strm != @MT
and fa.id_strm != @MT
--and fa.status in ('A', 'P')

-- Fixed assets (OS) fa_dnev
select par.skrbnik_1, pog.STATUS_AKT, pog.id_strm, fa.id_strm fa_id_strm
	--, fa.status
	, fa.* 
from dbo.POGODBA pog
inner join dbo.partner par on pog.id_kupca = par.id_kupca
inner join dbo.fa_dnev fa on pog.id_cont = fa.id_cont
where par.skrbnik_1 = @skrbnik_1
and pog.status_akt != 'Z'
--and pog.id_strm != @MT
and fa.id_strm != @MT 