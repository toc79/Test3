-- [[TAX_ID=46550671661]]
DECLARE @id_object varchar(100)
SET @id_object = (SELECT id_object FROM dbo.reports_log WHERE edoc_file_name = @OriginalFileName AND id_object_edoc = @id)

--ovo se koristi samo za 'Contract'ESL_PAR_REG_OZN
declare @id_reports_log int
set @id_reports_log = (SELECT id_reports_log FROM dbo.reports_log WHERE edoc_file_name = @OriginalFileName and doc_type = 'Contract' and id_object_edoc = @Id)

declare @is_for_fina bit

set @is_for_fina = (Select cast(count(*) as bit) 
                      From dbo.partner a 
					  inner join dbo.rac_out b on a.id_kupca = b.id_kupca
					  where a.ident_stevilka is not null and a.ident_stevilka <> '' and b.ddv_id = @id and @DocType='Invoice') 
					  
-- MID: 45714 g_barbarak; u print_centar_name se više ne gleda id_reg iz poste, već uvijek ide HP
-- MID: 45863 g_barbarak - Contract su podešeni na AllowAll
-- MID: 47921 g_vuradin - dodavanje nove vrste računa id_terj=31 za slanje u printcentar
-- MID: 48944 g_josip - ispravak suma poreza na općim računima te popravak opisa za id_terj 77
-- 24.01.2022 g_tomislav TID 12259 - added report INDIVIDUALNA_OBAV_SSOFT_ESL
-- 11.05.2023 g_tomislav MID 48870 - eksport za DMS
-- 22.12.2023 g_tomislav MID 51297 - dodan report PLANP_RPG_SSOFT_ESL

if @DocType = 'Invoice'
begin
	Select 
	'Račun br. ' + RTRIM(rac_out.ddv_id) as [gmi.earchive.doc_title],
	RTRIM(rac_out.opisdok) as [gmi.earchive.doc_description],
	CASE WHEN b.source = 'NAJEM_FA' THEN coalesce(rtrim(upper(v.naziv)), 'RAČUNI ZA RATE (RATE, AKONTACIJA, TROŠAK OBRADE)')
	WHEN b.source = 'ZOBR_FA' THEN 'ZATEZNE KAMATE'
	WHEN b.source = 'AVANSI' THEN 'RAČUNI PREDUJMOVA NEAKTIVNIH UGOVORA'
	WHEN b.source = 'OPC_FAKT' THEN 'RAČUNI ZA OTKUP'
	WHEN b.source = 'FAKTURE' THEN 'OPĆI RAČUNI'
	WHEN b.source = 'POGODBA' THEN 'RAČUNI ZA AKTIVACIJU UGOVORA'
	WHEN b.source = 'GL_OUTPUT_R' THEN 'RAČUNI IZ GLAVNE KNJIGE'
	WHEN b.source = 'TEC_RAZL' THEN 'RAČUNI ZA VALUTNE KLAUZULE'
	WHEN b.source = 'PLANP' THEN 'RAČUNI IZ PLANA OTPLATE'
	WHEN b.source = 'ZA_OPOM'  THEN 'RAČUN ZA OPOMENU'
	WHEN b.source = 'SPR_DDV' THEN 'PROMIJENA POREZNE OSNOVICE'
	ELSE 'OSTALI RAČUNI' END as [tip_dokumenta],
	RTRIM(partner.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
	CASE WHEN (b.source in ('NAJEM_FA', 'ZOBR_FA', 'AVANSI', 'TEC_RAZL') OR (b.source = 'GL_OUTPUT_R' and rac_out.id_dav_st = 'AV') or (b.source='FAKTURE' and fk.id_terj='31') or (b.source = 'ZA_OPOM' and o.st_opomina != 3)) and @is_for_fina = 0 THEN 1 
	ELSE 0 END as [edoc.for_print_centar],
	case when @is_for_fina = 0 then 1 else 0 end as [edoc.export_earchive],
	rtrim(rac_out.st_dok) as st_dok,
	case when b.source = 'POGODBA' then '0001' 
		when b.source = 'OPC_FAKT' then '0004'
		else '' end 
	 as [tip_dokumenta_dms],
	case when b.source in ('POGODBA', 'OPC_FAKT') then 1 else 0 end as [edoc.dms]
	From dbo.partner 
	inner join dbo.rac_out on partner.id_kupca = rac_out.id_kupca 
	inner join (Select a.ddv_id, dbo.gfn_GetInvoiceSource(a.ddv_id) as source
		  From dbo.rac_out a 
		  Where a.ddv_id =  @Id and @DocType='Invoice'
	) b on rac_out.ddv_id = b.ddv_id
	left join dbo.najem_fa c on rac_out.ddv_id = c.ddv_id
	left join dbo.vrst_ter v on c.id_terj = v.id_terj
	left join dbo.fakture fk on fk.ddv_id=rac_out.ddv_id
	--left join dbo.poste p on partner.id_poste = p.id_poste 
        left join (
            Select a.*
            From dbo.reports_log a
            inner join (
                  Select min(id_reports_log) as id_reports_log
                  from dbo.reports_log 
                  where id_object_edoc is not null
                  and doc_type = @DocType and id_object_edoc = @Id
            )b on a.id_reports_log = b.id_reports_log

        ) x on x.id_object_edoc = @Id and x.doc_type = @DocType
	left join dbo.gv_za_opom_with_arh o on rac_out.ddv_id = o.ddv_id 
	Where rac_out.ddv_id =  @Id and @DocType='Invoice'
end

if @DocType = 'TaxChngIx'
begin
	Select 
		'Obavijest o indeksaciji ugovor ' + RTRIM(p.id_pog) + ' ' + CONVERT(char(10), r.datum, 104) as [gmi.earchive.doc_title], 
		'Obavijest o indeksaciji br. ' + RTRIM(r.st_dok) as[gmi.earchive.doc_description], 
		'OBAVIJEST O PROMJENI INDEKSA' as [tip_dokumenta], 
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		0 as [edoc.dms]
	from dbo.partner par 
	inner join dbo.rep_ind r on par.id_kupca = r.id_kupca 
	inner join dbo.gv_PogodbaAll p on r.id_cont = p.id_cont 
	--left join dbo.poste po on par.id_poste = po.id_poste  
        left join (
            Select a.*
            From dbo.reports_log a
            inner join (
                  Select min(id_reports_log) as id_reports_log
                  from dbo.reports_log 
                  where id_object_edoc is not null
                  and doc_type = @DocType and id_object_edoc = @Id
            )b on a.id_reports_log = b.id_reports_log
        ) x on x.id_object_edoc = @Id and x.doc_type = @DocType
	where cast(r.id_rep_ind as varchar(100)) = @Id and @DocType = 'TaxChngIx'
end

if @DocType = 'TaxChange'
begin
	Select rtrim(r.st_dok) as st_dok, 
		'Promijena porezne osnovice ' + RTRIM(p.id_pog) + ' ' + CONVERT(char(10), r.datum, 104) as [gmi.earchive.doc_title], 
		'Promijena porezne osnovice ' + RTRIM(r.st_dok) as [gmi.earchive.doc_description], 
		'PROMIJENA POREZNE OSNOVICE' as [tip_dokumenta], 
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive], 
		0 as [edoc.dms]
	from dbo.partner par 
	inner join dbo.spr_ddv r on par.id_kupca = r.id_kupca 
	inner join dbo.gv_PogodbaAll p on r.id_cont = p.id_cont 
	--left join dbo.poste po on par.id_poste = po.id_poste  
        left join (
            Select a.*
            From dbo.reports_log a
            inner join (
                  Select min(id_reports_log) as id_reports_log
                  from dbo.reports_log 
                  where id_object_edoc is not null
                  and doc_type = @DocType and id_object_edoc = @Id
            )b on a.id_reports_log = b.id_reports_log

        ) x on x.id_object_edoc = @Id and x.doc_type = @DocType
	where cast(r.id_spr_ddv as varchar(100)) = @Id and @DocType = 'TaxChange'
end

if @DocType = 'Reminder'
begin 
	Select 
		CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni za ugovor ' ELSE 'Račun za troškove opomene za ugovor ' END + RTRIM(b.id_pog) + ' ' + CONVERT(char(10), a.datum_dok, 104) as [gmi.earchive.doc_title],
		CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni br. ' + RTRIM(a.dok_opom) Else 'Račun za troškove opomene br. ' + RTRIM(a.ddv_id) END  as [gmi.earchive.doc_description],
		CASE WHEN a.ddv_id is null THEN 'OBAVIJEST O OPOMENI' ELSE 'RAČUN ZA OPOMENU' END as [tip_dokumenta],
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
		CASE WHEN a.st_opomina != 3 THEN 1 ELSE 0 END as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		RTRIM(par.dav_stev) as oib, 
		0 as [edoc.dms]
	from dbo.za_opom a
	left join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont 
	left join dbo.partner par on a.id_kupca = par.id_kupca
	--left join dbo.poste p on par.id_poste = p.id_poste 
        left join (
            Select a.*
            From dbo.reports_log a
            inner join (
                  Select min(id_reports_log) as id_reports_log
                  from dbo.reports_log 
                  where id_object_edoc is not null
                  and doc_type = @DocType and id_object_edoc = @Id
            )b on a.id_reports_log = b.id_reports_log
        ) x on x.id_object_edoc = @Id and x.doc_type = @DocType
	where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'Reminder'

	UNION ALL

	Select 
		CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni za ugovor ' ELSE 'Račun za troškove opomene za ugovor ' END + RTRIM(b.id_pog) + ' ' + CONVERT(char(10), a.datum_dok, 104) as [gmi.earchive.doc_title],
		CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni br. ' + RTRIM(a.dok_opom) Else 'Račun za troškove opomene br. ' + RTRIM(a.ddv_id) END  as [gmi.earchive.doc_description],
		CASE WHEN a.ddv_id is null THEN 'OBAVIJEST O OPOMENI' ELSE 'RAČUN ZA OPOMENU' END as [tip_dokumenta],
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
		CASE WHEN a.st_opomina != 3 THEN 1 ELSE 0 END as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		rtrim(par.dav_stev) as oib, 
		0 as [edoc.dms]
	from dbo.arh_za_opom a
	left join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont 
	left join dbo.partner par on a.id_kupca = par.id_kupca 
	--left join dbo.poste p on par.id_poste = p.id_poste 
        left join (
            Select a.*
            From dbo.reports_log a
            inner join (
                  Select min(id_reports_log) as id_reports_log
                  from dbo.reports_log 
                  where id_object_edoc is not null
                  and doc_type = @DocType and id_object_edoc = @Id
            )b on a.id_reports_log = b.id_reports_log
        ) x on x.id_object_edoc = @Id and x.doc_type = @DocType
	where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'Reminder'
end

if @DocType = 'General' And @ReportName = 'IZJ_POPL_SSOFT'
begin 
	Select
		'Potvrda o kupoprodaji FL ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Potvrda o kupoprodaji FL ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description],
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'POTVRDA O KUPOPRODAJI FL' as [tip_dokumenta],
		rtrim(par.dav_stev) as oib,
		p.id_cont, RTRIM(p.id_pog) as id_pog, RTRIM(p.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		b.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0002' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.pogodba p
	inner join dbo.partner par on p.id_kupca = par.id_kupca
	--MID 41776 JOIN pogodbe i reports_log radimo po id_object a ne @id (što je id_object_edoc a kako bi obradili i ispisi istog doctype i istog id-ja u SSOFT ispisu (u ovom slučaju id_cont)
	--za takve slučajeve id_object_edoc mora biti jedinstven što je za ove slučajeve riješeno dodavanjem naziva SSOFT ispisa na id u reports_edoc_settings.edoc_id_lookup
	inner join dbo.reports_log b on cast(p.id_cont as varchar(100)) = b.id_object And b.doc_type = 'General' and b.edoc_file_name = @OriginalFileName AND b.id_object_edoc = @id
	inner join dbo.users u on b.rendered_by = u.username 
	where cast(p.id_cont as varchar(100)) = @id_object and @DocType = 'General'
end

if @DocType = 'General' And @ReportName = 'IZJ_KUP_SSOFT_ESL' 
begin 
	Select
		'Izjava kupca za odjavu vozila ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Izjava kupca za odjavu vozila ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description],
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'IZJAVA KUPCA ZA ODJAVU VOZILA' as [tip_dokumenta],
		rtrim(par.dav_stev) as oib,
		p.id_cont, RTRIM(p.id_pog) as id_pog, RTRIM(par.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		b.rendered_when as datum_ispisa, 
		0 as [edoc.dms]
	from dbo.pogodba p
	inner join dbo.reports_log b on cast(p.id_cont as varchar(100)) = CAST(SUBSTRING(b.id_object, 1, CHARINDEX(';', b.id_object) - 1) as varchar(100)) 
		And b.doc_type = 'General' and b.edoc_file_name = @OriginalFileName
	inner join dbo.partner par on cast(par.id_kupca as varchar(100)) = CAST(SUBSTRING(b.id_object, CHARINDEX(';', b.id_object) + 1, LEN(b.id_object))  as varchar(100))
	where b.id_object_edoc = @id AND @DocType = 'General'
end

if @DocType = 'General' And @ReportName = 'KON_OBR_SSOFT_ESL'
begin 
	Select
		'Konačni obračun ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Konačni obračun ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'KONAČNI OBRAČUN' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		p.id_cont, RTRIM(p.id_pog) as id_pog, RTRIM(par.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		b.rendered_when as datum_ispisa,
		0 as [edoc.dms]
	from dbo.pogodba p
	Inner join dbo.partner par on p.id_kupca = par.id_kupca
	inner join dbo.reports_log b on CAST(p.id_cont as varchar(100)) = REPLACE(@id,'K1','') And b.doc_type = 'General' and b.edoc_file_name = @OriginalFileName
	where b.id_object_edoc = @id AND @DocType = 'General'
end

if @DocType = 'Contract' AND @ReportName = 'OBV_OPC_SSOFT_ESL'
begin 
	Select
		'Obavijest o isteku ugovora o leasingu ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Obavijest o isteku ugovora o leasingu ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(b.rendered_by, '')) + '.pdf' As print_centar_name,
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'OBAVIJEST ZA OTKUP' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		p.id_cont, RTRIM(p.id_pog) as id_pog, RTRIM(par.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		b.rendered_when as datum_ispisa,
		0 as [edoc.dms]
	From dbo.pogodba p
	INNER JOIN dbo.partner par on p.id_kupca = par.id_kupca
	--MID 41776 JOIN pogodbe i reports_log radimo po id_object a ne @id (što je id_object_edoc a kako bi obradili i ispisi istog doctype i istog id-ja u SSOFT ispisu (u ovom slučaju id_cont)
	--za takve slučajeve id_object_edoc mora biti jedinstven što je za ove slučajeve riješeno dodavanjem naziva SSOFT ispisa na id u reports_edoc_settings.edoc_id_lookup
	INNER JOIN dbo.reports_log b on CAST(p.id_cont as varchar(100)) = b.id_object AND b.doc_type = 'Contract' AND b.edoc_file_name = @OriginalFileName AND b.id_object_edoc = @id
	--left join dbo.poste pos on par.id_poste = pos.id_poste 
	where cast(p.id_cont as varchar(100)) = @id_object and @DocType = 'Contract'
end

if @DocType = 'NotifReg' AND @ReportName = 'OBVREGT_SSOFT_ESL'
begin 
	Select
		'PUNOMOĆ I OBAVIJEST O ISTEKU REGISTRACIJE I POLICA OSIGURANJA ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'PUNOMOĆ I OBAVIJEST O ISTEKU REGISTRACIJE I POLICA OSIGURANJA ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description],
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(b.rendered_by, '')) + '.pdf' As print_centar_name, 
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'PUNOMOĆ I DOPIS ZA REGISTRACIJU' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		p.id_cont, RTRIM(p.id_pog) as id_pog, RTRIM(par.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		b.rendered_when as datum_ispisa,
		0 as [edoc.dms]
	From dbo.za_regis a
	INNER JOIN dbo.pogodba p on a.id_cont = p.id_cont
	INNER JOIN dbo.partner par on p.id_kupca = par.id_kupca
	INNER JOIN dbo.reports_log b on CAST(a.id_za_regis as varchar(100)) = @id AND b.doc_type = 'NotifReg' AND b.edoc_file_name = @OriginalFileName
	--left join dbo.poste pos on par.id_poste = pos.id_poste 
	WHERE b.id_object_edoc = @id AND @DocType = 'NotifReg'
end

if @DocType = 'NotifZaPz' AND @ReportName = 'PZ_DOPIS_SSOFT_ESL'
begin 
	Select
		'OBAVIJEST O ISTEKU IMOVINSKOG OSIGURANJA ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'OBAVIJEST O ISTEKU IMOVINSKOG OSIGURANJA ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description],
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(b.rendered_by, '')) + '.pdf' As print_centar_name, 
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'OBAVIJEST O ISTEKU OSIGURANJA' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		p.id_cont, RTRIM(p.id_pog) as id_pog, RTRIM(par.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		b.rendered_when as datum_ispisa,
		0 as [edoc.dms]
	From dbo.za_pz a
	INNER JOIN dbo.pogodba p on a.id_cont = p.id_cont
	INNER JOIN dbo.partner par on p.id_kupca = par.id_kupca
	INNER JOIN dbo.reports_log b on CAST(a.id_za_pz as varchar(100)) = @id AND b.doc_type = 'NotifZaPz' AND b.edoc_file_name = @OriginalFileName
	--left join dbo.poste pos on par.id_poste = pos.id_poste 
	WHERE b.id_object_edoc = @id AND @DocType = 'NotifZaPz'
end

if @DocType = 'General' And @ReportName = 'PREDROPC_SSOFT_ESL'
begin 
	Select
		'Ponuda za otkup ' + RTRIM(op.st_dok) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Ponuda za otkup ' + RTRIM(op.st_dok) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description],
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'PONUDA ZA OTKUP' as [tip_dokumenta],
		rtrim(par.dav_stev) as oib,
		p.id_cont, RTRIM(p.id_pog) as id_pog, RTRIM(p.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		b.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0005' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.opc_fakt op
	inner join dbo.pogodba p on op.id_cont = p.id_cont
	inner join dbo.partner par on op.id_kupca = par.id_kupca
	inner join dbo.reports_log b on b.edoc_file_name = @OriginalFileName 
	inner join dbo.users u on b.rendered_by = u.username 
	where op.st_dok = @id
end

if @DocType = 'Notif'
begin
	Select 
		'Obavijest za rate ' + RTRIM(a.st_dok) as [gmi.earchive.doc_title], 
		'Obavijest za rate ' + RTRIM(a.st_dok) as [gmi.earchive.doc_description], 
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(b.rendered_by, '')) + '.pdf' As print_centar_name, 		
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'OBAVIJEST ZA RATE' as [tip_dokumenta], 
		0 as [edoc.dms]
	From dbo.najem_ob a
	INNER JOIN dbo.partner par ON a.id_kupca = par.id_kupca
	--INNER JOIN dbo.poste pos on par.id_poste = pos.id_poste 
	INNER JOIN dbo.reports_log b on CAST(a.id_najem_ob as varchar(100)) = @Id AND b.doc_type = 'Notif' AND b.edoc_file_name = @OriginalFileName
	Where cast(a.id_najem_ob as varchar(100)) =  @Id and @DocType = 'Notif'
end

if @DocType = 'GuarRemind' AND @ReportName = 'OPOMJAM_SSOFT_ESL'
begin 
	DECLARE @id_opom varchar(MAX), @id_poroka varchar(MAX)
	SET @id_opom = SUBSTRING(@id,0,CHARINDEX('$',@id,0))
	SET @id_poroka = SUBSTRING(@id,CHARINDEX('$',@id,0)+1,LEN(@id))
	
	Select 
		'Obavijest jamcu o opomeni za ugovor ' + RTRIM(b.id_pog) + ' ' + CONVERT(char(10), a.datum_dok, 104) as [gmi.earchive.doc_title],
		'Obavijest jamcu o opomeni br. ' + RTRIM(a.dok_opom) as [gmi.earchive.doc_description],
		'OBAVIJEST JAMCU O OPOMENI' as [tip_dokumenta],
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(cast(substring(@id, 0, charindex('$',@id)) as varchar(100))) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
		CASE WHEN a.st_opomina != 1 THEN 1 ELSE 0 END as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		RTRIM(par.dav_stev) as oib,
		b.id_cont, RTRIM(b.id_pog) as id_pog, RTRIM(par.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		0 as [edoc.dms]
	from dbo.gv_za_opom_with_arh a
	Inner join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont
	Inner Join dbo.pog_poro por ON a.id_cont = por.id_cont and por.id_poroka = @id_poroka
	Inner join dbo.partner par on por.id_poroka = par.id_kupca
	--Inner join dbo.poste p on par.id_poste = p.id_poste
	Inner JOIN dbo.tip_poro tp on por.oznaka = tp.id_tip_poro and tp.glavni <> 1 
    INNER JOIN dbo.reports_log x on x.id_object_edoc = @Id AND x.doc_type = @DocType AND x.edoc_file_name = @OriginalFileName
	where cast(a.id_opom as varchar(100)) = @id_opom and @DocType = 'GuarRemind'
end

-- MID: 40319 g_barbarak; dodavanje zbirnih računa u edoc obrade

if @DocType = 'InvoiceCum'
begin
	Select 
		'Račun br. ' + RTRIM(ra.ddv_id) as [gmi.earchive.doc_title],
		RTRIM(ra.opisdok) as [gmi.earchive.doc_description],
		'ZBIRNI RAČUN ZA RATE' as [tip_dokumenta],
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(ra.ddv_id) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		rtrim(ra.st_dok) as st_dok,
		z.id_krov_pog,
		rtrim(kp.st_krov_pog) as st_krov_pog,
		rtrim(par.dav_stev) as OIB,
		ra.ddv_date,
		ra.id_kupca,
		rtrim(par.naz_kr_kup) as naz_kr_kup,
		rtrim(ra.ddv_id) as ddv_id_cum,
		0 as [edoc.dms]
	From dbo.zbirniki z
	inner join dbo.rac_out ra on z.ddv_id = ra.ddv_id
	inner join dbo.partner par on ra.id_kupca = par.id_kupca
	inner join dbo.krov_pog kp on z.id_krov_pog = kp.id_krov_pog
	--left join dbo.poste p on par.id_poste = p.id_poste 
        left join (
            Select a.*
            From dbo.reports_log a
            inner join (
                  Select min(id_reports_log) as id_reports_log
                  from dbo.reports_log 
                  where id_object_edoc is not null
                  and doc_type = @DocType and id_object_edoc = @Id
            )b on a.id_reports_log = b.id_reports_log
        ) x on x.id_object_edoc = @Id and x.doc_type = @DocType
	Where z.id_zbirnik = @Id and @DocType='InvoiceCum'
end

if @DocType = 'Contract' And @ReportName = 'PLANP_SSOFT_ESL'
begin 
	Select
		'Plan otplate ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Plan otplate ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'PLAN OTPLATE' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		rl.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0009' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.pogodba p
	Inner join dbo.partner par on p.id_kupca = par.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	inner join dbo.users u on rl.rendered_by = u.username
	where cast(p.id_cont as varchar(100)) = @Id and @DocType = 'Contract'	
end

if @DocType = 'Contract' And @ReportName = 'PLANP_PK_SSOFT_ESL'
begin 
	Select
		'Plan otplate tijekom ug. ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Plan otplate tijekom ug. ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'PLAN OTPLATE TIJEKOM UG.' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		rl.rendered_when as datum_ispisa,
		0 as [edoc.dms]
	from dbo.pogodba p
	Inner join dbo.partner par on p.id_kupca = par.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	where cast(p.id_cont as varchar(100)) = @Id and @DocType = 'Contract'
end

if @DocType = 'Contract' And @ReportName = 'PLANP_RPG_SSOFT_ESL'
begin 
	Select
		'Plan otplate reprogram ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Plan otplate reprogram ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'PLAN OTPLATE REPROGRAM' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		rl.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0011' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.pogodba p
	Inner join dbo.partner par on p.id_kupca = par.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	inner join dbo.users u on rl.rendered_by = u.username
	where cast(p.id_cont as varchar(100)) = @Id 	
end

if @DocType = 'Contract' And @ReportName = 'OBV_PRIM_SSOFT'
begin 
	Select
		'Obavijest dobavljaču ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Obavijest dobavljaču ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'OBAVIJEST DOBAVLJAČU' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		rl.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0010' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.pogodba p
	Inner join dbo.partner par on p.id_kupca = par.id_kupca
	inner join dbo.reports_log rl ON rl.id_object_edoc = @Id AND rl.id_reports_log = @id_reports_log
	inner join dbo.users u on rl.rendered_by = u.username
	where cast(p.id_cont as varchar(100)) = @Id 
end

if @DocType = 'General' AND @ReportName = 'OBV_OBE_SSOFT_ESL'
begin 
	Select
		'Obavijest o obeštećenju ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Obavijest o obeštećenju ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(b.rendered_by, '')) + '.pdf' As print_centar_name,
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'OBAVIJEST O OBEŠTEĆENJU' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		p.id_cont, RTRIM(p.id_pog) as id_pog, RTRIM(par.id_kupca) as id_kupca, RTRIM(par.naz_kr_kup) as naz_kr_kup,
		b.rendered_when as datum_ispisa,
		0 as [edoc.dms]
	From dbo.pogodba p
	INNER JOIN dbo.partner par on p.id_kupca = par.id_kupca
	--INNER JOIN dbo.dokument d on p.id_cont = d.id_cont AND d.id_obl_zav = 'OB'
	--MID 41776 JOIN pogodbe i reports_log radimo po id_object a ne @id (što je id_object_edoc a kako bi obradili i ispisi istog doctype i istog id-ja u SSOFT ispisu (u ovom slučaju id_cont)
	--za takve slučajeve id_object_edoc mora biti jedinstven što je za ove slučajeve riješeno dodavanjem naziva SSOFT ispisa na id u reports_edoc_settings.edoc_id_lookup
	INNER JOIN dbo.reports_log b on CAST(p.id_cont as varchar(100)) = b.id_object AND b.doc_type = 'General' AND b.edoc_file_name = @OriginalFileName AND b.id_object_edoc = @id
	where cast(p.id_cont as varchar(100)) = @id_object and @DocType = 'General'
end

if @DocType = 'PreBuyout' AND @ReportName = 'PON_PRED_ODKUP_KLI_SSOFT_ESL'
begin 
	Select
		'Prijevremeni otkup - informativni izračun ' +cast(ppo.id_pon_pred_odkup as varchar(100)) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Prijevremeni otkup - informativni izračun ' +cast(ppo.id_pon_pred_odkup as varchar(100)) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'PRIJEVREMENI OTKUP - INFORMATIVNI IZRAČUN' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		b.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0003' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.pon_pred_odkup ppo
	inner join dbo.pogodba p on ppo.id_cont = p.id_cont
	inner join dbo.partner par on ppo.id_kupca = par.id_kupca
	inner join dbo.reports_log b on b.edoc_file_name = @OriginalFileName 
	inner join dbo.users u on b.rendered_by = u.username
	where cast(ppo.id_pon_pred_odkup as varchar(100)) = @id 
end

if @DocType = 'PreBuyout' AND @ReportName = 'PON_PRED_ODKUP_OBRK_SSOFT_ESL'
begin 
	Select
		'Informativni izračun sadašnje vrijednosti – obračun za klijenta ' +cast(ppo.id_pon_pred_odkup as varchar(100)) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Informativni izračun sadašnje vrijednosti – obračun za klijenta ' +cast(ppo.id_pon_pred_odkup as varchar(100)) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'OBRAČUN ZA KLIJENTA' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		b.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0006' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.pon_pred_odkup ppo
	inner join dbo.pogodba p on ppo.id_cont = p.id_cont
	inner join dbo.partner par on ppo.id_kupca = par.id_kupca
	inner join dbo.reports_log b on b.edoc_file_name = @OriginalFileName 
	inner join dbo.users u on b.rendered_by = u.username
	where cast(ppo.id_pon_pred_odkup as varchar(100)) = @id 
end

if @DocType = 'PreBuyout' AND @ReportName = 'KUPAC_SSOFT_ESL'
begin 
	Select
		'Informativni izračun sadašnje vrijednosti – kupac ' +cast(ppo.id_pon_pred_odkup as varchar(100)) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Informativni izračun sadašnje vrijednosti – kupac ' +cast(ppo.id_pon_pred_odkup as varchar(100)) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'KUPAC' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		b.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0007' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.pon_pred_odkup ppo
	inner join dbo.pogodba p on ppo.id_cont = p.id_cont
	inner join dbo.partner par on ppo.id_kupca = par.id_kupca
	inner join dbo.reports_log b on b.edoc_file_name = @OriginalFileName 
	inner join dbo.users u on b.rendered_by = u.username
	where cast(ppo.id_pon_pred_odkup as varchar(100)) = @id 
end

if @DocType = 'PreBuyout' AND @ReportName = 'PRIM_LEAS_SSOFT_ESL'
begin 
	Select
		'Informativni izračun sadašnje vrijednosti – primatelj leasinga ' +cast(ppo.id_pon_pred_odkup as varchar(100)) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_title], 
		'Informativni izračun sadašnje vrijednosti – primatelj leasinga ' +cast(ppo.id_pon_pred_odkup as varchar(100)) +' za ugovor ' + RTRIM(p.id_pog) as [gmi.earchive.doc_description], 
		0 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'PRIMATELJ LEASINGA' as [tip_dokumenta],
		RTRIM(par.dav_stev) as oib,
		b.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'0008' as [tip_dokumenta_dms],
		1 as [edoc.dms]
	from dbo.pon_pred_odkup ppo
	inner join dbo.pogodba p on ppo.id_cont = p.id_cont
	inner join dbo.partner par on ppo.id_kupca = par.id_kupca
	inner join dbo.reports_log b on b.edoc_file_name = @OriginalFileName 
	inner join dbo.users u on b.rendered_by = u.username
	where cast(ppo.id_pon_pred_odkup as varchar(100)) = @id 
end

if @DocType = 'Partner' AND @ReportName = 'INDIVIDUALNA_OBAV_SSOFT_ESL'
begin 
	Select
		'Individualna obavijest za partnera ' + RTRIM(par.id_kupca) as [gmi.earchive.doc_title], 
		'Individualna obavijest za partnera ' + RTRIM(par.id_kupca) as [gmi.earchive.doc_description], 
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'INDIVIDUALNA OBAVIJEST' as [tip_dokumenta],
		b.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'' as [tip_dokumenta_dms],
		0 as [edoc.dms]
	from dbo.partner par 
	inner join dbo.reports_log b on b.edoc_file_name = @OriginalFileName 
	inner join dbo.users u on b.rendered_by = u.username
	where par.id_kupca = @id 
end

if @DocType = 'Partner' AND @ReportName = 'OBV_POTV_POD_SSOFT_ESL'
begin 
	Select
		'OBAVIJEST KORISNICIMA i POTVRDA PODATAKA za partnera ' + RTRIM(par.id_kupca) as [gmi.earchive.doc_title], 
		'OBAVIJEST KORISNICIMA i POTVRDA PODATAKA za partnera ' + RTRIM(par.id_kupca) as [gmi.earchive.doc_description], 
		1 as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		'OBAVIJEST KORISNICIMA i POTVRDA PODATAKA' as [tip_dokumenta],
		b.rendered_when as datum_ispisa,
		u.domain_name as ispisao_domain_name,
		'' as [tip_dokumenta_dms],
		0 as [edoc.dms]
	from dbo.partner par 
	inner join dbo.reports_log b on b.edoc_file_name = @OriginalFileName 
	inner join dbo.users u on b.rendered_by = u.username
	where par.id_kupca = @id 
end
/* G_IGORP - PRIČEKATI DA SE POTVRDI MR50069
if @DocType = 'RmndrDoc'
begin 
	Select 
		CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni za dok. za ugovor ' ELSE 'Račun za troškove opomene za dok. za ugovor ' END + RTRIM(b.id_pog) + ' ' + CONVERT(char(10), a.datum_dok, 104) as [gmi.earchive.doc_title],
		CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni za dok.br. ' + RTRIM(a.dok_opom) Else 'Račun za troškove opomene za dok. br. ' + RTRIM(a.ddv_id) END  as [gmi.earchive.doc_description],
		CASE WHEN a.ddv_id is null THEN 'OBAVIJEST O OPOMENI ZA DOK.' ELSE 'RAČUN ZA OPOMENU ZA DOK.' END as [tip_dokumenta],
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
		CASE WHEN a.st_opomina != 3 THEN 1 ELSE 0 END as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		RTRIM(par.dav_stev) as oib, 
		0 as [edoc.dms]
	from dbo.za_opom a
	left join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont 
	left join dbo.partner par on a.id_kupca = par.id_kupca
	--left join dbo.poste p on par.id_poste = p.id_poste 
        left join (
            Select a.*
            From dbo.reports_log a
            inner join (
                  Select min(id_reports_log) as id_reports_log
                  from dbo.reports_log 
                  where id_object_edoc is not null
                  and doc_type = @DocType and id_object_edoc = @Id
            )b on a.id_reports_log = b.id_reports_log
        ) x on x.id_object_edoc = @Id and x.doc_type = @DocType
	where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'RmndrDoc'

	UNION ALL

	Select 
		CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni za dok. za ugovor ' ELSE 'Račun za troškove opomene za dok. za ugovor ' END + RTRIM(b.id_pog) + ' ' + CONVERT(char(10), a.datum_dok, 104) as [gmi.earchive.doc_title],
		CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni za dok. br. ' + RTRIM(a.dok_opom) Else 'Račun za troškove opomene za dok. br. ' + RTRIM(a.ddv_id) END  as [gmi.earchive.doc_description],
		CASE WHEN a.ddv_id is null THEN 'OBAVIJEST O OPOMENI ZA DOK.' ELSE 'RAČUN ZA OPOMENU ZA DOK.' END as [tip_dokumenta],
		RTRIM(par.id_kupca) + '_HP_' + RTRIM(@DocType) + '_' + RTRIM(@Id) + '_' + rtrim(isnull(x.rendered_by, '')) + '.pdf' As print_centar_name,
		CASE WHEN a.st_opomina != 3 THEN 1 ELSE 0 END as [edoc.for_print_centar],
		1 as [edoc.export_earchive],
		rtrim(par.dav_stev) as oib, 
		0 as [edoc.dms]
	from dbo.arh_za_opom a
	left join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont 
	left join dbo.partner par on a.id_kupca = par.id_kupca 
	--left join dbo.poste p on par.id_poste = p.id_poste 
        left join (
            Select a.*
            From dbo.reports_log a
            inner join (
                  Select min(id_reports_log) as id_reports_log
                  from dbo.reports_log 
                  where id_object_edoc is not null
                  and doc_type = @DocType and id_object_edoc = @Id
            )b on a.id_reports_log = b.id_reports_log
        ) x on x.id_object_edoc = @Id and x.doc_type = @DocType
	where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'RmndrDoc'
end
*/

--=================== FINA =======================

If @DocType='Invoice' and @is_for_fina = 1
Begin
	
	Select @is_for_fina as [fina.is_for_fina]

	if @is_for_fina = 1
	begin 

		declare @source varchar(30), @id_terj char(2), @tip_leas char(2), @p_zrac varchar(50), @p_podjetje varchar(100), @int_kamate varchar(100)
		declare @addCostXml varchar(max), @invoiceLineXml varchar(max), @taxTotalXml varchar(max), @datum_dok datetime
		declare @referencesXml varchar(max), @ubl_tip varchar(5), @xml as xml, @addPropertyXml varchar(max), @dom_valuta varchar(10) 
	
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
		rtrim(u.user_id) as InvoicePersonIssued,
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
		cast(rtrim(isnull(kat.val_string,'')) as varchar(max)) as InvoiceOrderReference,  
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
			inner join dbo.kategorije_tip b on a.id_kategorije_tip = b.id_kategorije_tip and b.entiteta = 'POGODBA' and b.neaktiven = 0
			where b.sifra = 'ORDER_NO'
		) kat on p.ID_CONT = kat.id_cont and a.ID_KUPCA = p.id_kupca
		left join dbo.users u on a.izdal = u.username
		Where a.ddv_id = @Id

		if @source = 'NAJEM_FA'
		begin 
			Select * into #najem_fa From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) where ddv_id = @id
            Select @id_terj = id_terj, @tip_leas = dbo.gfn_Nacin_leas_HR(nacin_leas), @datum_dok = datum_dok, @int_kamate = dbo.gfn_GetCustomSettings('id_terj_interkal_obr')  From #najem_fa where ddv_id = @id

			if @id_terj = '21'
			begin 
				update #invoice_data set 
				InvoiceDate = b.datum_dok, 
				InvoiceDeliveryDate = b.datum_dok, 
				InvoiceDueDate = b.dat_zap, 
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO PREMA ISPISU
				InvoicePersonIssued = u.user_id,  --TODO PREMA ISPISU
	
				InvoiceTotalNetAmount = case when @tip_leas = 'OL' 
											then b.rac_out_debit_neto + b.rac_out_neobdav   --NAJAMNINA + PPMV
											else b.rac_out_debit_neto + b.rac_out_brez_davka end,  --KAMATA
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit_davek + case when @tip_leas = 'OL' 
														then b.rac_out_debit_neto + b.rac_out_neobdav 
														else b.rac_out_debit_neto + b.rac_out_brez_davka end,
				InvoiceTotalAddCostsAmount = 0, --case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end ,
				InvoiceTotalPayableAmount = b.rac_out_debit + b.rac_out_neobdav, -- + case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end,
				InvoiceNote = case when @tip_leas = 'F1' then 'Obavijest o dospijeću glavnice ' + case when b.srobresti <> 0 then 'i PPMV-a ' else '' end + 'prema Planu otplate: ' + dbo.gfn_gccif(b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '. UKUPNO ZA PLATITI: ' + dbo.gfn_gccif(b.rac_out_debit + b.rac_out_neobdav + b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '.' else '' end,
				InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo ugovorenu zateznu kamatu od datuma dospijeća. Ukoliko uplata navedenog iznosa bude izvršena najkasnije u roku od 15 dana od dana dospijeća, ' + @p_podjetje + ' neće obračunavati zateznu kamatu.'
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id
				left join dbo.nastavit n on 1 = 1
				left join dbo.users u on b.ra_izdal = u.username
				
				declare @startdate datetime, @enddate datetime, @rata_type varchar(30), @rata_prije datetime, @rata_poslije datetime, @obnaleto decimal(6,2)
				
				--TODO OVAJ DIO PO LEASING KUĆI
				Select @rata_type =  
				Case when (cs.val = 'Anticipative' and dok.id_dokum is null) or (cs.val = 'Decursive' and dok.id_dokum is not null) Then 'Anticipative'
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
				--ESL ima čudan select za razdoblje
				if @rata_type = 'Anticipative'
				begin 
					/*set @startdate = @datum_dok
				
					if @rata_poslije is null OR Abs(datediff(d, @datum_dok, @rata_poslije - 1) - datediff(d, @datum_dok, DATEADD(mm,12/@obnaleto,@datum_dok) - 1)) >= 5
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok) - 1
					end
				
					if @rata_poslije is not null And Abs(datediff(d, @datum_dok, @rata_poslije - 1) - datediff(d, @datum_dok, DATEADD(mm,12/@obnaleto,@datum_dok) - 1)) < 5
					begin 
						set @enddate = @rata_poslije - 1
					end*/

					set @startdate = case when DATEPART(dd, @datum_dok) = 15 then @datum_dok else DATEADD(dd, -(DAY(DATEADD(mm, 1, @datum_dok)) -1), DATEADD(mm, 0, @datum_dok)) end 

					set @enddate = case when DATEPART(dd, @datum_dok) = 15 then DATEADD(mm, 12/@obnaleto, @datum_dok) - 1 else
											case when @obnaleto = 12 then DATEADD(dd, -DAY(DATEADD(m, 1, @datum_dok)), DATEADD(m, 1, @datum_dok)) 
												else DATEADD(mm, 12/@obnaleto, @datum_dok) - 1 end
									end
				end
				
				--TODO OVAJ DIO PO LEASING KUĆI
				--ESL NE KORISTI Decursive
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
			
				update #invoice_data set  InvoicePeriodStartDate = @startdate, InvoicePeriodEndDate = @enddate
				
				-- MID: 45871 g_barbarak, dodavanje reg. oznake na račune za rate
				set @xml = (Select Name, Value 
							From (
								Select 'Reg. oznaka' as Name,
								rtrim(c.reg_stev) as Value
								From dbo.najem_fa a
								inner join dbo.pogodba b on a.ID_CONT = b.ID_CONT 
								inner join dbo.gv_Zapisniki c on b.ID_CONT = c.id_cont
								inner join dbo.general_register gr_reg on a.id_kupca = gr_reg.id_key and gr_reg.id_register = 'ESL_PAR_REG_OZN' and gr_reg.neaktiven = 0
								where a.ddv_id = @Id and c.se_registrira = 1 and c.reg_stev is not null and c.reg_stev != ''
							) res
							FOR XML PATH ('LineAddProperty'), ROOT('ArrayOfLineAddProperty')
							)
							
				set @addPropertyXml = replace(replace(CAST(@xml as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' )
				
				if @tip_leas = 'F1'
				begin
					
					/*DODATNI TROŠKOVI NA RAČUNU*/
					--TODO PO FIRMI ZA SADA JE ZAJEDNO GLAVNICA + PPMV
					--set  @xml = (
					--Select AddCostName, AddCostAmount
					--From (
					--	Select 'Obavijest o dospijeću glavnice' + case when srobresti > 0 then ' i PPMV-a' else '' end +  ' prema Planu otplate' as AddCostName,
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
						-- 27.04.2020 Tomislav MID 44664 - naknada za poček zbog COVID19
						CASE WHEN dok_MR.id_dokum is not null and b.neto = 0 THEN 'Naknada za ugovoreni poček za razdoblje' ELSE 'Rata za razdoblje' END as LineDesc,  --TODO AKO JE UBLEN MOŽE SE STAVITI I PERIOD U OPIS STAVKE
						case when o.naziv_tuj3 is null or rtrim(o.naziv_tuj3) = ''  then 'H87' else rtrim(o.naziv_tuj3) end as LineQuantityUnit, 
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
						OUTER APPLY (select top 1 id_dokum 
									from dbo.dokument 
									where id_obl_zav = 'MR' 
									and b.datum_dok between zacetek and isnull(velja_do, '99991231')
									and id_cont = b.id_cont) dok_MR
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
						rtrim(b.naz_terj) + ' za razdoblje' as LineDesc, 
						case when o.naziv_tuj3 is null or rtrim(o.naziv_tuj3) = ''  then 'H87' else rtrim(o.naziv_tuj3) end as LineQuantityUnit, 
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
						'Poseban porez na motorna vozila (PPMV)' as LineDesc, 
						case when o.naziv_tuj3 is null or rtrim(o.naziv_tuj3) = ''  then 'H87' else rtrim(o.naziv_tuj3) end as LineQuantityUnit, 
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
				InvoicePersonIssued = u.user_id,  --TODO PREMA ISPISU
				InvoiceTotalNetAmount = b.rac_out_debit_neto + b.rac_out_brez_davka + b.rac_out_neobdav,  
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit + b.rac_out_neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = b.rac_out_debit + rac_out_neobdav,
				InvoiceNote = '',
				InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu.'
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				inner join dbo.VRST_TER c on b.ID_TERJ = c.id_terj
				left join dbo.users u on b.ra_izdal = u.username

					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						RTRIM(case when b.id_terj ='35' then 'Naknada za ugovoreni poček'
								   when d.sif_terj = 'SFIN' AND @tip_leas = 'OL' then 'Naknada za pribavu objekta leasinga'
						           else rtrim(b.naziv_terj) end) as LineDesc, --TODO Provjeriti po ispisima
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
						RTRIM(case when b.id_terj ='35' then 'Naknada za ugovoreni poček'
								   when d.sif_terj = 'SFIN' AND @tip_leas = 'OL' then 'Naknada za pribavu objekta leasinga'
						           else rtrim(b.naziv_terj) end) as LineDesc, --TODO Provjeriti po ispisima
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
						case when d.ima_robresti = 1 then 'Poseban porez na motorna vozila (PPMV)' 
							 else RTRIM(case when b.id_terj ='35' then 'Naknada za ugovoreni poček'
								   when d.sif_terj = 'SFIN' AND @tip_leas = 'OL' then 'Naknada za pribavu objekta leasinga'
						           else rtrim(b.naziv_terj) end) end as LineDesc, 
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
				InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.neobdav,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = rtrim(@p_podjetje) + ' kao Davatelj leasinga zadržava pravo vlasništva objekta leasinga do konačne otplate te ovim računom nije moguće napraviti prijenos vlasništva objekta leasinga bez odobrenja Davatelja leasinga. Datum isporuke: prema Potvrdi o preuzimanju po Ugovoru o financijskom leasingu br. ' + rtrim(b.id_pog) +'.',
				InvoicePaymentNote = ''
				From #invoice_data a
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				left join dbo.users u on a.izdal = u.username
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
						'Poseban porez na motorna vozila (PPMV)' as LineDesc,  
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
		
		-- 13.08.2021 g_tomislav MID 47431 - zakomentiran join na dbo.avansi jer se ne koristi i jer se nakon aktvacije ugovora račun više ne nalazi u dbo.avansi
		if @source = 'AVANSI'
		begin
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.DDV_DATE, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
				InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit,
				InvoiceType = '386',
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = '' ,
				InvoicePaymentNote = '' -- TODO PO FIRMAMA, ALI KOD AVANSA NEMA PLAĆANJA
				From #invoice_data a 
				--left join dbo.avansi av on a.ddv_id = av.ddv_id -- MORA BITI LEFT JOIN JER SE NAKON AKTVACIJE UGOVORA RAČUN VIŠE NE NALAZI U DBO.AVANSI
				--inner join dbo.pogodba b on a.id_cont = b.id_cont 
				--left join dbo.placila c on av.id_plac = c.id_plac 
				left join dbo.users u on a.izdal = u.username
				
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 
						'PREDUJAM' as LineItemIdent,
						'Primljena uplata bez PDV-a po ugovoru' as LineDesc,  --TODO podesiti po firmama
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
				InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.BREZ_DAVKA + a.neobdav) else (a.debit_neto + a.BREZ_DAVKA + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om
				InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
				InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav) else (a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end, --TODO provjeriti zbog kombinacije s PPMV-om,
				--PRIJE PROMJENE DA SVE MORA BITI NEGATIVNO DA BI BIO CREDIT NOTE 
				--InvoiceType = case when (a.DEBIT + a.BREZ_DAVKA) < 0 or ((a.DEBIT + a.BREZ_DAVKA) = 0 and a.NEOBDAV < 0) then '381' else '383' end,
				InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else '383' end,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = case when a.DEBIT < 0 and a.NEOBDAV < 0 then 'Ovim putem vršimo storno računa navedenog u referenci na prethodni račun.'
							      else 'Ovim putem teretimo račun naveden u referenci na prethodni račun.' end,
				InvoicePaymentNote = '', --TODO podesiti sukladno odobrenje/terećenje
				document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end
				From #invoice_data a
				left join dbo.users u on a.izdal = u.username
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

		-- NIJE PODEŠEN KAO INVOICE U reports_edoc_settings
		if @source = 'REP_IND'
		begin
				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.DDV_DATE, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
				InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
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
				left join dbo.users u on a.izdal = u.username
				
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
				InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = 'Temeljem Vašeg plaćanja dana '+ isnull(convert(varchar(10), z.dat_zap, 104),'') +'. obračunali smo zatezne kamate.',
				InvoicePaymentNote = '' -- TODO PO FIRMAMA
				From #invoice_data a 
				inner join dbo.ZOBR_FA z on a.ddv_id = z.ddv_id
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				left join dbo.users u on a.izdal = u.username
					
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

		--ESL NEMA 'DOK_OPOM'
		-- 31.12.2020 g_tomislav MID 46058 - bugfix: za_opom is replaced with gv_za_opom_with_arh
		if @source IN ('ZA_OPOM')
		begin

				update #invoice_data set 
				InvoiceIssueDate = a.dat_vnosa,
				InvoiceDueDate = a.valuta, 
				InvoiceDate = a.DDV_DATE,
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoicePaymentId = 'HR01 '+ b.sklic, --TODO provjeriti na ispisu zbog trećih osoba
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO NAPUNITI TEKST
				InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = case when z.st_opomina in (1, 2) then 'PRVA OPOMENA ZA NEPLAĆENA POTRAŽIVANJA PO UGOVORU O ' + case when @tip_leas = 'OL' then 'OPERATIVNOM' else 'FINANCIJSKOM' end + ' LEASINGU BR. ' + rtrim(b.id_pog) + '.'
				                   when z.st_opomina = 2 then 'PDRUGA OPOMENA ZA NEPLAĆENA POTRAŽIVANJA PO UGOVORU O ' + case when @tip_leas = 'OL' then 'OPERATIVNOM' else 'FINANCIJSKOM' end + ' LEASINGU BR. ' + rtrim(b.id_pog) + '.'
									when z.st_opomina = 3 then 'OPOMENA PRED RASKID UGOVORA O ' +  case when @tip_leas = 'OL' then 'OPERATIVNOM' else 'FINANCIJSKOM' end + ' LEASINGU BR. ' + rtrim(b.id_pog) + '.'
									when x.st_opomin is not null then 'Obavještavamo Vas da smo, uvidom u našu poslovnu evidenciju ustanovili da s datumom '+convert(varchar(10),getdate(),104)+' nismo zaprimili svu ugovornu dokumentaciju.'
							 end				 ,
				InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu.' -- TODO PO FIRMAMA
				From #invoice_data a 
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				left join dbo.gv_za_opom_with_arh z on a.DDV_ID = z.ddv_id
				left join (Select ddv_id, st_opomin From dbo.dok_opom group by ddv_id, st_opomin) x on a.ddv_id = x.ddv_id
				left join dbo.users u on a.izdal = u.username
				
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
			InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.neobdav,
			InvoiceNote = rtrim(isnull(c.opombe, '')), --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO 
			InvoicePaymentNote = 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu. Predmet kupoprodaje preuzet je na način "viđeno-kupljeno". Kupac se osobno uvjerio u stanje predmeta kupoprodaje, te nedostatake koje je uočio prihvaća u cjelosti.' --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO
			From #invoice_data a
			inner join dbo.pogodba b on a.id_cont = b.id_cont 
			inner join dbo.OPC_FAKT c on a.DDV_ID = c.DDV_ID
			left join dbo.tecajnic t on c.id_tec = t.id_tec
			left join dbo.users u on a.izdal = u.username
					
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
					'Poseban porez na motorna vozila (PPMV)' as LineDesc,  
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

		if @source = 'ZA_REGIS'
		begin

			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = a.VALUTA, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.neobdav,
			InvoiceNote = 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu.',
			InvoicePaymentNote = 'Molimo da gore navedeni iznos uplatite do datuma dospjeća.' --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO 
			From #invoice_data a
			left join dbo.users u on a.izdal = u.username
			
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
					'PROMDOV' as LineItemIdent, 'Prometna dozvola i/ili knjižica vozila' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
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
					'DODOPR' as LineItemIdent, 'Osnovna oprema vozila i/ili protupožarni aparat' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
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
					'PROMDOZ' as LineItemIdent, 'Produljenje valjanosti prometne dozvole i/ili knjižice vozila' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
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
					'USL' as LineItemIdent, 'Administrativna naknada je obračunata sukladno Općim uvjetima' as LineDesc, 'H87' as LineQuantityUnit, cast(1 as decimal(18,2)) as LineQuantity,
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
			InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.neobdav) else (a.debit_neto + a.brez_davka + a.neobdav) end, 
			InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
			InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.debit_davek + a.neobdav) else (a.debit_neto + a.brez_davka + a.debit_davek + a.neobdav) end,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = case when a.debit < 0 and a.neobdav < 0 then '' else 'Molimo Vas, da iznos određen računom platite odmah' end,
			InvoicePaymentNote = case when a.debit < 0 and a.neobdav < 0 then '' else 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu.' end, -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end -- TODO AKO JE TEČAJNA NEGATIVNA MORA BITI CREDIT NOTE
			From #invoice_data a 
			inner join dbo.pogodba b on a.id_cont = b.id_cont
			left join dbo.users u on a.izdal = u.username
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
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as LineTaxNote, 
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
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.brez_davka <> 0 and a.NEOBDAV = 0
						union all
					Select 
					'OP' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or (a.neobdav > 0 and a.brez_davka > 0) then abs(a.neobdav + a.brez_davka) else (a.neobdav + a.brez_davka) end as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.BREZ_DAVKA <> 0 and a.neobdav <> 0 
						union all
					Select 
					'NO' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					case when (a.document_external_type = 'CreditNoteEnvelope') or a.neobdav > 0 then abs(a.neobdav) else (a.neobdav) end as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
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
			InvoicePaymentId = 'HR01 '+ case when b.id_kupca <> a.id_kupca then '998-' + a.id_kupca + '-' + b.id_sklic + dbo.tfn_GetControlNum('998-' + a.id_kupca + '-' + b.id_sklic) else b.sklic end, --TODO provjeriti na ispisu zbog trećih osoba
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = rtrim(isnull(f.rep,'')) + case when f.MARZA > 0 then 'Administrativna naknada je obračunata sukladno Općim uvjetima.' else '' end + case when f.id_terj in ('77','78') then 'Predmet kupoprodaje preuzet je na način "viđeno-kupljeno". Kupac se osobno uvjerio u stanje predmeta kupoprodaje, te nedostatake koje je uočio prihvaća u cjelosti.' else '' end ,
			InvoicePaymentNote = 'Molimo da gore navedeni iznos uplatite do datuma dospjeća. Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu.' -- TODO PO FIRMAMA
			From #invoice_data a 
			inner join dbo.pogodba b on a.id_cont = b.id_cont
			inner join dbo.fakture f on a.ddv_id = f.ddv_id
			left join dbo.tecajnic t on f.id_tec = t.id_tec
			left join dbo.users u on a.izdal = u.username

				/*STAVKE*/
				set  @xml = (
				Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
				LineAmount,LineTaxNote,LineTaxName
				From (
					Select fp.id_post as LineItemIdent, 
					case when f.id_terj in ('77') then rtrim(p.pred_naj) else rtrim(fp.opis) end as LineDesc, --TODO Provjeriti po ispisima
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
					inner join dbo.pogodba p on f.id_cont = p.id_cont 
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
					where a.brez_davka > 0 and a.neobdav = 0
						union all
					Select 
					'OP' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					a.brez_davka + a.neobdav as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.brez_davka > 0 and a.neobdav > 0
						union all
					Select 
					'NO' as TaxName,
					cast(0 as decimal(18,2)) as TaxRate,
					a.neobdav as TaxBase,
					cast(0 as decimal(18,2)) as TaxAmount,
					rtrim(cast(isnull(a.klavzula,'Klauzula') as varchar(max))) as TaxNote 
					From #invoice_data a
					inner join dbo.dav_stop c on a.id_dav_st = c.id_dav_st
					where a.neobdav > 0 and a.brez_davka = 0
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
			InvoicePersonIssued = u.user_id, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_neto + a.brez_davka + a.debit_opr + a.debit_izv + a.neobdav) else (a.debit_neto + a.brez_davka + a.debit_opr + a.debit_izv + a.neobdav) end, 
			InvoiceTotalTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit_davek) else (a.debit_davek) end,
			InvoiceTotalWithTaxAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then abs(a.debit + a.neobdav) else (a.debit + a.neobdav) end,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = rtrim(isnull(b.rep,'')) ,
			InvoicePaymentNote = case when b.TIP_KNJIGE = 'IAVA' or (a.debit < 0 and a.neobdav < 0) then '' else 'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu.' end, -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end
			From #invoice_data a 
			inner join dbo.gl_output_r b on a.ddv_id = b.DDV_ID 
			left join dbo.tecajnic t on b.id_tec = t.id_tec
			left join dbo.users u on a.izdal = u.username

				/*STAVKE*/
				set  @xml = (
				Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
				LineAmount,LineTaxNote,LineTaxName
				From (
					Select 
					case when fp.PROTIKONTO is null or fp.PROTIKONTO = '' then rtrim(cast(fp.id_gl_out_rk as varchar(10))) else rtrim(fp.PROTIKONTO) end as LineItemIdent, 
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