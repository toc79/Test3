*31.7.2013. TK  - dodan ispis mjesta i crte za potpis
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