declare @session_id as char(40)
set @session_id = {@session_id}

select --required
	convert(varchar(30), zo.id_opom) + ';' + pogp.id_poroka as [doc_id], --cast(pogp.id_poroka as char(30)) as doc_id,
	'OBV_POR_SSOFT_RLC' as [report_name], --'Opomena jamcu za neplaćena potraživanja' as [attachment_name]
	--optional
	-- CAST(0 as bit) as use_queue,
	-- 60 AS queue_delay, --u sec
	-- 1 AS queue_priority,
	-- 3 AS retry_count,
	-- 3000 AS retry_interval -- ne radi, postavi default
from dbo.za_opom zo
	--inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
	inner join dbo.pog_poro pogp on zo.id_cont = pogp.id_cont
	inner join 
		(	Select a.id_kupca, max(email) as mail_to
			From dbo.p_kontakt a 
				inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
			Where a.neaktiven = 0 and b.sifra IN ('MAIL')
			Group by a.id_kupca
		) d on pogp.id_poroka = d.id_kupca
where zo.st_opomina in (1,2,3)
	and isnull(zo.dok_opom, '') != ''
	and pogp.neaktiven = 0
	and pogp.oznaka in ('0', '1')
	
union all 

select 
	convert(varchar(30), zo.id_opom) + ';' + pogp.id_poroka as [doc_id],
	'OPOMJAM_SSOFT_RLC' as [report_name],
from dbo.za_opom zo
	--inner join dbo.xdoc_document_tmp xdt on xdt.session_id = @session_id and xdt.filter = 1 and xdt.doc_id = cast(eef.id as varchar(40))
	inner join dbo.pog_poro pogp on zo.id_cont = pogp.id_cont
	inner join 
		(	Select a.id_kupca, max(email) as mail_to
			From dbo.p_kontakt a 
				inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga
			Where a.neaktiven = 0 and b.sifra IN ('MAIL')
			Group by a.id_kupca
		) d on pogp.id_poroka = d.id_kupca
where zo.st_opomina in (1,2,3)
	and isnull(zo.dok_opom, '') != ''
	and pogp.neaktiven = 0
	and pogp.oznaka in ('A')

union all 

--ID pripreme 6


order by 2, 1