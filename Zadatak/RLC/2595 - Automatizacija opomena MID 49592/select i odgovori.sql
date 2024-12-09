-- PODEŠAVANJA
1. Job izdavanja opomena (job za pripremu već postoji)
Kod izdavanje opomena treba iskljuliti ID pripreme 6 Priprema opomena - O1 opomene bez troška je ispis ide grupirano po partneru. TO zapravo treba provjeriti s RLC da li treba zapisati datume opomena na ugovore tog partnera, ako treba onda izdavanje ide i za ID pripremu 6.

2. podesiti event (ali ne queue-able već običan ) za ispis OPOMIN bez troškova (not Invoice)
select * from dbo.custom_event_handlers where event_name = 'ReminderWithNoCostAfterIssue'
-- update dbo.custom_event_handlers set inactive = 0 where event_name = 'ReminderWithNoCostAfterIssue'
-- select * from dbo.ext_func  where ID_EXT_FUNC like 'Sys.EventHandler.RenderEdocReportQ.ReminderWithNoCostAfterIssue'
--ne mora biti Q jer to znači da će raise_event dodatni u queue što pak nije potrebno 
--u eventu podesiti renderiranje reporta i delay čime će automatski ići u queue ?!
--=> TESTIRATI NA RLC BEZ QUEUE
--=> testirao sam na ESL i kada se stavi delay, onda report ide u QUEUE u eventu InsertOrUpdate  

3. Podesiti renderiranje u XDOCu za ispise:  (Treba ići zasebno renderiranje/ispisivanje zato jer ne idu svi na MAIL....)
U eventu je potrebno podesiti više reporta ili XDOC => bolje XDOC jer bi trebalo u 2 eventa Invoice.Issued i ReminderWithNoCostAfterIssue
0043 guarremind Obavijest jamcu o opomeni - ide samo za tipove in ('0','1')
0044 guarremind Obavijest dodatnim jamcima o opomeni - ide samo za tipove A (B nije korišten od 2007)
-- u Candidates čak i ne treba zapisati id-jeve (doc_id) jer bi trebao biti kompozitni ključ i zato jer imamo ARH_ZA_OPOM
0045 general Obavijest o neplaćenim potraživanjima => ovaj ispis je vezan na točku 5.
DODATNI KOMENTAR 09.09.2024: to znači da će kod svih automatizma za izdavanje računa za ratu biti potrebno maknuti one opomene koje ima ID pripreme 6 Priprema opomena - O1 opomene bez troška??!!
Provjeriti s RLC, da li idu opomene jamcima za pripremu 6 .



4. slanje na mail iz edoca. Jedan XDOC za sve? Zašto ne
PDF sign
filter_metadata_field=pdf_sign;filter_metadata_value=0;sign_metadata_xml=false;throw_exception=true;cert_file=\\RLENOVAAPP-t\NOVA_TEST\AppServer\config\e-racun-test.rl-hr.hr.p12;cert_pwd=Leasing5;
Samo se računi potpisuju (Invoice i InvoiceCum)
Kod slanja na mail, onda se isti ne mogu slati grupirano npr. 20 po mailu. Eventualno, da se tako grupirani potpišu što smo slali mislim u GMI za OTP => u source nije vidljivo da su dodali Merge and sign
Zbog navedenog možda zaseban izvoz za račune opomena, a zaseban izvoz za ostalo. Ili svi zajedno jedan ispis jedan mail


5. poseban izvjštaj 

6. excel 



7. deaktivirati xdoc i job 30 Slanje obavijesti e-mailom o obavezi izdavanja ispisivanja opomena



/*
Komentari nakon podešavanja
Mogu greške
Greška kod joba
	id_step_history	start_time	end_time	exec_command	run_status	error_msg	response
	384512	05.09.2024. 10:04	05.09.2024. 10:04	<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs><list>62268</list> <list>62272</list> <list>62274</list> <list>62280</list> <list>62283</list> <list>62288</list> <list>62289</list> <list>62291</list> <list>62292</list> <list>62293</list> <list>62294</list> <list>62295</list> <list>62296</list> <list>62297</list> <list>62298</list> <list>62308</list> <list>62313</list> <list>62316</list> <list>62318</list> <list>62319</list> <list>62320</list> <list>62323</list> <list>62326</list> <list>62332</list> <list>62333</list> <list>62340</list></issue_reminders>	0 - Failed	Exception: Za odabrani datum nije unešen tečaj (5.9.2024.).
Stack trace    at GMI.Core.GMI_ProcessXmlEngine.Handle(GMI_Session session, XmlDocument xml_doc, Boolean is_async)
   at GMI.Core.GMI_JobRunner.RunBl()	

select * from dbo.ext_func  where ID_EXT_FUNC like 'Sys.EventHandler.RenderEdocReportQ.ReminderWithNoCostAfterIssue'
ne mora biti Q jer to znači da će raise_event dodatni u queue što pak nije potrebno 

<?xml version="1.0" encoding="utf-16"?>
<raise_event xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <event_name>reminderwithnocostafterissue</event_name>
  <is_from_queue>true</is_from_queue>
  <event_data name="IDs" value="63024" />
</raise_event>

Tipovi jamca
ID_TIP_PORO	OPIS	GLAVNI
0	Jamac               	0
1	Jamac               	1
A	Dodatni jamac       	0
B	Sudužnik            	1
select * from dbo.TIP_PORO
select oznaka, GodinaUnosa = year(datum_vnosa), count(*) as br_zapisa from dbo.pog_poro group by oznaka, year(datum_vnosa) order by GodinaUnosa desc


*/

--renderiranje iz programa
<?xml version='1.0' encoding='utf-8'?>
<render_report2  xmlns='urn:gmi:nova:core'>
<wait_to_finish>false</wait_to_finish>
<return_rendered_data>true</return_rendered_data>
<return_data_to_memory>false</return_data_to_memory>
<document>
<report_name>OBV_POR_SSOFT_RLC</report_name>
<object_id>19658689;041416</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<print_settings><skip_preview>false</skip_preview>
</print_settings></render_report2>

--renderiranje iz eventa
<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>OPOMIN_SSOFT_ESL</report_name>
  <object_id>63006</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
  <sql_code_after>update dbo.za_opom set izpisan = 1 where id_opom = 63006</sql_code_after>
</render_report>

--renderiranje iz XDOC koji šalje mail => onda nema XML poziva u logu => PDF se kreira u EDOC_DSA folderu
06.09.2024 15:02:36:627	126	MultiThreadedReportRendering	Sys			Rendering report: OBV_POR_SSOFT_RLC 19658689;041416
06.09.2024 15:02:36:627	126	EdocUtils	Sys			Get report from global cache: OBV_POR_SSOFT_RLC
06.09.2024 15:02:37:769	126	MultiThreadedReportRendering	Sys			Finished main rendering report : OBV_POR_SSOFT_RLC 19658689;041416
06.09.2024 15:02:37:769	126	EdocUtils	Sys			Rendering report OBV_POR_SSOFT_RLC with id '19658689;041416' to EDOC - condition is true



use Nova_hac_new

select * from dbo.ext_func  where ID_EXT_FUNC like '%ReminderWithNoCostAfterIssue%'
select * from dbo.ext_func  where ID_EXT_FUNC like 'Sys.EventHandler.RenderEdocReportQ.ReminderWithNoCostAfterIssue'

--ReminderWithNoCostAfterIssue

declare @broj_opomena int = (SELECT count(*) as broj_opomena FROM dbo.za_opom where st_opomina in (1,2,3) and isnull(dok_opom, '') = '')  --and oznacen = 0

if @broj_opomena > 0 
begin
Select  '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' 
		+ replace(replace(replace(
				(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
				FROM dbo.za_opom    
				where st_opomina in (1,2,3)    
				--and oznacen = 0
				and isnull(dok_opom, '') = ''
				order by st_opomina, id_opom
				FOR XML PATH(''))
			,'&lt;','<'),'&gt;','>'),'lt;','') 
		+ '</issue_reminders>'
end

select * from dbo.custom_event_handlers where event_name = 'ReminderWithNoCostAfterIssue'
update dbo.custom_event_handlers set inactive = 0 where event_name = 'ReminderWithNoCostAfterIssue'

select ddv_id, * from dbo.za_opom where ST_OPOMINA > 0

select * from dbo.queue_pending
select * from dbo.queue_archive where  inserted_at > getdate()-1
select top 10 * from dbo.reports_log order by 1 desc




title	description	pre_eval_sql	cmd
1. Priprava Opominov	1. Priprava Opominov	SELECT dbo.gfn_GetDatePart(GETDATE()) AS TargetDate	<reminders_generate xmlns="urn:gmi:nova:leasing">    <dat_prip>${TargetDate}</dat_prip>    <reminder_types>   <id_za_opom_type>1</id_za_opom_type>    </reminder_types>    <reminder_types>   <id_za_opom_type>2</id_za_opom_type>    </reminder_types>       <reminder_types>   <id_za_opom_type>17</id_za_opom_type>    </reminder_types>  </reminders_generate>
2. Izdaja Opominov	2. Izdaja Opominov	Select  isnull( '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' +  + '<' + replace(replace(replace(SUBSTRING(  (       SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      FROM  dbo.za_opom    where st_opomina in (1,2,3)    and oznacen = 0    FOR XML PATH('')   ), 2 , 9999),'&lt;','<'),'&gt;','>'),'lt;','') + '</issue_reminders>',  '<issue_reminders_nlb_wrapper xmlns="urn:gmi:nova:si_nlb">  <with_costs>true</with_costs>  <id_opom_list_as_string></id_opom_list_as_string> </issue_reminders_nlb_wrapper>' )	
3. dnevna rutina PRIPRAVA DOGODKOV ZA OPOMINE	3. dnevna rutina PRIPRAVA DOGODKOV ZA OPOMINE		<?xml version="1.0" encoding="utf-16"?>  <opom_dog xmlns="urn:gmi:nova:si_nlb">    <insert_arh_opravki>true</insert_arh_opravki>  </opom_dog>
4. Edoc izvozi	4. Edoc izvozi	select code from ( select '<prepare xmlns="urn:gmi:nova:xdoc"> <xdoc_template_id>3</xdoc_template_id> <perform_commit_automatically>true</perform_commit_automatically> </prepare>' as code, 1 as vrstni_red union select '<prepare xmlns="urn:gmi:nova:xdoc"> <xdoc_template_id>5</xdoc_template_id> <perform_commit_automatically>true</perform_commit_automatically> </prepare>' as code, 2 as vrstni_red union select '<prepare xmlns="urn:gmi:nova:xdoc"> <xdoc_template_id>6</xdoc_template_id> <perform_commit_automatically>true</perform_commit_automatically> </prepare>' as code, 3 as vrstni_red ) a order by a.vrstni_red asc	
5. Edoc 1. obdelava	5. Edoc 1. obdelava		<split_file xmlns='urn:gmi:nova:edoc-engine' />
6. Edoc 2. obdelava	6. Edoc 2. obdelava		<export_file xmlns='urn:gmi:nova:edoc-engine' />
7. Epps izvoz datotek	7. Epps izvoz datotek		<epps_zip_and_send_to_ws xmlns="urn:gmi:nova:si_nlb">  <edoc_channels>EDOC_EPPS</edoc_channels>  <edoc_channels>EDOC_EPPS_ODPOVED</edoc_channels>  <edoc_channels>EDOC_EPPS2</edoc_channels>  <mailTo>izterjava@nlbleasego.si</mailTo>  </epps_zip_and_send_to_ws>

1. 
Već imaju job
Automatska priprema opomena
DECLARE @target_date datetime, @id_za_opom varchar(1000)

SELECT @target_date = dbo.gfn_GetDatePart(getdate())

SET @id_za_opom = (SELECT id_za_opom_type FROM dbo.za_opom_type FOR XML PATH('reminder_types'))

SELECT 
'<reminders_generate xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:leasing">
<dat_prip>' + CONVERT(varchar(100), @target_date, 126) + '</dat_prip>
	' + @id_za_opom + '
</reminders_generate>'
WHERE @target_date <> dbo.gfn_FirstWorkDay(dbo.gfn_GetFirstDayOfMonth(@target_date))

<reminders_generate xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:leasing"> <dat_prip>2023-03-13T00:00:00</dat_prip>  <reminder_types><id_za_opom_type>1</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>5</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>6</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>7</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>8</id_za_opom_type></reminder_types><reminder_types><id_za_opom_type>9</id_za_opom_type></reminder_types> </reminders_generate>


2.
Da se podesi da se u 2. jobu koji generira opomene, da se pokrene sljedeći job (4. ) koji ispisuje opomene ?
issue_reminders_nlb_wrapper se izvršava ako nema opomena, možda bolje da se okine isti element bez LIST => u oba slučajeva bez liste se javlja ERROR 
GMI.Core.GmiException: Error while handling ProcessXml request: The element 'issue_reminders' in namespace 'urn:gmi:nova:leasing' has invalid child element 'id_opom_list_as_string' in namespace 'urn:gmi:nova:leasing'.
pa bi trebalo podesiti da vrati ili prazno (TESTIRATI) ili bez redova (ovo je sigurno u redu)

na kraju liste budu dva znaka <</issue_reminders> => da li je to bug?
Select  isnull( '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' 
		+ '<' + replace(replace(replace(SUBSTRING(  
				(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
				FROM dbo.za_opom    
				where st_opomina in (1,2,3)    
				and oznacen = 0    
				FOR XML PATH('')   )
			, 2 , 9999),'&lt;','<'),'&gt;','>'),'lt;','') 
		+ '</issue_reminders>'
	,  '<issue_reminders_nlb_wrapper xmlns="urn:gmi:nova:si_nlb">  <with_costs>true</with_costs>  <id_opom_list_as_string></id_opom_list_as_string> </issue_reminders_nlb_wrapper>' )
	<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs><list>17675369</list> <list>17675370</list> <list>17675371</list> <list>17675372</list> <list>17675373</list> <list>17675374</list> <list>17675378</list> <list>17675380</list> <list>17675381</list> <list>17675382</list> <list>17675383</list> 
	...
	<list>17675670</list> <list>17675671</list> <list>17675672</list> <list>17675674</list> <list>17675675</list> <list>17675676</list> <list>17675677</list> <list>17675678</list> <list>17675679</list> <list>17675680</list> <</issue_reminders>

SUBSTRING je do 9999 !? => bolje je koristiti STUFF

Da li se lista cijepa ili idu svi?? ili izdavati jednu po jednu ? 
Jer na NOVA_TEST sam imao 7000 zapisa (realno neće nikada biti tako, ali nisu se mogli svi kandidati prikazati u Result (samo do 65000 znakova) 
=> pogledao u FOXu i lista se kreira za sve (ne cijepa se) pa bi iz kroz SQL trebalo biti ok => TESTIRAO MOŽE PREKO 7000 ZAPISA
=> Testirao i kada nema kandidata za izdavanje, javlja se greška ako nema kandidata jer mora biti neku processXML (ne može biti NULL ili prazan string '' ili bez list elementa npr. <issue_reminders xmlns="urn:gmi:nova:si_nlb">  <with_costs>true</with_costs>  <id_opom_list_as_string></id_opom_list_as_string> </issue_reminders>)
Tako da bi trebalo kroz XDOC ili naći neki Processxml koji "ništa ne radi" 
Svakako treba hendlat i takav slučaj da nema ProcessXml-a => hendlano je tako da ide IF vidi ispod
--DORAĐENI 
declare @broj_opomena int = (SELECT count(*) as broj_opomena FROM dbo.za_opom where st_opomina in (1,2,3) and isnull(dok_opom, '') = '')  --and oznacen = 0

if @broj_opomena > 0 
begin
Select  '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' 
		+ '<' + replace(replace(replace(STUFF(  
				(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
				FROM dbo.za_opom    
				where st_opomina in (1,2,3)    
				--and oznacen = 0
				and isnull(dok_opom, '') = ''
				order by st_opomina, id_opom
				FOR XML PATH(''))
			, 1, 1, ''),'&lt;','<'),'&gt;','>'),'lt;','') 
		+ '</issue_reminders>'
end	

-- BEZ STUFF PRIMJER
--declare @broj_opomena int = (SELECT count(*) as broj_opomena FROM dbo.za_opom where st_opomina in (1,2,3) and isnull(dok_opom, '') = '')  --and oznacen = 0

if @broj_opomena > 0 
begin
Select  '<issue_reminders xmlns="urn:gmi:nova:leasing"><with_costs>true</with_costs>' 
		+ replace(replace(replace(
				(SELECT '<list>' + cast(ID_OPOM as varchar) + '</list>' AS 'data()'      
				FROM dbo.za_opom    
				where st_opomina in (1,2,3)    
				--and oznacen = 0
				and isnull(dok_opom, '') = ''
				order by st_opomina, id_opom
				FOR XML PATH(''))
			,'&lt;','<'),'&gt;','>'),'lt;','') 
		+ '</issue_reminders>'
end	

4.
Nakon izdavanja, renderiranje bi trebalo ići kroz event ili je ipak bolje rješenje XDOC? => ako je Invoice u eventu, onda bi možda bilo bolje da kroz event idu i opomene bez troška (event ReminderWithNoCostAfterIssue )




Izdavanje i renderiranje opomena kroz aplikaciju (NOVA_TEST RLC)

{f84a4345-5c8e-41f4-9f23-f394fc8cbe8e}
************
<?xml version='1.0' encoding='utf-8'?>
<render_report2  xmlns='urn:gmi:nova:core'>
<wait_to_finish>false</wait_to_finish>
<return_rendered_data>true</return_rendered_data>
<return_data_to_memory>false</return_data_to_memory>
<document>
<report_name>OPOMIN</report_name>
<object_id>17673005</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>OPOMIN</report_name>
<object_id>17672490</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<print_settings><skip_preview>false</skip_preview>
</print_settings></render_report2>
************
<cookie>{cc2c2032-f2f8-4898-b8ff-89514ddbeee4}</cookie>
___________________________________________________
{f84a4345-5c8e-41f4-9f23-f394fc8cbe8e}
************
<issue_reminders xmlns='urn:gmi:nova:leasing'>
<with_costs>true</with_costs>
<list>17673005</list><list>17672490</list>
</issue_reminders>
************