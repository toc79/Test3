--MR 37157

DECLARE @dat_izd_enabled int
DECLARE @datum_izd_od datetime
DECLARE @datum_izd_do datetime

set @dat_izd_enabled = {0}
set @datum_izd_od = {1}
set @datum_izd_do = {2}



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

		
	Select a.*,b.*, c.val_text, p.vr_osebe
	into #current_state
	From dbo.gv_PEval_LastEvaluation_ByType a
	inner join #ods_data_field1 b on a.id_kupca = b.val_str and cast(a.ext_id as int) = b.val_int
	inner join #ods_data_field2 c on b.id_ods_data_document = c.id_ods_data_document
	left join dbo.partner p on a.id_kupca = p.id_kupca
	where a.eval_type = 'Z'
	and a.ext_id_type = 'BPM'
	and  a.ext_id in (select id from bpm.dbo.bpm_process_instance where date_finished between @datum_izd_od and @datum_izd_do)
	


	Select a.*,
		isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc1"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc1
		, 
		isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc2"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc2
		,
		isnull(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_desc3"]/@val_str)[1]', 'varchar(1000)'), '') as related_fo_manage_desc3
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
				Select a.id_kupca, a.dat_eval, a.val_int, a.id_p_eval, a.id_ods_data_document,
				a.related_fo_manage_desc1 as related_fo_manage_desc1,
				t.c.value('(DATA_FIELD[@def_name="customer_desc"]/@val_str)[1]', 'varchar(1000)') as customer_desc,
				t.c.value('(DATA_FIELD[@def_name="customer_id"]/@val_str)[1]', 'varchar(1000)') as customer_id,
				t.c.value('(DATA_FIELD[@def_name="customer_address"]/@val_str)[1]', 'varchar(1000)') as customer_address,
				t.c.value('(DATA_FIELD[@def_name="customer_place"]/@val_str)[1]', 'varchar(1000)') as customer_place,
				t.c.value('(DATA_FIELD[@def_name="customer_country"]/@val_str)[1]', 'varchar(1000)') as customer_country,
				t.c.value('(DATA_FIELD[@def_name="customer_business_address"]/@val_str)[1]', 'varchar(1000)') as customer_business_address,
				t.c.value('(DATA_FIELD[@def_name="customer_business_place"]/@val_str)[1]', 'varchar(1000)') as customer_business_place,
				t.c.value('(DATA_FIELD[@def_name="customer_business_country"]/@val_str)[1]', 'varchar(1000)') as customer_business_country,
				cast(case when isdate(t.c.value('(DATA_FIELD[@def_name="customer_date_of_establishment"]/@val_str)[1]', 'varchar(1000)'))= 1 then t.c.value('(DATA_FIELD[@def_name="customer_date_of_establishment"]/@val_str)[1]', 'varchar(1000)') else null end as datetime) as customer_date_of_establishment,
				t.c.value('(DATA_FIELD[@def_name="customer_emso"]/@val_str)[1]', 'varchar(1000)') as customer_emso,
				t.c.value('(DATA_FIELD[@def_name="customer_oib"]/@val_str)[1]', 'varchar(1000)') as customer_oib,
				t.c.value('(DATA_FIELD[@def_name="customer_stev_reg"]/@val_str)[1]', 'varchar(1000)') as customer_stev_reg,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_emso1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_emso1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_address1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_address1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_place1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_place1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_country1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_country1,
				cast(case when isdate(t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birth_date1"]/@val_str)[1]', 'varchar(1000)'))= 1 then t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birth_date1"]/@val_str)[1]', 'varchar(1000)') else null end as datetime) as related_fo_manage_birth_date1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birthplace1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_birthplace1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_foundation1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_foundation1,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_percentage_of_shares1"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_percentage_of_shares1, 
				a.related_fo_manage_desc2 as related_fo_manage_desc2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_emso2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_emso2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_address2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_address2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_place2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_place2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_country2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_country2,
				cast(case when isdate(t.c.value('(DATA_FIELD[@def_name="related_fo1_manage_birth_date2"]/@val_str)[1]', 'varchar(1000)'))= 1 then t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birth_date2"]/@val_str)[1]', 'varchar(1000)') else null end as datetime) as related_fo_manage_birth_date2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birthplace2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_birthplace2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_foundation2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_foundation2,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_percentage_of_shares2"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_percentage_of_shares2, 
				a.related_fo_manage_desc3 as related_fo_manage_desc3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_emso3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_emso3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_address3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_address3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_place3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_place3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_country3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_country3,
				cast(case when isdate(t.c.value('(DATA_FIELD[@def_name="related_fo1_manage_birth_date3"]/@val_str)[1]', 'varchar(1000)'))= 1 then t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birth_date3"]/@val_str)[1]', 'varchar(1000)') else null end as datetime) as related_fo_manage_birth_date3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_birthplace3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_birthplace3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_foundation3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_foundation3,
				t.c.value('(DATA_FIELD[@def_name="related_fo_manage_percentage_of_shares3"]/@val_str)[1]', 'varchar(1000)') as related_fo_manage_percentage_of_shares3,
				a.assignee_desc,
				cast(case when isdate(t.c.value('(DATA_FIELD[@def_name="assignee_birth_date"]/@val_str)[1]', 'varchar(1000)'))= 1 then t.c.value('(DATA_FIELD[@def_name="assignee_birth_date"]/@val_str)[1]', 'varchar(1000)') else null end as datetime) as assignee_birth_date,
				t.c.value('(DATA_FIELD[@def_name="assignee_birthplace"]/@val_str)[1]', 'varchar(1000)') as assignee_birthplace,
				t.c.value('(DATA_FIELD[@def_name="assignee_address"]/@val_str)[1]', 'varchar(1000)') as assignee_address,
				t.c.value('(DATA_FIELD[@def_name="assignee_place"]/@val_str)[1]', 'varchar(1000)') as assignee_place,
				t.c.value('(DATA_FIELD[@def_name="assignee_country"]/@val_str)[1]', 'varchar(1000)') as assignee_country,
				t.c.value('(DATA_FIELD[@def_name="assignee_oib"]/@val_str)[1]', 'varchar(1000)') as assignee_oib,
				t.c.value('(DATA_FIELD[@def_name="assigne_employment"]/@val_str)[1]', 'varchar(1000)') as assigne_employment,
				t.c.value('(DATA_FIELD[@def_name="assignee_work_place"]/@val_str)[1]', 'varchar(1000)') as assignee_work_place
				from #new_ones a
				cross apply a.val_text.nodes('/INSTANCE/DATA_FIELDS') t(c)
				where a.vr_osebe in ('FO','F1','ZA') or a.related_fo_manage_desc1 <> ''
			) a
	) all_parts

select
left(p.naz_kr_kup,240) as customer_name,
left(customer_emso,15) as customer_id,
left(customer_address,240)as customer_address,
left(customer_place,240) as customer_city,
left(customer_country,240) as customer_country,
d5.INT_OZNAKA as customer_country_code,
customer_date_of_establishment as customer_dob,
left(p.kraj_roj,240) as customer_pob,
left(p.naz_kr_kup,240) as organization,
left(customer_address,240) as customer_street
	into #rez
 from #rez_tmp a
left join dbo.partner p on a.customer_id=p.id_kupca
left join dbo.VRST_OSE v on p.vr_osebe=v.vr_osebe
left join dbo.drzave d1 on a.related_fo_manage_country1=d1.DRZAVA
left join dbo.drzave d2 on a.related_fo_manage_country2=d2.DRZAVA
left join dbo.drzave d3 on a.related_fo_manage_country3=d3.DRZAVA
left join dbo.drzave d4 on a.assignee_country=d4.DRZAVA
left join dbo.drzave d5 on a.customer_country=d5.DRZAVA
left join dbo.drzave d6 on a.customer_business_country=d6.DRZAVA
where p.vr_osebe in ('FO','F1','ZA') 
and a.id_kupca in (select distinct id_kupca from pogodba where status_akt='A')
union
select
left(related_fo_manage_desc1,240) as customer_name,
left(related_fo_manage_emso1,15) as customer_id,
left(related_fo_manage_address1,240)as customer_address,
left(related_fo_manage_place1,240) as customer_city,
left(related_fo_manage_country1,240) as customer_country,
d1.INT_OZNAKA as customer_country_code,
convert(varchar(10), related_fo_manage_birth_date1, 104) as customer_dob,
left(related_fo_manage_birthplace1,240) as customer_pob,
left(p.naz_kr_kup,240) as organization,
left(customer_address,240) as customer_street
 from #rez_tmp a
left join dbo.partner p on a.customer_id=p.id_kupca
left join dbo.VRST_OSE v on p.vr_osebe=v.vr_osebe
left join dbo.drzave d1 on a.related_fo_manage_country1=d1.DRZAVA
left join dbo.drzave d2 on a.related_fo_manage_country2=d2.DRZAVA
left join dbo.drzave d3 on a.related_fo_manage_country3=d3.DRZAVA
left join dbo.drzave d4 on a.assignee_country=d4.DRZAVA
left join dbo.drzave d5 on a.customer_country=d5.DRZAVA
left join dbo.drzave d6 on a.customer_business_country=d6.DRZAVA
where a.related_fo_manage_desc1 is not null and rtrim(a.related_fo_manage_desc1) <> ''
and a.id_kupca in (select distinct id_kupca from pogodba where status_akt='A')
union
select
left(related_fo_manage_desc2,240) as customer_name,
left(related_fo_manage_emso2,15) as customer_id,
left(related_fo_manage_address2,240)as customer_address,
left(related_fo_manage_place2,240) as customer_city,
left(related_fo_manage_country2,240) as customer_country,
d2.INT_OZNAKA as customer_country_code,
convert(varchar(10), related_fo_manage_birth_date2, 104) as customer_dob,
left(related_fo_manage_birthplace2,240) as customer_pob,
left(p.naz_kr_kup,240) as organization,
left(customer_address,240) as customer_street
 from #rez_tmp a
left join dbo.partner p on a.customer_id=p.id_kupca
left join dbo.VRST_OSE v on p.vr_osebe=v.vr_osebe
left join dbo.drzave d1 on a.related_fo_manage_country1=d1.DRZAVA
left join dbo.drzave d2 on a.related_fo_manage_country2=d2.DRZAVA
left join dbo.drzave d3 on a.related_fo_manage_country3=d3.DRZAVA
left join dbo.drzave d4 on a.assignee_country=d4.DRZAVA
left join dbo.drzave d5 on a.customer_country=d5.DRZAVA
left join dbo.drzave d6 on a.customer_business_country=d6.DRZAVA
where a.related_fo_manage_desc2 is not null and rtrim(a.related_fo_manage_desc2) <> ''
and a.id_kupca in (select distinct id_kupca from pogodba where status_akt='A')
union
select
left(related_fo_manage_desc3,240) as customer_name,
left(related_fo_manage_emso3,15) as customer_id,
left(related_fo_manage_address3,240)as customer_address,
left(related_fo_manage_place3,240) as customer_city,
left(related_fo_manage_country3,240) as customer_country,
d3.INT_OZNAKA as customer_country_code,
convert(varchar(10), related_fo_manage_birth_date3, 104) as customer_dob,
left(related_fo_manage_birthplace3,240) as customer_pob,
left(p.naz_kr_kup,240) as organization,
left(customer_address,240) as customer_street
 from #rez_tmp a
left join dbo.partner p on a.customer_id=p.id_kupca
left join dbo.VRST_OSE v on p.vr_osebe=v.vr_osebe
left join dbo.drzave d1 on a.related_fo_manage_country1=d1.DRZAVA
left join dbo.drzave d2 on a.related_fo_manage_country2=d2.DRZAVA
left join dbo.drzave d3 on a.related_fo_manage_country3=d3.DRZAVA
left join dbo.drzave d4 on a.assignee_country=d4.DRZAVA
left join dbo.drzave d5 on a.customer_country=d5.DRZAVA
left join dbo.drzave d6 on a.customer_business_country=d6.DRZAVA
where a.related_fo_manage_desc3 is not null and rtrim(a.related_fo_manage_desc3) <> ''
and a.id_kupca in (select distinct id_kupca from pogodba where status_akt='A')
union
select
left(assignee_desc,240) as customer_name,
left(assignee_oib,240) as customer_id,
left(assignee_address,240)as customer_address,
left(assignee_place,240) as customer_city,
left(assignee_country,240) as customer_country,
d4.INT_OZNAKA as customer_country_code,
convert(varchar(10), assignee_birth_date, 104) as customer_dob,
left(assignee_birthplace,240) as customer_pob,
left(p.naz_kr_kup,240) as organization,
left(customer_address,240) as customer_street
 from #rez_tmp a
left join dbo.partner p on a.customer_id=p.id_kupca
left join dbo.VRST_OSE v on p.vr_osebe=v.vr_osebe
left join dbo.drzave d1 on a.related_fo_manage_country1=d1.DRZAVA
left join dbo.drzave d2 on a.related_fo_manage_country2=d2.DRZAVA
left join dbo.drzave d3 on a.related_fo_manage_country3=d3.DRZAVA
left join dbo.drzave d4 on a.assignee_country=d4.DRZAVA
left join dbo.drzave d5 on a.customer_country=d5.DRZAVA
left join dbo.drzave d6 on a.customer_business_country=d6.DRZAVA
where a.assignee_desc is not null and rtrim(a.assignee_desc) <> ''
and a.id_kupca in (select distinct id_kupca from pogodba where status_akt='A')
	
/*
select 
dat_eval, 
left(customer_desc,240)as customer_organization,
left(customer_id,15) as customer_id,
customer_address,
customer_place,
left(customer_country,240) as customer_country,
d5.INT_OZNAKA as customer_country_cod,
customer_business_address,
customer_business_place,
left(customer_business_country,240) as customer_business_country,
d6.INT_OZNAKA as customer_business_country_cod,
customer_date_of_establishment,
left(customer_emso,240) as customer_emso,
left(customer_oib,240) as customer_oib,
customer_stev_reg,
p.kraj_roj as customer_pob,
--p.vr_osebe as customer_organization,
--v.naziv as customer_organization_desc,
left(related_fo_manage_desc1,240) as related_fo_manage_desc1,
left(related_fo_manage_emso1,240) as related_fo_manage_emso1,
related_fo_manage_address1,
left(related_fo_manage_place1,240) as related_fo_manage_place1,
left(related_fo_manage_country1,240) as related_fo_manage_country1,
d1.INT_OZNAKA as related_fo_manage_country1_cod,
convert(varchar(10), related_fo_manage_birth_date1, 104) as related_fo_manage_birth_date1,
left(related_fo_manage_birthplace1,240) as related_fo_manage_birthplace1,
related_fo_manage_foundation1,
left(isnull(related_fo_manage_percentage_of_shares1,0.00),240) as related_fo_manage_percentage_of_shares1,
left(related_fo_manage_desc2,240) as related_fo_manage_desc2,
left(related_fo_manage_emso2,240) as related_fo_manage_emso2,
left(related_fo_manage_address2,240) as related_fo_manage_address2,
left(related_fo_manage_place2,240) as related_fo_manage_place2,
left(related_fo_manage_country2,240) as related_fo_manage_country2,
d2.INT_OZNAKA as related_fo_manage_country2_cod,
convert(varchar(10), related_fo_manage_birth_date2, 104) as related_fo_manage_birth_date2,
left(related_fo_manage_birthplace2,240) as related_fo_manage_birthplace2,
related_fo_manage_foundation2,
left(isnull(related_fo_manage_percentage_of_shares2,0.00), 240) as related_fo_manage_percentage_of_shares2, 
left(related_fo_manage_desc3,240) as related_fo_manage_desc3,
left(related_fo_manage_emso3,240) as related_fo_manage_emso3,
left(related_fo_manage_address3,240) as related_fo_manage_address3,
left(related_fo_manage_place3,240) as related_fo_manage_place3,
left(related_fo_manage_country3,240) as related_fo_manage_country3,
d3.INT_OZNAKA as related_fo_manage_country3_cod,
convert(varchar(10), related_fo_manage_birth_date3, 104) as related_fo_manage_birth_date3,
left(related_fo_manage_birthplace3,240) as related_fo_manage_birthplace3,
left(related_fo_manage_foundation3,240) as related_fo_manage_foundation3,
left(isnull(related_fo_manage_percentage_of_shares3,0.00),240) as related_fo_manage_percentage_of_shares3,
left(assignee_desc,240) as assignee_desc,
convert(varchar(10), assignee_birth_date, 104) as assignee_birth_date,
left(assignee_birthplace,240) as assignee_birthplace,
assignee_address,
left(assignee_place,240) as assignee_place,
left(assignee_country,240) as assignee_country,
d4.INT_OZNAKA as assignee_country_cod,
left(assignee_oib,240) as assignee_oib,
--left(assignee_personal_doc_type,240) as assignee_personal_doc_type,
--left(assignee_personal_doc_id,240) as assignee_personal_doc_id,
--assignee_personal_doc_date,
--left(assignee_personal_doc_department,240) as assignee_personal_doc_department,
left(assigne_employment,240) as assigne_employment,
left(assignee_work_place,240) as assignee_work_place
into #rez
from #rez_tmp a
left join dbo.partner p on a.customer_id=p.id_kupca
left join dbo.VRST_OSE v on p.vr_osebe=v.vr_osebe
left join drzave d1 on a.related_fo_manage_country1=d1.DRZAVA
left join drzave d2 on a.related_fo_manage_country2=d2.DRZAVA
left join drzave d3 on a.related_fo_manage_country3=d3.DRZAVA
left join drzave d4 on a.assignee_country=d4.DRZAVA
left join drzave d5 on a.customer_country=d5.DRZAVA
left join drzave d6 on a.customer_business_country=d6.DRZAVA

*/

select* into #temp from #rez

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
		FROM #temp t
		INNER JOIN dbo.PARTNER p on p.id_kupca=t.id_kupca
		WHERE p.vr_osebe in (SELECT id FROM #tempVrste)
		Group by t.ID_KUPCA, p.vr_osebe 
	) as s
	FOR XML PATH ('Customers'), ROOT('ROOT')
)

DECLARE @time datetime;
SET @time=GETDATE();
exec dbo.gsp_GDPR_LogCustomerDataAccessInternal @time, {@username}, null,'Ime, Prezime','INTERNAL','CUSTOM_REPORT', 'Posebni izvještaj','1080',@xml
drop table #tempVrste
-- KONEC GDPR

select  id_pog, 
		id_cont, 
		naz_kr_kup, 
		ulica, 
		id_poste, 
		id_kupca,
		mesto, 
		telefon, 
		gsm, 
		vr_osebe, 
		nacin_leas, 
		id_obd,
		max_datum_dok,
		kategorija, 
		id_akcije, 
		naziv, 
		plac, 
		obnaleto,
		naziv_opreme
from #temp

drop table #temp


	drop table #current_state
	drop table #new_ones
	drop table #ods_data_field1
	drop table #ods_data_field2
	drop table #rez_tmp
	drop table #rez


	