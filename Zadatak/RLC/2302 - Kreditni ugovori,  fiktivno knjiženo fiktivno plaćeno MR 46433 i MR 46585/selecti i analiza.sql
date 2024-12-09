--(kred_planp.znes_r > 0 AND kred_planp.dat_zap < DATE() AND kred_planp.evident = '*' AND kred_planp.placano = .F. AND kred_planp.is_event = .F.)
select * from dbo.kred_planp 
where kred_planp.znes_r > 0 AND kred_planp.dat_zap < getdate() AND kred_planp.evident = '*' AND kred_planp.placano = 0 AND kred_planp.is_event = 0

select * from dbo.kred_planp where kred_planp.is_event = 1  --to su zapisi korištenja

select * from dbo.kred_planp 
where kred_planp.znes_r > 0 AND kred_planp.dat_zap < getdate() AND kred_planp.evident = '*' AND kred_planp.placano = 0 AND kred_planp.is_event = 0
and ID_KREDPOG='HAC_KREDITNI_1'



Knjiženo = kred_planp.evident

thisform.tbrACTIONS.btnknjizeno.Enabled = ((kred_planp.znes_r > 0 OR kred_planp.crpanje > 0) AND kred_planp.dat_zap < DATE() AND kred_planp.evident != '*')

PROCEDURE tbractions.btnKnjizeno.Click
		#INCLUDE ..\..\common\includes\locs.h
		
		LOCAL lcXMLDoc, lnId, lcText, lcTitle, loOdgovor, laOdgovori[2,3]
		
		lcText = "Oznaèim vse do izbranega ali samo trenutnega?" && caption
		lcTitle = "Izberi"
		loOdgovor = 2
		
		laOdgovori[1,1] = 6
		laOdgovori[1,2] = "&Vse"				&&Caption
		laOdgovori[1,3] = "Vse do izbranega"	&&Caption
		laOdgovori[2,1] = 7
		laOdgovori[2,2] = "&Trenutnega"					&&Caption
		laOdgovori[2,3] = "Samo trenutnega"	&&Caption
		*Obstaja tudi tretja opcija "Preklièi"
		
		loOdgovor = xmessagebox(lcText, 3, lcTitle, 0, @laOdgovori) && CREATEOBJECT("xmsgbox", lcText, 3, lcTitle)
		
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
		lcXmlDoc = lcXmlDoc + "<cc_make_fictive_booking xmlns='urn:gmi:nova:credit-contracts'>"
		lcXMLDoc = m.lcXMLDoc + GF_CreateNode("id_kred_pog", kred_pog.id_kredpog, "C", 1)
		lcXMLDoc = m.lcXMLDoc + GF_CreateNode("datum_dok", kred_planp.dat_zap, "D", 1)
		lcXMLDoc = m.lcXMLDoc + GF_CreateNode("only_selected", (loOdgovor = 7), "L", 1)
		
		lcXmlDoc = lcXmlDoc + "</cc_make_fictive_booking>"
		
		WAIT PRIPRAVLJAM_PODATKE WINDOW NOWAIT
		IF GF_ProcessXml(m.lcXMLDoc, .T.)
			obvesti("Uspešno konèano!")
			thisform.UpdateChild(kred_pog.id_kredpog)
			SELECT kred_planp
			LOCATE FOR kred_planp.id_kred_planp = lnId
		ELSE
			pozor("Oznaèevanje neuspešno!")
		ENDIF
	ENDPROC