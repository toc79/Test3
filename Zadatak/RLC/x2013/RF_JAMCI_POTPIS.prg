word
pogstrm
allt(_strm1.mesto)+","+chr(9)

pPotpis


akojam
iif(empty(pog_poro.id_poroka),"",chr(13)+"Jamac platac:"+chr(13)+chr(13)+chr(13))

akoJamCrta
iif(empty(pog_poro.id_poroka),"",allt(_strm1.mesto)+","+chr(9))

akoJamPot
iif(empty(pog_poro.id_poroka),"",chr(13)+"(mjesto i datum potpisa)")

Ovaj Ugovor je sklopljen i stupa na snagu na dan potpisa Ugovora od strane svih Ugovornih strana, točnije i Davatelja leasinga i Primatelja leasinga.
txtCl10
txtCl9
iif(empty(pog_poro.id_poroka),""," i Jamca-platca")



'Ovaj Ugovor je sklopljen i stupa na snagu na dan potpisa Ugovora od strane svih Ugovornih strana, točnije i Davatelja leasinga i Primatelja leasinga'+iif(!gf_nullorempty(RF_JAMCI_POTPIS(pogodba.id_cont)),' i Jamca-platca','')+'.'

lcid_strm =_pogodba_test.id_strm
GF_SQLEXEC("select * from strm1 where id_strm="+GF_QuotedStr(lcid_strm),"_strm1")

alltrim(_strm1.mesto)+', '+alltrim(gstr(pogodba.dat_sklen))




FUNCTION RF_JAMCI_POTPIS(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
LOCAL lcResult, lcOldAlias
	LOCAL x
	lcOldAlias = nvl(alias(),'')
	lcResult=""
	
	GF_SQLEXEC("select b.mesto from pogodba a left join strm1 b on a.id_strm=b.id_strm where a.id_cont="+str(lcid_cont),"_rf_strm1")
	
	GF_SQLEXEC("Select pg.*, "+gf_quotedstr("Jamac platac:")+" as naziv  From dbo.pog_poro pg Where id_cont="+str(lcid_cont), "_cur2")
	select _cur2
	IF reccount()=0
		RETURN lcResult
	ELSE
		select _cur2
		go top
		x=1
		scan
			lcResult=lcResult+_cur2.naziv+chr(13)+chr(13)+chr(13)+allt(_rf_strm1.mesto)+',_______________'+chr(13)+'(mjesto i datum potpisa)'+chr(13)+chr(13)
			x=x+1
		endscan
		if !empty(lcOldAlias) 
			select (lcOldAlias) 
		endif
		RETURN lcResult
	ENDIF
ENDFUNC


bck
*****************************
FUNCTION RF_JAMCI_POTPIS(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
LOCAL lcResult, lcOldAlias
	LOCAL x
	lcOldAlias = nvl(alias(),'')
	lcResult=""
	GF_SQLEXEC("Select pg.*, "+gf_quotedstr("Jamac platac:")+" as naziv  From dbo.pog_poro pg Where id_cont="+str(lcid_cont), "_cur2")
	select _cur2
	go top
	x=1
	scan
	lcResult=lcResult+_cur2.naziv+chr(13)+chr(13)+chr(13)+chr(13)
	x=x+1
	endscan
	if !empty(lcOldAlias) 
	select (lcOldAlias) 
	endif
	RETURN lcResult
ENDFUNC
************************************************

*bck sa TESTA
*****************************
FUNCTION RF_JAMCI_POTPIS(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
LOCAL lcResult, lcOldAlias
	LOCAL x
	lcOldAlias = nvl(alias(),'')
	lcResult=""
	GF_SQLEXEC("Select pg.*, "+gf_quotedstr("Jamac platac:")+" as naziv  From dbo.pog_poro pg Where id_cont="+str(lcid_cont), "_cur2")
	select _cur2
	go top
	x=1
	scan
	lcResult=lcResult+_cur2.naziv+chr(13)+chr(13)+chr(13)+chr(13)
	x=x+1
	endscan
	if !empty(lcOldAlias) 
	select (lcOldAlias) 
	endif
	RETURN lcResult
ENDFUNC