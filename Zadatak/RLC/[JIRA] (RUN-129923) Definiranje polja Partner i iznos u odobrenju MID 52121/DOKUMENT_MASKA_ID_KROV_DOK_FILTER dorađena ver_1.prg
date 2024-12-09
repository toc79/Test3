*!* Function must return string

** 19.08.2024 g_tomislav MID 51690 and 52121
IF dokument.id_obl_zav == "ZE"
	RETURN "id_cont is null and id_obl_zav = 'ZT' and id_kupca_dok = " +GF_QUOTEDSTR(dokument.id_kupca)
ELSE
	RETURN ""
ENDIF 