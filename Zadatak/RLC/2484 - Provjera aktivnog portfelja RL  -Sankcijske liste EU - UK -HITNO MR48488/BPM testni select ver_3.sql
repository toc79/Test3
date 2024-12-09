/* Zbog starih definicija nazivi može doći do duplanja naziva deifnicija 
ltrim(rtrim(def_title)) as def_title
kada se gleda distinct
title="Ime i prezime kontakt osobe" display_group="1. Osnovni podaci o društvu/fizičkoj osobi"
title="1. Tvrtka društva" display_group="2.1 Vlasnička struktura - pravne osobe"
title="2. Tvrtka društva" display_group="2.1 Vlasnička struktura - pravne osobe"
title="3. Tvrtka društva" display_group="2.1 Vlasnička struktura - pravne osobe"
title="4. Tvrtka društva" display_group="2.1 Vlasnička struktura - pravne osobe"
title="1. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_group="2.2 Vlasnička struktura - fizičke osobe"
title="2. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_group="2.2 Vlasnička struktura - fizičke osobe"
title="3. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_group="2.2 Vlasnička struktura - fizičke osobe"
title="4. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_group="2.2 Vlasnička struktura - fizičke osobe"
title="1. Ime i prezime" description="1. Ime i prezime" display_group="2.3 Uprava društva"
title="2. Ime i prezime" description="2. Ime i prezime" display_group="2.3 Uprava društva"
title="3. Ime i prezime" description="3. Ime i prezime" display_group="2.3 Uprava društva"
title="1. Ime i prezime" description="1. Ime i prezime" display_group="2.4 Prokuristi društva"
title="2. Ime i prezime" description="2. Ime i prezime" display_group="2.4 Prokuristi društva"
title="3. Ime i prezime" description="3. Ime i prezime" display_group="2.4 Prokuristi društva"
title="1. Pravna osoba" display_group="3.2. Konsolidacija"
title="2. Pravna osoba" display_group="3.2. Konsolidacija"
title="3. Pravna osoba" display_group="3.2. Konsolidacija"
title="1. Ime i prezime" description="1. Ime i prezime" display_group="4. Zakonski zastupnik/punomoćenik"
title="2. Ime i prezime" description="2. Ime i prezime" display_group="4. Zakonski zastupnik/punomoćenik"
title="3. Ime i prezime" description="3. Ime i prezime" display_group="4. Zakonski zastupnik/punomoćenik"
title="4. Ime i prezime" description="4. Ime i prezime" display_group="4. Zakonski zastupnik/punomoćenik"

*/
-- <data_field name="customer_desc" type="string" title="  Naziv/ime i prezime (primatelja leasing)" description="  Naziv/ime i prezime (primatelja leasing)" display_to_user="true" display_group="1. Osnovni podaci o društvu/fizičkoj osobi" />
-- To je istovremeno i partner u nova pa nisam radio provjeru, ti partneri imaju Rezident i poštu  pa bi i po tome valjalo gledati
-- select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str  
-- into #all_def_names -- ili UNION ALL
-- from dbo.gv_bpm_data_field_instance dfi (nolock)
-- where process_id = 'zspnft_parent_rlhr'
-- and def_name in ('customer_desc') 
-- and is_set = 1
-- and val_str != ''
--union all
-- <data_field name="contact_desc" type="string" title="Ime i prezime kontakt osobe" description="Ime i prezime kontakt osobe" display_to_user="true" display_group="1. Osnovni podaci o društvu/fizičkoj osobi" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str  
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('contact_desc') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_po_manage_desc1" type="string" title="1. Tvrtka društva" description="1. Tvrtka društva" display_to_user="true" display_group="2.1 Vlasnička struktura - pravne osobe" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_po_manage_desc1') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_po_manage_desc2" type="string" title="2. Tvrtka društva" description="2. Tvrtka društva" display_to_user="true" display_group="2.1 Vlasnička struktura - pravne osobe" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str 
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_po_manage_desc2') 
and is_set = 1
and val_str != ''
 union all
-- <data_field name="related_po_manage_desc3" type="string" title="3. Tvrtka društva" description="3. Tvrtka društva" display_to_user="true" display_group="2.1 Vlasnička struktura - pravne osobe" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str 
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_po_manage_desc3') 
and is_set = 1
and val_str != ''
 union all
-- <data_field name="related_po_manage_desc4" type="string" title="4. Tvrtka društva" description="4. Tvrtka društva" display_to_user="true" display_group="2.1 Vlasnička struktura - pravne osobe" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_po_manage_desc4') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_fo_manage_desc1" type="string" title="1. Ime i prezime (Vlasnička struktura - fizičke osobe)" description="1. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_fo_manage_desc1') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_fo_manage_desc2" type="string" title="2. Ime i prezime (Vlasnička struktura - fizičke osobe)" description="2. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_fo_manage_desc2') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_fo_manage_desc3" type="string" title="3. Ime i prezime (Vlasnička struktura - fizičke osobe)" description="3. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_fo_manage_desc3') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_fo_manage_desc4" type="string" title="4. Ime i prezime (Vlasnička struktura - fizičke osobe)" description="4. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_fo_manage_desc4') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="management_desc1" type="string" title="1. Ime i prezime" description="1. Ime i prezime" display_to_user="true" display_group="2.3 Uprava društva" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('management_desc1') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="management_desc2" type="string" title="2. Ime i prezime" description="2. Ime i prezime" display_to_user="true" display_group="2.3 Uprava društva" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('management_desc2') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="management_desc3" type="string" title="3. Ime i prezime" description="3. Ime i prezime" display_to_user="true" display_group="2.3 Uprava društva" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('management_desc3') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="procurator_desc1" type="string" title="1. Ime i prezime" description="1. Ime i prezime" display_to_user="true" display_group="2.4 Prokuristi društva" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('procurator_desc1') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="procurator_desc2" type="string" title="2. Ime i prezime" description="2. Ime i prezime" display_to_user="true" display_group="2.4 Prokuristi društva" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('procurator_desc2') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="procurator_desc3" type="string" title="3. Ime i prezime" description="3. Ime i prezime" display_to_user="true" display_group="2.4 Prokuristi društva" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('procurator_desc3') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="consolidation_desc1" type="string" description="1. Pravna osoba" title="1. Pravna osoba" display_to_user="true" display_group="3.2. Konsolidacija" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('consolidation_desc1') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="consolidation_desc2" type="string" description="2. Pravna osoba" title="2. Pravna osoba" display_to_user="true" display_group="3.2. Konsolidacija" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('consolidation_desc2') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="consolidation_desc3" type="string" description="3. Pravna osoba" title="3. Pravna osoba" display_to_user="true" display_group="3.2. Konsolidacija" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('consolidation_desc3') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="assignee_desc" type="string" title="1. Ime i prezime" description="1. Ime i prezime" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('assignee_desc') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="assignee_desc2" type="string" title="2. Ime i prezime" description="2. Ime i prezime" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('assignee_desc2') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="assignee_desc3" type="string" title="3. Ime i prezime" description="3. Ime i prezime" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('assignee_desc3') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="assignee_desc4" type="string" title="4. Ime i prezime" description="4. Ime i prezime" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
select process_instance_id, process_date_created, def_name, ltrim(rtrim(def_title)) as def_title, ltrim(rtrim(def_field_group)) as def_field_group, val_str
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('assignee_desc4') 
and is_set = 1
and val_str != ''

-- PIVOT  za sada netreba
-- može i * umjesto nabrajanja, ali navođenjem točnih naziva kolona time strogo definiramo redoslijed prikaza kolona 
--select process_instance_id, process_date_created, uloga, contact_desc, related_po_manage_desc1
--into #contact_descPivot from #all_def_names
--pivot (max(val_str) for def_name in ([contact_desc], [related_po_manage_desc1])) as PivotTable
-- drop table #all_def_names

select * from #all_def_names order by process_instance_id
--drop table #all_def_names

select distinct def_title, def_field_group from #all_def_names order by 2,1

select * 
from #all_def_names p
outer apply (  
	select COUNT(*) cnt  
	from B2RL.dbo.aml_Eu_Uk_list l  
	where  
		--/* preverjanje za fizično osebo */  
		--	( /*o.sifra = 'FO'  
		--	and*/ (p.ime <> ''  
		--		and ltrim(rtrim(l.[name])) COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.ime)) + '%') COLLATE Latin1_General_CI_AI)  
		--	and (p.priimek <> ''  
		--		and ltrim(rtrim(l.[name])) COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.priimek)) + '%') COLLATE Latin1_General_CI_AI)  
		--	)
		--OR   
		/* preverjanje za ostale osebe */  
			( /*o.sifra != 'FO'  
			and*/ (p.val_str <> ''  
				and ltrim(rtrim(l.[name])) COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.val_str)) + '%') COLLATE Latin1_General_CI_AI)  
			)  
		--or   
		--    (p.ulica <> ''  
		--    and l.[address] COLLATE Latin1_General_CI_AI LIKE ('%' + ltrim(rtrim(p.ulica)) + '%') COLLATE Latin1_General_CI_AI)  
	) aml  
where cnt > 0