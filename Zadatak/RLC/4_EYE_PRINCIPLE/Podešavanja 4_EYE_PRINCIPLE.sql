
begin tran
UPDATE custom_settings set val='1' where code='Nova.LE.4EyePrincip.ContractVerify'
UPDATE custom_settings set val='1' where code='Nova.LE.4EyePrincip.ContractSpecific'
UPDATE custom_settings set val='true' where code='Nova.LE.4EyePrincip.Invoice_upd_issue'
UPDATE custom_settings set val='true' where code='Nova.Gl.4EyePrincip.GlKDnevTransfer'

select * from custom_settings where code like '%4EyePrincip%'
--commit 

U 2.19 su sve postavke sa TRUE tj. 

begin tran
UPDATE custom_settings set val='true' where code='Nova.LE.4EyePrincip.ContractVerify'
UPDATE custom_settings set val='true' where code='Nova.LE.4EyePrincip.ContractSpecific'
UPDATE custom_settings set val='true' where code='Nova.LE.4EyePrincip.Invoice_upd_issue'
UPDATE custom_settings set val='true' where code='Nova.Gl.4EyePrincip.GlKDnevTransfer'

select * from custom_settings where code like '%4EyePrincip%'
select * from custom_settings  where code='Nova.App.KontrolingPlacevanjaApp'


--APP
UPDATE custom_settings set val='true' where code='Nova.App.KontrolingPlacevanjaApp'

--commit 

--RAČUN ZA OTKUP
Custom_settings = "Nova.LE.4EyePrincip.InvoiceIssueBuyout" 
licenca = 4_EYE_PRINCIP_INVOICE_ISSUE_BUYOUT