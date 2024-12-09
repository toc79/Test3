***************************************************
** 16.08.2024 g_tomislav MID 51690 and 51690 
***************************************************
IF dokument.id_obl_zav == "ZE" AND !GF_NULLOREMPTY(dokument.id_cont) && dokument vezan na ugovor 
	loForm.txtId_kupca.Obvezen = .T.
	loForm.txtStevilka.BackColor = 8454143
	loForm.txtId_krov_dok.Obvezen = .T.
	loForm.txtStevilka.BackColor = 8454143
ENDIF

IF INLIST(dokument.id_obl_zav, "B1", "B2", "B3", "B4", "B5", "B6") AND !GF_NULLOREMPTY(dokument.id_cont) && dokument vezan na ugovor 
	loForm.txtId_kupca.Obvezen = .T.
	loForm.txtStevilka.BackColor = 8454143
ENDIF
**END MID 51690 and 51690**************************