IF GF_NULLOREMPTY(gcLista) THEN
	POZOR("Prvo je potrebno pokrenuti dodatnu rutinu 3. Priprema Ugovora za prijenos polja U sefu!")
	RETURN .F.
ENDIF

TEXT TO lcSQL NOSHOW
	SELECT id_dokum, id_obl_zav, dok_in_safe, cast(sys_ts as bigint) AS sys_ts, popravil, dat_poprave, id_cont, id_kupca, opombe,0 as ima_u_sefu
	FROM dokument WHERE status_akt = 'A' AND id_cont IN ({0}) AND id_obl_zav IN ({1})
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", gcLista)
lcSQL = STRTRAN(lcSQL, "{1}", GF_CreateDelimitedList("_PATTERN", "id_obl_zav", "", ",", .t.))

GF_SQLEXEC(lcSQL, "_Candidates")

Select a.*, b.dok_in_safe as pattern From _Candidates a Inner join _PATTERN b ON a.id_obl_zav = b.id_obl_zav Where a.dok_in_safe <> b.dok_in_safe INTO CURSOR Candidates

USE IN _PATTERN
USE IN _Candidates

GF_EXT_FUNC("RLC_DOK_TRANSFER")

RELEASE gcLista