select * from print_selection where code_before like '%''OZ''%'

select * from print_selection where code_before like '%OZ,%'

select * from porocila where select_stmt like '%OZ,%'

select * from porocila where select_stmt like '%"OZ"%'

select * from report_variables where formula like '%"OZ"%'

Search "'OZ'" (38 hits in 11 files)
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\BEZTR_OPOMIN1.frt (8 hits)
	Line 15: 
	Line 23: pošaljete potvrdu o plaćanju na fax 6595 - 050."
	Line 23: pošaljete potvrdu o plaćanju na fax 6595 - 050."
	Line 23: pošaljete potvrdu o plaćanju na fax 6595 - 050."
	Line 23: pošaljete potvrdu o plaćanju na fax 6595 - 050."
	Line 23: pošaljete potvrdu o plaćanju na fax 6595 - 050."
	Line 25: lc_tipleas
	Line 25: lc_tipleas
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\BEZTR_OPOMIN2.frt (7 hits)
	Line 18: pošaljete potvrdu o plaćanju na fax 6595 - 050."
	Line 18: pošaljete potvrdu o plaćanju na fax 6595 - 050."
	Line 24: "Način plać."
	Line 26: lc_tipleas
	Line 26: lc_tipleas
	Line 26: lc_tipleas
	Line 26: lc_tipleas
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\BEZTR_OPOMIN3.frt (5 hits)
	Line 19: "Već plaćeno"
	Line 19: "Već plaćeno"
	Line 24: "Način plać."
	Line 26: lc_tipleas
	Line 26: lc_tipleas
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\FAK_LOBR_SSOFT_RLC.mrt (2 hits)
	Line 212: CASE WHEN d.tip_leas = 'OZ' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OZ_LOBR,
	Line 269: 			WHEN tip_knjizenja = 1 AND charindex(nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\OBVREG_SSOFT.mrt (4 hits)
	Line 241: 	MAX(CASE WHEN id_obl_zav IN ('AK', 'BK', 'VK', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') THEN zacetek ELSE '19000101' END) as velja_do_ak, 
	Line 242: 	MAX(CASE WHEN id_obl_zav IN ('AK', 'BK', 'VK', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') THEN konec ELSE '19000101' END) as kraj_ak
	Line 244: 	WHERE id_obl_zav IN ('AO', 'BO', 'AK', 'BK', 'VK' ,'VO', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') 
	Line 316: AND d.id_obl_zav IN ('AO', 'BO', 'AK', 'BK', 'VK' ,'VO', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ')</SqlCommand>
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\PONUDBA_RPG_SSOFT_RLC.mrt (1 hit)
	Line 139: 		WHEN nl.tip_knjizenja = 1 and CHARINDEX(nl.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\PONUDBA_SSOFT_RLC.mrt (1 hit)
	Line 146: 		WHEN nl.tip_knjizenja = 1 and CHARINDEX(nl.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\VARSCINA_SSOFT_RLC.mrt (1 hit)
	Line 132: WHEN e.tip_knjizenja = 1 and charindex(e.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\OPOMIN1.frt (3 hits)
	Line 23: "Oz. stranke"
	Line 34: lc_tipleas
	Line 34: lc_tipleas
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\OPOMIN2.frt (3 hits)
	Line 19: S poštovanjem,"
	Line 34: lc_tipleas
	Line 34: lc_tipleas
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\OPOMIN3.frt (3 hits)
	Line 22: "Već plaćeno"
	Line 37: lc_tipleas
	Line 37: lc_tipleas
Search "'OZ'" (9 hits in 5 files)
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\FAK_LOBR_SSOFT_RLC.mrt (2 hits)
	Line 212: CASE WHEN d.tip_leas = 'OZ' AND v.sif_terj = 'LOBR' THEN 1 ELSE 0 END AS OZ_LOBR,
	Line 269: 			WHEN tip_knjizenja = 1 AND charindex(nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\OBVREG_SSOFT.mrt (4 hits)
	Line 241: 	MAX(CASE WHEN id_obl_zav IN ('AK', 'BK', 'VK', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') THEN zacetek ELSE '19000101' END) as velja_do_ak, 
	Line 242: 	MAX(CASE WHEN id_obl_zav IN ('AK', 'BK', 'VK', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') THEN konec ELSE '19000101' END) as kraj_ak
	Line 244: 	WHERE id_obl_zav IN ('AO', 'BO', 'AK', 'BK', 'VK' ,'VO', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ') 
	Line 316: AND d.id_obl_zav IN ('AO', 'BO', 'AK', 'BK', 'VK' ,'VO', 'PW', 'PZ', 'PŽ', 'OL', 'OP', 'OZ')</SqlCommand>
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\PONUDBA_RPG_SSOFT_RLC.mrt (1 hit)
	Line 139: 		WHEN nl.tip_knjizenja = 1 and CHARINDEX(nl.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\PONUDBA_SSOFT_RLC.mrt (1 hit)
	Line 146: 		WHEN nl.tip_knjizenja = 1 and CHARINDEX(nl.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\VARSCINA_SSOFT_RLC.mrt (1 hit)
	Line 132: WHEN e.tip_knjizenja = 1 and charindex(e.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'


	Provjera na tip_knjizenja

Search "tip_knjizenja" (73 hits in 13 files)
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\DDV_DBRP_ZVEC_SSOFT_RLC.mrt (4 hits)
	Line 206: 	CASE WHEN tip_knjizenja = 1 THEN 'OL'
	Line 207: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
	Line 208: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
	Line 209: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\FAKT_TR_SSOFT_RLC.mrt (4 hits)
	Line 164: 	CASE WHEN tip_knjizenja = 1 THEN 'OL'
	Line 165: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
	Line 166: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
	Line 167: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\FAK_LOBR_SSOFT_RLC.mrt (6 hits)
	Line 116:           <value>tip_knjizenja,System.String</value>
	Line 266: 	CASE WHEN tip_knjizenja = 1 AND charindex(nacin_leas,@zakup_nek) = 0 THEN 'OL'
	Line 267: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
	Line 268: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
	Line 269: 			WHEN tip_knjizenja = 1 AND charindex(nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
	Line 270: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\NAL_PL_SSOFT_RLC.mrt (4 hits)
	Line 126: 	CASE WHEN tip_knjizenja = 1 THEN 'OL'
	Line 127: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
	Line 128: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
	Line 129: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
  
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\OBVREG_SSOFT.mrt (3 hits)
	Line 198: OR (n.tip_knjizenja = '2' AND ds.bod_cnt_lobr &lt;= 1)
	Line 216: OR (n.tip_knjizenja = '2' AND ds.bod_cnt_lobr &lt;= 1))
	Line 231: CASE WHEN pun.id_cont IS NULL OR (n.tip_knjizenja = '2' AND ds.bod_cnt_lobr = 0) THEN 0 ELSE 1 END as print_punomoc, 
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\OBV_LOBR_SSOFT_RLC.mrt (5 hits)
	Line 74:           <value>tip_knjizenja,System.String</value>
	Line 111: 	a.str_financ, a.leas_kred, a.tip_knjizenja, a.stev_reg, reg.opis as OPIS, reg.reg_stev as REG_STEV, reg.st_sas as ST_SAS, opr.opis as OPIS1,
	Line 1017:                   <Text>{IIF(najem_ob.PRINT_OPC == "1" &amp;&amp; najem_ob.leas_kred == "L" &amp;&amp; najem_ob.tip_knjizenja == "2","OTKUPNA VRIJEDNOST OBJEKTA LEASINGA", Format("{0:G2}",najem_ob.ZAP_OBR)+". "+IIF(najem_ob.leas_kred=="K" &amp;&amp; najem_ob.tip_knjizenja=="2","RATA ZAJMA", IIF(najem_ob.leas_kred=="L" &amp;&amp; najem_ob.tip_knjizenja=="2", "RATA LEASINGA", najem_ob.naziv_terj.Trim()))+" za razdoblje: "+Format("{0:dd.MM.yyyy}", najem_ob.dat_poc)+". - "+Format("{0:dd.MM.yyyy}", najem_ob.dat_do)+".")}</Text>
	Line 1017:                   <Text>{IIF(najem_ob.PRINT_OPC == "1" &amp;&amp; najem_ob.leas_kred == "L" &amp;&amp; najem_ob.tip_knjizenja == "2","OTKUPNA VRIJEDNOST OBJEKTA LEASINGA", Format("{0:G2}",najem_ob.ZAP_OBR)+". "+IIF(najem_ob.leas_kred=="K" &amp;&amp; najem_ob.tip_knjizenja=="2","RATA ZAJMA", IIF(najem_ob.leas_kred=="L" &amp;&amp; najem_ob.tip_knjizenja=="2", "RATA LEASINGA", najem_ob.naziv_terj.Trim()))+" za razdoblje: "+Format("{0:dd.MM.yyyy}", najem_ob.dat_poc)+". - "+Format("{0:dd.MM.yyyy}", najem_ob.dat_do)+".")}</Text>
	Line 1017:                   <Text>{IIF(najem_ob.PRINT_OPC == "1" &amp;&amp; najem_ob.leas_kred == "L" &amp;&amp; najem_ob.tip_knjizenja == "2","OTKUPNA VRIJEDNOST OBJEKTA LEASINGA", Format("{0:G2}",najem_ob.ZAP_OBR)+". "+IIF(najem_ob.leas_kred=="K" &amp;&amp; najem_ob.tip_knjizenja=="2","RATA ZAJMA", IIF(najem_ob.leas_kred=="L" &amp;&amp; najem_ob.tip_knjizenja=="2", "RATA LEASINGA", najem_ob.naziv_terj.Trim()))+" za razdoblje: "+Format("{0:dd.MM.yyyy}", najem_ob.dat_poc)+". - "+Format("{0:dd.MM.yyyy}", najem_ob.dat_do)+".")}</Text>
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\ODOB1_SSOFT_RLC.mrt (3 hits)
	Line 238: 	, CASE WHEN nacini_l.tip_knjizenja = 1 THEN 1 ELSE 0 END AS je_oper
	Line 240: 	--, CASE WHEN nacini_l.tip_knjizenja != 1 THEN pon.prv_obr ELSE pon.varscina END AS akondep
	Line 243: 	, CASE WHEN nacini_l.tip_knjizenja = 1 THEN 0 ELSE pon.prv_obr + pon.opcija END 
  
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\POG_EIB_SSOFT_RLC.mrt (3 hits)
	Line 172: 	CASE WHEN nl.tip_knjizenja = '1' THEN 'OL'
	Line 173:          WHEN nl.tip_knjizenja = '2' and nl.finbruto = 0 and nl.leas_kred = 'L' THEN 'FF'
	Line 174:          WHEN nl.tip_knjizenja = '2' and nl.finbruto = 1 and nl.leas_kred = 'L' THEN 'F1'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\PONUDBA_RPG_SSOFT_RLC.mrt (11 hits)
	Line 18:           <value>tip_knjizenja,System.String</value>
	Line 106: SELECT po.id_pon, nl.naziv, nl.tip_knjizenja, po.naziv_kup, nl.ima_opcijo, nl.leas_kred, nl.finbruto, 
	Line 136: 		WHEN nl.tip_knjizenja = 1 and CHARINDEX(nl.nacin_leas,@zakup_nek) = 0 THEN 'OL'
	Line 137: 		WHEN nl.tip_knjizenja = 2 and nl.finbruto = 0 and nl.leas_kred = 'L' THEN 'FF'
	Line 138: 		WHEN nl.tip_knjizenja = 2 and nl.finbruto = 1 and nl.leas_kred = 'L' THEN 'F1'
	Line 139: 		WHEN nl.tip_knjizenja = 1 and CHARINDEX(nl.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
	Line 253: 	Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina End as vrijednost_dom,
	Line 258: 																				When Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina End &lt;= 100000.00 Then '100000.00' 
	Line 259: 																				When Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina End &gt; 100000.00 AND Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina End &lt;= 200000.00 Then '200000.00' 
	Line 259: 																				When Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina End &gt; 100000.00 AND Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina End &lt;= 200000.00 Then '200000.00' 
	Line 260: 																				When Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina End &gt; 200000.00 Then '200000.01' Else 'XXX' END)
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\PONUDBA_SSOFT_RLC.mrt (12 hits)
	Line 18:           <value>tip_knjizenja,System.String</value>
	Line 113: SELECT po.id_pon, nl.naziv, nl.tip_knjizenja, po.naziv_kup, nl.ima_opcijo, nl.leas_kred, nl.finbruto, 
	Line 143: 		WHEN nl.tip_knjizenja = 1 and CHARINDEX(nl.nacin_leas,@zakup_nek) = 0 THEN 'OL'
	Line 144: 		WHEN nl.tip_knjizenja = 2 and nl.finbruto = 0 and nl.leas_kred = 'L' THEN 'FF'
	Line 145: 		WHEN nl.tip_knjizenja = 2 and nl.finbruto = 1 and nl.leas_kred = 'L' THEN 'F1'
	Line 146: 		WHEN nl.tip_knjizenja = 1 and CHARINDEX(nl.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'
	Line 275: 	Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar+p.robresti_dom Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina+p.robresti_dom End as vrijednost_dom,
	Line 280: 																				When Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar+p.robresti_dom Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina+p.robresti_dom End &lt;= 100000.00 Then '100000.00' 
	Line 281: 																				When Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar+p.robresti_dom Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina+p.robresti_dom End &gt; 100000.00 AND 
	Line 282: 																				Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar+p.robresti_dom Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina+p.robresti_dom End &lt;= 200000.00 Then '200000.00' 
	Line 283: 																				When Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar+p.robresti_dom Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina+p.robresti_dom End &gt; 200000.00 AND 
	Line 284: 																				Case When p.je_foseba = 1 OR (nl.tip_knjizenja = 2 AND g.val_char = 'OV') Then dbo.gfn_xchange('000',p.neto*(1+(p.dav_vred_op/100)), p.id_tec_n, p.dat_pon)+p.str_notar+p.robresti_dom Else dbo.gfn_xchange('000',p.neto, p.id_tec_n, p.dat_pon)+p.trosarina+p.robresti_dom End &lt;= 400000.00 Then '200000.01'																	
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\RLC_XDOC_T1.mrt (8 hits)
	Line 71: 	CASE WHEN tip_knjizenja = 1 THEN 'OL'
	Line 72: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
	Line 73: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
	Line 74: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
	Line 104: 	CASE WHEN tip_knjizenja = 1 THEN 'OL'
	Line 105: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
	Line 106: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
	Line 107: 			WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\SPL_FAK.mrt (4 hits)
	Line 203: 	CASE WHEN tip_knjizenja = 1 THEN 'OL'
	Line 204: 					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 0 THEN 'FF'
	Line 205: 					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'L' AND FINBRUTO = 1 THEN 'F1'
	Line 206: 					WHEN tip_knjizenja = 2 AND LEAS_KRED = 'K' THEN 'ZP'
  C:\Users\tomislav.krnjak\Documents\Zadatak\RLC\Reporti s PROD 29 05 2017\MRT\VARSCINA_SSOFT_RLC.mrt (6 hits)
	Line 101:           <value>tip_knjizenja,System.String</value>
	Line 125: ,d.naziv as naziv_ter,d.sif_terj, e.tip_knjizenja, f.naziv as naziv_tec
	Line 129: e.tip_knjizenja = 1 and charindex(e.nacin_leas,@zakup_nek) = 0 THEN 'OL'
	Line 130: WHEN e.tip_knjizenja = 2 and e.finbruto = 0 and e.leas_kred = 'L' THEN 'FF'
	Line 131: WHEN e.tip_knjizenja = 2 and e.finbruto = 1 and e.leas_kred = 'L' THEN 'F1'
	Line 132: WHEN e.tip_knjizenja = 1 and charindex(e.nacin_leas,@zakup_nek) &gt; 0 THEN 'OZ'

	
	10 ispisa