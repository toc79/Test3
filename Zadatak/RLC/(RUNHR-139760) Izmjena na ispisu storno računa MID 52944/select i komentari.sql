doraditi InvoiceNote i InvoicePaymentNote


ssoft objekt i select 

Text149, Text27, 


		private void Text27_Conditions(object sender, System.EventArgs e)
        {
            // CheckerInfo: Conditions Text27
            if ((!String.IsNullOrEmpty(spr_ddv.ddv_id) && (spr_ddv.ddv_old_d == 1)))
            {
                Stimulsoft.Report.Components.StiConditionHelper.Apply(sender, "Ar 10");
                ((Stimulsoft.Report.Components.StiComponent)(sender)).Enabled = false;
            }
            if ((!String.IsNullOrEmpty(spr_ddv.ddv_id) && !(spr_ddv.ddv_old_d == 1)))
            {
                ((Stimulsoft.Report.Components.StiComponent)(sender)).Enabled = true;
            }
            if ((String.IsNullOrEmpty(spr_ddv.ddv_id)))
            {
                ((Stimulsoft.Report.Components.IStiTextBrush)(sender)).TextBrush = new Stimulsoft.Base.Drawing.StiSolidBrush(System.Drawing.Color.Red);
                ((Stimulsoft.Report.Components.IStiBrush)(sender)).Brush = new Stimulsoft.Base.Drawing.StiSolidBrush(System.Drawing.Color.Transparent);
                Stimulsoft.Report.Components.StiConditionHelper.ApplyFont(sender, new System.Drawing.Font("Arial", 8F), Stimulsoft.Report.Components.StiConditionPermissions.All);
                ((Stimulsoft.Report.Components.IStiBorder)(sender)).Border = ((Stimulsoft.Base.Drawing.StiBorder)(((Stimulsoft.Report.Components.IStiBorder)(sender)).Border.Clone()));
                ((Stimulsoft.Report.Components.IStiBorder)(sender)).Border.Side = Stimulsoft.Base.Drawing.StiBorderSides.None;
                ((Stimulsoft.Report.Components.StiComponent)(sender)).Enabled = false;
            }
        }
        
        public void Text27__GetValue(object sender, Stimulsoft.Report.Events.StiGetValueEventArgs e)
        {
            // CheckerInfo: Text Text27
            e.Value = "Ispravak promjene porezne osnove temeljem ovjere!\r\n(U slučaju da niste primili dokument za ovjeru, molimo da ispravak porezne osnove potvrdite ovjerom ovog računa)";
        }
        
		
		
		private void Text149_Conditions(object sender, System.EventArgs e)
        {
            // CheckerInfo: Conditions Text149
            if ((!String.IsNullOrEmpty(spr_ddv.ddv_id) && spr_ddv.ddv_old_d == 1))
            {
                Stimulsoft.Report.Components.StiConditionHelper.Apply(sender, "Ar 10");
                ((Stimulsoft.Report.Components.StiComponent)(sender)).Enabled = true;
            }
            if ((String.IsNullOrEmpty(spr_ddv.ddv_id) ))
            {
                ((Stimulsoft.Report.Components.IStiTextBrush)(sender)).TextBrush = new Stimulsoft.Base.Drawing.StiSolidBrush(System.Drawing.Color.Red);
                ((Stimulsoft.Report.Components.IStiBrush)(sender)).Brush = new Stimulsoft.Base.Drawing.StiSolidBrush(System.Drawing.Color.Transparent);
                Stimulsoft.Report.Components.StiConditionHelper.ApplyFont(sender, new System.Drawing.Font("Arial", 8F), Stimulsoft.Report.Components.StiConditionPermissions.All);
                ((Stimulsoft.Report.Components.IStiBorder)(sender)).Border = ((Stimulsoft.Base.Drawing.StiBorder)(((Stimulsoft.Report.Components.IStiBorder)(sender)).Border.Clone()));
                ((Stimulsoft.Report.Components.IStiBorder)(sender)).Border.Side = Stimulsoft.Base.Drawing.StiBorderSides.None;
                ((Stimulsoft.Report.Components.StiComponent)(sender)).Enabled = false;
            }
            if ((!String.IsNullOrEmpty(spr_ddv.ddv_id) && !(spr_ddv.ddv_old_d == 1)))
            {
                ((Stimulsoft.Report.Components.IStiTextBrush)(sender)).TextBrush = new Stimulsoft.Base.Drawing.StiSolidBrush(System.Drawing.Color.Red);
                ((Stimulsoft.Report.Components.IStiBrush)(sender)).Brush = new Stimulsoft.Base.Drawing.StiSolidBrush(System.Drawing.Color.Transparent);
                Stimulsoft.Report.Components.StiConditionHelper.ApplyFont(sender, new System.Drawing.Font("Arial", 8F), Stimulsoft.Report.Components.StiConditionPermissions.All);
                ((Stimulsoft.Report.Components.IStiBorder)(sender)).Border = ((Stimulsoft.Base.Drawing.StiBorder)(((Stimulsoft.Report.Components.IStiBorder)(sender)).Border.Clone()));
                ((Stimulsoft.Report.Components.IStiBorder)(sender)).Border.Side = Stimulsoft.Base.Drawing.StiBorderSides.None;
                ((Stimulsoft.Report.Components.StiComponent)(sender)).Enabled = false;
            }
        }
        
        public void Text149__GetValue(object sender, Stimulsoft.Report.Events.StiGetValueEventArgs e)
        {
            // CheckerInfo: Text Text149
            e.Value = "Ovaj dokument je OBAVIJEST da je Raiffeisen Leasing d.o.o. proveo ispravak porezne osnovice sukladno članku 43.a Pravilnika o PDV-u koji se primjenjuje na izdane račune od 01.01.2024.";
        }

-- g_majam - MR52738, dodan uvjet u Text149

SELECT 	a.id_spr_ddv, a.datum, a.st_dok, a.id_kupca, a.dav_stev, a.debit, a.debit_neto, a.debit_davek,
	a.brez_davka, a.vrsta_rac, a.id_dav_st, a.id_cont, a.dav_obv, a.ddv_id, a.old_ddv_id,
	a.ddv_date, a.old_ddv_d, a.tip_knjige, a.opombe, a.neobdav, a.izpisan, a.potrdil, 
	a.received, a.ext_id, a.ext_type, 
	a.id_pog, a.sklic, a.id_strm, a.po_tecaju, a.id_val, a.dobrocno, a.id_tec,
	a.id_tec_new, a.deleted, a.id_cont_pog,
	a.id_val_new, a.naziv_new,
	a.naz_kr_kup, a.ddv_zav, a.naziv2_kup, a.naziv1_kup,
	a.ulica, a.id_poste, a.partner_dav_stev, a.vr_osebe,
	a.mesto, a.polni_naz, a.ulica_sed, a.id_poste_sed, a.mesto_sed, a.emso,
	a.dav_stop_davek,
	a.mesto_naziv,
	a.id_grupe,
	a.opombe_vrst_ter,
	a.stev_reg,
	a.nacin_leas,
	a.id_terj,
	a.pogodba_ddv_id,
	a.ddv_id_from_pogodba,
	a.id_klavzule, a.klavzula,
	a.izpisal, a.opombe_view,
	a.izpisal_desc, a.potrdil_desc,
	a.ro_izdal, a.ro_dat_vnosa
	, us.user_desc
	, dbo.gfn_TransformDDV_ID_HR(a.ddv_id, a.ddv_date) as Fis_BrRac
	, CASE WHEN a.ddv_date < ISNULL(cust.val, '20130701') THEN 1 ELSE 0 END as print_r1
	, dbo.gfn_TransformDDV_ID_HR(a.old_ddv_id, a.old_ddv_d) as Old_Fis_BrRac
	, CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) = 'OL' THEN 'operativnom' ELSE 'financijskom' END as txtNaciniL
	, CASE WHEN dbo.gfn_Nacin_leas_HR(a.nacin_leas) != 'F1' AND a.vrsta_rac='RPG' THEN 1 ELSE 0 END as prinPDV
	, CASE WHEN a.ddv_date < '20100101' THEN 0 ELSE 1 END AS PRINT_DDV_HR
	, CASE WHEN a.tip_knjige != 'IRAC' THEN a.neobdav ELSE 0 END AS print_neobdav
	, CASE WHEN SUBSTRING(a.opisdok,1,CHARINDEX(' ', a.opisdok) - 1) = 'REPROGRAM' THEN 'ISPRAVAK' ELSE SUBSTRING(a.opisdok,1,CHARINDEX(' ', a.opisdok) - 1) END as prva_rijec
	, CASE WHEN SUBSTRING(a.opisdok,1,CHARINDEX(' ', a.opisdok) - 1) = 'REPROGRAM' THEN REPLACE(a.opisdok,SUBSTRING(a.opisdok,1,CHARINDEX(' ', a.opisdok) - 1), 'ISPRAVAK GLAVNICE') ELSE a.OPISDOK END as opisdok
	, CASE WHEN CHARINDEX(grPPOM.VALUE, a.nacin_leas) > 0 THEN 1 ELSE 0 END AS PRINT_PPOM --DORADA PPOM
	, CASE WHEN CHARINDEX(grPPOM.VALUE, a.nacin_leas) > 0 AND a.debit_davek = 0 THEN 0 ELSE 1 END AS PRINT_PPOM_PDV
	, CASE WHEN a.debit_davek < 0 OR (a.debit_davek = 0 AND (a.debit+a.neobdav) < 0) THEN 1 ELSE 0 END print_dbrp
	, COALESCE(grp.value, '') as Print_izdao
	, COALESCE(grPrim.value, gr.value, '') AS Print_veri
	, RTRIM(LTRIM(gr_barcode.document_id)) +';'+RTRIM(LTRIM(a.id_pog))+';'++RTRIM(LTRIM(a.id_kupca))+';'+CAST(FORMAT(GETDATE(), 'yyyyMMddHHmmss') AS CHAR(14)) as barcode_rlc
	, CASE WHEN a.old_ddv_d >= '2024-01-01' THEN 1 ELSE 0 END as ddv_old_d
FROM dbo.pfn_gmc_print_spr_ddv() a
--dbo.pfn_gmc_print_spr_ddv() a
LEFT JOIN dbo.custom_settings cust on cust.code = 'Nova.Reports.Print_R1'
LEFT JOIN dbo.users us on us.username = a.ro_izdal
LEFT JOIN dbo.general_register grPPOM on grPPOM.id_register = 'RLC Reporting list' AND grPPOM.neaktiven = 0 AND grPPOM.id_key = 'RLC_PPOM_NL'
LEFT JOIN dbo.GENERAL_REGISTER gr ON gr.ID_REGISTER = 'REPORT_SIGNATORY' and gr.id_key = CASE WHEN a.debit_davek < 0 OR (a.debit_davek = 0 AND (a.debit+a.neobdav) < 0) THEN 'SPR_DBRPV' ELSE 'SPR_ZVECV' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grp ON grp.ID_REGISTER = 'REPORT_SIGNATORY' and grp.id_key = CASE WHEN a.debit_davek < 0 OR (a.debit_davek = 0 AND (a.debit+a.neobdav) < 0) THEN 'SPR_DBRP' ELSE 'SPR_ZVEC' END AND gr.neaktiven = 0
LEFT JOIN dbo.GENERAL_REGISTER grPrim ON grPrim.ID_REGISTER = 'REPORT_SIGNATORY' and grPrim.id_key = a.ro_izdal
OUTER APPLY(SELECT val_char AS document_id FROM dbo.gfn_g_register_active_v('BARCODE_REPORTS_RLHR','') WHERE id_key = 'DDV_DBRP_ZVEC_SSOFT_RLC') gr_barcode
where a.id_spr_ddv=@id

