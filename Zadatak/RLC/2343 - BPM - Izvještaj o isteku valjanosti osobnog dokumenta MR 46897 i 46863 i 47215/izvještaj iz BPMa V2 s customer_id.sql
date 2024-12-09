--29.06.2021 g_tomislav MID 46897 - created;

declare @today datetime = (cast(getdate() as date))
declare @process_instance_is_finished bit = 1

--ID klijenta, Naziv klijenta, Status, Broj AD ugovora 
--Ime i prezime, OIB, JMBG, Adresa prebivališta, Mjesto prebivališta
--Uloga, Naziv radnog mjesta
--Vrsta osob. dok., Broj osob. dok., Datum izdavanja osob. dok., Izdavatelj osob. dok., Datum valjanosti

--4. Zakonski zastupnik/punomoćenik - 1.
select process_instance_id, process_date_created, def_name, val_str--, def_title 
into #assignee
from dbo.gv_bpm_data_field_instance dfi (nolock)
where exists (select *
			from dbo.gv_bpm_data_field_instance (nolock)
			where process_id = 'zspnft_parent_rlhr' --zspnft_parent_rlhr
			and def_name in ('assignee_personal_doc_date')
			and is_set = 1
			and try_cast(val_str as datetime) <= @today
			and process_instance_is_finished = @process_instance_is_finished
			and process_instance_id = dfi.process_instance_id
			)
and def_name in ('assignee_nova_id1', 'assignee_desc', 'assignee_oib', 'assignee_address', 'assignee_place' --nema emso
	, 'assignee_work_place' -- uloga bi valjda bila '4. Zakonski zastupnik/punomoćenik - 1.' 
	, 'assignee_personal_doc_type', 'assignee_personal_doc_id' -- nema Datum izdavanja osob. dok.
	, 'assignee_personal_doc_department', 'assignee_personal_doc_date'
	, 'customer_id', 'customer_desc')
select * from #assignee

select process_instance_id, process_date_created, assignee_nova_id1, assignee_desc, assignee_oib, assignee_address, assignee_place, assignee_work_place, assignee_personal_doc_type, assignee_personal_doc_id, assignee_personal_doc_department, assignee_personal_doc_date, '4. Zakonski zastupnik/punomoćenik - 1' as uloga, customer_id, customer_desc 
into #assigneePivot from #assignee
pivot (max(val_str) for def_name in ([assignee_nova_id1], [assignee_desc], [assignee_oib], [assignee_address], [assignee_place] --nema emso
	, [assignee_work_place] -- uloga bi valjda bila '4. Zakonski zastupnik/punomoćenik - 1.' 
	, [assignee_personal_doc_type], [assignee_personal_doc_id] -- nema Datum izdavanja osob. dok.
	, [assignee_personal_doc_department], [assignee_personal_doc_date]
	, [customer_id], [customer_desc]
	)) as PivotTable
--select * from #assigneePivot

--4. Zakonski zastupnik/punomoćenik - 2.
select process_instance_id, process_date_created, def_name, val_str--, def_title 
into #assignee2
from dbo.gv_bpm_data_field_instance dfi (nolock)
where exists (select *
			from dbo.gv_bpm_data_field_instance (nolock)
			where process_id = 'zspnft_parent_rlhr' --zspnft_parent_rlhr
			and def_name in ('assignee_personal_doc_date2')
			and is_set = 1
			and try_cast(val_str as datetime) <= @today
			and process_instance_is_finished = @process_instance_is_finished
			and process_instance_id = dfi.process_instance_id
			)
and def_name in ('assignee_nova_id2', 'assignee_desc2', 'assignee_oib2', 'assignee_address2', 'assignee_place2' --nema emso
	, 'assignee_work_place2' -- uloga bi valjda bila '4. Zakonski zastupnik/punomoćenik - 1.' 
	, 'assignee_personal_doc_type2', 'assignee_personal_doc_id2' -- nema Datum izdavanja osob. dok.
	, 'assignee_personal_doc_department2', 'assignee_personal_doc_date2'
	, 'customer_id', 'customer_desc')
--select * from #assignee2

select process_instance_id, process_date_created, assignee_nova_id2, assignee_desc2, assignee_oib2, assignee_address2, assignee_place2, assignee_work_place2, assignee_personal_doc_type2, assignee_personal_doc_id2, assignee_personal_doc_department2, assignee_personal_doc_date2, '4. Zakonski zastupnik/punomoćenik - 2' as uloga, customer_id, customer_desc 
into #assigneePivot2 from #assignee2
pivot (max(val_str) for def_name in ([assignee_nova_id2], [assignee_desc2], [assignee_oib2], [assignee_address2], [assignee_place2] --nema emso
	, [assignee_work_place2] -- uloga bi valjda bila '4. Zakonski zastupnik/punomoćenik - 1.' 
	, [assignee_personal_doc_type2], [assignee_personal_doc_id2] -- nema Datum izdavanja osob. dok.
	, [assignee_personal_doc_department2], [assignee_personal_doc_date2]
	, [customer_id], [customer_desc]
	)) as PivotTable
--select * from #assigneePivot2

--2.2 Vlasnička struktura - fizičke osobe - 1
select process_instance_id, process_date_created, def_name, val_str--, def_title 
into #related_fo_manage_1
from dbo.gv_bpm_data_field_instance dfi (nolock)
where exists (select *
			from dbo.gv_bpm_data_field_instance (nolock)
			where process_id = 'zspnft_parent_rlhr' --zspnft_parent_rlhr
			and def_name in ('related_fo_manage_id_doc_date1')
			and is_set = 1
			and try_cast(val_str as datetime) <= @today
			and process_instance_is_finished = @process_instance_is_finished
			and process_instance_id = dfi.process_instance_id
			)
and def_name in ('related_fo_manage_nova_id1', 'related_fo_manage_desc1', 'related_fo_manage_oib1', 'related_fo_manage_address1', 'related_fo_manage_place1' --nema emso, work_place
	, 'related_fo_manage_ident_doc1' --1. Naziv i broj identifikacijske isprave - jedno polje za tip i broj
	, 'related_fo_manage_id_doc_issuer1' --1. Izdavatelj identifikacijske isprave
	, 'related_fo_manage_id_doc_date1' -- nema Datum izdavanja osob. dok.
	 , 'customer_id', 'customer_desc')
--select * from #related_fo_manage_1

select process_instance_id, process_date_created, related_fo_manage_nova_id1, related_fo_manage_desc1, related_fo_manage_oib1, related_fo_manage_address1, related_fo_manage_place1, '' as assignee_work_place, '' as assignee_personal_doc_type, related_fo_manage_ident_doc1, related_fo_manage_id_doc_issuer1,	related_fo_manage_id_doc_date1, '2.2 Vlasnička struktura - fizičke osobe - 1' as uloga, customer_id, customer_desc  
into #related_fo_manage_1Pivot from #related_fo_manage_1
pivot (max(val_str) for def_name in ([related_fo_manage_nova_id1], [related_fo_manage_desc1], [related_fo_manage_oib1], [related_fo_manage_address1], [related_fo_manage_place1]
	, [related_fo_manage_ident_doc1], [related_fo_manage_id_doc_issuer1], [related_fo_manage_id_doc_date1]
	, [customer_id], [customer_desc]
	)) as PivotTable
--select * from #related_fo_manage_1Pivot

--2.2 Vlasnička struktura - fizičke osobe - 2
select process_instance_id, process_date_created, def_name, val_str--, def_title 
into #related_fo_manage_2
from dbo.gv_bpm_data_field_instance dfi (nolock)
where exists (select *
			from dbo.gv_bpm_data_field_instance (nolock)
			where process_id = 'zspnft_parent_rlhr' --zspnft_parent_rlhr
			and def_name in ('related_fo_manage_id_doc_date2')
			and is_set = 1
			and try_cast(val_str as datetime) <= @today
			and process_instance_is_finished = @process_instance_is_finished
			and process_instance_id = dfi.process_instance_id
			)
and def_name in ('related_fo_manage_nova_id2', 'related_fo_manage_desc2', 'related_fo_manage_oib2', 'related_fo_manage_address2', 'related_fo_manage_place2' --nema emso, work_place
	, 'related_fo_manage_ident_doc2' --2. Naziv i broj identifikacijske isprave - jedno polje za tip i broj
	, 'related_fo_manage_id_doc_issuer2' --2. Izdavatelj identifikacijske isprave
	, 'related_fo_manage_id_doc_date2' -- nema Datum izdavanja osob. dok.
	, 'customer_id', 'customer_desc')
--select * from #related_fo_manage_2

select process_instance_id, process_date_created, related_fo_manage_nova_id2, related_fo_manage_desc2, related_fo_manage_oib2, related_fo_manage_address2, related_fo_manage_place2, '' as assignee_work_place, '' as assignee_personal_doc_type, related_fo_manage_ident_doc2, related_fo_manage_id_doc_issuer2,	related_fo_manage_id_doc_date2, '2.2 Vlasnička struktura - fizičke osobe - 2' as uloga, customer_id, customer_desc 
into #related_fo_manage_2Pivot from #related_fo_manage_2
pivot (max(val_str) for def_name in ([related_fo_manage_nova_id2], [related_fo_manage_desc2], [related_fo_manage_oib2], [related_fo_manage_address2], [related_fo_manage_place2]
	, [related_fo_manage_ident_doc2], [related_fo_manage_id_doc_issuer2], [related_fo_manage_id_doc_date2]
	, [customer_id], [customer_desc]
	)) as PivotTable
--select * from #related_fo_manage_2Pivot

--2.2 Vlasnička struktura - fizičke osobe - 3
select process_instance_id, process_date_created, def_name, val_str--, def_title 
into #related_fo_manage_3
from dbo.gv_bpm_data_field_instance dfi (nolock)
where exists (select *
			from dbo.gv_bpm_data_field_instance (nolock)
			where process_id = 'zspnft_parent_rlhr' --zspnft_parent_rlhr
			and def_name in ('related_fo_manage_id_doc_date3')
			and is_set = 1
			and try_cast(val_str as datetime) <= @today
			and process_instance_is_finished = @process_instance_is_finished
			and process_instance_id = dfi.process_instance_id
			)
and def_name in ('related_fo_manage_nova_id3', 'related_fo_manage_desc3', 'related_fo_manage_oib3', 'related_fo_manage_address3', 'related_fo_manage_place3' --nema emso, work_place
	, 'related_fo_manage_ident_doc3' --3. Naziv i broj identifikacijske isprave - jedno polje za tip i broj
	, 'related_fo_manage_id_doc_issuer3' --3. Izdavatelj identifikacijske isprave
	, 'related_fo_manage_id_doc_date3' -- nema Datum izdavanja osob. dok.
	, 'customer_id', 'customer_desc')
--select * from #related_fo_manage_3

select process_instance_id, process_date_created, related_fo_manage_nova_id3, related_fo_manage_desc3, related_fo_manage_oib3, related_fo_manage_address3, related_fo_manage_place3, '' as assignee_work_place, '' as assignee_personal_doc_type, related_fo_manage_ident_doc3, related_fo_manage_id_doc_issuer3,	related_fo_manage_id_doc_date3, '2.2 Vlasnička struktura - fizičke osobe - 3' as uloga, customer_id, customer_desc  
into #related_fo_manage_3Pivot from #related_fo_manage_3
pivot (max(val_str) for def_name in ([related_fo_manage_nova_id3], [related_fo_manage_desc3], [related_fo_manage_oib3], [related_fo_manage_address3], [related_fo_manage_place3]
	, [related_fo_manage_ident_doc3], [related_fo_manage_id_doc_issuer3], [related_fo_manage_id_doc_date3]
	, [customer_id], [customer_desc]
	)) as PivotTable
--select * from #related_fo_manage_3Pivot

--2.2 Vlasnička struktura - fizičke osobe - 4
select process_instance_id, process_date_created, def_name, val_str--, def_title 
into #related_fo_manage_4
from dbo.gv_bpm_data_field_instance dfi (nolock)
where exists (select *
			from dbo.gv_bpm_data_field_instance (nolock)
			where process_id = 'zspnft_parent_rlhr' --zspnft_parent_rlhr
			and def_name in ('related_fo_manage_id_doc_date4')
			and is_set = 1
			and try_cast(val_str as datetime) <= @today
			and process_instance_is_finished = @process_instance_is_finished
			and process_instance_id = dfi.process_instance_id
			)
and def_name in ('related_fo_manage_nova_id4', 'related_fo_manage_desc4', 'related_fo_manage_oib4', 'related_fo_manage_address4', 'related_fo_manage_place4' --nema emso, work_place
	, 'related_fo_manage_ident_doc4' --4. Naziv i broj identifikacijske isprave - jedno polje za tip i broj
	, 'related_fo_manage_id_doc_issuer4' --4. Izdavatelj identifikacijske isprave
	, 'related_fo_manage_id_doc_date4' -- nema Datum izdavanja osob. dok.
	, 'customer_id', 'customer_desc')
--select * from #related_fo_manage_4

select process_instance_id, process_date_created, related_fo_manage_nova_id4, related_fo_manage_desc4, related_fo_manage_oib4, related_fo_manage_address4, related_fo_manage_place4, '' as assignee_work_place, '' as assignee_personal_doc_type, related_fo_manage_ident_doc4, related_fo_manage_id_doc_issuer4,	related_fo_manage_id_doc_date4, '2.2 Vlasnička struktura - fizičke osobe - 4' as uloga, customer_id, customer_desc 
into #related_fo_manage_4Pivot from #related_fo_manage_4
pivot (max(val_str) for def_name in ([related_fo_manage_nova_id4], [related_fo_manage_desc4], [related_fo_manage_oib4], [related_fo_manage_address4], [related_fo_manage_place4]
	, [related_fo_manage_ident_doc4], [related_fo_manage_id_doc_issuer4], [related_fo_manage_id_doc_date4]
	, [customer_id], [customer_desc]
	)) as PivotTable
--select * from #related_fo_manage_4Pivot


select * into #finalPivot from #assigneePivot
union all
select * from #assigneePivot2
union all
select * from #related_fo_manage_1Pivot
union all
select * from #related_fo_manage_2Pivot
union all
select * from #related_fo_manage_3Pivot
union all
select * from #related_fo_manage_4Pivot
select * from #finalPivot

--FINAL BPM
select par.id_kupca, par.naz_kr_kup, par.neaktiven as status, pog.broj_ad_ugovora
	, par.tip_os_izk, gr_os_izk.value as Vrsta_osob_dok, st_os_izk as Broj_osob_dok, par.d_os_izk as Datum_izdavanja_osob_dok
	, par.izd_os_izk as Izdavatelj_osob_dok, par.d_velj_os_izk as Datum_valjanosti, par.emso as jmbg
	, ap.process_instance_id, ap.process_date_created, nova_prod.dbo.gfn_StringToFOX(assignee_nova_id1) as assignee_nova_id1
	, nova_prod.dbo.gfn_StringToFOX(assignee_desc) as assignee_desc, nova_prod.dbo.gfn_StringToFOX(assignee_oib) as assignee_oib
	, nova_prod.dbo.gfn_StringToFOX(assignee_address) as assignee_address, nova_prod.dbo.gfn_StringToFOX(assignee_place) as assignee_place
	, nova_prod.dbo.gfn_StringToFOX(assignee_work_place) as assignee_work_place, nova_prod.dbo.gfn_StringToFOX(assignee_personal_doc_type) as assignee_personal_doc_type
	, nova_prod.dbo.gfn_StringToFOX(assignee_personal_doc_id) as assignee_personal_doc_id, nova_prod.dbo.gfn_StringToFOX(assignee_personal_doc_department) as assignee_personal_doc_department
	, try_cast(assignee_personal_doc_date as datetime) as assignee_personal_doc_date, uloga 
	, nova_prod.dbo.gfn_StringToFOX(customer_id) as customer_id, nova_prod.dbo.gfn_StringToFOX(customer_desc) as customer_desc
into #finalBPM
from #finalPivot ap
left join nova_prod.dbo.partner par on (par.id_kupca = ap.assignee_nova_id1 or par.dav_stev = ap.assignee_oib)
outer apply (select nova_prod.dbo.gfn_StringToFOX(value) as value from nova_prod.dbo.general_register where id_register = 'OS_IZK' and id_key = par.tip_os_izk) gr_os_izk
outer apply (select count(*) as broj_ad_ugovora from nova_prod.dbo.pogodba where status_akt in ('D', 'A') and id_kupca = par.id_kupca) pog
order by par.id_kupca 
--select * from #finalBPM

--FINAL NOVA AND BPM
select * from #finalBPM

order by id_kupca, assignee_desc


 drop table #assignee
 drop table #assigneePivot
 drop table #assignee2
 drop table #assigneePivot2
 drop table #related_fo_manage_1
 drop table #related_fo_manage_1Pivot
 drop table #related_fo_manage_2
 drop table #related_fo_manage_2Pivot
 drop table #related_fo_manage_3
 drop table #related_fo_manage_3Pivot
 drop table #related_fo_manage_4
 drop table #related_fo_manage_4Pivot
 drop table #finalPivot
 drop table #finalBPM