

declare @ddv_id varchar(30) = '20240040990'
select kk_memo, * from dbo.pogodba where ddv_id = @ddv_id
select top 10 kk_memo, ddv_id, * from dbo.pogodba where ddv_id is not null and ddv_id != '' order by id_cont desc
select file_name from dbo.edoc_exported_files where document_id = @ddv_id

select 
case when b.id_dav_op = 'NM' then 'Vrijednost objekta leasinga: '+ dbo.gfn_gccif(d.brez_davka) + ' ' + rtrim(n.dom_valuta) else 'Vrijednost objekta leasinga bez PDV-a: '+ dbo.gfn_gccif(d.debit_neto) + ' ' + rtrim(n.dom_valuta) end +
							  case when d.debit_davek > 0 then ', Iznos PDV-a: '+ dbo.gfn_gccif(d.debit_davek) + ' ' + rtrim(n.dom_valuta) else '' end +
							  case when d.neobdav > 0 then
									case when vo.se_regis = '*' then ', Posebni porez na motorna vozila (PPMV): ' else ', Neoporezivi dio:' end
									+ dbo.gfn_gccif(d.neobdav) + ' ' + rtrim(n.dom_valuta) else '' end 
								+ ', Ukupno: '+ dbo.gfn_gccif(d.debit+d.neobdav) + ' ' + rtrim(n.dom_valuta) + '.' 
							  + case when e.debit > 0 then CHAR(10) + 'SPECIFIKACIJA PREDUJMOVA' + CHAR(10) + ltrim(rtrim(b.kk_memo)) + ' - Osnova: ' + dbo.gfn_gccif(e.debit_neto) + ' ' + rtrim(n.dom_valuta) + ', PDV: ' + dbo.gfn_gccif(e.debit_davek) + ' ' + rtrim(n.dom_valuta) + ', Ukupno: ' + dbo.gfn_gccif(e.debit) + ' ' + rtrim(n.dom_valuta) + CHAR(10) + 'Sveukupno - Osnova: '+ dbo.gfn_gccif(a.debit_neto) + ' ' + rtrim(n.dom_valuta)+ ', PDV: ' + dbo.gfn_gccif(a.debit_davek) + ' ' + rtrim(n.dom_valuta) + case when a.neobdav > 0 and vo.se_regis = '*' then ', PPMV: ' + dbo.gfn_gccif(a.neobdav) + ' ' + rtrim(n.dom_valuta) else '' end + ', Ukupno: ' + case when vo.se_regis = '*' then dbo.gfn_gccif(a.debit+a.neobdav) else dbo.gfn_gccif(a.debit) end + ' ' + rtrim(n.dom_valuta) else '' end + CHAR(10)
							+ 'Objekt leasinga ostaje u vlasništvu ' + rtrim(n.p_podjetje) + ' do konačne otplate svih obveza po Ugovoru o leasingu broj ' + rtrim(b.id_pog) + '. O izvršenoj otplati objekta leasinga, ' + rtrim(n.p_podjetje) + ' izdat će posebno Ovlaštenje s dozvolom prijenosa prava vlasništva na ime kupca.' ,
				InvoicePaymentNote = 'Plaćanje ovog računa je sukcesivno u skladu sa otplatnim planom koji je sastavni dio ugovora o financijskom leasingu broj ' + rtrim(b.id_pog) + '.'
From dbo.rac_out a
inner join dbo.pogodba b on a.id_cont = b.id_cont 
left join dbo.nastavit n on 1 = 1
inner join dbo.vrst_opr vo ON b.id_vrste = vo.id_vrste
left join (SELECT c.id_cont, SUM(c.debit) AS debit, SUM(c.debit_neto) AS debit_neto, SUM(c.debit_davek) AS debit_davek, SUM(c.neobdav) AS neobdav, SUM(c.brez_davka) AS brez_davka
			FROM(SELECT p.id_cont, r.debit, r.debit_neto, r.debit_davek, r.brez_davka, r.neobdav 
				FROM dbo.pogodba p INNER JOIN dbo.rac_out r ON p.ddv_id = r.ddv_id 
				UNION ALL
				SELECT p.ID_CONT, r.debit, r.debit_neto, r.debit_davek, r.brez_davka, r.neobdav 
				FROM dbo.pogodba p INNER JOIN dbo.rac_out r ON p.id_cont = r.id_cont AND CHARINDEX(RTRIM(r.ddv_id), p.kk_memo) != 0 
				) c GROUP BY c.ID_CONT)d ON a.id_cont = d.id_cont
left join (SELECT p.id_cont, SUM(debit) as debit, SUM(debit_neto) as debit_neto, SUM(debit_davek) AS debit_davek 
			FROM dbo.pogodba p INNER JOIN dbo.rac_out r on p.id_cont = r.id_cont AND CHARINDEX(RTRIM(r.ddv_id), p.kk_memo) != 0 GROUP BY p.id_cont) e ON a.id_cont = e.id_cont
where a.DDV_ID = @ddv_id


--za testiranje processing plugin

 declare @id varchar(100), @OriginalFileName varchar(100), @DocType varchar(100), @ReportName varchar(100)
 set @id = '20240040440'
 set @OriginalFileName = (select file_name from dbo.edoc_exported_files where document_id = @id)--'Contract_83787_2023_12_07_11_39_46_456.pdf'
 set @DocType = 'Invoice'
 set @ReportName = 'KK_FAKT_SSOFT_RLC' 
 
