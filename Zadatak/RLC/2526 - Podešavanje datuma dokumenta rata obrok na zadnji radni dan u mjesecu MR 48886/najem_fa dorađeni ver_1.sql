declare @datum_dok datetime = '20221230'
declare @obnaleto int = 2
declare @startdate datetime, @enddate datetime

set @startdate = DATEADD(dd,-(DAY(@datum_dok)-1), @datum_dok)
set @enddate =  DATEADD(dd,-(DAY(DATEADD(mm,1,@datum_dok))),DATEADD(mm,12/@obnaleto,@datum_dok))

select @startdate, @enddate

--dekurzivna 
set @startdate = dbo.gfn_GetFirstDayOfMonth(DATEADD(mm, -12/@obnaleto +1, @datum_dok)) 
set @enddate =  @datum_dok

select @startdate, @enddate, DATEADD(mm,-12/@obnaleto ,@datum_dok)

select * from dbo.DATUM_DOK_CREATE_TYPE

OL
{najem_fa.ZAP_OBR.ToString().Trim()}. Obrok za razdoblje ({Format("{0:dd.MM.yyyy}", najem_fa.Datum_od)}. - {Format("{0:dd.MM.yyyy}", najem_fa.Datum_do)}.)

OZ
Zakup/najam za razdoblje ({Format("{0:dd.MM.yyyy}", najem_fa.Datum_od)}. - {Format("{0:dd.MM.yyyy}", najem_fa.Datum_do)}.)

F1
Kamata u okviru {najem_fa.ZAP_OBR.ToString().Trim()}. rate ({Format("{0:dd.MM.yyyy}", najem_fa.Datum_od)}. - {Format("{0:dd.MM.yyyy}", najem_fa.Datum_do)}.)

select * from dbo.custom_settings cs1 where cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
update dbo.custom_settings set val = 'DN' where code = 'BOOKING_CRO_ACC_ALTMOD_DOK'

select * from dbo.DATUM_DOK_CREATE_TYPE
-- INSERT INTO dbo.DATUM_DOK_CREATE_TYPE(naziv,odmik,delovni_dan,neaktiven) VALUES('Prvi dan u mjesecu',1,0,1)
-- INSERT INTO dbo.DATUM_DOK_CREATE_TYPE(naziv,odmik,delovni_dan,neaktiven) VALUES('Prvi radni dan u mjesecu',1,1,1)
-- INSERT INTO dbo.DATUM_DOK_CREATE_TYPE(naziv,odmik,delovni_dan,neaktiven) VALUES('Zadnji radni dan u mjesecu',-1,1,1)
-- INSERT INTO dbo.DATUM_DOK_CREATE_TYPE(naziv,odmik,delovni_dan,neaktiven) VALUES('Zadnji dan u mjesecu mesecu',-1,1,0)
Nema uključeno na kalkulaciji niti ponudi
Tip datum dokumenta j epodešen, da li ostale tipove treba deaktivirati?

--update dbo.custom_settings set val = 'F1,FO,SP,FR,R1,SR' where code = 'Nova.GDPR.ListOfCustomerTypesForAccessLog'

Datum 1. rate će biti drugačiji na ponudi nego na ugovoru, može doći do promejne EKSa. Da li je bolje na ponudi podesiti tip datuma dokumenta?
Postavljanje datuma se može prekucati. Da li kreirati kontrolu na PROVERI PODATKE?

D:\NOVA_TEST\IO\edoc\edoc_dsa\Invoice_20210080833_2022_05_24_11_42_19_600.pdf     
-- Testiranje processing_plugins
declare @id varchar(100) = '20220027243'
declare @OriginalFileName varchar(2000) = (select file_name from dbo.EDOC_EXPORTED_FILES where document_id = @id)
declare @DocType varchar(100)='Invoice'
declare @ReportName varchar(100) = 'FAK_LOBR_SSOFT_RLC'

-- Testiranje najem_fa
declare @id varchar(100) = '20220027244' -- mjesečna '20220027243'


DECLARE @datum datetime, @tip_leas char(2)
SET @datum = getdate()

set @tip_leas = (select dbo.gfn_Nacin_leas_HR(b.nacin_leas) 
	From dbo.rac_out a 
	left join dbo.pogodba b on a.id_cont = b.id_cont
	where a.ddv_id = @id)

SELECT a.*, 
	c.obnaleto, 
	(a.SNETO+a.SMARZA+a.SOBRESTI)*h.davek/100 as znesek_net_pdv,
	a.SREGIST*h.davek/100 as sregist_pdv,
	b.ddv_id as pogodba_ddv_id, 
	CASE WHEN left(e.opis,3) = 'ZAK' THEN 'zakonsku' else 'ugovornu' end as obresti_opis, f.direktor,
	g.saldo As g_saldo, g.kredit as g_kredit, g.id_val as g_id_val, @tip_leas AS tip_leas,
	v.sif_terj,
	dbo.pfn_gmc_hub3_BarCode(a.id_kupca, n.dom_valuta, a.sdebit, 'HR01', RTRIM(b.sklic), 'OTHR', CASE WHEN b.nacin_leas IN ('NF', 'NO') THEN 'Zakup/najam '+CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) END+'.-'+CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) ELSE CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) END+'.)' ELSE LTRIM(RTRIM(ra.opisdok)) END) as barkod_value,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OL_LOBR,
	CASE WHEN @tip_leas = 'OZ' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OZ_LOBR,
	CASE WHEN @tip_leas = 'F1' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS F1_LOBR,
	CASE WHEN @tip_leas = 'ZP' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS ZP_LOBR,
	CASE 
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'LOBR' THEN 'Obrok'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'LOBR' THEN 'Glavnica'
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'SFIN' THEN 'Naknada za korištena sredstava'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'SFIN' THEN 'Interkalarna kamata'
		 WHEN @tip_leas = 'F1' AND v.sif_terj = 'POLO' THEN v.naziv
		 WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN 'Posebna najamnina'
		 ELSE v.naziv
	END AS NAZ_TERJ1,
	CASE WHEN opr.se_regis= '*' THEN zap.opis ELSE nzap.opis END AS ZAP_OPIS, 
	ISNULL(zap.reg_stev,'') as zap_reg_stev, ISNULL(zap.st_sas,'') as zap_st_sas,
	CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_od,''),104) 
		ELSE case when ALTMOD_DOK.id_cont is null then CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.datum_dok)-1),a.datum_dok),104) 
			else convert(varchar(25), dbo.gfn_GetFirstDayOfMonth(DATEADD(mm, -12/c.obnaleto + 1, a.datum_dok)), 104) -- Dekurzivna naplata
			end
		END AS Datum_od,
	CASE WHEN v.sif_terj = 'SFIN' THEN CONVERT(VARCHAR(25),ISNULL(inter_obr.dat_do,''),104) 
		ELSE case when ALTMOD_DOK.id_cont is null then CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,a.datum_dok))),DATEADD(mm,12/c.obnaleto,a.datum_dok)),104) 
			else convert(varchar(25), a.datum_dok, 104) -- Dekurzivna naplata
			end
		END AS Datum_do,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI END AS NOT_LOBR_NETO,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SDAVEK ELSE a.SNETO+a.SREGIST+a.SMARZA+a.SOBRESTI+a.SROBRESTI+a.SDAVEK END AS NOT_LOBR_NETO1,
	CASE WHEN @tip_leas = 'OL' AND v.sif_terj = 'POLO' THEN a.SDEBIT-a.SROBRESTI ELSE a.SDEBIT END AS NOT_LOBR_DEBIT,
	CASE WHEN inter_obr.dat_od IS NULL OR inter_obr.dat_do IS NULL THEN 1 ELSE 0 END AS SFIN_NA_PLANP,
	CASE WHEN v.sif_terj <> 'LOBR' THEN 1 ELSE 0 END AS NOT_LOBR,
	CASE WHEN LEN(RTRIM(a.dav_stev)) = 11 THEN 0 ELSE 1 END AS OIB_NOT_OK,
	CASE WHEN a.vr_osebe = 'SP' AND LEN(a.stev_reg)>0 THEN 1 ELSE 0 END AS PRINT_MBO,
	CASE WHEN a.vr_osebe NOT IN ('SP','FO') AND LEN(a.emso)>0 AND LEN(a.emso)<13 THEN 1 ELSE 0 END AS PRINT_MB,
	CASE WHEN a.dat_zap <= @datum THEN CAST(a.dolg-a.debit AS DECIMAL(18,2)) ELSE a.dolg END AS PRINT_DOLG,
	CASE WHEN kon.id_kupca_k IS NOT NULL THEN 1 ELSE 0 END AS Print_Vloga,
	ISNULL(konp.opis,'') as Print_DP, dok.opis1 as Print_DU,
	COALESCE(grp.value, '') as Print_izdao,
	COALESCE(grPrim.value, gr.value, '') AS Print_veri,
	CASE WHEN a.id_klavzule is null or a.id_klavzule = '' THEN 0 ELSE 1 END AS PRINT_KLAVZULA,
	CASE WHEN a.datum_dok < '20130101' THEN 0 ELSE 1 END AS PRINT_DDV_HR,
	dbo.gfn_transformDDV_ID_HR(a.ddv_id,a.datum_dok) as Fis_BrRac,
	RTRIM(CONVERT(varchar(50), a.ra_dat_vnosa,104) + '. '+ CONVERT(VARCHAR(50), a.ra_dat_vnosa,108)) AS Dat_Izdavanja,
	CASE WHEN a.datum_dok < ISNULL(cust.val, '20500101') THEN 1 ELSE 0 END AS print_r1,
	CASE WHEN g.saldo=0 AND (v.sif_terj='MSTR' or v.sif_terj='POLO') THEN 1 ELSE 0 END AS PRINT_PODMIREN,
	CASE WHEN a.vr_osebe = 'FO' or a.vr_osebe = 'F1' THEN 1 ELSE 0 END as je_FO,
	CASE WHEN (month(a.datum_dok) = 3 AND year(a.datum_dok) = 2019) AND v.sif_terj = 'LOBR' AND a.nacin_leas NOT IN ('NO','NF','PF','PO') AND f.vr_osebe NOT IN ('F1','FO') THEN 1 ELSE 0 END as PRINT_POSEBAN_TEKST,
	CASE WHEN a.id_tec IN ('016', '017') THEN 1 ELSE 0 END AS hnb_txt,
	--potpis skrbnika za welcome letter
	CASE WHEN f.skrbnik_1 IS NOT NULL THEN skrbnik.naz_kr_kup ELSE ' ' END AS Skrbnik,
	CASE WHEN a.id_kupca IN (select id_kupca
		from dbo.POGODBA
		group by ID_KUPCA
		having COUNT(ID_CONT) = 1 ) THEN 1 ELSE 0 
	END AS Prvi_ugovor,
	CASE WHEN g.id_terj = '21' and g.zap_obr = 1 THEN 1 ELSE 0 END AS Prva_rata,
	CASE WHEN b.nacin_leas = 'TP' THEN 0 ELSE 1 END AS Preuzeti_ugovor
FROM dbo.pfn_gmc_Print_InvoiceForInstallments(@datum) a
INNER JOIN dbo.pogodba b on a.id_cont = b.id_cont
LEFT JOIN dbo.obdobja c on b.id_obd = c.id_obd
LEFT JOIN dbo.gen_interkalarne_obr_child inter_obr ON a.st_dok = inter_obr.st_dok
LEFT JOIN dbo.obresti e on b.id_obrv = e.id_obr
LEFT JOIN dbo.partner f on b.id_kupca = f.id_kupca
LEFT JOIN dbo.planp g on a.id_cont = g.id_cont AND a.st_dok = g.st_dok
LEFT JOIN dbo.vrst_ter v on a.id_terj = v.id_terj
--correction in case of multiple zapisnika MR 40630 LEFT JOIN dbo.zap_reg zap on a.id_cont = zap.id_cont
--LEFT JOIN dbo.zap_ner nzap on a.id_cont = nzap.id_cont
outer apply (SELECT TOP 1 opis, reg_stev, st_sas FROM dbo.zap_reg WHERE zap_reg.id_cont = a.id_cont) zap
outer apply (SELECT TOP 1 opis FROM dbo.zap_ner WHERE zap_ner.id_cont = a.id_cont) nzap
LEFT JOIN dbo.vrst_opr opr on b.id_vrste = opr.id_vrste
INNER JOIN dbo.dav_stop h ON a.id_dav_st = h.id_dav_st
LEFT JOIN (SELECT a.id_cont, a.id_dokum, a.opis1
	FROM dbo.dokument a
INNER JOIN (SELECT MAX(id_dokum) AS id FROM dbo.dokument WHERE id_obl_zav = 'DU' GROUP BY id_cont) b ON a.id_dokum = b.id
			) dok on a.id_cont = dok.id_cont
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'IV' AND NEAKTIVEN = 0) kon on a.id_kupca = kon.id_kupca
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'DP' AND NEAKTIVEN = 0) konp on a.id_kupca = konp.id_kupca 
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'XW' AND NEAKTIVEN = 0) konXW on a.id_kupca = konXW.id_kupca
INNER JOIN dbo.rac_out ra on a.ddv_id = ra.ddv_id
LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
LEFT JOIN dbo.GENERAL_REGISTER gr ON gr.ID_REGISTER = 'REPORT_SIGNATORY' and gr.id_key = 
	CASE WHEN v.sif_terj = 'MSTR' THEN 'FAK_LOBRV_MSTR' 
		WHEN v.sif_terj = 'SFIN' THEN 'FAK_LOBRV_SFIN'
		WHEN v.sif_terj = 'POLO' THEN 'FAK_LOBRV_POLO'
		ELSE 'FAK_LOBRV' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key =
	CASE WHEN v.sif_terj = 'MSTR' THEN 'FAK_LOBR_MSTR' 
	WHEN v.sif_terj = 'SFIN' THEN 'FAK_LOBR_SFIN'
	WHEN v.sif_terj = 'POLO' THEN 'FAK_LOBR_POLO'
	ELSE 'FAK_LOBR' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grPrim ON grPrim.ID_REGISTER = 'REPORT_SIGNATORY' and grPrim.id_key = a.ra_izdal and grPrim.neaktiven = 0
JOIN dbo.nastavit n ON 1 = 1
LEFT JOIN (SELECT naz_kr_kup, id_kupca FROM dbo.PARTNER) skrbnik on f.skrbnik_1 = skrbnik.id_kupca --potpis skrbnika za welcome letter
left join dbo.custom_settings cs1 on cs1.code = 'BOOKING_CRO_ACC_ALTMOD_DOK'
Left Join dbo.dokument ALTMOD_DOK on a.id_cont = ALTMOD_DOK.id_cont and CHARINDEX(ALTMOD_DOK.id_obl_zav, cs1.val) > 0
WHERE a.ddv_id = @id