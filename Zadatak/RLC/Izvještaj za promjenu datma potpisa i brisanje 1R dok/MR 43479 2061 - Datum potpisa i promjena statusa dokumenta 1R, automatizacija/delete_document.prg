PROCEDURE tlbDokument.btnBrisi.Click
		#INCLUDE ..\..\common\includes\locs.h
		LOCAL lcXml, lcXmlResult, lcE, llConfirm, llDeleteLinks
		
		WITH Thisform
			IF RECCOUNT("dokument") = 0 THEN 
				.grdDokument.SetFocus
				RETURN 
			ENDIF
		
			* Check permission
			IF GOBJ_Permissions.GetPermissionEx('ContractDocumentationDelete','DocTypes',dokument.id_obl_zav) < 2 THEN 
				pozor(STRTRAN(PERMISSION_DENIED, "{0}", "ContractDocumentationDelete"))
				.grdDokument.SetFocus
				RETURN
			ENDIF
		
			lcE = CHR(13) + CHR(10)
			
			* Checks
			DIMENSION laResult[2]
			laResult = GF_CheckBeforeDeletingDocs(dokument.id_dokum)
			llConfirm = laResult[1]
			llDeleteLinks = laResult[2]
			
			lcXml = '<delete_dokument xmlns="urn:gmi:nova:leasing">' + lcE
			lcXml = lcXml + GF_CreateNode("id_dokum", dokument.id_dokum, "N", 1) + lcE
			IF llDeleteLinks = .T. THEN
				lcXml = lcXml + GF_CreateNode("delete_linked_docs", .T., "L", 1) + gcE
			ENDIF
			lcXml = lcXml + "</delete_dokument>"
			
			IF llConfirm THEN
				lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)
		
				IF TYPE("lcXmlResult") != "C" THEN
					RETURN .F.
				ENDIF
				ll4Eyes = XMLDataType(GF_GetSingleNodeXml(lcXmlResult, "sent_to_4eyes"), 'L', 2)
		
				IF TYPE("ll4Eyes") != "L" THEN
					pozor("Zapisa ni mogoče zbrisati!")
					RETURN .F.
				ENDIF
				
				IF (ll4Eyes)
					OBVESTI(FOUREYES_QUEUE_OK)
				ELSE 
					obvesti(INFDELETED_LOC)
					Thisform.gmi_requery()
				ENDIF
			ENDIF
			.grdDokument.SetFocus
		ENDWITH
	ENDPROC

*** GF_CheckBeforeDeletingDocs **************************************************

FUNCTION GF_CheckBeforeDeletingDocs
	LPARAMETERS id_dokum
	LOCAL lcE, lcXml, lcXmlResult, lcCursor, lcErrorMsg, lcConfirmMsg, llDeleteLinks, llConfirm

	lcE = CHR(13) + CHR(10)

	* Cehck for linked documents
	lcXml = '<check_for_linked_docs xmlns="urn:gmi:nova:leasing">' + lcE
	lcXml = lcXml + GF_CreateNode("id_dokum", id_dokum, "N", 1) + gcE
	lcXml = lcXml + "</check_for_linked_docs>"
	lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)
	IF TYPE("lcXmlResult") == "L" AND lcXmlResult = .F. THEN && Error occured
		DIMENSION result[2]
		result[1] = .F.
		result[2] = .F.
		RETURN result
	ENDIF

	* Stop on error (empty string = no errors)
	lcConfirmMsg = ""
	IF TYPE("lcXmlResult") == "C" THEN
		lcConfirmMsg = GF_GetSingleNodeXml(lcXmlResult, "unblocking_docs")
		lcErrorMsg = GF_GetSingleNodeXml(lcXmlResult, "error_msg")
		IF (!GF_NULLOREMPTY(lcErrorMsg)) THEN
			obvesti(lcErrorMsg)
			DIMENSION result[2]
			result[1] = .F.
			result[2] = .F.
			RETURN result
		ENDIF
	ENDIF

	* Get confirmation for deletion
	llDeleteLinks = .F.
	llConfirm = .F.
	IF (!GF_NULLOREMPTY(lcConfirmMsg)) THEN
		llDeleteLinks = .T.
		llConfirm = potrjeno(lcConfirmMsg + lcE + lcE + STRTRAN(DELETEREC_LOC, "?", " " + TRANSFORM(id_dokum) + "?"))
	ELSE
		llConfirm = potrjeno(STRTRAN(DELETEREC_LOC, "?", " " + TRANSFORM(id_dokum) + "?"))
	ENDIF
	
	* Result
	DIMENSION result[2]
	result[1] = llConfirm
	result[2] = llDeleteLinks
	RETURN result
ENDFUNC