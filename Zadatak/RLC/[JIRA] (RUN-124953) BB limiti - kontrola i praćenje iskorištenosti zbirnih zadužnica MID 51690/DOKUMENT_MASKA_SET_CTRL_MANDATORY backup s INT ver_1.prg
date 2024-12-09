
***************************************************
**13.10.2022 g_nenadm, MR 48015 obavezan identifikator suglasnosti
***************************************************
if dokument.id_obl_zav = "SE" then
	loForm.txtStevilka.Obvezen = .T.
	loForm.lblStevilka.Caption = "Identifikator su."
	loForm.txtStevilka.BackColor = 8454143
endif
**KRAJ MR 48015************************************

***************************************************
**13.10.2022 g_nenadm, MR 48015 obavezan identifikator suglasnosti
***************************************************
if dokument.id_obl_zav = "SE" then
	loForm.txtStevilka.Obvezen = .T.
	loForm.lblStevilka.Caption = "Identifikator su."
	loForm.txtStevilka.BackColor = 8454143
endif
**KRAJ MR 48015*************************************************

***************************************************
**24.01.2024 g_tomislav MID 51690 
***************************************************
IF dokument.id_obl_zav == "ZE" AND !GF_NULLOREMPTY(dokument.id_cont) && dokument vezan na ugovor 
	loForm.txtId_kupca.Obvezen = .T.
	loForm.txtStevilka.BackColor = 8454143
	loForm.txtId_krov_dok.Obvezen = .T.
	loForm.txtStevilka.BackColor = 8454143
ENDIF
**KRAJ MID 51690*************************************************