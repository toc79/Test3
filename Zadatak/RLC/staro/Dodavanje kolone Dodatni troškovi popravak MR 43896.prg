GF_SQLEXEC("SELECT d.id_cont, SUM(dbo.gfn_xchange(a.id_tec, d.pred_znesek_dom, '000',a.dat_sklen)) as neto_val FROM dbo.gv_DodStrPogodba AS D INNER JOIN dbo.pogodba AS A ON D.id_cont = A.id_cont GROUP BY d.id_cont","_DOD_TROS")

GF_AddColumnsToGrid("POGODBA_PREGLED", "BGridResult", "Dodatni troškovi", "LOOKUP(_DOD_TROS.neto_val, POGODBA.ID_CONT,_DOD_TROS.ID_CONT)", 120 , "")

*NOVO
* 10.01.2020 g_tomislav MR 43896 - added exchange from d.id_tec insted of '000'. 

GF_SQLEXEC("SELECT d.id_cont, SUM(dbo.gfn_xchange(a.id_tec, d.pred_znesek_dom, d.id_tec, a.dat_sklen)) as neto_val FROM dbo.gv_DodStrPogodba AS D INNER JOIN dbo.pogodba AS A ON D.id_cont = A.id_cont GROUP BY d.id_cont","_DOD_TROS")

GF_AddColumnsToGrid("POGODBA_PREGLED", "BGridResult", "Dodatni troškovi", "LOOKUP(_DOD_TROS.neto_val, POGODBA.ID_CONT,_DOD_TROS.ID_CONT)", 120 , "")
