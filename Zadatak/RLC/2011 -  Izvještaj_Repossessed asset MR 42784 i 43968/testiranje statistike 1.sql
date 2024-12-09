set statistics time on
DECLARE @today datetime = getdate()
DECLARE @ds_id_tec char(3) = (select top 1 planp_ds_tec from dbo.loc_nast order by id_loc_nast) -- from gfn_ContractStateForDashboardFromDS

SELECT a.id_pog Ugovor, nacin_leas Tip_financ , e.eval_model
	, a.id_kupca Sif_part, b.ext_id AS Coconut, b.naz_kr_kup AS Partner
	, ISNULL(c.znesek, 0) AS znp_saldo_brut_all
	, ISNULL(d.znesek, 0) AS bod_neto_lpod 
	--, ds.znp_saldo_brut_all
	--, ds.bod_neto_lpod
	--, dbo.gfn_Xchange(a.id_tec, ds.znp_saldo_brut_ALL, ds.id_tec, @today) AS Jos_duguje
	--, dbo.gfn_Xchange(a.id_tec, ds.bod_neto_lpod, @ds_id_tec, @today) AS Buduca_glavnica
, ru.* --, a.*
, a.id_tec
FROM dbo.pogodba a
INNER JOIN dbo.partner b ON a.id_kupca = b.id_kupca
LEFT JOIN (SELECT id_cont, id_tec, znp_saldo_brut_all, bod_neto_lpod FROM dbo.gv_planp_ds_by_contract) ds ON a.id_cont = ds.id_cont
LEFT JOIN (SELECT id_kupca, eval_model FROM dbo.gv_PEval_LastEvaluation) e ON a.id_kupca = e.id_kupca ---- This view return each partner last evaluation data of type E.  
OUTER APPLY (SELECT TOP 1 id_cont, datum_dok, zacetek, velja_do, vrednost, id_kupca FROM dbo.dokument WHERE id_obl_zav = 'RU' AND id_cont = a.id_cont ORDER BY status_akt) ru
OUTER APPLY (SELECT TOP 1 id_cont, datum_dok, zacetek, velja_do, vrednost, id_kupca FROM dbo.dokument WHERE id_obl_zav = 'RA' AND id_cont = a.id_cont ORDER BY status_akt) ra
OUTER APPLY (SELECT TOP 1 id_cont, datum_dok, zacetek, velja_do, vrednost, id_kupca FROM dbo.dokument WHERE id_obl_zav = 'RE' AND id_cont = a.id_cont ORDER BY status_akt) re
OUTER APPLY (SELECT TOP 1 id_cont, datum_dok, zacetek, velja_do, vrednost, id_kupca FROM dbo.dokument WHERE id_obl_zav = 'KL' AND id_cont = a.id_cont ORDER BY status_akt) kl
OUTER APPLY dbo.gfn_xchange_table(a.id_tec, ds.znp_saldo_brut_all, @ds_id_tec, @today) c
OUTER APPLY dbo.gfn_xchange_table(a.id_tec, ds.bod_neto_lpod, @ds_id_tec, @today) d
WHERE a.status_akt = 'A'

--AND a.status in ('RA', '08', 'PP', 'RI') 

--za test lokalno
--AND a.status in ('RA', '08', 'PP', 'RI') 

--AND (ru.id_cont IS NOT NULL OR ra.id_cont IS NOT NULL OR re.id_cont IS NOT NULL OR kl.id_cont IS NOT NULL)

--SELECT ID_KUPCA, DAT_EVAL, EVAL_MODEL FROM gv_p_eval ORDER BY ID_KUPCA

set statistics time OFF

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

(8699 row(s) affected)

 SQL Server Execution Times:
   CPU time = 3112 ms,  elapsed time = 977 ms.


 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

(8699 row(s) affected)

 SQL Server Execution Times:
   CPU time = 3233 ms,  elapsed time = 972 ms.
