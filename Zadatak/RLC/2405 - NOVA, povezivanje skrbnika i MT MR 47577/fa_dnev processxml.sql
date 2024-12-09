	-- Fixed assets (OS) fa_dnev
	select '<insert_update_fa_dnev xmlns=''urn:gmi:nova:fa''>'
		+'<dat_fakt>'+convert(varchar(30), fa.dat_fakt, 126)+'</dat_fakt>'
		+'<id_strm>'+rtrim(MT.id_strm)+'</id_strm>'
		+'<id_sobe>'+rtrim(fa.id_sobe)+'</id_sobe>'
		+'<id_amor_sk>'+rtrim(fa.id_amor_sk)+'</id_amor_sk>'
		+'<id_nomen>'+rtrim(fa.id_nomen)+'</id_nomen>'
		+'<id_kupca>'+rtrim(fa.id_kupca)+'</id_kupca>'
		-- IF !GF_NULLOREMPTY(fa_dnev.id_cont)
			-- lcXml = lcXml + GF_CreateNode("id_cont", fa_dnev.id_cont, "I", 1) + gcE		
		-- ENDIF 
		+case when fa.id_cont is not null then 
				'<id_cont>'+cast(fa.id_cont as varchar(20))+'</id_cont>'
				else '' end
		-- IF !GF_NULLOREMPTY(fa_dnev.id_gl_sifkljuc)
			-- lcXml = lcXml + GF_CreateNode("id_gl_sifkljuc", fa_dnev.id_gl_sifkljuc, "I", 1) + gcE	
		-- ENDIF	
		+case when fa.id_gl_sifkljuc is not null and fa.id_gl_sifkljuc = '' then 
				'<id_gl_sifkljuc>'+cast(fa.id_gl_sifkljuc as varchar(20))+'</id_gl_sifkljuc>'
				else '' end
		+'<id_knjizbe>'+rtrim(fa.id_knjizbe)+'</id_knjizbe>'
		+'<id_fa>'+cast(fa.id_fa as varchar(20))+'</id_fa>'
		+'<inv_stev>'+rtrim(fa.inv_stev)+'</inv_stev>'
		-- IF GOBJ_Settings.GetVal("je_revalor")
			-- lcXml = lcXml + GF_CreateNode("id_reval_sk", fa_dnev.id_reval_sk, "C", 1) + gcE
			-- lcMonth = SUBSTR(DTOS(fa_dnev.zac_amort_datum), 5, 2)
			-- lcYear = LEFT(DTOS(fa_dnev.zac_amort_datum),4)
			-- lcXml = lcXml + GF_CreateNode("zac_reval", lcYear + "/" + lcMonth, "C", 1) + gcE
		-- ELSE
			-- lcMonth = SUBSTR(DTOS(fa_dnev.zac_amort_datum), 5, 2)
			-- lcYear = LEFT(DTOS(fa_dnev.zac_amort_datum),4)
			-- lcXml = lcXml + GF_CreateNode("zac_reval", lcYear + "/" + lcMonth, "C", 1) + gcE
		-- ENDIF
		+case when @je_revalor = 1 then 
				'<id_reval_sk>'+rtrim(fa.id_reval_sk)+'</id_reval_sk>'
				+'<zac_reval>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' + cast(datepart(MM, fa.zac_amort_datum) as char(2))+'</zac_reval>' -- isto kao u else ?!
			else
				'<zac_reval>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' + cast(datepart(MM, fa.zac_amort_datum) as char(2))+'</zac_reval>'
			end
		+'<id_grupe>'+rtrim(fa.id_grupe)+'</id_grupe>'
		-- IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled THEN
			-- lcMonth = SUBSTR(DTOS(fa_dnev.datum_nakupa), 5, 2)
			-- lcYear = LEFT(DTOS(fa_dnev.datum_nakupa),4)
			-- lcXml = lcXml + GF_CreateNode("llmmnakup", lcYear + "/" + lcMonth, "C", 1) + gcE
		-- ELSE
			-- lcXml = lcXml + GF_CreateNode("llmmnakup", fa_dnev.llmmnakup, "C", 1) + gcE
		-- ENDIF
		+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
			+'<llmmnakup>'+cast(datepart(yy,fa.datum_nakupa) as varchar(5)) +'/' + cast(datepart(MM, fa.datum_nakupa) as char(2))+'</llmmnakup>'
			else
			'<llmmnakup>'+rtrim(fa.llmmnakup)+'</llmmnakup>'
			end
		+'<neam_vred>'+cast(fa.neam_vred as varchar(30))+'</neam_vred>'
		+'<nabav_vred>'+cast(fa.nabav_vred as varchar(30))+'</nabav_vred>'
		+'<naziv1>'+rtrim(fa.naziv1)+'</naziv1>'
		+'<naziv2>'+rtrim(fa.naziv2)+'</naziv2>'
		+'<nab_vr_bre>'+cast(fa.nab_vr_bre as varchar(30))+'</nab_vr_bre>'
		+'<odp_vr_bre>'+cast(fa.odp_vr_bre as varchar(30))+'</odp_vr_bre>'
		+'<odpis_vred>'+cast(fa.odpis_vred as varchar(30))+'</odpis_vred>'
		-- IF GOBJ_Settings.GetVal("tri_am_st")
			-- lcXml = lcXml + GF_CreateNode("st_amek", fa_dnev.st_amek, "N", 1) + gcE	
			-- lcXml = lcXml + GF_CreateNode("st_amint", fa_dnev.st_amint, "N", 1) + gcE
		-- ENDIF
		+case when @tri_am_st = 1 then
				'<st_amek>'+cast(fa.st_amek as varchar(20))+'</st_amek>'
				+'<st_amint>'+cast(fa.st_amint as varchar(20))+'</st_amint>'
				else '' end
		+'<stopnja_am>'+cast(fa.stopnja_am as varchar(20))+'</stopnja_am>'
		+'<sys_ts>'+cast(cast(fa.sys_ts as bigint) as varchar(40))+'</sys_ts>'
		+'<st_fakture>'+rtrim(fa.st_fakture)+'</st_fakture>'
		+'<v_pripravi>'+case when fa.v_pripravi = 1 then 'true' else 'false' end+'</v_pripravi>'
		+'<vnesel>'+rtrim(fa.vnesel)+'</vnesel>'
		-- IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled = .T. THEN
			-- lcMonth = SUBSTR(DTOS(fa_dnev.zac_amort_datum), 5, 2)
			-- lcYear = LEFT(DTOS(fa_dnev.zac_amort_datum),4)
			-- lcXml = lcXml + GF_CreateNode("zac_amort", lcYear + "/" + lcMonth, "C", 1) + gcE
		-- ELSE
			-- lcXml = lcXml + GF_CreateNode("zac_amort", fa_dnev.zac_amort, "C", 1) + gcE
		-- ENDIF
		+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
				'<zac_amort>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' + cast(datepart(MM, fa.zac_amort_datum) as char(2))+'</zac_amort>'
			else
				'<zac_amort>'+fa.zac_amort+'</zac_amort>'
			end
		-- IF !GF_NULLOREMPTY(fa_dnev.eurotax_id)
			-- lcXml = lcXml + GF_CreateNode("eurotax_id", fa_dnev.eurotax_id, "C", 1) + gcE
		-- ENDIF
		+case when fa.eurotax_id is not null and fa.eurotax_id != '' then
				'<eurotax_id>'+rtrim(fa.eurotax_id)+'</eurotax_id>'
				else '' end
		-- IF !GF_NULLOREMPTY(fa_dnev.id_project)
			-- lcXml = lcXml + GF_CreateNode("id_project", fa_dnev.id_project, "N", 1) + gcE
		-- ENDIF
		+case when fa.id_project is not null and fa.id_project != '' then
				'<id_project>'+cast(fa.id_project as varchar(20))+'</id_project>'
				else '' end
		-- IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled THEN
			-- lcXml = lcXml + GF_CreateNode("zac_amort_datum", fa_dnev.zac_amort_datum, "D", 1) + gcE
		-- ELSE
			-- lcDay = "01"
			-- lcXml = lcXml + GF_CreateNode("zac_amort_datum", DATE(VAL(LEFT(fa_dnev.zac_amort,4)), VAL(RIGHT(fa_dnev.zac_amort,2)), VAL(lcDay)), "D", 1) + gcE
		-- ENDIF
		+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
				+'<zac_amort_datum>'+CONVERT(varchar(30), fa.zac_amort_datum, 126)+'</zac_amort_datum>' --2014-06-01T00:00:00.000
			else
				+'<zac_amort_datum>'+CONVERT(varchar(30), cast(datefromparts(LEFT(fa.zac_amort,4), RIGHT(fa.zac_amort,2), 1) as datetime), 126) +'</zac_amort_datum>' --2014-06-01T00:00:00.000
			end
		-- IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled THEN
			-- lcXml = lcXml + GF_CreateNode("datum_nakupa", fa_dnev.datum_nakupa, "D", 1) + gcE
		-- ELSE
			-- lcDay = "01"
			-- lcXml = lcXml + GF_CreateNode("datum_nakupa", DATE(VAL(LEFT(fa_dnev.llmmnakup,4)), VAL(RIGHT(fa_dnev.llmmnakup,2)), VAL(lcDay)), "D", 1) + gcE
		-- ENDIF
		+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
				+'<datum_nakupa>'+CONVERT(varchar(30), fa.datum_nakupa, 126)+'</datum_nakupa>' --2014-06-01T00:00:00.000
			else
				+'<datum_nakupa>'+CONVERT(varchar(30), cast(datefromparts(LEFT(fa.llmmnakup,4), RIGHT(fa.llmmnakup,2), 1) as datetime), 126) +'</datum_nakupa>' --2014-06-01T00:00:00.000
			end
		+'<ne_knjizim>'+case when fa.ne_knjizim = 1 then 'true' else 'false' end+'</ne_knjizim>'
		+'</insert_update_fa_dnev>' as xml

ELSE &&update				 
				lcXml = "<insert_update_fa_dnev xmlns='urn:gmi:nova:fa'>" + gcE
				lcXml = lcXml + GF_CreateNode("dat_fakt", fa_dnev.dat_fakt, "D", 1) + gcE	
				lcXml = lcXml + GF_CreateNode("id_strm", fa_dnev.id_strm, "C", 1) + gcE
				lcXml = lcXml + GF_CreateNode("id_sobe", fa_dnev.id_sobe, "C", 1) + gcE
				lcXml = lcXml + GF_CreateNode("id_amor_sk", fa_dnev.id_amor_sk, "C", 1) + gcE
				lcXml = lcXml + GF_CreateNode("id_nomen", fa_dnev.id_nomen, "C", 1) + gcE		
				lcXml = lcXml + GF_CreateNode("id_kupca", fa_dnev.id_kupca, "C", 1) + gcE
				
				IF !GF_NULLOREMPTY(fa_dnev.id_cont)
					lcXml = lcXml + GF_CreateNode("id_cont", fa_dnev.id_cont, "I", 1) + gcE		
				ENDIF 	
				
				IF !GF_NULLOREMPTY(fa_dnev.id_gl_sifkljuc)
					lcXml = lcXml + GF_CreateNode("id_gl_sifkljuc", fa_dnev.id_gl_sifkljuc, "I", 1) + gcE	
				ENDIF	
				
				lcXml = lcXml + GF_CreateNode("id_knjizbe", fa_dnev.id_knjizbe, "C", 1) + gcE
				lcXml = lcXml + GF_CreateNode("id_fa", fa_dnev.id_fa, "I", 1) + gcE	
				lcXml = lcXml + GF_CreateNode("inv_stev", fa_dnev.inv_stev, "C", 1) + gcE
				
				IF GOBJ_Settings.GetVal("je_revalor")
					lcXml = lcXml + GF_CreateNode("id_reval_sk", fa_dnev.id_reval_sk, "C", 1) + gcE
					lcMonth = SUBSTR(DTOS(fa_dnev.zac_amort_datum), 5, 2)
					lcYear = LEFT(DTOS(fa_dnev.zac_amort_datum),4)
					lcXml = lcXml + GF_CreateNode("zac_reval", lcYear + "/" + lcMonth, "C", 1) + gcE
				ELSE
					lcMonth = SUBSTR(DTOS(fa_dnev.zac_amort_datum), 5, 2)
					lcYear = LEFT(DTOS(fa_dnev.zac_amort_datum),4)
					lcXml = lcXml + GF_CreateNode("zac_reval", lcYear + "/" + lcMonth, "C", 1) + gcE
				ENDIF
				
				lcXml = lcXml + GF_CreateNode("id_grupe", fa_dnev.id_grupe, "C", 1) + gcE
				
				IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled THEN
					lcMonth = SUBSTR(DTOS(fa_dnev.datum_nakupa), 5, 2)
					lcYear = LEFT(DTOS(fa_dnev.datum_nakupa),4)
					lcXml = lcXml + GF_CreateNode("llmmnakup", lcYear + "/" + lcMonth, "C", 1) + gcE
				ELSE
					lcXml = lcXml + GF_CreateNode("llmmnakup", fa_dnev.llmmnakup, "C", 1) + gcE
				ENDIF		
				
				lcXml = lcXml + GF_CreateNode("neam_vred", fa_dnev.neam_vred, "N", 1) + gcE
				lcXml = lcXml + GF_CreateNode("nabav_vred", fa_dnev.nabav_vred, "N", 1) + gcE
				lcXml = lcXml + GF_CreateNode("naziv1", fa_dnev.naziv1, "C", 1) + gcE
				lcXml = lcXml + GF_CreateNode("naziv2", fa_dnev.naziv2, "C", 1) + gcE
				lcXml = lcXml + GF_CreateNode("nab_vr_bre", fa_dnev.nab_vr_bre, "N", 1) + gcE
				lcXml = lcXml + GF_CreateNode("odp_vr_bre", fa_dnev.odp_vr_bre, "N", 1) + gcE
				lcXml = lcXml + GF_CreateNode("odpis_vred", fa_dnev.odpis_vred, "N", 1) + gcE
				
				IF GOBJ_Settings.GetVal("tri_am_st")
					lcXml = lcXml + GF_CreateNode("st_amek", fa_dnev.st_amek, "N", 1) + gcE	
					lcXml = lcXml + GF_CreateNode("st_amint", fa_dnev.st_amint, "N", 1) + gcE
				ENDIF
				
				lcXml = lcXml + GF_CreateNode("stopnja_am", fa_dnev.stopnja_am, "N", 1) + gcE
				lcXml = lcXml + GF_CreateNode("sys_ts", fa_dnev.sys_ts, "N", 1) + gcE
				lcXml = lcXml + GF_CreateNode("st_fakture", fa_dnev.st_fakture, "C", 1) + gcE
				lcXml = lcXml + GF_CreateNode("v_pripravi", fa_dnev.v_pripravi, "L", 1) + gcE
				lcXml = lcXml + GF_CreateNode("vnesel", fa_dnev.vnesel, "C", 1) + gcE
						
				IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled = .T. THEN
					lcMonth = SUBSTR(DTOS(fa_dnev.zac_amort_datum), 5, 2)
					lcYear = LEFT(DTOS(fa_dnev.zac_amort_datum),4)
					lcXml = lcXml + GF_CreateNode("zac_amort", lcYear + "/" + lcMonth, "C", 1) + gcE
				ELSE
					lcXml = lcXml + GF_CreateNode("zac_amort", fa_dnev.zac_amort, "C", 1) + gcE
				ENDIF
				
				IF !GF_NULLOREMPTY(fa_dnev.eurotax_id)
					lcXml = lcXml + GF_CreateNode("eurotax_id", fa_dnev.eurotax_id, "C", 1) + gcE
				ENDIF
				
				IF !GF_NULLOREMPTY(fa_dnev.id_project)
					lcXml = lcXml + GF_CreateNode("id_project", fa_dnev.id_project, "N", 1) + gcE
				ENDIF
				
				IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled THEN
					lcXml = lcXml + GF_CreateNode("zac_amort_datum", fa_dnev.zac_amort_datum, "D", 1) + gcE
				ELSE
					lcDay = "01"
					lcXml = lcXml + GF_CreateNode("zac_amort_datum", DATE(VAL(LEFT(fa_dnev.zac_amort,4)), VAL(RIGHT(fa_dnev.zac_amort,2)), VAL(lcDay)), "D", 1) + gcE
				ENDIF
				
				IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled THEN
					lcXml = lcXml + GF_CreateNode("datum_nakupa", fa_dnev.datum_nakupa, "D", 1) + gcE
				ELSE
					lcDay = "01"
					lcXml = lcXml + GF_CreateNode("datum_nakupa", DATE(VAL(LEFT(fa_dnev.llmmnakup,4)), VAL(RIGHT(fa_dnev.llmmnakup,2)), VAL(lcDay)), "D", 1) + gcE
				ENDIF
				lcXml = lcXml + GF_CreateNode("ne_knjizim", fa_dnev.ne_knjizim, "L", 1) + gcE 
				
				lcXml = lcXml + "</insert_update_fa_dnev>"
				
				IF !GF_ProcessXml(lcXml) THEN