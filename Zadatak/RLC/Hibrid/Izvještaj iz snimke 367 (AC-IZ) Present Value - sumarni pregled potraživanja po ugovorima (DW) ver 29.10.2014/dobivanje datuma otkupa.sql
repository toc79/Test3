declare @id_oc_report int = 1980

SELECT pp.*
	--, pp.datum_dok, obresti
INTO #PLANP 
FROM  NOVA_TEST.dbo.planp pp
--WHERE EXISTS (SELECT id_cont FROM dbo.oc_contracts WHERE id_cont = pp.id_cont AND id_oc_report = @id_oc_report)
INNER JOIN (SELECT a.id_cont, a.nacin_leas, b.ima_opcijo 
			FROM dbo.oc_contracts a
			INNER JOIN dbo.nacini_l b ON a.nacin_leas = b.nacin_leas AND a.id_oc_report = b.id_oc_report 
			WHERE a.id_oc_report = @id_oc_report
			) b ON pp.id_cont = b.id_cont
INNER JOIN dbo.vrst_ter c ON pp.id_terj = c.id_terj AND c.id_oc_report = @id_oc_report

SELECT * FROM #PLANP 

DECLARE @id_terj char(2)
SET @id_terj = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj = case when @ima_opcijo = 1 then 'OPC' else 'LOBR' end)

SELECT MAX(datum_dok) as datum_dok 
FROM #planp pp 
INNER JOIN  (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj = case when @ima_opcijo = 1 then 'OPC' else 'LOBR' end
	) terj ON terj.id_terj = pp.id_terj AND id_oc_report = @id_oc_report
GROUP BY id_cont

DROP TABLE #PLANP



ALTER FUNCTION [dbo].[gfn_GetOpcSt_dok] (@id_cont int, @nacin_leas char(2))
RETURNS char(21)
AS
BEGIN
    DECLARE 
		@st_dok char(21),
		@ima_opcijo bit, 
		@id_terj char(2)

	IF @nacin_leas is null
		SET @nacin_leas = (SELECT nacin_leas FROM dbo.pogodba WHERE id_cont = @id_cont)

	SET @ima_opcijo = (SELECT ima_opcijo FROM dbo.nacini_l WHERE nacin_leas = @nacin_leas)
	SET @id_terj = (SELECT id_terj FROM dbo.vrst_ter WHERE sif_terj= case when @ima_opcijo = 1 then 'OPC' else 'LOBR' end)

	SET @st_dok = (SELECT 
						top 1 p.st_dok 
					FROM 
						dbo.planp p
					WHERE 
						p.id_cont = @id_cont and 
						p.id_terj = @id_terj and
						1 = case when @ima_opcijo = 1 then 1 else case when p.obresti = 0 then 1 else 0 end end and
						p.datum_dok in 
						(
							SELECT 
								MAX(datum_dok) as datum_dok 
							FROM 
								dbo.planp 
							WHERE 
								id_cont = @id_cont and 
								id_terj = @id_terj 
							GROUP BY 
								id_cont
						)
					ORDER BY 
						p.zap_obr DESC)

	RETURN @st_dok
END
