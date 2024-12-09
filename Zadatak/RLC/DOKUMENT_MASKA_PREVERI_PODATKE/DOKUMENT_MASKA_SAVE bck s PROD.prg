*!* 19.03.2015 Jelena; MID 50180 - created
*!* 07.04.2015 Ziga; MID 50180 - minor modifications

LOCAL loForm

loForm = GF_GetFormObject("frmDokument_maska")
IF ISNULL(loForm) THEN
	RETURN
ENDIF

IF !GF_NULLOREMPTY(loForm.txtTip_cen.Value) THEN
	LOCAL llVrni, lcIdKupca, lcTipCen, llOnBlackList 

	lcTipCen = loForm.txtTip_cen.Value
 
	IF GF_SQLExecScalar("SELECT COUNT(*) FROM dbo.gfn_g_register('OCEN_VRED_TIP') WHERE id_key = '" + TRANSFORM(lcTipCen) + "'") > 0 THEN
		lcIdKupca = GF_SQLExecScalar("SELECT val_char FROM dbo.gfn_g_register('OCEN_VRED_TIP') WHERE id_key = '" + TRANSFORM(lcTipCen) + "'")
			
		IF !GF_NULLOREMPTY(lcIdKupca) THEN
			GF_SQLEXEC("SELECT * FROM dbo.partner WHERE id_kupca = '" + TRANSFORM(lcIdKupca ) + "'", "_part")
			IF RECCOUNT("_part") > 0 THEN
				IF _part.neaktiven THEN  
					pozor("Partner procjenitelja je neaktivan.")
				ENDIF
			ELSE
				pozor("Partner procjenitelja ne postoji u sistemu.")
			ENDIF
	
			llOnBlackList = GF_JeNaCrniListi(_part.dav_stev, _part.emso)
			IF llOnBlackList THEN
				pozor("Procjenitelj postoji na black listi.")
			ENDIF
		ELSE
			pozor("Procjenitelj nema definiran broj partnera u posebnim šifrantima 'Znakovna vrijednost'.")
		ENDIF
	
		IF USED("_part")
			USE IN _part
		ENDIF
	ENDIF
ENDIF