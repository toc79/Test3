local objform, objform2,x, llform, lcResult, tmp, lcType, lcFileName, lcFileName1
llform = .f.
for x=1 to _screen.formCount
    objform=_screen.forms(x)
    if allt(upper(objform.name))="VNOS_TEC"
        *= messagebox(objform.caption)
         objform2=objform
    	llform=.t.
    endif
next    

if !llform
    =messagebox("Nema forma")
    return .f.
endif    


GF_SQLEXEC("Select * From dbo.io_channels Where channel_code="+GF_QuotedStr("IMP_RATES"),"_io_channel")

lcChannelExtraParams = allt(mline(_io_channel.channel_extra_params,1))
lnPosition = AT(";", lcChannelExtraParams)
lcType = SUBSTR(lcChannelExtraParams,1,lnPosition-1)
lcServerPath = SUBSTR(lcChannelExtraParams,lnPosition+1)

IF lcType='XLS' THEN
	
	lcFileName1=allt(lcServerPath) + allt(_io_channel.channel_file_name)
	
	IF !FILE(lcFileName1) THEN
		
		llpitanje = potrjeno("Na definiranoj lokaciji ne postoji datoteka sa tečajevima."+chr(10)+chr(13)+"Želite li kopirati datoteku s tečajevima na definiranu lokaciju?")
    
		IF llpitanje THEN

			lcFileName = Getfile('XLS', 'Select:', 'Select')

			if empty(lcFileName)
				=obvesti("Niste odabrali datoteku!")	
				return .f.
			endif    

			xxx=FILETOSTR(lcFileName)
			STRTOFILE(xxx,lcFileName1)

			=obvesti("Kopiranje uspješno")
		ELSE
			=obvesti("Ne postoji datoteka sa tečajevima!")
			return .f.
		ENDIF
	ENDIF
ENDIF

lnDataSessionId=objform2.datasessionid
*set datasession to lnDataSessionId    

LOCAL lnI
lnI = 0
llPrecision = GObj_Settings.GetVal("tecaj_dec_mest")

DIMENSION CursorDescription(5,17)

lnI = lnI + 1
CursorDescription(lnI,1) = "idtec"
CursorDescription(lnI,2) = "C"
CursorDescription(lnI,3) = 3
CursorDescription(lnI,4) = 0
CursorDescription(lnI,5) = .F.
CursorDescription(lnI,6) = .F.
CursorDescription(lnI,7) = "idtec"

lnI = lnI + 1
CursorDescription(lnI,1) = "valuta"
CursorDescription(lnI,2) = "C"
CursorDescription(lnI,3) = 3
CursorDescription(lnI,4) = 0
CursorDescription(lnI,5) = .F.
CursorDescription(lnI,6) = .F.
CursorDescription(lnI,7) = "valuta"

lnI = lnI + 1
CursorDescription(lnI,1) = "sifravalute"
CursorDescription(lnI,2) = "C"
CursorDescription(lnI,3) = 3
CursorDescription(lnI,4) = 0
CursorDescription(lnI,5) = .F.
CursorDescription(lnI,6) = .F.
CursorDescription(lnI,7) = "sifravalute"

lnI = lnI + 1
CursorDescription(lnI,1) = "jedinica"
CursorDescription(lnI,2) = "I"
CursorDescription(lnI,3) = 0
CursorDescription(lnI,4) = 0
CursorDescription(lnI,5) = .F.
CursorDescription(lnI,6) = .F.
CursorDescription(lnI,7) = "jedinica"

lnI = lnI + 1
CursorDescription(lnI,1) = "tecajvalue"
CursorDescription(lnI,2) = "N"
CursorDescription(lnI,3) = 20
CursorDescription(lnI,4) = llPrecision
CursorDescription(lnI,5) = .F.
CursorDescription(lnI,6) = .F.
CursorDescription(lnI,7) = "tecajvalue"

llIncludeClosed = potrjeno("Želite li arhivirati datoteku s tečajevima?")

lcE = CHR(13) + CHR(10)
lcXML = "<?xml version="+GF_QuotedStr("1.0")+" encoding="+GF_QuotedStr("utf-8")+" ?>" + LcE
lcXML= lcXML + "<import_exchange_rates xmlns="+chr(34)+"urn:gmi:ext_func:import_rates"+chr(34)+">" + lcE
lcXml = lcXml + "<archive_file>"+iif(llIncludeClosed,"true","false")+"</archive_file>" + lcE
lcXml = lcXml + "</import_exchange_rates>"


if GF_ProcessXml(lcXml, .F., .F.) then
  
  lcResult = GOBJ_Comm.GetResult()

  if Len(lcResult)>0 then
	obvesti("Tečajevi su uspješno importirani.")
	GF_XML2Cursor_2(@CursorDescription, "imported_exch_tmp", lcResult, "//import_exchange_rates_response/Tecaji","elem")
	
	if reccount("imported_exch_tmp")>0 then
	    set datasession to lnDataSessionId 
		GF_XML2Cursor_2(@CursorDescription, "imported_exch", lcResult, "//import_exchange_rates_response/Tecaji","elem")
		
		sele _tecaj
		
		go top
		scan
		   *_tecaj.tecaj = lookup(imported_exch.tecaj_value,_tecaj.id_tec,right("00"+imported_exch.tecajvalue,3))
		   *obvesti(lookup(imported_exch.tecajvalue,_tecaj.id_tec,right("00"+tran(imported_exch.idtec),3)))		   
		   replace tecaj with lookup(imported_exch.tecajvalue,_tecaj.id_tec,imported_exch.idtec)
		endscan
		
	endif
	
	
  endif
else
  =obvesti("Došlo je do greške prilikom obrade!")
endif
  
return .f.