declare @id_kupca as varchar(10), @id_tec varchar(3), @dat_tec datetime, @delimiter char(1), @id_xml varchar(100), @xml_data2 xml, @cnt int
--, @ID CHAR(50)

set @cnt = 1
set @delimiter = '$'
--set @id = '000015$017$20210901$498'

while (charindex(@delimiter, @id)>0)
begin

if @cnt = 1
begin

set @id_kupca = ltrim(rtrim(substring(@id, 1, charindex(@delimiter, @id)-1)))
end

if @cnt = 2
begin

set @id_tec = ltrim(rtrim(substring(@id, 1, charindex(@delimiter, @id)-1)))
end
if @cnt = 3
begin

set @dat_tec = ltrim(rtrim(substring(@id, 1, charindex(@delimiter, @id)-1)))
end
if @cnt = 4
begin

set @id_xml = ltrim(rtrim(substring(@id, 1, charindex(@delimiter, @id)-1)))
end

set @id = substring(@id, charindex(@delimiter, @id)+1, len(@id))
set @cnt = @cnt + 1
end

set @xml_data2 = (Select cast(xml1 as xml) as xml_data From dbo.ssoft_reports Where id = CAST (@id_xml as INT))

select
	p.id_cont,
	ISNULL(SUM(dbo.gfn_Xchange(@id_tec, PP.znp_debit_LPOD + PP.znp_debit_OST, PP.ID_tec, @dat_tec)),0) AS Debit,
ISNULL(SUM(dbo.gfn_Xchange(@id_tec, PP.znp_kredit_LPOD + PP.znp_kredit_OST, PP.ID_tec, @dat_tec)),0) AS Kredit,
ISNULL(SUM(dbo.gfn_Xchange(@id_tec, PP.znp_saldo_brut_LPOD + PP.znp_saldo_OST, PP.ID_tec, @dat_tec)),0) AS Saldo,
MIN(znp_min_dat_zap_ALL) as znp_min_dat_zap_ALL,
ISNULL(dbo.gfn_xchange('000',SUM(dbo.gfn_Xchange(@id_tec, PP.znp_saldo_brut_LPOD + PP.znp_saldo_OST, PP.ID_tec, @dat_tec)),@id_tec,getdate()),0) AS Saldo_dom,
p.sklic, par.vr_osebe,
p.id_pog,
@id_tec as id_tec_s,
@dat_tec as dat_tec_s,
p.id_kupca as id_kupca
into #tmp
FROM dbo.pogodba p
LEFT JOIN dbo.planp_ds PP ON P.id_cont = pp.ID_CONT
INNER JOIN
(Select
	rtrim(t.c.value('id_cont[1]','int')) as id_cont
	From @xml_data2.nodes('VFPData/rezultat2') t(c)
) a ON p.id_cont = a.id_cont
and p.id_kupca = @id_kupca

INNER JOIN dbo.partner par ON p.id_kupca = par.id_kupca
--where p.id_cont = 67257
GROUP BY p.id_cont, p.sklic, p.id_pog, p.id_kupca, par.vr_osebe

select SALDO_EUR_MIG.res_print as SALDO_RES_PRINT
	, SALDO_EUR_MIG.res_amount as SALDO_RES_AMOUNT
	, SALDO_EUR_MIG.res_exch as SALDO_RES_EXCH
	, SALDO_EUR_MIG.res_id_val as SALDO_RES_ID_VAL

	, SALDO_DOM_EUR_MIG.res_print as SALDO_DOM_RES_PRINT
	, SALDO_DOM_EUR_MIG.res_amount as SALDO_DOM_RES_AMOUNT
	, SALDO_DOM_EUR_MIG.res_exch as SALDO_DOM_RES_EXCH
	, SALDO_DOM_EUR_MIG.res_id_val as SALDO_DOM_RES_ID_VAL
	, TMP.* from #tmp TMP
outer apply dbo.pfn_gmc_xchangeEurMigrationPrintouts(@id_tec, Saldo, getdate(), vr_osebe, id_cont) as SALDO_EUR_MIG
outer apply dbo.pfn_gmc_xchangeEurMigrationPrintouts('000', Saldo_dom, getdate(), vr_osebe, id_cont) as SALDO_DOM_EUR_MIG


drop table #tmp