--10.05.2024 g_tomislav MID 52056 - created;

declare @vnesel varchar(15) = {0}
declare @id_kupca char(6) = {3}

declare @today datetime = convert(date, getdate())

select '<insert_update_dokument xmlns="urn:gmi:nova:leasing"><dokument>'
		+'<dat_poprave>'+CONVERT(varchar(30), getdate(), 126)+'</dat_poprave>'
		+'<datum>'+CONVERT(varchar(30), dateadd(dd, dok.dni_zap, @today), 126)+'</datum>'
		+'<datum_dok>'+CONVERT(varchar(30), @today, 126)+'</datum_dok>'
		+'<dok_in_safe>false</dok_in_safe>'
		+'<id_kupca>'+@id_kupca+'</id_kupca>'
		+'<id_obl_zav>'+dok.id_obl_zav+'</id_obl_zav>'
		+'<id_zapo></id_zapo><ima>false</ima><is_elligible>false</is_elligible><kolicina>1</kolicina>'
		+'<opis>'+ltrim(rtrim(dok.opis))+'</opis>'
		+'<opis1></opis1><opombe></opombe><opravi_sam>2</opravi_sam>'
		+'<popravil>'+@vnesel+'</popravil>'
		+'<potrebno>true</potrebno><rang_hipo>1</rang_hipo><reg_stev></reg_stev><st_nalepke></st_nalepke><st_vink></st_vink><status_akt>A</status_akt><status_zk></status_zk><stevilka></stevilka><tip_cen></tip_cen>'
		+'<vnesel>'+@vnesel+'</vnesel>'
		+'<vrednost>0</vrednost><vrst_red_d></vrst_red_d><vrsta></vrsta>'
		+'<zav_je_on>false</zav_je_on></dokument></insert_update_dokument>' AS xml
	, cast(0 as bit) as via_queue
	, 0 as delay
	, cast(0 as bit) as via_esb
	, 'nova.le' as esb_target
from (
	select distinct dok2.id_obl_zav, dok2.dni_zap, dok2.opis
	from dbo.general_register gr 
	outer apply dbo.gfn_GetTableFromListDelimiter(ltrim(rtrim(REPLACE(REPLACE(REPLACE(VAL_CHAR, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))), ',') dl
	inner join dbo.dok dok2 on dl.id = dok2.id_obl_zav
	where gr.ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS' 
	and gr.id_key = @vr_osebe
) dok

-- 13.12.2021 g_tomislav MID 47577 - created; this event changes id_strm on contracts and fixed assets
-- 15.03.2022 g_tomislav MID 48043 - added change id_strm in delimiters (gl_razmej i gl_raz_planp)

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
	
	-- candidates
	select pog.id_cont, MT.id_strm as id_strm_new
	into #candidates
	from dbo.POGODBA pog
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT postoji u dbo.STRM1 da tek onda ide tj. za skrbnika postoji popunjen MT
	where (1 = @changed_Skrbnik_1 and pog.id_kupca = @id_kupca -- kod promjene skrbnika_1 na partneru: provjeravaju se svi partnerovi ugovori
		or 1 = @changed_Kategorija4 and s1.id_kupca = @id_kupca) -- kod promjene kategorije4 na partneru: provjeravaju se za istog svi partneri (te ugovori) gdje je on skrbnik 
	
	-- Contracts
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
	and c.id_strm_new != pog.id_strm 
	
-- s RLC
<insert_update_dokument xmlns="urn:gmi:nova:leasing">
<dokument>
<dat_poprave>2024-05-09T10:52:04.000</dat_poprave>
<datum>2024-05-09T00:00:00.000</datum>
<datum_dok>2024-05-09T00:00:00.000</datum_dok>
<dok_in_safe>false</dok_in_safe>
<id_kupca>000012</id_kupca>
<id_obl_zav>P1</id_obl_zav>
<id_zapo></id_zapo>
<ima>false</ima>
<is_elligible>false</is_elligible>
<kolicina>1</kolicina>
<opis>Upitnik za klijenta</opis>
<opis1></opis1>
<opombe></opombe>
<opravi_sam>2</opravi_sam>
<popravil>g_tomislav</popravil>
<potrebno>true</potrebno>
<rang_hipo>1</rang_hipo>
<reg_stev></reg_stev>
<st_nalepke></st_nalepke>
<st_vink></st_vink>
<status_akt>A</status_akt>
<status_zk></status_zk>
<stevilka></stevilka>
<tip_cen></tip_cen>
<vnesel>g_tomislav</vnesel>
<vrednost>0</vrednost>
<vrst_red_d></vrst_red_d>
<vrsta></vrsta>
<zav_je_on>false</zav_je_on>
</dokument>
</insert_update_dokument>

-- -- dodatna rutina na ESL
-- Kreiranje lcId_obl_zav_Izjava dokumenata: krovni i vezani na krovni
		IF POTRJENO("Želite li formirati krovni dokument "+lcId_obl_zav_Izjava+" na partnera " +allt(lcId_kupca) +" te također isti takav dokument po svim ugovorima iz liste?")
			TEXT TO lcSql NOSHOW
				declare @today datetime = dbo.gfn_getDatePart(getdate())
				select '<insert_update_dokument xmlns="urn:gmi:nova:leasing"><dokument>'
					+'<dat_poprave>'+CONVERT(varchar(30), getdate(), 126)+'</dat_poprave>'
					+'<datum>'+CONVERT(varchar(30), dateadd(dd, dok.dni_zap, @today), 126)+'</datum>'
					+'<datum_dok>'+CONVERT(varchar(30), @today, 126)+'</datum_dok>'
					+'<dok_in_safe>false</dok_in_safe>'
					+'<id_kupca>{0}</id_kupca>'
					+'<id_obl_zav>'+dok.id_obl_zav+'</id_obl_zav>'
					--+'<id_tec>{4}</id_tec>'
					+'<id_zapo></id_zapo><ima>false</ima><is_elligible>false</is_elligible><kolicina>1</kolicina>'
					+'<opis>'+ltrim(rtrim(dok.opis))+'</opis>'
					+'<opis1></opis1><opombe></opombe><opravi_sam>2</opravi_sam>'
					+'<popravil>{1}</popravil>'
					+'<potrebno>true</potrebno><rang_hipo>1</rang_hipo><reg_stev></reg_stev><st_nalepke></st_nalepke><st_vink></st_vink><status_akt>A</status_akt><status_zk></status_zk><stevilka></stevilka><tip_cen></tip_cen>'
					+'<vnesel>{1}</vnesel>'
					+'<vrednost>0</vrednost><vrst_red_d></vrst_red_d><vrsta></vrsta>'
					--+'<zacetek>'+CONVERT(varchar(30), @today, 126)+'</zacetek>'
					+'<zav_je_on>false</zav_je_on></dokument></insert_update_dokument>'
				--from dbo.dok 
				--where id_obl_zav = '{3}'
				from (select distinct dl.* 
					from dbo.general_register gr 
					outer apply dbo.gfn_GetTableFromListDelimiter(ltrim(rtrim(REPLACE(REPLACE(REPLACE(VAL_CHAR, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))), ',') dl
					join dbo.dok dok on dl.id = dok.id_obl_zav
					where gr.ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS' 
					and gr.id_key = @vr_osebe) dok
			ENDTEXT

			lcSql = STRTRAN(lcSql, "{0}", lcId_kupca)
			lcSql = STRTRAN(lcSql, "{1}", ALLT(allt(GObj_Comm.getUserName())))
			lcSql = STRTRAN(lcSql, "{2}", GF_TRANSFORM_NUMERIC(_ef_limiti.limit_ukupni))
			lcSql = STRTRAN(lcSql, "{3}", lcId_obl_zav_Izjava)
			lcSql = STRTRAN(lcSql, "{4}", lcTarget_id_tec)
			
			lcXML = GF_SQLEXECScalar(lcSql)
			
			lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)