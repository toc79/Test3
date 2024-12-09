2 Dodatno što nisam slso 
Za operativni leasing i Hibrid (OF) se i dalje uzima podatak podatak iz polja 'Vrijednost s PDV' zbrojen s 'Neoporeziv' iz starog pregleda knjige izlaznih računa u GL.

-- STARO
CASE WHEN b.SOURCE = 'NAJEM_FA' And v.sif_terj = 'LOBR' and c.nacin_leas in ('F1','F2') THEN c.sdebit ELSE rac_out.debit+rac_out.NEOBDAV END as iznos_rate,

--NOVO
declare @eom_blockade bit

set @eom_blockade = (select ~inactive from users where username = 'sys_eom') 

if @DocType = 'Invoice'
begin
	Select naz_kr_kup as [partner_title],
	CASE WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'LOBR' THEN '0001' 
	WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'MSTR' THEN '0003' 
	WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'POLO' THEN '0004' 
	WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'SFIN' THEN '0009' 
	WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'REG' THEN '0010' 
	WHEN b.source = 'ZOBR_FA' THEN '0006'
	WHEN b.source = 'AVANSI' THEN '0007'
	WHEN b.source = 'TEC_RAZL' THEN '0008'
	WHEN b.source = 'PLANP' and v1.sif_terj = 'MSTR' THEN '0003'
	WHEN b.source = 'PLANP' and v1.sif_terj = 'POLO' THEN '0004'
	WHEN b.source = 'PLANP' and v1.sif_terj = 'VARS' THEN '0005'
	WHEN b.source = 'FAKTURE' and v2.id_terj in ('1I','1J') THEN '0031'
	WHEN b.source = 'FAKTURE' and v2.id_terj = '13' THEN '0032'
	WHEN b.source = 'FAKTURE' and v2.id_terj not in ('1I','1J','13') THEN '0020'
	WHEN b.source = 'POGODBA' THEN '0011'
	WHEN b.source = 'SPR_DDV' THEN '0012'
	ELSE 'XXXX' END as [tip_dokumenta],
	CASE WHEN @eom_blockade = 0 Or b.source in ('SPR_DDV','POGODBA') Or f.id_kupca is not null or (e.id_kupca is not null And b.source = 'NAJEM_FA' And v.sif_terj = 'LOBR') Then '0' ELSE '1' End [edoc.filter_field],
	CASE WHEN b.source = 'NAJEM_FA' And v.sif_terj = 'LOBR' Then '1' ELSE '0' End [edoc.for_web],
	CASE WHEN @eom_blockade = 1 And b.source not in ('SPR_DDV','POGODBA') And f.id_kupca is not null And Not(e.id_kupca is not null And b.source = 'NAJEM_FA' And v.sif_terj = 'LOBR') Then '1' Else '0' End as [edoc.not_print],
	RTRIM(partner.id_kupca) + '_' +  
	CASE WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'LOBR' THEN '0001' 
	WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'MSTR' THEN '0003' 
	WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'POLO' THEN '0004' 
	WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'SFIN' THEN '0009' 
	WHEN b.source = 'NAJEM_FA' and v.sif_terj = 'REG' THEN '0010' 
	WHEN b.source = 'ZOBR_FA' THEN '0006'
	WHEN b.source = 'AVANSI' THEN '0007'
	WHEN b.source = 'TEC_RAZL' THEN '0008'
	WHEN b.source = 'PLANP' and v1.sif_terj = 'MSTR' THEN '0003'
	WHEN b.source = 'PLANP' and v1.sif_terj = 'POLO' THEN '0004'
	WHEN b.source = 'PLANP' and v1.sif_terj = 'VARS' THEN '0005'
	WHEN b.source = 'FAKTURE' and v2.id_terj in ('1I','1J') THEN '0031'
	WHEN b.source = 'FAKTURE' and v2.id_terj = '13' THEN '0032'
	WHEN b.source = 'FAKTURE' and v2.id_terj not in ('1I','1J','13') THEN '0020'
	WHEN b.source = 'POGODBA' THEN '0011'
	WHEN b.source = 'SPR_DDV' THEN '0012'
	ELSE 'XXXX' END
	+ '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	CASE WHEN b.SOURCE = 'NAJEM_FA' And v.sif_terj = 'LOBR' and dbo.gfn_Nacin_leas_HR(c.nacin_leas) = ('F1') THEN c.sdebit ELSE rac_out.debit+rac_out.NEOBDAV END as iznos_rate, -- 09.11.2017 popravljeno MR 39200
	dbo.gfn_transformDDV_ID_HR(rac_out.ddv_id, rac_out.ddv_date) as Fis_BrRac
	From dbo.partner 
	inner join dbo.rac_out on partner.id_kupca = rac_out.id_kupca 
	inner join (Select a.ddv_id, dbo.gfn_GetInvoiceSource(a.ddv_id) as source
		  From dbo.rac_out a 
		  Where a.ddv_id =  @Id and @DocType='Invoice'
	) b on rac_out.ddv_id = b.ddv_id
	left join dbo.najem_fa c on rac_out.ddv_id = c.ddv_id And b.source = 'NAJEM_FA'
	left join dbo.vrst_ter v on c.id_terj = v.id_terj
	left join dbo.planp pp on rac_out.ddv_id = pp.ddv_id And b.source = 'PLANP'
	left join dbo.vrst_ter v1 on pp.id_terj = v1.id_terj
	left join dbo.fakture fak on rac_out.ddv_id = fak.ddv_id And b.source = 'FAKTURE'
	left join dbo.vrst_ter v2 on fak.id_terj = v2.id_terj
	left join dbo.p_kontakt f on partner.id_kupca = f.id_kupca And f.id_vloga = 'XP'
	left join dbo.p_kontakt e on partner.id_kupca = e.id_kupca And e.id_vloga = 'XW'
	Where rac_out.ddv_id =  @Id and @DocType='Invoice'
end

if @DocType = 'Notif'
begin
	Select b.naz_kr_kup as [partner_title],
	'0002' as [tip_dokumenta],
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
	Where cast(a.id_za_regis as varchar(100)) =  @Id and @DocType='General'
end