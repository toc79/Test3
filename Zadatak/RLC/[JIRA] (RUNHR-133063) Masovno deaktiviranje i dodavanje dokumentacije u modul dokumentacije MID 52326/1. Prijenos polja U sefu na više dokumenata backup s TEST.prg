&& MR48906 g_igorp 20.06.2022

&& 1. Prijenos polja U sefu na više dokumenata  

LOCAL lcStariAlias
lcStariAlias = ALIAS()

loForm = GF_GetFormObject("frmDOKUMENT_PREGLED")

**PROVJERA OVLASTI KORISNIKA
IF GOBJ_Permissions.GetPermission('ContractDocumentationUpdate') < 2 THEN 
	pozor("Nemate potrebna prava za izvođenje funkcionalnosti (dodavanje ili brisanje ugovorne dokumentacije)")
	RETURN .F.
ENDIF

PUBLIC gcLista
gcLista = ""

lcKup = GF_SQLExecScalar("SELECT id_kupca FROM pogodba WHERE id_cont = "+GF_QUOTEDSTR(dokument.id_cont))

lnOdg = rf_msgbox("Odabir dokumenta za podešavanje polja U sefu","Želite li podesiti više dokumenata ili trenutni dokument?","Više","Jedan","Poništiti")

DO CASE
	CASE lnOdg = 1	&& Više
		loForm.gmi_requery
		loForm.grdDokument.SetFocus

		Select .T. as Oznacen, id_dokum, id_obl_zav, opis, dok_in_safe, id_cont, lcKup as id_kupca From Dokument Where id_obl_zav # 'IE' Group by id_obl_zav INTO CURSOR _PATTERN
		GF_DataPreview("_PATTERN", "", "frmPripDok2", "Odaberite dokumente za koje želite prijenos polja U sefu")
		USE IN _PATTERN
	CASE lnOdg = 2	&& Jedan
		IF DOKUMENT.ID_OBL_ZAV != 'IE' THEN
			lcID = Dokument.ID_DOKUM
			Select .T. as Oznacen, id_obl_zav, dok_in_safe, id_cont, lcKup as id_kupca From Dokument Where ID_DOKUM = lcID INTO CURSOR _PATTERN

			&&GF_EXT_FUNC("RLC_DOK_PREPARE")

			GF_DataPreview("_PATTERN", "", "frmPripDok2", "Odaberite dokumente za koje želite prijenos polja U sefu")
			USE IN _PATTERN
		ELSE
			POZOR("Za vrstu dokumenta IE ova rutina se ne upotrebljava!")
			RETURN .F.
		ENDIF
	OTHERWISE
		RETURN .F.
ENDCASE