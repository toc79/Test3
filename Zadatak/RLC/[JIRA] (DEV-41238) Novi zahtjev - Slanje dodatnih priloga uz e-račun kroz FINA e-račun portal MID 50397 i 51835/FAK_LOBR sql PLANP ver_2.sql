declare @OpcSt_dok char(21) = (select ISNULL(dbo.gfn_GetOpcSt_dok(id_cont, nacin_leas), '0') as OpcSt_dok from dbo.pogodba where id_cont = @id_cont)
declare @ddv_date datetime = (select ddv_date from dbo.rep_ind where id_rep_ind = @id_rep_ind) -- ddv_date datetime parametar can't be null that's why it is set here
	
Select a.datum_dok,
	a.zap_obr,
	a.neto,
	a.marza, 
	a.obresti,
	a.robresti,
	a.debit,
	@OpcSt_dok as OpcSt_dok,
	CASE WHEN a.ST_DOK = @OpcSt_dok THEN 'OTKUPNA VRIJEDNOST OBJEKTA LEASINGA' ELSE 'RATA' END AS txtOpis,
	CASE WHEN a.id_val = 'HRK' THEN 'KN' ELSE a.id_val END AS id_val
From dbo.planp a
Left Join dbo.vrst_ter v on a.id_terj = v.id_terj
Where a.id_cont = @id_cont
and v.sif_terj = 'LOBR' 
and a.datum_dok > @ddv_date