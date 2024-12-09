--MID 49739 g_vuradin 06.02.2023

declare @export_id as varchar(40)

set @export_id = {@export_id}

select cast(a.id as varchar(30)) as doc_id
from dbo.edoc_exported_files a
where cast(a.export_id as varchar(40)) = @export_id
and a.id_kupca in (Select a.id_kupca From dbo.p_kontakt a inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga Where a.neaktiven = 0 and b.sifra IN ('MAIL') Group by a.id_kupca) 
--and a.id_kupca not in (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' group by id_kupca)
and a.id_edoc_doctype = 'TaxChngIx'