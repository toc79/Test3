1341 ugovora
845 osnovnih sredstava
2 nove nabave
oko 3 minute

select * from dbo.CUSTOM_SETTINGS where code = 'Nova.LE.CustomerCategoryName4'
update dbo.CUSTOM_SETTINGS set val= 'Mj.tr.' where code = 'Nova.LE.CustomerCategoryName4'


- podešavanje da se kod unosa ugovora početno postavi referent iz odobrenja
- postavljanje mjesta troška kod unosa ugovora
- kontrola kod spremanja aktivnog i neaktivnog ugovora 
- kontrola da se ne može unijeti skrbnik za nekog partnera ukoliko nema podatak "Kategorija 4". Na produkciji treba poslati listu svih skrbnika 1 na partnerima te će na njima morati promijeniti podatke tj. ne na svima samo na nezaključenim 

NA nova_test sam maknuo kontrolu koja onemogućava određena polja za unos, kako bih bilo lakše testiranje.

? GOBJ_LicenceManager.IsModuleEnabled("FA_DAILY_DEPRECIATION")
u slučaju lidence za dnevnu deperciation trebati će obavezno doraditi automatizam oko promejne FA jer vrijednosti nekih od polja ovise o tim podešavanjima
ma masci je sve vezano GOBJ_Settings.GetVal("TIP_AMORTIZACIJE") == 1 AND thisform.daily_amort_enabled = .T.

Za promjenu podataka neaktivnih ugovora sam napravio da se zapiše u pregled reprograma (korištena je klasa za promejnu aktivnog ugovora pa će opis biti da je riječ o promjeni aktivnog ugovora). Možemo napraviti da se ne zapiše u pregled reprograma.

neaktivne ugovore starije od ?? to ih pitati

Nakon unosa novog partnera, on nema niti jedan ugovor tako da nije potrebno na ta event Entered.

RLC treba testirati promejnu
1)  skrbnika 1,  
2) Kategorije 4 tj. Mj.tr. na partneru te 
3) skrbnika 1 i Kategorije 4 tj. Mj.tr. na partneru koji je i sam skrbnik 1 i ima dakle ugovore (ako ćete ovakav treći slučaj imati.

Ak odođe do greške kod promejne MT, promejna na partneru se neće spremiti će

-- insert into dbo.EXT_FUNC values ('Sys.EventHandler.ProcessXml.Partner.Changed', '', 'SQL_CS', 0, null)
-- select ID_STRM, status_akt,* from dbo.pogodba where id_kupca = '029344' and STATUS_AKT != 'Z'
-- update dbo.pogodba set id_strm = '0902' where id_cont in (72208,72209)
--Parameters {X}:
--{0} 0 - 'g_tomislav'   
--{1} 1 - 'partner.changed'   
--{2} 2 - 'id_kupca'  
--{3} 3 - '000012'
--{4} 4 - 'changed_fields'
--{5} 5 - 'SKRBNIK_1,KATEGORIJA4,dat_poprave' - list of changed fields

insert into dbo.EXT_FUNC values ('Sys.EventHandler.ProcessXml.Partner.Changed', '', 'SQL_CS', 0, null)

Event Partner.Changed raised with event data: [Key: [id_kupca], Value: [000012]; Key: [changed_fields], Value: [OPIS_DEJ,dat_poprave]; ]
--Parameters {X}:  
--'g_tomislav' 0 -'g_tomislav'     
--'partner.changed' 1 -'generalregister.update'     
--'id_kupca' 2 -'id_register'    
--'000012' 3 -'RLC_SKRBNIK_1_MT'    
--'changed_fields' 4 -'id_key'    
--'OPIS_DEJ,dat_poprave' 5 -'001493'    

-----------------------------------------------------------------------------------
--Za GMI možda bug? TODO Josip rekao da je ot nebitno za HR, bitno za dnevne amortizacije
-- fa_dnev
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

--dok kod FA je drugačije postavljenje
If GOBJ_Settings.GetVal("je_revalor")
	lcXml = lcXml + GF_CreateNode("id_reval_sk", fa.id_reval_sk, "C", 1) + gcE
	lcXml = lcXml + GF_CreateNode("zac_reval", fa.zac_reval, "C", 1) + gcE
ELSE
	lcXml = lcXml + GF_CreateNode("zac_reval", fa.zac_amort, "C", 1) + gcE
ENDIF
-----------------------------------------------------------------------------------


select kategorija3,* from dbo.PARTNER where kategorija3 is not null and kategorija3 != ''

select skrbnik_2, * from dbo.PARTNER where skrbnik_2 is not null and skrbnik_2 != '' and skrbnik_2 != '000015'
select skrbnik_2, * from dbo.PARTNER where id_kupca in ('011318', '000015')    

select id_kupca, * from dbo.USERS 
select skrbnik_1,* from dbo.PARTNER where skrbnik_1 in (select id_kupca from dbo.users where id_kupca is not null)

select * from dbo.referent

SELECT * FROM dbo.ref_grup_strm 
SELECT * FROM dbo.vrst_opr

--
select top 100 * from dbo.odobrit  order by id_odobrit desc

--0043448

select * from dbo.custom_settings where code = 'referent_from_approval'
insert into dbo.custom_settings values ('referent_from_approval', 1, 'Ob vnosu pogodbe se privzeto nastavi referent iz odobritve, če omenjena nastavitev = 1.')
--insert into dbo.custom_settings values ('referent_from_approval', 1, 'Ob vnosu pogodbe se privzeto nastavi referent iz odobritve, če omenjena nastavitev = 1.', 'Odobrit')

select * from dbo.GRUPE
SELECT * FROM dbo.ref_grup_strm

insert into dbo.ref_grup_strm (id_ref, id_grupe, id_strm, user_id) values ('0030', 'VNC', '1010', 338) -- ne mogu biti null id_grupe niti user_id tako da ako će se podešavati, zbog kalkulacije treba za svakog usera podesiti sve grupe

--update dbo.REF_GRUP_STRM set id_strm = '1010' 


select par.skrbnik_1, s1.naz_kr_kup,* 
from dbo.PARTNER par
join dbo.PARTNER s1 on par.skrbnik_1 = s1.id_kupca
where par.skrbnik_1 is not null and par.skrbnik_1 != '' 

Kod deaktiviranja zapisa posebnog šifranta kao i kod brisanja, neće biti nikakvih akcija, samo kod promjene MT.
Mogu podesiti da se neaktivni zapisi ne uvažavaju, da li to ima smisla??

sp_helptext gfn_FA_Register 

select * from dbo.EVENT_HISTORY order by id_event_history desc
select * from dbo.EVENT_TYPE
select * from dbo.EVENT_TYPE_CHILD
select * from dbo.EXT_FUNC where id_ext_func like '%Sys%'
select * from dbo.custom_event_handlers
--update dbo.custom_event_handlers set inactive = 1, handler_full_name = '' where event_name = 'Contract.InsertingOrUpdating'
--update dbo.custom_event_handlers set inactive = 1 where event_name = 'Contract.InsertOrUpdate'

--insert into dbo.EXT_FUNC values ('Sys.EventHandler.ProcessXml.GeneralRegister.Update', '', 'SQL_CS', 0, null)
--insert into dbo.EXT_FUNC values ('Sys.EventHandler.ProcessXml.GeneralRegister.Insert', '', 'SQL_CS', 0, null)
--insert into dbo.ext_func values ('Sys.EventHandler.ProcessXml.Contract.InsertOrUpdate', '', 'SQL_CS', 0, null) -- NE RADI NA AKTIVNIM UGOVORMA 
--insert into dbo.ext_func values ('Sys.EventHandler.ProcessXml.Contract.InsertingOrUpdating', '', 'SQL_CS', 0, null) -- NE RADI NA AKTIVNIM UGOVORIMA
--Kod promjene aktivnog ugovora na NOVA_HAC_NEW ima Event, koji pak nije naveden u ext_func ili custom_event_handlers, Event DwcDiffSyncCandidate.Insert raised with event data: [Key: [id_cont], Value: [2262]; Key: [id_kupca], Value: []; Key: [type], Value: [UPD]; ]  /// <summary> Called when something happened on contract, partner, claim etc. that is relevant for dwc diff sync candidate</summary>
--select * from dbo.custom_event_handlers -- nije bilo potrebno registrirati event, možda zato što nije custom
