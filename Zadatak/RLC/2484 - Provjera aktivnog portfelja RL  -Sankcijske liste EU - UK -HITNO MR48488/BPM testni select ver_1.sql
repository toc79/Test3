-- <data_field name="contact_desc" type="string" title="Ime i prezime kontakt osobe" description="Ime i prezime kontakt osobe" display_to_user="true" display_group="1. Osnovni podaci o društvu/fizičkoj osobi" />
select process_instance_id, process_date_created, def_name, 'Ime i prezime kontakt osobe' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
into #all_def_names -- ili UNION ALL
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('contact_desc') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_po_manage_desc1" type="string" title="1. Tvrtka društva" description="1. Tvrtka društva" display_to_user="true" display_group="2.1 Vlasnička struktura - pravne osobe" />
select process_instance_id, process_date_created, def_name, '1. Tvrtka društva' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_po_manage_desc1') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_po_manage_desc2" type="string" title="2. Tvrtka društva" description="2. Tvrtka društva" display_to_user="true" display_group="2.1 Vlasnička struktura - pravne osobe" />
select process_instance_id, process_date_created, def_name, '2. Tvrtka društva' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_po_manage_desc2') 
and is_set = 1
and val_str != ''
 union all
-- <data_field name="related_po_manage_desc3" type="string" title="3. Tvrtka društva" description="3. Tvrtka društva" display_to_user="true" display_group="2.1 Vlasnička struktura - pravne osobe" />
select process_instance_id, process_date_created, def_name, '3. Tvrtka društva' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_po_manage_desc3') 
and is_set = 1
and val_str != ''
 union all
-- <data_field name="related_po_manage_desc4" type="string" title="4. Tvrtka društva" description="4. Tvrtka društva" display_to_user="true" display_group="2.1 Vlasnička struktura - pravne osobe" />
select process_instance_id, process_date_created, def_name, '4. Tvrtka društva' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_po_manage_desc4') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_fo_manage_desc1" type="string" title="1. Ime i prezime (Vlasnička struktura - fizičke osobe)" description="1. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
select process_instance_id, process_date_created, def_name, '1. Ime i prezime (Vlasnička struktura - fizičke osobe)' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_fo_manage_desc1') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_fo_manage_desc2" type="string" title="2. Ime i prezime (Vlasnička struktura - fizičke osobe)" description="2. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
select process_instance_id, process_date_created, def_name, '2. Ime i prezime (Vlasnička struktura - fizičke osobe)' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_fo_manage_desc2') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_fo_manage_desc3" type="string" title="3. Ime i prezime (Vlasnička struktura - fizičke osobe)" description="3. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
select process_instance_id, process_date_created, def_name, '3. Ime i prezime (Vlasnička struktura - fizičke osobe)' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_fo_manage_desc3') 
and is_set = 1
and val_str != ''
union all
-- <data_field name="related_fo_manage_desc4" type="string" title="4. Ime i prezime (Vlasnička struktura - fizičke osobe)" description="4. Ime i prezime (Vlasnička struktura - fizičke osobe)" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
select process_instance_id, process_date_created, def_name, '4. Ime i prezime (Vlasnička struktura - fizičke osobe)' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('related_fo_manage_desc4') 
and is_set = 1
and val_str != ''

union all
-- <data_field name="management_desc1" type="string" title="1. Ime i prezime" description="1. Ime i prezime" display_to_user="true" display_group="2.3 Uprava društva" />
select process_instance_id, process_date_created, def_name, '1. Ime i prezime' as uloga, val_str  --ltrim(rtrim(def_field_group)) + ' - 1.' as def_field_group
from dbo.gv_bpm_data_field_instance dfi (nolock)
where process_id = 'zspnft_parent_rlhr'
and def_name in ('management_desc1') 
and is_set = 1
and val_str != ''
 680:     <data_field name="management_desc2" type="string" title="2. Ime i prezime" description="2. Ime i prezime" display_to_user="true" display_group="2.3 Uprava društva" />
 709:     <data_field name="management_desc3" type="string" title="3. Ime i prezime" description="3. Ime i prezime" display_to_user="true" display_group="2.3 Uprava društva" />
 745:     <data_field name="procurator_desc1" type="string" title="1. Ime i prezime" description="1. Ime i prezime" display_to_user="true" display_group="2.4 Prokuristi društva" />
 779:     <data_field name="procurator_desc2" type="string" title="2. Ime i prezime" description="2. Ime i prezime" display_to_user="true" display_group="2.4 Prokuristi društva" />
 813:     <data_field name="procurator_desc3" type="string" title="3. Ime i prezime" description="3. Ime i prezime" display_to_user="true" display_group="2.4 Prokuristi društva" />
 875:     <data_field name="consolidation_desc1" type="string" description="1. Pravna osoba" title="1. Pravna osoba" display_to_user="true" display_group="3.2. Konsolidacija" />
 901:     <data_field name="consolidation_desc2" type="string" description="2. Pravna osoba" title="2. Pravna osoba" display_to_user="true" display_group="3.2. Konsolidacija" />
 927:     <data_field name="consolidation_desc3" type="string" description="3. Pravna osoba" title="3. Pravna osoba" display_to_user="true" display_group="3.2. Konsolidacija" />
 954:     <data_field name="assignee_desc" type="string" title="1. Ime i prezime" description="1. Ime i prezime" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
1016:     <data_field name="assignee_desc2" type="string" title="2. Ime i prezime" description="2. Ime i prezime" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
1077:     <data_field name="assignee_desc3" type="string" title="3. Ime i prezime" description="3. Ime i prezime" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
1137:     <data_field name="assignee_desc4" type="string" title="4. Ime i prezime" description="4. Ime i prezime" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />

-- PIVOT  za sada netreba
-- može i * umjesto nabrajanja, ali navođenjem točnih naziva kolona time strogo definiramo redoslijed prikaza kolona 
--select process_instance_id, process_date_created, uloga, contact_desc, related_po_manage_desc1
--into #contact_descPivot from #all_def_names
--pivot (max(val_str) for def_name in ([contact_desc], [related_po_manage_desc1])) as PivotTable

select * from #all_def_names order by process_instance_id
--select * from #contact_descPivot

-- drop table #all_def_names
--drop table #contact_descPivot