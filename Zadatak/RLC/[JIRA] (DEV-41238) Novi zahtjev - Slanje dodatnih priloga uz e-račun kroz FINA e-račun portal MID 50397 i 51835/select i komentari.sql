-- podešavanja na produkciju
	-- podesio sam dodatnu rutinu dodavanja polja Napomena
--insert into dbo.ext_func (ID_EXT_FUNC, code, id_ext_func_type, inactive, onform) values ('Sys.EventHandler.RenderEdocReport.Report.Rendered', '', 'SQL_CS', 0, null)

-- podešavanja testu
--insert into dbo.ext_func (ID_EXT_FUNC, code, id_ext_func_type, inactive, onform) values ('Sys.EventHandler.RenderEdocReport.Report.Rendered', '', 'SQL_CS', 0, null)
insert into dbo.ext_func (ID_EXT_FUNC, code, id_ext_func_type, inactive, onform) values ('Sys.EventHandler.SqlExec.Report.Rendered', '', 'SQL_CS', 0, null)
--ili Queue
--insert into dbo.ext_func (ID_EXT_FUNC, code, id_ext_func_type, inactive, onform) values ('Sys.EventHandler.SqlExecQ.Report.Rendered', '', 'SQL_CS', 0, null)

--29.02.2024
-- podešeno jedan event, processing plugin i xdoc 54
-- podesiti na produkciju OBV_IND ispisa i FAK_LOBR => OBV_IND će MK
-- podesiti na produkciju poseban izvještaj 

nisam podešavao cusotm_event_handler

Sys.EventHandler.RenderEdocReportQ.Invoice.Issued  
Report.Rendered

Sys.EventHandler.RenderEdocReportQ.Report.Rendered NE RADI 
ISTINA NEMA GA U CUSTOM_EVENT_HANDLERu, ali nema ni Invoice.Issued pa radi 

KADA SE STAVI DELAY, ONDA IDE U QUEUE !!!! :) :) :) :) :) :) :) :) :) :) :) :) :) :) :) :) 
                                                 


Kolege,
provjereno smo na TESTU za klijente koji imaju FINA ID slanje dod.priloga (obavijest o inedksaciji) uz e-račun.
1. Ispis rate pojedinačne, (opcija Ispisi -  Računi za rate), e-račun:
- noćna obrada - OK 
- obavijest kreirana kao dodatna stranica računa  - OK
- obavijest je označena ispisanom u bazi obavijesti - OK 
- u bazi obavijesti, pod napomenom naveden broj računa  s kojim je obavijest poslana - OK
- barkod na računu – OK
Obzirom da se kreirao i dodatni pdf obavijesti koji se kreirao noćnom obradom i otišao u kanal PC (za naš primjer), što nam ne odgovara, molimo da se isključi kreiranje dodatnog pdf-a obavijesti
Naime, ne želimo dodatni pdf obavijesti iz razloga jer taj dokument kao takav nije nikad poslan klijentu pa nam ne odgovara da bude u evidenciji
2. Ispis zbirne rate (opcija Ispisi -Zbirni računi za rate), e -račun:
Provjerili smo i zbirne e-račune  za rate, te smo odlučili da ne želimo slati obavijesti kao dodatni prilog uz e-račun za zbirne rate.  Molimo isključiti tj ne uključivati automatski ispis obavijesti  uz zbirne e-račune za rate. 
Sve ostaje kako je i dosada.
Barkod na zbirnom računu- OK
lp
Snježana

Poštovana/i,
u privitku vam šaljemo novu ponudu za sljedeće dorade (samo za FINA partnere/e-račune), stara ponuda 10466 nije više važeća:
1. dorada ispisa RAČUNI ZA RATE na način da se kreira dodatna stranica obavijest o indeksaciji (za OL i FL)
2. dorada ispisa ZBIRNI RAČUNI ZA RATE na način da se kreira dodatna stranica obavijest o indeksaciji, za OL ugovore će ići specifikacija s kolonama npr. ugovor, datum reprograma, naziv indeksa, iznos stare i nove rate, a za FL ugovore će ići zasebna stranica s planom otplate
3. podešavanje automatskog renderiranja/ispisivanja ispisa OBAVIJEST/DOPIS O INDEKSACIJI nakon što se ispiše račun za ratu/zbirni račun, označavanje zapisa ispisanom i spremanje broja računa u napomenu.
4. dorada posebnog izvještaja "(IT-CA) EDOC - Pregled eksporta datoteka".
Zadnja stavka ponude "Pomoć korisnicima kod testiranja i nepredviđene situacije" će se naplatiti prema stvarnom utrošenom vremenu ako do njih dođe.
GMC: 
- zbirni ne treba dorađivati ali bi trebalo doraditi barcode => podesiti s produkcije i promjeniti opet logo
- račun za ratu ostaje isti 
- ispis OBV_IND se nije mjenjao jer je samo optimiziran => može kao takav na produkciju
- da li samo u kanal PCK ili općenoti renderiranje i onda edoc obrada i u arhivu
Ali treba svakako doraditi Report.Rendered jer se za zbirni račun automatski ispiše OBV_IND??

- doraditi processing plugins oko "...otišao u kanal PC (za naš primjer .." 
ako u opombe imamo upisani DDV_ID, onda ne ide u PCK

 PCK (edoc.filter_field) and Ne PCK (edoc.not_print)
 da li provjeravati DDV_ID u edoc_exported files ili najem_fa ili? => možda najbolje u edoc_exported_files ali u trenutku edoc obrade možda neće postojati tako da je bolje iz najem_fa
 
if @DocType = 'TaxChngIx'
begin
	Select '0016' as [tip_dokumenta],
	'1' as [edoc.dms],
	CASE WHEN g.id_kupca is not null Then '0'
	     When @eom_blockade = 0  Then '0' 
		 WHEN  f.id_kupca is not null Then '0' 
	     ELSE '1' End as [edoc.filter_field],
	'0' as [edoc.for_web],
	CASE WHEN g.id_kupca is not null Then '0' 
	     when @eom_blockade = 1 And f.id_kupca is not null  Then '1'  
		 ELSE '0' End as [edoc.not_print],
	RTRIM(a.id_kupca) + '_' + '0016' + '_' + RTRIM(@Id) + '.pdf' As print_centar_name,
	a.id_kupca as partner_id,
	b.naz_kr_kup as [partner_title],
	a.id_cont as contract_id, 
	RTRIM(p.id_pog) as contract_number,
		0 as pdf_sign
	From dbo.rep_ind a 
	Inner join dbo.partner b on a.id_kupca = b.id_kupca
	Inner join dbo.pogodba p on a.id_cont = p.id_cont
	left join dbo.p_kontakt f on b.id_kupca = f.id_kupca And f.id_vloga = 'XP'
	left join dbo.p_kontakt g on b.id_kupca = g.id_kupca And g.id_vloga = '02'
	Where cast(a.id_rep_ind as varchar(100)) = @Id and @DocType='TaxChngIx'
end





-- komentari za odgovor
reporti
FAK_LOBR
OBV_IND
ZBR_FAKT
Možda obrisati tekst
Iznos mjesečnih obroka u valuti je {Format("{0:N2}", ZBIRNIKI.DEBIT)} {ZBIRNIKI.id_val.Trim()}. {IIF(ZBIRNIKI.id_tec!= "000", "Protuvrijednost u kunama obračunava se prema " + ZBIRNIKI.naz_tecaj.Trim() + " na dan kreiranja računa.", "")}

i FAK_LOBR
Iznos mjesečnog obroka u valuti je {Format("{0:N2}", najem_fa.DEBIT)} {najem_fa.ID_VAL}. Protuvrijednost u kunama obračunava se prema {najem_fa.pog_tec.Trim()} na dan kreiranja računa.
	CASE WHEN kon.id_kupca_k IS NOT NULL THEN 1 ELSE 0 END AS Print_Vloga,
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'IV' AND NEAKTIVEN = 0) kon on a.id_kupca = kon.id_kupca
IV  	Ispis iznosa i u valuti na računima za rate za navedenog partnera.
000538	IBM HRVATSKA D.O.O. koji nema aktivnih ugovora.
id_kupca_k = Šifra partnera (kontakt)
Predlažem da se ta rečenica obriše ako će ugovori biti samo u EUR.



select ulica_sed, * from dbo.partner where id_kupca = '023913'
update dbo.partner set ulica_sed = ulica_sed +' test' where id_kupca = '023913'


-- FAK_LOBR primjeri
--F1
select * from dbo.najem_fa where ddv_id = '20230067896'
select top 6  * from dbo.rep_ind order by ID_REP_IND desc
update dbo.REP_IND set ddv_date = '20230703', izpisan = 0 where ID_REP_IND = 177535 --datum = '20230331', izpisan = 0, ddv_date = '20230403' 
-- originalno
update dbo.REP_IND set ddv_date = '20230403', izpisan = 1 where ID_REP_IND = 177535

--OL
select * from dbo.najem_fa where ddv_id = '20230067431' --id_cont = 77176
select top 6  * from dbo.rep_ind order by ID_REP_IND desc
update dbo.REP_IND set ddv_date = '20230703', izpisan = 0 where ID_REP_IND = 177539 --datum = '20230331', izpisan = 0, ddv_date = '20230403'
-- originalno
update dbo.REP_IND set ddv_date = '20230403', izpisan = 1 where ID_REP_IND = 177539


GREŠKA JE BILA U DATA FROM  OTHER SOURCES, kada se makne PRVA_RATA.datum_dok_MinDate, onda se podaci prikažu , bilo je podšeno poziv prema @id_rep_ind = najem_fa.id_rep_ind
Kada se za makne taj poziv i prebaci na @id najem_fa.DDV_ID

	/*24.10.2023 g_tomislav MID 
	Kada se za makne taj poziv @id=najem_fa.DDV_ID, i podesi se jednostavniji poziv @id_rep_ind = najem_fa.id_rep_ind (ili id_rep_ind_varchar), to isto funkcionira, ali kada se podesi Data form other sources PRVA_RATA.datum_dok_MinDate tada se podaci ne prikažu (kada se makne PRVA_RATA.datum_dok_MinDate, onda se podaci prikažu) => BUG?, pa je podešeno ovako kompliciranije 
	IP je koristio Master component
	*/
	

-- Zbirni račun ZBR_FAKT
select * from dbo.najem_fa where ddv_id = '20230068058   ' --id_cont = 77176
select top 6 izpisan, ddv_date, * from dbo.rep_ind where id_rep_ind in (177447, 177443) order by ID_REP_IND desc

update dbo.REP_IND set ddv_date = '20230703', izpisan = 0 where ID_REP_IND in (177447) --id_zbirnik 455
update dbo.REP_IND set ddv_date = '20230803', izpisan = 0 where ID_REP_IND in (177443) 
-- originalno
update dbo.REP_IND set ddv_date = '20230327', izpisan = 1 where ID_REP_IND in (177447, 177443)




select * from dbo.najem_fa where ddv_id = '20230068058'

select ddv_id from dbo.zbirniki where id_zbirnik =455





select case when isnull(pa.ident_stevilka, '') != '' then 1 else 0 end as FINA,  ident_stevilka
	, CASE WHEN kon.id_kupca_k IS NOT NULL THEN 1 ELSE 0 END AS Print_Vloga
	, * 
from dbo.partner pa 
LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'IV' AND NEAKTIVEN = 0) kon on pa.id_kupca = kon.id_kupca
where 1=1
--and isnull(pa.ident_stevilka, '') != '' 
and kon.id_kupca_k is not null

SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'IV' AND NEAKTIVEN = 0

select * from dbo.p_kontakt_vloga

select * from dbo.pogodba where id_kupca = '000538' and status_akt = 'A'

select * from dbo.custom_event_handlers

banka\hrpeo



select * from dbo.queue_pending
select * from dbo.queue_archive where inserted_at > getdate()-1

select top 20 * from dbo.REP_IND
--update dbo.rep_ind set opombe = 'test' where id_rep_ind  = 177447 and opombe not like '%20230068058%'

begin tran
select IZPISAN, OPOMBE, * from dbo.rep_ind where id_rep_ind  = 177447
update dbo.rep_ind set izpisan = 1 where id_rep_ind  = 177447 and izpisan = 0; update dbo.rep_ind set opombe = '20230068058' + char(13) + opombe where id_rep_ind  = 177447 and opombe not like '%20230068058%'
select IZPISAN, OPOMBE, * from dbo.rep_ind where id_rep_ind  = 177447
rollback 

select ident_stevilka, * from dbo.partner where id_kupca in ('000015', '000114')
--update dbo.partner set ident_stevilka = '1234' where id_kupca = '000015'
--update dbo.partner set ident_stevilka = '12345' where id_kupca = '000114'

select * from dbo.najem_fa where ddv_id = '20230067896'
select top 6 izpisan, ddv_date, * from dbo.rep_ind order by ID_REP_IND desc 

update dbo.REP_IND set ddv_date = '20230703', izpisan = 0 where ID_REP_IND = 177535 --datum = '20230331', izpisan = 0, ddv_date = '20230403' 
-- originalno
update dbo.REP_IND set ddv_date = '20230403', izpisan = 1 where ID_REP_IND = 177535 

select top 6 izpisan, ddv_date, * from dbo.rep_ind where id_rep_ind in (177447, 177443) order by ID_REP_IND desc

update dbo.REP_IND set ddv_date = '20230703', izpisan = 0 where ID_REP_IND in (177447) --id_zbirnik 455
update dbo.REP_IND set ddv_date = '20230803', izpisan = 0 where ID_REP_IND in (177443) 
-- originalno
update dbo.REP_IND set ddv_date = '20230327', izpisan = 1 where ID_REP_IND in (177447, 177443)


--OL pojedinačni
update dbo.REP_IND set ddv_date = '20230703', izpisan = 0 where ID_REP_IND = 177539 

select ulica_sed, * from dbo.partner where id_kupca = '023913'
update dbo.partner set ident_stevilka = '6789' where id_kupca = '023913'