-- [[TAX_ID=23780250353]]
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

	declare @zero decimal(18,2)
	set @zero = 0

	Select 
	rtrim(a.id_kupca) + '_' +
	CASE WHEN x.source = 'NAJEM_FA' and nf.id_terj = '21' THEN '1321'
	WHEN x.source = 'ZOBR_FA' THEN '1322'
	WHEN x.source = 'TEC_RAZL' THEN '1323'
	WHEN x.source = 'AVANSI' THEN '1324'
	when x.source = 'NAJEM_FA' and nf.id_terj = '04' then '1325' 
	when x.source = 'NAJEM_FA' and nf.id_terj = '20' then '1326'
	when x.source = 'FAKTURE' then '1327'
	when x.source = 'NAJEM_FA' and nf.id_terj = '59' then '1328' 
	when x.source = 'NAJEM_FA' and nf.id_terj = '03' then '1329'
	when x.source = 'NAJEM_FA' and nf.id_terj = '64' then '1346' 
	when x.source = 'ZA_OPOM' and opom.ddv_id is not null and opom.st_opomina = 1 then '1330'
	when x.source = 'ZA_OPOM' and opom.ddv_id is not null and opom.st_opomina = 2 then '1331'
	when x.source = 'ZA_OPOM' and opom.ddv_id is not null and opom.st_opomina = 3 then '1332'
	when x.source = 'GL_OUTPUT_R' THEN '1336'
	WHEN x.source = 'OPC_FAKT' THEN '1341'
	WHEN x.source = 'SPR_DDV' THEN '1342'
	WHEN x.source = 'POGODBA' THEN '1343'
	when x.source = 'DOK_OPOM' THEN 
	CASE WHEN dok_opom.st_opomin=1 THEN '1338'
		 WHEN dok_opom.st_opomin=2 THEN '1344'
		 WHEN dok_opom.st_opomin=3 THEN '1345'
	ELSE '' 
	END
	ELSE '' END
	+ '_' + rtrim(a.ddv_id) + convert(varchar(10),getdate(),112)+'.pdf' as [edoc.destination_file_name],
	CASE WHEN nf.id_terj = '21' THEN nf.neto ELSE 0 END as [installment_neto],
	CASE WHEN nf.id_terj = '21' THEN nf.debit ELSE 0 END As [installment_bruto],
	CASE WHEN x.source = 'NAJEM_FA' and nf.id_terj = '21' THEN '1321'
	WHEN x.source = 'ZOBR_FA' THEN '1322'
	WHEN x.source = 'TEC_RAZL' THEN '1323'
	WHEN x.source = 'AVANSI' THEN '1324'
	when x.source = 'NAJEM_FA' and nf.id_terj = '04' then '1325' 
	when x.source = 'NAJEM_FA' and nf.id_terj = '20' then '1326'
	when x.source = 'FAKTURE' then '1327'
	when x.source = 'NAJEM_FA' and nf.id_terj = '59' then '1328' 
	when x.source = 'NAJEM_FA' and nf.id_terj = '03' then '1329'
	when x.source = 'NAJEM_FA' and nf.id_terj = '64' then '1346'
	when x.source = 'ZA_OPOM' and opom.ddv_id is not null and opom.st_opomina = 1 then '1330'
	when x.source = 'ZA_OPOM' and opom.ddv_id is not null and opom.st_opomina = 2 then '1331'
	when x.source = 'ZA_OPOM' and opom.ddv_id is not null and opom.st_opomina = 3 then '1332'
	when x.source = 'GL_OUTPUT_R' THEN '1336'
	WHEN x.source = 'OPC_FAKT' THEN '1341'
	WHEN x.source = 'SPR_DDV' THEN '1342'
	WHEN x.source = 'POGODBA' THEN '1343'
	when x.source = 'DOK_OPOM' THEN 
		CASE WHEN dok_opom.st_opomin=1 THEN '1338'
			 WHEN dok_opom.st_opomin=2 THEN '1344'
			 WHEN dok_opom.st_opomin=3 THEN '1345'
		ELSE '' 
	END
	ELSE '' END As [id_rac],
	/* MID:42631 g_barbarak - uključivanje u pripremu SPR_DDV, zakomentiran dio
	CASE WHEN x.source = 'SPR_DDV' THEN
		CASE WHEN gr.id_key is null THEN '1'
			ELSE rtrim(gr.val_char)
		END
	ELSE
	*/
	--MID 45590 g_barbarak - dodavanje uvjeta za tečajne razlike manje od 10kn
	--MID 47493 g_branisl - dodavanje dodatnih uvjeta za isključivanje uvjeta za tečajne manje od 10kn
	Case When @is_for_fina = 1 then '-1'
		When x.source = 'TEC_RAZL' and ABS(a.debit_neto+a.debit_davek+a.brez_davka+a.neobdav+c.ostalo) < 10 and TR.id_kupca IS NULL THEN 'TR'
		When pk1.id_kupca is null Then
			CASE WHEN pk.id_kupca is null THEN 
				CASE WHEN gr.id_key is null THEN '1'
					ELSE rtrim(gr.val_char)
				END
			ELSE '0' END 
	Else
		'PS'
	End as [edoc.filter_field],
	a.dat_vnosa as datum_izdavanja,
	dbo.gfn_transformddv_id_hr(a.ddv_id, a.ddv_date) as fis_br_rac,
	isnull(ro.osnovica_hrk, @zero) as osnovica_hrk, 
	isnull(ro.porez_hrk, @zero) as porez_hrk, 
	isnull(ro.oslobodjeno_hrk, @zero) as oslobodjeno_hrk, 
	isnull(ro.neoporezivo_hrk, @zero) as neoporezivo_hrk, 
	isnull(ro.osnovica_hrk, @zero) + isnull(ro.porez_hrk, @zero) + isnull(ro.oslobodjeno_hrk, @zero) + isnull(ro.neoporezivo_hrk, @zero) as ukupno_hrk,
	case when isnull(b.sif_terj,'') = 'LOBR' and isnull(nl.tip_leas,'') = 'F1' then nf.sneto else @zero end as glavnica_fl_hrk,
	isnull(ro.osnovica_hrk, @zero) + isnull(ro.porez_hrk, @zero) 
	+ isnull(ro.oslobodjeno_hrk, @zero) + isnull(ro.neoporezivo_hrk, @zero) 
	+ case when isnull(b.sif_terj,'') = 'LOBR' and isnull(nl.tip_leas,'') = 'F1' then nf.sneto else @zero end as sveukupno_hrk,
	case when x.source = 'TEC_RAZL' and ABS(a.debit_neto+a.debit_davek+a.brez_davka+a.neobdav+c.ostalo) < 10 and TR.id_kupca IS NULL then 0
		WHEN xl.id_kupca is not null and @is_for_fina = 0 then 1 else 0 end as copy_to_xl_folder,
	1 as pdf_sign 
	From dbo.rac_out a
	Inner Join (Select a.ddv_id, dbo.gfn_GetInvoiceSource(a.ddv_id) as source
		  From dbo.rac_out a 
		  Where a.ddv_id = @Id and @DocType='Invoice'
	)x On a.ddv_id = x.ddv_id
	Left Join dbo.najem_fa nf On a.ddv_id = nf.ddv_id 
	Left join dbo.vrst_ter b on (b.id_terj = nf.id_terj And x.source = 'NAJEM_FA') Or (b.sif_terj = 'ZOBR' And x.source = 'ZOBR_FA')
	left join dbo.partner p on a.id_kupca = p.id_kupca
	left join dbo.p_kontakt pk on p.id_kupca = pk.id_kupca and pk.id_vloga = '01' and pk.neaktiven = 0
	left join dbo.general_register gr on rtrim(p.id_poste) = rtrim(gr.id_key) And gr.id_register = 'POSTE_ZONE'
	left join (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' Group by id_kupca) pk1 on a.id_kupca = pk1.id_kupca 
	left join ( select 
				ro.ddv_id as id,
				sum(ro.debit_neto) as osnovica_hrk,
				sum(ro.debit_davek) as porez_hrk,
				sum(ro.neobdav) as neoporezivo_hrk,
				sum(ro.brez_davka + ro.debit_opr) as oslobodjeno_hrk,
				sum(ro.debit_izv) as izvoz_hrk
				from dbo.rac_out ro
				Where ro.DDV_ID = @Id and @DocType='Invoice'
				Group by ro.DDV_ID
	) ro on a.DDV_ID = ro.id
	left join(Select nacin_leas, 
			  CASE WHEN tip_knjizenja = 1 THEN 'OL'
				WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
				WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
				WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
				ELSE 'XX' END as tip_leas
				From dbo.nacini_l 
	)nl on nf.nacin_leas = nl.nacin_leas
	left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'XL' and neaktiven = 0 Group by id_kupca) xl on a.id_kupca = xl.id_kupca 
	left join dbo.gv_za_opom_with_arh opom on a.ddv_id = opom.ddv_id
	left join (select ddv_id, st_opomin from dbo.dok_opom where ddv_id = @id
			   union
			   select ddv_id, st_opomin from dbo.arh_dok_opom where ddv_id = @id) dok_opom on dok_opom.ddv_id=a.ddv_id
	left join (Select ddv_id, sum(ostalo) as ostalo from dbo.tec_razl group by ddv_id) c on a.ddv_id = c.ddv_id
	left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'TR' and neaktiven = 0 Group by id_kupca) TR on a.id_kupca = TR.id_kupca
	Where a.ddv_id =  @Id And @DocType = 'Invoice'

	/*
	'Invoice_' + RTRIM(a.ddv_id) + '_' + CASE WHEN x.source IN ('NAJEM_FA', 'ZOBR_FA' ) Then rtrim(b.naziv)
	When x.source = 'AVANSI' THEN  'PRIMLJENI PREDUJAM'
	When x.source = 'TEC_RAZL' THEN 'TEČAJNE RAZLIKE'
	ELSE '' END
	+ '_' + convert(varchar(10),getdate(),112)+'.pdf' As [edoc.destination_file_name],

	CASE WHEN pk.id_kupca is null THEN 
		CASE WHEN gr.id_key is null THEN '1'
			ELSE rtrim(gr.val_char)
		END
	ELSE '0' END as [edoc.filter_field],
	*/
end

if @DocType = 'Reminder'
begin 
Select 
	rtrim(a.id_kupca) + '_' +
	CASE when a.st_opomina = 1 then '1333'
	when a.st_opomina = 2 then '1334'
	when a.st_opomina = 3 then '1335'
	ELSE '' END
	+ '_' + replace(replace(rtrim(a.dok_opom),'-',''),'/','') + convert(varchar(10),getdate(),112)+'.pdf' as [edoc.destination_file_name],
	CASE when a.st_opomina = 1 then '1333'
	when a.st_opomina = 2 then '1334'
	when a.st_opomina = 3 then '1335'
	ELSE '' END As [id_rac],
	Case When pk1.id_kupca is null Then
		CASE WHEN pk.id_kupca is null THEN 
			CASE WHEN gr.id_key is null THEN '1'
				ELSE rtrim(gr.val_char)
			END
		ELSE '0' END 
	Else
		'PS'
	End as [edoc.filter_field],
	case when xl.id_kupca is not null then 1 else 0 end as copy_to_xl_folder,
	1 as pdf_sign 
	From dbo.gv_za_opom_with_arh a
	left join dbo.partner p on a.id_kupca = p.id_kupca
	left join dbo.p_kontakt pk on p.id_kupca = pk.id_kupca and pk.id_vloga = '01' and pk.neaktiven = 0
	left join dbo.general_register gr on rtrim(p.id_poste) = rtrim(gr.id_key) And gr.id_register = 'POSTE_ZONE'
	left join (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' Group by id_kupca) pk1 on a.id_kupca = pk1.id_kupca 
	left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'XL' and neaktiven = 0 Group by id_kupca) xl on a.id_kupca = xl.id_kupca 
	Where a.id_opom =  @Id And @DocType = 'Reminder'
end

if @DocType = 'Notif'
begin
	Select 
	rtrim(a.id_kupca) + '_' + '1337' + '_' +  replace(replace(rtrim(a.st_dok),'-',''),'/','') + convert(varchar(10),getdate(),112)+'.pdf' as [edoc.destination_file_name],
	'1337' As [id_rac],
	Case When pk1.id_kupca is null Then
		CASE WHEN pk.id_kupca is null THEN 
			CASE WHEN gr.id_key is null THEN '1'
				ELSE rtrim(gr.val_char)
			END
		ELSE '0' END 
	Else
		'PS'
	End as [edoc.filter_field],
	a.dat_prip as datum_pripreme,
	case when xl.id_kupca is not null then 1 else 0 end as copy_to_xl_folder ,
	1 as pdf_sign 
	From dbo.najem_ob a 
	left join dbo.partner p on a.id_kupca = p.id_kupca
	left join dbo.p_kontakt pk on p.id_kupca = pk.id_kupca and pk.id_vloga = '01' and pk.neaktiven = 0
	left join dbo.general_register gr on rtrim(p.id_poste) = rtrim(gr.id_key) And gr.id_register = 'POSTE_ZONE'
	left join (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' Group by id_kupca) pk1 on a.id_kupca = pk1.id_kupca 
	left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'XL' and neaktiven = 0 Group by id_kupca) xl on a.id_kupca = xl.id_kupca 
	Where cast(a.id_najem_ob as varchar(100)) =  @Id and @DocType = 'Notif'
end

if @DocType = 'RmndrDoc'
begin
	Select 
	rtrim(pog.id_kupca) + 
	CASE WHEN a.st_opomin=1 THEN '_1338_'
		 WHEN a.st_opomin=2 THEN '_1344_'
		 WHEN a.st_opomin=3 THEN '_1345_'
		 ELSE '_' 
	END
	+ replace(replace(rtrim(a.dok_opom),'-',''),'/','') + convert(varchar(10),getdate(),112)+'.pdf' as [edoc.destination_file_name],
	CASE WHEN a.st_opomin=1 THEN '1338'
		 WHEN a.st_opomin=2 THEN '1344'
		 WHEN a.st_opomin=3 THEN '1345'
	ELSE '' 
	END
	As [id_rac],
	CASE WHEN a.st_opomin = 1 THEN
		CASE WHEN gr.id_key is null THEN '1'
			ELSE rtrim(gr.val_char)
		END
	ELSE
	Case When pk1.id_kupca is null Then
		CASE WHEN pk.id_kupca is null THEN 
			CASE WHEN gr.id_key is null THEN '1'
				ELSE rtrim(gr.val_char)
			END
		ELSE '0' END 
	Else
		'PS'
	End
	END
	as [edoc.filter_field],
	case when xl.id_kupca is not null then 1 else 0 end as copy_to_xl_folder,
	1 as pdf_sign 
	From dbo.dok_opom a
	inner join dbo.dokument d on a.id_dokum = d.id_dokum
	inner join dbo.pogodba pog on d.id_cont = pog.id_cont
	inner join dbo.partner p on pog.id_kupca = p.id_kupca
	left join dbo.p_kontakt pk on p.id_kupca = pk.id_kupca and pk.id_vloga = '01' and pk.neaktiven = 0
	left join dbo.general_register gr on rtrim(p.id_poste) = rtrim(gr.id_key) And gr.id_register = 'POSTE_ZONE'
	left join (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' Group by id_kupca) pk1 on pog.id_kupca = pk1.id_kupca 
	left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'XL' and neaktiven = 0 Group by id_kupca) xl on pog.id_kupca = xl.id_kupca 
	Where a.id_opom =  @Id And @DocType = 'RmndrDoc'
	
	union all
	
	Select 
	rtrim(pog.id_kupca) + 
	CASE WHEN a.st_opomin=1 THEN '_1338_'
		 WHEN a.st_opomin=2 THEN '_1344_'
		 WHEN a.st_opomin=3 THEN '_1345_'
		 ELSE '_' 
	END
	+ replace(replace(rtrim(a.dok_opom),'-',''),'/','') + convert(varchar(10),getdate(),112)+'.pdf' as [edoc.destination_file_name],
	CASE WHEN a.st_opomin=1 THEN '1338'
		 WHEN a.st_opomin=2 THEN '1344'
		 WHEN a.st_opomin=3 THEN '1345'
	ELSE '' 
	END
	As [id_rac],
	CASE WHEN a.st_opomin = 1 THEN
		CASE WHEN gr.id_key is null THEN '1'
			ELSE rtrim(gr.val_char)
		END
	ELSE
	Case When pk1.id_kupca is null Then
		CASE WHEN pk.id_kupca is null THEN 
			CASE WHEN gr.id_key is null THEN '1'
				ELSE rtrim(gr.val_char)
			END
		ELSE '0' END 
	Else
		'PS'
	End
	END
	as [edoc.filter_field],
	case when xl.id_kupca is not null then 1 else 0 end as copy_to_xl_folder, 
	1 as pdf_sign 
	From dbo.arh_dok_opom a
	inner join dbo.dokument d on a.id_dokum = d.id_dokum
	inner join dbo.pogodba pog on d.id_cont = pog.id_cont
	inner join dbo.partner p on pog.id_kupca = p.id_kupca
	left join dbo.p_kontakt pk on p.id_kupca = pk.id_kupca and pk.id_vloga = '01' and pk.neaktiven = 0
	left join dbo.general_register gr on rtrim(p.id_poste) = rtrim(gr.id_key) And gr.id_register = 'POSTE_ZONE'
	left join (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' Group by id_kupca) pk1 on pog.id_kupca = pk1.id_kupca 
	left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'XL' and neaktiven = 0 Group by id_kupca) xl on pog.id_kupca = xl.id_kupca 
	Where a.id_opom =  @Id And @DocType = 'RmndrDoc'
end

if @DocType = 'TaxChngIx' 
begin
	Select 
	rtrim(a.id_kupca) + '_' + 
	CASE WHEN @ReportName = 'OBV_IND_SSOFT_OTP' THEN '1339'
		WHEN @ReportName = 'IND_REP_SSOFT_OTP' THEN '1340'
		ELSE ''
		END	+ '_' + replace(replace(rtrim(a.st_dok),'-',''),'/','') + convert(varchar(10),getdate(),112)+'.pdf' as [edoc.destination_file_name],
	CASE WHEN @ReportName = 'OBV_IND_SSOFT_OTP' THEN '1339'
		WHEN @ReportName = 'IND_REP_SSOFT_OTP' THEN '1340'
		ELSE ''
		END As [id_rac],
	Case When pk1.id_kupca is null Then
		CASE WHEN pk.id_kupca is null THEN 
			CASE WHEN gr.id_key is null THEN '1'
				ELSE rtrim(gr.val_char)
			END
		ELSE '0' END 
	Else
		'PS'
	End as [edoc.filter_field],
	case when xl.id_kupca is not null then 1 else 0 end as copy_to_xl_folder,
	1 as pdf_sign 
	From dbo.rep_ind a 
	left join dbo.partner p on a.id_kupca = p.id_kupca
	left join dbo.p_kontakt pk on p.id_kupca = pk.id_kupca and pk.id_vloga = '01' and pk.neaktiven = 0
	left join dbo.general_register gr on rtrim(p.id_poste) = rtrim(gr.id_key) And gr.id_register = 'POSTE_ZONE'
	left join (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' Group by id_kupca) pk1 on a.id_kupca = pk1.id_kupca 
	left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'XL' and neaktiven = 0 Group by id_kupca) xl on a.id_kupca = xl.id_kupca 
	Where cast(a.id_rep_ind as varchar(100)) =  @Id and @DocType = 'TaxChngIx'
end

if @DocType = 'InvoiceCum'
begin
	Select 
	rtrim(ra.id_kupca) + '_' + '1347' + '_' +  replace(replace(rtrim(a.ddv_id),'-',''),'/','') + convert(varchar(10),getdate(),112)+'.pdf' as [edoc.destination_file_name],
	'1347' As [id_rac],
	Case When @is_for_fina = 1 then '-1'
	     When pk1.id_kupca is null Then
			CASE WHEN pk.id_kupca is null THEN 
				CASE WHEN gr.id_key is null THEN '1'
					ELSE rtrim(gr.val_char)
				END
			ELSE '0' END 
	Else
		'PS'
	End as [edoc.filter_field],
	a.dat_vnosa as datum_pripreme,
	case when xl.id_kupca is not null and @is_for_fina = 0 then 1 else 0 end as copy_to_xl_folder ,
	1 as pdf_sign 
	From dbo.zbirniki a 
	INNER JOIN dbo.rac_out ra on a.ddv_id = ra.ddv_id
	left join dbo.partner p on ra.id_kupca = p.id_kupca
	left join dbo.p_kontakt pk on p.id_kupca = pk.id_kupca and pk.id_vloga = '01' and pk.neaktiven = 0
	left join dbo.general_register gr on rtrim(p.id_poste) = rtrim(gr.id_key) And gr.id_register = 'POSTE_ZONE'
	left join (Select id_kupca From dbo.p_kontakt where neaktiven = 0 and id_vloga = 'PS' Group by id_kupca) pk1 on ra.id_kupca = pk1.id_kupca 
	left join (Select id_kupca From dbo.p_kontakt Where id_vloga = 'XL' and neaktiven = 0 Group by id_kupca) xl on ra.id_kupca = xl.id_kupca 
	Where cast(a.id_zbirnik as varchar(100)) =  @id and @DocType = 'InvoiceCum'
	end

If @DocType='Invoice' 
Begin

	if @is_for_fina = 1
	begin 
		Select @is_for_fina as [fina.is_for_fina]
		
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

		/*Na sve račune se dodaju podaci o ugovoru, broju šasije, registarskoj oznaci i serijskom broju*/
			Select a.id_cont, d.id_pog, b.st_sas, b.reg_stev, c.ser_st, f.se_regis
			into #zapisnici1
			From rac_out a 
			inner join dbo.pogodba d on a.id_cont = d.id_cont
			inner join dbo.vrst_opr f on d.id_vrste = f.id_vrste
			outer apply (
				Select *
				From gfn_zap_reg_single_per_contract2(a.id_cont)
			)b
			outer apply (
				Select *
				From gfn_zap_ner_single_per_contract2(a.id_cont)
			)c
			where a.ddv_id = @id

			set @xml = (Select Name, Value 
							From (
									Select 'Ugovor' as Name, rtrim(id_pog) as Value From #zapisnici1 where id_pog is not null and id_pog <> ''
									union all
									Select 'Broj šasije' as Name, rtrim(st_sas) as Value From #zapisnici1 where st_sas is not null and st_sas <> '' and se_regis = '*'
									union all
									Select 'Registarska oznaka' as Name, rtrim(reg_stev) as Value From #zapisnici1 where reg_stev is not null and reg_stev <> ''  and se_regis = '*'
									union all
									Select 'Serijski broj' as Name, rtrim(ser_st) as Value From #zapisnici1 where ser_st is not null and ser_st <> '' and se_regis = '' 
							) res
							FOR XML PATH ('LineAddProperty'), ROOT('ArrayOfLineAddProperty')
							)

			set @addPropertyXml = replace(replace(CAST(@xml as varchar(max)), '<Name>', '<Name xmlns="urn:gmc:ui">' ), '<Value>', '<Value xmlns="urn:gmc:ui">' )

			drop table #zapisnici1
		/*Na sve račune se dodaju podaci o ugovoru, broju šasije, registarskoj oznaci i serijskom broju*/

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
			inner join dbo.kategorije_tip b on a.id_kategorije_tip = b.id_kategorije_tip and b.entiteta = 'POGODBA' and b.neaktiven = 0
			where b.sifra = 'ORDER_NO'
		) kat on p.ID_CONT = kat.id_cont and a.ID_KUPCA = p.id_kupca 
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
				InvoiceDate = a.DDV_DATE, -- MID 47061, g_barbarak promijenjeno iz najem_fa.datum_dok u rac_out.ddv_date
				InvoiceDeliveryDate = a.DDV_DATE,
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
				InvoiceTotalAddCostsAmount = 0, -- case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end ,
				InvoiceTotalPayableAmount = b.rac_out_debit + b.rac_out_neobdav, -- + case when @tip_leas = 'F1' then b.sneto + b.srobresti else 0 end,
				InvoiceNote = case when @tip_leas = 'F1' then 'Obavijest o dospijeću glavnice: ' + dbo.gfn_gccif(b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '. Sveukupno za platiti - ' + rtrim(cast(b.zap_obr as varchar(20))) + '. leasing obrok: ' + dbo.gfn_gccif(b.rac_out_debit + b.rac_out_neobdav + b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '.' else '' end,
				InvoicePaymentNote = case when @tip_leas = 'F1' 
											then 'Račun se odnosi na iznos kamate u obroku. Iznos glavnice je dio računa ' + dbo.gfn_TransformDDV_ID_HR(c.ddv_id, d.ddv_date) + ', sukladno otplatnoj tablici ugovora, i ne služi kao dokument za ponovno knjiženje, već kao obavijest za plaćanje.' + case when b.srobresti > 0 then ' U iznos glavnice uključen je i iznos financiranog PPMV-a sukladno otplatnom planu.' else '' end 
											else  '' end
									 + 'Navedeni iznos odgovara protuvrijednosti ' + rtrim(b.id_val) + ' ' +  dbo.gfn_gccif(b.debit) + ' primjenjujući ' + rtrim(b.naz_tec) + ' na dan izdavanja i vezan je uz ugovornu valutnu klauzulu. Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. '
									 + CASE WHEN c.kategorija1 = '102' AND b.neto = 0 THEN 'Kod zakašnjenja plaćanja za period u kojem se zaračunava smanjena naknada zbog COVID 19, ne zaračunavamo zateznu kamatu. Za plaćanja iza tog razdoblja '+ CASE WHEN left(e.opis,3) = 'ZAK' THEN 'zakonska' else 'ugovorna' end +' zatezna kamata biti će zaračunata.'  -- 08.04.2020 Tomislav MID 44543 COVID19
										ELSE 'Kod zakašnjenja plaćanja zaračunavamo ' + case when left(e.opis,3) = 'ZAK' then 'zakonsku' else 'ugovornu' end + ' zateznu kamatu.' END 
									 + case when b.id_tec != '000' then ' U slučaju da obavljate plaćanje do datuma dospijeća računa molimo Vas da iznos uplatite u kunskom iznosu navedenom u ovom računu. U slučaju da plaćate nakon datuma dospijeća računa, molimo Vas da navedeni iznos uplatite u kunskoj protuvrijednosti preračunat po tečaju na dan plaćanja koristeći ' + rtrim(b.naz_tec) + '.' else '' end
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				left join dbo.pogodba c on b.id_cont = c.id_cont 
				left join dbo.rac_out d on c.ddv_id = d.ddv_id
				left join dbo.nastavit n on 1 = 1 
				left join dbo.obresti e on c.id_obrv = e.id_obr

				declare @startdate datetime, @enddate datetime, @rata_type varchar(30), @rata_prije datetime, @rata_poslije datetime, @obnaleto decimal(6,2)
				declare @DN_kategorija1 varchar(50), @dn_startdate datetime, @dn_enddate datetime, @use_dn_dates bit
				
				set @DN_kategorija1 = (select top 1 id_key from dbo.gfn_g_register('DOK_KATEGORIJA1') where val_char = 'DN' and neaktiven = 0)
					
				--TODO OVAJ DIO PO LEASING KUĆI
				Select @rata_type =  
				Case when (cs.val = 'Anticipative' and dok.id_dokum is null) or (cs.val = 'Decursive' and dok.id_dokum is not null) Then 'Anticipative'
				when (cs.val = 'Decursive' And dok.id_dokum is null) Or (cs.val = 'Anticipative' And dok.id_dokum is not null) Then 'Decursive'
				Else '' End, 
				@rata_prije = pp.datum_prije,
				@rata_poslije = pp1.datum_poslije, 
				@obnaleto = c.obnaleto,
				@use_dn_dates = case when ltrim(rtrim(isnull(dok.kategorija1, ''))) = @DN_kategorija1 AND ltrim(rtrim(isnull(dok.ext_id, ''))) = d.st_dok THEN 1 ELSE 0 END, 
				@dn_startdate = dok.zacetek,
				@dn_enddate = dok.konec
				From #invoice_data a 
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				inner join #najem_fa d on a.ddv_id = d.ddv_id 
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
					
					if @obnaleto = 12
					begin
					
						set @startdate = dbo.gfn_GetFirstDayOfMonth(@datum_dok)
						set @enddate = dbo.gfn_GetLastDayOfMonth(@datum_dok)
					end
					
					if @obnaleto <> 12 and @rata_poslije is null
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok) - 1
					end
				
					if @obnaleto <> 12 and @rata_poslije is not null 
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
					
					if @use_dn_dates = 1
					begin
						set @startdate = isnull(@dn_startdate, @startdate)
						set @enddate = isnull(@dn_enddate, @enddate)
					end
				end
			
				update #invoice_data set  InvoicePeriodStartDate = @startdate, InvoicePeriodEndDate = @enddate
				
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
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						-- 08.04.2020 Tomislav MID 44543 COVID19 - iz teksta na dokumentu je izbačen string $[0]. $[1]. 
						--Kamata za vrijeme trajanja počeka u otplati glavnice zbog nastanka izvanrednih okolnosti (COVID 19) za razdoblje $[0]. $[1].
						case when p.kategorija1 = '102' and b.neto = 0 and dok_HR.opis1 is not null then replace(dok_HR.opis1, '$[0]. $[1].', '') else 'Kamata za razdoblje' end as LineDesc,  --TODO AKO JE UBLEN MOŽE SE STAVITI I PERIOD U OPIS STAVKE
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
						outer apply (select top 1 opis1 from dbo.dokument where id_obl_zav = 'HR' and status_akt = 'A' and id_cont = b.id_cont order by id_dokum desc) dok_HR
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
						-- 08.04.2020 Tomislav MID 44543 COVID19 - iz teksta na dokumentu je izbačen string $[0]. $[1]. 
						--Naknada zbog nastanka izvanrednih okolnosti (COVID 19) i smanjenog opsega korištenja leasing objekta za razdoblje $[0]. $[1].
						case when p.kategorija1 = '102' and b.neto = 0 and dok_HR.opis1 is not null then replace(dok_HR.opis1, '$[0]. $[1].', '') 
							else rtrim(cast(b.zap_obr as varchar(20))) + '. ' + rtrim(v.naziv) + ' za razdoblje' end as LineDesc, 
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
						left join dbo.vrst_ter v on b.id_terj = v.id_terj
						outer apply (select top 1 opis1 from dbo.dokument where id_obl_zav = 'HR' and status_akt = 'A' and id_cont = b.id_cont order by id_dokum desc) dok_HR
						where b.ddv_id = @id  
							union all
						Select @id_terj +'-PPMV' as LineItemIdent, 
						'Posebni porez na motorna vozila' as LineDesc, 
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
				declare @id_terj_napo varchar(10)
				set @id_terj_napo = (Select rtrim(id_terj) From dbo.vrst_ter where sif_terj = 'NAPO')
				
				update #invoice_data set 
				InvoiceDate = a.DDV_DATE, -- MID 47061, g_barbarak promijenjeno iz najem_fa.datum_dok u rac_out.ddv_date 
				InvoiceDeliveryDate = a.DDV_DATE, 
				InvoiceDueDate = b.dat_zap, 
				InvoicePaymentDesc = 'Plaćanje ' + rtrim(a.opisdok), --TODO PREMA ISPISU
				InvoicePersonIssued = b.ra_izdal,  --TODO PREMA ISPISU
				InvoiceTotalNetAmount = b.rac_out_debit_neto + b.rac_out_brez_davka + b.rac_out_neobdav,  
				InvoiceTotalTaxAmount = b.rac_out_debit_davek, -- POREZ
				InvoiceTotalWithTaxAmount = b.rac_out_debit + b.rac_out_neobdav,
				InvoiceTotalAddCostsAmount = 0,
				InvoiceTotalPayableAmount = b.rac_out_debit + rac_out_neobdav,
				InvoiceNote = case when c.sif_terj = 'POLO' then 'Posebna najamnina se odnosi na cijelo ugovoreno razdoblje trajanja leasing ugovora.' else '' end,
				InvoicePaymentNote = 'Navedeni iznos odgovara protuvrijednosti ' + rtrim(b.id_val) + ' ' +  dbo.gfn_gccif(b.debit) + ' primjenjujući ' + rtrim(b.naz_tec) + ' na dan izdavanja i vezan je uz ugovornu valutnu klauzulu. Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. Kod zakašnjenja plaćanja zaračunavamo ' + case when left(e.opis,3) = 'ZAK' then 'zakonsku' else 'ugovornu' end + ' zateznu kamatu.'
									+ case when b.id_tec != '000' then ' U slučaju da obavljate plaćanje do datuma dospijeća računa molimo Vas da iznos uplatite u kunskom iznosu navedenom u ovom računu. U slučaju da plaćate nakon datuma dospijeća računa, molimo Vas da navedeni iznos uplatite u kunskoj protuvrijednosti preračunat po tečaju na dan plaćanja koristeći ' + rtrim(b.naz_tec) + '.' else '' end
				From #invoice_data a
				inner join #najem_fa b on a.ddv_id = b.ddv_id 
				inner join dbo.VRST_TER c on b.ID_TERJ = c.id_terj 
				left join dbo.pogodba d on b.id_cont = d.id_cont
				left join dbo.obresti e on d.id_obrv = e.id_obr

					set @addCostXml = cast('' as varchar(max))

					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select @id_terj as LineItemIdent, 
						rtrim(case when d.sif_terj = 'SFIN' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
								when d.sif_terj = 'SFIN' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNE KAMATE ZA RAZDOBLJE'
								when d.sif_terj = 'NAPO' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
								when d.sif_terj = 'NAPO' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNA KAMATA'
								when d.sif_terj = 'POLO' and @tip_leas = 'OL' then 'POSEBNA NAJAMNINA'
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
						RTRIM(case when d.sif_terj = 'SFIN' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
								when d.sif_terj = 'SFIN' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNE KAMATE ZA RAZDOBLJE'
								when d.sif_terj = 'NAPO' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
								when d.sif_terj = 'NAPO' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNA KAMATA'
								when d.sif_terj = 'POLO' and @tip_leas = 'OL' then 'POSEBNA NAJAMNINA'
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
						case when d.ima_robresti = 1 
								then 'Posebni porez na motorna vozila' 
								else RTRIM(case when d.sif_terj = 'SFIN' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
											when d.sif_terj = 'SFIN' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNE KAMATE ZA RAZDOBLJE'
											when d.sif_terj = 'NAPO' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
											when d.sif_terj = 'NAPO' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNA KAMATA'
											when d.sif_terj = 'POLO' and @tip_leas = 'OL' then 'POSEBNA NAJAMNINA'
											else d.naziv end) 
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
							set InvoicePeriodStartDate = c.dat_od, InvoicePeriodEndDate = dateadd(dd, -1, c.dat_do)
						From #invoice_data a
						inner join #najem_fa b on a.DDV_ID = b.DDV_ID
						inner join dbo.gen_interkalarne_obr_child c on b.ST_DOK = c.st_dok
						where a.DDV_ID = @id and c.dat_do is not null and c.dat_od is not null
					end
					
					if @id_terj_napo = @id_terj
					begin
						update #invoice_data 
							set InvoicePeriodStartDate = dbo.gfn_GetFirstDayOfMonth(b.datum_dok), InvoicePeriodEndDate = dbo.gfn_GetLastDayOfMonth(b.datum_dok)
						From #invoice_data a
						inner join #najem_fa b on a.DDV_ID = b.DDV_ID
						where a.DDV_ID = @id 
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
				InvoiceNote = 'Račun ne može služiti za prijenos prava vlasništva na Primatelja leasinga bez originalne potvrde ' + rtrim(@p_podjetje) + ' o izvršenoj otplati leasing objekta.',
				InvoicePaymentNote = 'Detaljna specifikacija plaćanja po ovom računu definirana je otplatnom tablicom koja je sastavni dio Ugovora o leasingu, a leasing objekt, sukladno Općim uvjetima, ostaje u vlasništvu ' + rtrim(@p_podjetje) + ' do konačne otplate svih obveza po Ugovoru o leasingu broj ' + rtrim(b.id_pog) + '. Po izvršenoj otplati svih obveza ' + rtrim(@p_podjetje) + ' izdat će posebnu potvrdu o ispunjenju svih obveza s dozvolom prijenosa prava vlasništva na ime kupca.'
				From #invoice_data a
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
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
				InvoiceNote = 'Temeljem primljene uplate od ' + isnull(convert(varchar(10), c.dat_pl, 104),'') + ', a za Vašu knjigovodstvenu evidenciju, ispostavljamo Vam račun za primljeni predujam.' ,
				InvoicePaymentNote = '' -- TODO PO FIRMAMA, ALI KOD AVANSA NEMA PLAĆANJA
				From #invoice_data a 
				inner join dbo.avansi av on a.ddv_id = av.ddv_id
				inner join dbo.pogodba b on a.id_cont = b.id_cont 
				left join dbo.placila c on av.id_plac = c.id_plac 
				
					/*STAVKE*/
					set  @xml = (
					Select LineItemIdent, LineDesc, LineQuantityUnit,LineQuantity,LineNetPrice,LineNetTotal,LineTaxRate,LineTaxAmount,
					LineAmount,LineTaxNote,LineTaxName
					From (
						Select 
						'PREDUJAM' as LineItemIdent,
						'Primljena uplata' as LineDesc,  --TODO podesiti po firmama
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
				InvoiceNote = 'Izjava kupca/primatelja leasinga: Sukladno čl.33. st.7. Zakona o porezu na dodanu vrijednost, potpisom ovog dokumenta potvrđujemo da smo izvršili ispravak pretporeza, osim iznosa pretporeza za koji nismo imali pravo na odbitak u visini 100% iznosa (za nabave sredstava za osobni prijevoz u razdoblju 01.03.2012-31.12.2017.g.), sukladno čl. 27. prijelaznih i završnih odredbi Zakona o izmjenama i dopunama Zakona o porezu na dodanu vrijednost (Nar. nov. 115/16).',
				InvoicePaymentNote = 'Ispravak promjene porezne osnove temeljem ovjere! (U slučaju da niste primili dokument za ovjeru, molimo da ispravak porezne osnove potvrdite ovjerom ovog računa)', --TODO podesiti sukladno odobrenje/terećenje
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
				InvoiceNote = 'Temeljem Vašeg plaćanja dana '+ isnull(convert(varchar(10), z.dat_zap, 104),'') +' obračunali smo zatezne kamate.' ,
				InvoicePaymentNote = 'Gore navedeni iznos već je naplaćen Vašom uplatom, jer potraživanja za zateznu kamatu imaju prioritet zatvaranja, ali je za isti iznos ostao otvoren dospjeli dug po potraživanju na koje se obračunala zatezna kamata.' -- TODO PO FIRMAMA
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
				InvoiceNote = CASE WHEN z.st_opomina in (1, 2) THEN 'Obavještavamo Vas da smo uvidom u našu poslovnu evidenciju ustanovili da s datumom '+convert(varchar(10),z.datum_dok -1,104)+'. nisu podmirena potraživanja po ugovoru '+ rtrim(b.id_pog) + '.'
									WHEN z.st_opomina = 3 THEN 'Obavještavamo Vas da smo uvidom u našu poslovnu evidenciju ustanovili da, usprkos prethodno poslanim opomenama, s datumom '+convert(varchar(10),z.datum_dok -1,104)+'. nisu podmirena potraživanja po ugovoru '+ rtrim(b.id_pog) + '.'
									when x.st_opomin is not null then 'Obavještavamo Vas da smo, uvidom u našu poslovnu evidenciju ustanovili da s datumom '+convert(varchar(10),getdate(),104)+' nismo zaprimili svu ugovornu dokumentaciju.'
							 END				 ,
				InvoicePaymentNote = 'Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate.' -- TODO PO FIRMAMA
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

		if @source = 'OPC_FAKT'
		begin

			update #invoice_data set 
			InvoiceIssueDate = a.dat_vnosa,
			InvoiceDueDate = c.DAT_ZAP, 
			InvoiceDate = a.DDV_DATE,
			InvoiceDeliveryDate = a.DDV_DATE, 
			InvoicePaymentId = 'HR01 '+ ('999-' + c.id_kupca + '-' + rtrim(b.id_sklic)) +
				dbo.gfn_CalculateControlDigit('999-' + c.id_kupca + '-' + rtrim(b.id_sklic)), --TODO popraviti id_p1 prema ispisu
			InvoicePaymentDesc = '', --TODO NAPUNITI TEKST
			InvoicePersonIssued = a.izdal, --TODO NAPUNITI PREMA TEKSTU NA ISPISU
			InvoiceTotalNetAmount = a.debit_neto + a.BREZ_DAVKA + a.neobdav, 
			InvoiceTotalTaxAmount = a.debit_davek,
			InvoiceTotalWithTaxAmount = a.debit_neto + a.BREZ_DAVKA + a.debit_davek + a.neobdav,
			InvoiceTotalAddCostsAmount = 0,
			InvoiceTotalPayableAmount = a.debit + a.neobdav,
			InvoiceNote = rtrim(isnull(c.opombe, '')), --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO 
			InvoicePaymentNote = case when c.id_tec != '000' then 'Navedeni iznos odgovara protuvrijednosti ' + rtrim(t.id_val) + ' ' + dbo.gfn_gccif(c.debit) + ' primjenjujući ' + rtrim(t.naziv) + ' na dan izdavanja računa i vezan je uz valutnu klauzulu. Molimo Vas da uplatu izvršite u kunskoj protuvrijednosti koristeći ' + rtrim(t.naziv) + ' na dan plaćanja.' 
							     else '' end --TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO
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
			InvoiceNote = 'Tečajne razlike nastaju zbog razlike u tečaju na dan dospijeća računa i tečaja na dan Vaše uplate ako je u međuvremenu došlo do promjene ugovornog tečaja.'+case when dbo.gfn_Nacin_leas_HR(b.nacin_leas) = 'F1' then ' Obavijest o tečajnim razlikama na udio u glavnici: '+dbo.gfn_gccif(c.ostalo) + ' ' + rtrim(n.dom_valuta) + '. Ukupno za platiti: '+ dbo.gfn_gccif(a.debit_neto+a.debit_davek+a.brez_davka+a.neobdav+c.ostalo)+' ' + rtrim(n.dom_valuta) + '.' else '' end,
			InvoicePaymentNote = '', -- TODO PO FIRMAMA
			InvoiceType = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then '381' else InvoiceType end,
			document_external_type = case when (a.debit < 0 and a.neobdav <= 0) or (a.debit <= 0 and a.neobdav < 0) then 'CreditNoteEnvelope' else document_external_type end -- TODO AKO JE TEČAJNA NEGATIVNA MORA BITI CREDIT NOTE
			From #invoice_data a
			left join (Select ddv_id, sum(ostalo) as ostalo from dbo.tec_razl group by ddv_id) c on a.ddv_id = c.ddv_id
			inner join dbo.pogodba b on a.id_cont = b.id_cont
			left join dbo.nastavit n on 1 = 1	
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
			--TODO OVO PODESITI NA SVAKOJ FIRMI POSEBNO InvoiceNote
			InvoiceNote = rtrim(isnull(f.rep,'')) ,
			InvoicePaymentNote = case when f.id_tec != '000' then 'Navedeni iznos odgovara protuvrijednosti '+ rtrim(t.id_val) + ' ' + dbo.gfn_gccif(f.za_placilo) + ' primjenjujući ' + rtrim(t.naziv) +' na dan izdavanja. U slučaju da plaćate do datuma dospijeća računa molimo Vas da iznos uplatite u kunskom iznosu navedenom u ovom računu. Ukoliko vršite plaćanje nakon datuma dospijeća računa, molimo Vas da navedeni iznos uplatite u kunskoj protuvrijednosti primjenjujući ' + rtrim(t.naziv) +'' else '' end -- TODO PO FIRMAMA
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
			InvoiceNote = rtrim(isnull(b.rep,'')) ,
			InvoicePaymentNote = case when b.id_tec != '000' then 'Navedeni iznos odgovara protuvrijednosti '+ dbo.gfn_gccif(b.DEBIT_VAL) + ' ' + rtrim(t.id_val) + ' primjenjujući ' + rtrim(t.naziv) +'.' 
								 else '' end
								 +'Kod zakašnjenja plaćanja zaračunavamo zateznu kamatu sukladno zakonu.', -- TODO PO FIRMAMA
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
					Select rtrim(fp.PROTIKONTO) as LineItemIdent, 
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
				InvoiceNote = case when @tip_leas = 'F1' then 'Obavijest o dospijeću glavnice: ' + dbo.gfn_gccif(b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '. Sveukupno za platiti leasing obroke: ' + dbo.gfn_gccif(a.debit + a.neobdav + b.sneto + b.srobresti) + ' ' + rtrim(n.dom_valuta) + '.' else '' end,
				InvoicePaymentNote = case when @tip_leas = 'F1' 
											then 'Račun se odnosi na iznos kamate u obroku. Iznos glavnice je dio računa ' + dbo.gfn_TransformDDV_ID_HR(a.ddv_id, a.ddv_date) + ', sukladno otplatnoj tablici ugovora, i ne služi kao dokument za ponovno knjiženje, već kao obavijest za plaćanje. ' + case when b.srobresti > 0 then 'U iznos glavnice uključen je i iznos financiranog PPMV-a sukladno otplatnom planu. ' else '' end 
											else  '' end
									 + 'Navedeni iznos odgovara protuvrijednosti ' + rtrim(b.id_val) + ' ' +  dbo.gfn_gccif(b.debit) + ' primjenjujući ' + rtrim(b.naz_tec) + ' na dan izdavanja i vezan je uz ugovornu valutnu klauzulu. Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. '
									 + ' Kod zakašnjenja plaćanja zaračunavamo zakonsku zateznu kamatu.'  
									 + ' Tečajne razlike do apsolutnog bruto iznosa '  + dbo.gfn_gccif(l.meja_tr) + ' KN se ne obračunavaju.'
									 + case when b.id_tec != '000' then ' U slučaju da obavljate plaćanje do datuma dospijeća računa molimo Vas da iznos uplatite u kunskom iznosu navedenom u ovom računu. U slučaju da plaćate nakon datuma dospijeća računa, molimo Vas da navedeni iznos uplatite u kunskoj protuvrijednosti preračunat po tečaju na dan plaćanja koristeći ' + rtrim(b.naz_tec) + '.' else '' end
				From #invoice_data1 a 
				left join dbo.nastavit n on 1 = 1 
				left join dbo.loc_nast l on 1 = 1 
				outer apply (
					Select sum(sneto) as sneto, sum(SROBRESTI) as srobresti, sum(sobresti) as sobresti, sum(smarza) as smarza, sum(sdavek) as sdavek, sum(SDEBIT) as sdebit, ddv_id, min(id_cont) as id_cont,
					sum(debit) as debit, sum(neto) as neto, min(id_tec) as id_tec, min(id_val) as id_val, min(naz_tec) as naz_tec From dbo.pfn_gmc_Print_InvoiceForInstallments(GETDATE()) where ddv_id = a.DDV_ID Group by ddv_id
				) b

				set @DN_kategorija1 = (select top 1 id_key from dbo.gfn_g_register('DOK_KATEGORIJA1') where val_char = 'DN' and neaktiven = 0)
					
				--TODO OVAJ DIO PO LEASING KUĆI
				Select @rata_type =  
				Case when (cs.val = 'Anticipative' and dok.id_dokum is null) or (cs.val = 'Decursive' and dok.id_dokum is not null) Then 'Anticipative'
				when (cs.val = 'Decursive' And dok.id_dokum is null) Or (cs.val = 'Anticipative' And dok.id_dokum is not null) Then 'Decursive'
				Else '' End, 
				@rata_prije = pp.datum_prije,
				@rata_poslije = pp1.datum_poslije, 
				@obnaleto = c.obnaleto,
				@use_dn_dates = case when ltrim(rtrim(isnull(dok.kategorija1, ''))) = @DN_kategorija1 AND ltrim(rtrim(isnull(dok.ext_id, ''))) = d.st_dok THEN 1 ELSE 0 END, 
				@dn_startdate = dok.zacetek,
				@dn_enddate = dok.konec
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
					
					if @obnaleto = 12
					begin
					
						set @startdate = dbo.gfn_GetFirstDayOfMonth(@datum_dok)
						set @enddate = dbo.gfn_GetLastDayOfMonth(@datum_dok)
					end
					
					if @obnaleto <> 12 and @rata_poslije is null
					begin
						set @enddate = DATEADD(mm,12/@obnaleto,@datum_dok) - 1
					end
				
					if @obnaleto <> 12 and @rata_poslije is not null 
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
					
					if @use_dn_dates = 1
					begin
						set @startdate = isnull(@dn_startdate, @startdate)
						set @enddate = isnull(@dn_enddate, @enddate)
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
						'Kamata za razdoblje' as LineDesc,  --TODO AKO JE UBLEN MOŽE SE STAVITI I PERIOD U OPIS STAVKE
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
						rtrim(cast(b.zap_obr as varchar(20))) + '. ' + rtrim(v.naziv) + ' za razdoblje' as LineDesc, 
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
						'Posebni porez na motorna vozila' as LineDesc, 
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
				set @id_terj_napo = (Select rtrim(id_terj) From dbo.vrst_ter where sif_terj = 'NAPO')
				
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
				InvoiceNote = case when c.sif_terj = 'POLO' then 'Posebna najamnina se odnosi na cijelo ugovoreno razdoblje trajanja leasing ugovora.' else '' end,
				InvoicePaymentNote = 'Navedeni iznos odgovara protuvrijednosti ' + rtrim(b.id_val) + ' ' +  dbo.gfn_gccif(b.debit) + ' primjenjujući ' + rtrim(b.naz_tec) + ' na dan izdavanja i vezan je uz ugovornu valutnu klauzulu. Neupisivanje poziva na broj može imati za posljedicu neevidentiranje Vaše uplate. Kod zakašnjenja plaćanja zaračunavamo zakonsku zateznu kamatu.'
									+ case when b.id_tec != '000' then ' U slučaju da obavljate plaćanje do datuma dospijeća računa molimo Vas da iznos uplatite u kunskom iznosu navedenom u ovom računu. U slučaju da plaćate nakon datuma dospijeća računa, molimo Vas da navedeni iznos uplatite u kunskoj protuvrijednosti preračunat po tečaju na dan plaćanja koristeći ' + rtrim(b.naz_tec) + '.' else '' end
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
						rtrim(case when d.sif_terj = 'SFIN' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
								when d.sif_terj = 'SFIN' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNE KAMATE ZA RAZDOBLJE'
								when d.sif_terj = 'NAPO' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
								when d.sif_terj = 'NAPO' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNA KAMATA'
								when d.sif_terj = 'POLO' and @tip_leas = 'OL' then 'POSEBNA NAJAMNINA'
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
						rtrim(case when d.sif_terj = 'SFIN' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
								when d.sif_terj = 'SFIN' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNE KAMATE ZA RAZDOBLJE'
								when d.sif_terj = 'NAPO' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
								when d.sif_terj = 'NAPO' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNA KAMATA'
								when d.sif_terj = 'POLO' and @tip_leas = 'OL' then 'POSEBNA NAJAMNINA'
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
						case when d.ima_robresti = 1 
								then 'Posebni porez na motorna vozila' 
								else RTRIM(case when d.sif_terj = 'SFIN' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
											when d.sif_terj = 'SFIN' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNE KAMATE ZA RAZDOBLJE'
											when d.sif_terj = 'NAPO' and @tip_leas = 'OL' then 'NAKNADA ZA KORIŠTENJE SREDSTVA'
											when d.sif_terj = 'NAPO' and (@tip_leas = 'F1' or @tip_leas = 'FF') then 'INTERKALARNA KAMATA'
											when d.sif_terj = 'POLO' and @tip_leas = 'OL' then 'POSEBNA NAJAMNINA'
											else d.naziv end) 
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
					
					if @id_terj_napo = @id_terj
					begin
						update #invoice_data1 
							set InvoicePeriodStartDate = dbo.gfn_GetFirstDayOfMonth(b.datum_dok), InvoicePeriodEndDate = dbo.gfn_GetLastDayOfMonth(b.datum_dok)
						From #invoice_data1 a
						inner join (Select Top 1 ddv_id, datum_dok From #najem_fa1) b on a.DDV_ID = b.DDV_ID
						
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