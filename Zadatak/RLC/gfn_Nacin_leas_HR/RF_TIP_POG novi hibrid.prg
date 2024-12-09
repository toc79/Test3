***********************************************
* Funkcija vraća 7 grupa načina leasinga
* FF - financijski leasing
* F1 - financijski
* OL - operativni
* ZP - krediti
* NA - najam
* OZ - zakup
* XX - ako tip leasinga ne postoji

FUNCTION RF_TIP_POG(tcNacin_leas)
	IF PCOUNT() # 1 OR LEN(ALLTRIM(tcNacin_leas)) # 2 THEN
		POZOR("PARAMETER ERROR - RF_TIP_POG")
		RETURN "ERROR"
	ENDIF

	tcNacin_leas = ALLTRIM(UPPER(tcNacin_leas))
	
	LOCAL lcStariAlias, lcResult
	
	lcStariAlias = ALIAS()
		
	lcResult = NVL(GF_SQLEXECScalarNull("SELECT dbo.gfn_Nacin_leas_HR("+GF_QuotedStr(tcNacin_leas)+")"), "XX")
		
    If !Empty(lcStariAlias) THEN
        Select (lcStariAlias)
    ENDIF

	RETURN lcResult
ENDFUNC
***********************************************




***********************************************
* Funkcija vraća 7 grupa načina lizinga
* FF - financijski leasing
* F1 -
* OL - operativni (Hibrid TK MR 38251 29.05.2017)
* ZP - krediti
* XX - ako tip leasinga ne postoji
* OZ - dorada za nove tipove leasinga zakup popisane u custom_settings, BD 27.03.2014
* TP - dorada za THIRD PARTY CONTRACTS po polju nacini_l.third_party, BK 08.05.2017

FUNCTION RF_TIP_POG(tcNacin_leas)
	IF PCOUNT() # 1 OR LEN(ALLTRIM(tcNacin_leas)) # 2 THEN
		POZOR("PARAMETER ERROR - RF_TIP_POG")
		RETURN "ERROR"
	ENDIF

	tcNacin_leas = ALLTRIM(UPPER(tcNacin_leas))

	LOCAL lcStariAlias
	lcStariAlias = ALIAS()

	GF_SQLEXEC("SELECT * FROM dbo.nacini_l WHERE nacin_leas = "+GF_QuotedStr(tcNacin_leas), "_rf_nacini_l")
	GF_SQLEXEC("SELECT val FROM dbo.custom_settings where code = 'Nova.LE.Zakup.Nekretnina'", "_rf_zakup_ne")
	
	LOCAL lcResult
	DO CASE
		CASE _rf_nacini_l.tip_knjizenja == "2" AND _rf_nacini_l.finbruto == .F. AND _rf_nacini_l.leas_kred == "L" AND _rf_nacini_l.ol_na_nacin_fl == .F.
			lcResult = "FF"
		CASE _rf_nacini_l.tip_knjizenja == "2" AND _rf_nacini_l.finbruto == .T. AND _rf_nacini_l.leas_kred == "L"
			lcResult = "F1"
		CASE (_rf_nacini_l.tip_knjizenja == "1" AND ATC(_rf_nacini_l.nacin_leas,_rf_zakup_ne.val) = 0 AND !(_rf_nacini_l.third_party)) OR _rf_nacini_l.ol_na_nacin_fl == .T.
			lcResult = "OL"
		CASE _rf_nacini_l.tip_knjizenja == "1" AND ATC(_rf_nacini_l.nacin_leas,_rf_zakup_ne.val) > 0 AND !(_rf_nacini_l.third_party)
			lcResult = "OZ"
		CASE _rf_nacini_l.leas_kred == "K"
			lcResult = "ZP"
		CASE _rf_nacini_l.tip_knjizenja == "1" AND (_rf_nacini_l.third_party)
			lcResult = "TP"	
		OTHERWISE
			lcResult = "XX"
	ENDCASE
	
	USE IN _rf_nacini_l
	USE IN _rf_zakup_ne

    If !Empty(lcStariAlias) THEN
        Select (lcStariAlias)
    ENDIF

	RETURN lcResult
ENDFUNC
***********************************************