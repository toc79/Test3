select KK_MEMO,* from pogodba where dbo.gfn_Nacin_leas_HR(pogodba.nacin_leas) = 'F1' 
AND  STATUS_AKT = 'A'
AND cast(ltrim(rtrim(REPLACE(REPLACE(REPLACE(KK_MEMO, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))) as varchar(8000)) != ''  
order by ID_CONT  desc



RAZLIKA PO RN.BR. {pogodba.Fis_BrRac.Trim()}:


Razlika po Rn.br. {pogodba.Fis_BrRac.Trim()}:

za F1 POPRAVLJENO na kao za F4
{Format("{0:N2}", pogodba.ro_debit)}


za F4 
{Format("{0:N2}", pogodba.ro_debit + rac_out.neobdav)} {Settings.dom_valuta.Trim()}


--select KK_MEMO, robresti_val,* from pogodba where dbo.gfn_Nacin_leas_HR(pogodba.nacin_leas) = 'F1' 
--AND  STATUS_AKT = 'A'
--AND cast(ltrim(rtrim(REPLACE(REPLACE(REPLACE(KK_MEMO, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))) as varchar(8000)) != ''  
--AND ID_VRSTE in (select ID_VRSTE from VRST_OPR where se_regis = '*')
--order by ID_CONT  desc

--F4
select ddv_id,NEOBDAV,* from RAC_OUT where ID_CONT = 58125

declare @id varchar (30) = 'M2017000024'
--SELECT SUM(a.debit) AS debit, SUM(a.debit_neto) AS debit_neto, SUM(a.debit_davek) AS debit_davek, SUM(a.brez_davka) AS brez_davka, SUM(a.neobdav) AS neobdav
--FROM(
SELECT r.debit, r.debit_neto, r.debit_davek, r.brez_davka, r.neobdav 
	FROM dbo.pogodba p INNER JOIN dbo.rac_out r ON p.ddv_id = r.ddv_id 
		WHERE p.ddv_id = @id
	UNION ALL
SELECT r.debit, r.debit_neto, r.debit_davek, r.brez_davka, r.neobdav 
	FROM dbo.pogodba p INNER JOIN dbo.rac_out r ON p.id_cont = r.id_cont AND CHARINDEX(RTRIM(r.ddv_id), p.kk_memo) != 0 
		WHERE p.ddv_id = @id
--) a

--F1 58194
select ddv_id,NEOBDAV,* from RAC_OUT where ID_CONT = 58194

--declare 
SET @id  = '20170057579   '
--SELECT SUM(a.debit) AS debit, SUM(a.debit_neto) AS debit_neto, SUM(a.debit_davek) AS debit_davek, SUM(a.brez_davka) AS brez_davka, SUM(a.neobdav) AS neobdav
--FROM(
SELECT r.debit, r.debit_neto, r.debit_davek, r.brez_davka, r.neobdav 
	FROM dbo.pogodba p INNER JOIN dbo.rac_out r ON p.ddv_id = r.ddv_id 
		WHERE p.ddv_id = @id
	UNION ALL
SELECT r.debit, r.debit_neto, r.debit_davek, r.brez_davka, r.neobdav 
	FROM dbo.pogodba p INNER JOIN dbo.rac_out r ON p.id_cont = r.id_cont AND CHARINDEX(RTRIM(r.ddv_id), p.kk_memo) != 0 
		WHERE p.ddv_id = @id
--) a