-- [[TAX_ID=75346450537]]

--declare @id varchar(100), @OriginalFileName varchar(100), @DocType varchar(100), @ReportName varchar(100)
--set @id = '320'
--set @OriginalFileName = 'InvoiceCum_82_2022_05_18_11_25_36_126.pdf'
--set @DocType = 'InvoiceCum'
--set @ReportName = 'ZBR_FAKT_SSOFT_RLC'

declare @eom_blockade bit
set @eom_blockade = (select ~inactive from users where username = 'sys_eom')

DECLARE @id_object varchar(100)
SET @id_object = (SELECT id_object FROM dbo.reports_log WHERE edoc_file_name = @OriginalFileName AND id_object_edoc = @id)

declare @FileName varchar(200)
set @FileName = @OriginalFileName 
declare @OriginalId varchar(2000)
set @OriginalId = (select dbo.gfn_edoc_get_original_id_for_file(@OriginalFileName))

--ovo se koristi samo za 'Contract'
declare @id_reports_log int
set @id_reports_log = (SELECT id_reports_log FROM dbo.reports_log WHERE edoc_file_name = @FileName and doc_type = 'Contract' and id_object_edoc = @Id)

declare @is_for_fina bit


if @DocType='Invoice'
begin

	set @is_for_fina = (Select cast(count(*) as bit) 
						  From dbo.partner a 
						  inner join dbo.rac_out b on a.id_kupca = b.id_kupca
						  where a.ident_stevilka is not null and a.ident_stevilka <> '' and b.ddv_id = @id and @DocType='Invoice') 
end

if @DocType = 'InvoiceCum'
begin
	set @is_for_fina = (Select cast(count(*) as bit)
						 From dbo.zbirniki a
						 inner join dbo.rac_out b on a.ddv_id = b.ddv_id 
						 inner join dbo.partner c on b.id_kupca = c.id_kupca
						 Where @DocType='InvoiceCum' and a.id_zbirnik = @id and c.ident_stevilka is not null and c.ident_stevilka <> '')
end
--MID: 44138 g_barbarak - Contract i Approval su podešeni na AllowAll

if @DocType = 'Invoice'
begin

	declare @rac_source varchar(100)

	set @rac_source = (Select dbo.gfn_GetInvoiceSource(@Id))
	if @rac_source = 'ERROR'
		begin
		if exists(select * from dbo.rac_out where ddv_id = @id and sif_rac = 'AVA')
			set @rac_source = 'AVANSI'
	end

	Select naz_kr_kup as [partner_title],
	CASE WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'LOBR' THEN '0001' 
	WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'MSTR' THEN '0003' 
	WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'POLO' THEN '0004' 
	WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'SFIN' THEN '0009' 
	WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'REG' THEN '0010' 
	WHEN @rac_source = 'ZOBR_FA' THEN '0006'
	WHEN @rac_source = 'AVANSI' THEN '0007'
	WHEN @rac_source = 'TEC_RAZL' THEN '0008'
	WHEN @rac_source = 'PLANP' and v1.sif_terj = 'MSTR' THEN '0003'
	WHEN @rac_source = 'PLANP' and v1.sif_terj = 'POLO' THEN '0004'
	WHEN @rac_source = 'PLANP' and v1.sif_terj = 'VARS' THEN '0005'
	WHEN @rac_source = 'FAKTURE' and v2.id_terj in ('1I','1J') THEN '0031'
	WHEN @rac_source = 'FAKTURE' and v2.id_terj = '13' THEN '0032'
	WHEN @rac_source = 'FAKTURE' and v2.id_terj not in ('1I','1J','13') THEN '0020'
	WHEN @rac_source = 'POGODBA' THEN '0011'
	WHEN @rac_source = 'SPR_DDV' THEN '0012'
	WHEN @rac_source = 'OPC_FAKT' THEN '0021'
	WHEN @rac_source = 'GL_OUTPUT_R' THEN '0022'
	WHEN @rac_source = 'ZA_OPOM' THEN '0041' --and opom.ddv_id is not null 
	WHEN @rac_source = 'DOK_OPOM' THEN '0046'
	ELSE 'XXXX' END as [tip_dokumenta],
	case when @is_for_fina = 1 then '0' else '1' end as [edoc.dms],
	CASE WHEN @is_for_fina = 1 then '0'
             WHEN @eom_blockade = 0 Or @rac_source in ('SPR_DDV','POGODBA', 'OPC_FAKT','GL_OUTPUT_R') Or (f.id_kupca is not null And @rac_source not in ('ZA_OPOM','DOK_OPOM')) or (e.id_kupca is not null And @rac_source = 'NAJEM_FA' And v.sif_terj = 'LOBR') Then '0' 
             ELSE '1' End [edoc.filter_field],
	CASE WHEN @is_for_fina = 1 then '0'
             WHEN @rac_source = 'NAJEM_FA' And v.sif_terj = 'LOBR' Then '1' 
             ELSE '0' End [edoc.for_web],
	CASE WHEN @is_for_fina = 1 then '0'
             WHEN @eom_blockade = 1 And @rac_source not in ('SPR_DDV','POGODBA', 'OPC_FAKT','GL_OUTPUT_R', 'ZA_OPOM','DOK_OPOM') And f.id_kupca is not null And Not(e.id_kupca is not null And @rac_source = 'NAJEM_FA' And v.sif_terj = 'LOBR') Then '1' 
             Else '0' End as [edoc.not_print],
	RTRIM(partner.id_kupca) + '_' +  
	CASE WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'LOBR' THEN '0001' 
	WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'MSTR' THEN '0003' 
	WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'POLO' THEN '0004' 
	WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'SFIN' THEN '0009' 
	WHEN @rac_source = 'NAJEM_FA' and v.sif_terj = 'REG' THEN '0010' 
	WHEN @rac_source = 'ZOBR_FA' THEN '0006'
	WHEN @rac_source = 'AVANSI' THEN '0007'
	WHEN @rac_source = 'TEC_RAZL' THEN '0008'
	WHEN @rac_source = 'PLANP' and v1.sif_terj = 'MSTR' THEN '0003'
	WHEN @rac_source = 'PLANP' and v1.sif_terj = 'POLO' THEN '0004'
	WHEN @rac_source = 'PLANP' and v1.sif_terj = 'VARS' THEN '0005'
	WHEN @rac_source = 'FAKTURE' and v2.id_terj in ('1I','1J') THEN '0031'
	WHEN @rac_source = 'FAKTURE' and v2.id_terj = '13' THEN '0032'
	WHEN @rac_source = 'FAKTURE' and v2.id_terj not in ('1I','1J','13') THEN '0020'
	WHEN @rac_source = 'POGODBA' THEN '0011'
	WHEN @rac_source = 'SPR_DDV' THEN '0012'
	WHEN @rac_source = 'OPC_FAKT' THEN '0021'
	WHEN @rac_source = 'GL_OUTPUT_R' THEN '0022'
	WHEN @rac_source = 'ZA_OPOM' THEN '0041' --and opom.ddv_id is not null
	WHEN @rac_source = 'DOK_OPOM' THEN '0046'
	ELSE 'XXXX' END
	+ '_' + RTRIM(@Id) + '.pdf' As print_centar_name, 
	-- 13.11.2017 popravljeno MR 39200 --CASE WHEN b.SOURCE = 'NAJEM_FA' And v.sif_terj = 'LOBR' and c.nacin_leas in ('F1','F2') THEN c.sdebit ELSE rac_out.debit+rac_out.NEOBDAV END as iznos_rate, 
	CASE WHEN @rac_source = 'NAJEM_FA' And v.sif_terj = 'LOBR' and dbo.gfn_Nacin_leas_HR(c.nacin_leas) = ('F1') THEN c.sdebit ELSE rac_out.debit+rac_out.NEOBDAV END as iznos_rate, 
	dbo.gfn_transformDDV_ID_HR(rac_out.ddv_id, rac_out.ddv_date) as Fis_BrRac
	From dbo.rac_out 
	inner join dbo.partner on rac_out.id_kupca = partner.id_kupca 
	/*inner join (Select a.ddv_id, dbo.gfn_GetInvoiceSource(a.ddv_id) as source
		  From dbo.rac_out a 
		  Where a.ddv_id =  @Id and @DocType='Invoice'
	) b on rac_out.ddv_id = b.ddv_id*/
	left join dbo.najem_fa c on rac_out.ddv_id = c.ddv_id And @rac_source = 'NAJEM_FA'
	left join dbo.vrst_ter v on c.id_terj = v.id_terj
	left join dbo.planp pp on rac_out.ddv_id = pp.ddv_id And @rac_source = 'PLANP'
	left join dbo.vrst_ter v1 on pp.id_terj = v1.id_terj
	left join dbo.fakture fak on rac_out.ddv_id = fak.ddv_id And @rac_source = 'FAKTURE'
	left join dbo.vrst_ter v2 on fak.id_terj = v2.id_terj
	--left join dbo.gv_za_opom_with_arh opom on rac_out.ddv_id = opom.ddv_id
	/*left join (select ddv_id, st_opomin from dbo.dok_opom where ddv_id = @id group by ddv_id, st_opomin
			   union
			   select ddv_id, st_opomin from dbo.arh_dok_opom where ddv_id = @id group by ddv_id, st_opomin
	) dok_opom on rac_out.ddv_id = dok_opom.ddv_id*/
	left join dbo.p_kontakt f on partner.id_kupca = f.id_kupca And f.id_vloga = 'XP'
	left join dbo.p_kontakt e on partner.id_kupca = e.id_kupca And e.id_vloga = 'XW'
	Where rac_out.ddv_id =  @Id --and @DocType='Invoice'
end

if @DocType = 'Notif'
begin
	Select b.naz_kr_kup as [partner_title],
	'0002' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN @eom_blockade = 0 Or f.id_kupca is not null Then '0' ELSE '1' End [edoc.filter_field],
	'0' as [edoc.for_web],
	CASE WHEN @eom_blockade = 1 And f.id_kupca is not null Then '1' ELSE '0' End [edoc.not_print],
	RTRIM(a.id_kupca) + '_' + '0002' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.debit as iznos_rate, 
	'' as Fis_BrRac
	From dbo.najem_ob a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	left join dbo.p_kontakt f on b.id_kupca = f.id_kupca And f.id_vloga = 'XP'
	Where cast(a.id_najem_ob as varchar(100)) =  @Id and @DocType='Notif'
end

if @DocType = 'General' and @ReportName = 'OBVREG_SSOFT'
begin
	Select '0013' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN @eom_blockade = 1 Then '1' ELSE '0' End [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_kupca) + '_' + '0013' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as partner_title,
	a.id_cont as contract_id, 
	RTRIM(p.id_pog) as contract_number
	From dbo.za_regis a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
    Inner join dbo.pogodba p on a.id_cont = p.id_cont
	inner join dbo.reports_log c on cast(a.id_za_regis as varchar(100)) = @id And c.doc_type = 'General' and c.edoc_file_name = @OriginalFileName
	where c.id_object_edoc = @id AND @DocType = 'General'
end
--g_igorp MR 50129 26.01.2023 dodani ispisi 'PROM_DAT_DOK_SSOFT_RLC','PROM_NAB_DOK_SSOFT_RLC'
if @DocType = 'Contract' and @ReportName IN ('PROM_OTPL_FL_SSOFT_RLC', 'PROM_DAT_DOK_SSOFT_RLC','PROM_NAB_DOK_SSOFT_RLC')
begin
	
	Select '0014' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_pog) + '_' + '0014' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as partner_title,
	a.id_cont as contract_id, 
	RTRIM(a.id_pog) as contract_number
	From dbo.pogodba a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	Where cast(a.id_cont as varchar(100)) =  @Id and @DocType='Contract'
end

if @DocType = 'Contract' and @ReportName = 'PROM_OTPL_OL1_SSOFT_RLC'
begin
		
	Select '0015' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_pog) + '_' + '0015' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as partner_title,
	a.id_cont as contract_id, 
	RTRIM(a.id_pog) as contract_number
	From dbo.pogodba a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	Where cast(a.id_cont as varchar(100)) =  @Id and @DocType='Contract'
end

if @DocType = 'TaxChngIx'
begin
	Select '0016' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN g.id_kupca is not null Then '0'
	     When @eom_blockade = 0  Then '0' 
		 WHEN  f.id_kupca is not null Then '0' 
	     ELSE '1' End  [edoc.filter_field],
	'0' as [edoc.for_web],
	CASE WHEN g.id_kupca is not null Then '0' 
	     when @eom_blockade = 1 And f.id_kupca is not null  Then '1'  
		 ELSE '0' End [edoc.not_print],
	RTRIM(a.id_kupca) + '_' + '0016' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as [partner_title],
	a.id_cont as contract_id, 
	RTRIM(p.id_pog) as contract_number
	From dbo.rep_ind a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	Inner join dbo.pogodba p on a.id_cont = p.id_cont
	left join dbo.p_kontakt f on b.id_kupca = f.id_kupca And f.id_vloga = 'XP'
	left join dbo.p_kontakt g on b.id_kupca = g.id_kupca And g.id_vloga = '02'
	Where cast(a.id_rep_ind as varchar(100)) = @Id and @DocType='TaxChngIx'
end

if @DocType = 'Reminder'
begin 
	Select '0042' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN @eom_blockade = 0 Then '0' ELSE '1' End [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_kupca) + '_' + '0042' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as [partner_title],
	a.id_cont as contract_id, 
	RTRIM(p.id_pog) as contract_number
	From dbo.gv_za_opom_with_arh a
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	Inner join dbo.pogodba p on a.id_cont = p.id_cont
	Where cast(a.id_opom as varchar(100)) = @Id And @DocType = 'Reminder'
end

if @DocType = 'RmndrDoc'
begin 
	Select '0047' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN @eom_blockade = 0 Then '0' ELSE '1' End [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(p.id_kupca) + '_' + '0047' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	p.id_kupca as partner_id,
	b.naz_kr_kup as [partner_title],
	d.id_cont as contract_id, 
	RTRIM(p.id_pog) as contract_number
	From dbo.dok_opom a
	Inner join dbo.dokument d on a.id_dokum = d.id_dokum
	Inner join dbo.pogodba p on d.id_cont = p.id_cont
	Inner join dbo.partner b on p.id_kupca = b.id_kupca
	Where cast(a.id_opom as varchar(100)) = @Id And @DocType = 'RmndrDoc'
	
	union all
	
	Select '0047' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN @eom_blockade = 0 Then '0' ELSE '1' End [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(p.id_kupca) + '_' + '0047' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	p.id_kupca as partner_id,
	b.naz_kr_kup as [partner_title],
	d.id_cont as contract_id, 
	RTRIM(p.id_pog) as contract_number
	From dbo.arh_dok_opom a
	Inner join dbo.dokument d on a.id_dokum = d.id_dokum
	Inner join dbo.pogodba p on d.id_cont = p.id_cont
	Inner join dbo.partner b on p.id_kupca = b.id_kupca
	Where cast(a.id_opom as varchar(100)) = @Id And @DocType = 'RmndrDoc'
end

if @DocType = 'GuarRemind' and @ReportName = 'OPOMJAM_SSOFT_RLC'
begin 
	Select '0044' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN @eom_blockade = 0 Then '0' ELSE '1' End [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(por.id_poroka) + '_' + '0044' + '_' + cast(substring(@id, 0, charindex('$',@id)) as varchar(100)) + '.pdf' As print_centar_name,
	por.id_poroka as partner_id,
	par.naz_kr_kup as [partner_title],
	a.id_cont as contract_id, 
	RTRIM(b.id_pog) as contract_number
	From dbo.gv_za_opom_with_arh a
	Inner join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont
	Inner Join dbo.pog_poro por ON a.id_cont = por.id_cont and por.id_poroka = cast(substring(@id, charindex('$',@id)+1, len(rtrim(@id))) as char(6))  and por.neaktiven = 0 and por.oznaka = 'A'
	Inner join dbo.partner par on por.id_poroka = par.id_kupca
	Where cast(a.id_opom as varchar(100)) = cast(substring(@id, 0, charindex('$',@id)) as varchar(100)) and @DocType = 'GuarRemind'
end

if @DocType = 'GuarRemind' and @ReportName = 'OBV_POR_SSOFT_RLC'
begin 
	Select '0043' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN @eom_blockade = 0 Then '0' ELSE '1' End [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(por.id_poroka) + '_' + '0043' + '_' + cast(substring(@id, 0, charindex('$',@id)) as varchar(100)) + '.pdf' As print_centar_name,
	por.id_poroka as partner_id,
	par.naz_kr_kup as [partner_title],
	a.id_cont as contract_id, 
	RTRIM(b.id_pog) as contract_number
	From dbo.gv_za_opom_with_arh a
	Inner join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont
	Inner Join dbo.pog_poro por ON a.id_cont = por.id_cont and por.id_poroka = cast(substring(@id, charindex('$',@id)+1, len(rtrim(@id))) as char(6)) and por.neaktiven = 0 and  por.oznaka in ('0','1')
	Inner join dbo.partner par on por.id_poroka = par.id_kupca
	Where cast(a.id_opom as varchar(100)) = cast(substring(@id, 0, charindex('$',@id)) as varchar(100)) and @DocType = 'GuarRemind'
end

if @DocType = 'General' and @ReportName = 'OBV_O1_SSOFT_RLC'
begin

Select '0045' as [tip_dokumenta],
    '1' as [edoc.dms],
    CASE WHEN @eom_blockade = 0 Then '0' ELSE '1' End [edoc.filter_field],
    '0' as [edoc.for_web],
    '0' as [edoc.not_print],
    RTRIM(p.id_kupca) + '_0045_' + rtrim(@Id) + '.pdf' As print_centar_name,
	p.id_kupca as partner_id,
    p.naz_kr_kup as [partner_title]
    From dbo.PARTNER p
    Where cast(p.id_kupca as varchar(100)) = cast(substring(@id, 1, charindex('$', @id)-1) as varchar(100)) and @DocType = 'General'
end

if @DocType = 'Contract' and @ReportName = 'NAL_PL_SSOFT_RLC'
begin

	Select '0017' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_pog) + '_' + '0017' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as partner_title,
	a.id_cont as contract_id, 
	RTRIM(a.id_pog) as contract_number
	From dbo.pogodba a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	Where cast(a.id_cont as varchar(100)) = @Id and @DocType = 'Contract'
end

if @DocType = 'Approval'
begin
	Select '0018' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_kupca) + '_' + '0018' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name
	From dbo.Odobrit a
	Where cast(a.id_odobrit as varchar(100)) = @Id and @DocType = 'Approval'
end

if @DocType = 'Contract' and @ReportName = 'PLANP_SSOFT_RLC'
begin

	Select '0019' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_pog) + '_' + '0019' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as partner_title,
	a.id_cont as contract_id, 
	RTRIM(a.id_pog) as contract_number
	From dbo.pogodba a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	Where cast(a.id_cont as varchar(100)) = @Id and @DocType = 'Contract'
end

IF @DocType = 'General' AND @ReportName = 'OBV_OPC_SSOFT_RLC'
BEGIN

SELECT '0033' AS [tip_dokumenta],
    '1' AS [edoc.dms],
    CASE WHEN @eom_blockade = 0 THEN '0' ELSE '1' End [edoc.filter_field],
    '0' AS [edoc.for_web],
    '0' AS [edoc.not_print],
    RTRIM(odg.id_kupca) + '_0033_' + rtrim(@Id) +'.pdf' AS print_centar_name,
	odg.id_kupca AS partner_id,
    par.naz_kr_kup AS partner_title,
	odg.id_cont as contract_id,					   
	RTRIM(LTRIM(pog.id_pog)) AS contract_number
 	FROM dbo.odgnaopc odg
	JOIN dbo.partner par ON odg.id_kupca = par.id_kupca
	JOIN dbo.pogodba pog ON odg.id_cont = pog.id_cont
	--MID 45895 JOIN pogodbe i reports_log radimo po id_object a ne @id (što je id_object_edoc a kako bi obradili i ispisi istog doctype i istog id-ja u SSOFT ispisu (u ovom slučaju id_cont)
	--za takve slučajeve id_object_edoc mora biti jedinstven što je za ove slučajeve riješeno dodavanjem naziva SSOFT ispisa na id u reports_edoc_settings.edoc_id_lookup
	inner join dbo.reports_log b on cast(odg.id_cont as varchar(100)) = b.id_object And b.doc_type = 'General' and b.edoc_file_name = @OriginalFileName
	where b.id_object_edoc = @id AND @DocType = 'General'	
END

if @DocType = 'Contract' and @ReportName = 'ZAH_UK_REG_SSOFT_RLC'
begin

	Select '0034' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	RTRIM(a.id_pog) + '_' + '0034' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as partner_title,
	a.id_cont as contract_id, 
	RTRIM(a.id_pog) as contract_number
	From dbo.pogodba a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	Where cast(a.id_cont as varchar(100)) = @Id and @DocType = 'Contract'
end

if @DocType = 'General' and @ReportName = 'KU_DNEV_SSOFT_RLC'
begin
	Select '0035' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	'Dnevnik kupaca_0035_' + RTRIM(@Id) + '.pdf' As print_centar_name
	From dbo.reports_log b 
	inner join dbo.users c on b.rendered_by = c.username
	where cast(b.id_object as varchar(100)) = @Id and @DocType = 'General'
end

if @DocType = 'General' and @ReportName = 'GL_K_DNEV_SSOFT_RLC'
begin
	Select '0036' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	'Dnevnik GK br.' + RTRIM(@Id) + '.pdf' As print_centar_name
	From dbo.reports_log b 
	inner join dbo.users c on b.rendered_by = c.username
	where cast(b.id_object as varchar(100)) = @Id and @DocType = 'General'
end

if @DocType = 'General' and @ReportName = 'OTHER2GK_SSOFT_RLC'
begin
	Select '0037' as [tip_dokumenta],
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print],
	'Dnevnik prijenosa iz '+SUBSTRING(@id, 1, 2)+' br. ' + RTRIM(@Id) + '.pdf' As print_centar_name
	From dbo.reports_log b 
	inner join dbo.users c on b.rendered_by = c.username
	where cast(b.id_object as varchar(100)) = @Id and @DocType = 'General'
end

if @DocType = 'General' and @ReportName = 'BPM_SCORING_VIEW'
begin
	Select '0048' as [tip_dokumenta],
	 d.id_doc as [broj_odobrenja],
	 d.id_pon as [broj_ponude],
	 d.id_kupca as [partner_id], 
	 e.naz_kr_kup as [partner_title], 
	 c.external_id as [bpm_instanca], 
	'1' as [edoc.dms],
	'0' as [edoc.filter_field],
	'0' as [edoc.for_web],
	'0' as [edoc.not_print]
	From dbo.reports_log b 
	inner join dbo.scoring_results c on cast(c.id_scoring as varchar(100)) = @Id 
	inner join dbo.Odobrit d on c.id_odobrit = d.id_odobrit 
	left join dbo.partner e on d.id_kupca = e.id_kupca 
	where cast(b.id_object as varchar(100)) = @Id and @DocType = 'General' and b.id_report = @ReportName
end

if @DocType = 'InvoiceCum'
begin
	Select 
	'0049' as [tip_dokumenta],
	case when @is_for_fina = 1 then '0' else '1' end as [edoc.dms],
	CASE when @is_for_fina = 1 then '0'
	     WHEN @eom_blockade = 0 THEN '0' 
		 when f.id_kupca is not null then '0'								  
		 ELSE '1' End as [edoc.filter_field],
	'0' as [edoc.for_web],
	CASE when @is_for_fina = 1 then '0'
	     WHEN @eom_blockade = 0 THEN '0' 
		 when f.id_kupca is null then '0'							  
		 ELSE '1' End as [edoc.not_print],
	RTRIM(b.id_kupca) + '_0049_' + RTRIM(ra.ddv_id) + '.pdf' As print_centar_name, 
	dbo.gfn_transformDDV_ID_HR(ra.ddv_id, ra.ddv_date) as Fis_BrRac
	From dbo.zbirniki z
	inner join dbo.rac_out ra on z.ddv_id = ra.ddv_id
	inner join dbo.partner b on ra.id_kupca = b.id_kupca 
	left join dbo.p_kontakt f on b.id_kupca = f.id_kupca And f.id_vloga = 'XP'																	   
	Where cast(z.id_zbirnik as varchar(100)) =  @id and @DocType = 'InvoiceCum'

end

If @DocType='Invoice'  and @is_for_fina = 1
Begin

		Select @is_for_fina as [fina.is_for_fina]
		
		declare @source varchar(30), @id_terj char(2), @tip_leas char(2), @p_zrac varchar(50), @p_podjetje varchar(100), @int_kamate varchar(100)
		declare @addCostXml varchar(max), @invoiceLineXml varchar(max), @taxTotalXml varchar(max), @datum_dok datetime
		declare @referencesXml varchar(max), @ubl_tip varchar(5), @xml as xml, @addPropertyXml varchar(max), @dom_valuta varchar(10)
	
		set @source = dbo.gfn_GetInvoiceSource(@Id)
		if @source = 'ERROR'
		begin
			if exists(select * from dbo.rac_out where ddv_id = @id and sif_rac = 'AVA')
				set @source = 'AVANSI'
		end
		
		Select @p_zrac = cast(rtrim(p_zrac) as varchar(50)), @p_podjetje = cast(rtrim(p_podjetje) as varchar(100)), @dom_valuta = cast(rtrim(dom_valuta) as varchar(10)) From dbo.nastavit
		set @addCostXml = ''
		set @invoiceLineXml = ''
		set @referencesXml = ''
		set @taxTotalXml = ''
		set @addPropertyXml = ''

		--OVA VARIJABLA SLUŽI AKO SE ŽELI RAZLIČITE VRIJEDNOSTI ZA ODREĐENA POLJA: InvoiceNote, InvoicePaymentDesc, 
		--InvoicePaymentNote, LineDesc
		set @ubl_tip = IsNull((Select TOP 1 c.vrednost From dbo.kategorije_entiteta a 
					inner join dbo.kategorije_tip b on a.id_kategorije_tip = b.id_kategorije_tip 
					inner join dbo.kategorije_sifrant c on a.id_kategorije_sifrant = c.id_kategorije_sifrant and a.id_kategorije_tip = c.id_kategorije_tip
					where b.sifra = 'Fina.Ubl.Tip' and b.entiteta = 'PARTNER'
					and a.id_entiteta = (Select id_kupca From dbo.rac_out Where ddv_id = @Id and @DocType='Invoice')
					order by a.id_kategorije_entiteta desc), 'UblEN')

		Select dbo.gfn_TransformDDV_ID_HR(a.ddv_id, a.ddv_date) as InvoiceId, 
		a.dat_vnosa as InvoiceIssueDate, 
		a.DDV_DATE as InvoiceDate,
		a.VALUTA as InvoiceDueDate,
		cast(null as datetime) as InvoicePeriodStartDate,
		cast(null as datetime) as InvoicePeriodEndDate,
		@dom_valuta	as InvoiceCurrency,
		'394' as InvoiceType, 
		a.ddv_date as InvoiceDeliveryDate,
		cast('' as varchar(max)) as InvoiceNote, -- Ubl 1024 znakova, UblEn nema ograničenja
		rtrim(a.izdal) as InvoicePersonIssued,
		a.id_kupca as InvoiceCustomerId,
		a.dav_stev as InvoiceCustomerOIB,
		coalesce(rtrim(kat1.val_string), b.ident_stevilka) as InvoiceCustomerFinaId,
		b.naz_kr_kup as InvoiceCustomerName,
		rtrim(replace(b.ulica_sed, rtrim(isnull(b.ulica_st_sed, '')), ''))  as InvoiceCustomerStreet, 
		isnull(b.ulica_st_sed, '') as InvoiceCustomerHouseNumber, 
		replace(b.id_poste_sed, 'HR-','') as InvoiceCustomerPostalCode,
		b.mesto_sed as InvoiceCustomerCity,
		rtrim(c.drzava) as InvoiceCustomerCountry,

		--TODO paziti nije isto za OPC_FAKT, FAKTURE, OUTPUT_GL pa treba popravljati po pojedinom tipu (ne ovdje)
		cast('HR01 ' + rtrim(isnull(p.sklic, '')) as varchar(100)) as InvoicePaymentId, 
		
		cast('' as varchar(max)) as InvoicePaymentDesc, --Ubl 105 znakova, UblEn nema ograničenja
		@p_zrac as InvoicePaymentAccount,
		cast('Molimo upišite ispravan poziv na broj' as varchar(max)) as InvoicePaymentNote, --Ovo ovisi koji je tip Ubl-a jer za Ubl mora biti do 
		cast(0 as decimal(18,2)) as InvoiceTotalNetAmount,
		cast(0 as decimal(18,2)) as InvoiceTotalTaxAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalWithTaxAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalAddCostsAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalRoundingAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalPayableAmount,
		cast('InvoiceEnvelope' as varchar(100)) as document_external_type, --TODO za odobrenje ovo mora biti CreditNoteEnvelope 
		cast('' as varchar(max)) as InvoiceCustomContractReference, 
		cast(rtrim(isnull(kat.val_string, '')) as varchar(max)) as InvoiceOrderReference,
		a.*, ks.klavzula
		into #invoice_data
		From dbo.rac_out a
		left join dbo.partner b on a.id_kupca = b.id_kupca 
		left join dbo.poste c on b.id_poste_sed = c.id_poste
		left join dbo.pogodba p on a.id_cont = p.id_cont
		left join dbo.klavzule_sifr ks on ks.id_klavzule = a.id_klavzule
		left join (
			Select cast(a.id_entiteta as int) as id_cont, a.val_string
			From dbo.kategorije_entiteta a
			inner join dbo.kategorije_tip b on a.id_kategorije_tip = b.id_kategorije_tip and b.entiteta = 'POGODBA'
			where b.sifra = 'ORDER_NO'
		) kat on p.ID_CONT = kat.id_cont and a.ID_KUPCA = p.id_kupca
		left join (
			Select cast(a.id_entiteta as int) as id_cont, a.val_string
			From dbo.kategorije_entiteta a
			inner join dbo.kategorije_tip b on a.id_kategorije_tip = b.id_kategorije_tip and b.entiteta = 'POGODBA'
			where b.sifra = 'UG_FINA_ID'
		) kat1 on p.ID_CONT = kat1.id_cont and a.ID_KUPCA = p.id_kupca
		Where a.ddv_id = @Id

		if @source = 'NAJEM_FA'
		begin 
			Select *
			into #najem_fa
			From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) where ddv_id = @id
            Select @id_terj = id_terj, @tip_leas = dbo.gfn_Nacin_leas_HR(nacin_leas), @datum_dok = datum_dok, @int_kamate = dbo.gfn_GetCustomSettings('id_terj_interkal_obr')  
            From #najem_fa 
            where ddv_id = @id

			if @id_terj = '21'
			begin 
				update #invoice_data set 
				InvoiceDate = b.datum_dok, 
				InvoiceDeliveryDate = b.datum_dok, 
				InvoiceDueDate = b.dat_zap, 
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO PREMA ISPISU
				--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)),  --TODO PREMA ISPISU
				
				InvoiceTotalNetAmount = case when @tip_leas = 'OL' 
											then b.rac_out_debit_neto + b.rac_out_neobdav   --NAJAMNINA + PPMV
											else b.rac_out_debit_neto + b.rac_out_brez_davka end,  --KAMATA
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit_davek + case when @tip_leas = 'OL' 
														then b.rac_out_debit_neto + b.rac_out_neobdav 
														else b.rac_out_debit_neto + b.rac_out_brez_davka end,
				InvoiceTotalAddCostsAmount = 0, -- case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end ,
				InvoiceTotalPayableAmount = b.rac_out_debit + b.rac_out_neobdav, -- + case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end
				InvoiceNote = case when @tip_leas in ('F1','ZP') 
								   then 'Glavnica u okviru ' + rtrim(cast(b.zap_obr as varchar(10))) + '. rate: ' + dbo.gfn_gccif(b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '. Ukupno za platiti: ' + dbo.gfn_gccif(b.rac_out_debit + b.rac_out_neobdav + b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '.'
								   else '' end,
				InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. Kod zakašnjenja plaćanja zaračunavamo zakonsku zateznu kamatu.' + case when b.id_tec <> '000' then ' Nakon datuma dospijeća u obvezi ste platiti iznos u valuti koristeći ' + rtrim(b.naz_tec)+' na dan uplate. Informacije o tečaju na dan uplate možete saznati putem info telefona RBA broj 062 / 62 62 62 ili na www.rba.hr.' else '' end
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				--left join dbo.general_register grp on grp.id_register = 'REPORT_SIGNATORY' and grp.id_key = 'FAK_LOBR' and grp.neaktiven = 0
				left join dbo.nastavit n on 1 = 1

			
				declare @startdate datetime, @enddate datetime, @rata_type varchar(30)/*, @rata_prije datetime, @rata_poslije datetime*/, @obnaleto decimal(6,2)
				
				--TODO OVAJ DIO PO LEASING KUĆI
				Select @rata_type =  
				case when (cs.val = 'Anticipative' and dok.id_dokum is null) or (cs.val = 'Decursive' and dok.id_dokum is not null) then 'Anticipative'
				when (cs.val = 'Decursive' And dok.id_dokum is null) Or (cs.val = 'Anticipative' And dok.id_dokum is not null) then 'Decursive'
				else '' end, 
				--@rata_prije = pp.datum_prije,
				--@rata_poslije = pp1.datum_poslije, 
				@obnaleto = c.obnaleto
				From #invoice_data a 
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				left join dbo.obdobja c on b.id_obd = c.id_obd
				Left Join dbo.custom_settings cs on cs.code = 'BOOKING_CRO_INT_ACCR_TYPE'
				Left Join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
				Left Join dbo.dokument dok on b.id_cont = dok.id_cont and CHARINDEX(dok.id_obl_zav, cs1.val) > 0
				--left join (Select id_cont, max(datum_dok) as datum_prije From dbo.planp where datum_dok < @datum_dok and id_terj = @id_terj group by id_cont)pp on b.id_cont = pp.id_cont
				--left join (Select id_cont, max(datum_dok) as datum_poslije From dbo.planp where datum_dok > @datum_dok and id_terj = @id_terj group by id_cont)pp1 on b.id_cont = pp1.id_cont
				Where a.ddv_id = @id
				
				--TODO OVAJ DIO PO LEASING KUĆI
				/*if @rata_type = 'Anticipative'
				begin 
					set @startdate = @datum_dok
				
					if @rata_poslije is null OR Abs(datediff(d, @datum_dok, @rata_poslije - 1) - datediff(d, @datum_dok, DATEADD(mm,12/@obnaleto,@datum_dok) - 1)) >= 5
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok) - 1
					end
				
					if @rata_poslije is not null And Abs(datediff(d, @datum_dok, @rata_poslije - 1) - datediff(d, @datum_dok, DATEADD(mm,12/@obnaleto,@datum_dok) - 1)) < 5
					begin 
						set @enddate = @rata_poslije - 1
					end
			
				end*/
				
				--TODO OVAJ DIO PO LEASING KUĆI
				/*if @rata_type = 'Decursive'
				begin
					set @enddate = @datum_dok
					if @rata_prije is null OR Abs(datediff(d, @rata_prije + 1, @datum_dok) - datediff(d, DATEADD(mm,-12/@obnaleto,@datum_dok) + 1, @datum_dok)) >= 5
					begin 
						set @startdate = DATEADD(mm,-12/@obnaleto,@datum_dok) + 1
					end
				
					if @rata_prije is not null And Abs(datediff(d, @rata_prije + 1, @datum_dok) - datediff(d, DATEADD(mm,-12/@obnaleto,@datum_dok) + 1, @datum_dok)) < 5
					begin
						set @startdate = @rata_prije + 1
					end
				end*/
				
				if @rata_type = 'Decursive'
				begin
					set @startdate = dbo.gfn_GetFirstDayOfMonth(DATEADD(mm, -12/@obnaleto + 1, @datum_dok))
					set @enddate = @datum_dok
					
				end
				else
				begin
					set @startdate = DATEADD(dd,-(DAY(@datum_dok)-1), @datum_dok)
					set @enddate =  DATEADD(dd,-(DAY(DATEADD(mm,1,@datum_dok))),DATEADD(mm,12/@obnaleto,@datum_dok))
				end
				
				update #invoice_data set InvoicePeriodStartDate = @startdate, InvoicePeriodEndDate = @enddate

				if @tip_leas in ('F1', 'ZP')
				begin
					
					/*DODATNI TROŠKOVI NA RAČUNU*/
					--TODO PO FIRMI ZA SADA JE ZAJEDNO GLAVNICA + PPMV
					--set  @xml = (
					--Select AddCostName, AddCostAmount
					--From (
					--	Select 'Obavijest o dospijeću glavnice' as AddCostName,
					--	sneto + SROBRESTI as AddCostAmount
					--	From #najem_fa 
					--	where ddv_id = @id
					--) a
					--FOR XML PATH ('InvoiceAddCost'), ROOT('ArrayOfInvoiceAddCost')  )
			
					--set @addCostXml = cast(@xml as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						'Kamata u okviru ' + rtrim(cast(b.zap_obr as varchar(10))) + '. rate' as LineDesc,  --TODO AKO JE UBLEN MOŽE SE STAVITI I PERIOD U OPIS STAVKE
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.rac_out_debit_neto + b.rac_out_brez_davka as LineNetPrice, 
						b.rac_out_debit_neto + b.rac_out_brez_davka as LineNetTotal,
						c.davek as LineTaxRate,
						b.rac_out_debit_davek as LineTaxAmount,
						b.rac_out_debit as LineAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName
						From #najem_fa b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st 
						left join dbo.pogodba p on b.id_cont = p.id_cont
						left join dbo.OBDOBJA o on p.ID_OBD = o.id_obd
						where b.ddv_id = @id  
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						b.rac_out_debit_neto + b.rac_out_brez_davka as TaxBase,
						b.rac_out_debit_davek as TaxAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as TaxNote
						From #najem_fa b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						where b.ddv_id = @id  
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))
				end

				if @tip_leas in ('OL','OZ')
				begin 
					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						rtrim(cast(b.zap_obr as varchar(10))) + '. Obrok za razdoblje' as LineDesc, 
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.rac_out_debit_neto as LineNetPrice, 
						b.rac_out_debit_neto as LineNetTotal,
						c.davek as LineTaxRate,
						b.rac_out_debit_davek as LineTaxAmount,
						b.rac_out_debit_neto + b.rac_out_debit_davek as LineAmount,
						'' as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName
						From #najem_fa b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						left join dbo.pogodba p on b.ID_CONT = p.ID_CONT
						left join dbo.OBDOBJA o on p.ID_OBD = o.id_obd
						where b.ddv_id = @id  
							union all
						Select @id_terj +'-PPMV' as LineItemIdent, 
						'Posebni porez na motorna vozila (prolazna stavka)' as LineDesc, 
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.rac_out_neobdav as LineNetPrice, 
						b.rac_out_neobdav as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						b.rac_out_neobdav as LineAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'NO' as LineTaxName
						From #najem_fa b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						left join dbo.pogodba p on b.ID_CONT = p.ID_CONT
						left join dbo.OBDOBJA o on p.ID_OBD = o.id_obd
						where b.ddv_id = @id and b.rac_out_neobdav > 0
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						b.rac_out_debit_neto as TaxBase,
						b.rac_out_debit_davek as TaxAmount,
						'' as TaxNote
						From #najem_fa b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						where b.ddv_id = @id  
						union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						b.rac_out_neobdav as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #najem_fa b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						where b.ddv_id = @id and b.rac_out_neobdav <> 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))
				end
			end

			--INTERKALARNE IZ MODULA
			if @id_terj != '21' 
			begin
				
				update #invoice_data set 
				InvoiceDate = b.datum_dok, 
				InvoiceDeliveryDate = b.datum_dok, 
				InvoiceDueDate = b.dat_zap, 
				InvoicePaymentDesc = 'Plaćanje ' + RTRIM(a.opisdok), --TODO PREMA ISPISU
				--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)),  --TODO PREMA ISPISU
				InvoiceTotalNetAmount = b.rac_out_debit_neto + b.rac_out_brez_davka + b.rac_out_neobdav,  
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit + b.rac_out_neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = b.rac_out_debit + rac_out_neobdav ,
				InvoiceNote = CASE WHEN g.saldo = 0 AND (c.sif_terj='MSTR' or c.sif_terj='POLO') THEN 'GORE NAVEDENI IZNOS JE VEĆ PODMIREN.' ELSE '' END,
				InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. Kod zakašnjenja plaćanja zaračunavamo zakonsku zateznu kamatu.' + case when b.id_tec <> '000' then ' Nakon datuma dospijeća u obvezi ste platiti iznos u valuti koristeći ' + rtrim(b.naz_tec)+' na dan uplate. Informacije o tečaju na dan uplate možete saznati putem info telefona RBA broj 062 / 62 62 62 ili na www.rba.hr.' else '' end
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				inner join dbo.VRST_TER c on b.ID_TERJ = c.id_terj 
				LEFT JOIN dbo.planp g on b.id_cont = g.id_cont AND b.st_dok = g.st_dok
				--left join dbo.general_register grp on grp.id_register = 'REPORT_SIGNATORY' and grp.id_key = case when c.sif_terj = 'MSTR' then 'FAK_LOBR_MSTR' 
				--																				when c.sif_terj = 'SFIN' then 'FAK_LOBR_SFIN'
				--																				when c.sif_terj = 'POLO' then 'FAK_LOBR_POLO'
				--																				else 'FAK_LOBR' end and grp.neaktiven = 0

					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						RTRIM(case 
								 when @tip_leas = 'OL' AND d.sif_terj = 'SFIN' then 'Naknada za korištena sredstava'
								 when @tip_leas = 'F1' AND d.sif_terj = 'SFIN' then 'Interkalarna kamata'
								 when @tip_leas = 'OL' AND d.sif_terj = 'POLO' then 'Posebna najamnina'
								 else d.naziv
							end) as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.rac_out_debit_neto as LineNetPrice, 
						b.rac_out_debit_neto as LineNetTotal,
						c.davek as LineTaxRate,
						b.rac_out_debit_davek as LineTaxAmount,
						b.rac_out_debit_neto + b.rac_out_debit_davek as LineAmount,
						'' as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName
						From #najem_fa b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						inner join dbo.vrst_ter d on b.ID_TERJ = d.id_terj
						where b.ddv_id = @id and b.rac_out_debit_neto > 0
							union all
						Select @id_terj as LineItemIdent, 
						RTRIM(case 
								 when @tip_leas = 'OL' AND d.sif_terj = 'SFIN' then 'Naknada za korištena sredstava'
								 when @tip_leas = 'F1' AND d.sif_terj = 'SFIN' then 'Interkalarna kamata'
								 when @tip_leas = 'OL' AND d.sif_terj = 'POLO' then 'Posebna najamnina'
								 else d.naziv
							end) as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.rac_out_brez_davka as LineNetPrice, 
						b.rac_out_brez_davka as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						b.rac_out_brez_davka as LineAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'OP' as LineTaxName
						From #najem_fa b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						inner join dbo.vrst_ter d on b.ID_TERJ = d.id_terj
						where b.ddv_id = @id and b.rac_out_brez_davka > 0
							union all
						Select @id_terj as LineItemIdent, 
						case when d.ima_robresti = 1 then 'Posebni porez na motorna vozila (prolazna stavka)' 
							else RTRIM(case 
								 when @tip_leas = 'OL' AND d.sif_terj = 'SFIN' then 'Naknada za korištena sredstava'
								 when @tip_leas = 'F1' AND d.sif_terj = 'SFIN' then 'Interkalarna kamata'
								 when @tip_leas = 'OL' AND d.sif_terj = 'POLO' then 'Posebna najamnina'
								 else d.naziv
							end) 
						end as LineDesc, 
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.rac_out_neobdav as LineNetPrice, 
						b.rac_out_neobdav as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						b.rac_out_neobdav as LineAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'NO' as LineTaxName
						From #najem_fa b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						inner join dbo.vrst_ter d on b.ID_TERJ = d.id_terj
						where b.ddv_id = @id and b.rac_out_neobdav > 0
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						b.rac_out_debit_neto as TaxBase,
						b.rac_out_debit_davek as TaxAmount,
						'' as TaxNote
						From #najem_fa b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						where b.ddv_id = @id  and b.rac_out_debit_neto > 0
						 union all
						Select 
						'OP' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						b.rac_out_brez_davka as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #najem_fa b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st 
						inner join dbo.vrst_ter d on b.ID_TERJ = d.id_terj
						where b.ddv_id = @id and b.rac_out_brez_davka > 0
						 union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						b.rac_out_neobdav as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #najem_fa b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st 
						inner join dbo.vrst_ter d on b.ID_TERJ = d.id_terj
						where b.ddv_id = @id and b.rac_out_neobdav > 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))

					--TODO provjeriti na ispisu kako ispisuju period interkalarnih kamata
					if @id_terj = @int_kamate and isnull(@int_kamate, '') <> ''
					begin 
						update #invoice_data 
							set InvoicePeriodStartDate = c.dat_od, InvoicePeriodEndDate = c.dat_do
						From #invoice_data a
						inner join #najem_fa b on a.DDV_ID = b.DDV_ID
						inner join dbo.gen_interkalarne_obr_child c on b.ST_DOK = c.st_dok
						where a.DDV_ID = @id and c.dat_do is not null and c.dat_od is not null
					end
			end

			drop table #najem_fa
		end

		if @source = 'POGODBA'
		begin

				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.DDV_DATE, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
				--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)), --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.neobdav,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = 'Objekt leasinga ostaje u vlasništvu ' + rtrim(@p_podjetje) + ' do konačne otplate svih obveza po Ugovoru o leasingu broj ' + rtrim(b.id_pog) + '. O izvršenoj otplati objekta leasinga, ' + rtrim(@p_podjetje) + ' izdat će posebno Ovlaštenje s dozvolom prijenosa prava vlasništva na ime kupca.' ,
				InvoicePaymentNote = 'Plaćanje ovog računa je sukcesivno u skladu sa otplatnim planom koji je sastavni dio ugovora o financijskom leasingu broj ' + rtrim(b.id_pog) + '.'
				From #invoice_data a
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				--LEFT JOIN dbo.general_register grp ON grp.id_register = 'REPORT_SIGNATORY' AND grp.id_key = 'KK_FAKT'
				--TODO provjeriti zbog opcije reprogram zbog ponovljene aktivacije polja datume i ddv_id
				--join sa id_cont bi trebao riješti problem
					
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 
						'AKTIVAC' as LineItemIdent,
						RTRIM(b.pred_naj) as LineDesc,  --TODO AKO TREBA DODATI POJEDINOSTI IZ ZAPISNIKA O VOZILU/PLOVILO/OPREMA SAMO ZA UblEN, ZA SAD SAMO IZ PRILOGA
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.debit_neto + a.BREZ_DAVKA as LineNetPrice, 
						a.debit_neto + a.BREZ_DAVKA as LineNetTotal,
						c.davek as LineTaxRate,
						a.debit_davek as LineTaxAmount,
						a.debit as LineAmount, 
						case when a.NEOBDAV > 0 then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName
						From #invoice_data a
						inner join dbo.pogodba b on a.id_cont = b.id_cont and a.ddv_id = b.ddv_id
						inner join dbo.dav_stop c on b.id_dav_op = c.id_dav_st
							UNION ALL
						Select 
						'PPMV' as LineItemIdent,
						'Poseban porez na motorna vozila (prolazna stavka)' as LineDesc,  
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.NEOBDAV as LineNetPrice, 
						a.NEOBDAV as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2)) as LineTaxAmount,
						a.NEOBDAV as LineAmount, 
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote,
						'NO' as LineTaxName
						From #invoice_data a
						inner join dbo.pogodba b on a.id_cont = b.id_cont and a.ddv_id = b.ddv_id
						inner join dbo.dav_stop c on b.id_dav_op = c.id_dav_st
						where a.NEOBDAV > 0
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					select  @xml =
					 (
						Select TaxName, TaxRate,
						TaxBase,
						TaxAmount ,
						TaxNote 
						From (
							Select 
							rtrim(c.opis_tuj1) as TaxName,
							c.davek as TaxRate,
							a.debit_neto + a.BREZ_DAVKA + case when a.NEOBDAV > 0 and rtrim(c.opis_tuj1) = 'NO' then a.neobdav else 0 end as TaxBase,
							a.debit_davek as TaxAmount,
							case when a.NEOBDAV > 0  and rtrim(c.opis_tuj1) != 'NO' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as TaxNote
							From #invoice_data a
							inner join dbo.pogodba b on a.id_cont = b.id_cont and a.ddv_id = b.ddv_id
							inner join dbo.dav_stop c on b.id_dav_op = c.id_dav_st
								union all
							Select 
							'NO' as TaxName,
							cast(0 as decimal(18,2)) as TaxRate,
							a.NEOBDAV as TaxBase,
							cast(0 as decimal(18,2)) as TaxAmount,
							rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote
							From #invoice_data a
							inner join dbo.pogodba b on a.id_cont = b.id_cont and a.ddv_id = b.ddv_id
							inner join dbo.dav_stop c on b.id_dav_op = c.id_dav_st
							where a.NEOBDAV > 0 and rtrim(c.opis_tuj1) != 'NO'
						) a
						FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate')
					)
			
					set @taxTotalXml = cast(@xml as varchar(max))

					/*REFERENCE*/
					--OVO SE NE DIRA
					set @xml = (Select ReferenceId, ReferenceIssueDate
									From (
										select dbo.gfn_TransformDDV_ID_HR(r.ddv_id, r.DDV_DATE) as ReferenceId, r.dat_vnosa as ReferenceIssueDate, r.id_cont, r.SIF_RAC, p.DDV_ID
										from dbo.pogodba p 
										inner join dbo.rac_out r on p.id_cont = r.id_cont and charindex(rtrim(r.ddv_id), p.kk_memo) != 0 
										where p.ddv_id = @id and r.SIF_RAC = 'AVA'
									) a
									FOR XML PATH ('InvoiceReference'), ROOT('ArrayOfInvoiceReference')
								)

					set @referencesXml = cast(@xml as varchar(max))

		end

		if @source = 'AVANSI'
		begin
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.DDV_DATE, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
				--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)), --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit,
				InvoiceType = '386',
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = 'Temeljem primljene uplate od ' + isnull(convert(varchar(10), c.dat_pl, 104),'') + ', ispostavljamo ovaj račun za predujam za Vašu knjigovodstvenu evidenciju.' ,
				InvoicePaymentNote = '' -- TODO PO FIRMAMA, ALI KOD AVANSA NEMA PLAĆANJA
				From #invoice_data a 
				left join dbo.avansi av on a.ddv_id = av.ddv_id
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				left join dbo.placila c on av.id_plac = c.id_plac 
				--LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = 'FAK_AVAN' AND gr.neaktiven = 0
				
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 
						'PREDUJAM' as LineItemIdent,
						'Predujam' as LineDesc,  --TODO podesiti po firmama
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.debit_neto + a.BREZ_DAVKA as LineNetPrice, 
						a.debit_neto + a.BREZ_DAVKA as LineNetTotal,
						c.davek as LineTaxRate,
						a.debit_davek as LineTaxAmount,
						a.debit + a.neobdav as LineAmount, 
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						rtrim(c.opis_tuj1) as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					select  @xml =
					 (
						Select TaxName, TaxRate,
						TaxBase,
						TaxAmount ,
						TaxNote 
						From (
							Select 
							rtrim(c.opis_tuj1) as TaxName,
							c.davek as TaxRate,
							a.debit_neto + a.BREZ_DAVKA as TaxBase,
							a.debit_davek as TaxAmount,
							rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote
							From #invoice_data a
							inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						) a
						FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate')
					)
			
					set @taxTotalXml = cast(@xml as varchar(max))

		end

		if @source = 'SPR_DDV'
		begin
				
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.DDV_DATE, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
				--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)), --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.BREZ_DAVKA + a.neobdav) else (a.debit_neto + a.BREZ_DAVKA + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om
				InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
				InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav) else (a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om,
				--PRIJE PROMJENE DA SVE MORA BITI NEGATIVNO DA BI BIO CREDIT NOTE 
				--InvoiceType = case when (a.DEBIT + a.BREZ_DAVKA) < 0 or ((a.DEBIT + a.BREZ_DAVKA) = 0 and a.NEOBDAV < 0) then '381' else '383' end,
				InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else '383' end,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'MOLIMO POTVRDITE ISPRAVAK PRETPOREZA POVRATOM OVJERENE KOPIJE STORNA (sukladno čl. 33 stavak 7. Zakona o porezu na dodanu vrijednost) !'
								else 'Plaćanje ovog računa je sukcesivno u skladu sa otplatnim planom koji je sastavni dio ugovora o ' + case when dbo.gfn_Nacin_leas_HR(b.nacin_leas) = 'OL' then 'operativnom' else 'financijskom' end + ' leasingu broj '+ rtrim(b.id_pog) +'.' end,
				InvoicePaymentNote = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'Ispravak promjene porezne osnove temeljem ovjere! (U slučaju da niste primili dokument za ovjeru, molimo da ispravak porezne osnove potvrdite ovjerom ovog računa)'
								else CASE WHEN dbo.gfn_Nacin_leas_HR(b.nacin_leas) != 'F1' AND c.vrsta_rac='RPG' THEN 'Molimo Vas da uplatite samo iznos PDV-a.' ELSE '' END end, --TODO podesiti sukladno odobrenje/terećenje
				document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end
				From #invoice_data a
				inner join 
					(Select id_cont, id_pog, nacin_leas from dbo.pogodba
					UNION 
					Select id_cont, id_pog, nacin_leas from dbo.POGODBA_DELETED) b on a.id_cont = b.id_cont 
				--LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = case when a.debit_davek < 0 OR (a.debit_davek = 0 AND (a.debit+a.neobdav) < 0) then 'SPR_DBRP' else 'SPR_ZVEC' end AND grp.neaktiven = 0
				left join dbo.spr_ddv c on a.ddv_id = c.ddv_id

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 'IDPP' as LineItemIdent, --TODO 
						a.OPISDOK as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then cast(1 as decimal(18,2)) else cast(-1 as decimal(18,2)) end as LineQuantity,
						abs(a.debit_neto) as LineNetPrice, 
						abs(a.debit_neto) as LineNetTotal,
						c.davek as LineTaxRate,
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_davek) else a.debit_davek end as LineTaxAmount,
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_neto + a.debit_davek) else a.debit_neto + a.debit_davek end as LineAmount,
						'' as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.debit_neto <> 0
							union all
						Select 'IDPO' as LineItemIdent, --TODO
						a.OPISDOK as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.brez_davka > 0 then cast(1 as decimal(18,2)) else cast(-1 as decimal(18,2)) end as LineQuantity,
						abs(a.brez_davka) as LineNetPrice, 
						abs(a.brez_davka) as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.brez_davka > 0 then abs(a.brez_davka) else a.brez_davka end as LineAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'OP' as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.brez_davka <> 0
							union all
						Select 'IDPN' as LineItemIdent,  --TODO 
						a.OPISDOK as LineDesc, --TODO
						'H87' as LineQuantityUnit, 
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then cast(1 as decimal(18,2)) else cast(-1 as decimal(18,2)) end as LineQuantity,
						abs(a.neobdav) as LineNetPrice, 
						abs(a.neobdav) as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then abs(a.neobdav) else a.neobdav end as LineAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'NO' as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.neobdav <> 0
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_neto) else a.debit_neto end as TaxBase,
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_davek) else a.debit_davek end as TaxAmount,
						'' as TaxNote
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.debit_neto <> 0
						 union all
						Select 
						'OP' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.brez_davka > 0 then abs(a.brez_davka) else a.brez_davka end as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.brez_davka <> 0
						 union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then abs(a.neobdav) else a.neobdav end as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.neobdav <> 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))

					/*REFERENCE*/
					--OVO SE NE DIRA
					set @xml = (Select ReferenceId, ReferenceIssueDate
									From (
										select dbo.gfn_TransformDDV_ID_HR(r.ddv_id, r.DDV_DATE) as ReferenceId, r.dat_vnosa as ReferenceIssueDate, r.id_cont, r.SIF_RAC, p.DDV_ID
										from dbo.spr_ddv p 
										inner join dbo.rac_out r on p.old_ddv_id = r.ddv_id 
										where p.ddv_id = @id
									) a
									FOR XML PATH ('InvoiceReference'), ROOT('ArrayOfInvoiceReference')
								)

					set @referencesXml = cast(@xml as varchar(max))

		end

		-- ISPIS NIJE PODEŠEN U report_edoc_settings kao račun
		if @source = 'REP_IND'
		begin
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.DDV_DATE, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
				--InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav, 
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.neobdav, 
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = '',
				InvoicePaymentNote = '' --TODO podesiti sukladno odobrenje/terećenje
				From #invoice_data a
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 'IDXP' as LineItemIdent, --TODO 
						s.OPISDOK as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.debit_neto as LineNetPrice, 
						a.debit_neto as LineNetTotal,
						c.davek as LineTaxRate,
						a.debit_davek as LineTaxAmount,
						a.debit_neto + a.debit_davek as LineAmount,
						'' as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName
						From #invoice_data a
						inner join dbo.REP_IND s on a.ddv_id = s.ddv_id
						inner join dbo.dav_stop c on s.id_dav_st = c.id_dav_st
						where a.debit_neto <> 0
							union all
						Select 'IDXO' as LineItemIdent, --TODO
						s.OPISDOK as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.brez_davka as LineNetPrice, 
						a.brez_davka as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						a.brez_davka as LineAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'OP' as LineTaxName
						From #invoice_data a
						inner join dbo.REP_IND s on a.ddv_id = s.ddv_id
						inner join dbo.dav_stop c on s.id_dav_st = c.id_dav_st
						where a.brez_davka <> 0
							union all
						Select 'IDXN' as LineItemIdent,  --TODO 
						s.OPISDOK as LineDesc, --TODO
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.neobdav as LineNetPrice, 
						a.neobdav as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						a.neobdav as LineAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'NO' as LineTaxName
						From #invoice_data a
						inner join dbo.REP_IND s on a.ddv_id = s.ddv_id
						inner join dbo.dav_stop c on s.id_dav_st = c.id_dav_st
						where a.neobdav <> 0
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						a.debit_neto as TaxBase,
						a.debit_davek as TaxAmount,
						'' as TaxNote
						From #invoice_data a
						inner join dbo.REP_IND s on a.ddv_id = s.ddv_id
						inner join dbo.dav_stop c on s.id_dav_st = c.id_dav_st
						where a.debit_neto <> 0
						 union all
						Select 
						'OP' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.brez_davka as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.REP_IND s on a.ddv_id = s.ddv_id
						inner join dbo.dav_stop c on s.id_dav_st = c.id_dav_st
						where a.brez_davka <> 0
						 union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.neobdav as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.REP_IND s on a.ddv_id = s.ddv_id
						inner join dbo.dav_stop c on s.id_dav_st = c.id_dav_st
						where a.neobdav <> 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))

					/*REFERENCE*/
					--OVO SE NE DIRA
					set @xml = (Select ReferenceId, ReferenceIssueDate
									From (
										select dbo.gfn_TransformDDV_ID_HR(r.ddv_id, r.DDV_DATE) as ReferenceId, r.dat_vnosa as ReferenceIssueDate, r.id_cont, r.SIF_RAC, p.DDV_ID
										from dbo.rep_ind p 
										inner join dbo.rac_out r on p.old_ddv_id = r.ddv_id 
										where p.ddv_id = @id
									) a
									FOR XML PATH ('InvoiceReference'), ROOT('ArrayOfInvoiceReference')
								)

					set @referencesXml = cast(@xml as varchar(max))

		end

		if @source = 'ZOBR_FA'
		begin
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = z.dat_zap, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
				--InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = 'Dana '+ isnull(convert(varchar(10), z.datum_dok, 104),'') +' obračunali smo zatezne kamate.' ,
				InvoicePaymentNote = '' -- TODO PO FIRMAMA
				From #invoice_data a 
				inner join dbo.ZOBR_FA z on a.ddv_id = z.ddv_id
				inner join dbo.pogodba b on a.id_cont = b.id_cont
					
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 'ZOBP' as LineItemIdent, 
						'Zatezna kamata' as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.debit_neto as LineNetPrice, 
						a.debit_neto as LineNetTotal,
						c.davek as LineTaxRate,
						a.debit_davek as LineTaxAmount,
						a.debit_neto + a.debit_davek as LineAmount,
						'' as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.debit_neto > 0
							union all
						Select 'ZOBO' as LineItemIdent, 
						'Zatezna kamata' as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.brez_davka as LineNetPrice, 
						a.brez_davka as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						a.brez_davka as LineAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'OP' as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.brez_davka > 0
							union all
						Select 'ZOBN' as LineItemIdent, 
						'Zatezna kamata' as LineDesc, 
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.neobdav as LineNetPrice, 
						a.neobdav as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						a.neobdav as LineAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'NO' as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.neobdav > 0
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						a.debit_neto as TaxBase,
						a.debit_davek as TaxAmount,
						'' as TaxNote
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.debit_neto > 0
						 union all
						Select 
						'OP' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.brez_davka as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.brez_davka > 0
						 union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.neobdav as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.neobdav > 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))
		end

		
		if @source IN ('ZA_OPOM', 'DOK_OPOM')
		begin
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.valuta, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentId = 'HR01 '+ b.sklic, --TODO provjeriti na ispisu zbog trećih osoba
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO NAPUNITI TEKST
				--InvoicePersonIssued = case when @source = 'DOK_OPOM' then rtrim(a.izdal) else rtrim(isnull(gr.value, a.izdal)) end, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = CASE WHEN z.st_opomina in (1, 2) THEN 'Ukoliko je gore navedeni iznos u međuvremenu podmiren, molimo da nam javite datum uplate ili pošaljete kopiju potvrde plaćanja. Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.'
									WHEN z.st_opomina = 3 THEN 'Ukoliko je gore navedeni iznos u međuvremenu podmiren, molimo da nam javite datum uplate ili pošaljete kopiju potvrde plaćanja. Ukoliko ne postupite u skladu s ovom opomenom predmetni će se ugovor smatrati raskinutim, sva potraživanja učinjena dospjelim, te ćemo naplatu izvršiti prisilnim putem.'
									when x.st_opomin is not null then 'Obavještavamo Vas da po Ugovoru ' + rtrim(b.id_pog) + ', unatoč već poslanim obavijestima, do sada nismo zaprimili neophodnu dokumentaciju.'
																	  + ' Po primitku ove obavijesti dužni ste podmiriti trošak opomene i u roku od 10 dana dostaviti neophodnu dokumentaciju, zaključno do datuma dospjeća naznačenoga na ovom računu.'
																	  + 'U protivnom, ' + rtrim(@p_podjetje) + ' bit će prisiljen pokrenuti daljnje korake sa ciljem zaštite ugovornih prava, a na teret i trošak Primatelja leasinga.'
							 END				 ,
				InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate.' -- TODO PO FIRMAMA
				From #invoice_data a 
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				left join dbo.za_opom z on a.DDV_ID = z.ddv_id
				left join (Select ddv_id, st_opomin From dbo.dok_opom group by ddv_id, st_opomin) x on a.ddv_id = x.ddv_id
				--LEFT JOIN dbo.GENERAL_REGISTER gr ON gr.ID_REGISTER = 'REPORT_SIGNATORY' and gr.id_key = 'OPOMIN' AND gr.neaktiven = 0

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 'OPMP' as LineItemIdent, 
						rtrim(a.OPISDOK) as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.debit_neto as LineNetPrice, 
						a.debit_neto as LineNetTotal,
						c.davek as LineTaxRate,
						a.debit_davek as LineTaxAmount,
						a.debit_neto + a.debit_davek as LineAmount,
						'' as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.debit_neto > 0
							union all
						Select 'OPMO' as LineItemIdent, 
						rtrim(a.OPISDOK) as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.brez_davka as LineNetPrice, 
						a.brez_davka as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						a.brez_davka as LineAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'OP' as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.brez_davka > 0
							union all
						Select 'OPMN' as LineItemIdent, 
						rtrim(a.OPISDOK) as LineDesc, 
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						a.neobdav as LineNetPrice, 
						a.neobdav as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						a.neobdav as LineAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'NO' as LineTaxName
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.neobdav > 0
					) a
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						a.debit_neto as TaxBase,
						a.debit_davek as TaxAmount,
						'' as TaxNote
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.debit_neto > 0
						 union all
						Select 
						'OP' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.brez_davka as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.brez_davka > 0
						 union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.neobdav as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.neobdav > 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))
		end

		if @source = 'OPC_FAKT'
		begin

			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = c.DAT_ZAP, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentId = 'HR01 '+ ('998' + c.id_kupca + rtrim(b.id_sklic)) +
				dbo.gfn_CalculateControlDigit('998' + c.id_kupca + rtrim(b.id_sklic)), --TODO popraviti id_p1 prema ispisu
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)), --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.neobdav,
			InvoiceNote = rtrim(isnull(c.opombe, '')), --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO 
			InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate.' --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO
			From #invoice_data a
			inner join dbo.pogodba b on a.id_cont = b.id_cont 
			inner join dbo.OPC_FAKT c on a.DDV_ID = c.DDV_ID
			left join dbo.tecajnic t on c.id_tec = t.id_tec
			--LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = 'OPC_FAK' AND grp.neaktiven = 0
					
				/*STAVKE*/
				set  @xml = (
				Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
				LineAmount,LineTaxNote,LineTaxName
				From (
					Select 
					'OPCP' as LineItemIdent,
					rtrim(p.PRED_NAJ) as LineDesc,  --TODO prema ispisu
					'H87' as LineQuantityUnit, 
					cast(1 as decimal(18,2)) as LineQuantity,
					a.debit_neto + a.BREZ_DAVKA as LineNetPrice, 
					a.debit_neto + a.BREZ_DAVKA as LineNetTotal,
					c.davek as LineTaxRate,
					a.debit_davek as LineTaxAmount,
					a.debit as LineAmount, 
					case when a.NEOBDAV > 0 then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					rtrim(c.opis_tuj1) as LineTaxName
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join dbo.pogodba p on a.id_cont = p.id_cont 
						UNION ALL
					Select 
					'OPCN' as LineItemIdent,
					'Posebni porez na motorna vozila (prolazna stavka)' as LineDesc,  
					'H87' as LineQuantityUnit, 
					cast(1 as decimal(18,2)) as LineQuantity,
					a.NEOBDAV as LineNetPrice, 
					a.NEOBDAV as LineNetTotal,
					cast(0 as decimal(18,2)) as LineTaxRate,
					cast(0 as decimal(18,2)) as LineTaxAmount,
					a.NEOBDAV as LineAmount, 
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote,
					'NO' as LineTaxName
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.NEOBDAV > 0
				) a
				FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

				set @invoiceLineXml = cast(@xml as varchar(max))

				/*POREZI*/
				select  @xml =
					(
					Select TaxName, TaxRate,
					TaxBase,
					TaxAmount ,
					TaxNote 
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						a.debit_neto + a.BREZ_DAVKA as TaxBase,
						a.debit_davek as TaxAmount,
						case when a.NEOBDAV > 0 then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as TaxNote
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
							union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.NEOBDAV as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.NEOBDAV > 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate')
				)
			
				set @taxTotalXml = cast(@xml as varchar(max))
		end

		/*NIJE PODEŠEN U EDOC-u, NEMAJU ISPIS*/
		if @source = 'ZA_REGIS'
		begin

			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = a.VALUTA, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			--InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.neobdav,
			InvoiceNote = '' --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO 
			From #invoice_data a
			
			select top 1 * 
			into #vrst_ter 
			From dbo.vrst_ter 
			Where sif_terj = 'REG'
			
			Select * 
			into #za_regis 
			From dbo.za_regis 
			where DDV_ID = @id
					
			Select top 1 ddv_id, dav_n, dav_o, dav_m, dav_r, dav_b 
			into #planp 
			From dbo.planp 
			where DDV_ID = @id
					
				/*STAVKE*/
				set  @xml = (
				Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
				LineAmount,LineTaxNote,LineTaxName
				From (
					Select 
					'TEHP' as LineItemIdent, 'Tehnički pregled' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.teh_p as LineNetPrice, b.teh_p as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.teh_p * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.teh_p * (1 + (c.davek/100)),2) else b.teh_p end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1 
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.teh_p > 0
						UNION ALL
					Select 
					'CEST' as LineItemIdent, 'Cestarina' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.cest as LineNetPrice, b.cest as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.cest * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.cest * (1 + (c.davek/100)),2) else b.cest end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.cest > 0
						UNION ALL
					Select 
					'REGIST' as LineItemIdent, 'Registracija' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.regist as LineNetPrice, b.regist as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.regist * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.regist * (1 + (c.davek/100)),2) else b.regist end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.regist > 0
						UNION ALL				
					Select 
					'PROMDOV' as LineItemIdent, 'Prometna dozvola' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.prom_dov as LineNetPrice, b.prom_dov as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.prom_dov * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.prom_dov * (1 + (c.davek/100)),2) else b.prom_dov end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.prom_dov > 0
						UNION ALL			
					Select 
					'REGTABL' as LineItemIdent, 'Registarske tablice' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.reg_tabl as LineNetPrice, b.reg_tabl as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.reg_tabl * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.reg_tabl * (1 + (c.davek/100)),2) else b.reg_tabl end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.reg_tabl > 0
						UNION ALL		
					Select 
					'EKOT' as LineItemIdent, 'EKO test' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.taksa as LineNetPrice, b.taksa as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.taksa * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.taksa * (1 + (c.davek/100)),2) else b.taksa end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.taksa > 0
						UNION ALL	
					Select 
					'TISK' as LineItemIdent, 'Tiskanica' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.tiskovina as LineNetPrice, b.tiskovina as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.tiskovina * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.tiskovina * (1 + (c.davek/100)),2) else b.tiskovina end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.tiskovina > 0
						UNION ALL		
					Select 
					'DODOPR' as LineItemIdent, 'Dodatna oprema' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.strosek3 as LineNetPrice, b.strosek3 as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.strosek3 * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.strosek3 * (1 + (c.davek/100)),2) else b.strosek3 end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.strosek3 > 0
						UNION ALL	
					Select 
					'NAOKOL' as LineItemIdent, 'Posebna naknada za okoliš' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.strosek1 as LineNetPrice, b.strosek1 as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.strosek1 * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.strosek1 * (1 + (c.davek/100)),2) else b.strosek1 end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.strosek1 > 0
						UNION ALL	
					Select 
					'PROMDOZ' as LineItemIdent, 'Produženje prom. dozvole' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.strosek2 as LineNetPrice, b.strosek2 as LineNetTotal,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.strosek2 * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then round(b.strosek2 * (1 + (c.davek/100)),2) else b.strosek2 end as LineAmount, 
					case when isnull(pl.dav_r, v.dav_r) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_r, v.dav_r) = 'D' then 'PDV' 
						when isnull(pl.dav_r, v.dav_r) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.strosek2 > 0
						UNION ALL		
					Select 
					'USL' as LineItemIdent, 'Administrativna naknada' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.usluga as LineNetPrice, b.usluga as LineNetTotal,
					case when isnull(pl.dav_m, v.dav_m) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_m, v.dav_m) = 'D' then round(b.usluga * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_m, v.dav_m) = 'D' then round(b.usluga * (1 + (c.davek/100)),2) else b.usluga end as LineAmount, 
					case when isnull(pl.dav_m, v.dav_m) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_m, v.dav_m) = 'D' then 'PDV' 
						when isnull(pl.dav_m, v.dav_m) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.usluga > 0
						UNION ALL			
					Select 
					'OST' as LineItemIdent, 'Ostalo' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.ostalo as LineNetPrice, b.ostalo as LineNetTotal,
					case when isnull(pl.dav_m, v.dav_m) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_m, v.dav_m) = 'D' then round(b.ostalo * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_m, v.dav_m) = 'D' then round(b.ostalo * (1 + (c.davek/100)),2) else b.ostalo end as LineAmount, 
					case when isnull(pl.dav_m, v.dav_m) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_m, v.dav_m) = 'D' then 'PDV' 
						when isnull(pl.dav_m, v.dav_m) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.ostalo > 0
						UNION ALL				
					Select 
					'PREM' as LineItemIdent, 'Osiguranje' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
					b.pp_neto as LineNetPrice, b.pp_neto as LineNetTotal,
					case when isnull(pl.dav_n, v.dav_n) = 'D' then c.davek else 0 end as LineTaxRate,
					case when isnull(pl.dav_n, v.dav_n) = 'D' then round(b.pp_neto * (c.davek/100),2) else 0 end as LineTaxAmount,
					case when isnull(pl.dav_n, v.dav_n) = 'D' then round(b.pp_neto * (1 + (c.davek/100)),2) else b.pp_neto end as LineAmount, 
					case when isnull(pl.dav_n, v.dav_n) = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when isnull(pl.dav_n, v.dav_n) = 'D' then 'PDV' 
						when isnull(pl.dav_n, v.dav_n) = 'O' then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join #za_regis b on a.ddv_id = b.ddv_id
					inner join #vrst_ter v on 1 = 1
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					left join #planp pl on 1 = 1 
					where b.pp_neto > 0																																																								
				) a
				FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

				set @invoiceLineXml = cast(@xml as varchar(max))

				/*POREZI*/
				select  @xml =
					(
					Select TaxName, TaxRate,
					TaxBase,
					TaxAmount ,
					TaxNote 
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						a.debit_neto as TaxBase,
						a.debit_davek as TaxAmount,
						'' as TaxNote
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.debit_neto <> 0
						 union all
						Select 
						'OP' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.brez_davka as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.brez_davka <> 0
						 union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						a.neobdav as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From #invoice_data a
						inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
						where a.neobdav <> 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate')
				)
			
				set @taxTotalXml = cast(@xml as varchar(max))

				drop table #vrst_ter
				drop table #za_regis
				drop table #planp
		end

		if @source = 'TEC_RAZL'
		begin
			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = a.valuta, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentId = 'HR01 '+ b.sklic, --TODO provjeriti na ispisu zbog trećih osoba
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)), --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.neobdav) else (a.debit_neto + a.brez_davka + a.neobdav) end, 
			InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
			InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.debit_davek + a.neobdav) else (a.debit_neto + a.brez_davka + a.debit_davek + a.neobdav) end,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = '' ,
			InvoicePaymentNote = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '' else 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate.' end, -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end -- TODO AKO JE TEČAJNA NEGATIVNA MORA BITI CREDIT NOTE
			From #invoice_data a 
			inner join dbo.pogodba b on a.id_cont = b.id_cont 
			--LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = 'FAK_TR' AND grp.neaktiven = 0
			/*inner join (select ddv_id, sum(ostalo) as ostalo 
							from dbo.tec_razl 
							group by ddv_id) t on a.ddv_id = t.ddv_id*/

				set @addCostXml = ''
				/*DODATNI TROŠKOVI NA RAČUNU*/
				--TODO PO FIRMI ZA SADA JE ZAJEDNO GLAVNICA + PPMV
				/*set  @xml = (
				Select AddCostName, AddCostAmount
				From (
					Select 'Obavijest o tečajnim razlikama na udio u glavnici:' as AddCostName,
					sum(t.ostalo) as AddCostAmount
					From #invoice_data a 
						inner join dbo.tec_razl t on a.ddv_id = t.ddv_id
						group by t.ddv_id
				) a
				FOR XML PATH ('InvoiceAddCost'), ROOT('ArrayOfInvoiceAddCost')  )
			
				set @addCostXml = cast(@xml as varchar(max))
				*/
				set @addCostXml = ''

				/*STAVKE*/
				set  @xml = (
				Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
				LineAmount,LineTaxNote,LineTaxName
				From (
					Select 'TRAP' as LineItemIdent, 
					rtrim(a.OPISDOK) as LineDesc, --TODO Provjeriti po ispisima
					'H87' as LineQuantityUnit, 
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then cast(1 as decimal(18,2)) else cast(-1 as decimal(18,2)) end as LineQuantity,
					abs(a.debit_neto) as LineNetPrice, 
					abs(a.debit_neto) as LineNetTotal,
					c.davek as LineTaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_davek) else (a.debit_davek) end as LineTaxAmount,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_neto + a.debit_davek) else (a.debit_neto + a.debit_davek) end as LineAmount,
					'' as LineTaxNote,
					rtrim(c.opis_tuj1) as LineTaxName
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.debit_neto <> 0
						union all
					Select 'TRAO' as LineItemIdent, 
					rtrim(a.OPISDOK) as LineDesc, --TODO Provjeriti po ispisima
					'H87' as LineQuantityUnit, 
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.brez_davka > 0 then cast(1 as decimal(18,2)) else cast(-1 as decimal(18,2)) end as LineQuantity,
					abs(a.brez_davka) as LineNetPrice, 
					abs(a.brez_davka) as LineNetTotal,
					cast(0 as decimal(18,2)) as LineTaxRate,
					cast(0 as decimal(18,2))  as LineTaxAmount,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.brez_davka > 0 then abs(a.brez_davka) else a.brez_davka end as LineAmount,
					rtrim('PDV nije obračunat sukladno Čl.40 Zakona o porezu na dodanu vrijednost.') as LineTaxNote, 
					'OP' as LineTaxName
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.brez_davka <> 0
						union all
					Select 'TRAN' as LineItemIdent, 
					rtrim(a.OPISDOK) as LineDesc, 
					'H87' as LineQuantityUnit, 
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then cast(1 as decimal(18,2)) else cast(-1 as decimal(18,2)) end as LineQuantity,
					abs(a.neobdav) as LineNetPrice, 
					abs(a.neobdav) as LineNetTotal,
					cast(0 as decimal(18,2)) as LineTaxRate,
					cast(0 as decimal(18,2))  as LineTaxAmount,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then abs(a.neobdav) else a.neobdav end as LineAmount,
					rtrim('PDV nije obračunat sukladno Čl.40 Zakona o porezu na dodanu vrijednost.') as LineTaxNote, 
					'NO' as LineTaxName
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.neobdav <> 0
				) a
				FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

				set @invoiceLineXml = cast(@xml as varchar(max))

				/*POREZI*/
				set  @xml = (
				Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
				From (
					Select 
					rtrim(c.opis_tuj1) as TaxName,
					c.davek as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_neto) else (a.debit_neto) end as TaxBase,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_davek) else (a.debit_davek) end as TaxAmount,
					'' as TaxNote
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.debit_neto <> 0
						union all
					Select 
					'OP' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.brez_davka > 0 then abs(a.brez_davka) else (a.brez_davka) end as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim('PDV nije obračunat sukladno Čl.40 Zakona o porezu na dodanu vrijednost.') as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.brez_davka <> 0
						union all
					Select 
					'NO' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then abs(a.neobdav) else (a.neobdav) end as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim('PDV nije obračunat sukladno Čl.40 Zakona o porezu na dodanu vrijednost.') as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.neobdav <> 0
				) a
				FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

				set @taxTotalXml = cast(@xml as varchar(max))

				/*REFERENCE*/
				--OVO SE NE DIRA
				set @xml = (Select ReferenceId, ReferenceIssueDate
								From (
									select dbo.gfn_TransformDDV_ID_HR(r.ddv_id, r.DDV_DATE) as ReferenceId, r.dat_vnosa as ReferenceIssueDate
										from #invoice_data a
										inner join dbo.tec_razl t on a.ddv_id = t.ddv_id
										inner join dbo.planp pl on t.id_cont = pl.id_cont and t.st_dok = pl.st_dok 
										inner join dbo.rac_out r on pl.ddv_id = r.ddv_id
										/*union all
									select dbo.gfn_TransformDDV_ID_HR(r.ddv_id, r.DDV_DATE) as ReferenceId, r.dat_vnosa as ReferenceIssueDate
										from #invoice_data a
										inner join (select id_cont, ddv_id from dbo.tec_razl where ostalo <> 0 group by id_cont, ddv_id) t on a.ddv_id = t.ddv_id
										inner join dbo.pogodba p on t.id_cont = p.id_cont
										inner join dbo.rac_out r on p.ddv_id = r.ddv_id and r.sif_rac = 'AKT'*/
								) a
								FOR XML PATH ('InvoiceReference'), ROOT('ArrayOfInvoiceReference')
							)

				set @referencesXml = cast(@xml as varchar(max))

		end

		if @source = 'FAKTURE'
		begin
			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = a.valuta, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentId = 'HR01 '+ case when f.id_cont_third_party is null then 
									case when b.id_kupca <> a.id_kupca then '998-' + a.id_kupca + '-' + b.id_sklic + dbo.tfn_GetControlNum('998-' + a.id_kupca + '-' + b.id_sklic) else b.sklic end
								else 
									'999-' + TP_POG.id_kupca + '-' + TP_pog.id_sklic + dbo.tfn_GetControlNum('999-' + TP_pog.id_kupca + '-' + TP_pog.id_sklic)
								end, --TODO provjeriti na ispisu zbog trećih osoba
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)), --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = rtrim(isnull(f.rep,'')) ,
			InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu. Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate.'-- TODO PO FIRMAMA
			From #invoice_data a 
			inner join dbo.pogodba b on a.id_cont = b.id_cont
			inner join dbo.fakture f on a.ddv_id = f.ddv_id
			left join dbo.tecajnic t on f.id_tec = t.id_tec 
			--LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = 'FAKTURE' AND grp.neaktiven = 0
			LEFT JOIN dbo.pogodba TP_pog ON f.id_cont_third_party = TP_pog.id_cont

				/*STAVKE*/
				set  @xml = (
				Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
				LineAmount,LineTaxNote,LineTaxName
				From (
					Select fp.id_post as LineItemIdent, 
					rtrim(fp.opis) as LineDesc, --TODO Provjeriti po ispisima
					'H87' as LineQuantityUnit, 
					cast(1 as decimal(18,2)) as LineQuantity,
					dbo.gfn_Xchange('000', fp.znesek_net + fp.mstr + fp.robresti, f.id_tec, f.datum_dok) as LineNetPrice, 
					dbo.gfn_Xchange('000', fp.znesek_net + fp.mstr + fp.robresti, f.id_tec, f.datum_dok) as LineNetTotal,
					case when fp.dav_tip = 'D' then c.davek else 0 end as LineTaxRate,
					case when fp.dav_tip = 'D' then 
						round(dbo.gfn_Xchange('000', fp.znesek_net + fp.mstr + fp.robresti, f.id_tec, f.datum_dok) * f.proc_dav / 100, 2) 
						else 0 end as LineTaxAmount,
					dbo.gfn_Xchange('000', fp.znesek_net + fp.mstr + fp.robresti, f.id_tec, f.datum_dok) + 
						case when fp.dav_tip = 'D' then round(dbo.gfn_Xchange('000', fp.znesek_net + fp.mstr + fp.robresti, f.id_tec, f.datum_dok) * f.proc_dav / 100, 2) 
						else 0 end
						as LineAmount,
					case when fp.dav_tip = 'D' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when fp.dav_tip = 'N' then 'NO'  
						when fp.dav_tip = 'O' then 'OP' 
						else rtrim(c.opis_tuj1) end as LineTaxName
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					inner join dbo.fakture f on a.ddv_id = f.ddv_id
					inner join dbo.fak_pos fp on f.id_fakt = fp.id_fakt
				) a
				FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

				set @invoiceLineXml = cast(@xml as varchar(max))

				/*POREZI*/
				set  @xml = (
				Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
				From (
					Select 
					rtrim(c.opis_tuj1) as TaxName,
					c.davek as TaxRate,
					a.debit_neto as TaxBase,
					a.debit_davek as TaxAmount,
					'' as TaxNote
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.debit_neto > 0
						union all
					Select 
					'OP' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					a.brez_davka as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.brez_davka > 0
						union all
					Select 
					'NO' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					a.neobdav as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.neobdav > 0
				) a
				FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

				set @taxTotalXml = cast(@xml as varchar(max))

		end

		/*ISPIS NIJE PODEŠEN U EDOC-u*/
		if @source = 'GL_OUTPUT_R'
		begin
			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = a.valuta, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentId = 'HR01 '+ b.sklic, --TODO provjeriti na ispisu zbog trećih osoba
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			--InvoicePersonIssued = rtrim(isnull(grp.value, InvoicePersonIssued)), --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.debit_opr + a.debit_izv + a.neobdav) else (a.debit_neto + a.brez_davka + a.debit_opr + a.debit_izv + a.neobdav) end, 
			InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
			InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = rtrim(isnull(b.rep,'')) ,
			InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu sukladno zakonu. Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate.', -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end
			From #invoice_data a 
			inner join dbo.gl_output_r b on a.ddv_id = b.DDV_ID 
			left join dbo.tecajnic t on b.id_tec = t.id_tec
			--LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = 'OUTPUT_R2' AND grp.neaktiven = 0

				/*STAVKE*/
				set  @xml = (
				Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
				LineAmount,LineTaxNote,LineTaxName
				From (
					Select 
					case when fp.protikonto is null or fp.protikonto = '' then rtrim(cast(fp.id_gl_out_rk as varchar(10))) else rtrim(fp.PROTIKONTO) end as LineItemIdent, 
					rtrim(fp.opis) as LineDesc, --TODO Provjeriti po ispisima
					'H87' as LineQuantityUnit, 
					case when (a.document_external_type = 'CreditNoteEnvelope') or fp.znesek > 0 then abs(fp.KOSOV) else (-1 * abs(fp.KOSOV)) end as LineQuantity,
					abs(fp.cena) as LineNetPrice, 
					abs(fp.osnova) as LineNetTotal,
					case when fp.je_davek = 1 then c.davek else 0 end as LineTaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or fp.davek > 0 then abs(fp.davek) else fp.davek end as LineTaxAmount,
					case when (a.document_external_type = 'CreditNoteEnvelope') or fp.znesek > 0 then abs(fp.znesek) else fp.znesek end as LineAmount,
					case when fp.je_davek = 1 then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as LineTaxNote,
					case when fp.je_davek = 1 then rtrim(c.opis_tuj1) 
						 when fp.je_davek = 0 and a.BREZ_DAVKA + a.DEBIT_OPR + a.DEBIT_IZV <> 0 then 'OP' 
						else 'NO' end as LineTaxName
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					inner join dbo.GL_OUTPUT_R f on a.ddv_id = f.ddv_id
					inner join dbo.GL_OUT_RK fp on f.ID_GL_OUTPUT_R = fp.ID_GL_OUTPUT_R 
					
				) a
				FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

				set @invoiceLineXml = cast(@xml as varchar(max))

				/*POREZI*/
				set  @xml = (
				Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
				From (
					Select 
					rtrim(c.opis_tuj1) as TaxName,
					c.davek as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_neto > 0 then abs(a.debit_neto) else a.debit_neto end as TaxBase,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.debit_davek > 0 then abs(a.debit_davek) else a.debit_davek end as TaxAmount,
					'' as TaxNote
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.debit_neto <> 0
						union all
					Select 
					'OP' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or (a.brez_davka + a.debit_opr + a.debit_izv) > 0 then abs(a.brez_davka + a.debit_opr + a.debit_izv) else (a.brez_davka + a.debit_opr + a.debit_izv) end as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.brez_davka + a.debit_opr + a.debit_izv <> 0
						union all
					Select 
					'NO' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then abs(a.neobdav) else a.neobdav end as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.neobdav <> 0
				) a
				FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

				set @taxTotalXml = cast(@xml as varchar(max))

		end

		/*OVO DALJE SE NE DIRA*/
		Select TOP 1 InvoiceId, InvoiceIssueDate, InvoiceDate, InvoiceDueDate, InvoicePeriodStartDate, InvoicePeriodEndDate,
		InvoiceCurrency, InvoiceType, InvoiceDeliveryDate, InvoiceNote, InvoicePersonIssued, InvoiceCustomerId,
		InvoiceCustomerOIB, InvoiceCustomerFinaId, InvoiceCustomerName, InvoiceCustomerStreet, InvoiceCustomerHouseNumber, 
		InvoiceCustomerPostalCode, InvoiceCustomerCity, InvoiceCustomerCountry, InvoicePaymentId, InvoicePaymentDesc, 
		InvoicePaymentAccount, InvoicePaymentNote, InvoiceTotalNetAmount, InvoiceTotalTaxAmount, InvoiceTotalWithTaxAmount, 
		InvoiceTotalAddCostsAmount, InvoiceTotalPayableAmount, InvoiceTotalRoundingAmount, document_external_type, InvoiceOrderReference, InvoiceCustomContractReference,    
		replace(replace(@referencesXml,'<ReferenceId>', '<ReferenceId xmlns="urn:gmc:ui">'),'<ReferenceIssueDate>', '<ReferenceIssueDate xmlns="urn:gmc:ui">') as referencesXml,
		replace(replace(replace(replace(replace(@taxTotalXml, '<TaxName>', '<TaxName xmlns="urn:gmc:ui">'), '<TaxBase>', '<TaxBase xmlns="urn:gmc:ui">'), '<TaxNote>', '<TaxNote xmlns="urn:gmc:ui">'), '<TaxRate>', '<TaxRate xmlns="urn:gmc:ui">'), '<TaxAmount>', '<TaxAmount xmlns="urn:gmc:ui">') as taxTotalXml,
		replace(replace(@addCostXml,'<AddCostName>','<AddCostName xmlns="urn:gmc:ui">'),'<AddCostAmount>','<AddCostAmount xmlns="urn:gmc:ui">') as addCostXml, 
		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@invoiceLineXml, '<LineDesc>', '<LineDesc xmlns="urn:gmc:ui">'),'<LineQuantityUnit>', '<LineQuantityUnit xmlns="urn:gmc:ui">'),'<LineQuantity>', '<LineQuantity xmlns="urn:gmc:ui">'),'<LineNetPrice>', '<LineNetPrice xmlns="urn:gmc:ui">'),'<LineNetTotal>', '<LineNetTotal xmlns="urn:gmc:ui">'),'<LineTaxRate>', '<LineTaxRate xmlns="urn:gmc:ui">'),'<LineTaxAmount>', '<LineTaxAmount xmlns="urn:gmc:ui">'),'<LineAmount>', '<LineAmount xmlns="urn:gmc:ui">'),'<LineTaxNote>', '<LineTaxNote xmlns="urn:gmc:ui">'),'<LineTaxName>', '<LineTaxName xmlns="urn:gmc:ui">'),'<LineItemIdent>', '<LineItemIdent xmlns="urn:gmc:ui">') as invoiceLineXml, 
		@addPropertyXml as lineAddPropertiesXml 
		From #invoice_data

		drop table #invoice_data

end

if @DocType = 'InvoiceCum' and @is_for_fina = 1 and exists(Select * From dbo.KROV_POG a inner join dbo.krov_pog_tip b on a.ID_TIP = b.ID_TIP inner join dbo.zbirniki c on a.ID_KROV_POG = c.ID_KROV_POG where c.ID_ZBIRNIK = @id  and b.IMA_ZBIRNIK = 0 and b.IMA_PARTNERJA = 1 and b.IMA_ZBIRNO_FAKTURO = 1)
begin 
		Select @is_for_fina as [fina.is_for_fina]
		
		set @source = dbo.gfn_GetInvoiceSource(@Id)
		Select @p_zrac = cast(rtrim(p_zrac) as varchar(50)), @p_podjetje = cast(rtrim(p_podjetje) as varchar(100)), @dom_valuta = cast(rtrim(dom_valuta) as varchar(10)) From dbo.nastavit
		set @addCostXml = ''
		set @invoiceLineXml = ''
		set @referencesXml = ''
		set @taxTotalXml = ''
		set @addPropertyXml = '' 

		--OVA VARIJABLA SLUŽI AKO SE ŽELI RAZLIČITE VRIJEDNOSTI ZA ODREĐENA POLJA: InvoiceNote, InvoicePaymentDesc, 
		--InvoicePaymentNote, LineDesc
		set @ubl_tip = IsNull((Select TOP 1 c.vrednost From dbo.kategorije_entiteta a 
					inner join dbo.kategorije_tip b on a.id_kategorije_tip = b.id_kategorije_tip 
					inner join dbo.kategorije_sifrant c on a.id_kategorije_sifrant = c.id_kategorije_sifrant and a.id_kategorije_tip = c.id_kategorije_tip
					where b.sifra = 'Fina.Ubl.Tip' and b.entiteta = 'PARTNER'
					and a.id_entiteta = (Select a.id_kupca From dbo.rac_out a inner join dbo.zbirniki z on a.ddv_id = z.ddv_id Where z.id_zbirnik = @id and @DocType='InvoiceCum')
					order by a.id_kategorije_entiteta desc), 'UblEN')

		set @int_kamate = dbo.gfn_GetCustomSettings('id_terj_interkal_obr')  

		Select * into #najem_fa1 
		From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) a
		cross apply (
			Select * From dbo.pfn_gmc_InvoicePartValues (a.SNETO, a.SOBRESTI, a.SMARZA, a.SROBRESTI, a.SREGIST, a.SDAVEK, a.DAV_VRED, a.dav_N, a.dav_O, a.dav_M, a.dav_B, a.dav_R, a.fakt_obr)
		) b 
		where a.ddv_id in (Select ddv_id From dbo.ZBIRNIKI where ID_ZBIRNIK = @id) 

		Select dbo.gfn_TransformDDV_ID_HR(a.ddv_id, a.ddv_date) as InvoiceId, 
		dbo.gfn_GetInvoiceSource(a.ddv_id) as source,
		a.dat_vnosa as InvoiceIssueDate, 
		a.DDV_DATE as InvoiceDate,
		a.VALUTA as InvoiceDueDate,
		cast(null as datetime) as InvoicePeriodStartDate,
		cast(null as datetime) as InvoicePeriodEndDate,
		@dom_valuta as InvoiceCurrency,
		'394' as InvoiceType, 
		a.ddv_date as InvoiceDeliveryDate,
		cast('' as varchar(max)) as InvoiceNote, -- Ubl 1024 znakova, UblEn nema ograničenja
		rtrim(a.izdal) as InvoicePersonIssued,
		a.id_kupca as InvoiceCustomerId,
		a.dav_stev as InvoiceCustomerOIB,
		b.ident_stevilka as InvoiceCustomerFinaId,
		b.naz_kr_kup as InvoiceCustomerName,
		rtrim(replace(b.ulica_sed, rtrim(isnull(b.ulica_st_sed, '')), ''))  as InvoiceCustomerStreet,  
		isnull(b.ulica_st_sed, '') as InvoiceCustomerHouseNumber, 
		replace(b.id_poste_sed, 'HR-','') as InvoiceCustomerPostalCode,
		b.mesto_sed as InvoiceCustomerCity,
		rtrim(c.drzava) as InvoiceCustomerCountry,

		--SKLIC JE IZ ZBIRNIKA
		cast('HR01 ' + rtrim(isnull(z.sklic, '')) as varchar(100)) as InvoicePaymentId, 
		
		cast('' as varchar(max)) as InvoicePaymentDesc, --Ubl 105 znakova, UblEn nema ograničenja
		@p_zrac as InvoicePaymentAccount,
		cast('Molimo upišite ispravan poziv na broj' as varchar(max)) as InvoicePaymentNote, --Ovo ovisi koji je tip Ubl-a jer za Ubl mora biti do 
		cast(0 as decimal(18,2)) as InvoiceTotalNetAmount,
		cast(0 as decimal(18,2)) as InvoiceTotalTaxAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalWithTaxAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalAddCostsAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalRoundingAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalPayableAmount,
		cast('InvoiceEnvelope' as varchar(100)) as document_external_type, --TODO za odobrenje ovo mora biti CreditNoteEnvelope  
		cast(rtrim(isnull(dok.stevilka,'')) as varchar(max)) as InvoiceCustomContractReference, --TODO
		cast(rtrim(coalesce(dok.ext_id, jn.val_string, '')) as varchar(max)) as InvoiceOrderReference, --TODO
		a.*, ks.klavzula, nf.DAT_ZAP, nf.DATUM_DOK, nf.ID_TERJ--, nf.NACIN_LEAS
		into #invoice_data1
		From dbo.rac_out a
		inner join dbo.zbirniki z on a.ddv_id = z.ddv_id 
		left join (Select ddv_id, nacin_leas, ID_TERJ, datum_dok, dat_zap From #najem_fa1 group by ddv_id, nacin_leas, ID_TERJ, datum_dok, dat_zap ) nf on a.ddv_id = nf.ddv_id 
		left join (
			Select top 1 a.id_cont, a.ddv_id, b.val_string
			From #najem_fa1 a
			inner join (
			Select cast(a.id_entiteta as int) as id_cont, a.val_string
			From dbo.kategorije_entiteta a
			inner join dbo.kategorije_tip b on a.id_kategorije_tip = b.id_kategorije_tip and b.entiteta = 'POGODBA' and b.neaktiven = 0
			where b.sifra = 'ORDER_NO') b on a.id_cont = b.id_cont 
			where b.val_string is not null and b.val_string <> ''
		) jn on a.ddv_id = jn.ddv_id 
		left join dbo.partner b on a.id_kupca = b.id_kupca 
		left join dbo.poste c on b.id_poste_sed = c.id_poste
		left join dbo.klavzule_sifr ks on ks.id_klavzule = a.id_klavzule 
		left join (
			Select z.ID_ZBIRNIK, b.stevilka, b.ext_id
			From dbo.krov_pog a 
			inner join dbo.zbirniki z on a.ID_KROV_POG = z.ID_KROV_POG
			left join dbo.dokument b on a.ID_KROV_POG = b.id_krov_pog and b.ID_OBL_ZAV = dbo.gfn_GetCustomSettings('Hr_Integration.HR_SLOG.JNContractDokType') and b.STATUS_AKT = 'A'
		) dok on z.ID_ZBIRNIK = dok.ID_ZBIRNIK
		Where z.id_zbirnik = @id

		set @id_terj = (Select id_terj From #invoice_data1)
		set @tip_leas = (Select dbo.gfn_Nacin_leas_HR(nacin_leas) From #invoice_data1)
		set @datum_dok = (Select datum_dok From #invoice_data1)
				
		Select a.id_cont, a.id_pog, b.st_sas, b.reg_stev, c.ser_st 
		into #zapisnici
		From #najem_fa1 a
		outer apply (
			Select *
			From gfn_zap_reg_single_per_contract2(a.id_cont)
		)b
		outer apply (
			Select *
			From gfn_zap_ner_single_per_contract2(a.id_cont)
		)c

		if @id_terj = '21'
		begin
			update #invoice_data1 set 
				InvoiceDate = a.DDV_DATE, -- MID 47061, g_barbarak promijenjeno iz najem_fa.datum_dok u rac_out.ddv_date
				InvoiceDeliveryDate = a.DDV_DATE,
				InvoiceDueDate = a.VALUTA, 
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO PREMA ISPISU
				InvoicePersonIssued = a.izdal,  --TODO PREMA ISPISU
				
				InvoiceTotalNetAmount = case when @tip_leas = 'OL' 
											then a.debit_neto + a.neobdav   --NAJAMNINA + PPMV
											else a.debit_neto + a.brez_davka end,  --KAMATA
				InvoiceTotalTaxAmount = a.debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = a.debit_davek + case when @tip_leas = 'OL' 
														then a.debit_neto + a.neobdav
														else a.debit_neto + a.brez_davka end,
				InvoiceTotalAddCostsAmount = 0, -- case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end ,
				InvoiceTotalPayableAmount = a.debit + a.neobdav + a.izravnava_ddv, -- + case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end,
				InvoiceTotalRoundingAmount = a.izravnava_ddv,
				InvoiceNote = case when @tip_leas in ('F1', 'ZP') then 'Glavnica u okviru rata: ' + dbo.gfn_gccif(b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '. Ukupno za platiti: ' + dbo.gfn_gccif(a.debit + a.neobdav + b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '.' else '' end,
				InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. Kod zakašnjenja plaćanja zaračunavamo zakonsku zateznu kamatu.'
									 + case when b.id_tec != '000' then ' Nakon datuma dospijeća u obvezi ste platiti iznos u valuti koristeći ' + rtrim(b.naz_tec)+' na dan uplate. Informacije o tečaju na dan uplate možete saznati putem info telefona RBA broj 062 / 62 62 62 ili na www.rba.hr.' else '' end
				From #invoice_data1 a 
				left join dbo.nastavit n on 1 = 1 
				left join dbo.loc_nast l on 1 = 1 
				outer apply (
					Select sum(sneto) as sneto, sum(SROBRESTI) as srobresti, sum(sobresti) as sobresti, sum(smarza) as smarza, sum(sdavek) as sdavek, sum(SDEBIT) as sdebit, ddv_id, min(id_cont) as id_cont,
					sum(debit) as debit, sum(neto) as neto, min(id_tec) as id_tec, min(id_val) as id_val, min(naz_tec) as naz_tec From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) where ddv_id = a.DDV_ID Group by ddv_id
				) b

				--TODO OVAJ DIO PO LEASING KUĆI
				Select @rata_type =  
					Case when (cs.val = 'Anticipative' and dok.id_dokum is null) or (cs.val = 'Decursive' and dok.id_dokum is not null) Then 'Anticipative'
					when (cs.val = 'Decursive' And dok.id_dokum is null) Or (cs.val = 'Anticipative' And dok.id_dokum is not null) Then 'Decursive'
					Else '' End, 
				-- @rata_prije = pp.datum_prije,
				-- @rata_poslije = pp1.datum_poslije, 
				@obnaleto = c.obnaleto
				From #invoice_data1 a 
				inner join (Select top 1 id_cont, ddv_id, st_dok From #najem_fa1) d on a.ddv_id = d.ddv_id 
				inner join dbo.pogodba b on d.id_cont = b.id_cont
				left join dbo.obdobja c on b.id_obd = c.id_obd
				Left Join dbo.custom_settings cs on cs.code = 'BOOKING_CRO_INT_ACCR_TYPE'
				Left Join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
				Left Join dbo.dokument dok on b.id_cont = dok.id_cont and CHARINDEX(dok.id_obl_zav, cs1.val) > 0
				-- left join (Select id_cont, max(datum_dok) as datum_prije From dbo.planp where datum_dok < @datum_dok and id_terj = @id_terj group by id_cont)pp on b.id_cont = pp.id_cont
				-- left join (Select id_cont, max(datum_dok) as datum_poslije From dbo.planp where datum_dok > @datum_dok and id_terj = @id_terj group by id_cont)pp1 on b.id_cont = pp1.id_cont
				
				if @rata_type = 'Decursive'
				begin
					set @startdate = dbo.gfn_GetFirstDayOfMonth(DATEADD(mm, -12/@obnaleto + 1, @datum_dok))
					set @enddate = @datum_dok				
				end
				else
				begin
					set @startdate = DATEADD(dd,-(DAY(@datum_dok)-1), @datum_dok)
					set @enddate =  DATEADD(dd,-(DAY(DATEADD(mm,1,@datum_dok))),DATEADD(mm,12/@obnaleto,@datum_dok))
				end
				
				update #invoice_data1 set InvoicePeriodStartDate = @startdate, InvoicePeriodEndDate = @enddate

				if @tip_leas in ('F1', 'ZP')
				begin

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName, ArrayOfLineAddProperties
					From (
						Select rtrim(p.id_pog) + '-' + @id_terj as LineItemIdent, 
						'Kamata u okviru ' + rtrim(cast(b.zap_obr as varchar(10))) + '. rate' as LineDesc,  --TODO AKO JE UBLEN MOŽE SE STAVITI I PERIOD U OPIS STAVKE
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.sobresti + b.smarza + b.SREGIST as LineNetPrice, 
						b.sobresti + b.smarza + b.SREGIST as LineNetTotal,
						c.davek as LineTaxRate,
						b.sdavek as LineTaxAmount,
						b.sdebit - b.srobresti - b.sneto as LineAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName, 
						replace(replace(replace(CAST( (
							Select Name, Value
							From (
							Select 'Ugovor' as Name, rtrim(id_pog) as Value From #zapisnici where id_pog is not null and id_pog <> '' and id_cont = b.id_cont
							union all
							Select 'Broj šasije' as Name, rtrim(st_sas) as Value From #zapisnici where st_sas is not null and st_sas <> '' and id_cont = b.id_cont
							union all
							Select 'Registarska oznaka' as Name, rtrim(reg_stev) as Value From #zapisnici where reg_stev is not null and reg_stev <> '' and id_cont = b.id_cont
							union all
							Select 'Serijski broj' as Name, rtrim(ser_st) as Value From #zapisnici where ser_st is not null and ser_st <> '' and id_cont = b.id_cont
							) a
							FOR XML PATH('LineAddProperties') 
	
						) as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' ), '<LineAddProperties>', '<LineAddProperties xmlns="urn:gmc:ui">') as ArrayOfLineAddProperties,
						b.id_pog
						From #najem_fa1 b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st 
						left join dbo.pogodba p on b.id_cont = p.id_cont
						left join dbo.OBDOBJA o on p.ID_OBD = o.id_obd
						where b.ddv_id in (Select ddv_id From dbo.ZBIRNIKI where ID_ZBIRNIK = @id)  
					) a
					Order by a.id_pog, a.LineItemIdent
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						b.debit_neto + b.brez_davka as TaxBase,
						b.debit_davek as TaxAmount,
						rtrim(cast(isnull(d.klavzula,'Klauzula') as varchar(max))) as TaxNote
						From dbo.rac_out b
						left join dbo.dav_stop c on b.id_dav_st = c.id_dav_st
						left join dbo.KLAVZULE_SIFR d on b.id_klavzule = d.id_klavzule
						where b.ddv_id in (Select ddv_id From dbo.ZBIRNIKI where ID_ZBIRNIK = @id)  
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))
				end

				if @tip_leas in ('OL','OZ')
				begin 
					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName, ArrayOfLineAddProperties
					From (
						Select rtrim(p.id_pog) + '-' + @id_terj as LineItemIdent, 
						rtrim(cast(b.zap_obr as varchar(10))) + '. Obrok za razdoblje' as LineDesc, 
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.sneto + b.sobresti + b.smarza + b.SREGIST as LineNetPrice, 
						b.sneto + b.sobresti + b.smarza + b.SREGIST as LineNetTotal,
						c.davek as LineTaxRate,
						b.sdavek as LineTaxAmount,
						b.sdebit - b.srobresti as LineAmount,
						'' as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName, 
						replace(replace(replace(CAST( (
							Select Name, Value
							From (
							Select 'Ugovor' as Name, rtrim(id_pog) as Value From #zapisnici where id_pog is not null and id_pog <> '' and id_cont = b.id_cont
							union all
							Select 'Broj šasije' as Name, rtrim(st_sas) as Value From #zapisnici where st_sas is not null and st_sas <> '' and id_cont = b.id_cont
							union all
							Select 'Registarska oznaka' as Name, rtrim(reg_stev) as Value From #zapisnici where reg_stev is not null and reg_stev <> '' and id_cont = b.id_cont
							union all
							Select 'Serijski broj' as Name, rtrim(ser_st) as Value From #zapisnici where ser_st is not null and ser_st <> '' and id_cont = b.id_cont
							) a
							FOR XML PATH('LineAddProperties')
	
						) as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' ), '<LineAddProperties>', '<LineAddProperties xmlns="urn:gmc:ui">') as ArrayOfLineAddProperties,
						p.id_pog
						From #najem_fa1 b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						left join dbo.pogodba p on b.ID_CONT = p.ID_CONT
						left join dbo.OBDOBJA o on p.ID_OBD = o.id_obd 
						left join dbo.vrst_ter v on b.id_terj = v.id_terj
							union all
						Select rtrim(p.id_pog) + '-' + @id_terj +'-PPMV' as LineItemIdent, 
						'Posebni porez na motorna vozila (prolazna stavka)' as LineDesc, 
						'H87' as LineQuantityUnit,
						cast(1 as decimal(18,2)) as LineQuantity,
						b.srobresti as LineNetPrice, 
						b.srobresti as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						b.srobresti as LineAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'NO' as LineTaxName, 
						replace(replace(replace(CAST( (
							Select Name, Value
							From (
							Select 'Ugovor' as Name, rtrim(id_pog) as Value From #zapisnici where id_pog is not null and id_pog <> '' and id_cont = b.id_cont
							) a
							FOR XML PATH('LineAddProperties')
	
						) as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' ), '<LineAddProperties>', '<LineAddProperties xmlns="urn:gmc:ui">') as ArrayOfLineAddProperties,
						p.id_pog
						From #najem_fa1 b
						left join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						left join dbo.pogodba p on b.ID_CONT = p.ID_CONT
						left join dbo.OBDOBJA o on p.ID_OBD = o.id_obd
						where b.srobresti > 0
					) a
					Order by a.id_pog, a.LineItemIdent
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						b.debit_neto as TaxBase,
						b.debit_davek as TaxAmount,
						'' as TaxNote
						From dbo.rac_out b
						left join dbo.dav_stop c on b.id_dav_st = c.id_dav_st
						left join dbo.KLAVZULE_SIFR d on b.id_klavzule = d.id_klavzule
						where b.ddv_id in (Select ddv_id From dbo.ZBIRNIKI where ID_ZBIRNIK = @id)  
						union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						b.neobdav as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(d.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From  dbo.rac_out b
						left join dbo.dav_stop c on b.id_dav_st = c.id_dav_st
						left join dbo.KLAVZULE_SIFR d on b.id_klavzule = d.id_klavzule
						where b.ddv_id in (Select ddv_id From dbo.ZBIRNIKI where ID_ZBIRNIK = @id) and b.neobdav <> 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))
				end
		end

		if @id_terj != '21' 
			begin
								
				update #invoice_data1 set 
				InvoiceDate = a.DDV_DATE, 
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoiceDueDate = a.valuta, 
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO PREMA ISPISU
				InvoicePersonIssued = a.izdal,  --TODO PREMA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.brez_davka + a.neobdav,  
				InvoiceTotalTaxAmount = a.debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = a.debit + a.neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.neobdav + a.izravnava_ddv,
				InvoiceTotalRoundingAmount = a.izravnava_ddv,
				InvoiceNote = '',
				InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. Kod zakašnjenja plaćanja zaračunavamo zakonsku zateznu kamatu.' 
									+ case when b.id_tec <> '000' then ' Nakon datuma dospijeća u obvezi ste platiti iznos u valuti koristeći ' + rtrim(b.naz_tec)+' na dan uplate. Informacije o tečaju na dan uplate možete saznati putem info telefona RBA broj 062 / 62 62 62 ili na www.rba.hr.' else '' end
				From #invoice_data1 a
				left join dbo.nastavit n on 1 = 1 
				left join dbo.loc_nast l on 1 = 1 
				outer apply (
					Select sum(sneto) as sneto, sum(SROBRESTI) as srobresti, sum(sobresti) as sobresti, sum(smarza) as smarza, sum(sdavek) as sdavek, sum(SDEBIT) as sdebit, ddv_id, min(id_cont) as id_cont,
					sum(debit) as debit, sum(neto) as neto, min(id_tec) as id_tec, min(id_val) as id_val, min(naz_tec) as naz_tec From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) where ddv_id = a.DDV_ID Group by ddv_id
				) b
				inner join dbo.VRST_TER c on c.ID_TERJ = @id_terj 

				set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName, ArrayOfLineAddProperties
					From (
						Select rtrim(b.id_pog) + '-' + @id_terj as LineItemIdent, 
						RTRIM(case 
								 when @tip_leas = 'OL' AND d.sif_terj = 'SFIN' then 'Naknada za korištena sredstava'
								 when @tip_leas = 'F1' AND d.sif_terj = 'SFIN' then 'Interkalarna kamata'
								 when @tip_leas = 'OL' AND d.sif_terj = 'POLO' then 'Posebna najamnina'
								 else d.naziv
							end) as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.osnovaDOM as LineNetPrice, 
						b.osnovaDOM as LineNetTotal,
						c.davek as LineTaxRate,
						b.davekDOM as LineTaxAmount,
						b.osnovaDOM + b.davekDOM as LineAmount,
						'' as LineTaxNote,
						rtrim(c.opis_tuj1) as LineTaxName, 
						replace(replace(replace(CAST( (
							Select Name, Value
							From (
							Select 'Ugovor' as Name, rtrim(id_pog) as Value From #zapisnici where id_pog is not null and id_pog <> '' and id_cont = b.id_cont
							union all
							Select 'Broj šasije' as Name, rtrim(st_sas) as Value From #zapisnici where st_sas is not null and st_sas <> '' and id_cont = b.id_cont
							union all
							Select 'Registarska oznaka' as Name, rtrim(reg_stev) as Value From #zapisnici where reg_stev is not null and reg_stev <> '' and id_cont = b.id_cont
							union all
							Select 'Serijski broj' as Name, rtrim(ser_st) as Value From #zapisnici where ser_st is not null and ser_st <> '' and id_cont = b.id_cont
							) a
							FOR XML PATH('LineAddProperties')
	
						) as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' ), '<LineAddProperties>', '<LineAddProperties xmlns="urn:gmc:ui">') as ArrayOfLineAddProperties,
						b.id_pog
						From #najem_fa1 b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						inner join dbo.vrst_ter d on b.ID_TERJ = d.id_terj
						where b.osnovaDOM > 0
							union all
						Select rtrim(b.id_pog) + '-' + @id_terj as LineItemIdent, 
						RTRIM(case 
								 when @tip_leas = 'OL' AND d.sif_terj = 'SFIN' then 'Naknada za korištena sredstava'
								 when @tip_leas = 'F1' AND d.sif_terj = 'SFIN' then 'Interkalarna kamata'
								 when @tip_leas = 'OL' AND d.sif_terj = 'POLO' then 'Posebna najamnina'
								 else d.naziv
							end) as LineDesc, --TODO Provjeriti po ispisima
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.oproscenDOM as LineNetPrice, 
						b.oproscenDOM as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						b.oproscenDOM as LineAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'OP' as LineTaxName, 
						replace(replace(replace(CAST( (
							Select Name, Value
							From (
							Select 'Ugovor' as Name, rtrim(id_pog) as Value From #zapisnici where id_pog is not null and id_pog <> '' and id_cont = b.id_cont
							union all
							Select 'Broj šasije' as Name, rtrim(st_sas) as Value From #zapisnici where st_sas is not null and st_sas <> '' and id_cont = b.id_cont
							union all
							Select 'Registarska oznaka' as Name, rtrim(reg_stev) as Value From #zapisnici where reg_stev is not null and reg_stev <> '' and id_cont = b.id_cont
							union all
							Select 'Serijski broj' as Name, rtrim(ser_st) as Value From #zapisnici where ser_st is not null and ser_st <> '' and id_cont = b.id_cont
							) a
							FOR XML PATH('LineAddProperties')
	
						) as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' ), '<LineAddProperties>', '<LineAddProperties xmlns="urn:gmc:ui">') as ArrayOfLineAddProperties,
						b.id_pog
						From #najem_fa1 b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						inner join dbo.vrst_ter d on b.ID_TERJ = d.id_terj
						where b.oproscenDOM > 0
							union all
						Select rtrim(b.id_pog) + '-' + @id_terj as LineItemIdent, 
						case when d.ima_robresti = 1 then 'Posebni porez na motorna vozila (prolazna stavka)' 
							else RTRIM(case 
								 when @tip_leas = 'OL' AND d.sif_terj = 'SFIN' then 'Naknada za korištena sredstava'
								 when @tip_leas = 'F1' AND d.sif_terj = 'SFIN' then 'Interkalarna kamata'
								 when @tip_leas = 'OL' AND d.sif_terj = 'POLO' then 'Posebna najamnina'
								 else d.naziv
							end) 
						end as LineDesc, 
						'H87' as LineQuantityUnit, 
						cast(1 as decimal(18,2)) as LineQuantity,
						b.neobdavcenDOM as LineNetPrice, 
						b.neobdavcenDOM as LineNetTotal,
						cast(0 as decimal(18,2)) as LineTaxRate,
						cast(0 as decimal(18,2))  as LineTaxAmount,
						b.neobdavcenDOM as LineAmount,
						rtrim(cast(isnull(b.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
						'NO' as LineTaxName,
						replace(replace(replace(CAST( (
							Select Name, Value
							From (
							Select 'Ugovor' as Name, rtrim(id_pog) as Value From #zapisnici where id_pog is not null and id_pog <> '' and id_cont = b.id_cont 
							union all
							Select 'Broj šasije' as Name, rtrim(st_sas) as Value From #zapisnici where st_sas is not null and st_sas <> '' and id_cont = b.id_cont 
							union all
							Select 'Registarska oznaka' as Name, rtrim(reg_stev) as Value From #zapisnici where reg_stev is not null and reg_stev <> '' and id_cont = b.id_cont 
							union all
							Select 'Serijski broj' as Name, rtrim(ser_st) as Value From #zapisnici where ser_st is not null and ser_st <> '' and id_cont = b.id_cont 
							) a
							FOR XML PATH('LineAddProperties')
	
						) as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' ), '<LineAddProperties>', '<LineAddProperties xmlns="urn:gmc:ui">') as ArrayOfLineAddProperties,
						b.id_pog
						From #najem_fa1 b
						inner join dbo.dav_stop c on b.rac_out_id_dav_st = c.id_dav_st
						inner join dbo.vrst_ter d on b.ID_TERJ = d.id_terj
						where b.neobdavcenDOM > 0
					) a
					Order by a.id_pog, a.LineItemIdent
					FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

					set @invoiceLineXml = cast(@xml as varchar(max))

					/*POREZI*/
					set  @xml = (
					Select TaxName, TaxRate,TaxBase,TaxAmount,TaxNote
					From (
						Select 
						rtrim(c.opis_tuj1) as TaxName,
						c.davek as TaxRate,
						b.debit_neto as TaxBase,
						b.debit_davek as TaxAmount,
						'' as TaxNote
						From dbo.rac_out b
						left join dbo.dav_stop c on b.id_dav_st = c.id_dav_st
						where b.ddv_id in (Select ddv_id From dbo.ZBIRNIKI where ID_ZBIRNIK = @id) and b.debit_neto > 0
						 union all
						Select 
						'OP' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						b.brez_davka as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(d.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From dbo.rac_out b
						left join dbo.dav_stop c on b.id_dav_st = c.id_dav_st
						left join dbo.KLAVZULE_SIFR d on b.id_klavzule = d.id_klavzule
						where b.ddv_id in (Select ddv_id From dbo.ZBIRNIKI where ID_ZBIRNIK = @id) and b.brez_davka > 0
						 union all
						Select 
						'NO' as TaxName,
						cast(0 as decimal(18,2)) as TaxRate,
						b.neobdav as TaxBase,
						cast(0 as decimal(18,2)) as TaxAmount,
						rtrim(cast(isnull(d.klavzula,'Klauzula') as varchar(max))) as TaxNote 
						From dbo.rac_out b
						left join dbo.dav_stop c on b.id_dav_st = c.id_dav_st
						left join dbo.KLAVZULE_SIFR d on b.id_klavzule = d.id_klavzule
						where b.ddv_id in (Select ddv_id From dbo.ZBIRNIKI where ID_ZBIRNIK = @id) and b.neobdav > 0
					) a
					FOR XML PATH ('InvoiceTaxAmountPerTaxRate'), ROOT('ArrayOfInvoiceTaxAmountPerTaxRate'))

					set @taxTotalXml = cast(@xml as varchar(max))

					--TODO provjeriti na ispisu kako ispisuju period interkalarnih kamata
					if @id_terj = @int_kamate and isnull(@int_kamate, '') <> ''
					begin 
						update #invoice_data1 
							set InvoicePeriodStartDate = c.dat_od, InvoicePeriodEndDate = dateadd(dd, -1, c.dat_do)
						From #invoice_data1 a
						inner join #najem_fa1 b on a.DDV_ID = b.DDV_ID
						inner join dbo.gen_interkalarne_obr_child c on b.ST_DOK = c.st_dok
						where c.dat_do is not null and c.dat_od is not null
					end
			end
		

		/*OVO DALJE SE NE DIRA*/
		Select TOP 1 InvoiceId, InvoiceIssueDate, InvoiceDate, InvoiceDueDate, InvoicePeriodStartDate, InvoicePeriodEndDate,
		InvoiceCurrency, InvoiceType, InvoiceDeliveryDate, InvoiceNote, InvoicePersonIssued, InvoiceCustomerId,
		InvoiceCustomerOIB, InvoiceCustomerFinaId, InvoiceCustomerName, InvoiceCustomerStreet, InvoiceCustomerHouseNumber, 
		InvoiceCustomerPostalCode, InvoiceCustomerCity, InvoiceCustomerCountry, InvoicePaymentId, InvoicePaymentDesc, 
		InvoicePaymentAccount, InvoicePaymentNote, InvoiceTotalNetAmount, InvoiceTotalTaxAmount, InvoiceTotalWithTaxAmount, 
		InvoiceTotalAddCostsAmount, InvoiceTotalPayableAmount, InvoiceTotalRoundingAmount, document_external_type, InvoiceOrderReference, InvoiceCustomContractReference,
		replace(replace(@referencesXml,'<ReferenceId>', '<ReferenceId xmlns="urn:gmc:ui">'),'<ReferenceIssueDate>', '<ReferenceIssueDate xmlns="urn:gmc:ui">') as referencesXml,
		replace(replace(replace(replace(replace(@taxTotalXml, '<TaxName>', '<TaxName xmlns="urn:gmc:ui">'), '<TaxBase>', '<TaxBase xmlns="urn:gmc:ui">'), '<TaxNote>', '<TaxNote xmlns="urn:gmc:ui">'), '<TaxRate>', '<TaxRate xmlns="urn:gmc:ui">'), '<TaxAmount>', '<TaxAmount xmlns="urn:gmc:ui">') as taxTotalXml,
		replace(replace(@addCostXml,'<AddCostName>','<AddCostName xmlns="urn:gmc:ui">'),'<AddCostAmount>','<AddCostAmount xmlns="urn:gmc:ui">') as addCostXml, 
		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@invoiceLineXml, '<LineDesc>', '<LineDesc xmlns="urn:gmc:ui">'),'<LineQuantityUnit>', '<LineQuantityUnit xmlns="urn:gmc:ui">'),'<LineQuantity>', '<LineQuantity xmlns="urn:gmc:ui">'),'<LineNetPrice>', '<LineNetPrice xmlns="urn:gmc:ui">'),'<LineNetTotal>', '<LineNetTotal xmlns="urn:gmc:ui">'),'<LineTaxRate>', '<LineTaxRate xmlns="urn:gmc:ui">'),'<LineTaxAmount>', '<LineTaxAmount xmlns="urn:gmc:ui">'),'<LineAmount>', '<LineAmount xmlns="urn:gmc:ui">'),'<LineTaxNote>', '<LineTaxNote xmlns="urn:gmc:ui">'),'<LineTaxName>', '<LineTaxName xmlns="urn:gmc:ui">'),'<LineItemIdent>', '<LineItemIdent xmlns="urn:gmc:ui">'), '<ArrayOfLineAddProperties>', ''), '</ArrayOfLineAddProperties>', '') as invoiceLineXml, 
		@addPropertyXml as lineAddPropertiesXml 
		From #invoice_data1

		drop table #invoice_data1
		drop table #zapisnici
		drop table #najem_fa1
end