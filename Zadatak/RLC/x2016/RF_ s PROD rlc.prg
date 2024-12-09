************************************************
* 05.05.2015 g_mladens: MR 31201 (1352)
************************************************
FUNCTION RF_FRM_DOK()
&&PRIPREMA DOKUMENTA
lcWhere	= ALLTRIM(GF_GeneralRegister('RLC Reporting list','RLC_ZBIR_DOK','value'))

GF_SQLEXEC("SELECT * FROM dbo.gfn_ContractDocumentation("+TRANSFORM(pogodba.id_cont)+") WHERE ali_na_pog = 1 AND dni_zap=0 AND id_obl_zav NOT IN ("+lcWhere+")", "dok_prije")

GF_SQLEXEC("SELECT * FROM dbo.gfn_ContractDocumentation("+TRANSFORM(pogodba.id_cont)+") WHERE ali_na_pog = 1 AND dni_zap>0 AND id_obl_zav NOT IN ("+lcWhere+")", "dok_poslje")

TEXT TO lcSQl NOSHOW
	Select a.opis, a.kolicina, a.velja_do, a.velj_opis, a.naz_kr_kup, b.id_frame
	From dbo.gfn_ContractDocumentation ({0}) a
	Inner join dbo.frame_pogodba b on a.id_cont = b.id_cont
	Where a.id_obl_zav IN ({1})
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", TRANS(pogodba.id_cont))
lcSQL = STRTRAN(lcSQL, "{1}", lcWhere)

GF_SQLExec(lcSQL, "_FrmDok")

IF RECCOUNT('_FrmDok') > 0 THEN
	SELECT opis, kolicina, velja_do, velj_opis, naz_kr_kup, id_frame FROM _FrmDok INTO CURSOR _GF_CreateZav_memo

	LOCAL lcOpis, lcFrm, lcZav_memo 
	lcZav_memo = ''
	SELECT _GF_CreateZav_memo

	SCAN
		lcOpis = ALLTRIM(_GF_CreateZav_memo.opis)
		lcFrm = ' BR. '+  IIF(ISNULL(_GF_CreateZav_memo.id_frame),'', TRANSFORM(_GF_CreateZav_memo.id_frame))
		lcNaz_kr_kup = IIF(ISNULL(_GF_CreateZav_memo.naz_kr_kup),'',' ('+ALLTRIM(_GF_CreateZav_memo.naz_kr_kup)+')')

		lcZav_memo = lcZav_memo + lcOpis + lcFrm + lcNaz_kr_kup + CHR(13)
	ENDSCAN
ELSE 
	lcZav_memo = ''
ENDIF

CREATE CURSOR _print1(zav_memo_prije M, zav_memo_poslje M, zav_memo_FrmDok M)
SELECT _print1
APPEND BLANK

REPLACE zav_memo_prije WITH GF_createZav_memo("dok_prije") IN _print1
REPLACE zav_memo_poslje WITH GF_createZav_memo("dok_poslje") IN _print1
REPLACE zav_memo_FrmDok WITH lcZav_memo IN _print1

IF USED ("dok_prije")
	USE IN dok_prije
ENDIF

IF USED ("dok_poslje")
	USE IN dok_poslje
ENDIF

IF USED ("_FrmDok")
	USE IN _FrmDok
ENDIF

IF USED ("_GR")
	USE IN _GR
ENDIF

IF USED ("_GF_CreateZav_memo")
	USE IN _GF_CreateZav_memo
ENDIF
ENDFUNC
************************************************

************************************************
* 03.09.2014 g_tomislav: MR 29084 (1273)
FUNCTION RF_FO_OVRHA(lcVr_osebe)
local lcVr_osebe
IF inlist(lcVr_osebe,'FO','F1')
	RETURN 'Ističemo da u slučaju neispunjenja dospjele novčane obveze po ovom računu '+allt(GOBJ_Settings.GetVal('p_podjetje'))+' može zatražiti određivanje ovrhe na temelju vjerodostojne isprave.'
	ELSE 
	RETURN ''
ENDIF
ENDFUNC
************************************************
*MŠ 2.8.2012 potpisnik iz šifranta
FUNCTION RF_POTPIS(lcid_rep)
LOCAL lcPotpis

	LOCAL lcStariAlias
	lcStariAlias = ALIAS()

TEXT TO lcSql NOSHOW
	SELECT Value FROM general_register WHERE id_register = 'REPORT_SIGNATORY' AND id_key = '{0}'
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", lcid_rep)

GF_SqlExec(lcSql,"SIGN")

IF RECCOUNT("SIGN") = 0
	APPEND BLANK IN SIGN
ENDIF

lcPotpis = ALLTRIM(SIGN.Value)
    If !Empty(lcStariAlias) THEN
        Select (lcStariAlias)
    ENDIF

RETURN lcPotpis
**USE IN SIGN
ENDFUNC
************************************************
FUNCTION RF_PRINT_MB 
RETURN {31.12.2010} 
ENDFUNC
*************************************************
FUNCTION RF_PRINT_P_MB 
RETURN {31.12.2010} 
ENDFUNC
*************************************************
*Daniel 29.06.2007 izracun promijenjene EOM
FUNCTION RF_NEW_EOM(tnid_cont)
 IF PCOUNT() # 1 THEN 
		POZOR("PARAMETER ERROR - RF_NEW_EOM")
		RETURN .F.
ENDIF

 Local lccommand, lccursor, lneom, lcpoint
 Local lce, lcres, lceom
 lce = Chr(10)+Chr(13)
 lcxml = "<?xml version="+gf_quotedstr("1.0")+" encoding="+gf_quotedstr("utf-8")+" ?>"+lce
 lcxml = lcxml+"<calculate_EOM xmlns="+gf_quotedstr("urn:gmi:nova:leasing")+">"+lce
 lcXML = lcXML + GF_CreateNode("id_cont", tnid_cont, "N", 1)+ lcE
 lcxml = lcxml+"</calculate_EOM>"
 lcres = gf_processxml(lcxml,.T.,.T.)
 If !Empty(lcres) and Type("lcRes")="C"
     lceom = gf_getsinglenodexml(lcres,"calc_EOM")
     lcpoint = Set("POINT")
     Set Point To "."
     lneom = Round(Val(lceom), 4)
     Set Point To lcpoint
     If Val(lceom)!=-1
     Return lneom
     Else
     Return lneom
     Endif
 Else
     Return .F.
 Endif
ENDFUNC
***********************************************
* Function returns true if given id_grupe is "IMO", otherwise it returns false
FUNCTION RF_IMO(tcGrupa)
	IF PCOUNT() # 1 THEN 
		POZOR("PARAMETER ERROR - RF_IMO")
		RETURN .F.
	ENDIF 
	RETURN ALLTRIM(UPPER(tcGrupa)) == "IMO"
ENDFUNC 
***********************************************
* Funkcija vraća 5 grupe načina lizinga
* FF - financijski leasing
* F1 -
* OL - operativni
* ZP - krediti
* XX - ako tip leasinga ne postoji
* OZ - dorada za nove tipove leasinga zakup popisane u custom_settings, BD 27.03.2014
FUNCTION RF_TIP_POG(tcNacin_leas)
	IF PCOUNT() # 1 OR LEN(ALLTRIM(tcNacin_leas)) # 2 THEN
		POZOR("PARAMETER ERROR - RF_TIP_POG")
		RETURN "ERROR"
	ENDIF

	tcNacin_leas = ALLTRIM(UPPER(tcNacin_leas))

	LOCAL lcStariAlias
	lcStariAlias = ALIAS()

	GF_SQLEXEC("SELECT * FROM dbo.nacini_l WHERE nacin_leas = "+GF_QuotedStr(tcNacin_leas), "_rf_nacini_l")
	GF_SQLEXEC("SELECT val FROM custom_settings where code = 'Nova.LE.Zakup.Nekretnina'", "_rf_zakup_ne")
	
	LOCAL lcResult
	DO CASE
		CASE _rf_nacini_l.tip_knjizenja == "2" AND _rf_nacini_l.finbruto == .F. AND _rf_nacini_l.leas_kred == "L"
			lcResult = "FF"
		CASE _rf_nacini_l.tip_knjizenja == "2" AND _rf_nacini_l.finbruto == .T. AND _rf_nacini_l.leas_kred == "L"
			lcResult = "F1"
		CASE _rf_nacini_l.tip_knjizenja == "1" AND ATC(_rf_nacini_l.nacin_leas,_rf_zakup_ne.val) = 0 
			lcResult = "OL"
		CASE _rf_nacini_l.tip_knjizenja == "1" AND ATC(_rf_nacini_l.nacin_leas,_rf_zakup_ne.val) > 0 
			lcResult = "OZ"
		CASE _rf_nacini_l.leas_kred == "K"
			lcResult = "ZP"
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
* Function returns true if given leas type is for used vehicles, otherwise it returns false
FUNCTION RF_RAB(tcNacin_leas)
	IF PCOUNT() # 1 OR LEN(ALLTRIM(tcNacin_leas)) # 2 THEN 
		POZOR("PARAMETER ERROR - RF_RAB")
		RETURN .F.
	ENDIF 
	RETURN ALLTRIM(UPPER(tcNacin_leas)) == "FU"
ENDFUNC
***********************************************
FUNCTION rf_msgbox
PARAMETERS tcCaption, tcMessage, tcButton1, tcButton2, tcButton3
LOCAL lnReturn, loRF

         DIMENSION laButtons[2, 2]
         laButtons[1, 1] = "&"+tcButton1               && Caption
         laButtons[1, 2] = tcButton1              && Caption
         laButtons[2, 1] = "&"+tcButton2              && Caption
         laButtons[2, 2] = tcButton2               && Caption

         GF_SetMsgBoxButtonCaption(7, laButtons[1, 1], laButtons[1, 2])
         GF_SetMsgBoxButtonCaption(6, laButtons[2, 1], laButtons[2, 2])

         lnReturn = xmessagebox(tcMessage, 3, tcCaption)
         *!* lnReturn = 6 - Trenutni; lnReturn = 7 - Vse; lnReturn = 2 - Prekliči

		 DO CASE
				CASE lnReturn = 6
					lnReturn = 2
				CASE lnReturn = 7
					lnReturn = 1
				OTHERWISE
					lnReturn = 100
		ENDCASE

	RETURN lnReturn
ENDFUNC
***********************************************
*25.05.2006 Nenad Milevoj ispisuje svu dokumentaciju za jedan ugovor
FUNCTION RF_DOKUMENT_OSIGURANJA(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
	LOCAL lcResult
	LOCAL x
	lcResult=""
	GF_SQLEXEC("Select a.*,b.ali_na_pog From dbo.dokument a left join dbo.dok b on a.id_obl_zav=b.id_obl_zav where b.ali_na_pog=1 and a.ima=1 and a.id_cont="+str(lcid_cont),"_cur1")
	select _cur1
	go top
	x=1
	scan
	lcResult=lcResult+str(x)+". " +allt(_cur1.opis)+chr(9)+allt(str(_cur1.kolicina))+chr(13)
	x=x+1
	endscan
	RETURN lcResult
ENDFUNC
***********************************************
***********************************************
*25.05.2006 Nenad Milevoj ispisuje sve vozače za jedan zapisnik
FUNCTION RF_ZAPISNIK_VOZACI(lcid_zapo)
	IF ISNULL(lcid_zapo) OR EMPTY(lcid_zapo) THEN
		RETURN "GREŠKA"
	ENDIF
	LOCAL lcResult
	LOCAL x
	lcResult=""
	GF_SQLEXEC("Select * From dbo.zreg_poobl Where zreg_poobl.id_zapo="+GF_QuotedStr(lcid_zapo),"_cur1")
	select _cur1
	go top
	x=1
	scan
	lcResult=lcResult+str(x)+". "+allt(_cur1.ime)+", "+allt(_cur1.naslov)+", JMBG:"+allt(_cur1.emso)+chr(13)
	x=x+1
	endscan
	RETURN lcResult
ENDFUNC

***********************************************
*25.05.2006 Nenad Milevoj ispisuje sve jamce za jedan ugovor
*27.11.2009 Tomislav Krnjak: dodan je OIB
*03.02.2010 Tomislav Krnjak: dodano da za vr_osebe=SP ispisuje 'MBO:' i stev_reg
FUNCTION RF_JAMCI(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
	LOCAL lcResult, lcOldAlias
	lcOldAlias = nvl(alias(),'')
	LOCAL x
	lcResult=""
	
	GF_SQLEXEC("Select CASE WHEN vr_osebe<>"+GF_QuotedStr("FO")+" THEN "+GF_QuotedStr("MB: ")+"+ p.emso ELSE "+GF_QuotedStr("JMBG: ")+"+ p.emso END as emso,p.dav_stev,p.naz_kr_kup,p.ulica_sed,p.vr_osebe,p.id_poste_sed,p.mesto_sed,p.direktor,p.stev_reg, o.dat_sklen From pogodba o INNER JOIN POG_PORO g ON o.id_cont=g.id_cont INNER JOIN PARTNER p ON g.id_poroka=p.id_kupca Where o.id_cont="+str(lcid_cont)+" ORDER BY g.oznaka ASC","_cur1")
	select _cur1
	go top
	x=1
	scan
	
	lcResult=lcResult+allt(_cur1.naz_kr_kup)+", "+allt(_cur1.ulica_sed)+", "+allt(_cur1.id_poste_sed)+" "+allt(_cur1.mesto_sed)+iif(LEN(allt(_cur1.dav_stev))=11,", OIB: "+alltr(_cur1.dav_stev),"")+iif(_cur1.vr_osebe='SP',', MBO: '+allt(_cur1.stev_reg),iif(RF_PRINT_MB()>_cur1.dat_sklen,+', '+allt(_cur1.emso),""))+iif(!empty(_cur1.direktor),iif(_cur1.vr_osebe="FD",", vlasnik ",", zastupan po ")+allt(_cur1.direktor),"")+chr(13)
	x=x+1
	endscan
	if !empty(lcOldAlias) 
	select (lcOldAlias) 
	endif
	RETURN lcResult
ENDFUNC

***********************************************
*30.06.2006 Daniel Vrpoljac mijenjanje naziva valute HRK u KN
FUNCTION RF_TO_KN(lcid_val)
	IF ISNULL(lcid_val) OR EMPTY(lcid_val) THEN
		RETURN "GREŠKA"
	ENDIF
	RETURN lcid_val
ENDFUNC
***********************************************
FUNCTION RF_DiskDav
LPARAMETERS tnNet_nal, tnNeto_obrok, tnObr_mera, tnSt_obrok, tnObnaleto, tnBeg_end, tnDav_proc
LOCAL lnY, lnX, lnObrok_razd, lnObrok_anuiteta, lnSe_razdolznin, lnObrok_obresti, lnObrok_davek, lnObrok_davek_disk, lnObrok_broj_dana, lnObrok_datum_dok, lnSum_davek_disk

   lnY=1+tnObr_mera/(100*tnObnaleto)
   lnObrok_anuiteta = tnNeto_obrok
   lnSe_razdolznin = tnNet_nal
   lnObrok_broj_dana = 0
   lnObrok_datum_dok = DATE()
   lnSum_davek_disk=0
   
   FOR lnX=1 to tnSt_obrok
	    lnObrok_obresti=iif(lnX=1 AND tnBeg_end=1,0,lnSe_razdolznin * (lnY-1))
	
		lnObrok_razd=lnObrok_anuiteta-lnObrok_obresti
		lnObrok_davek=lnObrok_obresti*tnDav_proc/100
		lnSe_razdolznin=lnSe_razdolznin-lnObrok_razd
		lnObrok_broj_dana = lnObrok_datum_dok - DATE()		
		lnObrok_davek_disk =(lnObrok_davek*100)/(100+((1+tnObr_mera/100)^(lnObrok_broj_dana/365)-1)*100)
		lnSum_davek_disk = lnSum_davek_disk + lnObrok_davek_disk

   		lnObrok_datum_dok = GOMONTH(lnObrok_datum_dok, 12/tnObnaleto)

   NEXT
   RETURN ROUND(lnSum_davek_disk,2)
ENDFUNC
*****************************
FUNCTION RF_XML_OUTPUT
LPARAMETERS lvValue, lcPicture, lcEmpty, lnPadl

lcValue=ALLTRIM(TRANSFORM(lvValue))


IF TYPE("lvValue")="T" OR TYPE("lvValue")="D"
	lcValue=DTOS(lvvalue)
	lcValue=LEFT(lcValue,4)+"-"+SUBSTR(lcValue,5,2)+"-"+RIGHT(lcValue,2)
	lcValue=STRTRAN(lcValue," ","")
	IF lcValue="1900-01-01" OR lcValue="--"
	   lcValue=lcEmpty
	ENDIF
ENDIF 
lcValue = STRTRAN(lcValue, "&", "&amp;")
lcValue = STRTRAN(lcValue, "<", "&lt;")
lcValue = STRTRAN(lcValue, ">", "&gt;")
lcValue = STRCONV(lcValue,9)
*lcValue = CHRTRAN(lcValue,"ŠĐČĆŽšđčćžöÖüÜäÄ´","SDCCZsdcczoOuUaA ")
		
&&AND ATC(lcTag,"vrij_tr_ug_leas,int_br_obj,red_br_izmjene")=0		
IF TYPE("lvValue")="N" 
	if !empty(lcPicture)
		lnValue=ROUND(lvValue,2)
		lcValue=ALLTRIM(TRANSFORM(lnValue,lcPicture))
	else
		lcValue=ALLTRIM(STR(lvValue))
	endif	
ENDIF	

IF empty(lcValue)
   lcValue=lcEmpty
else
   if lnPadl>0
   	  lcValue=padl(lcValue,lnPadl,"0")
   endif
ENDIF

return lcValue
*****************
FUNCTION RF_GetSklic
LPARAMETERS tcId_kupca, tcSklic
IF ISNULL(tcId_kupca) OR EMPTY(tcId_kupca) THEN
		RETURN "GREŠKA"
ENDIF
IF ISNULL(tcSklic) OR EMPTY(tcSklic) THEN
		RETURN "GREŠKA"
ENDIF
local lcNewSklic
	if alltrim(tcId_kupca)!=substr(alltrim(tcSklic),5,6)
		lcNewSklic="998-"+alltrim(tcId_kupca)+"-"+substr(alltrim(tcSklic),12,7)
		return GF_SQLEXECScalar("select "+Gf_QuotedStr(lcNewSklic)+"+dbo.gfn_CalculateControlDigit("+GF_QuotedStr(lcNewSklic)+")")
		
	else
		return tcSklic
	endif

	
ENDFUNC
*****************************
*31.7.2013. TK  - dodan ispis mjesta i crte za potpis
*29.12.2014 g_tomislav - popravak ALIAS()
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
		lcResult = ""
	ELSE
		select _cur2
		go top
		x=1
		scan
			lcResult=lcResult+_cur2.naziv+chr(13)+chr(13)+chr(13)+allt(_rf_strm1.mesto)+',_______________'+chr(13)+'(mjesto i datum potpisa)'+chr(13)+chr(13)
			x=x+1
		endscan
	ENDIF
	if !empty(lcOldAlias) 
		select (lcOldAlias) 
	endif
	RETURN lcResult
ENDFUNC
************************************************
*27.01.2010 Josip - mstr - porezna stopa na ponudi (id_dav_st)
FUNCTION RF_PON_MSTR_DAV(lcid_pon)
	IF ISNULL(lcid_pon) OR EMPTY(lcid_pon) THEN
		RETURN "GREŠKA"
	ENDIF
	
	lcid_dav_st=''
	
	IF gf_lookup('vrst_ter.id_dav_st_pog', 'MSTR', 'vrst_ter.sif_terj')
                lcid_dav_st=gf_lookup('ponudba.id_dav_st', lcid_pon, 'ponudba.id_pon')
        ELSE
                lcid_dav_st=gf_lookup('vrst_ter.id_dav_st', 'MSTR', 'vrst_ter.sif_terj')
        ENDIF
	RETURN lcid_dav_st
ENDFUNC

************************************************
*27.01.2010 Josip - mstr - porezna stopa na ugovoru (id_dav_st)
FUNCTION RF_POG_MSTR_DAV(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
	
	lcid_dav_st=''
	
	IF gf_lookup('vrst_ter.id_dav_st_pog', 'MSTR', 'vrst_ter.sif_terj')
                lcid_dav_st=gf_lookup('pogodba.id_dav_st', lcid_cont, 'pogodba.id_cont')
        ELSE
                lcid_dav_st=gf_lookup('vrst_ter.id_dav_st', 'MSTR', 'vrst_ter.sif_terj')
        ENDIF
	RETURN lcid_dav_st
ENDFUNC
************************************************

*10.03.2010 Josip - stro - porezna stopa na ugovoru (id_dav_st)
FUNCTION RF_POG_STRO_DAV(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
	
	lcid_dav_st=''
	
	IF gf_lookup('vrst_ter.id_dav_st_pog', 'STRO', 'vrst_ter.sif_terj')
                lcid_dav_st=gf_lookup('pogodba.id_dav_st', lcid_cont, 'pogodba.id_cont')
        ELSE
                lcid_dav_st=gf_lookup('vrst_ter.id_dav_st', 'STRO', 'vrst_ter.sif_terj')
        ENDIF
	RETURN lcid_dav_st
ENDFUNC
************************************************
*18.05.2010 Nenad Milevoj ispisuje svu dokumentaciju za jedan ugovor
FUNCTION RF_DOKUMENT_OSIG(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
	LOCAL lcResult
	LOCAL x
	lcResult=""
	GF_SQLEXEC("Select a.*,b.ali_na_pog From dbo.dokument a left join dbo.dok b on a.id_obl_zav=b.id_obl_zav where a.id_obl_zav in ('GO','IN','JZ','M1','M2','M3','M4','M5','ZA','ZJ','ZK','ZN','ZS') and a.ima=1 and a.id_cont="+str(lcid_cont),"_cur1")
	select _cur1
	go top
	x=1
	scan
	lcResult=lcResult+str(x)+". " +allt(_cur1.opis)+chr(9)+allt(str(_cur1.kolicina))+chr(13)
	x=x+1
	endscan
	RETURN lcResult
ENDFUNC
***********************************************
FUNCTION RF_CHECK_OIB(lcOIB)
IF ISNULL(lcOIB) OR EMPTY(lcOIB) THEN
		RETURN "GREŠKA"
ENDIF

local llOIBCheck, llOIBcalc, lnbroj_iteracija, lnduzina, lnP

llOIBCheck = .t.
llOIBcalc = .t.
lnbroj_iteracija = 1
lnduzina = LEN(ALLT(lcOIB)) - 1
lnP = 10

IF !(len(allt(lcOIB))=11 AND LEN(CHRTRAN(allt(lcOIB),"01234567890","")) = 0) THEN
	llOIBCheck = .f.
ENDIF
IF llOIBCheck
	DO WHILE lnbroj_iteracija <= lnduzina
		lnP = (lnP + VAL(SUBSTR(ALLT(lcOIB),lnbroj_iteracija,1))) % 10
  
		lnP = (IIF(lnP=0,10,lnP) * 2) % 11

		lnbroj_iteracija = lnbroj_iteracija + 1
	ENDDO

	lnP = IIF(11 - lnP = 10, 0, 11 - lnP)

	IF lnP # VAL(SUBSTR(allt(lcOIB),lnduzina+1,1)) 
		llOIBcalc = .f.
	ENDIF
ENDIF

RETURN (llOIBCheck AND llOIBcalc)

ENDFUNC
***********************************************
***********************************************
***Funkcija koje će se stavljati u print when novog broja računa na ispisu
FUNCTION RF_PRINT_DDV_HR (ldddv_date)
IF PCOUNT() # 1 THEN
	POZOR("PARAMETER ERROR - RF_PRINT_DDV_HR ")
	RETURN .F.
ENDIF

	RETURN IIF(ldddv_date < {01.01.2013}, .f., .t.)
ENDFUNC
***********************************************
****19.12.2012 Nenad; Funkcija koja transformira DDV_ID u oblik za fiskalizaciju
****22.04.2013 Nenad; Funkcija dorađena da se transformacija po knjigama radi o nekog datuma
FUNCTION RF_TRANSFORM_DDV_HR(lcDDV_ID, ldDDV_date)

IF GF_NULLOREMPTY(lcDDV_ID) OR PCOUNT() # 2 THEN
 POZOR("PARAMETER ERROR - RF_TRANSFORM_DDV_HR")
 RETURN .F.
ENDIF

IF RF_PRINT_DDV_HR(TTOD(ldDDV_date)) = .f. THEN 
 RETURN lcDDV_ID
ENDIF

local lcDDVID_Fis, lnChar

lcDDV_ID = allt(lcDDV_ID)

lcDDVID_Fis= lcDDV_ID

lnChar = iif(left(lcDDVID_Fis,1) # "2", 5, 4)

lcDDVID_Fis= RIGHT(lcDDVID_Fis, LEN(lcDDVID_Fis) - lnChar)

local lcCustomSetting, lcBrojNU, lcCustomSetting1, lcCustomSetting2, ldTmpDate 

lcCustomSetting = GF_CustomSettings("Hr_Integration.FiskalHR.UseKnjige")
lcCustomSetting1 = GF_CustomSettings("Hr_Integration.FiskalHR.UseKnjigeWithDate")
lcCustomSetting2 = GF_CustomSettings("Hr_Integration.FiskalHR.UseKnjigeFromDate")

IF GF_NULLOREMPTY(lcCustomSetting2) OR LEN(lcCustomSetting2) # 8 THEN
	lcCustomSetting2 = "20130101"
ENDIF

ldTmpDate = ctod(RIGHT(lcCustomSetting2, 2) + "." + SUBSTR(lcCustomSetting2, 5, 2) + "." +LEFT(lcCustomSetting2, 4))

IF lcCustomSetting = "1" AND (lcCustomSetting1 = "0" OR (lcCustomSetting1 = "1" AND ldDDV_date >= ldTmpDate)) THEN
 DO CASE
  CASE LEFT(lcDDV_ID,1) == "A"
   lcBrojNU = "2"
  CASE LEFT(lcDDV_ID,1) == "N"
   lcBrojNU = "3"
  CASE LEFT(lcDDV_ID,1) == "I"
   lcBrojNU = "4"
  CASE LEFT(lcDDV_ID,1) == "P"
   lcBrojNU = "5"
  CASE LEFT(lcDDV_ID,1) == "E"
   lcBrojNU = "6"
  CASE LEFT(lcDDV_ID,1) == "M"
   lcBrojNU = "7"
  OTHERWISE
   lcBrojNU = "1" 
 ENDCASE

ELSE
 lcBrojNU= "1"

ENDIF

lcDDVID_Fis= allt(trans(val(lcDDVID_Fis))) + "-1-" + lcBrojNU + " " + lcDDV_ID

RETURN lcDDVID_Fis

ENDFUNC
***********************************************
***20.12.2012 Nenad; funkcija za formatiranje datum i vremena i pretvorbu u string
FUNCTION RF_TTOC(ldDate)
IF PCOUNT() # 1 THEN
	POZOR("PARAMETER ERROR - RF_TTOC")
	RETURN .F.
ENDIF

RETURN STRTRAN(TTOC(ldDate), gStr(ldDate), gStr(ldDate) + ".")

ENDFUNC
***********************************************
***20.12.2012 Mladen; funkcija koja vraća način plaćanja
FUNCTION RF_NACIN_PLAC
	RETURN 'Transakcijski račun'
ENDFUNC
***********************************************
*!* 15.01.2013 Ziga; MID 37670 - created

PROCEDURE COPYTOEXCEL
	LPARAMETERS pcCursorName, pcFields

	LOCAL lnParameters
	lnParameters = PCOUNT()
	IF ISNULL(pcCursorName)
		pcCursorName = .f.
	ENDIF 
	DO case
		CASE lnParameters<1
			pcCursorName = ALIAS()
		CASE lnParameters=1
			IF VARTYPE(pcCursorName)#"C" OR ISNULL(pcCursorName)
				pcCursorName = ALIAS()				
			ENDIF
		CASE lnParameters>1
			IF ISNULL(pcFields) OR VARTYPE(pcFields)#"C"
				pcFields = ""
			ENDIF
	ENDCASE

	IF EMPTY(pcCursorName)
		MESSAGEBOX("Ni podatkov!"+CHR(13)+"Prenos se ne bo izvedel!")
		RETURN .f.
	ENDIF

	PRIVATE array arExcelFields[1]
	PRIVATE oWorkBook1

	LOCAL ARRAY arLines(1), arFields(1)
	LOCAL lnFields, lnCounter, lcFields, lnFCopy, lnR
	LOCAL oExcel, oWorkbook, lcFileName, lcSafety, lcCopy, loRange

	lcFields = ""
	lnFCopy = 0
	lnR = RECCOUNT(pcCursorName)
	
	IF !EMPTY(pcFields)
		lnFields = ALINES(arLines,pcFields,.t.,",")
		FOR lnCounter = 1 TO afields(arFields,pcCursorName)
			FOR lnCounter1 = 1 TO lnFields
				IF UPPER(ALLTRIM(arLines(lnCounter1)))== ALLTRIM(UPPER(arFields(lnCounter,1))) AND !arFields(lnCounter,2)$"MG"
					lcFields = lcFields + FIELD(lnCounter)+","
					lnFCopy = lnFCopy+1
					DIMENSION arExcelFields[lnFCopy,4]
					arExcelFields[lnFCopy,1]=arFields[lnCounter,1]
					arExcelFields[lnFCopy,2]=arFields[lnCounter,2]
					arExcelFields[lnFCopy,3]=arFields[lnCounter,3]
					arExcelFields[lnFCopy,4]=arFields[lnCounter,4]
					EXIT
				ENDIF
			ENDFOR
		ENDFOR
		lcFields = LEFT(lcFields,LEN(lcFields)-1)
	ELSE
		FOR lnCounter = 1 TO AFIELDS(arFields,pcCursorName)
			IF !arFields(lnCounter,2)$"MG"
				lnFCopy = lnFCopy+1
				DIMENSION arExcelFields[lnFCopy,4]
				arExcelFields[lnFCopy,1]=arFields[lnCounter,1]
				arExcelFields[lnFCopy,2]=arFields[lnCounter,2]
				arExcelFields[lnFCopy,3]=arFields[lnCounter,3]
				arExcelFields[lnFCopy,4]=arFields[lnCounter,4]
			ENDIF
		ENDFOR
	ENDIF
	
	RELEASE arFields

	oExcel = CreateObject("Excel.Application")
	if vartype(oExcel) != "O"
		MESSAGEBOX("MS EXCEL programa ne morem zagnati!")
	  	return .F.
	endif

	lcSafety = SET("Safety")
	lcFileName = gLocal+SYS(2015)+".xls"

	SELECT (pcCursorName)

	IF EMPTY(lcFields)
		COPY TO (lcFileName) TYPE XL5 all
	ELSE
		lcCopy = "COPY TO "+lcFileName+" FIELDS "+lcFields+" TYPE XL5 ALL"
		&lcCopy
	ENDIF

	oExcel.DisplayAlerts = .f.

	oWorkbook1 = oExcel.Workbooks.Add
	FOR lnCounter = oWorkBook1.Sheets.Count TO 2 STEP - 1
		IF lnCounter>1
			oWorkBook1.Sheets(lnCounter).Delete()
		ENDIF
	ENDFOR

	oWorkbook = oExcel.Workbooks.Open(lcFileName)
	loRange = oWorkbook.Sheets(1).Range(oWorkbook.Sheets(1).Cells(1, 1), oWorkbook.Sheets(1).Cells(lnR+1,lnFCopy))
	loRange.Copy()
	oWorkbook1.Sheets(1).Paste()
	oWorkBook.Close
	oWorkBook = ""
	RELEASE oWorkBook
	
	FOR lnCounter = 1 TO ALEN(arExcelFields,1)
		DO case
			CASE INLIST(arExcelFields(lnCounter,2),"M","C")
				oWorkbook1.Sheets(1).Columns(lnCounter).NumberFormat = "@"
			CASE arExcelFields(lnCounter,2) = "L"
				oWorkbook1.Sheets(1).Columns(lnCounter).NumberFormat = "@"
			CASE INLIST(arExcelFields(lnCounter,2),"N","F","I","B","Y")
				oWorkbook1.Sheets(1).Columns(lnCounter).NumberFormat = "#,##0."+REPLICATE("0",arExcelFields[lnCounter,4])+";@"
			CASE arExcelFields(lnCounter,2)=="D"
				oWorkbook1.Sheets(1).Columns(lnCounter).NumberFormat = "dd/mm/yyyy;@"
			CASE arExcelFields(lnCounter,2)=="T"
				oWorkbook1.Sheets(1).Columns(lnCounter).NumberFormat = "dd/mm/yyyy hh:mm:ss;@"
		ENDCASE
	ENDFOR          

   	oRange = oWorkbook1.Sheets(1).Range(oWorkbook1.Sheets(1).Cells(1, 1), oWorkbook1.Sheets(1).Cells(1,lnFCopy))

	With oRange.Interior
    	.ColorIndex = 36
    	.Pattern = 1
	ENDWITH
	WITH oRange.Borders(9) &&lxEdgeBottom
		.LineStyle = -4119 &&xlDouble
		.Weight = 4 &&xcThick
		.ColorIndex = -4105 &&xlAutomatic
	ENDWITH
    oRange.AutoFilter
    
    oWorkBook1.Sheets(1).Name = RIGHT("0"+ALLTRIM(STR(DAY(DATE()))),2)+"_"+RIGHT("0"+ALLTRIM(STR(month(DATE()))),2)+"_"+ALLTRIM(STR(year(DATE())))

	oExcel.Visible = .t.
	oExcel.DisplayAlerts = .t.
	IF lnR>30
		oWorkBook1.Sheets(1).Cells(2,1).Select
		oExcel.ActiveWindow.FreezePanes=.t.
		oExcel.ActiveWindow.ScrollRow = lnR+1
	ENDIF

	oExcel.Application.WindowState = -4137
	ADDEXCELSUM(@oWorkBook1,@arExcelFields,lnR)
	oWorkBook1.Sheets(1).UsedRange.EntireColumn.Autofit

	*vzpostavi ustrezno stanje okolja
	SET SAFETY OFF
	IF FILE(lcFileName)
		DELETE FILE (lcFileName)
	ENDIF
	lcSafety = "SET SAFETY "+lcSafety
	&lcSafety
	oExcel = ""
	oWorkBook = ""
	oWorkBook1 = ""
	RELEASE oWorkBook1
	RELEASE arExcelFields

ENDPROC

PROCEDURE ADDEXCELSUM
	LPARAMETERS poWorkBook,arExcelFields, pnPosition
	LOCAL oRange
	FOR lnCounter = 1 TO ALEN(arExcelFields,1)
		IF INLIST(arExcelFields(lnCounter,2),"I","N","F","B","Y")
			oRange = poWorkBook.Sheets(1).Cells(pnPosition+2,lnCounter)
			oRange.FormulaR1C1 = "=SUM(R[-"+ALLTRIM(STR(pnPosition))+"]C:R[-1]C)"
			With oRange.Interior
		    	.ColorIndex = 19
		    	.Pattern = 1
			ENDWITH
			WITH oRange.Borders(9) &&lxEdgeBottom
				.LineStyle = -4119 &&xlDouble
				.Weight = 4 &&xcThick
				.ColorIndex = -4105 &&xlAutomatic
			ENDWITH
		    With oRange.Borders(8)
		        .LineStyle = -4119
		        .Weight = 4
		        .ColorIndex = -4105
		    EndWith
		ENDIF
	ENDFOR
ENDPROC
***********************************************
*24.05.2013 BD ispisuje sve kontakte za partnera sa ugovora

FUNCTION RF_KONTAKTI(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
	LOCAL lcResult
	LOCAL x
	lcResult=""

TEXT TO lcSQL2 NOSHOW
select b.naziv, b.opis, b.telefon, b.gsm, b.email
from
(select '1' as id, p.direktor as naziv, 
case when p.direktor='' then '' else 'Direktor' end as opis, 
isnull(p.tel_dir,'') as telefon, '' as gsm, '' as email
from partner p 
inner join pogodba a on p.id_kupca=a.id_kupca 
where id_cont ={0}
union
select '2' as id, p.kontakt as naziv, 
case when p.kontakt='' then '' else 'Kontakt' end as opis, 
isnull(p.telefon_k ,'') as telefon, '' as gsm, '' as email
from partner p 
inner join pogodba a on p.id_kupca=a.id_kupca 
where id_cont ={0}
union
select '3' as id,
case when k.id_kupca_k is null then isnull(k.naziv,'') else p.naz_kr_kup end as naziv,
u.opis, k.telefon, k.gsm, k.email
from p_kontakt k
inner join pogodba a on k.id_kupca=a.id_kupca
inner join p_kontakt_vloga u on u.id_vloga=k.id_vloga
left join partner p on p.id_kupca=k.id_kupca_k
where a.id_cont={0}and k.id_vloga in ('DI', 'KT', 'PR', 'PU', 'RA', 'TJ', 'UP', 'VP', 'ZA')) b
where opis<>''
order by id 
ENDTEXT

lcSQL2 = STRTRAN(lcSQL2, "{0}", TRANS(lcid_cont))
GF_SQLEXEC(lcSQL2,"_par_kontakt")

	select _par_kontakt
	go top
	x=1
	scan
	lcResult=lcResult+IIF(gf_nullorempty(_par_kontakt.naziv),"",allt(_par_kontakt.naziv)+", ")+IIF(gf_nullorempty(_par_kontakt.opis),"",allt(_par_kontakt.opis)+", ")+IIF(gf_nullorempty(_par_kontakt.telefon),"",allt(_par_kontakt.telefon)+", ")+IIF(gf_nullorempty(_par_kontakt.gsm),"",allt(_par_kontakt.gsm)+", ")+allt(_par_kontakt.email)+chr(13)
	x=x+1
	endscan
	RETURN lcResult
ENDFUNC

***********************************************
FUNCTION RF_PRINT_R1 (ldddv_date)
IF PCOUNT() # 1 THEN
 POZOR("PARAMETER ERROR - RF_PRINT_R1")
 RETURN .F.
ENDIF
 
 RETURN IIF(ldddv_date < {15.08.2013}, .t., .f.)
ENDFUNC
************************************************
FUNCTION RF_PRINT_PIB (ldddv_date)
IF PCOUNT() # 1 THEN
 POZOR("PARAMETER ERROR - RF_PRINT_PIB")
 RETURN .F.
ENDIF
 
 RETURN IIF(ldddv_date > {30.06.2013}, .t., .f.)
ENDFUNC
************************************************
****25.05.2010 Nenad - izračun EKS kao na ugovoru za ESL
FUNCTION RF_CALC_EOM_ESL(lcId_pon)
	IF ISNULL(lcid_pon) or EMPTY(lcId_Pon) THEN
		RETURN "GREŠKA"
	ENDIF

LOCAL lcSql, ldDat_pon, ldZap_2ob, lnDni_zap, tlDav_obv

TEXT TO lcSql NOSHOW
	SELECT a.*, b.rac_eom, b.sif_terj, b.naziv AS vrst_ter_naziv
	  FROM dbo.gfn_GenerateAmortisationPlan({0}) a
	 INNER JOIN dbo.vrst_ter b ON a.id_terj = b.id_terj
ENDTEXT

GF_SQLEXEC("Select * From dbo.ponudba Where id_pon="+GF_QuotedStr(lcId_pon),"_ponudba")
GF_SQLEXEC("Select * From dbo.nacini_l","_nacini_l")
GF_SQLEXEC("Select * From dbo.kalk_form","_kalk_form")

lnDobrocno = IIF(LOOKUP(_kalk_form.dobrocno, _ponudba.nacin_leas, _kalk_form.nacin_leas),"1","0")
lnOpc_imaobr = IIF(_ponudba.Opc_imaobr, "1", "0")
lnDisk_r = IIF(_ponudba.Disk_r, "1", "0")
lnIzvoz = 0

ldDat_pon = _ponudba.dat_pon 
ldZap_2ob = GOMONTH(ldDat_pon, 1) - Day(ldDat_pon) + 1 
lnDni_zap = LOOKUP(_nacini_l.dni_zap, _ponudba.nacin_leas, _nacini_l.nacin_leas)

xcomm = ;
VarToPar(_ponudba.id_dav_st)+","+VarToPar(_ponudba.prv_obr)+","+VarToPar(_ponudba.man_str)+","+VarToPar(_ponudba.Marza_av)+","+;
VarToPar(_ponudba.Stroski_zt)+","+VarToPar(_ponudba.Stroski_pz)+","+VarToPar(_ponudba.Zav_fin)+","+VarToPar(_ponudba.Str_financ)+","+;
VarToPar(_ponudba.Akont)+","+VarToPar(_ponudba.st_obrok)+","+VarToPar(_ponudba.vr_val)+","+VarToPar(_ponudba.beg_end)+","+;
VarToPar(_ponudba.rabat_nam)+","+VarToPar(_ponudba.rabat_njim)+","+VarToPar(_ponudba.dej_obr)+","+VarToPar(_ponudba.obr_mera)+","+;
VarToPar(_ponudba.oststr)+","+VarToPar(_ponudba.id_obd)+","+VarToPar(_ponudba.ost_obr)+","+VarToPar(_ponudba.opcija)+","+;
VarToPar(_ponudba.varscina)+","+VarToPar(_ponudba.ddv)+","+VarToPar(lnDobrocno)+","+VarToPar(_ponudba.Stroski_x)+","+;
VarToPar(_ponudba.nacin_leas)+","+VarToPar(lnIzvoz)+","+VarToPar(_ponudba.Marza_ob)+","+VarToPar(lookup(_nacini_l.opc_datzad,_ponudba.nacin_leas,_nacini_l.nacin_leas))+","+;
VarToPar(lnOpc_imaobr)+","+VarToPar(lnDisk_r)+","+VarToPar(_ponudba.nacin_ms)+","+;
VarToPar(ldDat_pon)+","+VarToPar(ldDat_pon)+","+VarToPar(ldDat_pon)+","+VarToPar(ldDat_pon)+","+;
VarToPar(ldZap_2ob)+",null,"+VarToPar(lnDni_zap)+","+VarToPar(_ponudba.traj_naj)+","+VarToPar(_ponudba.moratorij_mes)


lcSql = STRTRAN(lcSql, "{0}", xcomm)
GF_SQLEXEC(lcSql, "_tmpESLplanp")

tlDav_obv = !_ponudba.je_foseba
**calc_eom
llEOM_neto = LOOKUP(_kalk_form.eom_neto, _ponudba.nacin_leas, _kalk_form.nacin_leas) AND tlDav_obv 

IF (LOOKUP(_nacini_l.dav_n, _ponudba.nacin_leas, _nacini_l.nacin_leas) = "D" AND !llEOM_neto) THEN
   lnVr_val_EOM = _ponudba.vr_val * (1 + _ponudba.dav_vred/100)
ELSE
	lnVr_val_EOM = _ponudba.vr_val
ENDIF

SELECT debit - IIF(llEOM_neto,davek,0) AS debit, dat_zap FROM _tmpESLplanp WHERE rac_eom INTO CURSOR _temp_eom_calcESL READWRITE

INSERT INTO _temp_eom_calcESL VALUES (0, _ponudba.dat_pon)


lnEOM = GF_CalcEOMNew("_temp_eom_calcESL", lnVr_val_EOM)

select _temp_eom_calcESL
browse

USE IN _temp_eom_calcESL
USE IN _tmpESLplanp


RETURN lnEOM

ENDFUNC
***********************************************