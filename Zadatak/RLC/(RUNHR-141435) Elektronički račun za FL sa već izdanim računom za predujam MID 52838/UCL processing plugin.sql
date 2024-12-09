-- [[TAX_ID=18736141210]]

declare @FileName varchar(200)
set @FileName = @OriginalFileName 
declare @OriginalId varchar(2000)
set @OriginalId = (select dbo.gfn_edoc_get_original_id_for_file(@OriginalFileName))

--ovo se koristi samo za 'Contract'
declare @id_reports_log int
set @id_reports_log = (SELECT id_reports_log FROM dbo.reports_log WHERE edoc_file_name = @FileName and doc_type = 'Contract' and id_object_edoc = @Id)

declare @is_for_fina bit

set @is_for_fina = (Select cast(count(*) as bit) 
                      From dbo.partner a 
					  inner join dbo.rac_out b on a.id_kupca = b.id_kupca
					  where a.ident_stevilka is not null and a.ident_stevilka <> '' and 
					  b.ddv_id = @id and @DocType='Invoice') 
	
select @is_for_fina as [fina.is_for_fina]

If @DocType='Invoice' 
Begin

	Select 
	RTRIM(a.st_dok) as st_dok,
	RTRIM(a.opisdok) as [gmi.earchive.doc_description],
	'Račun br. ' + RTRIM(a.ddv_id) as [gmi.earchive.doc_title] 
	From dbo.rac_out a
	Where a.ddv_id = @id
	
End

if @DocType = 'TaxChange'
begin
	Select 
	RTRIM(r.st_dok) as st_dok,
	RTRIM(r.opisdok) as [gmi.earchive.doc_description],
	'Promjena porezne osnovice ' + RTRIM(p.id_pog) + ' ' + CONVERT(char(10), r.datum, 104) as [gmi.earchive.doc_title]
	From dbo.spr_ddv r 
	Inner join dbo.gv_PogodbaAll p on r.id_cont = p.id_cont 
    Where cast(r.id_spr_ddv as varchar(100)) = @Id and @DocType = 'TaxChange'
end

if @DocType = 'Reminder'
begin 
	Select
	RTRIM(par.dav_stev) as partner_tax_id,
	'Obavijest o opomeni za ugovor ' + RTRIM(b.id_pog) + ' ' + CONVERT(char(10), a.datum_dok, 104) as [gmi.earchive.doc_title],
	'Obavijest o opomeni br. ' + RTRIM(a.dok_opom) as [gmi.earchive.doc_description]
	From dbo.gv_za_opom_with_arh  a
	Left join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont 
	Left join dbo.partner par on a.id_kupca = par.id_kupca
    Where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'Reminder'
end

if @DocType = 'RmndrDoc' And @ReportName = 'DOK_OP_SSOFT_UCL'
begin 
	Select
	RTRIM(p.dav_stev) as partner_tax_id,
	a.ddv_date as document_date,
	RTRIM(a.dok_opom) as st_dok,
	'Obavijest o opomeni za dok. za ugovor ' + RTRIM(c.id_pog) + ' ' + CONVERT(char(10), a.ddv_date, 104) as [gmi.earchive.doc_title],
	'Obavijest o opomeni za dokumentaciju br. ' + RTRIM(a.dok_opom) as [gmi.earchive.doc_description]
	From dbo.gv_dok_opom_with_arh a 
	Inner join dbo.dokument b on a.id_dokum = b.id_dokum 
	Inner join dbo.pogodba c on b.id_cont = c.id_cont
	Inner join dbo.partner p on c.id_kupca = p.id_kupca
	Where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'RmndrDoc'
end

if @DocType = 'RmndrDoc' And @ReportName = 'OPO_OSIG_SSOFT_UCL'
begin 
	Select
	RTRIM(p.dav_stev) as partner_tax_id,
	a.ddv_date as document_date,
	RTRIM(a.dok_opom) as st_dok,
	c.id_cont as contract_id,
	c.id_pog as contract_number,
	p.id_kupca as partner_id,
	'Podsjetnik za dostavu dokumentacije za ugovor ' + RTRIM(c.id_pog) + ' pripremljen ' + CONVERT(char(10), a.dat_prip, 104) as [gmi.earchive.doc_title],
	'Podsjetnik za dostavu dokumentacije br. ' + RTRIM(a.dok_opom) as [gmi.earchive.doc_description]
	From dbo.gv_dok_opom_with_arh a 
	Inner join dbo.dokument b on a.id_dokum = b.id_dokum 
	Inner join dbo.pogodba c on b.id_cont = c.id_cont
	Inner join dbo.partner p on c.id_kupca = p.id_kupca
	Where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'RmndrDoc'
end

if @DocType = 'Notif'
begin 
	Select
	'Obavijest o rati ' + RTRIM(a.id_najem_ob) as [gmi.earchive.doc_title],
	'Obavijest o rati ' + RTRIM(a.st_dok) as [gmi.earchive.doc_description]
	From dbo.najem_ob  a
    Where cast(a.id_najem_ob as varchar(100)) = @Id and @DocType = 'Notif'
end


if @DocType = 'NotifReg'
begin
	Select
	RTRIM(pa.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Obavijest o isteku ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_title], 
	'Obavijest o isteku ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_description]
	From dbo.za_regis a
	INNER JOIN dbo.pogodba p on a.id_cont = p.id_cont
	INNER JOIN dbo.partner pa on a.id_kupca = pa.id_kupca
	Where cast(a.id_za_regis as varchar(100)) =  @Id and @DocType = 'NotifReg'
end


if @DocType = 'TaxChngIx'
begin
	Select 
	RTRIM(r.st_dok) as st_dok,
	'Obavijest o indeksaciji ugovor ' + RTRIM(p.id_pog) + ' ' + CONVERT(char(10), r.datum, 104) as [gmi.earchive.doc_title], 
	RTRIM(r.opisdok) as[gmi.earchive.doc_description]
	from dbo.rep_ind r 
	inner join dbo.gv_PogodbaAll p on r.id_cont = p.id_cont 
	where cast(r.id_rep_ind as varchar(100)) = @Id and @DocType = 'TaxChngIx'
end

if @DocType = 'Contract' And @ReportName = 'KON_OBR_USTUP_SSOFT_UCL'
begin
	SELECT
	RTRIM(par.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Konačni obračun ' + RTRIM(p.id_pog) + ' ' + CONVERT(char(10), CASE WHEN p.status_akt = 'Z' THEN p.dat_zakl ELSE getdate() END, 104) as [gmi.earchive.doc_title],
	'Konačni obračun ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	FROM dbo.pogodba p
	INNER JOIN dbo.partner par on p.id_kupca = par.id_kupca
	inner join dbo.reports_log rl ON rl.id_object = @Id AND rl.id_reports_log = @id_reports_log
	WHERE CAST(p.id_cont as varchar(100)) = @Id AND @DocType = 'Contract'
end

if @DocType = 'Contract' And @ReportName = 'POT_OBV_SSOFT_UCL'
begin
	SELECT
	RTRIM(par.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Potvrda o ispunjenju obveza ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title],
	'Potvrda o ispunjenju obveza ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	FROM dbo.pogodba p
	INNER JOIN dbo.partner par on p.id_kupca = par.id_kupca
	inner join dbo.reports_log rl ON rl.id_object = @Id AND rl.id_reports_log = @id_reports_log
	WHERE CAST(p.id_cont as varchar(100)) = @Id AND @DocType = 'Contract'
end

if @DocType = 'ZapReg' And @ReportName = 'ZAM_ODJ_SSOFT_UCL'
begin
	
	SELECT
	CONVERT(date, getdate()) as document_date,
	'Punomoć za odjavu ' + RTRIM(po.id_pog) as [gmi.earchive.doc_title],
	RTRIM(a.opis) as [gmi.earchive.doc_description]
	FROM dbo.zap_reg a
	inner join dbo.pogodba po on a.id_cont = po.id_cont
	WHERE CAST(a.id_zapo as varchar(100)) = @Id AND @DocType = 'ZapReg'
end

if @DocType = 'NotifZaPz'
begin
	Select
	a.id_cont as contract_id,
	RTRIM(p.id_pog) as contract_number,
	RTRIM(a.id_kupca) as partner_id,
	RTRIM(pa.naz_kr_kup) as partner_title,
	RTRIM(pa.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Imovinsko osiguranje - obavijest o isteku ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_title], 
	'Imovinsko osiguranje - obavijest o isteku ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_description]
	From dbo.za_pz a
	INNER JOIN dbo.pogodba p on a.id_cont = p.id_cont
	INNER JOIN dbo.partner pa on a.id_kupca = pa.id_kupca
	Where cast(a.id_za_pz as varchar(100)) =  @Id and @DocType = 'NotifZaPz'
end

If @DocType='InvoiceCum' 
Begin
	Select 
	RTRIM(z.ddv_id) as id,
	RTRIM(po.ID_KUPCA) as partner_id,
	RTRIM(pa.naz_kr_kup) as partner_title,
	RTRIM(po.st_krov_pog) as st_dok,
	RTRIM(pa.dav_stev) as partner_tax_id,
	z.DAT_VNOSA as document_date,
	RTRIM(ra.opisdok) as [gmi.earchive.doc_description],
	'Zbirni račun br. ' + RTRIM(z.ddv_id) as [gmi.earchive.doc_title]
	From dbo.ZBIRNIKI z
	inner join dbo.KROV_POG po on po.ID_KROV_POG = z.ID_KROV_POG
	inner join dbo.rac_out ra on z.ddv_id = ra.ddv_id
	left outer join dbo.PARTNER pa on pa.id_kupca = po.ID_KUPCA
	Where cast(z.ID_ZBIRNIK as varchar(100)) =  @Id and @DocType = 'InvoiceCum'
	
End

if @DocType = 'General' And @ReportName = 'OPO_SSOFT_UCL'
begin
	Select
	p.id_cont as contract_id,
	RTRIM(LTRIM(p.id_pog)) as contract_number,
	p.id_kupca as partner_id,
	RTRIM(pa.naz_kr_kup) as partner_title,
	RTRIM(pa.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Opomena za nepodmirene obveze po ugovoru br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_title],
	'Opomena za nepodmirene obveze po ugovoru br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	From dbo.pogodba p
	Inner join dbo.partner pa on p.id_kupca = pa.id_kupca
	Inner join dbo.reports_log b ON cast (p.id_cont as varchar (100)) = b.id_object AND b.doc_type = 'General' AND b.edoc_file_name = @OriginalFileName
	Where b.id_object_edoc = @Id and @DocType = 'General'
end

if @DocType = 'Contract' And @ReportName = 'OBV_DOB_SSOFT'
begin
	Select
	p.id_cont as contract_id,
	RTRIM(LTRIM(p.id_pog)) as contract_number,
	p.id_kupca as partner_id,
	RTRIM(pa.naz_kr_kup) as partner_title,
	RTRIM(pa.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Obavijest dobavljaču o odobrenju financiranja po ugovoru br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_title],
	'Obavijest dobavljaču o odobrenju financiranja po ugovoru br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	From dbo.pogodba p
	Inner join dbo.partner pa on p.id_kupca = pa.id_kupca
	Inner join dbo.reports_log b ON cast (p.id_cont as varchar (100)) = b.id_object AND b.doc_type = 'Contract' AND b.edoc_file_name = @OriginalFileName
	Where b.id_object_edoc = @Id and @DocType = 'Contract'
end

if @DocType = 'Contract' And @ReportName = 'UOBV_OPC_SSOFT_UCL'
begin
	Select
	p.id_cont as contract_id,
	RTRIM(LTRIM(p.id_pog)) as contract_number,
	p.id_kupca as partner_id,
	RTRIM(pa.naz_kr_kup) as partner_title,
	RTRIM(pa.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Obavijest o otkupu po ugovoru br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_title],
	'Obavijest o otkupu po ugovoru br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	From dbo.pogodba p
	Inner join dbo.partner pa on p.id_kupca = pa.id_kupca
	Inner join dbo.reports_log b ON cast (p.id_cont as varchar (100)) = b.id_object AND b.doc_type = 'Contract' AND b.edoc_file_name = @OriginalFileName
	Where b.id_object_edoc = @Id and @DocType = 'Contract'
end

if @DocType = 'General' And @ReportName = 'DDV_DBRP_FIK_SSOFT'
begin
Select
	d.id_cont as contract_id,
	RTRIM(LTRIM(p.id_pog)) as contract_number,
	p.id_kupca as partner_id,
	RTRIM(pa.naz_kr_kup) as partner_title,
	RTRIM(pa.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Promjena porezne osnovice - Fiktivna po ugovoru br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_title],
	'Promjena porezne osnovice - Fiktivna po ugovoru br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	FROM dbo.pogodba p
	INNER JOIN dbo.partner pa on p.id_kupca = pa.id_kupca
	INNER JOIN (SELECT PP.ID_Cont, PP.id_planp_cl_content FROM dbo.planp_clone PP  
				WHERE PP.id_planp_cl_content = @Id Group by PP.id_cont, PP.id_planp_cl_content) d on p.id_cont = d.id_cont
	INNER JOIN dbo.reports_log b ON cast (d.id_planp_cl_content as varchar (100)) = b.id_object AND b.doc_type = 'General' AND b.edoc_file_name = @OriginalFileName
	Where b.id_object_edoc = @Id and @DocType = 'General'
end

if @DocType = 'Contract' And @ReportName = 'PLANP_SSOFT_UCL'
begin
	SELECT
	RTRIM(par.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Plan otplate za ugovor br. ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title],
	'Plan otplate za ugovor br. ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	FROM dbo.pogodba p
	INNER JOIN dbo.partner par on p.id_kupca = par.id_kupca
	inner join dbo.reports_log rl ON CAST(SUBSTRING(rl.id_object, 0, CHARINDEX(';',rl.id_object)) AS VARCHAR(100)) = @Id AND rl.id_reports_log = @id_reports_log
	WHERE CAST(p.id_cont as varchar(100)) = @Id AND @DocType = 'Contract'
end

if @DocType = 'ZapReg' And @ReportName = 'PREUZ_IZJAVA_SSOFT_UCL'
begin
	SELECT
	CONVERT(date, getdate()) as document_date,
	'Izjava o preuzimanju dokumentacije ' + RTRIM(po.id_pog) as [gmi.earchive.doc_title],
	RTRIM(a.opis) as [gmi.earchive.doc_description]
	FROM dbo.zap_reg a
	inner join dbo.pogodba po on a.id_cont = po.id_cont
	WHERE CAST(a.id_zapo as varchar(100)) = @Id AND @DocType = 'ZapReg'
end

if @DocType = 'General' And @ReportName = 'POV_AV_SSOFT_UCL'
begin
	Select
	p.id_cont as contract_id,
	RTRIM(LTRIM(p.id_pog)) as contract_number,
	p.id_kupca as partner_id,
	RTRIM(pa.naz_kr_kup) as partner_title,
	RTRIM(pa.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Nalog za povrat više uplaćenih sredstava ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title],
	'Nalog za povrat više uplaćenih sredstava ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	From dbo.pogodba p
	Inner join dbo.partner pa on p.id_kupca = pa.id_kupca
	Inner join dbo.reports_log b ON cast (p.id_pog as varchar (100)) = b.id_object AND b.doc_type = 'General' AND b.edoc_file_name = @OriginalFileName
	Where b.id_object_edoc = @Id and @DocType = 'General'
end

if @DocType = 'General' And @ReportName = 'OBV_PRIM_RASK_SSOFT_UCL'
begin
	Select
	o.id_cont as contract_id,
	RTRIM(LTRIM(p.id_pog)) as contract_number,
	o.id_kupca as partner_id,
	RTRIM(pa.naz_kr_kup) as partner_title,
	RTRIM(pa.dav_stev) as partner_tax_id,
	CONVERT(date, getdate()) as document_date,
	'Obavijest o jednostranom raskidu OL ugovora br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_title],
	'Obavijest o jednostranom raskidu OL ugovora br.' + RTRIM(p.id_pog) as [gmi.earchive.doc_description]
	From dbo.opc_fakt o
	Inner join dbo.pogodba p on o.id_cont = p.id_cont
	Inner join dbo.partner pa on o.id_kupca = pa.id_kupca
	Inner join dbo.reports_log b ON cast (o.st_dok as varchar (100)) = b.id_object AND b.doc_type = 'General' AND b.edoc_file_name = @OriginalFileName
	Where b.id_object_edoc = @Id and @DocType = 'General'
end
if @DocType = 'General' and  @ReportName = 'ISP_RAC_SSOFT_UCL'-- S01
begin 
	Select
	a.stevilka as damage_id,
	b.id_cont as contract_id,
	RTRIM(b.id_pog) as contract_number,
	c.id_kupca as partner_id,
	c.naz_kr_kup as partner_title,
	c.dav_stev as partner_tax_id,
	'Ispravak računa za štetu ' + RTRIM(a.ststete) + ' ' + CONVERT(char(10), getdate(), 104) as [gmi.earchive.doc_title],
	'Ispravak računa za štetu ' + RTRIM(a.ststete) as [gmi.earchive.doc_description]	
	FROM dbo.ss_odskod a
	LEFT JOIN dbo.pogodba b on b.id_cont = a.id_cont
	LEFT JOIN dbo.partner c on b.id_kupca = c.id_kupca
	where cast(a.stevilka as varchar(100)) = @Id and @DocType = 'General'
end
 if @DocType = 'General' and  @ReportName = 'ISP_STETE_SSOFT_UCL'-- S02
begin 
	Select
	a.stevilka as damage_id,
	b.id_cont as contract_id,
	RTRIM(b.id_pog) as contract_number,
	c.id_kupca as partner_id,
	c.naz_kr_kup as partner_title,
	c.dav_stev as partner_tax_id,
	'Isplata štete ' + RTRIM(a.ststete) + ' ' + CONVERT(char(10), getdate(), 104) as [gmi.earchive.doc_title],
	'Isplata štete ' + RTRIM(a.ststete) as [gmi.earchive.doc_description]	
	FROM dbo.ss_odskod a
	LEFT JOIN dbo.pogodba b on b.id_cont = a.id_cont
	LEFT JOIN dbo.partner c on b.id_kupca = c.id_kupca
	where cast(a.stevilka as varchar(100)) = @Id and @DocType = 'General'
end
 if @DocType = 'General' and  @ReportName = 'IZJ_NAM_SSOFT_UCL'-- S03
begin 
	Select
	a.stevilka as damage_id,
	b.id_cont as contract_id,
	RTRIM(b.id_pog) as contract_number,
	c.id_kupca as partner_id,
	c.naz_kr_kup as partner_title,
	c.dav_stev as partner_tax_id,
	'Izjava o namirenju štete ' + RTRIM(a.ststete) + ' ' + CONVERT(char(10), getdate(), 104) as [gmi.earchive.doc_title],
	'Izjava o namirenju štete ' + RTRIM(a.ststete) as [gmi.earchive.doc_description]	
	FROM dbo.ss_odskod a
	LEFT JOIN dbo.pogodba b on b.id_cont = a.id_cont
	LEFT JOIN dbo.partner c on b.id_kupca = c.id_kupca
	where cast(a.stevilka as varchar(100)) = @Id and @DocType = 'General'
end
 if @DocType = 'General' and  @ReportName = 'NALOG_OBRADA_ZAH_SSOFT_UCL'-- S04
begin 
	Select
	a.stevilka as damage_id,
	b.id_cont as contract_id,
	RTRIM(b.id_pog) as contract_number,
	c.id_kupca as partner_id,
	c.naz_kr_kup as partner_title,
	c.dav_stev as partner_tax_id,
	'Nalog za obradu odštetnog zahtjeva ' + RTRIM(a.ststete) + ' ' + CONVERT(char(10), getdate(), 104) as [gmi.earchive.doc_title],
	'Nalog za obradu odštetnog zahtjeva  ' + RTRIM(a.ststete) as [gmi.earchive.doc_description]	
	FROM dbo.ss_odskod a
	LEFT JOIN dbo.pogodba b on b.id_cont = a.id_cont
	LEFT JOIN dbo.partner c on b.id_kupca = c.id_kupca
	where cast(a.stevilka as varchar(100)) = @Id and @DocType = 'General'
end
 if @DocType = 'General' and  @ReportName = 'NAR_ISP_SSOFT_UCL'-- S05
begin 
	Select
	a.stevilka as damage_id,
	b.id_cont as contract_id,
	RTRIM(b.id_pog) as contract_number,
	c.id_kupca as partner_id,
	c.naz_kr_kup as partner_title,
	c.dav_stev as partner_tax_id,
	'Narudžba popravka ' + RTRIM(a.ststete) + ' ' + CONVERT(char(10), getdate(), 104) as [gmi.earchive.doc_title],
	'Narudžba popravka ' + RTRIM(a.ststete) as [gmi.earchive.doc_description]	
	FROM dbo.ss_odskod a
	LEFT JOIN dbo.pogodba b on b.id_cont = a.id_cont
	LEFT JOIN dbo.partner c on b.id_kupca = c.id_kupca
	where cast(a.stevilka as varchar(100)) = @Id and @DocType = 'General'
end
 if @DocType = 'General' and  @ReportName = 'OBV_ZAP_UPL_STETE_SSOFT_UCL'-- S06
begin 
	Select
	a.stevilka as damage_id,
	b.id_cont as contract_id,
	RTRIM(b.id_pog) as contract_number,
	c.id_kupca as partner_id,
	c.naz_kr_kup as partner_title,
	c.dav_stev as partner_tax_id,
	'Obavijest o zaprimljenoj uplati za štetu ' + RTRIM(a.ststete) + ' ' + CONVERT(char(10), getdate(), 104) as [gmi.earchive.doc_title],
	'Obavijest o zaprimljenoj uplati za štetu ' + RTRIM(a.ststete) as [gmi.earchive.doc_description]	
	FROM dbo.ss_odskod a
	LEFT JOIN dbo.pogodba b on b.id_cont = a.id_cont
	LEFT JOIN dbo.partner c on b.id_kupca = c.id_kupca
	where cast(a.stevilka as varchar(100)) = @Id and @DocType = 'General'
end
 if @DocType = 'General' and  @ReportName = 'SUG_ISPLATA_SSOFT_UCL'-- S07
begin 
	Select
	a.stevilka as damage_id,
	b.id_cont as contract_id,
	RTRIM(b.id_pog) as contract_number,
	c.id_kupca as partner_id,
	c.naz_kr_kup as partner_title,
	c.dav_stev as partner_tax_id,
	'Suglasnost za isplatu štete ' + RTRIM(a.ststete) + ' ' + CONVERT(char(10), getdate(), 104) as [gmi.earchive.doc_title],
	'Suglasnost za isplatu štete ' + RTRIM(a.ststete) as [gmi.earchive.doc_description]	
	FROM dbo.ss_odskod a
	LEFT JOIN dbo.pogodba b on b.id_cont = a.id_cont
	LEFT JOIN dbo.partner c on b.id_kupca = c.id_kupca
	where cast(a.stevilka as varchar(100)) = @Id and @DocType = 'General'
end
if @DocType = 'General' and  @ReportName = 'OPO_OSIG_SSOFT_UCL'-- O08
begin 
	Select
	b.id_cont as contract_id,
	RTRIM(b.id_pog) as contract_number,
	c.id_kupca as partner_id,
	c.naz_kr_kup as partner_title,
	c.dav_stev as partner_tax_id,
	'Dopis za nedostajuću dokumentaciju ' + RTRIM(a.id_opom) + ' ' + CONVERT(char(10), getdate(), 104) as [gmi.earchive.doc_title],
	'Dopis za nedostajuću dokumentaciju ' + RTRIM(a.id_opom) as [gmi.earchive.doc_description]	
	FROM dbo.za_opom a
	LEFT JOIN dbo.pogodba b on b.id_cont = a.id_cont
	LEFT JOIN dbo.partner c on b.id_kupca = c.id_kupca
	where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'General'
end
/*OVO DALJE JE SAMO ZA ERAČUNE*/


If @DocType='Invoice' 
Begin

	if @is_for_fina = 1
	begin 

		declare @source varchar(30), @id_terj char(2), @tip_leas char(2), @p_zrac varchar(50), @p_podjetje varchar(100), @int_kamate varchar(100), @p_http varchar(100)
		declare @addCostXml varchar(max), @invoiceLineXml varchar(max), @taxTotalXml varchar(max), @datum_dok datetime, @datum_dok2 datetime
		declare @referencesXml varchar(max), @ubl_tip varchar(5), @xml as xml, @addPropertyXml varchar(max), @dom_valuta varchar(3)
	
		set @source = dbo.gfn_GetInvoiceSource(@Id)
		if @source = 'ERROR'
		begin
			if exists(select * from dbo.rac_out where ddv_id = @id and sif_rac = 'AVA')
				set @source = 'AVANSI'
		end
		
		Select @p_zrac = cast(rtrim(p_zrac) as varchar(50)), @p_podjetje = cast(rtrim(p_podjetje) as varchar(100)), @p_http = cast(rtrim(p_http) as varchar(100)), @dom_valuta = ltrim(rtrim(dom_valuta)) From dbo.nastavit
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

		--TODO paziti nije isto za OPC_FAKT, FAKTURE, OUTPUT_GL pa treba popravljati po pojedinom tipu (ne ovdje)
		cast('HR01 ' + rtrim(isnull(p.sklic, '')) as varchar(100)) as InvoicePaymentId, 
		
		cast('' as varchar(max)) as InvoicePaymentDesc, --Ubl 105 znakova, UblEn nema ograničenja
		@p_zrac as InvoicePaymentAccount,
		cast('Molimo upišite ispravan poziv na broj' as varchar(max)) as InvoicePaymentNote, --Ovo ovisi koji je tip Ubl-a jer za Ubl mora biti do 
		cast(0 as decimal(18,2)) as InvoiceTotalNetAmount,
		cast(0 as decimal(18,2)) as InvoiceTotalTaxAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalWithTaxAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalAddCostsAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalPayableAmount,
		cast('InvoiceEnvelope' as varchar(100)) as document_external_type, --TODO za odobrenje ovo mora biti CreditNoteEnvelope 
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
		Where a.ddv_id = @Id

		if @source = 'NAJEM_FA'
		begin 
			
			Select * into #najem_fa From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) where DDV_ID = @id
			
			Select @id_terj = id_terj, @tip_leas = dbo.gfn_Nacin_leas_HR(nacin_leas), @datum_dok = datum_dok, @int_kamate = dbo.gfn_GetCustomSettings('id_terj_interkal_obr') ,
			@datum_dok2 = dateadd(dd,-(day(case when id_kupca in ('001373','001466','001458') then dat_zap else datum_dok end)-1), case when id_kupca IN ('001373','001466','001458') then dat_zap else datum_dok end)
			From #najem_fa where ddv_id = @id

			if @id_terj = '21'
			begin 
				Select rep_ind.id_cont, rep_ind.datum, rep_ind.nobrok, p.id_pog, p.prevzeta
				INTO #REP_IND
				From dbo.rep_ind
				inner join dbo.pogodba p on rep_ind.id_cont = p.id_cont
				inner join dbo.nacini_l n on p.nacin_leas = n.nacin_leas
				Where id_rep_ind in (Select max(id_rep_ind) as id_rep_ind From rep_ind where izpisan = 0 group by id_cont)
					and (n.tip_knjizenja='1' or (n.tip_knjizenja='2' and n.finbruto=1 and n.leas_kred='L') or n.leas_kred='K' or p.nacin_leas='F9')
					and rep_ind.id_cont in (Select id_cont From dbo.rac_out where ddv_id = @id)
			
				update #invoice_data set 
				InvoiceDate = b.datum_dok, 
				InvoiceDeliveryDate = b.datum_dok, 
				InvoiceDueDate = b.dat_zap, 
				InvoicePaymentDesc = 'Plaćanje ' + RTRIM(a.opisdok), --TODO PREMA ISPISU
				InvoicePersonIssued = b.ra_izdal,  --TODO PREMA ISPISU
				
				InvoiceTotalNetAmount = case when @tip_leas = 'OL' 
											then b.rac_out_debit_neto + b.rac_out_neobdav   --NAJAMNINA + PPMV
											else b.rac_out_debit_neto + b.rac_out_brez_davka end,  --KAMATA
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit_davek + case when @tip_leas = 'OL' 
														then b.rac_out_debit_neto + b.rac_out_neobdav 
														else b.rac_out_debit_neto + b.rac_out_brez_davka end,
				InvoiceTotalAddCostsAmount = 0, -- case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end ,
				InvoiceTotalPayableAmount = b.rac_out_debit + rac_out_neobdav, -- + case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end,
				InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. Nakon datuma dospijeća, na iznos ' + dbo.gfn_gccif(b.debit) + ' ' +  case when b.id_tec = '000' then rtrim(n.dom_valuta) else b.id_val end + ' zaračunavamo zatezne kamate' + case when b.id_tec = '000' then '.' else ' i primjenjujemo ugovornu valutnu klauzulu ukoliko je ona veća od -/+ ' + dbo.gfn_gccif(l.meja_tr) + ' ' + rtrim(n.dom_valuta) +' koristeći ' + b.naz_tec + '.' end,
				InvoiceNote = case when @tip_leas = 'F1' 
						then case when b.robresti > 0 then 'Glavnica i PPMV po otplatnom planu: ' else 'Glavnica po otplatnom planu: ' end + dbo.gfn_gccif(b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '. UKUPNO ZA PLATITI S GLAVNICOM I PPMV-OM: ' + dbo.gfn_gccif(b.rac_out_debit + b.rac_out_neobdav + b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '.'
						else '' end
						+ case when r.id_cont is not null then ' Slijedom promjene kamatnog indexa, izvršili smo usklađenje/promjenu leasing ' + case when @tip_leas = 'OL' then 'obroka/rate. Vaš leasing obrok/rata počevši od ' else 'rate/anuiteta. Vaša rata/anuitet počevši od ' end + convert(varchar(10), r.datum, 104) + ' ., iznosi ' + dbo.gfn_gccif(r.nobrok) + ' ' + rtrim(b.id_val) + case when @tip_leas = 'OL' then ' s PDV-om.' else '.' end else '' end
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				left join dbo.nastavit n on 1 = 1 
				left join #REP_IND r on b.ID_CONT = r.ID_CONT
				left join dbo.loc_nast l on 1 = 1

				declare @startdate datetime, @enddate datetime, @rata_type varchar(30), @rata_prije datetime, @rata_poslije datetime, @obnaleto decimal(6,2)
				
				--TODO OVAJ DIO PO LEASING KUĆI
				Select @rata_type =  
				case when (cs.val = 'Anticipative' and dok.id_dokum is null) or (cs.val = 'Decursive' and dok.id_dokum is not null) Then 'Anticipative'
				when (cs.val = 'Decursive' And dok.id_dokum is null) Or (cs.val = 'Anticipative' And dok.id_dokum is not null) Then 'Decursive'
				Else '' End, 
				@rata_prije = pp.datum_prije,
				@rata_poslije = pp1.datum_poslije, 
				@obnaleto = c.obnaleto
				From #invoice_data a 
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				left join dbo.obdobja c on b.id_obd = c.id_obd
				Left Join dbo.custom_settings cs on cs.code = 'BOOKING_CRO_INT_ACCR_TYPE'
				Left Join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
				Left Join dbo.dokument dok on b.id_cont = dok.id_cont and CHARINDEX(dok.id_obl_zav, cs1.val) > 0
				left join (Select id_cont, max(datum_dok) as datum_prije From dbo.planp where datum_dok < @datum_dok and id_terj = @id_terj group by id_cont)pp on b.id_cont = pp.id_cont
				left join (Select id_cont, max(datum_dok) as datum_poslije From dbo.planp where datum_dok > @datum_dok and id_terj = @id_terj group by id_cont)pp1 on b.id_cont = pp1.id_cont
				Where a.ddv_id = @id
				
				--TODO OVAJ DIO PO LEASING KUĆI
				if @rata_type = 'Anticipative'
				begin 
					set @startdate = case when @obnaleto = 12 then @datum_dok2 else @datum_dok end
									
					if @obnaleto = 12 
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok2) - 1 
					end
									
					if @obnaleto <> 12 and (@rata_poslije is null OR Abs(datediff(d, @datum_dok, @rata_poslije - 1) - datediff(d, @datum_dok, DATEADD(mm,12/@obnaleto,@datum_dok) - 1)) >= 5)
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok)						
					end
								
					if @obnaleto <> 12 and (@rata_poslije is not null And Abs(datediff(d, @datum_dok, @rata_poslije - 1) - datediff(d, @datum_dok, DATEADD(mm,12/@obnaleto,@datum_dok) - 1)) < 5)
					begin 
						set @enddate = @rata_poslije - 1
					end
							
				end
								
				--TODO OVAJ DIO PO LEASING KUĆI
				if @rata_type = 'Decursive'
				begin
					set @enddate = @datum_dok
									
					if @obnaleto = 12 
					begin
						--set @startdate = DATEADD(mm,-12/@obnaleto,@datum_dok) + case when @rata_prije is null then 0 else 1 end
						--set @startdate = @datum_dok2
						SET @startdate = CASE WHEN @rata_prije IS NULL THEN CASE WHEN dbo.gfn_GetLastDayOfMonth(@datum_dok) = @datum_dok THEN dbo.gfn_GetFirstDayOfMonth(@datum_dok) ELSE DATEADD(mm,-12/@obnaleto,@datum_dok) + 1 END ELSE @rata_prije + 1 END
					end
									
					if @obnaleto <> 12 and (@rata_prije is null OR Abs(datediff(d, @rata_prije + 1, @datum_dok) - datediff(d, DATEADD(mm,-12/@obnaleto,@datum_dok) + 1, @datum_dok)) >= 5)
					begin 
						set @startdate = DATEADD(mm,-12/@obnaleto,@datum_dok) + 1
					end
								
					if @obnaleto <> 12 and (@rata_prije is not null And Abs(datediff(d, @rata_prije + 1, @datum_dok) - datediff(d, DATEADD(mm,-12/@obnaleto,@datum_dok) + 1, @datum_dok)) < 5)
					begin
						set @startdate = @rata_prije + 1
					end
				end
			
				update #invoice_data set  InvoicePeriodStartDate = @startdate, InvoicePeriodEndDate = @enddate
				
		                set @xml = (Select Name, Value 
							From (
								Select 'Broj šasije' as Name,
								rtrim(c.st_sas) as Value
								From dbo.najem_fa a
								inner join dbo.pogodba b on a.ID_CONT = b.ID_CONT 
								inner join dbo.gv_Zapisniki c on b.ID_CONT = c.id_cont
								where a.ddv_id = @Id and c.se_registrira = 1
							) res
							FOR XML PATH ('LineAddProperty'), ROOT('ArrayOfLineAddProperty')
							)
				-- 23.12.2021 g_tomislav MID 47648 - popravak prikaza Value elemnata u slučaju kada su prazni
				set @addPropertyXml = replace(replace(replace(CAST(@xml as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' ),'<Value/>','<Value xmlns="urn:gmc:ui"/>')

				if @tip_leas = 'F1'
				begin
					
					/*DODATNI TROŠKOVI NA RAČUNU*/
					--TODO PO FIRMI ZA SADA JE ZAJEDNO GLAVNICA + PPMV
					--set  @xml = (
					--Select AddCostName, AddCostAmount
					--From (
					--	Select case when robresti > 0 then 'Glavnica i PPMV po otplatnom planu' else 'Glavnica po otplatnom planu' end as AddCostName,
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
						rtrim(cast(b.zap_obr as varchar(10))) + '. Kamata za razdoblje' as LineDesc,  --TODO AKO JE UBLEN MOŽE SE STAVITI I PERIOD U OPIS STAVKE
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

				if @tip_leas = 'OL'
				begin 
					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						rtrim(cast(b.zap_obr as varchar(10))) + '. ' + rtrim('Oporezivi dio leasing obroka za razdoblje') as LineDesc, 
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
						--left join dbo.OBDOBJA o on p.ID_OBD = o.id_obd
						where b.ddv_id = @id  
							union all
						Select @id_terj +'-PPMV' as LineItemIdent, 
						'Neoporezivi dio leasing obroka (PPMV):' as LineDesc, 
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
						--left join dbo.OBDOBJA o on p.ID_OBD = o.id_obd
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
				
				drop table #REP_IND
			end

			--INTERKALARNE IZ MODULA
			if @id_terj != '21' 
			begin
				
				update #invoice_data set 
				InvoiceDate = b.datum_dok, 
				InvoiceDeliveryDate = b.datum_dok, 
				InvoiceDueDate = b.dat_zap, 
				InvoicePaymentDesc = case when g.saldo is not null and g.saldo = 0 then 'PLAĆENO!' else 'Plaćanje ' + RTRIM(case when @tip_leas = 'OL' and c.sif_terj = 'SFIN' then 'Pripadajući dio leasing obroka za razdoblje korištenja'
								   when @tip_leas = 'F1' and c.sif_terj = 'SFIN' then 'Interkalarna kamata za razdoblje'
								   else c.naziv
							  end) end, --TODO PREMA ISPISU
				InvoicePersonIssued = b.ra_izdal,  --TODO PREMA ISPISU
				InvoiceTotalNetAmount = b.rac_out_debit_neto + b.rac_out_brez_davka + b.rac_out_neobdav,  
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit + b.rac_out_neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = b.rac_out_debit + rac_out_neobdav,
				InvoiceNote = '',
				InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate.'
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				inner join dbo.VRST_TER c on b.ID_TERJ = c.id_terj
				left join dbo.planp g on b.st_dok = g.st_dok

					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj+'P' as LineItemIdent, 
						RTRIM(case when @tip_leas = 'OL' and d.sif_terj = 'SFIN' then 'Pripadajući dio leasing obroka za razdoblje korištenja'
								   when @tip_leas = 'F1' and d.sif_terj = 'SFIN' then 'Interkalarna kamata za razdoblje'
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
						Select @id_terj+'0' as LineItemIdent, 
						RTRIM(case when @tip_leas = 'OL' and d.sif_terj = 'SFIN' then 'Pripadajući dio leasing obroka za razdoblje korištenja'
								   when @tip_leas = 'F1' and d.sif_terj = 'SFIN' then 'Interkalarna kamata za razdoblje'
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
						Select @id_terj+'N' as LineItemIdent, 
						case when d.ima_robresti = 1 then 'POSEBAN POREZ NA MOTORNA VOZILA' 
							else RTRIM(case when @tip_leas = 'OL' and d.sif_terj = 'SFIN' then 'Pripadajući dio leasing obroka za razdoblje korištenja'
										when @tip_leas = 'F1' and d.sif_terj = 'SFIN' then 'Interkalarna kamata za razdoblje'
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
				InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.neobdav,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = case when b.id_dav_op = 'NM' then 'Vrijednost objekta leasinga: '+ dbo.gfn_gccif(d.brez_davka) + ' ' + rtrim(n.dom_valuta) else 'Vrijednost objekta leasinga bez PDV-a: '+ dbo.gfn_gccif(d.debit_neto) + ' ' + rtrim(n.dom_valuta) end +
							  case when d.debit_davek > 0 then ', Iznos PDV-a: '+ dbo.gfn_gccif(d.debit_davek) + ' ' + rtrim(n.dom_valuta) else '' end +
							  case when d.neobdav > 0 then
									case when vo.se_regis = '*' then ', Posebni porez na motorna vozila (PPMV): ' else ', Neoporezivi dio:' end
									+ dbo.gfn_gccif(d.neobdav) + ' ' + rtrim(n.dom_valuta) else '' end +
							  ', Ukupno: '+ dbo.gfn_gccif(d.debit+d.neobdav) + ' ' + rtrim(n.dom_valuta) + '.' +
							  case when e.debit > 0 then CHAR(10) + 'SPECIFIKACIJA PREDUJMOVA' + CHAR(10) + ltrim(rtrim(b.kk_memo)) + ' - Osnova: ' + dbo.gfn_gccif(e.debit_neto) + ' ' + rtrim(n.dom_valuta) + ', PDV: ' + dbo.gfn_gccif(e.debit_davek) + ' ' + rtrim(n.dom_valuta) + ', Ukupno: ' + dbo.gfn_gccif(e.debit) + ' ' + rtrim(n.dom_valuta) + CHAR(10) + 'Sveukupno - Osnova: '+ dbo.gfn_gccif(a.debit_neto) + ' ' + rtrim(n.dom_valuta)+ ', PDV: ' + dbo.gfn_gccif(a.debit_davek) + ' ' + rtrim(n.dom_valuta) + case when a.neobdav > 0 and vo.se_regis = '*' then ', PPMV: ' + dbo.gfn_gccif(a.neobdav) + ' ' + rtrim(n.dom_valuta) else '' end + ', Ukupno: ' + case when vo.se_regis = '*' then dbo.gfn_gccif(a.debit+a.neobdav) else dbo.gfn_gccif(a.debit) end + ' ' + rtrim(n.dom_valuta) else '' end +
						     CHAR(10) + 'Račun ne može služiti za prijenos vlasništva bez originalne Potvrde ' + rtrim(@p_podjetje) + ' o ispunjenju svih obveza korisnika po predmetnom ugovoru.',
				InvoicePaymentNote = 'Na zakašnjela plaćanja obračunavamo ugovorenu zateznu kamatu, kao i eventualno nastalu tečajnu razliku prema Općim uvjetima o leasingu.'
				From #invoice_data a
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				left join dbo.nastavit n on 1 = 1
				inner join dbo.vrst_opr vo ON b.id_vrste = vo.id_vrste
				left join (SELECT c.id_cont, SUM(c.debit) AS debit, SUM(c.debit_neto) AS debit_neto, SUM(c.debit_davek) AS debit_davek, SUM(c.neobdav) AS neobdav, SUM(c.brez_davka) AS brez_davka
							FROM(SELECT p.id_cont, r.debit, r.debit_neto, r.debit_davek, r.brez_davka, r.neobdav 
								FROM dbo.pogodba p INNER JOIN dbo.rac_out r ON p.ddv_id = r.ddv_id 
								UNION ALL
								SELECT p.ID_CONT, r.debit, r.debit_neto, r.debit_davek, r.brez_davka, r.neobdav 
								FROM dbo.pogodba p INNER JOIN dbo.rac_out r ON p.id_cont = r.id_cont AND CHARINDEX(RTRIM(r.ddv_id), p.kk_memo) != 0 
								) c GROUP BY c.ID_CONT)d ON a.id_cont = d.id_cont
				left join (SELECT p.id_cont, SUM(debit) as debit, SUM(debit_neto) as debit_neto, SUM(debit_davek) AS debit_davek 
							FROM dbo.pogodba p INNER JOIN dbo.rac_out r on p.id_cont = r.id_cont AND CHARINDEX(RTRIM(r.ddv_id), p.kk_memo) != 0 GROUP BY p.id_cont) e ON a.id_cont = e.id_cont
				
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
						'PPMV - POSEBNI POREZ NA MOTORNA VOZILA (prolazna stavka)' as LineDesc,  
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
							case when a.NEOBDAV > 0 and rtrim(c.opis_tuj1) != 'NO' then '' else rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) end as TaxNote
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
				InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit,
				InvoiceType = '386',
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = 'Temeljem primljene uplate od ' + isnull(convert(varchar(10), c.dat_pl, 104),'') + ', a za Vašu knjigovodstvenu evidenciju, ispostavljamo Vam račun za primljeni predujam.' ,
				InvoicePaymentNote = '' -- TODO PO FIRMAMA, ALI KOD AVANSA NEMA PLAĆANJA
				From #invoice_data a 
				left join dbo.avansi av on a.ddv_id = av.ddv_id
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				left join dbo.placila c on av.id_plac = c.id_plac 
				
				
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 
						'PREDUJAM' as LineItemIdent,
						'Predujam po ugovoru' as LineDesc,  --TODO podesiti po firmama
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
				InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.BREZ_DAVKA + a.neobdav) else (a.debit_neto + a.BREZ_DAVKA + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om
				InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
				InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav) else (a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om,
				--PRIJE PROMJENE DA SVE MORA BITI NEGATIVNO DA BI BIO CREDIT NOTE 
				--InvoiceType = case when (a.DEBIT + a.BREZ_DAVKA) < 0 or ((a.DEBIT + a.BREZ_DAVKA) = 0 and a.NEOBDAV < 0) then '381' else '383' end,
				InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else '383' end,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = 'Ovim putem vršimo promjenu porezne osnovice računa navedenog u referenci na prethodni račun.',
				InvoicePaymentNote = '', --TODO podesiti sukladno odobrenje/terećenje
				document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end
				From #invoice_data a
				--inner join dbo.pogodba b on a.id_cont = b.id_cont
				
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

		-- ISPIS NIJE PODEŠEN KAO INVOICE
		if @source = 'REP_IND'
		begin
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.DDV_DATE, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
				InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
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
				InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = 'Specifikacija obračuna zatezne kamate u prilogu.' ,
				InvoicePaymentNote = 'Neupisivanje poziva na broj ima za posljedicu neevidentiranje Vaše uplate.' -- TODO PO FIRMAMA
				From #invoice_data a 
				inner join dbo.ZOBR_FA z on a.ddv_id = z.ddv_id
				inner join dbo.pogodba b on a.id_cont = b.id_cont
					
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 'ZOBP' as LineItemIdent, 
						'ZATEZNA KAMATA' as LineDesc, --TODO Provjeriti po ispisima
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
						'ZATEZNA KAMATA' as LineDesc, --TODO Provjeriti po ispisima
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
						'ZATEZNA KAMATA' as LineDesc, 
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

		--
		if @source IN ('ZA_OPOM', 'DOK_OPOM')
		begin
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.valuta, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentId = 'HR01 '+ b.sklic, --TODO provjeriti na ispisu zbog trećih osoba
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO NAPUNITI TEKST
				InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote =  case when z.id_opom is not null then 'Upozoravamo Vas da ćemo, u slučaju nepodmirenja Vaših obveza, a sukladno ugovornim odredbama i pozitivnim zakonskim propisima, biti prinuđeni naplatiti se po predanim instrumentima osiguranja plaćanja i to bez slanja bilo kakve daljnje opomene što će Vam prouzročiti dodatne nepotrebne troškove.'
									when x.DDV_ID is not null then 'Obavještavamo vas da po Ugovoru ' + rtrim(b.id_pog) + ' do sada nismo primili neophodnu dokumentaciju.'
									else '' end,
				InvoicePaymentNote = '' -- TODO PO FIRMAMA
				From #invoice_data a 
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				left join dbo.za_opom z on a.DDV_ID = z.ddv_id
				left join (Select ddv_id, st_opomin From dbo.dok_opom group by ddv_id, st_opomin) x on a.ddv_id = x.ddv_id
				
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

		--ISPIS JOŠ NIJE NAPRAVLJEN
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
			InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.neobdav,
			InvoiceNote = rtrim(isnull(c.opombe, '')), --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO 
			InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu.' --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO
			From #invoice_data a
			inner join dbo.pogodba b on a.id_cont = b.id_cont 
			inner join dbo.OPC_FAKT c on a.DDV_ID = c.DDV_ID
			left join dbo.tecajnic t on c.id_tec = t.id_tec
					
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
					'PPMV - POSEBNI POREZ NA MOTORNA VOZILA (prolazna stavka)' as LineDesc,  
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

		--NEMAJU DOBAR ISPIS
		if @source = 'ZA_REGIS'
		begin

			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = a.VALUTA, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.neobdav,
			InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo ugovorenu zateznu kamatu.',
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
			InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.neobdav) else (a.debit_neto + a.brez_davka + a.neobdav) end, 
			InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
			InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.debit_davek + a.neobdav) else (a.debit_neto + a.brez_davka + a.debit_davek + a.neobdav) end,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = 'Specifikacija obračuna tečajnih razlika je u prilogu.' ,
			InvoicePaymentNote = '', -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end -- TODO AKO JE TEČAJNA NEGATIVNA MORA BITI CREDIT NOTE
			From #invoice_data a 
			inner join dbo.pogodba b on a.id_cont = b.id_cont
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
					rtrim(cast(isnull(a.klavzula,'PDV nije obračunat sukladno Članku 40 stavak (1) točka b) Zakona o porezu na dodanu vrijednost.') as varchar(max))) as LineTaxNote, 
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
					rtrim(cast(isnull(a.klavzula,'PDV nije obračunat sukladno Članku 40 stavak (1) točka b) Zakona o porezu na dodanu vrijednost.') as varchar(max))) as LineTaxNote, 
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
					rtrim(cast(isnull(a.klavzula,'PDV nije obračunat sukladno Članku 40 stavak (1) točka b) Zakona o porezu na dodanu vrijednost.') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.brez_davka <> 0 and a.NEOBDAV = 0
						union all
					Select 
					'OP' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or (a.neobdav > 0 and a.brez_davka > 0) then abs(a.neobdav + a.brez_davka) else (a.neobdav + a.brez_davka) end as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'PDV nije obračunat sukladno Članku 40 stavak (1) točka b) Zakona o porezu na dodanu vrijednost.') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.BREZ_DAVKA <> 0 and a.neobdav <> 0 
						union all
					Select 
					'NO' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then abs(a.neobdav) else (a.neobdav) end as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'PDV nije obračunat sukladno Članku 40 stavak (1) točka b) Zakona o porezu na dodanu vrijednost.') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.neobdav <> 0 and a.BREZ_DAVKA = 0
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
			InvoicePaymentId = 'HR01 '+ b.sklic, --TODO provjeriti na ispisu zbog trećih osoba
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = rtrim(isnull(f.rep,'')) ,
			InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo ugovorenu zateznu kamatu.' -- TODO PO FIRMAMA
			From #invoice_data a 
			inner join dbo.pogodba b on a.id_cont = b.id_cont
			inner join dbo.fakture f on a.ddv_id = f.ddv_id
			left join dbo.tecajnic t on f.id_tec = t.id_tec

				/*STAVKE*/
				set  @xml = (
				Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
				LineAmount,LineTaxNote,LineTaxName
				From (
					Select fp.id_post as LineItemIdent, 
					case when f.id_terj in ('29', '30', '52', '63') then  
						case when fp.robresti > 0 then 'PPMV' else case when f.ID_TERJ = '29' then 'OSTACI OBJEKTA ' else '' end + rtrim(d.PRED_NAJ) end
					else 
						rtrim(fp.opis) end as LineDesc, --TODO Provjeriti po ispisima
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
					inner join dbo.pogodba d on a.ID_CONT = d.ID_CONT 
				) a
				FOR XML PATH ('InvoiceLine'), ROOT('ArrayOfInvoiceLine')  )

				set @invoiceLineXml = cast(@xml as varchar(max))

				--29.01.2021 g_tomislav MR 45974 - prikaz elemenata zapisnika za fakturu otkupa u addPropertyXml
				--25.02.2021 g_tomislav MR 46469 - popravak prikaza Value elemnata u slučaju kada su prazni
				
				declare @print_stav bit, @print_txt varchar(max)
				select @print_stav = case when f.id_terj in ('29', '30', '52', '63') then 0 else 1 end 
					, @print_txt = CASE WHEN f.id_terj = '29' THEN 'Ostaci objekta leasinga prodani po principu viđeno - kupljeno:' ELSE 'Rabljeni objekt leasinga prodan po principu viđeno - kupljeno:' END 
				from #invoice_data a inner join dbo.fakture f on a.ddv_id = f.ddv_id
				cross apply (select id_zapo from dbo.gv_Zapisniki where id_cont = a.id_cont) gvz --ako nema zapisnika, @print_stav će biti null i neće se pripremati @addPropertyXml
				
				if @print_stav = 0 --logika kao na ispisu SPL_FAK_SSOFT_UCL. Priprema se samo ako ima zapisnika, zato ne treba hendlat NULL polja ako nema zapisnika 
				begin 
					declare @print_str tinyint, @tip_opr char(1), @print_identicar bit, @znamka varchar(100), @tip varchar(100), @st_sas varchar(100), @st_mot varchar(100), @let_pro varchar(10), @identicar varchar(50), @opis_zn varchar(max), @let_pro_zn varchar(10), @ser_st varchar(200), @plov_voz varchar (20)
					
					select @print_str = case when k.se_regis = '*' then 1 else 2 end 
						, @tip_opr = k.tip_opr 
						, @znamka = rtrim(zr.znamka)
						, @tip = rtrim(zr.tip)
						, @st_sas = rtrim(zr.st_sas)
						, @st_mot = rtrim(zr.st_mot)
						, @let_pro = rtrim(zr.let_pro)
						, @print_identicar = CASE WHEN k.tip_opr = 'P' and zr.identicar != '' THEN 1 ELSE 0 END
						, @identicar = rtrim(zr.identicar)
						, @opis_zn = rtrim(coalesce(zn.opis, ''))
						, @let_pro_zn = rtrim(zn.let_pro)
						, @ser_st = rtrim(zn.ser_st)
						, @plov_voz = case when @tip_opr = 'P' then 'plovila' else 'vozila' end
					from #invoice_data a
					inner join dbo.pogodba d on a.id_cont = d.id_cont 
					inner join dbo.vrst_opr k on d.id_vrste = k.id_vrste
					left join dbo.gfn_zap_reg_single_per_contract() zr on a.id_cont = zr.id_cont
					left join dbo.gfn_zap_ner_single_per_contract() zn on a.id_cont = zn.id_cont
						
					if @print_str = 1 --1. registracija. Ako polje može biti null, treba staviti coalesce ili isnull
					begin 
						
						set @xml = (select Name, Value
									From (select @print_txt as Name, '' as Value, 0 as o
									union all 
									select 'Marka ' + @plov_voz +':' as Name, @znamka as Value, 1 as o 
									union all 
									select 'Tip ' + @plov_voz +':' as Name, @tip as Value , 2 as o
									union all 
									select 'Broj ' + case when @tip_opr = 'P' then 'trupa' else 'šasije' end +':' as Name, @st_sas as Value, 3 as o 
									union all 
									select 'Broj motora:' as Name, @st_mot as Value, 4 as o Where @tip_opr = 'P'
									union all 
									select 'God. proizvodnje:' as Name, @let_pro as Value, 5 as o
									union all 
									select 'Ime plovila:' as Name, @identicar as Value, 6 as o where @print_identicar = 1
									) x
									Order by x.o
									for xml path('LineAddProperty'), root('ArrayOfLineAddProperty'))
					end
					
					else --2. oprema
					
					begin 
						set @xml = (Select Name, Value
									From (select @print_txt as Name, '' as Value,0 as o
									union all 
									select 'Opis:' as Name, @opis_zn as Value,1 as o 
									union all 
									select 'Godina proizvodnje:' as Name, @let_pro_zn as Value,2 as o 
									union all 
									select 'Serijski broj:' as Name, @ser_st as Value,3 as o 
									)x
									order by x.o
									for xml path('LineAddProperty'), root('ArrayOfLineAddProperty'))
					end
						
					set @addPropertyXml = replace(replace(replace(CAST(@xml as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' ),'<Value/>','<Value xmlns="urn:gmc:ui"/>')	
				end
				
				else 
				
				begin
					set @addPropertyXml = ''
				end
				
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

		if @source = 'GL_OUTPUT_R'
		begin
			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = a.valuta, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentId = 'HR01 '+ b.sklic, --TODO provjeriti na ispisu zbog trećih osoba
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.debit_opr + a.debit_izv + a.neobdav) else (a.debit_neto + a.brez_davka + a.debit_opr + a.debit_izv + a.neobdav) end, 
			InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
			InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = rtrim(isnull(b.rep,'')) ,
			InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu sukladno zakonu.', -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end
			From #invoice_data a 
			inner join dbo.gl_output_r b on a.ddv_id = b.DDV_ID 
			left join dbo.tecajnic t on b.id_tec = t.id_tec

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
		InvoiceTotalAddCostsAmount, InvoiceTotalPayableAmount, document_external_type, InvoiceOrderReference, 
		replace(replace(@referencesXml,'<ReferenceId>', '<ReferenceId xmlns="urn:gmc:ui">'),'<ReferenceIssueDate>', '<ReferenceIssueDate xmlns="urn:gmc:ui">') as referencesXml,
		replace(replace(replace(replace(replace(@taxTotalXml, '<TaxName>', '<TaxName xmlns="urn:gmc:ui">'), '<TaxBase>', '<TaxBase xmlns="urn:gmc:ui">'), '<TaxNote>', '<TaxNote xmlns="urn:gmc:ui">'), '<TaxRate>', '<TaxRate xmlns="urn:gmc:ui">'), '<TaxAmount>', '<TaxAmount xmlns="urn:gmc:ui">') as taxTotalXml,
		replace(replace(@addCostXml,'<AddCostName>','<AddCostName xmlns="urn:gmc:ui">'),'<AddCostAmount>','<AddCostAmount xmlns="urn:gmc:ui">') as addCostXml, 
		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@invoiceLineXml, '<LineDesc>', '<LineDesc xmlns="urn:gmc:ui">'),'<LineQuantityUnit>', '<LineQuantityUnit xmlns="urn:gmc:ui">'),'<LineQuantity>', '<LineQuantity xmlns="urn:gmc:ui">'),'<LineNetPrice>', '<LineNetPrice xmlns="urn:gmc:ui">'),'<LineNetTotal>', '<LineNetTotal xmlns="urn:gmc:ui">'),'<LineTaxRate>', '<LineTaxRate xmlns="urn:gmc:ui">'),'<LineTaxAmount>', '<LineTaxAmount xmlns="urn:gmc:ui">'),'<LineAmount>', '<LineAmount xmlns="urn:gmc:ui">'),'<LineTaxNote>', '<LineTaxNote xmlns="urn:gmc:ui">'),'<LineTaxName>', '<LineTaxName xmlns="urn:gmc:ui">'),'<LineItemIdent>', '<LineItemIdent xmlns="urn:gmc:ui">') as invoiceLineXml, 
                @addPropertyXml as lineAddPropertiesXml		
                From #invoice_data

		drop table #invoice_data

	end
end