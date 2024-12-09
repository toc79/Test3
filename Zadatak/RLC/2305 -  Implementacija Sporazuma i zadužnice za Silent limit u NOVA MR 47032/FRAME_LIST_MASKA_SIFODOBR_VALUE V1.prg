loForm = GF_GetFormObject("frame_list_maska")
IF ISNULL(loForm) 
	RETURN
ENDIF

**----------------------------------------
** 11.01.2022 g_tomislav MID 47032 - created;

lnSif_odobrit = loForm.pgfFrames.pagFrame.txtSifOdobr.Value 

obvesti ("FRAME_LIST_MASKA_SIFODOBR_VALUE" +gce;
	+ "!GF_NULLOREMPTY(lnSif_odobrit): " + trans(!GF_NULLOREMPTY(lnSif_odobrit)) +gce;
	+ "frame_list.sif_odobrit: " + trans(GF_LOOKUP("frame_list.sif_odobrit", frame_list.id_frame, "frame_list.id_frame")) +gce;
	+ "lnSif_odobrit != GF_LOOKUP: " + trans(lnSif_odobrit != GF_LOOKUP("frame_list.sif_odobrit", frame_list.id_frame, "frame_list.id_frame")))

IF !GF_NULLOREMPTY(lnSif_odobrit) && OR lnSif_odobrit != 0 već je sadržano u gf_nulllorempty
	IF loForm.tip_vnosne_maske = 1 OR lnSif_odobrit != NVL(GF_LOOKUP("frame_list.sif_odobrit", frame_list.id_frame, "frame_list.id_frame"), 0)
		lnZnesek_val = loForm.pgfFrames.pagFrame.txtZnesek_val.Value
		lnNet_nal = NVL(GF_LOOKUP("odobrit.net_nal", lnSif_odobrit, "odobrit.id_odobrit"), 0)
	
		TEXT TO lcSql NOSHOW
			select o.id_odobrit, o.id_tec, o.net_nal, o.nacin_leas, o.vr_val, p.prv_obr_p, o.prv_obr, p.varsc_p, o.varscina
				, p.manstr_p, o.man_str, p.opcija_p, o.opcija, o.traj_naj, o.obr_mera, p.id_rtip
				, h.max_date_ended
			from dbo.odobrit o
			outer apply (select max(date_ended) as max_date_ended from dbo.WF_History where id_document = o.id_wf_document) h
			left join dbo.ponudba p on o.id_pon = p.id_pon
			where o.id_odobrit =
		ENDTEXT
		GF_SQLEXEC(lcSql + trans(lnSif_odobrit), "_ef_odobrit")
select * from _ef_odobrit
		*IF lnZnesek_val != lnNet_nal 
		* 1. pagFrame
		loForm.pgfFrames.pagFrame.txtZnesek_val.Value = _ef_odobrit.net_nal
		loForm.pgfFrames.pagFrame.txtDat_odobritve.Value = TTOD(_ef_odobrit.max_date_ended)
		* 2. pagFrameDetails
		loForm.pgfFrames.pagFrameDetails.cboLimNacin_leas.Value = _ef_odobrit.nacin_leas
		loForm.pgfFrames.pagFrameDetails.txtLimVr_val.Value = _ef_odobrit.vr_val
		loForm.pgfFrames.pagFrameDetails.txtLimProc_pol.Value = NVL(_ef_odobrit.prv_obr_p, 0)
		loForm.pgfFrames.pagFrameDetails.txtLimPrv_obr.Value = _ef_odobrit.prv_obr
		loForm.pgfFrames.pagFrameDetails.txtLimProc_varsc.Value = NVL(_ef_odobrit.varsc_p, 0)
		loForm.pgfFrames.pagFrameDetails.txtLimVarscina.Value = _ef_odobrit.varscina
		loForm.pgfFrames.pagFrameDetails.txtLimProc_ms.Value = NVL(_ef_odobrit.manstr_p, 0)
		loForm.pgfFrames.pagFrameDetails.txtLimMan_str.Value = _ef_odobrit.man_str
		loForm.pgfFrames.pagFrameDetails.txtLimProc_opcija.Value = NVL(_ef_odobrit.opcija_p, 0)
		loForm.pgfFrames.pagFrameDetails.txtLimOpcija.Value = _ef_odobrit.opcija
		loForm.pgfFrames.pagFrameDetails.txtLimTraj_naj.Value = _ef_odobrit.traj_naj
		loForm.pgfFrames.pagFrameDetails.txtLimObr_mera.Value = _ef_odobrit.obr_mera
		loForm.pgfFrames.pagFrameDetails.cboLimId_rtip.Value = NVL(_ef_odobrit.id_rtip, "")

		obvesti("Promijenjen je podatak u polju '" + allt(loForm.pgfFrames.pagFrame.lblZnesek_val.Caption) +"' iz " +allt(trans(lnZnesek_val, gccif)) +" u " +allt(trans(lnNet_nal, gccif)) +" (neto iznos financiranja)!")
		*ENDIF
	ENDIF
ENDIF
** KRAJ MID 47032---------------------------