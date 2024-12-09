SELECT 
	pp.id_cont, pp.dat_zap, pp.datum_dok, pp.id_terj, pp.zap_obr, pp.neto, pp.obresti,
	pp.robresti, pp.marza, pp.regist, pp.davek, pp.debit, pp.kredit, pp.saldo, pp.zaprto, 
	pp.id_val, pp.id_tec,
	pp.nacin_leas, pp.dat_obr, 
	pp.naziv, pp.sif_terj, 
	CASE WHEN dbo.gfn_Nacin_leas_HR(pp.nacin_leas) = 'F1' THEN 
			CASE WHEN dbo.gfn_GetOpcSt_dok(pp.id_cont, pp.nacin_leas) = pp.st_dok THEN 'OTKUPNA RATA' ELSE 
				CASE WHEN pp.sif_terj='LOBR' THEN 'RATA' ELSE pp.naziv END END
			ELSE
	CASE WHEN dbo.gfn_GetOpcSt_dok(pp.id_cont, pp.nacin_leas) = pp.st_dok THEN 'PREOSTALA VRIJEDNOST' ELSE
				CASE WHEN pp.sif_terj='LOBR' THEN 'RATA' ELSE pp.naziv END END
		END AS naziv_potrazivanja,
	CASE WHEN dbo.gfn_nacin_leas_HR(pp.id_pog) = 'OL' AND pp.id_terj = '21' THEN 'OBROK' ELSE pp.vrst_ter_naziv END AS vrst_ter_naziv
FROM dbo.gfn_PlanPlacilSelect(getdate()) pp
INNER JOIN dbo.rep_ind a on pp.id_cont=a.id_cont 
WHERE a.id_rep_ind in (Select max(id_rep_ind) as id_rep_ind From rep_ind where izpisan = 0 group by id_cont)
AND a.id_cont in (Select id_cont From dbo.rac_out where ddv_id = @id)
AND pp.datum_dok>a.datum
ORDER BY pp.dat_zap, pp.dat_obr, pp.datum_dok