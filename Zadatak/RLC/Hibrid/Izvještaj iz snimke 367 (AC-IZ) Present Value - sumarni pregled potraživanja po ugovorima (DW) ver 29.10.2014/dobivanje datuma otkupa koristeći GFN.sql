DECLARE @id_oc_report int = 106

SELECT b.sif_terj, pp.id_cont, pp.st_dok, pp.datum_dok --, pp.zap_obr--pp.*	--, pp.datum_dok, obresti
INTO #PLANP 
FROM  nova_hls.dbo.planp pp
INNER JOIN dbo.vrst_ter b ON pp.id_terj = b.id_terj AND b.id_oc_report = @id_oc_report
WHERE EXISTS (SELECT id_cont FROM dbo.oc_contracts WHERE id_cont = pp.id_cont AND id_oc_report = @id_oc_report)
AND b.sif_terj in ('LOBR', 'OPC')

select id_cont, nova_hls.dbo.gfn_GetOpcSt_dok(id_cont, nacin_leas) AS OpcSt_dok --, nova_hls.dbo.gfn_Nacin_leas_HR(nacin_leas) AS tip_leas
INTO #OpcSt_doks
FROM dbo.oc_contracts WHERE id_oc_report  = @id_oc_report --#PLANP 

--select * from #OpcSt_doks 

--Datum dokumenta otkupa
SELECT pp.id_cont, pp.datum_dok, pp.st_dok --, pp.zap_obr
INTO #OpcSt_doks_Zap_obr
FROM #PLANP pp  --nova_hls.dbo.planp pp
WHERE EXISTS (SELECT OpcSt_dok FROM #OpcSt_doks WHERE OpcSt_dok IS NOT NULL AND OpcSt_dok = pp.st_dok)

select * from #OpcSt_doks_Zap_obr order by id_cont

--Datum zadnje rate za ugovore bez otkupa i s otkupom
SELECT pp.id_cont, max(pp.datum_dok) max_datum_dok 
FROM #PLANP pp
INNER JOIN #OpcSt_doks b ON b.id_cont = pp.id_cont AND b.OpcSt_dok != pp.st_dok 
WHERE sif_terj = 'LOBR' -- za svaki sluèaj ako OL ima dva otkupa 
GROUP BY pp.id_cont 
order by pp.id_cont

-- Broj rate iz plana otplate
SELECT id_cont, count(*) FROM #PLANP WHERE sif_terj = 'LOBR' group by id_cont

DROP TABLE #PLANP 
DROP TABLE #OpcSt_doks
DROP TABLE #OpcSt_doks_Zap_obr