	Edoc channel ID	 Description	IO channel code	 Is active	Handler class	Handler parameters	Is batch export
	EDOC_EX1	ZA DMS	EDOC_EXPORT1	True	GMI.EdocEngine.SimpleBatchExporter,gmi_edoc_engine	filter_metadata_field=edoc.dms;filter_metadata_value=1	True
	EDOC_EX2	ZA PRINT CENTAR	EDOC_EXPORT2	True	GMI.EdocEngine.SimpleBatchExporter,gmi_edoc_engine	dont_copy_xml_files=true;destination_must_be_empty=false;ignore_duplicates=false;file_name_metadata=print_centar_name;filter_metadata_field=edoc.filter_field;filter_metadata_value=1	True
	EDOC_EX3	NE ZA PRINT CENTAR	EDOC_EXPORT3	True	GMI.EdocEngine.SimpleBatchExporter,gmi_edoc_engine	dont_copy_xml_files=true;destination_must_be_empty=false;ignore_duplicates=false;file_name_metadata=print_centar_name;filter_metadata_field=edoc.not_print;filter_metadata_value=1	True
	EDOC_EX4	ZA WEB (SAMO RATE)	EDOC_EXPORT4	True	GMI.EdocEngine.SimpleBatchExporter,gmi_edoc_engine	dont_copy_xml_files=false;destination_must_be_empty=false;ignore_duplicates=false;filter_metadata_field=edoc.for_web;filter_metadata_value=1	True
	EDOC_EX5	Export channel to mail (TaxchngIx)	EDOC_EXPORT	True	GMI.EdocEngine.EdocToXdocExporterBatch,gmi_edoc_engine	id_xdoc_template=57;	True
	EDOC_EXPORT_FINA	Export channel to FINA	HR_SLOG_DSA	True	GMI.EdocEngine.SimpleBatchExporter, gmi_edoc_engine	dont_copy_xml_files=false;destination_must_be_empty=false;ignore_duplicates=false;filter_metadata_field=fina.is_for_fina;filter_metadata_value=true	True
	

	Report name	 Document type	 Is active	Edoc condition	 Edoc ID lookup	 Document type lookup
	ARH_DOK_OP_SSOFT_RLC		False	select cast(case when dat_prip >= '20190709' then 1 else 0 end as bit) from dbo.arh_dok_opom where cast(id_opom as varchar(100)) = @Id	select case when ddv_id is null then rtrim(cast(id_opom as varchar(100))) else rtrim(ddv_id) end from dbo.arh_dok_opom where id_opom = @id	select case when ddv_id is null then 'RmndrDoc' else 'Invoice' end from dbo.arh_dok_opom where id_opom = @id
	DDV_DBRP_ZVEC_SSOFT_RLC		True	select cast(case when ddv_id is not null and ddv_date >= '20151201' then 1 else 0 end as bit)  from dbo.spr_ddv where cast(id_spr_ddv as varchar(100)) = @Id	select case when ddv_id is null or ddv_id = '' then cast(id_spr_ddv as varchar(100)) else ddv_id end from dbo.spr_ddv where id_spr_ddv = @id	select case when ddv_id is null or ddv_id = '' then 'TaxChange' else 'Invoice' end from dbo.spr_ddv where id_spr_ddv = @id
	DOK_OP_SSOFT_RLC		True	select cast(case when dat_prip >= '20190628' then 1 else 0 end as bit) from dbo.dok_opom where cast(id_opom as varchar(100)) = @Id 
union all 
select cast(case when dat_prip >= '20190628' then 1 else 0 end as bit) from dbo.arh_dok_opom where cast(id_opom as varchar(100)) = @Id	select case when ddv_id is null then rtrim(cast(id_opom as varchar(100))) else rtrim(ddv_id) end from dbo.dok_opom where id_opom = @id  
union all 
select case when ddv_id is null then rtrim(cast(id_opom as varchar(100))) else rtrim(ddv_id) end from dbo.arh_dok_opom where id_opom = @id	select case when ddv_id is null then 'RmndrDoc' else 'Invoice' end from dbo.dok_opom where id_opom = @id  
union all  
select case when ddv_id is null then 'RmndrDoc' else 'Invoice' end from dbo.arh_dok_opom where id_opom = @id
	OPOMIN		True	select case when datum_dok >='20190628' then CAST(1 as bit) else CAST(0 as bit) end from dbo.gv_za_opom_with_arh where id_opom = @id and dok_opom is not null and dok_opom <> ''	select case when stros_op_val = 0 then rtrim(cast(id_opom as varchar(100))) else rtrim(ddv_id) end from dbo.gv_za_opom_with_arh where id_opom = @id	select case when dok_opom is not null and dok_opom <> '' and (ddv_id is null or ddv_id <> '') and stros_op_val = 0 then 'Reminder' else 'Invoice' end from dbo.gv_za_opom_with_arh where id_opom = @id
	ODOB1_SSOFT_RLC	Approval	True			
	NAL_PL_SSOFT_RLC	Contract	True			
	PLANP_SSOFT_RLC	Contract	True			
	PROM_DAT_DOK_SSOFT_RLC	Contract	True			
	PROM_NAB_DOK_SSOFT_RLC	Contract	True			
	PROM_OTPL_FL_SSOFT_RLC	Contract	True			
	PROM_OTPL_OL1_SSOFT_RLC	Contract	True			
	ZAH_UK_REG_SSOFT_RLC	Contract	True			
	BPM_SCORING_VIEW	General	True			
	GL_K_DNEV_SSOFT_RLC	General	True			
	KU_DNEV_SSOFT_RLC	General	True			
	OBV_O1_SSOFT_RLC	General	True			
	OBV_OPC_SSOFT_RLC	General	True		Select @id + '_OBV_OPC_SSOFT_RLC'	
	OBVREG_SSOFT	General	True	Select CAST(~inactive as bit) From dbo.users Where username = 'sys_eom'		
	OTHER2GK_SSOFT_RLC	General	True			
	VARSCINA_SSOFT_RLC	General	False	select 
cast(case when datum_dok >= '20121220' then 1 else 0 end as bit) 
from dbo.planp 
where st_dok = @Id		
	OBV_POR_SSOFT_RLC	GuarRemind	True		Select REPLACE (@id,';','$')	
	OPOMJAM_SSOFT_RLC	GuarRemind	True		Select REPLACE (@id,';','$')	
	FAK_AVAN_RO_SSOFT_RLC	Invoice	True	select cast(case when ddv_date >= '20121211' then 1 else 0 end as bit) from dbo.rac_out where ddv_id = @Id		
	FAK_AVAN_SSOFT_RLC	Invoice	True	select cast(case when ddv_date >= '20121211' then 1 else 0 end as bit) from dbo.rac_out where ddv_id = @Id		
	FAK_LOBR_SSOFT_RLC	Invoice	True	select cast(case when ddv_date >= '20121203' then 1 else 0 end as bit) from dbo.rac_out where ddv_id = @Id		
	FAKT_TR_SSOFT_RLC	Invoice	True	select cast(case when ddv_date >= '20121220' then 1 else 0 end as bit) from dbo.rac_out where ddv_id = @Id		
	KK_FAKT	Invoice	True	select cast(case when ddv_date >= '20151201' then 1 else 0 end as bit) from dbo.rac_out where ddv_id = @Id		
	OPC_FAK_SSOFT_RLC	Invoice	True	select cast(case when ddv_date >= '20190628' then 1 else 0 end as bit) from dbo.rac_out where ddv_id = @Id		
	OUTPU_R2_SSOFT_RLC	Invoice	True	select cast(case when a.ddv_date >= '20190628' then 1 else 0 end as bit) from dbo.rac_out a INNER JOIN dbo.gl_output_r b ON a.ddv_id = b.ddv_id where a.ddv_id = @Id		
	SPL_FAK	Invoice	True	select cast(case when ddv_date >= '20140115' then 1 else 0 end as bit) from dbo.rac_out where ddv_id = @Id		
	ZOBR_FA_SSOFT_RLC	Invoice	True	select cast(case when ddv_date >= '20121214' then 1 else 0 end as bit) from dbo.rac_out where ddv_id = @Id		
	ZBR_FAKT_SSOFT_RLC	InvoiceCum	True	Select cast(case when ddv_id is null or ddv_id = '' then 0 else 1 end as bit) From dbo.zbirniki where cast(id_zbirnik as varchar(100)) = @id		
	OBV_LOBR_SSOFT_RLC	Notif	True	select cast(case when datum_dok >= '20121220' then 1 else 0 end as bit) from dbo.najem_ob where id_najem_ob = @Id		
	OBV_IND_SSOFT_RLC	TaxChngIx	True	select cast(case when datum >= '20181002' then 1 else 0 end as bit) from dbo.rep_ind where cast(id_rep_ind as varchar(100)) = @Id		