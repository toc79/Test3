*obvesti("POGODBA_MASKA_ZAP_2OB_WHEN")


** 24.05.2022 g_tomislav MID 48886 - zadnji dan sljedećeg mjeseca + razdoblje za tip datuma dokumenta 4 Zadnji dan u mjesecu
IF pogodba.id_datum_dok_create_type == 4

	ldDat_sklen = pogodba.dat_sklen

	IF GF_NULLOREMPTY(ldDat_sklen)
		POZOR("Datum sklapanja nije unesen!") 
		*loForm.Pageframe1.Page2.txtZap_2ob.Value = .NULL.
	ELSE 
		*GOMONTH(ldDate , 2) - DAY(GOMONTH(ldDate ,2))
		loForm.Pageframe1.Page2.txtZap_2ob.Value = GOMONTH(ldDat_sklen , 1 + (12/obdobja_lookup.obnaleto)) - DAY(GOMONTH(ldDat_sklen, 1 + (12/obdobja_lookup.obnaleto))) 
	ENDIF
ENDIF
** KRAJ 48886