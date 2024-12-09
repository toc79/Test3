
-- RLC podešavanje
--update dbo.p_kontakt_vloga set opis = 'Klijenti kojima se šalju računi/obavijesti na mail' where sifra = 'MAIL'  NISAM PODESIO jer je naziv Klijenti kojima se šalju dokumenti na mail

-- Provjeriti id_xdoc_template da li će na produkciji biti isti
INSERT INTO dbo.EDOC_CHANNEL(id_edoc_channel,description,io_channel_code,active,handler_class,handler_params,is_batch_export,files_must_be_signed,GDPR_relevant,id_export_destination) VALUES('EDOC_EX6','Export chanel to mail (Invoice LOBR)','EDOC_EXPORT',1,'GMI.EdocEngine.EdocToXdocExporterBatch,gmi_edoc_engine','id_xdoc_template=60;',1,0,NULL,NULL)

INSERT INTO dbo.edoc_processing_plugin(execution_order,handler_class,additional_params,active) VALUES(4,'GMI.EdocEngine.SignPdfPlugin,gmi_edoc_engine','filter_metadata_field=pdf_sign;filter_metadata_value=0;sign_metadata_xml=false;throw_exception=true;cert_file=\\Rlenovaapp-p\nova_prod\AppServer\config\e-racun-prod.rl-hr.hr.p12;cert_pwd=Leasing1;',1)
--JOŠ JEDNOM KREIRATI NOVU SKRIPTU I POPRAVITI PUTANJE
--INSERT INTO dbo.edoc_processing_plugin(execution_order,handler_class,additional_params,active) VALUES(2,'GMI.EdocEngine.SignPdfPlugin,gmi_edoc_engine','filter_metadata_field=pdf_sign;filter_metadata_value=0;sign_metadata_xml=false;throw_exception=true;cert_file=\\RLENOVAAPP-t\NOVA_TEST\AppServer\config\e-racun-test.rl-hr.hr.p12;cert_pwd=Leasing1;',1)
--filter_metadata_field=pdf_sign;filter_metadata_value=0;sign_metadata_xml=false;throw_exception=true;cert_file=\\RLENOVAAPP-t\NOVA_TEST\AppServer\config\e-racun-test.p12;cert_pwd=Leasing1;
--\\Rlenovaapp-p\nova_prod\AppServer\config

filter_metadata_field=pdf_sign;filter_metadata_value=0;sign_metadata_xml=false;throw_exception=true;cert_file=\\Rlenovaapp-p\nova_prod\AppServer\config\e-racun-prod.rl-hr.hr.p12;cert_pwd=Leasing1;

filter_metadata_field=pdf_sign;filter_metadata_value=0;sign_metadata_xml=false;throw_exception=true;cert_file=\\Rlenovaapp-p\nova_prod\AppServer\config\e-racun-prod.rl-hr.hr.p12;cert_pwd=Leasing1;

filter_metadata_field=pdf_sign;filter_metadata_value=0;sign_metadata_xml=false;throw_exception=true;cert_file=d:\nova_prod\AppServer\config\e-racun-prod.rl-hr.hr.p12;cert_pwd=Leasing1;

d:\nova_prod\IO\FINA\MAIN\

/*
podesio sam iznad
i processing plugin
izvoz podataka koji je sada id 60

*/

Poštovana/i, 

podešavanje slanja na mail i digitalno potpisivanje PDF računa za ratu sam podesio na produkciju.
Potpisivanje PDF dokumenta ide za tip dokumenta Invoice (za račune) i za zbirne račune (InvoiceCum)

Podesio sam novi izvještaj naziva "(IT-CA) EDOC - Pregled eksporta datoteka FAZA TESTIRANJA" na kojemu su napravljene dorade po ovom zahtjevu (i dorade po zahtjevu "[JIRA] (DEV-41238) Novi zahtjev - Slanje dodatnih priloga uz e-račun kroz FINA e-račun portal").
Na ovom novom izvještaju sam napravio optimizaciju pa je prikaz podataka brži. Izvještaj sam odmah podesio na produkciji pa možete testirati prikaz podataka i na produkciji.
Izvještaj bi se mogao još podesiti da se za tip npr. 'Obavijest o promjeni indeksa' prikaže točan naziv ispisa iz opcije ispisa 'OBAVIJEST/DOPIS O INDEKSACIJI' i tako za svaki tip ispis da se prikaže naziv ispisa (umjesto hardkodiranog tipa, iznimka je naravno ispis računa za tate koji se odnosi na više potraživanja tako da za taj tip ne bi iblo promjene).

Stari izvještaj "(IT-CA) EDOC - Pregled eksporta datoteka " se i dalje može koristiti pa možete usporediti podatke, a njega bi onda deaktivirali kada potvrdite novi izvještaj "(IT-CA) EDOC - Pregled eksporta datoteka FAZA TESTIRANJA".

$SIGN






merge_pdf_docs=false;add_order_number_to_subject_on_multiple=true;add_order_number_as_suffix=true;


update dbo.CUSTOM_SETTINGS set val = 'rl-hr.hr;rba.hr;gemicro.hr;gmi.si' where code = 'REDIRECT_MAIL_IN_TEST_ENVIRONMENT' --domene samo --;gemicro.hr
update dbo.CUSTOM_SETTINGS set val = 'leasing.it@rl-hr.hr' where code = 'DEFAULT_MAIL_IN_TEST_ENVIRONMENT' --domene samo --;gemicro.hr


<insert_mail xmlns="urn:gmi:nova:core"><from>Raiffeisen Leasing_Racuni <racuni@rl-hr.hr></from><to>tomislav.krnjak@gemicro.hr</to><cc></cc><subject>Test INSERT MAIL</subject><body>TEST body</body><body_is_html>true</body_is_html><send_immediately>true</send_immediately></insert_mail>

<insert_mail xmlns="urn:gmi:nova:core"><from>racuni@rl-hr.hr</from><to>tomislav.krnjak@gemicro.hr</to><cc></cc><subject>Test INSERT MAIL</subject><body>TEST body</body><body_is_html>true</body_is_html><send_immediately>true</send_immediately></insert_mail>



-- VAŽNO moguća podešavanja
sa mearge 
- se kreira jedan PDF u mail_attachment te elektronički potpis nije valjan 

bez mearge 
može se kreirati na dva načina: 
1. da se u SQL EXPORT grupira po id_kupca => tada se kreira jedan mail i 20 maksimalno privitaka (kreira se pojedinačni/zasebni PDF-ovi u mail attachmentima, potpis je valjan)
2. da se ne grupira po id_kupca te da doc_id bude npr EDOC_EXPORTED_FILES.ID (ili documemt_id) => tada ide jedan mail jedan privitak

Dodatna rutina u slučaju više attachmenta po mailu prikaže samo 1 prvi, ostale attachmente pak ne.


select top 200 * 
from dbo.mail m
left join dbo.mail_attachment ma on m.mail_id = ma.mail_id
where m.id_kupca is not null
--and m.id_kupca = '031473'
order by m.mail_id desc
-- update dbo.mail set mail_to = 'tomislav.krnjak@gemicro.hr' where mail_id = 153218
--update dbo.mail_attachment set attachment_name = 'Račun(i) za mjesečnu ratu-obrok' where mail_id = 153218
select xd.*, eef.* 
from dbo.xdoc_template xt 
join dbo.xdoc_document xd on xt.id_xdoc_template = xd.id_xdoc_template
join dbo.EDOC_EXPORTED_FILES eef on xd.doc_id = eef.id
where xt.id_xdoc_template = 57
--and eef.id_kupca = '031473'
order by eef.id desc



-- ZA ODGOVOR KIJENTU
Poštovana/i, 
podesio sam da 
- FINA partneri nisu kandidati za slanje na mail
- idu samo potraživanja za ratu id 21 (zbirni računi nisu podešeni pa ne idu na mail)
- partneri koji imaju ulogu šifre 02 MAIL "Klijenti kojima se šalju računi/obavijesti na mail"
Slanje se pokreće automatski nakon eDoc obrade (2. obrade), a funkcionalnost je podešena u izvozu podataka 57 "eDoc to eMail exporter - Računi za ratu".
P


-- ANALIZA
Error while parsing duplicate handeling policy!

	EDOC_EX5	Export channel to mail (TaxchngIx)	EDOC_EXPORT	True	GMI.EdocEngine.EdocToXdocExporterBatch,gmi_edoc_engine	id_xdoc_template=54;	True

\\RLENOVAAPP-T\NOVA_TEST_IO\OPZ_STAT\

EDOC_DSA                      	Edoc dsa Folder	d:\NOVA_TEST\IO\edoc\edoc_dsa\
EDOC_MAIN                     	Edoc main processing folder	d:\NOVA_TEST\IO\edoc\edoc_main\

-- select  replace(channel_path, 'd:\NOVA_TEST\IO\', '\\RLENOVAAPP-T\NOVA_TEST_IO\')  as new, * from dbo.io_channels where channel_code  in ('EDOC_DSA', 'EDOC_MAIN')
-- begin tran
-- update dbo.io_channels set channel_path = replace(channel_path, 'd:\NOVA_TEST\IO\', '\\RLENOVAAPP-T\NOVA_TEST_IO\') where channel_code  in ('EDOC_DSA', 'EDOC_MAIN')
--commit
OTP
merge_pdf_docs=false;merged_pdf_file_name=SviRačuniPartnera

Export_id iz edoc_exported_files   
120


C:\GEMICRO\Proxy_prod\PROD
eRačun.cer

izvoz na mail, samo je jedan izvoz za report OBV_IND 
eDoc to eMail exporter Obavijesti o promjeni mjesečne rate

Uloga 
02 Klijenti kojima se šalju obavijesti na mail    MAIL

skripte

INSERT INTO dbo.edoc_processing_plugin(execution_order,handler_class,additional_params,active) VALUES(2,'GMI.EdocEngine.SignPdfPlugin,gmi_edoc_engine','filter_metadata_field=pdf_sign;filter_metadata_value=0;sign_metadata_xml=false;throw_exception=true;cert_file=\\sizif\nova_prod\AppServer\config\e-racun-Globus_Nova.p12;cert_pwd=Leasing1;',1)

podesiti cert_file i cert_pwd 
RLC treba nam poslati cert_file ?

Da li treba i to podešavati tj. da li se treba razlikovati od OTPa?
code	val	description	tags	sensitive_data
Nova.DigSignature.SerialNum   	3F2111BA		Certificate; eDoc	1
INSERT INTO dbo.CUSTOM_SETTINGS(code,val,description,tags,sensitive_data) VALUES('Nova.DigSignature.SerialNum','3F2111BA','','Certificate; eDoc',1)

select * from dbo.CUSTOM_SETTINGS where code = 'Nova.DigSignature.SerialNum'
INSERT INTO dbo.CUSTOM_SETTINGS(code,val,description,tags,sensitive_data) VALUES('Nova.DigSignature.SerialNum','3F2111BA','','Certificate; eDoc',1)
delete from dbo.CUSTOM_SETTINGS where code = 'Nova.DigSignature.SerialNum'

podesiti processing plugin

"- doraditi Stimulsoft ispise kako bi mogli prikazati digitalni potpis na pdf dokumentima"
što treba podesiti na ssoft reportu?


svi xdoc
id_xdoc_template	title	nova_plugin	export_parameters
22	Izvoz podataka za Mail modul - odobrenje financiranja promjena statusa	GMI.xDoc.AdvancedMailExporter	NULL
30	Slanje obavijesti e-mailom o obavezi izdavanja/ispisivanja opomena	GMI.xDoc.AdvancedMailExporter	NULL
33	eMail exporter uvoz ponuda dwc	GMI.xDoc.AdvancedMailExporter	NULL
37	Provjera grešaka Server queue pending	GMI.xDoc.AdvancedMailExporter	NULL
47	Default events report - EBA	GMI.xDoc.AdvancedMailExporter	NULL
51	SEPA izravna terećenja	GMI.xDoc.AdvancedMailExporter	NULL
52	SEPA izravna terećenja FO - XLS	GMI.xDoc.EpplusExcelExporter	overwrite_existing=false;use_mail=true;template_id=Nalozi_template;use_master_table=true;use_naming_template=true;sql_naming_template="'Nalozi_@id.xlsx'";sql_naming_parameter_column_name=datum_izvrsenja;
53	SEPA izravna terećenja PO - XLS	GMI.xDoc.EpplusExcelExporter	overwrite_existing=false;use_mail=true;template_id=Nalozi_template;use_master_table=true;use_naming_template=true;sql_naming_template="'Nalozi_@id.xlsx'";sql_naming_parameter_column_name=datum_izvrsenja;
57	eDoc to eMail exporter Obavijesti o promjeni mjesečne rate	GMI.xDoc.AdvancedMailExporter	merge_pdf_docs=true;merged_pdf_file_name=Obavijest o promjeni mjesečne rate-obroka;merged_file_count=50;add_order_number_to_subject_on_multiple=true;add_order_number_as_suffix=true;


OTP FAK_LOBR report ima podešen single pass !!!


select * from dbo.edoc_processing_plugin

select * from dbo.CUSTOM_SETTINGS where code like '%sign%'
select * from dbo.io_channels where channel_code like '%PDF%'


exec dbo.Tsp_generate_inserts 'edoc_processing_plugin', 'dbo', 'false', '##inserts', 'where id_edoc_processing_plugin = 2', 0
select * from ##inserts


-- kontakti MAIL
--imaju duplih iako je u ulogama definirano samo jedna aktivna uloga na kontaku
Select a.id_kupca From dbo.p_kontakt a inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga Where a.neaktiven = 0 and b.sifra IN ('MAIL') Group by a.id_kupca having count(*) > 1 order by id_kupca
Select * 
			From dbo.p_kontakt a 
			inner join dbo.p_kontakt_vloga b on a.id_vloga = b.id_vloga 
			Where a.neaktiven = 0 
			and b.sifra IN ('MAIL') 
and a.id_kupca in (
'011042',
'016912',
'036613',
'040634',
'041082')

			order by id_kupca
			select * from dbo.p_kontakt_vloga


--select za izvještaj

select top 5 xdrh.*, xdd.* 
from dbo.xdoc_template xdt 
join dbo.xdoc_run_history xdrh on xdt.id_xdoc_template = xdrh.id_xdoc_template
join dbo.xdoc_document xdd on xdt.id_xdoc_template = xdd.id_xdoc_template
where xdt.id_xdoc_template = 57
order by xdrh.id_xdoc_run_history desc

select top 20 * from dbo.gv_EDOC_EXPORTED_FILES_CHANNELS where id_file = 1219379 order by 1 desc
select top 20 * from dbo.edoc_processing_file_event_history where id_file_edoc = 1219379 /*id_edoc_processing_history = 4452*/ order by id desc
select top 20 * from dbo.edoc_processing_batch_event_history order by id desc

--jako mala vjerojatnost je da postoje dva ista DOC_ID-a tako da ćemo uzimati sve podatke
select top 20 * 
from dbo.EDOC_EXPORTED_FILES eef
inner join dbo.xdoc_document xdd on eef.id = xdd.doc_id
where xdd.id_xdoc_template = 57
order by id desc

select top 200 * from dbo.edoc_processing_event_history order by id desc
select top 20 * from dbo.edoc_processing_history order by id desc
