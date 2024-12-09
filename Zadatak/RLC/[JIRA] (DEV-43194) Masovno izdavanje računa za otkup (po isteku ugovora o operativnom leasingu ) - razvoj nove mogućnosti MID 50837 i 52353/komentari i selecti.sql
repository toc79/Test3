
--insert into dbo.EXT_FUNC (ID_EXT_FUNC, code, id_ext_func_type, inactive, onform) values ('Sys.EventHandler.ProcessXml.Invoice.Issued', '',  'SQL_CS', 0, null)

insert into dbo.EXT_FUNC (ID_EXT_FUNC, code, id_ext_func_type, inactive, onform) values ('Sys.EventHandler.ProcessXmlQ.Invoice.Issued', '',  'SQL_CS', 0, null)

INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) VALUES('RLC_GENERATE_GENERAL_INVOICES','Import gen1eral invoices for Third party contracts from predefined XLTX template','\\RLENOVAAPP-P\nova_prod_IO\RLC_GENERATE_GENERAL_INVOICES','',0,NULL,NULL,NULL)



select status_akt, * from dbo.pogodba where id_pog in ('71213/23','71203/23','71204/23','71205/23')
--grp_GetGeneralInvoiceRecord 

exec dbo.grp_getgeneralinvoicerecord '001643/24'

\\RLENOVAAPP-P\nova_prod_IO\RL_PROVISIONS_NRT_IMPORT\

select prevzeta, dbo.gfn_Id_cont4Id_pog(prevzeta) as prevzeta_id_cont
	, f.*, pog.*
from dbo.pogodba pog
inner join dbo.fakture f on pog.id_cont = f.id_cont -- event ide prije zapisivanja ddv_id-a u dbo.fakture i planp pa je korišten queue event
where pog.nacin_leas = 'TP' 
and f.id_terj = '31'
and f.ddv_id = @ddv_id



koliko sam vidio ne kreira se novi zapisnik na TP ugovoru?
na na ZAP_NER se kreira?


	select *
	from dbo.zap_ner zn 
	where zn.id_cont in (@prevzeta_id_cont, @id_cont_third_party)
	and exists (select id_zapo from dbo.oprema o where o.prodano = 0 and zn.id_zapo = o.id_zapo)
	--group by zn.id_zapo



select ide iz zahtjeva
C:\Users\tomislav.krnjak\Documents\Zadatak\ESL\ERROR - Izvoz podataka (Xdoc) 50 - ROL - označavanje prodanim objekata FL ugovora MID 50422

select * from dbo.io_channels

RLC_GENERATE_GENERAL_INVOICES
exec dbo.Tsp_generate_inserts @t_name = 'io_channels'
select * from ##inserts

begin tran
delete from dbo.io_channels where channel_code = 'RLC_GENERATE_GENERAL_INVOICES'
INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) VALUES('RLC_GENERATE_GENERAL_INVOICES','Import gen1eral invoices for Third party contracts from predefined XLTX template','\\RLENOVAAPP-T\NOVA_TEST_IO\RLC_GENERATE_GENERAL_INVOICES','',0,NULL,NULL,NULL)
--commit


select top 20 id_cont, id_cont_third_party, nacin_leas_third_party, ddv_id, * from dbo.fakture where id_terj = '31' and DATUM_DOK >= '20230101' order by datum_dok desc
select * from dbo.zap_ner where ID_ZAPO = 'N009652'
select * from dbo.oprema where ID_ZAPO = 'N009652'



select nacin_leas , * from dbo.pogodba where id_cont = 76441

select nacin_leas , * 
from dbo.pogodba pog 
where nacin_leas = 'OF'
and status_akt = 'A'
and not exists (select * from dbo.fakture where id_terj = '31'and id_cont = pog.id_cont)
and exists (select * from dbo.zap_ner where id_cont = pog.ID_CONT)
order by id_cont desc

select * from dbo.fakture where id_cont = 76441


select * from dbo.zap_reg where id_zapo = 'R065993'

select * from dbo.queue_pending

select * from dbo.zap_ner where id_zapo = 'N009635'
select * from dbo.oprema where id_zapo = 'N009635'




--PROCESSXML

{5ac934f2-1da9-4b53-baea-719d67197c8f}
************
<generate_general_invoices xmlns='urn:gmi:nova:hr_raiffeisen'>
<issue_invoice_new_third_party_contract>true</issue_invoice_new_third_party_contract>
</generate_general_invoices>
************
<cookie>{8ed70582-2c72-4a87-8c5b-0c1849470c52}</cookie>
___________________________________________________
{5ac934f2-1da9-4b53-baea-719d67197c8f}
************
<blox_info xmlns='urn:gmi:nova:core'>
<blox>
<code>generate_general_invoices</code>
<xml_namespace>urn:gmi:nova:hr_raiffeisen</xml_namespace>
</blox>
</blox_info>

************
<?xml version="1.0" encoding="utf-16"?>
<blox_info_response xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <description />
  <parameter>
    <name>issue_invoice_new_third_party_contract</name>
    <type>Boolean</type>
    <description>Izdaj račun za novi fiktivni ugovor</description>
  </parameter>
</blox_info_response>
