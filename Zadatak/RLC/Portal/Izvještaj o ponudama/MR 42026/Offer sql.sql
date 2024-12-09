Poštovana/i, 

za dobivanje podatka "OIB dobavljača" se radi povezivanje preko polja CORE_ID (ID iz glavnog sistema), u ovom slučaju ponude 1023 to je 023472 (koji je za dobavljača id 1306 INSIDO D.O.O.) te u podacima stranke postoje dvije različite stranke s tim istim CORE_ID: B.M.K. (šifra stranke 1384) i INSIDO (više šifri stranke). 
Za B.M.K. šifra stranke 1384 se onda prikazuje drugi zapis s drugačijim poreznim brojem (sql rezultat je našao dvije stranke za taj CORE_ID i vratio dva različita OIBa).

Razlog zašto postoji netočan CORE_ID za stranku id 1384 B.M.K. je zato što je prvotno za tu šifru bila unesena stranka INSIDO, za koju se onda napravila promjena u B.M.K. nakon što joj je bio dodijeljen CORE_ID. U privitku vam šaljemo sliku iz arhivske tabele promjena podataka stranke.

Dodatno bi napomenuli da za oba partnera imate unesene više istih stranaka, pa svakako molimo da uputite korisnike da prije unosa nove stranke naprave provjeru da li ta stranka već postoji. U privitku vam šaljemo slike stranaka INSIDO i B.M.K.

$SIGN

Poštovana/i, 

za dobivanje podatka "OIB dobavljača" se radi povezivanje preko polja CORE_ID (ID iz glavnog sistema), u ovom slučaju ponude 1023 to je 023472 (koji je za dobavljača id 1306 INSIDO D.O.O.) te u podacima stranke postoje dvije različite stranke s tim istim CORE_ID:  B.M.K. (šifra stranke 1384) i INSIDO (više šifri stranke). 
Za B.M.K. šifra stranke 1384 se onda prikazuje drugi zapis s drugačijim poreznim brojem (sql rezultat je našao dvije stranke za taj CORE_ID i vratio dva različita OIBa).
Da bi na izvještaju izlazio podatak samo za INSIDO, tada bi mi trebali napraviti 
1) ispravak podatka za stranku id 1384 da je CORE_ID = 034840 (s obzirom da je tu riječ bilo o potvrđenoj ponudi, CORE_ID ne bi smio ostati prazan).
ili 
2) doradu izvještaja da se spajanje radi prema id dobavljača.

Razlog zašto postoji netočan CORE_ID za stranku id 1384 B.M.K. je zato što je prvotno za tu šifru bila unesena stranka INSIDO, za koju se onda napravila promjena u B.M.K. nakon što joj je bio dodijeljen CORE_ID. U privitku vam šaljemo sliku iz arhivske tabele promjena podataka stranke.

Dodatno bi napomenuli da za oba partnera imate unesene više istih stranaka, pa svakako molimo da uputite korisnike da prije unosa nove stranke naprave provjeru da li ta stranka već postoji. U privitku vam šaljemo slike stranaka INSIDO i B.M.K.

U privitku vam šaljemo i ponudu za analizu te za promjenu podataka CORE_ID s 023472 na 034840.

$SIGN

--podešavanje ssoft ispisa na portalu
begin tran
UPDATE dwc_test.dbo.rep_Report SET report_file = b.report_file, last_change = b.last_change
--select a.id, b.report_file, a.*, b.*
From dwc_test.dbo.rep_Report a
Inner join dwc_prod.dbo.rep_Report b on a.id = b.id AND b.id = 3
--commit



SELECT TOP 200 P.*, O.naziv AS oprema_naziv, U.user_desc AS users_vnesel, D.naziv as naz_obd, intg_pon.intg_ext_id as intg_ext_id,
			   prodajal.id_prod1 AS id_prod1
FROM dbo.ponudba P
LEFT JOIN dbo.vrst_opr O ON P.id_vrste = O.id_vrste
LEFT JOIN dbo.users U ON P.vnesel = U.username
LEFT JOIN dbo.obdobja as D on P.id_obd = D.id_obd
LEFT JOIN dbo.intg_dsa_ponudba intg_pon on P.id_pon = intg_pon.id_pon
LEFT JOIN dbo.prodajal prodajal on prodajal.id_prod = P.id_prod
WHERE intg_pon.intg_ext_id = 1023
		 
		 

DECLARE @zero as decimal(18,2), @DatOd datetime, @DatDo datetime
SET @zero = 0

SET @DatOd = (SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0))
SET @DatDo = GETDATE()

Select DISTINCT a.id_data_offer, a.offer_date, a.object_description, a.customer_full_name, IsNULL(a.customer_tax_id, SPACE(10)) as customer_tax_id, a.user_userdesc, a.equipment_type_id, a.equip_type_title
	, a.lease_type, a.supplier_short_name
	, IsNULL(CASE WHEN c.is_pseudo_vendor = 1 THEN d.tax_id ELSE c.tax_id END, SPACE(10)) AS supplier_tax_id
	, a.currency_id, a.price_brut + a.r_interests as price_brut, a.r_interests, a.interest_rate
	, a.downpayment_percent, a.lease_period, a.manipulative_costs_amount_brut, a.ppyr_title, a.residual_value_percent, a.bail_percent
	, a.date_inserted, CASE WHEN a.id_vendor = 1 THEN 'Raiffeisenbank Austria d.d.' ELSE a.vendor_name END AS vendor, IsNULL(a.core_id, SPACE(10)) as core_id
	, b.status_description, IsNULL(c.tax_id, SPACE(10)) as vendor_tax_id
FROM dbo.gv_data_Offer a
Left join dbo.gv_wf_Document b on a.workflow_doc_id = b.id_document
Left join (Select a.id_vendor, b.tax_id, a.is_pseudo_vendor
			From dbo.admin_Vendor a
			Left join dbo.data_Customer b ON a.core_id = b.core_id) c on a.id_vendor = c.id_vendor
Left join dbo.data_Customer d ON d.core_id = a.customer_as_vendor_core_id
--WHERE a.offer_date BETWEEN @DatOd AND @DatDo



Select *
FROM dbo.gv_data_Offer a
--Left join dbo.gv_wf_Document b on a.workflow_doc_id = b.id_document
--Left join (Select a.id_vendor, b.tax_id, a.is_pseudo_vendor
--	From dbo.admin_Vendor a
--	Left join dbo.data_Customer b ON a.core_id = b.core_id) c on a.id_vendor = c.id_vendor
--Left join dbo.data_Customer d ON d.core_id = a.customer_as_vendor_core_id
-- zadnji left join to radi
WHERE a.offer_date BETWEEN '20190104' AND '20190104'

DECLARE @zero as decimal(18,2), @DatOd datetime, @DatDo datetime
SET @zero = 0

--SET @DatOd = (SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0))
--SET @DatDo = GETDATE()

Select DISTINCT a.id_data_offer, a.offer_date, a.object_description, a.customer_full_name, IsNULL(a.customer_tax_id, SPACE(10)) as customer_tax_id, a.user_userdesc, a.equipment_type_id, a.equip_type_title
	, a.lease_type, a.supplier_short_name, IsNULL(CASE WHEN c.is_pseudo_vendor = 1 THEN d.tax_id ELSE c.tax_id END, SPACE(10)) AS supplier_tax_id
	, a.currency_id, a.price_brut + a.r_interests as price_brut, a.r_interests, a.interest_rate
	, a.downpayment_percent, a.lease_period, a.manipulative_costs_amount_brut, a.ppyr_title, a.residual_value_percent, a.bail_percent
	, a.date_inserted, CASE WHEN a.id_vendor = 1 THEN 'Raiffeisenbank Austria d.d.' ELSE a.vendor_name END AS vendor, IsNULL(a.core_id, SPACE(10)) as core_id
	, b.status_description, IsNULL(c.tax_id, SPACE(10)) as vendor_tax_id
FROM dbo.gv_data_Offer a
Left join dbo.gv_wf_Document b on a.workflow_doc_id = b.id_document
Left join (Select a.id_vendor, b.tax_id, a.is_pseudo_vendor
			From dbo.admin_Vendor a
			Left join dbo.data_Customer b ON a.core_id = b.core_id) c on a.id_vendor = c.id_vendor
Left join dbo.data_Customer d ON d.core_id = a.customer_as_vendor_core_id
--WHERE a.offer_date BETWEEN @DatOd AND @DatDo