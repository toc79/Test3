DECLARE @Id_cont int
SET @Id_cont = (select distinct id_cont from dbo.rep_ind where id_rep_ind = @id)
	
Select a.id_terj,
	a.datum_dok,
	a.zap_obr,
	a.neto,
	a.marza, 
	a.obresti,
	a.robresti,
	a.regist,
	a.davek, 
	a.debit,
	o.obnaleto, 
	c.ndatum, c.id_rep_ind,
	ISNULL(dbo.gfn_GetOpcSt_dok(a.id_cont,a.nacin_leas),'0') as OpcSt_dok,
	CASE WHEN a.ST_DOK = dbo.gfn_GetOpcSt_dok(a.id_cont,a.nacin_leas) THEN 'OTKUPNA VRIJEDNOST OBJEKTA LEASINGA' ELSE 'RATA' END AS txtOpis,
	CASE WHEN a.id_val = 'HRK' THEN 'KN' ELSE a.id_val END AS id_val
	From dbo.planp a
Inner Join dbo.rep_ind c on a.id_cont = c.id_cont 
Left join rtip b on b.id_rtip=c.id_rtip 
Left Join vrst_ter v on a.id_terj = v.id_terj
Left Join obdobja o on b.id_obdrep=o.id_obd
Where a.id_cont = @Id_cont
and v.sif_terj = 'LOBR' and a.datum_dok > c.ndatum
and c.id_rep_ind = @id