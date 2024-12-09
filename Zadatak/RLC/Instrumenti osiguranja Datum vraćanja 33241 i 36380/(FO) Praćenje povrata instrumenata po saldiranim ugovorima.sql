DECLARE @DocList varchar(8000)

Select @DocList = Value From GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and ID_KEY = 'RLC_IOP_LISTA'
Select * INTO #COLL From dbo.gfn_GetTableFromList(@DocList)

--UGOVORI KOJI SU SALDIRANI
Select a.id_cont, a.id_pog, a.nacin_leas, a.trojna_opc, a.se_varsc, a.varscina, 
	a.aneks, a.status_akt, c.id_kupca,c.naz_kr_kup, c.dav_stev, e.naziv, b.Saldiran
INTO #CANDIDATES
From dbo.pogodba a
Inner join dbo.partner c on a.id_kupca = c.id_kupca
Inner join dbo.statusi e on a.status = e.status
--SALDO IZ PLANA OTPLATE
Inner join (Select id_cont, CASE WHEN SUM(saldo)> 0 THEN 0 ELSE 1 END AS Saldiran
			From dbo.planp a
			Inner join dbo.vrst_ter b on a.id_terj = b.id_terj
			Where b.sif_terj <> 'OPC' Group by id_cont) b ON a.id_cont = b.id_cont and b.Saldiran = 1
Where a.status_akt = 'A' OR (a.status_akt = 'Z' AND a.DAT_ZAKL > '20140530')


--IZDAN OTKUP
Select a.id_cont, a.datum_dok, CASE WHEN a.ddv_id IS NOT NULL AND a.ddv_id <> '' THEN 1 ELSE 0 END AS SE_OPC
INTO #PLAP_OPC
From dbo.planp a
Inner join dbo.vrst_ter b on a.id_terj = b.id_terj
Inner join #CANDIDATES c on a.id_cont = c.id_cont
Where b.sif_terj = 'OPC' Group by a.id_cont, a.ddv_id, a.datum_dok


--INSTRUMENTI OSIGURANJA
Select a.id_cont, a.id_kupca, a.id_obl_zav, a.Opis, LEFT(a.opombe, 250) as opombe
	, CASE WHEN a.id_obl_zav = 'RA' THEN a.zacetek ELSE NULL END AS dat_pov
	, CASE WHEN a.id_obl_zav = 'RA' THEN NULL ELSE a.vrnjen END AS dat_vrac
INTO #DOK
From dbo.dokument a
Inner join #CANDIDATES b ON a.id_cont = b.id_cont
Inner join #COLL c on a.id_obl_zav = c.id


--DATUM ZADNJEG PLAĆANJA IZ LSK i PLACILA (dio koda iz gft_PaymentDistribution_View_General1)
Select a.id_cont, a.id_kupca, max(a.max_datum_placanja) as dat_pl
INTO #PLAC
From
(SELECT	l.ID_CONT,
		l.id_kupca,
		max(pl.dat_pl) as max_datum_placanja
	FROM dbo.lsk l 
	INNER JOIN dbo.placila pl on l.id_plac = pl.id_plac
	WHERE l.id_plac <> -1
	AND l.Kredit_DOM <> 0
	AND l.ID_Dogodka IN ('PLAC_IZ_AV','PLAC_ODPIS','PLAC_VRACI', 'PLAC_ZA_OD', 'PLACILO ', 'AV_VRACILO', 'AV_ODPIS', 'AV_ZAC_ODP')
	GROUP BY l.id_cont, l.id_kupca) a
Group by a.id_cont, a.id_kupca
	

--IZVJEŠTAJ
Select a.*, 
	CASE
		WHEN b.SE_OPC IS NULL THEN ' '
		WHEN b.SE_OPC = 0 THEN 'NE'
		WHEN b.SE_OPC = 1 THEN 'DA'
	END as SE_OPC, b.datum_dok as DAT_OPC,
	c.dat_pl, DATEDIFF(dd, c.dat_pl, GETDATE()) as DAYS_DUE,
	d.id_obl_zav, d.Opis, d.dat_pov, d.dat_vrac, ISNULL(d.opombe, '') as opombe
From #CANDIDATES a
Left join #PLAP_OPC b on a.id_cont = b.id_cont
Left join #PLAC c on a.id_cont = c.id_cont and a.id_kupca = c.id_kupca
Left join #DOK d on a.id_cont = d.id_cont
Order by a.id_kupca, a.id_cont

--MEM FREE
DROP TABLE #CANDIDATES
DROP TABLE #PLAP_OPC
DROP TABLE #PLAC
DROP TABLE #DOK
DROP TABLE #COLL

/*
 PROMIJENITI:
- Prikazati Datum vraćanja vrnjen -> Datum vraćanja trenutni to je zapravo 'Datum vraćanja instrumenata ' dat_vrac . Za RA dokument je uvijek NULL.  
 - Datum plaćanja/vraćanja prema novoj logici tj. preporučeni 'Zakonski rok' -> 'Kontrola 60 dana' polje da li je razlika u danima u okviru logike DA ili NE ili kao razlika razlika 'datum vraćanja preporučeni' i vrnjen -> možda najbolje dati broj dana razlike jer svi podaci ostali već postoje
-
4. 2 kriterija ukoliko se ne označe, prikazuju se svi dokumenti (kao na prvoj natuknici)
 Datum dokumenta na KO = Datum vraćanja instrumanata osig. na istom ugovoru.

- preporuka, dodati na dokmet podatak da je datum vraćanja unesen takav kakav je tj. iako je možda neispravan, i da se iste ne treba mijenjati (možda neki status dokumentacije) tj. dokument je obrađen, te se i taj podatak dodati na izvještaj.
