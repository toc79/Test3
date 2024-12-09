DECLARE @dat_izd_enabled int
DECLARE @datum_izd_od datetime
DECLARE @datum_izd_do datetime
DECLARE @pio_enabled int

set @dat_izd_enabled =   {0}
set @datum_izd_od =  {1} -- '20160101'
set @datum_izd_do =  dateadd(day,1,{2}) -- '20171218'
set @pio_enabled = {3}


create table #ods_data_field1 (
		id_ods_data_document int,
		val_str varchar(100),
		val_int int
	)
	
	create index IX_val_str_val_int on #ods_data_field1(val_str,val_int)
	
	create table #ods_data_field2 (
		id_ods_data_document int,
		val_text xml
	)
	
	create index IX_id_ods_data_document on #ods_data_field2(id_ods_data_document)
	


	insert into #ods_data_field1
	Select a.id_ods_data_document, max(isnull(val_str,0)) as val_str, cast(max(isnull(val_int,0)) as int) val_int
		From dbo.ODS_DATA_FIELD a
		inner join dbo.ODS_DEF_FIELD b on a.id_ods_def_field = b.id_ods_def_field --and b.field_sys_id in ('id_kupca', 'instance_id')
		inner join dbo.ODS_DATA_DOCUMENT c on a.id_ods_data_document = c.id_ods_data_document --and c.is_deleted = 0
		inner join dbo.ODS_DEF_DOCUMENT d on c.id_ods_def_document = d.id_ods_def_document --and d.document_sys_id = 'ZSPNFT_INSTANCE_DATA'
		where b.field_sys_id in ('id_kupca', 'instance_id') and c.is_deleted = 0 and d.document_sys_id = 'ZSPNFT_INSTANCE_DATA'
	group by a.id_ods_data_document


	insert into #ods_data_field2
	Select a.id_ods_data_document, cast(a.val_text as xml) as val_text
		From dbo.ODS_DATA_FIELD a
		inner join dbo.ODS_DEF_FIELD b on a.id_ods_def_field = b.id_ods_def_field and b.field_sys_id = 'instance_xml_data'
		inner join dbo.ODS_DATA_DOCUMENT c on a.id_ods_data_document = c.id_ods_data_document and c.is_deleted = 0
		inner join dbo.ODS_DEF_DOCUMENT d on c.id_ods_def_document = d.id_ods_def_document and d.document_sys_id = 'ZSPNFT_INSTANCE_DATA'

		
	Select a.*,b.*, c.val_text
	into #current_state
	From dbo.gv_PEval_LastEvaluation_ByType a
	inner join #ods_data_field1 b on a.id_kupca = b.val_str and cast(a.ext_id as int) = b.val_int
	inner join #ods_data_field2 c on b.id_ods_data_document = c.id_ods_data_document
	where a.eval_type = 'Z' and a.ext_id_type = 'BPM'
  			and  a.ext_id in 
  				(select id from bpm_test.dbo.bpm_process_instance where date_finished between @datum_izd_od and @datum_izd_do)
  	 		and a.ext_id in 
  	 			(select distinct process_instance_id  from bpm_test.dbo.gv_bpm_data_field_instance where process_instance_date_finished between @datum_izd_od and @datum_izd_do
  	 						AND
							((@pio_enabled = 0 and 1=1) or 
  	 						( @pio_enabled = 1 
			 					and def_id in (select id from bpm_test.dbo.bpm_def_data_field where name like '%is_pio%') 
			 					and (upper(val_str) like '%DA%' or upper(val_str) like '%TRUE%'))))

	Select a.*,
		isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc1"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc1
		, 
		isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc2"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc2
		,
		isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc3"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc3
		, 
		isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc4"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc4
		, 
		isnull(t.c.value('(DATA_FIELD[@def_name="assignee_desc"]/@val_str)[1]', 'varchar(1000)'), '') as assignee_desc
	into #new_ones
	From #current_state a
	cross apply val_text.nodes('/INSTANCE/DATA_FIELDS') as t(c)


	Select *
	into #rez_tmp	
	From(
			Select *
			From (
				Select 

				t.c.value('(DATA_FIELD[@def_name="changed_mark"]/@val_str)[1]', 'varchar(1000)') as changed_mark, -- ocjena rizika (ručna)

				t.c.value('(DATA_FIELD[@def_name="eval_date"]/@val_str)[1]', 'varchar(1000)') as eval_date, -- datum uskostavljanja poslovnog odnosa

				-- osnovni podaci o partneru

				t.c.value('(DATA_FIELD[@def_name="customer_intention"]/@val_str)[1]', 'varchar(1000)') as customer_intention,
				t.c.value('(DATA_FIELD[@def_name="customer_desc"]/@val_str)[1]', 'varchar(1000)') as customer_desc,
				t.c.value('(DATA_FIELD[@def_name="customer_oib"]/@val_str)[1]', 'varchar(1000)') as customer_oib,
				t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id,
				t.c.value('(DATA_FIELD[@def_name="customer_is_pio"]/@val_str)[1]', 'varchar(1000)') as customer_is_pio,
				t.c.value('(DATA_FIELD[@def_name="process_instance_id"]/@val_str)[1]', 'varchar(1000)') as process_instance_id,
				t.c.value('(DATA_FIELD[@def_name="customer_type"]/@val_str)[1]', 'varchar(1000)') as customer_type,
				 t.c.value('(DATA_FIELD[@def_name="customer_address"]/@val_str)[1]', 'varchar(1000)') as customer_address,
				 t.c.value('(DATA_FIELD[@def_name="customer_place"]/@val_str)[1]', 'varchar(1000)') as customer_place,
				 t.c.value('(DATA_FIELD[@def_name="customer_country"]/@val_str)[1]', 'varchar(1000)') as customer_country,
				 t.c.value('(DATA_FIELD[@def_name="customer_date_of_establishment"]/@val_str)[1]', 'varchar(1000)') as customer_date_of_establishment,
				 
				
				-- podaci o vlasnicima fizičke osobe (4x fizičke osobe)

				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc4,
				
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc1_child_process_id"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc1_child_process_id,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc2_child_process_id"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc2_child_process_id,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc3_child_process_id"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc3_child_process_id,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc4_child_process_id"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc4_child_process_id,

				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc1_is_pio"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc1_is_pio,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc2_is_pio"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc2_is_pio,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc3_is_pio"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc3_is_pio,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc4_is_pio"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_desc4_is_pio,

			    t.c.value('(DATA_FIELD[@def_name="related_fo_manage_nova_id1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_nova_id1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_nova_id2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_nova_id2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_nova_id3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_nova_id3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_nova_id4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_nova_id4,

				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_dav_stev1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_dav_stev1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_dav_stev2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_dav_stev2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_dav_stev3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_dav_stev3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_dav_stev4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_dav_stev4,

				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_address1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_address1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_address2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_address2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_address3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_address3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_address4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_address4,

				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_place1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_place1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_place2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_place2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_place3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_place3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_place4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_place4,

				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_country1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_country1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_country2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_country2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_country3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_country3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_country4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_country4,

				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_percentage_of_shares1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_percentage_of_shares1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_percentage_of_shares2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_percentage_of_shares2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_percentage_of_shares3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_percentage_of_shares3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_percentage_of_shares4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_percentage_of_shares4,

				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_intention1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_intention1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_intention2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_intention2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_intention3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_intention3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_intention4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_intention4,
				
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birth_date1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_birth_date1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birth_date2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_birth_date2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birth_date3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_birth_date3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birth_date4"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_birth_date4,

				-- podaci o zastupnicima (3x zastupnika)

				t.c.value('(DATA_FIELD[@def_name="management_nova_id1"]/@val_str)[1]', 'varchar(1000)') as management_nova_id1,
				t.c.value('(DATA_FIELD[@def_name="management_nova_id2"]/@val_str)[1]', 'varchar(1000)') as management_nova_id2,
				t.c.value('(DATA_FIELD[@def_name="management_nova_id3"]/@val_str)[1]', 'varchar(1000)') as management_nova_id3,

				t.c.value('(DATA_FIELD[@def_name="management_desc1"]/@val_str)[1]', 'varchar(1000)') as management_desc1,
				t.c.value('(DATA_FIELD[@def_name="management_desc2"]/@val_str)[1]', 'varchar(1000)') as management_desc2,
				t.c.value('(DATA_FIELD[@def_name="management_desc3"]/@val_str)[1]', 'varchar(1000)') as management_desc3,

				t.c.value('(DATA_FIELD[@def_name="management_address1"]/@val_str)[1]', 'varchar(1000)') as management_address1,
				t.c.value('(DATA_FIELD[@def_name="management_address2"]/@val_str)[1]', 'varchar(1000)') as management_address2,
				t.c.value('(DATA_FIELD[@def_name="management_address3"]/@val_str)[1]', 'varchar(1000)') as management_address3,

				t.c.value('(DATA_FIELD[@def_name="management_place1"]/@val_str)[1]', 'varchar(1000)') as management_place1,
				t.c.value('(DATA_FIELD[@def_name="management_place2"]/@val_str)[1]', 'varchar(1000)') as management_place2,
				t.c.value('(DATA_FIELD[@def_name="management_place3"]/@val_str)[1]', 'varchar(1000)') as management_place3,

				t.c.value('(DATA_FIELD[@def_name="management_country1"]/@val_str)[1]', 'varchar(1000)') as management_country1,
				t.c.value('(DATA_FIELD[@def_name="management_country2"]/@val_str)[1]', 'varchar(1000)') as management_country2,
				t.c.value('(DATA_FIELD[@def_name="management_country3"]/@val_str)[1]', 'varchar(1000)') as management_country3,

				t.c.value('(DATA_FIELD[@def_name="management_oib1"]/@val_str)[1]', 'varchar(1000)') as management_oib1,
				t.c.value('(DATA_FIELD[@def_name="management_oib2"]/@val_str)[1]', 'varchar(1000)') as management_oib2,
				t.c.value('(DATA_FIELD[@def_name="management_oib3"]/@val_str)[1]', 'varchar(1000)') as management_oib3,

				t.c.value('(DATA_FIELD[@def_name="management_desc1_doubtful"]/@val_str)[1]', 'varchar(1000)') as management_desc1_doubtful,
				t.c.value('(DATA_FIELD[@def_name="management_desc2_doubtful"]/@val_str)[1]', 'varchar(1000)') as management_desc2_doubtful,
				t.c.value('(DATA_FIELD[@def_name="management_desc3_doubtful"]/@val_str)[1]', 'varchar(1000)') as management_desc3_doubtful,
				
				t.c.value('(DATA_FIELD[@def_name="management_is_pio1"]/@val_str)[1]', 'varchar(1000)') as management_is_pio1,
				t.c.value('(DATA_FIELD[@def_name="management_is_pio2"]/@val_str)[1]', 'varchar(1000)') as management_is_pio2,
				t.c.value('(DATA_FIELD[@def_name="management_is_pio3"]/@val_str)[1]', 'varchar(1000)') as management_is_pio3,
				
				t.c.value('(DATA_FIELD[@def_name="management_birth_date1"]/@val_str)[1]', 'varchar(1000)') as management_birth_date1,
				t.c.value('(DATA_FIELD[@def_name="management_birth_date2"]/@val_str)[1]', 'varchar(1000)') as management_birth_date2,
				t.c.value('(DATA_FIELD[@def_name="management_birth_date3"]/@val_str)[1]', 'varchar(1000)') as management_birth_date3,
				
				-- podaci o vlasnicima - pravnim osobama
				
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_desc1"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_desc1,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_desc2"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_desc2,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_desc3"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_desc3,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_desc4"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_desc4,
				
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_nova_id1"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_nova_id1,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_nova_id2"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_nova_id2,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_nova_id3"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_nova_id3,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_nova_id4"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_nova_id4,
				
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_address1"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_address1,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_address2"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_address2,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_address3"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_address3,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_address4"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_address4,
				
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_place1"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_place1,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_place2"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_place2,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_place3"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_place3,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_place4"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_place4,
				
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_country1"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_country1,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_country2"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_country2,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_country3"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_country3,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_country4"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_country4,
				
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_dav_stev1"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_dav_stev1,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_dav_stev2"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_dav_stev2,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_dav_stev3"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_dav_stev3,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_dav_stev4"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_dav_stev4,
				
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_percentage_of_shares1"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_percentage_of_shares1,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_percentage_of_shares2"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_percentage_of_shares2,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_percentage_of_shares3"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_percentage_of_shares3,
				t.c.value('(DATA_FIELD[@def_name="related_po_manage_percentage_of_shares4"]/@val_str)[1]', 'varchar(1000)') as related_po_manage_percentage_of_shares4,

				ext_id -- instance id

				from #new_ones a
				cross apply a.val_text.nodes('/INSTANCE/DATA_FIELDS') t(c)
				-- where a.related_fo_manage_desc1 <> '' 
			) a
	) all_parts


select 

-- partner za kojeg je pokrenut proces
left(a.customer_desc,240) as customer_desc, 
left(a.customer_id,240) as customer_id, 
left(a.ext_id,10) as ext_id,
left(a.customer_type,10) as customer_type,
left(a.customer_address,200) as customer_address,
left(a.customer_place,50) as customer_place,
left(a.customer_country,50) as customer_country,
left(f0.drzavljan,50) as drzavljanstvo,
left(a.customer_oib,240) as customer_oib, 
-- case when a.customer_is_pio is null then 'Ne' else left(a.customer_is_pio,240) end as customer_is_pio, 
case when rtrim(ltrim(isnull(a.customer_is_pio ,'false')))='true' or upper(rtrim(ltrim(a.customer_is_pio)))='DA' then 'DA' else 'NE' end as customer_is_pio,
left(a.changed_mark,10) as changed_mark,
left(a.eval_date,10) as eval_date,
left(a.customer_intention,50) as customer_intention,
left(a.customer_date_of_establishment,10) as customer_date_of_establishment,


--vlasnik, fizička osoba 1
left(f1.vr_osebe,10) as f1_vrsta_osobe,
left(a.related_fo_manage_nova_id1,20) as related_fo_manage_nova_id1,
left(a.related_fo_manage_desc1,240) as related_fo_manage_desc1 ,
left(a.related_fo_manage_address1,240) as related_fo_manage_address1,
left(a.related_fo_manage_place1,240) as related_fo_manage_place1,
left(a.related_fo_manage_country1,240) as related_fo_manage_country1,
left(f1.drzavljan,50) as drzavljanstvo_f1,
left(a.related_fo_manage_dav_stev1,240) as related_fo_manage_dav_stev1,
left(a.related_fo_manage_percentage_of_shares1,240) as related_fo_manage_percentage_of_shares1,
--left(a.related_fo_manage_desc1_is_pio,240) as related_fo_manage_desc1_is_pio,
case when rtrim(ltrim(isnull(a.related_fo_manage_desc1_is_pio,'false')))='true' or upper(rtrim(ltrim(a.related_fo_manage_desc1_is_pio)))='DA' then 'DA' else 'NE' end as related_fo_manage_desc1_is_pio,
left(a.related_fo_manage_intention1,240) as related_fo_manage_intention1,
-- left(a.related_fo_manage_desc1_child_process_id,100) as related_fo_manage_desc1_child_process_id,
left(a.related_fo_manage_birth_date1,10) as related_fo_manage_birth_date1,

--vlasnik, fizička osoba 2
left(f2.vr_osebe,10) as f2_vrsta_osobe,
left(a.related_fo_manage_nova_id2,240) as related_fo_manage_nova_id2,
left(a.related_fo_manage_desc2,240) as related_fo_manage_desc2,
left(a.related_fo_manage_address2,240) as related_fo_manage_address2,
left(a.related_fo_manage_place2,240) as related_fo_manage_place2,
left(a.related_fo_manage_country2,240) as related_fo_manage_country2,
left(f2.drzavljan,50) as drzavljanstvo_f2,
left(a.related_fo_manage_dav_stev2,240) as related_fo_manage_dav_stev2,
left(a.related_fo_manage_percentage_of_shares2,240) as related_fo_manage_percentage_of_shares2,
-- left(a.related_fo_manage_desc2_is_pio,240) as related_fo_manage_desc2_is_pio,
case when rtrim(ltrim(isnull(a.related_fo_manage_desc2_is_pio,'false')))='true' or upper(rtrim(ltrim(a.related_fo_manage_desc2_is_pio)))='DA' then 'DA' else 'NE' end as related_fo_manage_desc2_is_pio,
left(a.related_fo_manage_intention2,240) as related_fo_manage_intention2,
-- left(a.related_fo_manage_desc2_child_process_id,100) as related_fo_manage_desc2_child_process_id,
left(a.related_fo_manage_birth_date2,10) as related_fo_manage_birth_date2,

--vlasnik, fizička osoba 3
left(f3.vr_osebe,10) as f3_vrsta_osobe,
left(a.related_fo_manage_nova_id3,240) as related_fo_manage_nova_id3,
left(a.related_fo_manage_desc3,240) as related_fo_manage_desc3,
left(a.related_fo_manage_address3,240) as related_fo_manage_address3,
left(a.related_fo_manage_place3,240) as related_fo_manage_place3,
left(a.related_fo_manage_country3,240) as related_fo_manage_country3,
left(f3.drzavljan,50) as drzavljanstvo_f3,
left(a.related_fo_manage_dav_stev3,240) as related_fo_manage_dav_stev3,
left(a.related_fo_manage_percentage_of_shares3,240) as related_fo_manage_percentage_of_shares3,
-- left(a.related_fo_manage_desc3_is_pio,240) as related_fo_manage_desc3_is_pio,
case when rtrim(ltrim(isnull(a.related_fo_manage_desc3_is_pio,'false')))='true' or upper(rtrim(ltrim(a.related_fo_manage_desc3_is_pio)))='DA' then 'DA' else 'NE' end as related_fo_manage_desc3_is_pio,
left(a.related_fo_manage_intention3,240) as related_fo_manage_intention3,
-- left(a.related_fo_manage_desc3_child_process_id,100) as related_fo_manage_desc3_child_process_id,
left(a.related_fo_manage_birth_date3,10) as related_fo_manage_birth_date3,

--vlasnik, fizička osoba 4
left(f4.vr_osebe,10) as f4_vrsta_osobe,
left(a.related_fo_manage_nova_id4,240) as related_fo_manage_nova_id4,
left(a.related_fo_manage_desc4,240) as related_fo_manage_desc4,
left(a.related_fo_manage_address4,240) as related_fo_manage_address4,
left(a.related_fo_manage_place4,240) as related_fo_manage_place4,
left(a.related_fo_manage_country4,240) as related_fo_manage_country4,
left(f4.drzavljan,50) as drzavljanstvo_f4,
left(a.related_fo_manage_dav_stev4,240) as related_fo_manage_dav_stev4,
left(a.related_fo_manage_percentage_of_shares4,240) as related_fo_manage_percentage_of_shares4,
-- left(a.related_fo_manage_desc4_is_pio,240) as related_fo_manage_desc4_is_pio,
case when rtrim(ltrim(isnull(a.related_fo_manage_desc4_is_pio,'false')))='true' or upper(rtrim(ltrim(a.related_fo_manage_desc4_is_pio)))='DA' then 'DA' else 'NE' end as related_fo_manage_desc4_is_pio,
left(a.related_fo_manage_intention4,240) as related_fo_manage_intention4,
-- left(a.related_fo_manage_desc4_child_process_id,100) as related_fo_manage_desc4_child_process_id,
left(a.related_fo_manage_birth_date4,10) as related_fo_manage_birth_date4,

--zsatupnik 1
left(z1.vr_osebe,10) as z1_vrsta_osobe,
left(a.management_nova_id1,240) as management_nova_id1,
left(a.management_desc1,240) as management_desc1,
left(a.management_address1,240) as management_address1,
left(a.management_place1,240) as management_place1,
left(a.management_country1,240) as management_country1,
left(z1.drzavljan,50) as drzavljanstvo_z1,
left(a.management_oib1,240) as management_oib1,
left(a.management_desc1_doubtful,240) as management_desc1_doubtful,
-- case when rtrim(ltrim(isnull(a.management_is_pio1,'false')))='true' then 'DA' else 'NE' end as management_is_pio1,
case when rtrim(ltrim(isnull(a.management_is_pio1,'false')))='true' or upper(rtrim(ltrim(a.management_is_pio1)))='DA' then 'DA' else 'NE' end as management_is_pio1,
left(a.management_birth_date1,10) as management_birth_date1,

--zsatupnik 2
left(z2.vr_osebe,10) as z2_vrsta_osobe,
left(a.management_nova_id2,240) as management_nova_id2,
left(a.management_desc2,240) as management_desc2,
left(a.management_address2,240) as management_address2,
left(a.management_place2,240) as management_place2,
left(a.management_country2,240) as management_country2,
left(z2.drzavljan,50) as drzavljanstvo_z2,
left(a.management_oib2,240) as management_oib2,
left(a.management_desc2_doubtful,240) as management_desc2_doubtfu2,
-- case when rtrim(ltrim(isnull(a.management_is_pio2,'false')))='true' then 'DA' else 'NE' end as management_is_pio2,
case when rtrim(ltrim(isnull(a.management_is_pio2,'false')))='true' or upper(rtrim(ltrim(a.management_is_pio2)))='DA' then 'DA' else 'NE' end as management_is_pio2,
left(a.management_birth_date2,10) as management_birth_date2,

--zsatupnik 3
left(z3.vr_osebe,10) as z3_vrsta_osobe,
left(a.management_nova_id3,240) as management_nova_id3,
left(a.management_desc3,240) as management_desc3,
left(a.management_address3,240) as management_address3,
left(a.management_place3,240) as management_place3,
left(a.management_country3,240) as management_country3,
left(z3.drzavljan,50) as drzavljanstvo_z3,
left(a.management_oib3,240) as management_oib3,
left(a.management_desc3_doubtful,240) as management_desc3_doubtful,
-- case when rtrim(ltrim(isnull(a.management_is_pio3,'false')))='true' then 'DA' else 'NE' end as management_is_pio3,
case when rtrim(ltrim(isnull(a.management_is_pio3,'false')))='true' or upper(rtrim(ltrim(a.management_is_pio3)))='DA' then 'DA' else 'NE' end as management_is_pio3,
left(a.management_birth_date3,10) as management_birth_date3,

--vlasnik, pravna osoba 1
left(a.related_po_manage_desc1,100) as related_po_manage_desc1,
left(a.related_po_manage_nova_id1,10) as related_po_manage_nova_id1,
left(a.related_po_manage_address1,240) as related_po_manage_address1,
left(a.related_po_manage_place1,240) as related_po_manage_place1,
left(a.related_po_manage_country1,240) as related_po_manage_country1,
left(a.related_po_manage_dav_stev1,15) as related_po_manage_dav_stev1,
left(a.related_po_manage_percentage_of_shares1,50) as related_po_manage_percentage_of_shares1,

--vlasnik, pravna osoba 2
left(a.related_po_manage_desc2,100) as related_po_manage_desc2,
left(a.related_po_manage_nova_id2,10) as related_po_manage_nova_id2,
left(a.related_po_manage_address2,240) as related_po_manage_address2,
left(a.related_po_manage_place2,240) as related_po_manage_place2,
left(a.related_po_manage_country2,240) as related_po_manage_country2,
left(a.related_po_manage_dav_stev2,15) as related_po_manage_dav_stev2,
left(a.related_po_manage_percentage_of_shares2,50) as related_po_manage_percentage_of_shares2,

--vlasnik, pravna osoba 3
left(a.related_po_manage_desc3,100) as related_po_manage_desc3,
left(a.related_po_manage_nova_id3,10) as related_po_manage_nova_id3,
left(a.related_po_manage_address3,240) as related_po_manage_address3,
left(a.related_po_manage_place3,240) as related_po_manage_place3,
left(a.related_po_manage_country3,240) as related_po_manage_country3,
left(a.related_po_manage_dav_stev3,15) as related_po_manage_dav_stev3,
left(a.related_po_manage_percentage_of_shares3,50) as related_po_manage_percentage_of_shares3,

--vlasnik, pravna osoba 4
left(a.related_po_manage_desc4,100) as related_po_manage_desc4,
left(a.related_po_manage_nova_id4,10) as related_po_manage_nova_id4,
left(a.related_po_manage_address4,240) as related_po_manage_address4,
left(a.related_po_manage_place4,240) as related_po_manage_place4,
left(a.related_po_manage_country4,240) as related_po_manage_country4,
left(a.related_po_manage_dav_stev4,15) as related_po_manage_dav_stev4,
left(a.related_po_manage_percentage_of_shares4,50) as related_po_manage_percentage_of_shares4

INTO #temp32039
from #rez_tmp a
left join partner f0 on a.customer_id=f0.id_kupca
left join partner f1 on a.related_fo_manage_nova_id1=f1.id_kupca
left join partner f2 on a.related_fo_manage_nova_id2=f2.id_kupca
left join partner f3 on a.related_fo_manage_nova_id3=f3.id_kupca
left join partner f4 on a.related_fo_manage_nova_id4=f4.id_kupca

left join partner z1 on a.management_nova_id1=z1.id_kupca
left join partner z2 on a.management_nova_id2=z2.id_kupca
left join partner z3 on a.management_nova_id3=z3.id_kupca

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
			t.customer_id as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Primatelj leasinga' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.customer_id
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.customer_id, p.vr_osebe 
		UNION
		SELECT
			t.related_fo_manage_nova_id1 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Vlasnik, fizička osoba 1' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.related_fo_manage_nova_id1
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.related_fo_manage_nova_id1, p.vr_osebe 
		UNION
		SELECT
			t.related_fo_manage_nova_id2 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Vlasnik, fizička osoba 2' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.related_fo_manage_nova_id2
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.related_fo_manage_nova_id2, p.vr_osebe 
		UNION
		SELECT
			t.related_fo_manage_nova_id3 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Vlasnik, fizička osoba 3' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.related_fo_manage_nova_id3
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.related_fo_manage_nova_id3, p.vr_osebe 
		UNION
		SELECT
			t.related_fo_manage_nova_id4 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Vlasnik, fizička osoba 4' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.related_fo_manage_nova_id4
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.related_fo_manage_nova_id4, p.vr_osebe 
		UNION
		SELECT
			t.management_nova_id1 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Zastupnik 1' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.management_nova_id1
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.management_nova_id1, p.vr_osebe 
		UNION
		SELECT
			t.management_nova_id2 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Zastupnik 2' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.management_nova_id2
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.management_nova_id2, p.vr_osebe
		UNION
		SELECT
			t.management_nova_id3 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Zastupnik 3' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.management_nova_id3
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.management_nova_id3, p.vr_osebe 
		
		UNION
		SELECT
			t.related_po_manage_nova_id1 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Pravna osoba - Vlasnik1' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.related_po_manage_nova_id1
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.related_po_manage_nova_id1, p.vr_osebe 
		UNION
		SELECT
			t.related_po_manage_nova_id2 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Pravna osoba - Vlasnik2' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.related_po_manage_nova_id2
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.related_po_manage_nova_id2, p.vr_osebe 
		UNION
		SELECT
			t.related_po_manage_nova_id3 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Pravna osoba - Vlasnik3' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.related_po_manage_nova_id3
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.related_po_manage_nova_id3, p.vr_osebe 
		UNION
		SELECT
			t.related_po_manage_nova_id4 as '@ID_KUPCA', 
			p.vr_osebe as '@vrsta_osebe',
			'Pravna osoba - Vlasnik4' as  '@Additional_desc'
		FROM #temp32039 t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.related_po_manage_nova_id4
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.related_po_manage_nova_id4, p.vr_osebe 
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();
exec dbo.gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Kraći naziv, Adresa(sjedišta), Država rođ., Državljanstvo, OIB, Datum rođenja','INTERNAL','CUSTOM_REPORT', 'Provjera PIO kod fizičkih osoba u BPM ZSPNFT - Pregled podataka','32039',@xml
drop table #tempVrste
-- KONEC GDPR

select* from #temp32039
drop table #temp32039


	drop table #current_state
	drop table #new_ones
	drop table #ods_data_field1
	drop table #ods_data_field2
	drop table #rez_tmp