--10.05.2024 g_tomislav MID 52056 - created;

declare @vnesel varchar(15) = {0}
declare @id_kupca char(6) = {3}

declare @vr_osebe char(2) = (select vr_osebe from dbo.partner where id_kupca = @id_kupca)
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
	cross apply dbo.gfn_GetTableFromListDelimiter(ltrim(rtrim(REPLACE(REPLACE(REPLACE(VAL_CHAR, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))), ',') dl
	inner join dbo.dok dok2 on dl.id = dok2.id_obl_zav
	where gr.ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS' 
	and gr.id_key = @vr_osebe
) dok