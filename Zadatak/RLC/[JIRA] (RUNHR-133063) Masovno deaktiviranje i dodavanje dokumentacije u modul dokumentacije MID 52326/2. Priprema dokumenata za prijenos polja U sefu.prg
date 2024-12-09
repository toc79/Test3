Select * From RESULT Where Oznacen = .t. INTO CURSOR _PATTERN

IF !USED("_PATTERN") OR RECCOUNT("_PATTERN") = 0 THEN 
	POZOR("Niste odabrali niti jedan dokument!")
	RETURN .F.
ENDIF

PRIVATE lcBrUg
lcBrUg = ""

lnOdg = rf_msgbox("Pitanje","Želite li dodati dokumentaciju na više partnerovih ugovora ili samo na jedan?","Više","Jedan","Poništiti")

DO CASE
	CASE lnOdg = 1	&& Više
		lnOdg2 = RF_MSGBOX("Pitanje","Partnerove ugovore želim odabrati prema razdoblju?","Dat. aktivacije","Dat. sklapanja","Poništiti")
		ldDat1 = GF_GET_DATE("Upišite početni datum razdoblja:",date(),,,"Pitanje")
		ldDat2 = GF_GET_DATE("Upišite završni datum razdoblja:",date(),,,"Pitanje")

		TEXT TO lcSQL NOSHOW
			SELECT CAST((0) AS BIT) AS oznacen, id_kupca, id_cont, id_pog, pred_naj, dat_sklen, dat_aktiv, {0} AS old_id_cont 
			FROM dbo.pogodba 
			WHERE status_akt <> 'Z' and id_cont <> {0} AND id_kupca= {1} AND {2} BETWEEN {3} AND {4}
		ENDTEXT

		lcSQL = STRTRAN(lcSQL, "{0}", TRANS(_PATTERN.id_cont))
		lcSQL = STRTRAN(lcSQL, "{1}", GF_QUOTEDSTR(ALLT(_PATTERN.id_kupca)))
		lcSQL = STRTRAN(lcSQL, "{2}", IIF(lnODG2=1,"dat_aktiv","dat_sklen"))
		lcSQL = STRTRAN(lcSQL, "{3}", GF_QUOTEDSTR(DTOS(ldDat1)))
		lcSQL = STRTRAN(lcSQL, "{4}", GF_QUOTEDSTR(DTOS(ldDat2)))

		GF_SQLExec(lcSQL,"_sviug")
		GF_DataPreview("_sviug", "", "frmPripPog2", "Odaberite ugovore na koje želite prenijeti dokumentaciju")

		lcBrUg = gcLista
		
		USE IN _sviug
	CASE lnOdg = 2	&& Jedan
		GF_ObstojaPogodba(lcBrUg, "_check","")
		lcBrUg = TRANS(_check.id_cont)
		USE IN _check

		TEXT TO lcSQL NOSHOW
			SELECT id_dokum, id_obl_zav, dok_in_safe, cast(sys_ts as bigint) AS sys_ts, popravil, dat_poprave, id_cont, id_kupca, opombe 
			FROM dokument WHERE status_akt = 'A' AND id_cont IN ({0}) AND id_obl_zav IN ({1})
		ENDTEXT

		lcSQL = STRTRAN(lcSQL, "{0}", lcBrUg)
		lcSQL = STRTRAN(lcSQL, "{1}", GF_CreateDelimitedList("_PATTERN", "id_obl_zav", "", ",", .t.))

		GF_SQLEXEC(lcSQL, "_Candidates")

		Select a.*, b.dok_in_safe as pattern From _Candidates a Inner join _PATTERN b ON a.id_obl_zav = b.id_obl_zav Where a.dok_in_safe <> b.dok_in_safe INTO CURSOR Candidates

		USE IN _PATTERN
		USE IN _Candidates

		GF_EXT_FUNC("RLC_DOK_TRANSFER")
	OTHERWISE
		RETURN .F.
ENDCASE