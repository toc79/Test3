-- [[TAX_ID=52277663197]]

declare @is_for_fina bit

if @DocType='Invoice'
begin	
	set @is_for_fina = (Select cast(count(*) as bit) 
	                      From dbo.partner a 
						  inner join dbo.rac_out b on a.id_kupca = b.id_kupca 
						  where a.ident_stevilka is not null and a.ident_stevilka <> '' and 
						  b.ddv_id = @id and @DocType='Invoice') 
end

if @DocType='InvoiceCum'
begin			  
	set @is_for_fina = (Select cast(count(*) as bit)
						 From dbo.zbirniki a
						 inner join dbo.rac_out b on a.ddv_id = b.ddv_id 
						 inner join dbo.partner c on b.id_kupca = c.id_kupca
						 Where @DocType='InvoiceCum' and a.id_zbirnik = @id and c.ident_stevilka is not null and c.ident_stevilka <> '')
end

if @DocType = 'Invoice'
begin
	Select 
	CASE WHEN r.id_kupca = '002610' AND x.source <> 'GL_OUTPUT_R'
	THEN
		'<Racun>'+
			'<ugovor_BKSL>' + RTRIM(b.id_pog) + '</ugovor_BKSL>' + 
			'<ug_CFM>' + RTRIM(pog.njih_st) + '</ug_CFM>' + 
			'<opis>' + RTRIM(r.opisdok) + '</opis>' + 
			'<osnovica_hrk>' + CAST((r.debit_neto + r.brez_davka + r.neobdav + r.debit_izv + r.debit_opr) as varchar(22)) + '</osnovica_hrk>' + 
			'<porez_hrk>' + CAST((r.debit_davek) as varchar(22)) + '</porez_hrk>' + 
			'<sveukupno_hrk>' + CAST((r.debit_neto + r.brez_davka + r.neobdav + r.debit_izv + r.debit_opr + r.debit_davek) as varchar(22)) + '</sveukupno_hrk>' + 
			'<fis_br_rac>' + RTRIM(dbo.gfn_TransformDDV_ID_HR(r.ddv_id, r.ddv_date)) + '</fis_br_rac>' + 
			'<datum_racuna>' + CONVERT(varchar(10), r.ddv_date, 120) + '</datum_racuna>' + 
			'<due_date>' + CONVERT(varchar(10), ISNULL(r.valuta, pp.dat_zap), 120) + '</due_date>' + 
			'<ppmv_hrk>' + 
			CAST(CASE WHEN 
			--operativac najamnina i otkup koji ima robresti
			(nl.tip_knjizenja = '1' AND nl.ima_robresti = 1 AND r.sif_rac IN ('LOB', 'OPC'))
			OR
			--financijaš AKT
			(nl.tip_knjizenja = '2' AND nl.ima_robresti = 1 AND r.sif_rac = 'AKT')
			OR
			--opće fakture
			(r.sif_rac = 'SPL' AND vt.ima_robresti = 1 AND r.old_ddv_d IS NULL)
			OR
			--storna opće fakture
			(r.sif_rac = 'SPL' AND vs.ima_robresti = 1 AND r.old_ddv_d IS NOT NULL)
			THEN 
				r.neobdav 
			--tečajne
			WHEN 
			(r.sif_rac = 'TRA' AND nl.tip_knjizenja = '1' AND nl.ima_robresti = 1)
			THEN
				isnull(tr.neobdav_tra, 0)
			ELSE 
				0 
			END as varchar(22)) + 
			'</ppmv_hrk>' + 
		'</Racun>' 
	ELSE
		''
	END as [edoc.doc_xml], 
	CASE WHEN r.id_kupca = '002610' AND x.source <> 'GL_OUTPUT_R' THEN 1 ELSE 0 END as [edoc.export_to_cfm],
	--dio koji se odnosi na e-arhivu
	'Račun br. ' + RTRIM(r.ddv_id) as [gmi.earchive.doc_title],
	RTRIM(r.opisdok) as [gmi.earchive.doc_description],
	CASE WHEN x.source = 'NAJEM_FA' THEN coalesce(rtrim(upper(v.naziv)), 'RAČUNI ZA RATE (RATE, AKONTACIJA, TROŠAK OBRADE)')
	WHEN x.source = 'ZOBR_FA' THEN 'ZATEZNE KAMATE'
	WHEN x.source = 'AVANSI' THEN 'RAČUNI PREDUJMOVA NEAKTIVNIH UGOVORA'
	WHEN x.source = 'OPC_FAKT' THEN 'RAČUNI ZA OTKUP'
	WHEN x.source = 'FAKTURE' THEN 'OPĆI RAČUNI'
	WHEN x.source = 'POGODBA' THEN 'RAČUNI ZA AKTIVACIJU UGOVORA'
	WHEN x.source = 'GL_OUTPUT_R' THEN 'RAČUNI IZ GLAVNE KNJIGE'
	WHEN x.source = 'TEC_RAZL' THEN 'RAČUNI ZA VALUTNE KLAUZULE'
	WHEN x.source = 'PLANP' THEN 'RAČUNI IZ PLANA OTPLATE'
	WHEN x.source = 'SPR_DDV' THEN 'RAČUNI IZ PROMJENE POREZNE OSNOVICE'
	WHEN x.source = 'ZA_OPOM' THEN 'RAČUN ZA OPOMENU'
	ELSE 'OSTALI RAČUNI' END as [tip_dokumenta],
	par.naz_kr_kup as [partner_title],
	RTRIM(r.dav_stev) as [oib], 
	case when @is_for_fina = 0 then '1' else '0' end as [edoc.for_nova_arhiva]
	
	FROM dbo.rac_out r
	INNER JOIN 
		(SELECT a.ddv_id, dbo.gfn_GetInvoiceSource(a.ddv_id) as source
		FROM dbo.rac_out a 
		WHERE a.ddv_id = @Id AND @DocType = 'Invoice') x ON r.ddv_id = x.ddv_id
	INNER JOIN dbo.partner par ON r.id_kupca = par.id_kupca
	LEFT JOIN dbo.gv_PogodbaAll b ON r.id_cont = b.id_cont
	LEFT JOIN dbo.pogodba pog ON r.id_cont = pog.id_cont
	LEFT JOIN dbo.nacini_l nl ON b.nacin_leas = nl.nacin_leas
	LEFT JOIN dbo.planp pp ON r.ddv_id = pp.ddv_id
	left join dbo.najem_fa c on r.ddv_id = c.ddv_id
	left join dbo.vrst_ter v on c.id_terj = v.id_terj
	LEFT JOIN dbo.fakture fa ON r.ddv_id = fa.ddv_id
	LEFT JOIN dbo.vrst_ter vt ON fa.id_terj = vt.id_terj
	LEFT JOIN dbo.fakture fs ON r.old_ddv_id = fs.ddv_id
	LEFT JOIN dbo.vrst_ter vs ON fs.id_terj = vs.id_terj
	LEFT JOIN 
		(SELECT ddv_id, SUM(neobdav) as neobdav_tra
		FROM dbo.tec_razl
		WHERE ddv_id = @id
		AND (CHARINDEX('-21-', st_dok) <> 0 OR CHARINDEX('-23-', st_dok) <> 0)
		GROUP BY ddv_id) tr ON r.ddv_id = tr.ddv_id
	
	WHERE r.ddv_id = @id and @DocType = 'Invoice'
end

if @DocType = 'Notif'
begin
	Select 
	'Obavijest o rati ' + RTRIM(a.id_najem_ob) as [gmi.earchive.doc_title],
	RTRIM(a.st_dok) as [gmi.earchive.doc_description],
	'OBAVIJEST O RATI' as [tip_dokumenta],
	b.naz_kr_kup as [partner_title],
	RTRIM(b.dav_stev) as [oib],
	'1' as [edoc.for_nova_arhiva]
	From dbo.najem_ob a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	Where cast(a.id_najem_ob as varchar(100)) =  @Id and @DocType = 'Notif'
end

if @DocType = 'Reminder'
begin 
	Select 
	CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni za ugovor ' ELSE 'Račun za troškove opomene za ugovor ' END + RTRIM(b.id_pog) + ' ' + CONVERT(char(10), a.datum_dok, 104) as [gmi.earchive.doc_title],
	CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni br. ' + RTRIM(a.dok_opom) Else 'Račun za troškove opomene br. ' + RTRIM(a.ddv_id) END  as [gmi.earchive.doc_description],
	CASE WHEN a.ddv_id is null THEN 'OBAVIJEST O OPOMENI' ELSE 'RAČUN ZA OPOMENU' END as [tip_dokumenta],
	RTRIM(a.dok_opom) as [broj_dokumenta], 
	a.st_opomina as [broj_opomene], 
	par.naz_kr_kup as [partner_title],
	RTRIM(par.dav_stev) as [oib],
	'1' as [edoc.for_nova_arhiva]
	from dbo.za_opom a
	left join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont 
	left join dbo.partner par on a.id_kupca = par.id_kupca
    where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'Reminder'

	UNION ALL

	Select 
	CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni za ugovor ' ELSE 'Račun za troškove opomene za ugovor ' END + RTRIM(b.id_pog) + ' ' + CONVERT(char(10), a.datum_dok, 104) as [gmi.earchive.doc_title],
	CASE WHEN a.ddv_id is null THEN 'Obavijest o opomeni br. ' + RTRIM(a.dok_opom) Else 'Račun za troškove opomene br. ' + RTRIM(a.ddv_id) END  as [gmi.earchive.doc_description],
	CASE WHEN a.ddv_id is null THEN 'OBAVIJEST O OPOMENI' ELSE 'RAČUN ZA OPOMENU' END as [tip_dokumenta],
	RTRIM(a.dok_opom) as [broj_dokumenta], 
	a.st_opomina as [broj_opomene], 
	par.naz_kr_kup as [partner_title],
	RTRIM(par.dav_stev) as [oib],
	'1' as [edoc.for_nova_arhiva]
	from dbo.arh_za_opom a
	left join dbo.gv_PogodbaAll b on a.id_cont = b.id_cont 
	left join dbo.partner par on a.id_kupca = par.id_kupca 
	left join dbo.poste p on par.id_poste = p.id_poste 
	where cast(a.id_opom as varchar(100)) = @Id and @DocType = 'Reminder'
end

if @DocType = 'TaxChange'
begin
	Select 
	'Promjena porezne osnovice ' + RTRIM(p.id_pog) + ' ' + CONVERT(char(10), r.datum, 104) as [gmi.earchive.doc_title], 
	'Promjena porezne osnovice ' + RTRIM(r.st_dok) as [gmi.earchive.doc_description], 
	'PROMJENA POREZNE OSNOVICE' as [tip_dokumenta], 
	par.naz_kr_kup as [partner_title],
	RTRIM(par.dav_stev) as [oib],
	'1' as [edoc.for_nova_arhiva]
	from dbo.spr_ddv r  
	inner join dbo.partner par on r.id_kupca = par.id_kupca 
	inner join dbo.gv_PogodbaAll p on r.id_cont = p.id_cont 
    where cast(r.id_spr_ddv as varchar(100)) = @Id and @DocType = 'TaxChange'
end

if @DocType = 'TaxChngIx'
begin
	Select 
	'Obavijest o indeksaciji ugovor ' + RTRIM(p.id_pog) + ' ' + CONVERT(char(10), r.datum, 104) as [gmi.earchive.doc_title], 
	'Obavijest o indeksaciji br. ' + RTRIM(r.st_dok) as[gmi.earchive.doc_description], 
	'OBAVIJEST O PROMJENI INDEKSA' as [tip_dokumenta], 
	par.naz_kr_kup as [partner_title],
	RTRIM(par.dav_stev) as [oib],
	'1' as [edoc.for_nova_arhiva]
	from dbo.rep_ind r 
	inner join dbo.partner par on r.id_kupca = par.id_kupca 
	inner join dbo.gv_PogodbaAll p on r.id_cont = p.id_cont 
	where cast(r.id_rep_ind as varchar(100)) = @Id and @DocType = 'TaxChngIx'
end

if @DocType = 'Contract'
begin
	Select 
	CASE WHEN @ReportName = 'PLANP_SSOFT_BKS' THEN 'Plan otplate ' + RTRIM(p.id_pog) ELSE 'Poziv na plaćanje' + RTRIM(p.id_pog) END as [gmi.earchive.doc_title], 
	CASE WHEN @ReportName = 'PLANP_SSOFT_BKS' THEN 'Plan otplate ' + RTRIM(p.id_pog) ELSE 'Poziv na plaćanje' + RTRIM(p.id_pog) END as [gmi.earchive.doc_description], 
	CASE WHEN @ReportName = 'PLANP_SSOFT_BKS' THEN 'PLAN OTPLATE' ELSE 'POZIV NA PLAĆANJE'  END as [tip_dokumenta], 
	par.naz_kr_kup as [partner_title],
	RTRIM(par.dav_stev) as [oib],
	'1' as [edoc.for_nova_arhiva]
	from dbo.gv_PogodbaAll p 
	inner join dbo.partner par on p.id_kupca = par.id_kupca 
	where cast(p.id_cont as varchar(100)) = @Id and @DocType = 'Contract'
end 

if @DocType = 'NotifReg'
begin
	Select 
	'Ovlaštenje za registraciju ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_title], 
	'Ovlaštenje za registraciju ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_description], 
	'OVLAŠTENJE ZA REGISTRACIJU' as [tip_dokumenta],
	RTRIM(par.dav_stev) as [oib],
	'1' as [edoc.for_nova_arhiva]
	from dbo.za_regis a
	inner join dbo.pogodba p on a.id_cont = p.id_cont
	inner join dbo.partner par on p.id_kupca = par.id_kupca 
	where cast(a.id_za_regis as varchar(100)) =  @Id and @DocType = 'NotifReg'
end

if @DocType = 'ZapReg'
begin
Select 
	'Ovlaštenje za registraciju ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_title], 
	'Ovlaštenje za registraciju ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_description], 
	'OVLAŠTENJE ZA REGISTRACIJU' as [tip_dokumenta],
	RTRIM(par.dav_stev) as [oib],
	'1' as [edoc.for_nova_arhiva]
	from dbo.zap_reg a
	inner join dbo.pogodba p on a.id_cont = p.id_cont
	inner join dbo.partner par on p.id_kupca = par.id_kupca 
	where cast(a.id_zapo as varchar(100)) =  @Id 
end

if @DocType = 'NotifZaPz'
begin
	Select 
	'Obavijest o isteku osiguranja ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_title], 
	'Obavijest o isteku osiguranja ' + RTRIM(p.id_pog) + ' ' + RTRIM(@Id) as [gmi.earchive.doc_description], 
	'OBAVIJEST O ISTEKU OSIGURANJA' as [tip_dokumenta],
	a.id_cont as [contract_id],
	RTRIM(p.id_pog) as [contract_number],
	RTRIM(a.id_kupca) as [partner_id],
	RTRIM(par.naz_kr_kup) as [partner_title],
	RTRIM(par.dav_stev) as [oib],
	CONVERT(date, getdate()) as [document_date],
	'1' as [edoc.for_nova_arhiva]
	from dbo.za_pz a
	inner join dbo.pogodba p on a.id_cont = p.id_cont
	inner join dbo.partner par on p.id_kupca = par.id_kupca 
	where cast(a.id_za_pz as varchar(100)) =  @Id and @DocType = 'NotifZaPz'
end
if @DocType = 'InvoiceCum'
begin
	Select 
	'Zbirni račun ' + RTRIM(r.DDV_ID) as [gmi.earchive.doc_title], 
	'Zbirni račun ' + RTRIM(r.DDV_ID) as [gmi.earchive.doc_description],
	'ZBIRNI RAČUN' as [tip_dokumenta],
	RTRIM(r.dav_stev) as [oib], 
	case when @is_for_fina = 0 then '1' else '0' end as [edoc.for_nova_arhiva],
	CONVERT(date, r.DATUM) as [document_date]
	From dbo.ZBIRNIKI z 
	inner join dbo.RAC_OUT r on z.DDV_ID = r.DDV_ID 
	left join dbo.PARTNER p on r.ID_KUPCA = p.id_kupca
	where z.ID_ZBIRNIK = @id
end

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
		--@p_zrac as InvoicePaymentAccount,
		h.data AS InvoicePaymentAccount, -- njihov žiro račun koji se povlači iz dbo.nova_resources
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
		left join dbo.nova_resources h ON h.id_resource = 'BKS_P_ZRAC2' and h.active = 1 --ovo je novo jer oni imaju svoj IBAN upisan 
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
				InvoicePersonIssued = b.ra_izdal,  --TODO PREMA ISPISU
				
				InvoiceTotalNetAmount = case when @tip_leas = 'OL' 
											then b.rac_out_debit_neto + b.rac_out_neobdav   --NAJAMNINA + PPMV
											else b.rac_out_debit_neto + b.rac_out_brez_davka end,  --KAMATA
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit_davek + case when @tip_leas = 'OL' 
														then b.rac_out_debit_neto + b.rac_out_neobdav 
														else b.rac_out_debit_neto + b.rac_out_brez_davka end,
				InvoiceTotalAddCostsAmount = 0, --case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end ,
				InvoiceTotalPayableAmount = b.rac_out_debit + b.rac_out_neobdav, -- + case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end,
				InvoiceNote = case when @tip_leas = 'F1' then 'Obavijest o dospijeću prema Planu otplate: ' + dbo.gfn_gccif(b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '. UKUPNO ZA PLATITI: ' + dbo.gfn_gccif(b.rac_out_debit + b.rac_out_neobdav + b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '.' else '' end+
				CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
				CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
				InvoicePaymentNote = case when b.id_tec != '000' then 'Iznos ' + case when @tip_leas = 'F1' then 'rate' else 'najamnine' end + ' izražen je u kunskoj protuvrijednosti prema ' + rtrim(t.naziv_tuj2) + ' na dan fakturiranja.' else '' end
									+ 'Na zakašnjela plaćanja obračunavamo ugovorenu zateznu kamatu prema Općim uvjetima leasinga.'
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				left join dbo.tecajnic t on b.id_tec = t.id_tec 
				left join dbo.nastavit n on 1 = 1
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'KLASA'
							) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = b.id_kupca
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'UR_BR'
							) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = b.id_kupca
				
				
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
				if @rata_type = 'Anticipative'
				begin 
					set @startdate = @datum_dok
				
					if @rata_poslije is null or @obnaleto = 12 
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok) - 1
					end
				
					if @rata_poslije is not null and @obnaleto <> 12
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
						set @startdate = dbo.gfn_GetFirstDayOfMonth(@datum_dok)
						set @enddate = dbo.gfn_GetLastDayOfMonth(@datum_dok)
					end
					
					if @obnaleto <> 12 and @rata_prije is null
					begin 
						set @startdate = DATEADD(mm,-12/@obnaleto,@datum_dok) + 1
					end
				
					if @obnaleto <> 12 and @rata_prije is not null
					begin
						set @startdate = @rata_prije + 1
					end
				end
				
				/*ovako je bilo prije, pa da imamo backup
				if @rata_type = 'Anticipative'
				begin 
					set @startdate = @datum_dok
				
					if @rata_poslije is null or @obnaleto = 12 
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok) - 1
					end
				
					if @rata_poslije is not null and @obnaleto <> 12
					begin 
						set @enddate = @rata_poslije - 1
					end
			
				end
				
				--TODO OVAJ DIO PO LEASING KUĆI
				if @rata_type = 'Decursive'
				begin
					set @enddate = @datum_dok
					if @rata_prije is null or @obnaleto = 12 
					begin 
						set @startdate = DATEADD(mm,-12/@obnaleto,@datum_dok) + 1
					end
				
					if @rata_prije is not null and @obnaleto <> 12
					begin
						set @startdate = @rata_prije + 1
					end
				end
				*/
			
				update #invoice_data set  InvoicePeriodStartDate = @startdate, InvoicePeriodEndDate = @enddate
				if @tip_leas = 'F1'
				begin
					
					/*DODATNI TROŠKOVI NA RAČUNU*/
					--TODO PO FIRMI ZA SADA JE ZAJEDNO GLAVNICA + PPMV
					/*set  @xml = (
					Select AddCostName, AddCostAmount
					From (
						Select 'Obavijest o dospijeću glavnice' + case when srobresti > 0 then ' i PPMV-a' else '' end + ' prema Planu otplate' as AddCostName,
						sneto + SROBRESTI as AddCostAmount
						From #najem_fa 
						where ddv_id = @id
					) a
					FOR XML PATH ('InvoiceAddCost'), ROOT('ArrayOfInvoiceAddCost')  )
			
					set @addCostXml = cast(@xml as varchar(max))*/

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						--'RATA za razdoblje' as LineDesc,  --TODO AKO JE UBLEN MOŽE SE STAVITI I PERIOD U OPIS STAVKE
						case when b.obresti > 0 and (b.neto+b.marza+b.robresti+b.regist) = 0 then 'Umanjena rata za razdoblje uslijed posebnih okolnosti (Covid -19) i u skladu sa Aneksom Ugovora o leasingu' else 'RATA za razdoblje' end as LineDesc,
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
						--rtrim(b.naz_terj) + ' za razdoblje' as LineDesc, 
						case when b.obresti > 0 and (b.neto+b.marza+b.robresti+b.regist) = 0 then 'Umanjena najamnina za razdoblje uslijed posebnih okolnosti (Covid -19) i u skladu sa Aneksom Ugovora o leasingu' else rtrim(b.naz_terj) + ' za razdoblje' end as LineDesc,
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
						Select @id_terj +'-PPMV' as LineItemIdent, 'Udio PPMV-a' as LineDesc, 
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
				InvoicePersonIssued = b.ra_izdal,  --TODO PREMA ISPISU
				InvoiceTotalNetAmount = b.rac_out_debit_neto + b.rac_out_brez_davka + b.rac_out_neobdav,  
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit + b.rac_out_neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = b.rac_out_debit + rac_out_neobdav,
				InvoicePaymentNote = case when b.id_tec != '000' then 'Plaćanje u kunskoj protuvrijednosti prema ' + rtrim(t.naziv_tuj2) + ' na dan uplate. "' else '' end 
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				inner join dbo.VRST_TER c on b.ID_TERJ = c.id_terj 
				left join dbo.tecajnic t on b.id_tec = t.id_tec 

					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						case when d.sif_terj = 'POLO' and @tip_leas = 'OL' then 'UNAPRIJED PLAĆENA NAJAMNINA' else RTRIM(d.naziv) end as LineDesc, --TODO Provjeriti po ispisima
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
						RTRIM(d.naziv) as LineDesc, --TODO Provjeriti po ispisima
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
						case when d.ima_robresti = 1 then 'PPMV' else RTRIM(d.naziv) end as LineDesc, 
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
							set InvoicePeriodStartDate = c.dat_od, InvoicePeriodEndDate = DATEADD(dd, -1, c.dat_do)
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
				--InvoiceNote = 'Račun ne može služiti za prijenos prava vlasništva na Primatelja leasinga bez originalne potvrde ' + rtrim(@p_podjetje) + ' o izvršenoj otplati leasing objekta.',
				InvoiceNote = 'Račun se izdaje temeljem Ugovora o financijskom leasingu ' + rtrim(b.id_pog) + '.' + ' Primatelj leasinga ne smije predmetom leasinga ni na kakav način pravno raspolagati, ne smije ga prodati, dati u zakup, podleasing, opteretiti ga bilo kakvim pravima trećih osoba i prenositi svoje ovlasti trećim osobama. Prijenos vlasništva moguć je isključivo po predočenju originala izjave leasing društva o podmirenju svih obveza po navedenom ugovoru o leasingu.'+
				CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
				CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
				InvoicePaymentNote = 'Plaćanje gore navedenog iznosa vrši se u obrocima, prema otplatnom planu, a prema navedenom tečaju. Zakašnjela plaćanja podliježu ugovorenoj zateznoj kamati prema Općim uvjetima leasinga.'
				From #invoice_data a
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'KLASA'
							) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = b.id_kupca
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'UR_BR'
							) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = b.id_kupca
				--TODO provjeriti zbog opcije reprogram zbog ponovljene aktivacije polja datume i ddv_id
				--join sa id_cont bi trebao riješti problem
				declare @ima_predujma bit 
				set @ima_predujma = 0

				if exists(select * from dbo.pogodba p inner join dbo.rac_out r on p.id_cont = r.id_cont and charindex(rtrim(r.ddv_id), p.kk_memo) != 0 where p.ddv_id = @id and r.SIF_RAC = 'AVA')
				begin
					update #invoice_data set InvoiceNote = 'Iznos do sada uplaćenih predujmova (' + rtrim(b.kk_memo) +'): ' + dbo.gfn_gccif(c.debit) + ', Ukupna vrijednost objekta s primljenim predujmovima: ' +  dbo.gfn_gccif(a.debit + a.neobdav + c.debit) + '. ' + InvoiceNote
					From #invoice_data a
					inner join dbo.pogodba b on a.id_cont = b.id_cont 
					inner join (
					SELECT SUM(r.debit) as debit, SUM(r.debit_neto) as debit_neto, SUM(r.debit_davek) AS debit_davek, SUM(r.brez_davka) AS brez_davka, SUM(r.neobdav) AS neobdav 
						FROM dbo.pogodba p 
						INNER JOIN dbo.rac_out r on p.id_cont = r.id_cont AND CHARINDEX(RTRIM(r.ddv_id), p.kk_memo) != 0
						WHERE p.ddv_id = @id
					) c on 1 = 1

					set @ima_predujma = 1
				end
					
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 
						'AKTIVAC' as LineItemIdent,
						case when @ima_predujma = 1 then 'Razlika po prethodno izdanim računima' else RTRIM(b.pred_naj) end as LineDesc,  --TODO AKO TREBA DODATI POJEDINOSTI IZ ZAPISNIKA O VOZILU/PLOVILO/OPREMA SAMO ZA UblEN, ZA SAD SAMO IZ PRILOGA
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
						'PPMV' as LineDesc,  
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
				InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA, 
				InvoiceTotalTaxAmount = a.debit_davek,
				InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit,
				InvoiceType = '386',
				--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
				InvoiceNote = CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
							  CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
				InvoicePaymentNote = 'Plaćanje u kunskoj protuvrijednosti prema ' + rtrim(t.naziv_tuj2) + ' na dan uplate.' -- TODO PO FIRMAMA, ALI KOD AVANSA NEMA PLAĆANJA
				From #invoice_data a 
				inner join dbo.avansi av on a.ddv_id = av.ddv_id
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				left join dbo.tecajnic t on b.id_tec = t.id_tec
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'KLASA'
							) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = b.id_kupca
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'UR_BR'
							) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = b.id_kupca
				
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 
						'PREDUJAM' as LineItemIdent,
						'Primljena uplata po ugovoru' as LineDesc,  --TODO podesiti po firmama
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
				InvoiceNote = CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
							  CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
				InvoicePaymentNote = '', --TODO podesiti sukladno odobrenje/terećenje
				document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end
				From #invoice_data a
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'KLASA'
							) katk on a.ID_CONT = katk.id_cont
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'UR_BR'
							) katur on a.ID_CONT = katur.id_cont
				--inner join dbo.pogodba b on a.id_cont = b.id_cont
				--MID: 45543 g_barbarak - Zakomentiran JOIN na pogodbu jer ju ne koristimo i dolazilo je do greške ako su slali račun za obrisani ugovor
				
				
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

		-- MOŽDA NEĆE TREBATI AKO ISPIS NIJE PODEŠEN U report_edoc_settings
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
				InvoiceNote = 'Zbog zakašnjelog plaćanja Vaše obveze na dan '+ isnull(convert(varchar(10), z.dat_zap, 104),'') +' obračunali smo zatezne kamate.'+
							CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
							CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
				InvoicePaymentNote = 'Ljubazno molimo da pri plaćanju obavezno upišete ispravan poziv na broj, u protivnom se uplata neće evidentirati. Hvala.' -- TODO PO FIRMAMA
				From #invoice_data a 
				inner join dbo.ZOBR_FA z on a.ddv_id = z.ddv_id
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'KLASA'
							) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = b.id_kupca
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'UR_BR'
							) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = b.id_kupca
					
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

		--NE KORISTE 'DOK_OPOM'
		if @source IN ('ZA_OPOM')
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
				InvoiceNote = CASE WHEN z.st_opomina in (1) THEN 'PRVA'
				                   WHEN z.st_opomina in (2) THEN 'DRUGA'
									WHEN z.st_opomina = 3 THEN 'TREĆA'
							 END + 'OPOMENA ZA NEPODMIRENE OBVEZE PO UGOVORU BR. ' + rtrim(b.id_pog)+
							 CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
							 CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
				InvoicePaymentNote = 'Ljubazno molimo da pri plaćanju obavezno upišete ispravan poziv na broj, u protivnom se uplata neće evidentirati.' -- TODO PO FIRMAMA
				From #invoice_data a 
				inner join dbo.pogodba b on a.id_cont = b.id_cont
				left join dbo.za_opom z on a.DDV_ID = z.ddv_id
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'KLASA'
							) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = b.id_kupca
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'UR_BR'
							) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = b.id_kupca
				
				
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
			InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.neobdav,
			InvoiceNote = rtrim(isnull(c.opombe, ''))+
						CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
						CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END, --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO 
			InvoicePaymentNote = case when c.id_tec != '000' then 'Plaćanje u kunskoj protuvrijednosti prema ' + rtrim(t.naziv_tuj2) + ' na dan uplate. ' 
							     else '' end  + 'Ljubazno molimo da pri plaćanju obavezno upišete ispravan poziv na broj, u protivnom se uplata neće evidentirati.' --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO
			From #invoice_data a
			inner join dbo.pogodba b on a.id_cont = b.id_cont 
			inner join dbo.OPC_FAKT c on a.DDV_ID = c.DDV_ID
			left join dbo.tecajnic t on c.id_tec = t.id_tec
			left join (
						Select cast(k.id_entiteta as int) as id_cont, k.val_string
						From dbo.kategorije_entiteta k
						inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
						where t.sifra = 'KLASA'
						) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = b.id_kupca
			left join (
						Select cast(k.id_entiteta as int) as id_cont, k.val_string
						From dbo.kategorije_entiteta k
						inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
						where t.sifra = 'UR_BR'
						) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = b.id_kupca
					
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
					'PPMV' as LineDesc,  
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

		--NE KORISTE ZA_REGIS
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
			InvoiceNote = case when dbo.gfn_Nacin_leas_HR(b.nacin_leas) = 'F1' then 'Za platiti: '+ dbo.gfn_gccif(a.debit_neto+a.debit_davek+a.brez_davka+a.neobdav+c.ostalo)+' ' + rtrim(n.dom_valuta) + '.' else '' end+
						CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
						CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
			InvoicePaymentNote = 'Plaćanje u kunskoj protuvrijednosti prema ' + rtrim(t.naziv_tuj2) + ' na dan uplate. ', -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end -- TODO AKO JE TEČAJNA NEGATIVNA MORA BITI CREDIT NOTE
			From #invoice_data a
			left join (Select ddv_id, sum(ostalo) as ostalo from dbo.tec_razl group by ddv_id) c on a.ddv_id = c.ddv_id
			inner join dbo.pogodba b on a.id_cont = b.id_cont
			left join dbo.tecajnic t on b.id_tec = t.id_tec
			left join dbo.nastavit n on 1 = 1
			left join (
						Select cast(k.id_entiteta as int) as id_cont, k.val_string
						From dbo.kategorije_entiteta k
						inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
						where t.sifra = 'KLASA'
						) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = b.id_kupca
			left join (
						Select cast(k.id_entiteta as int) as id_cont, k.val_string
						From dbo.kategorije_entiteta k
						inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
						where t.sifra = 'UR_BR'
						) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = b.id_kupca
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
			InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.NEOBDAV, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.NEOBDAV,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.NEOBDAV,
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO c
			InvoiceNote = rtrim(isnull(f.rep,''))+
						CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
						CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
			InvoicePaymentNote = 'Na zakašnjela plaćanja obračunavamo ugovorenu zateznu kamatu prema Općim uvjetima leasinga. Ljubazno molimo da pri plaćanju obavezno upišete ispravan poziv na broj, u protivnom se uplata neće evidentirati.'
			From #invoice_data a 
			inner join dbo.pogodba b on a.id_cont = b.id_cont
			inner join dbo.fakture f on a.ddv_id = f.ddv_id
			left join dbo.tecajnic t on f.id_tec = t.id_tec
			left join (
						Select cast(k.id_entiteta as int) as id_cont, k.val_string
						From dbo.kategorije_entiteta k
						inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
						where t.sifra = 'KLASA'
						) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = b.id_kupca
			left join (
						Select cast(k.id_entiteta as int) as id_cont, k.val_string
						From dbo.kategorije_entiteta k
						inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
						where t.sifra = 'UR_BR'
						) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = b.id_kupca

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
			InvoiceNote = rtrim(isnull(b.rep,''))+
						CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END+				
						CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
			InvoicePaymentNote ='Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu sukladno zakonu.', -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end
			From #invoice_data a 
			inner join dbo.gl_output_r b on a.ddv_id = b.DDV_ID 
			left join dbo.tecajnic t on b.id_tec = t.id_tec
			left join (
						Select cast(k.id_entiteta as int) as id_cont, k.val_string
						From dbo.kategorije_entiteta k
						inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
						where t.sifra = 'KLASA'
						) katk on a.ID_CONT = katk.id_cont
			left join (
						Select cast(k.id_entiteta as int) as id_cont, k.val_string
						From dbo.kategorije_entiteta k
						inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
						where t.sifra = 'UR_BR'
						) katur on a.ID_CONT = katur.id_cont

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
		h.data as InvoicePaymentAccount,
		cast('Molimo upišite ispravan poziv na broj' as varchar(max)) as InvoicePaymentNote, --Ovo ovisi koji je tip Ubl-a jer za Ubl mora biti do 
		cast(0 as decimal(18,2)) as InvoiceTotalNetAmount,
		cast(0 as decimal(18,2)) as InvoiceTotalTaxAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalWithTaxAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalAddCostsAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalRoundingAmount, 
		cast(0 as decimal(18,2)) as InvoiceTotalPayableAmount,
		cast('InvoiceEnvelope' as varchar(100)) as document_external_type, --TODO za odobrenje ovo mora biti CreditNoteEnvelope  
		cast(rtrim(isnull(dok.stevilka,'')) as varchar(max)) as InvoiceCustomContractReference, --TODO
		cast(rtrim(isnull(jn.val_string,'')) as varchar(max)) as InvoiceOrderReference, --TODO
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
			Select z.ID_ZBIRNIK, b.stevilka
			From dbo.krov_pog a 
			inner join dbo.zbirniki z on a.ID_KROV_POG = z.ID_KROV_POG
			left join dbo.dokument b on a.ID_KROV_POG = b.id_krov_pog and b.ID_OBL_ZAV = dbo.gfn_GetCustomSettings('Hr_Integration.HR_SLOG.JNContractDokType') and b.STATUS_AKT = 'A'
		) dok on z.ID_ZBIRNIK = dok.ID_ZBIRNIK
		left join dbo.nova_resources h ON h.id_resource = 'BKS_P_ZRAC2' and h.active = 1 --ovo je novo jer oni imaju svoj IBAN upisan
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
				InvoiceNote = case when @tip_leas = 'F1' then 'Obavijest o dospijeću prema Planu otplate: ' + dbo.gfn_gccif(b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '. UKUPNO ZA PLATITI: ' + dbo.gfn_gccif(a.debit + a.neobdav + b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '.' else '' end
								+ CASE WHEN katk.val_string != '' THEN CHAR(10)+ 'KLASA ' +rtrim(katk.val_string) ELSE '' END
								+ CASE WHEN katur.val_string != '' THEN CHAR(10)+ 'URBROJ ' +rtrim(katur.val_string) ELSE '' END,
				
				InvoicePaymentNote = case when b.id_tec != '000' then 'Iznos ' + case when @tip_leas = 'F1' then 'rate' else 'najamnine' end + ' izražen je u kunskoj protuvrijednosti prema ' + rtrim(t.naziv_tuj2) + ' na dan fakturiranja.' else '' end
									+ 'Na zakašnjela plaćanja obračunavamo ugovorenu zateznu kamatu prema Općim uvjetima leasinga.'
				From #invoice_data1 a 
				left join dbo.nastavit n on 1 = 1 
				outer apply (
					Select sum(sneto) as sneto, sum(SROBRESTI) as srobresti, sum(sobresti) as sobresti, sum(smarza) as smarza, sum(sdavek) as sdavek, sum(SDEBIT) as sdebit, ddv_id, min(id_cont) as id_cont,
					sum(debit) as debit, sum(neto) as neto, min(id_tec) as id_tec, min(id_val) as id_val, min(naz_tec) as naz_tec From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) where ddv_id = a.DDV_ID Group by ddv_id
				) b
				inner join dbo.pogodba pog on b.id_cont = pog.id_cont
				left join dbo.tecajnic t on pog.id_tec = t.id_tec 
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'KLASA'
							) katk on b.ID_CONT = katk.id_cont and a.ID_KUPCA = pog.id_kupca
				left join (
							Select cast(k.id_entiteta as int) as id_cont, k.val_string
							From dbo.kategorije_entiteta k
							inner join dbo.kategorije_tip t on k.id_kategorije_tip = t.id_kategorije_tip and t.entiteta = 'POGODBA'
							where t.sifra = 'UR_BR'
							) katur on b.ID_CONT = katur.id_cont and a.ID_KUPCA = pog.id_kupca

				
					
				--TODO OVAJ DIO PO LEASING KUĆI
				Select @rata_type =  
				Case when (cs.val = 'Anticipative' and dok.id_dokum is null) or (cs.val = 'Decursive' and dok.id_dokum is not null) Then 'Anticipative'
				when (cs.val = 'Decursive' And dok.id_dokum is null) Or (cs.val = 'Anticipative' And dok.id_dokum is not null) Then 'Decursive'
				Else '' End, 
				@rata_prije = pp.datum_prije,
				@rata_poslije = pp1.datum_poslije, 
				@obnaleto = c.obnaleto
				
				From #invoice_data1 a 
				inner join (Select top 1 id_cont, ddv_id, st_dok From #najem_fa1) d on a.ddv_id = d.ddv_id 
				inner join dbo.pogodba b on d.id_cont = b.id_cont
				left join dbo.obdobja c on b.id_obd = c.id_obd
				Left Join dbo.custom_settings cs on cs.code = 'BOOKING_CRO_INT_ACCR_TYPE'
				Left Join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
				Left Join dbo.dokument dok on b.id_cont = dok.id_cont and CHARINDEX(dok.id_obl_zav, cs1.val) > 0
				left join (Select id_cont, max(datum_dok) as datum_prije From dbo.planp where datum_dok < @datum_dok and id_terj = @id_terj group by id_cont)pp on b.id_cont = pp.id_cont
				left join (Select id_cont, max(datum_dok) as datum_poslije From dbo.planp where datum_dok > @datum_dok and id_terj = @id_terj group by id_cont)pp1 on b.id_cont = pp1.id_cont
				
				
				--TODO OVAJ DIO PO LEASING KUĆI
				if @rata_type = 'Anticipative'
				begin 
					set @startdate = @datum_dok
				
					if @rata_poslije is null or @obnaleto = 12 
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok) - 1
					end
				
					if @rata_poslije is not null and @obnaleto <> 12
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
						set @startdate = dbo.gfn_GetFirstDayOfMonth(@datum_dok)
						set @enddate = dbo.gfn_GetLastDayOfMonth(@datum_dok)
					end
					
					if @obnaleto <> 12 and @rata_prije is null
					begin 
						set @startdate = DATEADD(mm,-12/@obnaleto,@datum_dok) + 1
					end
				
					if @obnaleto <> 12 and @rata_prije is not null
					begin
						set @startdate = @rata_prije + 1
					end
				end
			
				update #invoice_data1 set  InvoicePeriodStartDate = @startdate, InvoicePeriodEndDate = @enddate

				if @tip_leas = 'F1'
				begin
					
					/*DODATNI TROŠKOVI NA RAČUNU*/
					--TODO PO FIRMI ZA SADA JE ZAJEDNO GLAVNICA + PPMV
					/*set  @xml = (
					Select AddCostName, AddCostAmount
					From (
						Select 'Obavijest o dospijeću glavnice' as AddCostName,
						sneto + SROBRESTI as AddCostAmount
						From #najem_fa 
						where ddv_id = @id
					) a
					FOR XML PATH ('InvoiceAddCost'), ROOT('ArrayOfInvoiceAddCost')  )
			
					set @addCostXml = cast(@xml as varchar(max))*/

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName, ArrayOfLineAddProperties
					From (
						Select rtrim(p.id_pog) + '-' + @id_terj as LineItemIdent, 
						'RATA za razdoblje' as LineDesc,  --TODO AKO JE UBLEN MOŽE SE STAVITI I PERIOD U OPIS STAVKE
						case when o.naziv_tuj3 is null or rtrim(o.naziv_tuj3) = ''  then 'H87' else rtrim(o.naziv_tuj3) end as LineQuantityUnit, 
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

				if @tip_leas = 'OL'
				begin 
					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName, ArrayOfLineAddProperties
					From (
						Select rtrim(p.id_pog) + '-' + @id_terj as LineItemIdent, 
						rtrim(b.naz_terj) + ' za razdoblje' as LineDesc, 
						case when o.naziv_tuj3 is null or rtrim(o.naziv_tuj3) = ''  then 'H87' else rtrim(o.naziv_tuj3) end as LineQuantityUnit, 
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
						'Udio PPMV-a' as LineDesc, 
						case when o.naziv_tuj3 is null or rtrim(o.naziv_tuj3) = ''  then 'H87' else rtrim(o.naziv_tuj3) end as LineQuantityUnit, 
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
						where b.srobresti <> 0
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
				InvoiceDate = a.DDV_DATE, -- MID 47061, g_barbarak promijenjeno iz najem_fa.datum_dok u rac_out.ddv_date 
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoiceDueDate = a.valuta, 
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO PREMA ISPISU
				InvoicePersonIssued = a.izdal,  --TODO PREMA ISPISU
				InvoiceTotalNetAmount = a.debit_neto + a.brez_davka + a.neobdav,  
				InvoiceTotalTaxAmount = a.debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = a.debit + a.neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = a.debit + a.neobdav,
				InvoiceTotalRoundingAmount = a.izravnava_ddv,
				
				InvoicePaymentNote = case when b.id_tec != '000' then 'Plaćanje u kunskoj protuvrijednosti prema ' + rtrim(t.naziv_tuj2) + ' na dan uplate. "' else '' end 
				From #invoice_data1 a
				outer apply (
					Select sum(sneto) as sneto, sum(SROBRESTI) as srobresti, sum(sobresti) as sobresti, sum(smarza) as smarza, sum(sdavek) as sdavek, sum(SDEBIT) as sdebit, ddv_id, min(id_cont) as id_cont,
					sum(debit) as debit, sum(neto) as neto, min(id_tec) as id_tec, min(id_val) as id_val, min(naz_tec) as naz_tec From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) where ddv_id = a.DDV_ID Group by ddv_id
				) b
				inner join dbo.VRST_TER c on c.ID_TERJ = @id_terj
				inner join dbo.pogodba pog on b.id_cont = pog.id_cont
				left join dbo.tecajnic t on pog.id_tec = t.id_tec				

				set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName, ArrayOfLineAddProperties
					From (
						Select rtrim(b.id_pog) + '-' + @id_terj as LineItemIdent, 
						case when d.sif_terj = 'POLO' and @tip_leas = 'OL' then 'UNAPRIJED PLAĆENA NAJAMNINA' else RTRIM(d.naziv) end as LineDesc,
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
						RTRIM(d.naziv) as LineDesc, --TODO Provjeriti po ispisima
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
						case when d.ima_robresti = 1 then 'PPMV' else RTRIM(d.naziv) end as LineDesc, 
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
				-- 07.03.2022. g_igorp MID 48485 podešavanje razdoblja potraživanja 
				if @id_terj = '36'
				BEGIN
					Select @rata_type =  
						Case when (cs.val = 'Anticipative' and dok.id_dokum is null) or (cs.val = 'Decursive' and dok.id_dokum is not null) Then 'Anticipative'
						when (cs.val = 'Decursive' And dok.id_dokum is null) Or (cs.val = 'Anticipative' And dok.id_dokum is not null) Then 'Decursive'
						Else '' End, 
						@rata_prije = pp.datum_prije,
						@rata_poslije = pp1.datum_poslije, 
						@obnaleto = c.obnaleto
					
					From #invoice_data1 a 
					inner join (Select top 1 id_cont, ddv_id, st_dok From #najem_fa1) d on a.ddv_id = d.ddv_id 
					inner join dbo.pogodba b on d.id_cont = b.id_cont
					left join dbo.obdobja c on b.id_obd = c.id_obd
					Left Join dbo.custom_settings cs on cs.code = 'BOOKING_CRO_INT_ACCR_TYPE'
					Left Join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
					Left Join dbo.dokument dok on b.id_cont = dok.id_cont and CHARINDEX(dok.id_obl_zav, cs1.val) > 0
					left join (Select id_cont, max(datum_dok) as datum_prije From dbo.planp where datum_dok < @datum_dok and id_terj = @id_terj group by id_cont)pp on b.id_cont = pp.id_cont
					left join (Select id_cont, max(datum_dok) as datum_poslije From dbo.planp where datum_dok > @datum_dok and id_terj = @id_terj group by id_cont)pp1 on b.id_cont = pp1.id_cont
					
					set @startdate = DATEADD(dd,-(DAY(@datum_dok)-1),@datum_dok)
					set @enddate = DATEADD(dd,-(DAY(DATEADD(mm,1,@datum_dok))),DATEADD(mm,12/@obnaleto,@datum_dok))
					
					update #invoice_data1 set  InvoicePeriodStartDate = @startdate, InvoicePeriodEndDate = @enddate
				END
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