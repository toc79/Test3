-- insert into dbo.EXT_FUNC values ('Sys.EventHandler.ProcessXml.Partner.Changed', '', 'SQL_CS', 0, null)
-- select ID_STRM, status_akt,* from dbo.pogodba where id_kupca = '029344' and STATUS_AKT != 'Z'
-- update dbo.pogodba set id_strm = '0903' where id_cont in (72208,72209)
-- update dbo.fa_dnev set id_strm = '0903' where id_cont in ()
--Parameters {X}:
--{0} - 0 - 'g_tomislav'   
--{1} - 1 - 'partner.changed'   
--{2} - 2 - 'id_kupca'  
--{3} - 3 - '000012'
--{4} - 4 - 'changed_fields'
--{5} - 5 - 'SKRBNIK_1,KATEGORIJA4,dat_poprave' - list of changed fields9)

declare @changed_fields varchar(8000) = 'KATEGORIJA4,dat_poprave' --SKRBNIK_1,
declare @changed_Skrbnik_1 bit = case when charindex('SKRBNIK_1', @changed_fields) > 0 then 1 else 0 end
declare @changed_Kategorija4 bit = case when charindex('KATEGORIJA4', @changed_fields) > 0 then 1 else 0 end
--select @changed_Skrbnik_1, @changed_Kategorija4 

if @changed_Skrbnik_1 > 0 or @changed_Kategorija4 > 0
begin
	declare @id_kupca char(6) = '036651' --'000012'
	declare @event_name varchar(40) = 'partner.changed'
	-- Podešavanja na RLC su: je_revalor = 0, TIP_AMORTIZACIJE = 0,  tri_am_st = 1 iz dbo.fa_nastavit
	declare @je_revalor bit = (select je_revalor from dbo.fa_nastavit)
	declare @tip_amortizacije tinyint = (select tip_amortizacije from dbo.fa_nastavit)
	declare @tri_am_st bit = (select tri_am_st from dbo.fa_nastavit)
	declare @daily_amort_enabled bit = 0 -- Nemaju licencu GOBJ_LicenceManager.IsModuleEnabled("FA_DAILY_DEPRECIATION") = .F.
	
	-- candidates
	select pog.id_cont, MT.id_strm as id_strm_new
	into #candidates
	from dbo.POGODBA pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT postoji u dbo.STRM1 da tek onda ide tj. za skrbnika postoji popunjen MT
	where (1 = @changed_Skrbnik_1 and pog.id_kupca = @id_kupca -- kod promjene skrbnika_1 na partneru: provjeravaju se svi partnerovi ugovori
		or 1 = @changed_Kategorija4 and s1.id_kupca = @id_kupca) -- kod promjene kategorije4 na partneru: provjeravaju se za istog svi partneri (te ugovori) gdje je on skrbnik 
	
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
			+'  <updated_value>' +rtrim(c.id_strm_new) +'</updated_value>'
			+'</updated_values>'
			+'</rpg_contract_update>' AS xml
		, cast(0 as bit) as via_queue
		, 0 as delay
		, cast(0 as bit) as via_esb
		, 'nova.le' as esb_target
	from dbo.POGODBA pog
	inner join #candidates c on pog.id_cont = c.id_cont 
	where pog.status_akt != 'Z'
	--and c.id_strm_new != pog.id_strm
	and pog.id_strm = '0901'

	--union all 
	-- Fixed assets (OS)
	select '<update_fa xmlns=''urn:gmi:nova:fa''>'
			+'<id_strm>'+rtrim(c.id_strm_new)+'</id_strm>'
			+'<id_sobe>'+rtrim(fa.id_sobe)+'</id_sobe>'
			+'<neam_vred>'+cast(fa.neam_vred as varchar(30))+'</neam_vred>'
			+'<id_amor_sk>'+rtrim(fa.id_amor_sk)+'</id_amor_sk>'
			+'<id_nomen>'+rtrim(fa.id_nomen)+'</id_nomen>'
			+'<id_kupca>'+fa.id_kupca+'</id_kupca>'
			+case when fa.id_gl_sifkljuc is not null and fa.id_gl_sifkljuc = '' then 
				'<id_gl_sifkljuc>'+cast(fa.id_gl_sifkljuc as varchar(20))+'</id_gl_sifkljuc>'
				else '' end
			+'<id_knjizbe>'+rtrim(fa.id_knjizbe)+'</id_knjizbe>'
			+'<id_fa>'+cast(fa.id_fa as varchar(20))+'</id_fa>'
			+case when @je_revalor = 1 then 
				'<id_reval_sk>'+rtrim(fa.id_reval_sk)+'</id_reval_sk>'
				+'<zac_reval>'+fa.zac_reval+'</zac_reval>'
			else
				'<zac_reval>'+fa.zac_amort+'</zac_reval>'
			end
			+'<id_grupe>'+rtrim(fa.id_grupe)+'</id_grupe>'
			+case when fa.id_cont is not null then 
				'<id_cont>'+cast(fa.id_cont as varchar(20))+'</id_cont>'
				else '' end
			+'<naziv1>'+rtrim(replace(replace(replace(fa.naziv1, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</naziv1>'
			+'<naziv2>'+rtrim(replace(replace(replace(fa.naziv2, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</naziv2>'
			+'<stopnja_am>'+cast(fa.stopnja_am as varchar(20))+'</stopnja_am>'
			+'<sys_ts>'+cast(cast(fa.sys_ts as bigint) as varchar(40))+'</sys_ts>'
			+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
				'<zac_amort>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' + left(convert(varchar(30), fa.zac_amort_datum, 104), 2)+'</zac_amort>'
			else
				'<zac_amort>'+fa.zac_amort+'</zac_amort>'
			end				
			+case when @tri_am_st = 1 then
				'<st_amint>'+cast(fa.st_amint as varchar(20))+'</st_amint>'
				+'<st_amek>'+cast(fa.st_amek as varchar(20))+'</st_amek>'
				else '' end
			+'<ne_knjizim>'+case when fa.ne_knjizim = 1 then 'true' else 'false' end+'</ne_knjizim>'
			+'<opombe>'+rtrim(replace(replace(replace(fa.opombe, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</opombe>'
			+case when fa.eurotax_id is not null and fa.eurotax_id != '' then
				'<eurotax_id>'+rtrim(fa.eurotax_id)+'</eurotax_id>'
				else '' end
			+case when fa.id_project is not null and fa.id_project != '' then
				'<id_project>'+cast(fa.id_project as varchar(20))+'</id_project>'
				else '' end
			+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
				+'<zac_amort_datum>'+CONVERT(varchar(30), fa.zac_amort_datum, 126)+'</zac_amort_datum>' 
			else
				+'<zac_amort_datum>'+CONVERT(varchar(30), cast(datefromparts(LEFT(fa.zac_amort,4), RIGHT(fa.zac_amort,2), 1) as datetime), 126) +'</zac_amort_datum>' 
			end
			+'</update_fa>' 
		as xml
		, cast(0 as bit) as via_queue
		, 0 as delay --300
		, cast(0 as bit) as via_esb
		, 'nova.fa' as esb_target
	from dbo.fa fa
	inner join #candidates c on fa.id_cont = c.id_cont
	where --fa.id_strm != c.id_strm_new
	fa.id_strm = '0901'
	and fa.status in ('A', 'P')

	--union all
	
	-- New fixed assets (OS) fa_dnev
	select '<insert_update_fa_dnev xmlns=''urn:gmi:nova:fa''>'
			+'<dat_fakt>'+convert(varchar(30), fa.dat_fakt, 126)+'</dat_fakt>'
			+'<id_strm>'+rtrim(c.id_strm_new)+'</id_strm>'
			+'<id_sobe>'+rtrim(fa.id_sobe)+'</id_sobe>'
			+'<id_amor_sk>'+rtrim(fa.id_amor_sk)+'</id_amor_sk>'
			+'<id_nomen>'+rtrim(fa.id_nomen)+'</id_nomen>'
			+'<id_kupca>'+rtrim(fa.id_kupca)+'</id_kupca>'
			+case when fa.id_cont is not null then 
					'<id_cont>'+cast(fa.id_cont as varchar(20))+'</id_cont>'
					else '' end
			+case when fa.id_gl_sifkljuc is not null and fa.id_gl_sifkljuc = '' then 
					'<id_gl_sifkljuc>'+cast(fa.id_gl_sifkljuc as varchar(20))+'</id_gl_sifkljuc>'
					else '' end
			+'<id_knjizbe>'+rtrim(fa.id_knjizbe)+'</id_knjizbe>'
			+'<id_fa>'+cast(fa.id_fa as varchar(20))+'</id_fa>'
			+'<inv_stev>'+rtrim(fa.inv_stev)+'</inv_stev>'
			+case when @je_revalor = 1 then 
					'<id_reval_sk>'+rtrim(fa.id_reval_sk)+'</id_reval_sk>'
					+'<zac_reval>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' +left(convert(varchar(30), fa.zac_amort_datum, 104), 2)+'</zac_reval>' -- isto kao u else ?!
				else
					 '<zac_reval>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' +left(convert(varchar(30), fa.zac_amort_datum, 104), 2)+'</zac_reval>'
				end
			+'<id_grupe>'+rtrim(fa.id_grupe)+'</id_grupe>'
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
			+case when @tri_am_st = 1 then
					'<st_amek>'+cast(fa.st_amek as varchar(20))+'</st_amek>'
					+'<st_amint>'+cast(fa.st_amint as varchar(20))+'</st_amint>'
					else '' end
			+'<stopnja_am>'+cast(fa.stopnja_am as varchar(20))+'</stopnja_am>'
			+'<sys_ts>'+cast(cast(fa.sys_ts as bigint) as varchar(40))+'</sys_ts>'
			+'<st_fakture>'+rtrim(fa.st_fakture)+'</st_fakture>'
			+'<v_pripravi>'+case when fa.v_pripravi = 1 then 'true' else 'false' end+'</v_pripravi>'
			+'<vnesel>'+rtrim(fa.vnesel)+'</vnesel>'
			+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
					'<zac_amort>'+cast(datepart(yy,fa.zac_amort_datum) as varchar(5)) +'/' + left(convert(varchar(30), fa.zac_amort_datum, 104), 2)+'</zac_amort>'
				else
					'<zac_amort>'+fa.zac_amort+'</zac_amort>'
				end
			+case when fa.eurotax_id is not null and fa.eurotax_id != '' then
					'<eurotax_id>'+rtrim(fa.eurotax_id)+'</eurotax_id>'
					else '' end
			+case when fa.id_project is not null and fa.id_project != '' then
					'<id_project>'+cast(fa.id_project as varchar(20))+'</id_project>'
					else '' end
			+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
					+'<zac_amort_datum>'+CONVERT(varchar(30), fa.zac_amort_datum, 126)+'</zac_amort_datum>' 
				else
					+'<zac_amort_datum>'+CONVERT(varchar(30), cast(datefromparts(LEFT(fa.zac_amort,4), RIGHT(fa.zac_amort,2), 1) as datetime), 126) +'</zac_amort_datum>'
				end
			+case when @tip_amortizacije = 1 and @daily_amort_enabled = 1 then 
					+'<datum_nakupa>'+CONVERT(varchar(30), fa.datum_nakupa, 126)+'</datum_nakupa>' --2014-06-01T00:00:00.000
				else
					+'<datum_nakupa>'+CONVERT(varchar(30), cast(datefromparts(LEFT(fa.llmmnakup,4), RIGHT(fa.llmmnakup,2), 1) as datetime), 126) +'</datum_nakupa>' 
				end
			+'<ne_knjizim>'+case when fa.ne_knjizim = 1 then 'true' else 'false' end+'</ne_knjizim>'
			+'</insert_update_fa_dnev>' 
		as xml
		, cast(0 as bit) as via_queue
		, 0 as delay --300
		, cast(0 as bit) as via_esb
		, 'nova.fa' as esb_target
	from dbo.fa_dnev fa
	inner join #candidates c on fa.id_cont = c.id_cont
	where --fa.id_strm != c.id_strm_new
	fa.id_strm = '0901'
	
	drop table #candidates
end