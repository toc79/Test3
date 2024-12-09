select * from dbo.CUSTOM_SETTINGS where code like '%mail%' or tags like '%mail%'

select * from dbo.CUSTOM_SETTINGS where code in ('DEFAULT_MAIL_IN_TEST_ENVIRONMENT', 'REDIRECT_MAIL_IN_TEST_ENVIRONMENT', 'Gmi.Nova.Mail.AlternativeSysFrom', 'NOVA_SYS_EMAIL_ADMIN', 'nova_sys_email_counters', 'NOVA_SYS_EMAIL_FROM', 'NOVA_SYS_EMAIL_INTERNAL_DOMAIN', 
'nova_sys_email_use_ssl', 'nova_sys_mail_regex_pattern', 'nova_sys_mail_send_or_sending', 'NOVA_SYS_MAIL_SERVER_DOMAIN', 'NOVA_SYS_MAIL_SERVER_PWD', 'NOVA_SYS_MAIL_SERVER_UN', 'nova_sys_mail_server_use_anonymous_auth', 'nova_sys_mail_smtp_port', 'nova_sys_mail_smtp_server',
'message_validity_period', 'nova_sys_email_use_template')

select top 20 * from dbo.mail order by mail_id desc

/*
Poštovani,
Prosleðujem parametre za email nalog koji æe se koristiti za slanje notifikacija iz NOVA sistema za SLBH.
user: nova_ba@scania.ba
pass: Sc4n1a!b1h-2022
Exchange Online (Plan 1)
SMTP:
Server/smart host: smtp.office365.com
Port: Port 587 (recommended) or port 25
TLS/ StartTLS: Enabled
Molim vas za proveru i potvrdu.
*/

begin tran
update dbo.CUSTOM_SETTINGS set val = 'scania.ba' where code = 'REDIRECT_MAIL_IN_TEST_ENVIRONMENT' --domene samo --;gemicro.hr
update dbo.CUSTOM_SETTINGS set val = 'scania.leasing@scania.ba' where code = 'DEFAULT_MAIL_IN_TEST_ENVIRONMENT'

update dbo.CUSTOM_SETTINGS set val = 'scania.leasing@scania.ba' where code = 'NOVA_SYS_EMAIL_ADMIN'
--update dbo.CUSTOM_SETTINGS set val = 'podpora@gmi.si' where code = 'nova_sys_email_counters' veæ podešeno eventualno ako treba dodati gemicro@gemicro.hr
update dbo.CUSTOM_SETTINGS set val = 'scania.leasing@scania.ba' where code = 'NOVA_SYS_EMAIL_FROM'
update dbo.CUSTOM_SETTINGS set val = 'scania.ba' where code = 'NOVA_SYS_EMAIL_INTERNAL_DOMAIN'
-- nedostaje INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('nova_sys_email_use_ssl', 'true', 'use SSL', 'Mail', 0) -- ili false
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('nova_sys_email_use_ssl', 'true', 'use SSL', 'Mail', 0) -- ili false
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('NOVA_SYS_MAIL_SERVER_DOMAIN', 'scania.ba', '', 'Mail', 0)
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('NOVA_SYS_MAIL_SERVER_PWD', 'sC4n1a2023l34s1ng!', '', 'Mail', 0)
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('NOVA_SYS_MAIL_SERVER_UN', 'scania.leasing@scania.ba', '', 'Mail', 0)
update dbo.CUSTOM_SETTINGS set val = '587' where code = 'nova_sys_mail_smtp_port'
update dbo.CUSTOM_SETTINGS set val = 'smtp.office365.com' where code = 'nova_sys_mail_smtp_server'
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('nova_sys_email_use_template', 'true', 'Lokacija predloška ...\AppServer\config\emailTemplate', 'Mail', 0)

-- p_kontakt_vloga
INSERT INTO dbo.p_kontakt_vloga(id_vloga,sifra,opis,obv_id_kupca,samo_en_akt,obv_email,obv_gsm,neaktiven,obv_trr,obv_naziv,za_nepopoln) VALUES('01','MAIL','Slanje obavijesti/rata na mail',0,1,1,0,0,0,0,0)

--samo na NOVA_TEST
update dbo.CUSTOM_SETTINGS set val = 'scania.ba;gemicro.hr;scania.com' where code = 'REDIRECT_MAIL_IN_TEST_ENVIRONMENT' --domene samo --;gemicro.hr
rollback

-- BACKUP

CODE	VAL	DESCRIPTION	TAGS	SENSITIVE_DATA
"DEFAULT_MAIL_IN_TEST_ENVIRONMENT"	"scania.leasing@scania.ba"	"Privzet email naslov za pošiljanje mailov iz testnega okolja."	"Mail"	.F.
"Gmi.Nova.Mail.AlternativeSysFrom"	""	"alternative from mail used in module urage report."	"Mail"	.F.
"message_validity_period"	"30"	"Max days after mail message creation that we try to send it to the recepient"	"Mail"	.F.
"NOVA_SYS_EMAIL_ADMIN"	"scania.leasing@scania.ba"	"Administrator's email address"	"Mail"	.F.
"nova_sys_email_counters"	"podpora@gmi.si"	"Email address for sending counters for module usage"	"Mail"	.F.
"NOVA_SYS_EMAIL_FROM"	"scania.leasing@scania.ba"	"Default "From" email address"	"Mail"	.F.
"NOVA_SYS_EMAIL_INTERNAL_DOMAIN"	"scania.ba"	"Internal email domain"	"Mail"	.F.
"nova_sys_email_use_ssl"	"true"	"use SSL"	"Mail"	.F.
"nova_sys_email_use_template"	"true"	"Lokacija predloška C:\Gemicro\NOVA_TEST_SCB\AppServer\config\emailTemplate"	"Mail"	.F.
"nova_sys_mail_regex_pattern"	"\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b"	"Regex pattern"	"Mail"	.F.
"nova_sys_mail_send_or_sending"	"false"	"Should app check if mail is in process of sending or alteray send before send"	"Mail"	.F.
"NOVA_SYS_MAIL_SERVER_DOMAIN"	"scania.ba"	"Mail"	"0"	.F.
"NOVA_SYS_MAIL_SERVER_PWD"	"sC4n1a2023l34s1ng!"	"Mail"	"0"	.F.
"NOVA_SYS_MAIL_SERVER_UN"	"scania.leasing@scania.ba"	"Mail"	"0"	.F.
"nova_sys_mail_server_use_anonymous_auth"	"false"	"Setting if anonymous authentication is used for smtp server"	"Mail"	.F.
"nova_sys_mail_smtp_port"	"587"	"Setting for smtp port"	"Mail"	.F.
"nova_sys_mail_smtp_server"	"smtp.office365.com"	"Setting for smtp server"	"Mail"	.F.
"REDIRECT_MAIL_IN_TEST_ENVIRONMENT"	"scania.ba;gemicro.hr"	"Domene na katere se lahko pošiljajo emaili iz testnega okolja. Domene se loèijo s simbolom ;"	"Mail"	.F.



CODE	VAL	DESCRIPTION	TAGS	SENSITIVE_DATA
"code_nova_mail_att_removed"	"File removed from email for security reasons:"	"Text to include when removing attachment from email"	"Mail"	.F.
"Css.Email.From"	""	"Defined email address from which will be send Css mail."	"Mail"	.F.
"Css.Email.To"	""	"GMI recipent CSS mail address."	"Mail"	.F.
"DEFAULT_MAIL_IN_TEST_ENVIRONMENT"	"scania.leasing@scania.ba"	"Privzet email naslov za pošiljanje mailov iz testnega okolja."	"Mail"	.F.
"DWC_IMPORT_ADMIN_MAIL"	""	"Email address for sending dwc import errors."	"Dwc; Mail"	.F.
"DWC_SYNC_LESSEE_SKIP_DOCUMENTATION_MAIL_NOTIFICATION"	"0"	"Do you want to skip sending mail to Lessee users when new documentation arrives on Nova Portal."	"Dwc; Mail"	.F.
"Gmi.Nova.Mail.AlternativeSysFrom"	""	"alternative from mail used in module urage report."	"Mail"	.F.
"HR.ZSPNFT.MAIL_TO"	""	"Mail address for mail sent after instance cloning."	"Gemicro; Mail"	.F.
"HR.ZSPNFT.USE_MAIL"	"0"	"Is mail sent after instance cloning."	"Gemicro; Mail"	.F.
"HR_OTP.ImportExRates.WarrningMail"	""	"Mail_to used in import exchage rates functionality for warning mail"	"OTP"	.F.
"message_validity_period"	"30"	"Max days after mail message creation that we try to send it to the recepient"	"Mail"	.F.
"Nova.CustomExt.Si_DH.IFRS9.Input.Preparation.MailTo"	""	"Komu vse pošljemo e-pošto z rezultatom zaganjanja IFRS9 Input Preparation vtiènika. S podpièji loèen seznam."	"Custom; DH; IFRS9"	.F.
"Nova.LE.PartnerEmailCheck"	"UTF8SMTP"	"E-mail check: UTF8SMTP - allow UTF8 characters; ASCII - allow only ASCII characters"	"Customer; Partner; Mail"	.F.
"NOVA_SYS_EMAIL_ADMIN"	"scania.leasing@scania.ba"	"Administrator's email address"	"Mail"	.F.
"nova_sys_email_counters"	"podpora@gmi.si"	"Email address for sending counters for module usage"	"Mail"	.F.
"NOVA_SYS_EMAIL_FROM"	"scania.leasing@scania.ba"	"Default "From" email address"	"Mail"	.F.
"NOVA_SYS_EMAIL_INTERNAL_DOMAIN"	"scania.ba"	"Internal email domain"	"Mail"	.F.
"nova_sys_email_use_ssl"	"true"	"use SSL"	"Mail"	.F.
"nova_sys_email_use_template"	"true"	"Lokacija predloška C:\Gemicro\NOVA_TEST_SCB\AppServer\config\emailTemplate"	"Mail"	.F.
"nova_sys_mail_regex_pattern"	"\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b"	"Regex pattern"	"Mail"	.F.
"nova_sys_mail_send_or_sending"	"false"	"Should app check if mail is in process of sending or alteray send before send"	"Mail"	.F.
"NOVA_SYS_MAIL_SERVER_DOMAIN"	"scania.ba"	"Mail"	"0"	.F.
"NOVA_SYS_MAIL_SERVER_PWD"	"sC4n1a2023l34s1ng!"	"Mail"	"0"	.F.
"NOVA_SYS_MAIL_SERVER_UN"	"scania.leasing@scania.ba"	"Mail"	"0"	.F.
"nova_sys_mail_server_use_anonymous_auth"	"false"	"Setting if anonymous authentication is used for smtp server"	"Mail"	.F.
"nova_sys_mail_smtp_port"	"587"	"Setting for smtp port"	"Mail"	.F.
"nova_sys_mail_smtp_server"	"smtp.office365.com"	"Setting for smtp server"	"Mail"	.F.
"NovaOnline.Dummy.Email.Domain"	"@gmi-dummymail.si"	"Dummy email domain for lessee users that do not have an e-mail address."	"NovaOnline"	.F.
"REDIRECT_MAIL_IN_TEST_ENVIRONMENT"	"scania.ba;gemicro.hr"	"Domene na katere se lahko pošiljajo emaili iz testnega okolja. Domene se loèijo s simbolom ;"	"Mail"	.F.
"SEND_MAIL_FOR_CONTRACT"	"TRUE"	"Send password mail after inserting new contract (true/false)"	"Mail; Contract"	.F.
"Si.Summit.SAS.Input.Preparation.Job.MailTo"	"klemenv.gmi@gmail.com"	"Custom setting for SAS Input Preparation job."	"Custom; Summit; Mail"	.F.
"SISBIZ_MAIL_SUBJECT"	"SISBIZ NAPAKE - zavrnjeni podatki BS"	"Obvestilo Sisbiz zavrnjeni podatki BS"	"Sisbiz; Mail"	.F.
"SISBIZ_MAIL_TO"	""	"Prejemniki Sisibiz mejla o zavrnjenih podatkih BS"	"Sisbiz; Mail"	.F.


/*

STARO


begin tran
update dbo.CUSTOM_SETTINGS set val = 'scania.ba' where code = 'REDIRECT_MAIL_IN_TEST_ENVIRONMENT' --domene samo --;gemicro.hr
update dbo.CUSTOM_SETTINGS set val = 'nova_ba@scania.ba' where code = 'DEFAULT_MAIL_IN_TEST_ENVIRONMENT'

update dbo.CUSTOM_SETTINGS set val = 'nova_ba@scania.ba' where code = 'NOVA_SYS_EMAIL_ADMIN'
--update dbo.CUSTOM_SETTINGS set val = 'podpora@gmi.si' where code = 'nova_sys_email_counters' veæ podešeno eventualno ako treba dodati gemicro@gemicro.hr
update dbo.CUSTOM_SETTINGS set val = 'nova_ba@scania.ba' where code = 'NOVA_SYS_EMAIL_FROM'
update dbo.CUSTOM_SETTINGS set val = 'scania.ba' where code = 'NOVA_SYS_EMAIL_INTERNAL_DOMAIN'
-- nedostaje INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('nova_sys_email_use_ssl', 'true', 'use SSL', 'Mail', 0) -- ili false
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('NOVA_SYS_MAIL_SERVER_DOMAIN', 'scania.ba', '', 'Mail', 0)
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('NOVA_SYS_MAIL_SERVER_PWD', 'Sc4n1a!b1h-2022', '', 'Mail', 0)
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('NOVA_SYS_MAIL_SERVER_UN', 'scania.ba\nova_ba', '', 'Mail', 0)
update dbo.CUSTOM_SETTINGS set val = '587' where code = 'nova_sys_mail_smtp_port'
update dbo.CUSTOM_SETTINGS set val = 'smtp.office365.com' where code = 'nova_sys_mail_smtp_server'
INSERT INTO dbo.custom_settings (code, val, description, tags, sensitive_data) VALUES ('nova_sys_email_use_template', 'true', 'Lokacija predloška ...\AppServer\config\emailTemplate', 'Mail', 0)
rollback


-- Isto kao iznad ali bez kolone sensitive_data
begin tran
--update dbo.CUSTOM_SETTINGS set val = 'scania.ba;gemicro.hr' where code = 'REDIRECT_MAIL_IN_TEST_ENVIRONMENT' --domene samo
update dbo.CUSTOM_SETTINGS set val = 'scania.ba' where code = 'REDIRECT_MAIL_IN_TEST_ENVIRONMENT' --domene samo
update dbo.CUSTOM_SETTINGS set val = 'nova_ba@scania.ba' where code = 'DEFAULT_MAIL_IN_TEST_ENVIRONMENT'

update dbo.CUSTOM_SETTINGS set val = 'nova_ba@scania.ba' where code = 'NOVA_SYS_EMAIL_ADMIN'
--update dbo.CUSTOM_SETTINGS set val = 'podpora@gmi.si' where code = 'nova_sys_email_counters' veæ podešeno eventualno ako treba dodati gemicro@gemicro.hr
update dbo.CUSTOM_SETTINGS set val = 'nova_ba@scania.ba' where code = 'NOVA_SYS_EMAIL_FROM'
update dbo.CUSTOM_SETTINGS set val = 'scania.ba' where code = 'NOVA_SYS_EMAIL_INTERNAL_DOMAIN'
INSERT INTO dbo.custom_settings (code, val, description, tags) VALUES ('nova_sys_email_use_ssl', 'true', 'use SSL', 'Mail')
INSERT INTO dbo.custom_settings (code, val, description, tags) VALUES ('NOVA_SYS_MAIL_SERVER_DOMAIN', 'scania.ba', 'Mail', 0)
INSERT INTO dbo.custom_settings (code, val, description, tags) VALUES ('NOVA_SYS_MAIL_SERVER_PWD', 'Sc4n1a!b1h-2022', 'Mail', 0)
--INSERT INTO dbo.custom_settings (code, val, description, tags) VALUES ('NOVA_SYS_MAIL_SERVER_UN', 'scania.ba\nova_ba', 'Mail', 0)
INSERT INTO dbo.custom_settings (code, val, description, tags) VALUES ('NOVA_SYS_MAIL_SERVER_UN', 'nova_ba@scania', 'Mail', 0)
update dbo.CUSTOM_SETTINGS set val = '587' where code = 'nova_sys_mail_smtp_port'
update dbo.CUSTOM_SETTINGS set val = 'smtp.office365.com' where code = 'nova_sys_mail_smtp_server'
rollback
--commit

update dbo.CUSTOM_SETTINGS set val = 'scania.leasing@scania.ba' where code = 'NOVA_SYS_MAIL_SERVER_UN'
update dbo.CUSTOM_SETTINGS set val = 'sC4n1a2023l34s1ng!' where code = 'NOVA_SYS_MAIL_SERVER_PWD'

update dbo.CUSTOM_SETTINGS set val = 'scania.leasing@scania.ba' where code = 'DEFAULT_MAIL_IN_TEST_ENVIRONMENT'
update dbo.CUSTOM_SETTINGS set val = 'scania.leasing@scania.ba' where code = 'NOVA_SYS_EMAIL_ADMIN'
update dbo.CUSTOM_SETTINGS set val = 'scania.leasing@scania.ba' where code = 'NOVA_SYS_EMAIL_FROM'
*/
TTL ima i 
nova_sys_email_use_template

TTL nema NOVA_SYS_MAIL_SERVER_DOMAIN
/*
<insert_mail xmlns="urn:gmi:nova:core"><from>tomislav.krnjak@gemicro.hr</from><to>tomislav.krnjak@gemicro.hr</to><cc></cc><subject>Test INSERT_MAIL</subject><body>Aktiviranje ugovora</body><body_is_html>true</body_is_html><send_immediately>true</send_immediately></insert_mail>

<insert_mail xmlns="urn:gmi:nova:core"><from>nova_ba@scania.ba</from><to>nova_ba@scania.ba</to><cc></cc><subject>Test INSERT MAIL</subject><body>TEST body</body><body_is_html>true</body_is_html><send_immediately>true</send_immediately></insert_mail>
*/

<insert_mail xmlns="urn:gmi:nova:core"><from>scania.leasing@scania.ba</from><to>scania.leasing@scania.ba</to><cc></cc><subject>Test INSERT MAIL</subject><body>TEST body</body><body_is_html>true</body_is_html><send_immediately>true</send_immediately></insert_mail>

<insert_mail xmlns="urn:gmi:nova:core"><from>scania.leasing@scania.ba</from><to>tomislav.krnjak@gemicro.hr</to><cc></cc><subject>Test INSERT MAIL</subject><body>TEST body</body><body_is_html>true</body_is_html><send_immediately>true</send_immediately></insert_mail>

System.Net.Mail.SmtpException: The SMTP server requires a secure connection or the client was not authenticated. The server response was: 5.7.57 Client not authenticated to send mail. Error: 535 5.7.3 Authentication unsuccessful [FR0P281CA0108.DEUP281.PROD.OUTLOOK.COM]     at System.Net.Mail.MailCommand.CheckResponse(SmtpStatusCode statusCode, String response)     at System.Net.Mail.MailCommand.Send(SmtpConnection conn, Byte[] command, MailAddress from, Boolean allowUnicode)     at System.Net.Mail.SmtpTransport.SendMail(MailAddress sender, MailAddressCollection recipients, String deliveryNotify, Boolean allowUnicode, SmtpFailedRecipientException& exception)     at System.Net.Mail.SmtpClient.Send(MailMessage message)     at GMI.Core.GMI_LegoSendMailSingle.SendMail(Tab_Mail mail)     at GMI.Core.GMI_LegoSendMailSingle.PrepareSingleMail()


