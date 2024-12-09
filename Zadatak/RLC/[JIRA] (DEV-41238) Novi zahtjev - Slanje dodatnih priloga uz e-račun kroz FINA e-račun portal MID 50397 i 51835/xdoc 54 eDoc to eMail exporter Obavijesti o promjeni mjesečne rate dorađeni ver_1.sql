--SQL CANDIDATES
--MID 49739 g_vuradin 06.02.2023
--29.02.2024 g_tomislav MID 51835 - excluding those already printed in FAK_LOBR_SSOFT_RLC

declare @export_id as varchar(40)

set @export_id = {@export_id}

select cast(a.id as varchar(30)) as doc_id
from dbo.edoc_exported_files a
left join dbo.rep_ind ri on convert(int, a.document_id) = ri.id_rep_ind
left join dbo.najem_fa nf on left(ri.opombe, 11) = nf.ddv_id --already printed in FAK_LOBR_SSOFT_RLC
where cast(a.export_id as varchar(40)) = @export_id
and a.id_kupca in (Select a.id_kupca From dbo.p_kontakt a inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga Where a.neaktiven = 0 and b.sifra IN ('MAIL') Group by a.id_kupca) 
and nf.ddv_id is null
and a.id_edoc_doctype = 'TaxChngIx'

--and a.id_kupca not in (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' group by id_kupca)