declare @id_tec_eur char(3), @id_terj_LOBR char(2)

set @id_tec_eur= (select id_tec from TECAJNIC where id_tec='006')
set @id_terj_LOBR = (select id_terj from VRST_TER where sif_terj='LOBR')

select bure.idcont,bure.novo,bure.nobrok	
	into #rep from	
	(select pp.id_cont idcont,pp.ZAP_OBR nobrok, pp.REGIST novo,pp1.zap_obr,pp1.REGIST staro 
	from PLANP pp	
	join PLANP pp1 on pp.ID_CONT=pp1.ID_CONT and pp.ZAP_OBR=pp1.ZAP_OBR+1 and pp.ID_TERJ=@id_terj_LOBR and pp1.ID_TERJ=@id_terj_LOBR	where  pp.REGIST >=0	and pp1.REGIST >0	
	and pp.REGIST !=pp1.REGIST	and  pp1.REGIST - pp.REGIST>1		--and pp.ID_CONT=39144
	group by  pp.id_cont, pp.REGIST, pp1.REGIST,pp.ZAP_OBR ,pp1.zap_obr		union	select  pp.id_cont,pp.ZAP_OBR, pp.REGIST staro,pp1.zap_obr,pp1.REGIST novo 	from PLANP pp
	join PLANP pp1 on pp.ID_CONT=pp1.ID_CONT and pp.ZAP_OBR=pp1.ZAP_OBR+1 and pp.ID_TERJ=@id_terj_LOBR and pp1.ID_TERJ=@id_terj_LOBR	where  pp.REGIST >=0	and pp1.REGIST >0	
	and pp.REGIST !=pp1.REGIST	and  pp.REGIST- pp1.REGIST >1	--and pp.ID_CONT=39144
	group by  pp.id_cont, pp.REGIST, pp1.REGIST,pp.ZAP_OBR ,pp1.zap_obr
		) bure
		order by bure.nobrok asc

select a.id_cont,id_vrst_dod_str, sum(dbo.gfn_xchange( case when a.ID_TEC!= @id_tec_eur then @id_tec_eur else a.ID_TEC end ,mes_obrok,a.ID_TEC,b.DAT_SKLEN)) MES_OBR_EUR 
into #DOD_STR_EUR
from dbo.gv_DodStrPogodba a
join POGODBA b on a.id_cont=b.ID_CONT
 group by id_vrst_dod_str,a.id_cont


select ID_CONT,KREDIT_DOM 
into #prodani
from GL where
OPISDOK ='000.PRODAJA OBJEKTA TP'

--ulaz samo dio---
	SELECT  po.id_cont,    
		sum(f.amount) 'RL FM UFA SAMO ZA DIO USLUGA'
		into #full
FROM       
  dbo.POGODBA po
   join dbo.actual_costs_full_leas f on po.id_cont = f.id_cont 
   join dbo.vrst_dod_str v on f.id_vrst_dod_str = v.id_vrst_dod_str
   where  f.id_vrst_dod_str in ('03','04','12','08','11','13','10','09')
group by po.id_cont  	

 --izlaz samo dio---sum(fa.sregist)*SUM(mes_obrok)/case when SUM(regist)=0 then 1 else SUM(regist)end  as 'RL FM IFA SAMO ZA DIO USLUGA' 
 select   fa.id_cont,sum(dbo.gfn_xchange( '000' ,s.mes_obr,s.id_tec,fa.DATUM_DOK)) as 'RL FM IFA SAMO ZA DIO USLUGA' 
 into #izlaz
 from NAJEM_FA fa
 inner join (select id_cont,id_tec, SUM(mes_obrok) mes_obr from gv_dodstrpogodba where id_vrst_dod_str in ('03','04','12','08','11','13','10','09') group by id_cont,id_tec) s on s.id_cont=fa.id_cont
  where fa.ID_TERJ='21' and fa.DATUM_DOK <= GETDATE() 	
    group by fa.id_cont

--svi dodatni ulaz----

SELECT  f.id_cont,    
		sum(f.amount) 'UKUPNO UFA ZA SVE DODATNE USLUGE'
		into #svi_ulaz
FROM     dbo.actual_costs_full_leas f 
group by f.id_cont

  ---svi dodatni izlaz----
  select p.ID_CONT, sum(SREGIST) dod_usl_Kn 
  into #svi_dodatni
   from NAJEM_FA p      
  where ID_CONT in (select ID_CONT from gv_dodstrpogodba)
  and p.ID_TERJ=@id_terj_LOBR and p.DATUM_DOK <= GETDATE() group by p.ID_CONT

---glavni---

select distinct pog.id_cont,
pog.ID_POG																													as [Ugovor],
pog.ID_PON																													as [Ponuda_br],
pog.STATUS_AKT																												as [Akt],
(select COUNT(*) from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ =@id_terj_LOBR)								as [Br_rata],
(select COUNT(*) from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ =@id_terj_LOBR and pl.DAT_ZAP <=getdate())		as [Dospjele_rate],
(select COUNT(*) from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ =@id_terj_LOBR  and pl.DAT_ZAP >getdate())		as [Nedospjele_rate],
pog.DOVOL_KM																												as [Dozvoljeni_km],
pog.CENA_DKM																												as [Cijena_dod_km],
((select COUNT(*) from PLANP pl where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ =@id_terj_LOBR )/12)*pog.DOVOL_KM				as [Ukupno_dozvoljeni_km],
pog.ID_KUPCA																												as [Šif_partnera],
part.naz_kr_kup																												as [Partner],
part1.naz_kr_kup																											as [Dobavljač],
pog.pred_naj																												as [Predmet_ugovora],
zap.ST_SAS																													as [Šasija],
zap.reg_stev																												as [Reg_oznaka],
zap.KUBIK																													as [Zapremnina],
zap.PS_KW																													as [Snaga],
zap.LET_PRO																													as [God_proizvodnje],
zap.vrsta																													as [Vrsta_vozila],
pog.NACIN_LEAS																												as [Tip_financ],
coalesce( (select TIPS.vrednost from POGODBA pog2  JOIN DBO.KATEGORIJE_ENTITETA KAT ON  KAT.ID_ENTITETA=pog.ID_cont  
JOIN DBO.KATEGORIJE_TIP TIP ON TIP.ID_KATEGORIJE_TIP=KAT.ID_KATEGORIJE_TIP  JOIN DBO.kategorije_sifrant TIPS 
ON KAT.id_kategorije_sifrant=TIPS.id_kategorije_sifrant where KAT.ID_KATEGORIJE_TIP= 12 and pog.ID_CONT=pog2.ID_CONT),'')    as [Tip_kalkulacije_održavanja],
coalesce(  (select TIPS.vrednost from POGODBA pog2  JOIN DBO.KATEGORIJE_ENTITETA KAT ON  KAT.ID_ENTITETA=pog.ID_cont  
JOIN DBO.KATEGORIJE_TIP TIP ON TIP.ID_KATEGORIJE_TIP=KAT.ID_KATEGORIJE_TIP   JOIN DBO.kategorije_sifrant TIPS 
ON KAT.id_kategorije_sifrant=TIPS.id_kategorije_sifrant where KAT.ID_KATEGORIJE_TIP= 14 and  pog.ID_CONT=pog2.ID_CONT),'')   as  [Tip_kalkulacije_održavanja_guma],
pog.DAT_AKTIV																												 as [Dat_akt],
(select min(DATUM_DOK) from PLANP pl where pog.ID_CONT= pl.id_cont and pl.ID_TERJ in (@id_terj_LOBR ))						 as [Početak],
(select max(DATUM_DOK) from PLANP pl where pog.ID_CONT= pl.id_cont and pl.ID_TERJ in ('23','64'))							 as [Kraj],
pog.DAT_ZAKL																												 as [Datum_konačnog_obračuna],
doc.ZACETEK																													 as [Kasko_datum_početka],	
doc.VELJA_DO																												 as	[Kasko_datum_isteka],
pog.id_val																													 as [Valuta],
pog.DEJ_OBR																													 as [Kam_stopa],
dbo.gfn_xchange(@id_tec_eur,pog.net_nal_zac,pog.ID_TEC,pog.dat_sklen)														 as [Iznos_financ_poč_EUR],
dbo.gfn_xchange(@id_tec_eur,pog.ROBRESTI_ZAC,pog.ID_TEC,pog.dat_sklen)														 as [Početna_vrij_PPMV_EUR],
dbo.gfn_xchange(@id_tec_eur,pog.OPCIJA,pog.ID_TEC,pog.dat_sklen)															 as [Otkup_EUR],
dbo.gfn_xchange(@id_tec_eur,(select sum(robresti) from PLANP pl where
 pog.ID_CONT= pl.id_cont and pl.ID_TERJ in ('23','64')),pog.ID_TEC,pog.dat_sklen)											 as [Ostatak_vrijednosti_PPMV_EUR],
dbo.gfn_xchange(@id_tec_eur ,(select top 1 OBRESTI+NETO from PLANP pl 
where pog.ID_CONT= pl.id_cont and  pl.ID_TERJ =@id_terj_LOBR ),pog.ID_TEC,pog.dat_sklen)		  							 as [Leasing_rata_neto_EUR],
dbo.gfn_xchange(@id_tec_eur ,(select top 1 robresti from PLANP pl where
 pog.ID_CONT= pl.id_cont and  pl.ID_TERJ =@id_terj_LOBR ),pog.ID_TEC,pog.dat_sklen)											 as [PPMV_rata_EUR]	,
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '03'),0)			 as [Održavanje_rata_neto_EUR], 
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '04'),0)			 as [Gume_rata_neto_EUR],
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '12'),0)			 as [Naknada_za_upravljanje_FM_neto_EUR],
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '08'),0)			 as [Odvoz_dovoz_vozila_neto_EUR]	,
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '11'),0)			 as [Pomoć_na_cesti_HR_rata_neto_EUR],	
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '13'),0)			 as [Pomoć_na_cesti_EU_rata_neto_EUR],	
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '10'),0)			 as [Atestiranje_VA_neto_EUR],	
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '09'),0)			 as [Zamjensko_vozilo_neto_EUR],
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '05'),0)			 as [Registracija_i_teh_pregledi_EUR], 
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '01'),0)			 as [Obvezno_osiguranje_EUR], 
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '02'),0)			 as [Kasko_osiguranje_EUR], 
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '06'),0)			 as [PCMV_EUR], 
isnull((select MES_OBR_EUR from #DOD_STR_EUR dod where dod.ID_CONT=pog.ID_CONT and dod.id_vrst_dod_str = '07'),0)			 as [RTV_EUR],
isnull(izl.[RL FM IFA SAMO ZA DIO USLUGA],0)																				 as [RL_FM_IFA_SAMO_ZA_DIO_USLUGA_Kn],
isnull(ful.[RL FM UFA SAMO ZA DIO USLUGA],0)																				 as [RL_FM_UFA_SAMO_ZA_DIO_USLUGA_Kn],
isnull(ful.[RL FM UFA SAMO ZA DIO USLUGA],0)-isnull(izl.[RL FM IFA SAMO ZA DIO USLUGA],0)										as [RL_FM_ukupno_UFA_IFA_neto_Kn],			
(isnull(ful.[RL FM UFA SAMO ZA DIO USLUGA],0)-isnull(izl.[RL FM IFA SAMO ZA DIO USLUGA],0))*1.25								as [RL_FM_ukupno_UFA_IFA_bruto_Kn],
isnull(svi.dod_usl_Kn,0)																										as [UKUPNO_IFA_ZA_SVE_DOD_USLUGE_Kn],
isnull(ul.[UKUPNO UFA ZA SVE DODATNE USLUGE],0)																					as [UKUPNO_UFA_ZA_SVE_DODATNE_USLUGE_Kn],
isnull(ul.[UKUPNO UFA ZA SVE DODATNE USLUGE],0)-isnull(svi.dod_usl_Kn,0)														as [UKUPNO_UFA_IFA_neto_Kn],
(isnull(ul.[UKUPNO UFA ZA SVE DODATNE USLUGE],0)-isnull(svi.dod_usl_Kn,0))*1.25													as [UKUPNO_UFA_IFA_bruto_Kn],	
isnull(dbo.gfn_xchange('000' ,(select NETO from PLANP pl 
where pog.ID_CONT= pl.id_cont and pl.ID_TERJ in ('2I')),kon.ID_TEC,pog.dat_sklen),0)											as [Iznos_po_KO_DOD_usluge_bez_PDV_Kn],
isnull(pr.KREDIT_DOM,0)																											as [Iznos_prodaje_vozila_Kn],
part.ulica_sed																													as [Adresa_partnera],
part.id_poste_sed																												as [Pošta],
part.mesto_sed																													as [Mjesto],
part.ulica																														as [Adresa_slanje],
part.id_poste																													as [Pošta_slanje],
part.mesto																														as [Mjesto_slanje],
pog.id_posrednik																												as [Posrednik],
pos.value_desc																													as [Naziv_posrednika],
 (select CASE WHEN a.id_posrednik IN ('RBAF', 'FLT', 'DOBF') THEN 'FLEET' ELSE '' END as tip_leas 
  from POGODBA a where a.id_cont=pog.id_cont)																					as [Tip_financiranja],
DOD.ukupni_trosak_EUR																											as [Dodatni_troškovi_EUR],
(select top 1 novo from #rep rep where rep.IDCONT=pog.ID_CONT)																	as [Dod_usluge_promjena]
--case when pog.id_cont in(select idcont from #rep)  then 'Da' else 'Ne' end														as [Reprogram]
 from 
 (select p.id_cont,dbo.gfn_xchange(@id_tec_eur,pl.dod_tro,pl.ID_TEC,p.dat_sklen) ukupni_trosak_EUR
from pogodba p 
join (select id_cont,max(id_tec) id_tec, SUM(regist) dod_tro ,COUNT(*) broj_rata 
		from PLANP 
		where id_cont in  (select distinct id_cont from gv_dodstrpogodba)group by ID_CONT) pl on pl.ID_CONT=p.id_cont ) dod
 INNER JOIN dbo.pogodba AS pog ON dod.id_cont = pog.id_cont
 inner join dbo.partner part on part.id_kupca=pog.ID_KUPCA
 left join dbo.partner part1 on part1.id_kupca=pog.ID_DOB
 left join dbo.ZAP_REG zap on zap.ID_CONT=pog.ID_CONT
 left join dbo.dokument doc on doc.ID_CONT=pog.ID_CONT and ID_OBL_ZAV ='AK' and  doc.STATUS_AKT='A'
 left join 	(SELECT id_key, DBO.gfn_StringToFOX(value) AS value_desc  FROM dbo.general_register	WHERE id_register = 'P_POSREDNIK') pos on pos.ID_KEY = pog.id_posrednik
 left join #full ful on ful.ID_CONT=pog.ID_CONT
 left join #izlaz izl on izl.ID_CONT=pog.ID_CONT
 left join #svi_dodatni svi on svi.ID_CONT=pog.ID_CONT
 left join #svi_ulaz ul on ul.id_cont=pog.ID_CONT
 left join #prodani pr on pr.id_cont=pog.ID_CONT
 left join (select id_cont, id_tec from PLANP pl where pl.ID_TERJ in ('2I')) kon on pog.ID_CONT=kon.id_cont
 --where ID_POG = '48626/15'

drop table #rep
drop table #full
drop table #izlaz
drop table #svi_ulaz
drop table #svi_dodatni
drop table #prodani
drop table #DOD_STR_EUR