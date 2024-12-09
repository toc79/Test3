Search "sif_bank" (39 hits in 5 files)
  U:\Source\Fox_2.22\Fox\common\prgs\sqltools.prg (3 hits)
	Line 4366: 		SELECT TOP 1 SIF_BANK FROM dbo.NASTAVIT WHERE DOM_VALUTA = '{0}'
	Line 4381: 	IF (GF_NULLOREMPTY(dom_banka.SIF_BANK)) THEN
	Line 4384: 		lcSql = STRTRAN(lcSql, "{2}", dom_banka.SIF_BANK)
  U:\Source\Fox_2.22\Fox\leasing\forms\pogodba_maska.SC2 (6 hits)
	Line 9577: 					lnDolg = GF_SQLExecScalar("SELECT dbo.gfn_GetCurrentDebtByCustomerFromDS('"+pogodba.id_kupca+"','" + GOBJ_Settings.GetVal("sif_bank")+"','" +DTOS(DATE())+"',0)")
	Line 9579: 					lnmax_znesek =  lnDolg + IIF(thisform.tip_vnosne_maske = 1, GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.net_nal, pogodba.id_tec, DATE()),0)			
	Line 9582: 					lnmax_znesek = GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.vr_val, pogodba.id_tec, DATE())
	Line 9585: 					lnDolg = GF_SQLExecScalar("SELECT dbo.gfn_GetCurrentDebtByCustomerFromDS('"+pogodba.id_kupca+"','" + GOBJ_Settings.GetVal("sif_bank")+"','" + DTOS(DATE())+"',1)")
	Line 9587: 					lnmax_znesek =  lnDolg + IIF(thisform.tip_vnosne_maske = 1, GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.net_nal, pogodba.id_tec, DATE()),0)			
	Line 9595: 			lcIdval_znesek = GF_LOOKUP('tecajnic.id_val',GOBJ_Settings.GetVal("sif_bank"),'tecajnic.id_tec')
  U:\Source\Fox_2.22\Fox\leasing\forms\pogodba_maska.SCT (12 hits)
	Line 7477: 			lnDolg = GF_SQLExecScalar("SELECT dbo.gfn_GetCurrentDebtByCustomerFromDS('"+pogodba.id_kupca+"','" + GOBJ_Settings.GetVal("sif_bank")+"','" +DTOS(DATE())+"',0)")
	Line 7479: 			lnmax_znesek =  lnDolg + IIF(thisform.tip_vnosne_maske = 1, GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.net_nal, pogodba.id_tec, DATE()),0)			
	Line 7482: 			lnmax_znesek = GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.vr_val, pogodba.id_tec, DATE())
	Line 7485: 			lnDolg = GF_SQLExecScalar("SELECT dbo.gfn_GetCurrentDebtByCustomerFromDS('"+pogodba.id_kupca+"','" + GOBJ_Settings.GetVal("sif_bank")+"','" + DTOS(DATE())+"',1)")
	Line 7487: 			lnmax_znesek =  lnDolg + IIF(thisform.tip_vnosne_maske = 1, GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.net_nal, pogodba.id_tec, DATE()),0)			
	Line 7495: 	lcIdval_znesek = GF_LOOKUP('tecajnic.id_val',GOBJ_Settings.GetVal("sif_bank"),'tecajnic.id_tec')
	Line 9468: 
	Line 9469: 
	Line 9472: 
	Line 9476: 
	Line 9477: 
	Line 9480: 
  U:\Source\Fox_2.22\Fox\leasing\forms\pogodba_update.SC2 (6 hits)
	Line 3796: 						lnDolg = GF_SQLExecScalar("SELECT dbo.gfn_GetCurrentDebtByCustomerFromDS('"+pogodba.id_kupca+"','" + GOBJ_Settings.GetVal("sif_bank")+"','" +DTOS(DATE())+"',0)")
	Line 3798: 						lnmax_znesek =  lnDolg + IIF(thisform.tip_vnosne_maske = 1, GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.net_nal, pogodba.id_tec, DATE()),0)			
	Line 3801: 						lnmax_znesek = GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.vr_val, pogodba.id_tec, DATE())
	Line 3804: 						lnDolg = GF_SQLExecScalar("SELECT dbo.gfn_GetCurrentDebtByCustomerFromDS('"+pogodba.id_kupca+"','" + GOBJ_Settings.GetVal("sif_bank")+"','" + DTOS(DATE())+"',1)")
	Line 3806: 						lnmax_znesek =  lnDolg + IIF(thisform.tip_vnosne_maske = 1, GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.net_nal, pogodba.id_tec, DATE()),0)			
	Line 3814: 				lcidval_znesek = GF_LOOKUP('tecajnic.id_val',GOBJ_Settings.GetVal("sif_bank"),'tecajnic.id_tec')
  U:\Source\Fox_2.22\Fox\leasing\forms\pogodba_update.SCT (12 hits)
	Line 2961: 				lnDolg = GF_SQLExecScalar("SELECT dbo.gfn_GetCurrentDebtByCustomerFromDS('"+pogodba.id_kupca+"','" + GOBJ_Settings.GetVal("sif_bank")+"','" +DTOS(DATE())+"',0)")
	Line 2963: 				lnmax_znesek =  lnDolg + IIF(thisform.tip_vnosne_maske = 1, GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.net_nal, pogodba.id_tec, DATE()),0)			
	Line 2966: 				lnmax_znesek = GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.vr_val, pogodba.id_tec, DATE())
	Line 2969: 				lnDolg = GF_SQLExecScalar("SELECT dbo.gfn_GetCurrentDebtByCustomerFromDS('"+pogodba.id_kupca+"','" + GOBJ_Settings.GetVal("sif_bank")+"','" + DTOS(DATE())+"',1)")
	Line 2971: 				lnmax_znesek =  lnDolg + IIF(thisform.tip_vnosne_maske = 1, GF_XCHANGE(GOBJ_Settings.GetVal("sif_bank"), pogodba.net_nal, pogodba.id_tec, DATE()),0)			
	Line 2979: 		lcidval_znesek = GF_LOOKUP('tecajnic.id_val',GOBJ_Settings.GetVal("sif_bank"),'tecajnic.id_tec')
	Line 3874: 
	Line 3875: 
	Line 3875: 
	Line 3876: 
	Line 3877: 
	Line 3877: 
