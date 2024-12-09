------------------------------------------------------------------------------------------------------------
-- Function for getting data for Default Events
--
-- History:
-- 22.01.2008 MatjazB; Task ID 5099 - created
-- 06.02.2012 MatjazB; MID 33682 - delete function gfn_DefaultEvents_View (SQL moved here) and added active_days
-- 21.05.2012 Natasa; MID 33682 - added new field additional_id 
-- 04.02.2014 Jelena; Task ID 7796 - supported option of more evaluation of type E for partner per day 
-- 07.04.2014 Ziga; MID 43841 - addeds description_auto and field tcl_2_5_perc
-- 14.04.2014 Ziga; MID 44579 - added fields future_capital_at_start and future_capital_at_end
-- 22.01.2015 Ziga; Bug ID 31330 - removed field tcl_2_5_perc
-- 19.07.2016 Domen; M53650 - Adding fields DPD_previous, DPD_all from default_events
-- 01.03.2018 MatjazB; Task 12921 - GDPR
------------------------------------------------------------------------------------------------------------
--EXEC  dbo.grp_DefaultEvents_View 0,'',0,'',1,'1',0,''  SAMO AKTIVNI
CREATE PROCEDURE [dbo].[grp_DefaultEvents_View]
	@par_pogodba_enabled bit,
	@par_pogodba_pogodba varchar(20),
	@par_partner_enabled bit,
	@par_partner_partner varchar(6),
	@par_vsi_enabled bit,
	@par_vsi_tip smallint,
	@par_tip_enabled bit,
	@par_tip_tip varchar(8000)
AS BEGIN
DECLARE @id_kupca varchar(8)
if @par_partner_enabled = 1 
    set @id_kupca = '''' + @par_partner_partner + ''''
else
    set @id_kupca = 'null'
DECLARE @cmd varchar(8000)
SET @cmd = '
SELECT *
INTO #last_evaluations
FROM dbo.gv_PEval_LastEvaluation
CREATE INDEX ix_last_evaluations_id_kupca ON #last_evaluations (id_kupca)
SELECT de.id_default_events, de.id_d_event, de.id_tec, de.id_kupca, de.id_cont, de.def_start_date,
    de.overdue_at_start, de.exposure_at_start, de.def_end_date, de.overdue_at_end, de.exposure_at_end,
    de.id_d_reason, de.description, de.user_start, de.dat_start, de.user_end, de.dat_end,
    de.prepare_end, de.neakt_pog_fv_start, de.neakt_pog_fv_end, de.undrawn_b2_ell_frame_start,
    de.undrawn_b2_ell_frame_end, de.dni_zamude_start, de.dni_zamude_end,
    p.id_pog, p.status AS status_pog,
    s.naziv AS status_pog_desc,
    par.naz_kr_kup, par.p_status, par.ext_id,
    gr.value AS p_status_desc,
    dere.sif_d_event AS sif_d_event, dere.naziv AS naziv_event,
    derr.sif_d_event AS sif_d_reason, derr.naziv AS naziv_reason,
    pe.eval_model, pe.dat_eval, gre.value as eval_model_desc, pe.asset_clas, gra.value as asset_clas_desc,
    t.id_val, t.naziv,
    dbo.gfn_GetUserDesc(de.user_start) AS us_desc, dbo.gfn_GetUserDesc(de.user_end) AS ue_desc,
    de.future_capital_at_start AS fut_capital_at_start,
    de.future_capital_at_end AS fut_capital_at_end,
    CASE WHEN ISNULL(de.prepare_end, 0) = 0 AND de.def_end_date IS NULL
        THEN DATEDIFF(dd, de.def_start_date, dbo.gfn_GetDatePart(GETDATE())) 
        ELSE 0 
        END AS active_days,
    de.additional_id,
	de.description_auto as description_auto,
	round(de.future_capital_at_start * 0.025, 2) as tcl_2_5_perc,
	de.DPD_previous,
	de.DPD_all
FROM 
    dbo.default_events de
    LEFT JOIN dbo.pogodba p ON de.id_cont = p.id_cont
    LEFT JOIN dbo.statusi s ON p.status = s.status
    INNER JOIN dbo.gfn_Partner_Pseudo(''grp_DefaultEvents_View'', ' + @id_kupca + ') par ON de.id_kupca = par.id_kupca
	LEFT JOIN #last_evaluations pe on pe.id_kupca = par.id_kupca
	LEFT JOIN dbo.gfn_g_register(''ass_clas'') gra ON pe.asset_clas = gra.id_key
	LEFT JOIN dbo.gfn_g_register(''ev_model'') gre ON pe.eval_model = gre.id_key
    LEFT JOIN dbo.gfn_g_register(''p_status'') gr ON par.p_status = gr.id_key
    INNER JOIN dbo.default_events_register dere ON de.id_d_event = dere.id_d_event
    LEFT JOIN dbo.default_events_register derr ON de.id_d_reason = derr.id_d_event
    LEFT JOIN dbo.tecajnic t ON de.id_tec = t.id_tec
WHERE
    '
IF @par_vsi_enabled = 1 AND @par_vsi_tip = 0 SET @cmd = @cmd + ' 1 = 1' -- vse postavke
IF @par_vsi_enabled = 1 AND @par_vsi_tip = 1 SET @cmd = @cmd + ' de.def_end_date IS NULL' -- samo aktivne
IF @par_vsi_enabled = 1 AND @par_vsi_tip = 2 SET @cmd = @cmd + ' de.def_end_date IS NOT NULL' -- samo zaključene
IF @par_vsi_enabled = 1 AND @par_vsi_tip = 3 SET @cmd = @cmd + ' de.prepare_end = 1 AND de.def_end_date IS NULL' -- samo zaključene
IF @par_pogodba_enabled = 1 SET @cmd = @cmd + ' AND p.id_pog LIKE ''' + @par_pogodba_pogodba  + ''''
IF @par_partner_enabled = 1 SET @cmd = @cmd + ' AND de.id_kupca = ''' + @par_partner_partner  + ''''
IF @par_tip_enabled = 1
BEGIN
	SET @par_tip_tip = '''' + REPLACE(@par_tip_tip, ',', ''',''') + ''''
	SET @cmd = @cmd + ' AND de.id_d_event IN (' + @par_tip_tip + ')'
END
SET @cmd = @cmd + ' DROP TABLE #last_evaluations'
PRINT (@cmd)
EXECUTE (@cmd)
END