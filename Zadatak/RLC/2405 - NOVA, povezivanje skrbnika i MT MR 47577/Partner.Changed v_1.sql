-- 22.11.2021 g_tomislav MID 47577 - created; this event changes id_strm on contracts and fixed assets

declare @changed_fields varchar(8000) = {5}

declare @changed_Skrbnik_1 bit = case when charindex('SKRBNIK_1', @changed_fields) > 0 then 1 else 0 end
declare @changed_Kategorija4 bit = case when charindex('KATEGORIJA4', @changed_fields) > 0 then 1 else 0 end

if @changed_Skrbnik_1 > 0 or @changed_Kategorija4 > 0
begin
	declare @id_kupca char(6) = {3}
	declare @event_name varchar(40) = {1}
	-- Podešavanja na RLC su: je_revalor = 0, TIP_AMORTIZACIJE = 0,  tri_am_st = 1 iz dbo.fa_nastavit
	declare @je_revalor bit = (select je_revalor from dbo.fa_nastavit)
	declare @tip_amortizacije tinyint = (select tip_amortizacije from dbo.fa_nastavit)
	declare @tri_am_st bit = (select tri_am_st from dbo.fa_nastavit)
	declare @daily_amort_enabled bit = 0 -- Nemaju licencu GOBJ_LicenceManager.IsModuleEnabled("FA_DAILY_DEPRECIATION") = .F.
	
	select '<?xml version=''1.0'' encoding=''utf-8'' ?>'
			+'<rpg_contract_update xmlns="urn:gmi:nova:leasing">'
			+'<common_parameters>'
			+'  <id_cont>' +cast(pog.id_cont as varchar(10)) +'</id_cont>'
			+'  <comment>Automatska promjena mjesta troška (event ' +@event_name +')</comment>'
			+'  <hash_value>' +cast(dbo.gfn_GetContractDataHash(pog.id_cont) as varchar(20)) +'</hash_value>'
			+'  <id_rep_category>999</id_rep_category>'
			+'  <use_4eyes>false</use_4eyes>'
			+'</common_parameters>'
			+'<updated_values>'
			+'  <table_name>POGODBA</table_name>'
			+'  <name>ID_STRM</name>'
			+'  <updated_value>' +rtrim(MT.id_strm) +'</updated_value>'
			+'</updated_values>'
			+'</rpg_contract_update>' AS xml
		, cast(0 as bit) as via_queue
		, 0 as delay
		, cast(0 as bit) as via_esb
		, 'nova.le' as esb_target
	from dbo.POGODBA pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT postoji u dbo.STRM1 da tek onda ide tj. za skrbnika postoji popunjen MT
	where (1 = @changed_Skrbnik_1 and pog.id_kupca = @id_kupca -- kod promjene skrbnika_1 na partneru: provjeravaju se svi partnerovi ugovori
		or 1 = @changed_Kategorija4 and s1.id_kupca = @id_kupca) -- kod promjene kategorije4 na partneru: provjeravaju se za istog svi partneri (te ugovori) gdje je on skrbnik 
	and pog.status_akt != 'Z'
	and MT.id_strm != pog.id_strm

	union all 
	-- Fixed assets (OS)
	select '<update_fa xmlns=''urn:gmi:nova:fa''>'
			+'<id_strm>'+rtrim(MT.id_strm)+'</id_strm>'
			+'<id_sobe>'+rtrim(fa.id_sobe)+'</id_sobe>'
			+'<neam_vred>'+cast(fa.neam_vred as varchar(30))+'</neam_vred>'
			+'<id_amor_sk>'+rtrim(fa.id_amor_sk)+'</id_amor_sk>'
			+'<id_nomen>'+rtrim(fa.id_nomen)+'</id_nomen>'
			+'<id_kupca>'+fa.id_kupca+'</id_kupca>'
			--IF !GF_NULLOREMPTY(fa.id_gl_sifkljuc)
			+case when fa.id_gl_sifkljuc is not null and fa.id_gl_sifkljuc = '' then 
				'<id_gl_sifkljuc>'+cast(fa.id_gl_sifkljuc as varchar(20))+'</id_gl_sifkljuc>'
				else '' end
			+'<id_knjizbe>'+rtrim(fa.id_knjizbe)+'</id_knjizbe>'
			+'<id_fa>'+cast(fa.id_fa as varchar(20))+'</id_fa>'
			--If GOBJ_Settings.GetVal("je_revalor")
			--	lcXml = lcXml + GF_CreateNode("id_reval_sk", fa.id_reval_sk, "C", 1) + gcE
			--	lcXml = lcXml + GF_CreateNode("zac_reval", fa.zac_reval, "C", 1) + gcE
			--ELSE
			--	lcXml = lcXml + GF_CreateNode("zac_reval", fa.zac_amort, "C", 1) + gcE
			--ENDIF
			+case when @je_revalor = 1 then 
				'<id_reval_sk>'+rtrim(fa.id_reval_sk)+'</id_reval_sk>'
				+'<zac_reval>'+fa.zac_reval+'</zac_reval>'
			else
				'<zac_reval>'+fa.zac_amort+'</zac_reval>'
			end
			+'<id_grupe>'+rtrim(fa.id_grupe)+'</id_grupe>'
			--IF !GF_NULLOREMPTY(fa.id_cont)
			--	lcXml = lcXml + GF_CreateNode("id_cont", fa.id_cont, "I", 1) + gcE		
			--ENDIF
			+case when fa.id_cont is not null then 
				'<id_cont>'+cast(fa.id_cont as varchar(20))+'</id_cont>'
				else '' end
			+'<naziv1>'+rtrim(replace(replace(replace(fa.naziv1, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</naziv1>'
			+'<naziv2>'+rtrim(replace(replace(replace(fa.naziv2, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</naziv2>'
			+'<stopnja_am>'+cast(fa.stopnja_am as varchar(20))+'</stopnja_am>'
			+'<sys_ts>'+cast(cast(fa.sys_ts as bigint) as varchar(40))+'</sys_ts>'
			--IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled = .T. THEN
			--	lcMonth = SUBSTR(DTOS(fa.zac_amort_datum), 5, 2)
			--	lcYear = LEFT(DTOS(fa.zac_amort_datum),4)
			--	lcXml = lcXml + GF_CreateNode("zac_amort", lcYear + "/" + lcMonth, "C", 1) + gcE
			--ELSE
			--	lcXml = lcXml + GF_CreateNode("zac_amort", fa.zac_amort, "C", 1) + gcE
			--ENDIF	
			+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
				'<zac_amort>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' + left(convert(varchar(30), fa.zac_amort_datum, 104), 2)+'</zac_amort>'
			else
				'<zac_amort>'+fa.zac_amort+'</zac_amort>'
			end				
			--IF GOBJ_Settings.GetVal("tri_am_st")
			--	lcXml = lcXml + GF_CreateNode("st_amint", fa.st_amint, "N", 1) + gcE
			--	lcXml = lcXml + GF_CreateNode("st_amek", fa.st_amek, "N", 1) + gcE	
			--ENDIF
			+case when @tri_am_st = 1 then
				'<st_amint>'+cast(fa.st_amint as varchar(20))+'</st_amint>'
				+'<st_amek>'+cast(fa.st_amek as varchar(20))+'</st_amek>'
				else '' end
			+'<ne_knjizim>'+case when fa.ne_knjizim = 1 then 'true' else 'false' end+'</ne_knjizim>'
			+'<opombe>'+rtrim(replace(replace(replace(fa.opombe, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</opombe>'
			--IF !GF_NULLOREMPTY(fa.eurotax_id)
			--	lcXml = lcXml + GF_CreateNode("eurotax_id", fa.eurotax_id, "C", 1) + gcE
			--ENDIF
			+case when fa.eurotax_id is not null and fa.eurotax_id != '' then
				'<eurotax_id>'+rtrim(fa.eurotax_id)+'</eurotax_id>'
				else '' end
			--IF !GF_NULLOREMPTY(fa.id_project)
			--	lcXml = lcXml + GF_CreateNode("id_project", fa.id_project, "N", 1) + gcE
			--ENDIF
			+case when fa.id_project is not null and fa.id_project != '' then
				'<id_project>'+cast(fa.id_project as varchar(20))+'</id_project>'
				else '' end
			--IF GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled then
			--	lcXml = lcXml + GF_CreateNode("zac_amort_datum", fa.zac_amort_datum, "D", 1) + gcE
			--ELSE
			--	lcDay = "01"
			--	lcXml = lcXml + GF_CreateNode("zac_amort_datum", DATE(VAL(LEFT(fa.zac_amort,4)), VAL(RIGHT(fa.zac_amort,2)), VAL(lcDay)), "D", 1) + gcE
			--ENDIF
			+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
				+'<zac_amort_datum>'+CONVERT(varchar(30), fa.zac_amort_datum, 126)+'</zac_amort_datum>' --2014-06-01T00:00:00.000
			else
				+'<zac_amort_datum>'+CONVERT(varchar(30), cast(datefromparts(LEFT(fa.zac_amort,4), RIGHT(fa.zac_amort,2), 1) as datetime), 126) +'</zac_amort_datum>' --2014-06-01T00:00:00.000
			end
			+'</update_fa>' 
		as xml
		, cast(0 as bit) as via_queue
		, 0 as delay --300
		, cast(0 as bit) as via_esb
		, 'nova.fa' as esb_target
		--, fa.* 
	from dbo.POGODBA pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT postoji u dbo.STRM1 da tek onda ide tj. za skrbnika postoji popunjen MT
	inner join dbo.fa fa on pog.id_cont = fa.id_cont
	where (1 = @changed_Skrbnik_1 and pog.id_kupca = @id_kupca -- kod promjene skrbnika_1 na partneru: provjeravaju se svi partnerovi ugovori
		or 1 = @changed_Kategorija4 and s1.id_kupca = @id_kupca) -- kod promjene kategorije4 na partneru: provjeravaju se za istog svi partneri (te ugovori) gdje je on skrbnik
	and fa.id_strm != MT.id_strm
	and fa.status in ('A', 'P')

	union all
	
	-- New fixed assets (OS) fa_dnev
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
					+'<zac_reval>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' +left(convert(varchar(30), fa.zac_amort_datum, 104), 2)+'</zac_reval>' -- isto kao u else ?!
				else
					 '<zac_reval>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' +left(convert(varchar(30), fa.zac_amort_datum, 104), 2)+'</zac_reval>'
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
				+'<llmmnakup>'+cast(datepart(yy,fa.datum_nakupa) as varchar(5)) +'/' + left(convert(varchar(30), fa.datum_nakupa, 104), 2)+'</llmmnakup>'
				else
				'<llmmnakup>'+rtrim(fa.llmmnakup)+'</llmmnakup>'
				end
			+'<neam_vred>'+cast(fa.neam_vred as varchar(30))+'</neam_vred>'
			+'<nabav_vred>'+cast(fa.nabav_vred as varchar(30))+'</nabav_vred>'
			+'<naziv1>'+rtrim(replace(replace(replace(fa.naziv1, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</naziv1>'
			+'<naziv2>'+rtrim(replace(replace(replace(fa.naziv2, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</naziv2>'
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
					'<zac_amort>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' + left(convert(varchar(30), fa.zac_amort_datum, 104), 2)+'</zac_amort>'
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
			+'</insert_update_fa_dnev>' 
		as xml
		, cast(0 as bit) as via_queue
		, 0 as delay --300
		, cast(0 as bit) as via_esb
		, 'nova.fa' as esb_target
		--, par.skrbnik_1, pog.STATUS_AKT, pog.id_strm, fa.id_strm fa_id_strm
		--, fa.* 
	from dbo.POGODBA pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT postoji u dbo.STRM1 da tek onda ide tj. za skrbnika postoji popunjen MT
	inner join dbo.fa_dnev fa on pog.id_cont = fa.id_cont
	where (1 = @changed_Skrbnik_1 and pog.id_kupca = @id_kupca -- kod promjene skrbnika_1 na partneru: provjeravaju se svi partnerovi ugovoru
		or 1 = @changed_Kategorija4 and s1.id_kupca = @id_kupca) -- kod promjene kategorije4 na partneru: provjeravaju se za istog svi partneri (te ugovori) gdje je on skrbnik
	and fa.id_strm != MT.id_strm
end

