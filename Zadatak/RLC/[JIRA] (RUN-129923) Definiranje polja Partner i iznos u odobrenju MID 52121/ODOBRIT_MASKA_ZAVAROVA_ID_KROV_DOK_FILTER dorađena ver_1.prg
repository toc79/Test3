*!* Function must return string

** 16.08.2024 g_tomislav MID 51690 and 52121
IF _zavar.id_obl_zav == "ZE"
	RETURN "id_cont is null and id_obl_zav = 'ZT' and id_kupca_dok = " +GF_QUOTEDSTR(_zavar.id_kupca)
ELSE
	RETURN ""
ENDIF 