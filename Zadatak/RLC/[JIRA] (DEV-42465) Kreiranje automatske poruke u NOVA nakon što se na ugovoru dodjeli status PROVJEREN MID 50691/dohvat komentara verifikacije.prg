nisam našao gdje se šalje mail kod Aktivacije, možda su to poslali iz RLB, a za RLC treba kod verifikacije

* get potential comment that was made at contract verification
		TEXT TO lcSQL NOSHOW 
			SELECT cast(r.comment as [text]) as comment, u.user_desc, r.[time], p.id_pog
			FROM 
			    dbo.reprogram r
			    INNER JOIN dbo.users u ON r.[user] = u.username 
			    INNER JOIN dbo.pogodba p on r.id_cont = p.id_cont
			WHERE 
			    r.id_rep_type = 'VER' 
			    AND r.id_cont IN ({0}) 
			    and LEN(ISNULL(r.comment, '')) <> 0
			ORDER BY r.time DESC
		ENDTEXT 
		lcSQL = STRTRAN(lcSQL, "{0}", lcListIdCont)
		GF_SQLEXEC(lcSQL, "reprogram")
		SELECT reprogram
		IF RECCOUNT() > 0 THEN 
			LOCAL lcComment, lcPogodba
			lcPogodba = "Pogodba" && caption
			lcComment = ""
			SCAN 
				lcComment = lcComment + "Odobril: " && caption
				lcComment = lcComment + ALLTRIM(reprogram.user_desc) + ', ' + ALLTRIM(DTOC(reprogram.time))
				lcComment = lcComment + "; " + lcPogodba + SPACE(1) + ALLTRIM(reprogram.id_pog) + gcE 
				lcComment = lcComment + ALLTRIM(reprogram.comment) + gcE + gcE
			ENDSCAN 
			GF_Message_memo(lcComment)
		ENDIF 