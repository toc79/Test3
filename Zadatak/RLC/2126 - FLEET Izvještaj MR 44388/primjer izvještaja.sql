select distinct pog.id_cont,
pog.ID_POG																									 as 'Ugovor',
pog.ID_PON																									 as 'Ponuda_br',
pog.STATUS_AKT																									 as 'Akt.',
(select COUNT(*) from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ ='21')							 as 'Br.rata',
(select COUNT(*) from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ ='21'and pl.DAT_ZAP <=getdate())as 'Dospjele rate',
(select COUNT(*) from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ ='21' and pl.DAT_ZAP >getdate())as 'Nedospjele rate',
pog.DOVOL_KM																								 as 'Dozvoljeni km',
pog.CENA_DKM																								 as 'Cijena dod.km',
((select COUNT(*) from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ ='21')/12)*pog.DOVOL_KM		 as 'Ukupno dozvoljeni km',
pog.ID_KUPCA																								 as 'Šif. partnera',
part.naz_kr_kup																								 as 'Partner',
part1.naz_kr_kup																							 as 'Dobavljač',
pog.pred_naj																								 as 'Predmet_ugovora',
zap.ST_SAS																									 as 'Šasija',
zap.reg_stev																								 as 'Reg. oznaka',
zap.KUBIK																								     as 'Zapremnina',
zap.PS_KW																									 as 'Snaga',
zap.LET_PRO																									 as 'God. proizvodnje',
zap.vrsta																									 as 'Vrsta vozila',
pog.NACIN_LEAS																								 as 'Tip financ.',
 (select TIPS.vrednost from POGODBA pog2  JOIN DBO.KATEGORIJE_ENTITETA KAT ON  KAT.ID_ENTITETA=pog.ID_cont  JOIN DBO.KATEGORIJE_TIP TIP ON TIP.ID_KATEGORIJE_TIP=KAT.ID_KATEGORIJE_TIP  JOIN DBO.kategorije_sifrant TIPS ON KAT.id_kategorije_sifrant=TIPS.id_kategorije_sifrant where KAT.ID_KATEGORIJE_TIP= 12 and pog.ID_CONT=pog2.ID_CONT)   as 'Tip kalkulacije održavanja',
 (select TIPS.vrednost from POGODBA pog2  JOIN DBO.KATEGORIJE_ENTITETA KAT ON  KAT.ID_ENTITETA=pog.ID_cont  JOIN DBO.KATEGORIJE_TIP TIP ON TIP.ID_KATEGORIJE_TIP=KAT.ID_KATEGORIJE_TIP   JOIN DBO.kategorije_sifrant TIPS ON KAT.id_kategorije_sifrant=TIPS.id_kategorije_sifrant where KAT.ID_KATEGORIJE_TIP= 14 and  pog.ID_CONT=pog2.ID_CONT)   as  'Tip kalkulacije održavanja guma',
pog.DAT_AKTIV																								 as 'Dat. akt.',
(select min(DATUM_DOK) from PLANP pl where pog.ID_CONT= pl.id_cont)											 as 'Početak',
(select max(DATUM_DOK) from PLANP pl where pog.ID_CONT= pl.id_cont and pl.ID_TERJ in ('23','64'))						 as 'Kraj',
pog.DAT_ZAKL																								 as 'Datum konačnog obračuna(zaključka)',
doc.ZACETEK																									as 'Kasko datum početka',	
doc.VELJA_DO 'Kasko datum isteka',
pog.id_val																									 as 'Valuta',
pog.DEJ_OBR																								 as 'Kam.stopa',
pog.vr_val_zac																							 as 'Iznos financ. poč.',
pog.ROBRESTI_ZAC																						 as 'Početna vrij. PPMV VAL',
(select NETO from PLANP pl where pog.ID_CONT= pl.id_cont and pl.ID_TERJ in ('23','64'))					 as 'Otkup',
(select robresti from PLANP pl where pog.ID_CONT= pl.id_cont and pl.ID_TERJ in ('23','64'))				 as 'Ostatak vrijednosti PPMV',
(select top 1 OBRESTI+NETO from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ ='21')	  			 as 'Leasing rata neto',
(select top 1 robresti from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ ='21')				as 'PPMV rata'	,
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '03')  as 'Održavanje rata neto', 
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '04')  as 'Gume rata neto',
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '12')  as 'Naknada za upravljanje FM neto',
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '08') as  'Odvoz-dovoz vozila neto'	,
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '11') as 'Pomoć na cesti HR rata neto',	
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '13') as 'Pomoć na cesti EU rata neto',	
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '10')as 'Atestiranje VA neto',	
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '09') as  'Zamjensko vozilo neto',
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '05')  as 'Registracija i teh. pregledi', 
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '01')  as 'Obvezno osiguranje', 
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '02') as 'Kasko osiguranje', 
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '06') as 'PCMV', 
(select sum(mes_obrok) from dbo.gv_DodStrPogodba dod where dod.ID_CONT=pog.ID_CONT and id_vrst_dod_str = '07') as 'RTV',
(select  sum(fa.regist)*SUM(mes_obrok)/SUM(SREGIST) from gv_dodstrpogodba stro join NAJEM_FA fa on stro.id_cont =fa.id_cont   where stro.id_cont=pog.ID_CONT  and id_vrst_dod_str in ('03','04','12','08','11','13','10') and fa.ID_TERJ='21' and stro.id_val='HRK')as 'RL FM IFA SAMO ZA DIO USLUGA HRK',
(select  sum(fa.sregist)*SUM(mes_obrok)/SUM(regist) from gv_dodstrpogodba stro join NAJEM_FA fa on stro.id_cont =fa.id_cont   where stro.id_cont=pog.ID_CONT  and id_vrst_dod_str in ('03','04','12','08','11','13','10') and fa.ID_TERJ='21' and stro.id_val='EUR') as 'RL FM IFA SAMO ZA DIO USLUGA'
--(select * from NAJEM_FA izl where izl.ID_CONT=pog.ID_CONT and id_terj=21)
 from POGODBA pog
 inner join partner part on part.id_kupca=pog.ID_KUPCA
  left join partner part1 on part1.id_kupca=pog.ID_DOB
 left join ZAP_REG zap on zap.ID_CONT=pog.ID_CONT
 left join dokument doc on doc.ID_CONT=pog.ID_CONT and ID_OBL_ZAV ='AK' and  doc.STATUS_AKT='A'
  where pog.ID_POG in ('62128/20')

 outer apply (select top 1 * from dokument  where  doc.ID_CONT=pog.ID_CONT and ID_OBL_ZAV ='AK' and  doc.STATUS_AKT='A' order by id_dokum desc) doc

--61919	57565/18   
--68660	62068/19   

 select * from 
 dbo.gv_DodStrPogodba where id_cont in ( '68723') --predviđeni na ponudi+predviđeni dodani na ugovoru

 -- select * from dod_str --predviđeni na ponudi

 select  sum(fa.sregist)*SUM(mes_obrok)/SUM(regist) from gv_dodstrpogodba stro
 join NAJEM_FA fa on stro.id_cont =fa.id_cont 
  where stro.id_cont in ( '68723') and id_vrst_dod_str in ('03','04','12','08','11','13','10') and fa.ID_TERJ='21' --predviđeni dodani na ugovoru
  --and fa.ZAP_OBR in (1,2)

  --pregled dodatnih trošak po ugovoru i šifri
  select * 
  from dbo.ACTUAL_COSTS_FULL_LEAS where id_cont = '68723'

    select TECAJ 
	from NAJEM_FA fa
	join TECAJ tec on tec.id_tec=fa.ID_TEC and fa.DATUM_DOK=tec.datum
	--izlazne fakture
	 where id_cont = '68660' and ID_TERJ='21'
	
	
    select *
	from NAJEM_FA fa
		 where id_cont = '68723' and ID_TERJ='21'
	
	  select * from RAC_OUT where id_cont = '68723' --izlazne fakture

	select * from TECAJ where datum in ('2019-12-01 00:00:00.000','2020-01-01 00:00:00.000') and id_tec='006'

	--select top 10* from dbo.pfn_gmc_Print_InvoiceForInstallments (dbo.gfn_GetDatePart(getdate())) a