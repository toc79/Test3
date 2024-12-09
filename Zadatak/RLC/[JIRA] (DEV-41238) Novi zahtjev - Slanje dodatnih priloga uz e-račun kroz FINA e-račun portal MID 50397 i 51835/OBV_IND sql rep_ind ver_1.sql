-- 30.07.2020 g_tomislav MR 45163 - dodan dok_hr
-- 24.10.2023 g_tomislav MID 50397 - optimization by removing unnecessary columns

SELECT 	
	--A.brez_davka, A.datum, A.ddv_date, A.debit_davek, A.debit_neto,
	--A.ddv_id, A.debit, 
	--A.id_cont, A.id_dav_st, A.id_kupca, A.id_rtip , A.id_tec, A.izpisan, A.ndavek, A.neobdav, A.nindeks, A.nmarza, 
	--A.old_ddv_d, A.old_ddv_id, A.opisdok, A.opombe, A.sdatum, A.sdavek, A.sindeks, A.smarza, 
	--A.st_dok, A.ddv_st_dok,
	--B.po_tecaju/(CASE WHEN N.id_tec_new IS NULL THEN 1 ELSE N.faktor END) AS po_tecaju, B.id_strm, B.dat_aktiv, B.ddv,
	--E.stevilka as st_poste, 
	--F.davek, 	--N.naziv as naziv_tec_pog, 
	--T.naziv as naziv_tec_rep_ind, O.id_grupe, PP.dat_zap as ddv_dat_zap,
	--ro.izdal as ro_izdal, ro.dat_vnosa as ro_dat_vnosa, --dbo.gfn_transformDDV_ID_HR(a.ddv_id,a.ddv_date) as Fis_BrRac, --RTRIM(CONVERT(VARCHAR(50), ro.dat_vnosa,104) + '. ' + CONVERT(VARCHAR(50), ro.dat_vnosa,108)) as Dat_Izdavanja, 	--CASE WHEN a.ddv_date < ISNULL(cust.val, '20500101') AND ISNULL(a.ddv_id,'')<>''  THEN 1 ELSE 0 END as print_r1, --CASE WHEN ISNULL(a.ddv_id,'') = '' THEN 0 ELSE 1 END AS Invoice,
	--CASE WHEN A.debit_neto+A.brez_davka <> 0 THEN 1 ELSE 0 END AS Print_C1,
	A.id_rep_ind, A.ndatum,  A.nneto, A.nobresti, A.nobrok, 
	A.sneto, A.sobresti, A.sobrok, A.st_obrokov, --A.timestamp, A.vnesel, A.vrsta_rac,
	B.id_pog, --B.nacin_leas, B.pred_naj, B.dobrocno, B.fix_del, B.sklic,
	C.naz_kr_kup, C.ulica, C.mesto, C.id_poste, -- C.naziv1_kup, C.naziv2_kup, C.dav_stev, C.polni_naz,
	C.ulica_sed, C.id_poste_sed, C.mesto_sed, --C.emso, C.vr_osebe, C.stev_reg,
	D.naziv as naziv_ind, -- D.id_tiprep,
	CASE WHEN T.id_val = 'HRK' THEN 'KN' ELSE T.id_val END AS id_val,
	KS.klavzula, --KS.id_klavzule,
	dbo.gfn_Nacin_leas_HR(b.nacin_leas) as tip_leas, 
	CASE WHEN LTRIM(RTRIM(c.ulica)) = LTRIM(RTRIM(c.ulica_sed)) THEN 1 ELSE 0 END AS Print_C2,
	case when dok_hr.id_obl_zav is null then 0 else 1 end as Print_moratorij,
	12/obd.obnaleto AS rtip_txt,
    case when c.vr_osebe in ('FO','F1') THEN 1 else 0 end as print_dani
FROM dbo.rep_ind A  
INNER JOIN dbo.pogodba B ON A.id_cont = B.id_cont
INNER JOIN dbo.tecajnic T ON T.id_tec = DBO.GFN_GETNEWTEC(A.id_tec)
INNER JOIN dbo.partner C ON B.id_kupca = C.id_kupca
INNER JOIN dbo.rtip D ON D.id_rtip = A.id_rtip
INNER JOIN dbo.obdobja obd on obd.id_obd= d.id_obdrep
--INNER JOIN dbo.tecajnic N ON N.id_tec = B.id_tec
--INNER JOIN dbo.poste E ON C.id_poste = E.id_poste
--LEFT JOIN dbo.dav_stop F ON A.id_dav_st = F.id_dav_st
--LEFT JOIN dbo.vrst_opr O ON B.id_vrste = O.id_vrste
--LEFT JOIN dbo.planp PP WITH (NOLOCK) ON a.ddv_st_dok = PP.st_dok
--LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
LEFT JOIN dbo.rac_out RO ON RO.ddv_id = A.ddv_id
LEFT JOIN dbo.klavzule_sifr KS ON KS.id_klavzule = RO.id_klavzule
outer apply (select top 1 id_obl_zav, velja_do --zacetek, 
			from dbo.dokument 
			where id_obl_zav = 'HR' and status_akt = 'A' 
			and A.ndatum between zacetek and isnull(velja_do, '99991231') --velja_do je popunjena na svim dokumentima, ali nije obavezno polje pa sam ipak dodao isnull
			and id_cont = a.id_cont) dok_hr 
WHERE A.id_rep_ind = @id

Poštovani,
kako je Vaš Ugovor o {IIF(rep_ind.tip_leas=="ZP", "zajmu", "financijskom leasingu")} broj {Trim(rep_ind.id_pog)} vezan uz promjenjivu kamatnu stopu, a koja je definirana varijabilnim dijelom vezanim uz {Trim(rep_ind.naziv_ind)} i fiksnu maržu, izvršili smo uskladu iznosa mjesečne rate u našem leasing ugovornom odnosu.
Kamatna stopa vezana uz stopu {Trim(rep_ind.naziv_ind)} mijenja se svaka 3 mjeseca, odnosno kvartalno (1. siječnja, 1. travnja, 1. srpnja i 1. listopada za pripadajuće tromjesečje). U tekućem kvartalu primjenjuje se visina RKS-a od {IIF(rep_ind.print_dani==1, "10-tog dana zadnjeg mjeseca","zadnjeg radnog dana")}  prethodnog kvartala (31. ožujak, 30. lipanj, 30. rujan, 31. prosinac).
Vezano na porast visine {Trim(rep_ind.naziv_ind)}, kamatna stopa je porasla u punoj mjeri porasta te vrijednosti.
Kamatna stopa vezana uz stopu {Trim(rep_ind.naziv_ind)} mijenja se svakih 6 mjeseci, odnosno polugodišnje (1. siječnja i 1. srpnja za pripadajuće polugodište). U tekućem polugodištu primjenjuje se visina RKS-a od {IIF(rep_ind.print_dani==1, "10-tog dana zadnjeg mjeseca","zadnjeg radnog dana")} prethodnog polugodišta (30. lipanj, 31. prosinac).
Vezano na porast visine {Trim(rep_ind.naziv_ind)}, kamatna stopa je porasla u punoj mjeri porasta te vrijednosti.
U prilogu šaljemo novu otplatnu tablicu sa usklađenim iznosima mjesečnih rata.
{Format("{0:N2}", rep_ind.sneto)} {rep_ind.id_val.Trim()}
{Format("{0:N2}", rep_ind.nneto)} {rep_ind.id_val.Trim()}
{Format("{0:N2}", rep_ind.sobresti)} {rep_ind.id_val.Trim()}
{Format("{0:N2}", rep_ind.nobresti)} {rep_ind.id_val.Trim()}
{Format("{0:N2}", rep_ind.sobrok)} {rep_ind.id_val.Trim()}
{Format("{0:N2}", rep_ind.nobrok)} {rep_ind.id_val.Trim()}
{IIF(rep_ind.Print_moratorij == 0, "Promjenom koja je izvršena "+Format("{0:dd.MM.yyyy}", rep_ind.ndatum)+" usklađeno", "Promjena rata izvršena je na način da je uzeta visina "+rep_ind.naziv_ind.Trim()+" na dan "+Format("{0:dd.MM.yyyy}", rep_ind.ndatum)+", a prva izmjenjena rata bit će Vam poslana sa datumom "+Format("{0:dd.MM.yyyy}", prva_rata.datum_dok_MinDate)+" zbog počeka otplate koji je korišten po ugovoru."+System.Environment.NewLine+"Usklađeno")} je {Format("{0:N0}", rep_ind.st_obrokov)} rata te je došlo do sljedećih promjena u otplatnoj tablici:
{Format("{0:dd.MM.yyyy}", planp.datum_dok)}
{planp.txtOpis.Trim()}
{Format("{0:N0}", planp.zap_obr)}
{Format("{0:N2}", planp.debit)}
{Format("{0:N2}", planp.neto + planp.marza)}
{Format("{0:N2}", planp.obresti)}
{Format("{0:N2}", planp.robresti)}
{planp.id_val.Trim()}
{rep_ind.klavzula.Trim()}
{rep_ind.naz_kr_kup.Trim()} {rep_ind.ulica.Trim()} {rep_ind.id_poste.Trim()} {rep_ind.mesto.Trim()} {rep_ind.ulica_sed.Trim()}, {rep_ind.id_poste_sed.Trim()} {rep_ind.mesto_sed.Trim()}
Poštovani,
kako je Vaš Ugovor o operativnom leasingu broj {Trim(rep_ind.id_pog)}, točnije mjesečni obrok, promjenjiv uslijed primjene implicitne kamatne stope, a koja stopa se sastoji od ugovorene referentne kamatne stope odnosno {Trim(rep_ind.naziv_ind)} uvećanog za maržu, izvršili smo uskladu iznosa mjesečnog obroka u našem leasing ugovornom odnosu te sukladno tomu promijenili iznos računa za mjesečni obrok leasinga.
Referentna kamatna stopa se mijenja kvartalno (1. siječnja, 1. travnja, 1. srpnja i 1. listopada za pripadajuće tromjesečje), odnosno polugodišnje (1. siječnja i 1. srpnja za pripadajuće polugodište), ovisno o ugovorenoj RKS. U tekućem kvartalu primjenjuje se visina RKS-a od zadnjeg radnog dana prethodnog kvartala (31. ožujak, 30. lipanj, 30. rujan, 31. prosinac), a u tekućem polugodištu visina RKS-a od zadnjeg radnog dana prethodnog polugodišta (30. lipanj, 31. prosinac) sukladno članku 7. Općih uvjeta koji su sastavni dio Vašeg ugovora o leasingu.