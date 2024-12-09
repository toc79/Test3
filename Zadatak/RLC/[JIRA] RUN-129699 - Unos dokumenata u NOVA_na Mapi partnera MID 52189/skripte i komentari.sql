--podešavanje na produkciji

--vrste dokumenata
select * from dbo.dok where id_obl_zav in (
'P1','P2','P3','P4','P5','P6','P7','P8','P9','PA','PB','PC','PE','PG','PH','SW','ID','UU','MP','FI','A2','A4','A1','A3','A5'
)

-- posebni šifranti 
select * from dbo.general_register where id_key = 'RLC_DOKDEF_FOR_PARTNERS' or ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS'

-- novi ext_func koji treba podesiti kao na testu
insert into dbo.ext_func (ID_EXT_FUNC, code, id_ext_func_type, inactive, onform) values ('Sys.EventHandler.ProcessXml.Partner.Entered', '', 'SQL_CS', 0, 'frmPartner_maska')

-- kraj podešavanja na produkciji  

Poštovana/i, 

na NOVA_TEST sam napravio podešavanja prema zahtjevu. 
U posebnom šifrantu sam kreirao novi šifrant za mapiranja šifre vrste osobe i vrste dokumenta. ID šifranta je RLC_DOKDEF_FOR_PARTNERS gdje Ključ predstavlja šifru vrste osobe, a Znakovna vrijednost predstavlja šifru vrsta dokumenata. Kada ćete vi sami uređivati šifrant, listu šifri dokumenta treba obavezno odvojiti zarezom (,) jer je zarez delimiter. Podaci vrste osobe i vrste dokumenata se kod uređivanja se moraju točno unijeti tj. to moraju biti postojeće  šifre. Ako jedna od šifri dokumenata nije postojeća tj. neispravno unesena, takav dokument se neće kreirati niti će se prikazati greška kod unosa partnera. 
Ako se unesu dvije iste šifre dokumenata za jednu vrstu osoba, kreirati će se samo jedan dokument npr. ako unesete tri iste "A3,A3,A3" onda će se kreirati jedan dokument A3 (to mogu drugačije podesiti da se kreira za svaki uneseni pa bi se kreiralo 3 dokumenta A3).

Korisnik koji unosi partnera treba imat odgovarajuća prava (premissions) za unos takvih vrsta dokumenata.

Molim testirajte i povratnu informaciju.

$SIGN 

select * from dbo.general_register where id_key = 'RLC_DOKDEF_FOR_PARTNERS'
select * from dbo.general_register where ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS'
select * from dbo.VRST_ose

--UPDATE dbo.general_register set id_key = 'RLC_DOKDEF_FOR_PARTNERS'  where id_key = 'RLC_DOK_FOR_PARTNERS'
--update dbo.general_register set ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS' where ID_REGISTER = 'RLC_DOK_FOR_PARTNERS'

--insert into dbo.general_register (ID_REGISTER, ID_KEY, VALUE, VAL_BIT, VAL_NUM, VAL_CHAR, neaktiven, val_datetime) values 

--insert into dbo.general_register (ID_REGISTER, ID_KEY, VALUE, VAL_BIT, VAL_NUM, VAL_CHAR, neaktiven, val_datetime)
--select 'RLC_DOK_FOR_PARTNERS', vr_osebe, naziv, 0, 0, '', 0, null from dbo.vrst_ose
--where vr_osebe != 'B1'

select distinct dl.* 
from dbo.general_register gr 
outer apply dbo.gfn_GetTableFromListDelimiter(gr.VAL_CHAR, ',') dl
where gr.ID_REGISTER = 'RLC_DOK_FOR_PARTNERS'
and not exists (select * from dbo.dok where id_obl_zav = dl.id)

select distinct dl.* 
from dbo.general_register gr 
outer apply dbo.gfn_GetTableFromListDelimiter(gr.VAL_CHAR, ',') dl
join dbo.dok dok on dl.id = dok.id_obl_zav
where gr.ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS'

10.05.2024 16:13:29:426	110	GMI_Session	Sys	[g_tomislav,10.239.110.142]	[0a4818fb-0df8-4e72-8945-f6bf42031a98,LE]	Event Partner.Entered raised with event data: [Key: [id_kupca], Value: [041486]; ]
10.05.2024 16:13:29:426	110	DBHelper	Db	[g_tomislav,10.239.110.142]	[0a4818fb-0df8-4e72-8945-f6bf42031a98,LE]	Getting dataset with adapter: --Parameters {X}:  -- 0 - 'g_tomislav'  -- 1 - 'partner.entered'  -- 2 - 'id_kupca'  -- 3 - '041486'  -- 4 - NULL    -- 5 - NULL  -- 6 - NULL

declare @vr_osebe char(2) = 'B1'

select distinct dl.* 
from dbo.general_register gr 
outer apply dbo.gfn_GetTableFromListDelimiter(ltrim(rtrim(REPLACE(REPLACE(REPLACE(VAL_CHAR, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))), ',') dl
join dbo.dok dok on dl.id = dok.id_obl_zav
where gr.ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS' 
and gr.id_key = @vr_osebe

--select gr.*, dl.* 
--from dbo.general_register gr 
--outer apply  dbo.gfn_GetTableFromListDelimiter(ltrim(rtrim(replace(replace(replace(VAL_CHAR, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))), ',') dl
--where gr.ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS' 
--and gr.id_key = @vr_osebe

declare @today datetime = convert(date, getdate())
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
		+'<zav_je_on>false</zav_je_on></dokument></insert_update_dokument>' AS xml
	, cast(0 as bit) as via_queue
	, 0 as delay
	, cast(0 as bit) as via_esb
	, 'nova.le' as esb_target
from (
	select distinct dok2.id_obl_zav, dok2.dni_zap, dok2.opis
	from dbo.general_register gr 
	outer apply dbo.gfn_GetTableFromListDelimiter(ltrim(rtrim(REPLACE(REPLACE(REPLACE(VAL_CHAR, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))), ',') dl
	join dbo.dok dok2 on dl.id = dok2.id_obl_zav
	where gr.ID_REGISTER = 'RLC_DOKDEF_FOR_PARTNERS' 
	and gr.id_key = @vr_osebe
) dok
