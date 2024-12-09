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