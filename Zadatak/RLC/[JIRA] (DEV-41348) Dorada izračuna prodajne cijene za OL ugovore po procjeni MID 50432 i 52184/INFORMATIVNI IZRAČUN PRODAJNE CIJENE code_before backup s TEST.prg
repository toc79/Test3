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

OBJ_ReportSelector.id_field = TRANS(cont4prov.id_pon_pred_odkup) + ";" + PuOdg

