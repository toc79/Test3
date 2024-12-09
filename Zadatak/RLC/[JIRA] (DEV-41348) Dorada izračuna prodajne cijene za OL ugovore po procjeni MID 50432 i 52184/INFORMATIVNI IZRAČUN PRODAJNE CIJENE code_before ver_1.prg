public PuOdg 

PuOdg = ""
lnOdg = rf_msgbox("Pitanje","Da li ponuda važeća za plaćanje zaključno do 25. dana u tek. mj.?","Ne","Da","Poništi")

DO case
	CASE lnOdg = 2	&& DA
		PuOdg = "2"
	CASE lnOdg = 1	&& NE
		PuOdg = "1"
	OTHERWISE
		RETURN .F.
ENDCASE

** 10.11.2023 g_tomislav MID 50432 - isti select/izračun kao na ispisu
IF cont4prov.str_sod > 0
	TEXT TO lcSql NOSHOW 
		DECLARE @XML AS xml = (SELECT REPLACE(CAST(xml_detail AS NVARCHAR(MAX)),'<?xml version="1.0" encoding="utf-16"?>','') FROM dbo.PON_PRED_ODKUP WHERE id_pon_pred_odkup = {0})

		DECLARE @temp TABLE (osnova DECIMAL (18,2), varscina DECIMAL(18,2), ppmv DECIMAL(18,2), net_val_fl DECIMAL(18,2), regist DECIMAL(18,2), neto DECIMAL(18,2), zam_obr DECIMAL(18,2), net_val_ol DECIMAL(18,2), debit_lobr_nedospjelo decimal(18,2))

		;WITH XMLNAMESPACES (N'urn:gmi:nova:leasing' AS NS)
		INSERT INTO @temp
		SELECT
			SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*', 0, IIF(vt.sif_terj = 'VOPC', r.value('(NS:neto)[1]', 'DECIMAL(18,2)'), r.value('(NS:disk_vred)[1]', 'DECIMAL(18,2)')))) AS osnova,
			SUM(DISTINCT(r.value('(NS:varscina)[1]', 'DECIMAL(18,2)'))) AS varscina,
			SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*', 0, r.value('(NS:robresti)[1]', 'DECIMAL(18,2)'))) AS ppmv,
			SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*' OR vt.sif_terj = 'VOPC', 0, r.value('(NS:net_val)[1]', 'DECIMAL(18,2)'))) AS net_val_fl,
			SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*' OR vt.sif_terj = 'VOPC', 0, r.value('(NS:regist)[1]', 'DECIMAL(18,2)'))) AS regist,
			SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*' OR vt.sif_terj = 'VOPC', 0, r.value('(NS:neto)[1]', 'DECIMAL(18,2)'))) AS neto,
			SUM(r.value('(NS:zam_obr)[1]', 'DECIMAL(18,2)')) AS zam_obr,
			SUM(IIF(r.value('(NS:z_davkom)[1]', 'CHAR(1)') = '*', r.value('(NS:net_val)[1]', 'DECIMAL(18,2)'), 0)) AS net_val_ol,
			sum(iif(r.value('(NS:evident)[1]', 'CHAR(1)') != '*' and vt.sif_terj = 'LOBR', r.value('(NS:debit)[1]', 'DECIMAL(18,2)'), 0)) as debit_lobr_nedospjelo
			FROM @XML.nodes('//NS:GBO_OfferPriorredemptionDetails') n(r)
		LEFT JOIN dbo.vrst_ter vt ON r.value('(NS:id_terj)[1]', 'CHAR(3)') = vt.id_terj 

		SELECT ((ppo.str_sod - temp.ppmv)/(1+(ISNULL(ds.davek, 0)/100))) --as osnovica_bez_pdv,
			-
			(temp.osnova + IIF(nl.odstej_var = 0, 0, dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE())) + ppo.str_odv + ppo.str_man + IIF(dbo.gfn_Nacin_leas_HR(pog.nacin_leas) != 'OL', ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),temp.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) + (((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100)) * (IIF(ISNULL(ppo.id_dav_st, '') = '', dsp.davek, ds.davek) / 100)), ((dbo.gfn_Xchange(dbo.gfn_GetNewTec(pog.id_tec),pog.varscina,pog.id_tec,GETDATE()) + temp.osnova) * (ppo.str_proc / 100))) - temp.ppmv)  --uk_brez_davek
			AS dobitak_gubitak
		FROM dbo.pon_pred_odkup ppo
		LEFT JOIN dbo.pogodba pog ON ppo.id_cont = pog.id_cont
		LEFT JOIN dbo.dav_stop ds ON ppo.id_dav_st = ds.id_dav_st
		LEFT JOIN dbo.nacini_l nl ON pog.nacin_leas = nl.nacin_leas
		LEFT JOIN @temp temp ON 1 = 1
		LEFT JOIN dbo.dav_stop dsp ON pog.id_dav_st = dsp.id_dav_st
		---------------------------------------------------------------------------------------------------------------------------------------------------
		WHERE ppo.id_pon_pred_odkup = {0}
	ENDTEXT

	lcSql = STRTRAN(lcSql, "{0}", str(cont4prov.id_pon_pred_odkup))
	
	IF GF_SQLEXECScalar(lcSql) < 0 
		OBVESTI("Gubitak po prodaji, potrebno je poslati Predobračun.")
	ENDIF
ENDIF


OBJ_ReportSelector.id_field = TRANS(cont4prov.id_pon_pred_odkup) + ";" + PuOdg