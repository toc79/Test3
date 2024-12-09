-- Select za kontrolu ugovora koji imaju otkup i potraživanje je dobro na 1. u mjesecu, ali pogodba.zap_opc NIJE prvog u mjesecu.

select c.id_cont ID_ugovora, b.id_pog Br_ugovora, b.zap_opc AS Dat_otkupa_na_ugovoru, trojna_opc AS Da_li_je_pripremljena_obavijest_o_otkupu
, c.st_dok Br_dok_potraživanja, c.datum_dok Datum_dok
, DATEDIFF(dd,c.datum_dok, d.datum_dok) as Razlika_dana
--, DATEDIFF(mm,c.datum_dok, b.zap_opc) as Razlika_mjeseci --NIJE DOBRO PROVJERAVATI 
from dbo.planp c 
join dbo.pogodba  b ON c.id_cont = b.id_cont
join dbo.planp d on d.zap_obr = c.zap_obr - 1 AND c.id_cont = d.id_cont
where b.zap_opc != c.datum_dok
AND b.STATUS_AKT != 'Z'
AND c.st_dok = dbo.gfn_GetOpcSt_dok(b.id_cont, b.nacin_leas)
AND dbo.gfn_Nacin_leas_HR(b.nacin_leas) like 'F1'
AND c.evident != '*' 
AND DAY(b.zap_opc) != 1 -- 516 zapisa - TO NISAM MIJENJAO
--AND DAY(c.datum_dok) != 1 -- 0 zapisa -> OK
AND b.OPCIJA > 0
order by 1