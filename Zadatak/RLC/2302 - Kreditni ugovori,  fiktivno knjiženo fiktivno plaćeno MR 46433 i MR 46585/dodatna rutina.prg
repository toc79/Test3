** 09.03.2021 g_tomislav MID 46433

** zadnji označen zapis ne uvažava pa su potrebne sljedeće 3 linije
SELECT rezultat 
SCAN FOR ozn = .t.
ENDSCAN

select * from rezultat where ozn into cursor kred_planp

if reccount("kred_planp") == 0
	pozor("Nema označenih kandidata za promjenu!")
else 
	if potrjeno("Da li želite podesiti 'Plaćeno' za sve označene zapise?")
		lnOK = 0
		lnError = 0
		
		scan 
			lcXMLDoc = ""

			* Prepare XML with input parameters	and data
			lcXMLDoc = "<?xml version='1.0' encoding='utf-8' ?>"
			lcXmlDoc = lcXmlDoc + "<cc_make_fictive_payed xmlns='urn:gmi:nova:credit-contracts'>"
			lcXMLDoc = lcXMLDoc + GF_CreateNode("id_kred_pog", kred_planp.id_kredpog, "C", 1)
			lcXMLDoc = lcXMLDoc + GF_CreateNode("datum_dok", kred_planp.dat_zap, "D", 1)
			lcXMLDoc = lcXMLDoc + GF_CreateNode("only_selected", .T., "L", 1) && ovo za dodatnu rutinu mora biti .T.
			lcXmlDoc = lcXmlDoc + "</cc_make_fictive_payed>"

			*WAIT PRIPRAVLJAM_PODATKE WINDOW NOWAIT
			WAIT WINDOW "Pripremam podatke (kreditni ugovor: "+allt(trans(kred_planp.id_kredpog))+")" NOWAIT
			IF GF_ProcessXml(lcXMLDoc, .T.)
				lnOK = lnOK + 1
			ELSE
				lnError = lnError + 1
			ENDIF
		endscan
		
		obvesti("Obrada je završena." +gce +"Uspješno: "+trans(lnOK) +gce +"Greške: "+trans(lnError))
	endif
endif

* Osvježavanje 
loForm = GF_GetFormObject("frmPoljubno_porocilo46433")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

loForm.runsql()



*Testiranje
*dodati proovjeru da li ima kandidata na pregledu
*nakon obrade treba osviježiti pregled da ne bi se poslali isti kandidati ili u foxu napraviti provjeru ponovno => bolje napraviti ponovnu provjeru 

select * from rezultat into cursor kred_planp

if reccount("kred_planp") == 0
	pozor("Nema kandidata za promjenu!")
else 

		
lcXMLDoc = ""
* Prepare XML with input parameters	and data
lcXMLDoc = "<?xml version='1.0' encoding='utf-8' ?>"
lcXmlDoc = lcXmlDoc + "<cc_make_fictive_payed xmlns='urn:gmi:nova:credit-contracts'>"
lcXMLDoc = lcXMLDoc + GF_CreateNode("id_kred_pog", kred_planp.id_kredpog, "C", 1)
lcXMLDoc = lcXMLDoc + GF_CreateNode("datum_dok", kred_planp.dat_zap, "D", 1)
lcXMLDoc = lcXMLDoc + GF_CreateNode("only_selected", .T., "L", 1) && ovo za dodatnu rutinu mora biti .T.
lcXmlDoc = lcXmlDoc + "</cc_make_fictive_payed>"

*WAIT PRIPRAVLJAM_PODATKE WINDOW NOWAIT
WAIT WINDOW "Pripremam podatke (kreditni ugovor: "+allt(trans(kred_planp.id_kredpog))+")" NOWAIT
IF GF_ProcessXml(lcXMLDoc, .T.)
	obvesti("Uspešno končano!")
ELSE
	pozor("Označevanje neuspešno!")
ENDIF



	PROCEDURE BgridResultDetail.AfterRowColChange
		LPARAMETERS nColIndex
		
		thisform.tbrACTIONS.btnknjizeno.Enabled = ((kred_planp.znes_r > 0 OR kred_planp.crpanje > 0) AND kred_planp.dat_zap < DATE() AND kred_planp.evident != '*')
		thisform.tbrACTIONS.btnplacano.Enabled = (kred_planp.znes_r > 0 AND kred_planp.dat_zap < DATE() AND kred_planp.evident = '*' AND kred_planp.placano = .F. AND kred_planp.is_event = .F.)
	ENDPROC
	
	
	PROCEDURE tbractions.btnPlacano.Click
		#INCLUDE ..\..\common\includes\locs.h
		
		LOCAL lcXMLDoc, lnId, lcText, lcTitle, loOdgovor
		
		lcText = "Označim vse do izbranega, sicer samo trenutnega?" && caption
		lcTitle = "Izberi"
		loOdgovor = 2
		
		loOdgovor = xmessagebox(lcText, 3, lcTitle) && CREATEOBJECT("xmsgbox", lcText, 3, lcTitle)
		
		* ******** MSG return value *********
		* 2 - Cancel
		* 6 - Yes
		* 7 - No
		* ***********************************
		
		IF (loOdgovor = 2)
			RETURN
		ENDIF 
		
		lnId = kred_planp.id_kred_planp
		
		lcXMLDoc = ""
		* Prepare XML with input parameters	and data
		lcXMLDoc = "<?xml version='1.0' encoding='utf-8' ?>"
		lcXmlDoc = lcXmlDoc + "<cc_make_fictive_payed xmlns='urn:gmi:nova:credit-contracts'>"
		lcXMLDoc = m.lcXMLDoc + GF_CreateNode("id_kred_pog", kred_pog.id_kredpog, "C", 1)
		lcXMLDoc = m.lcXMLDoc + GF_CreateNode("datum_dok", kred_planp.dat_zap, "D", 1)
		lcXMLDoc = m.lcXMLDoc + GF_CreateNode("only_selected", (loOdgovor = 7), "L", 1) && ovo za dodatnu rutinu mora biti .T.
		
		lcXmlDoc = lcXmlDoc + "</cc_make_fictive_payed>"
		
		WAIT PRIPRAVLJAM_PODATKE WINDOW NOWAIT
		IF GF_ProcessXml(m.lcXMLDoc, .T.)
			obvesti("Uspešno končano!")
			thisform.UpdateChild(kred_pog.id_kredpog)
			SELECT kred_planp
			LOCATE FOR kred_planp.id_kred_planp = lnId
		ELSE
			pozor("Označevanje neuspešno!")
		ENDIF
	ENDPROC
	