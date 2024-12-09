declare @id_tec char(3), @datum datetime, @okvir varchar(27), @okvir_status int
set @id_tec= '000'
set @datum = getdate()
set @okvir= 'REV'
set @okvir_status= 1

SELECT *
INTO #frames 
FROM dbo.gfn_FrameView(0,0,0,'',1,'19000101',@datum,0,0,'',0,'',0,0,0,0) where 1 = case when @okvir_status = 1 then case when status_akt='A' then 1 else 0 end  else 1 end

select a.id_kupca, a.ext_id id_kupca2, a.naziv1_kup, case when a.vr_osebe = 'SP' then a.stev_reg else '' end as stev_reg,
a.dav_stev as matbr, a.emso as jmbg, a.vr_osebe as vr_osobe, a.skrbnik_2, pov.id_grupe,gp.opis, gp.id_kupca as nositelj_grupe, p1.naziv1_kup as naz_nos_grupe,  
c.dat_eval,left(c.eval_model,2) as eval_model,right(rtrim(c.eval_model),1) as gams_flag,c.tec_limite,
case when year(c.datum_bil)=1899 then null else c.datum_bil end datum_bil,
dbo.gfn_xchange(@id_tec,pbil.prihodki, c.tec_limite, getdate()) prihodki,
dbo.gfn_xchange(@id_tec,pbil.sredstva, c.tec_limite, getdate()) sredstva,
pbil.zaposleno as zaposleno, 
c.limita,
c.rating1, c.rating2, c.uk_rating, c.kateg_b2,c.kategorija1,c.kateg1_opis,c.kategorija2,c.kateg2_opis, c.kategorija3, c.kateg3_opis,
isnull(b.net_nal,0) net_nal,
isnull(d.odr,0) odr, isnull(e.bud_gl,0) bud_gl,isnull(e.pot_net_nal,0) pot_net_nal,  
isnull(f.znesek_val,0) as znesek_val_frame, isnull(f.vr_val,0) as vr_val_frame,
isnull(f.razlika_val,0) as razlika_val_frame ,
isnull(d.odr,0) + isnull(e.bud_gl,0)+ isnull(e.pot_net_nal,0) + isnull(f.razlika_val,0) as uk_izloz,
crs.dat_eval as dat_crs,  crs.oall_ratin as crs, a.neaktiven, a.skrbnik_1, s.naz_kr_kup as skrbnik1_naziv, isnull(z.br_ug,0) as broj_ug, isnull(z.br_akt,0) as broj_akt    
from partner a 
left join dbo.partner s on a.skrbnik_1 = s.id_kupca
Left join 
	(select id_kupca, sum(dbo.gfn_xchange(@id_tec, net_nal, id_tec, getdate())) net_nal from pogodba
	where status_akt = 'A' 
	group by id_kupca) b on a.id_kupca=b.id_kupca 
Left join (Select a.id_kupca, sum(case when a.status_akt in ('A','D','Z') Then 1 ELSE 0 END ) as br_ug,
			sum(case when a.status_akt in ('A','D') then 1 else 0 end) as br_akt
			From dbo.pogodba a
			Where a.status_akt in ('A','D','Z')
			Group by a.id_kupca
) z on a.id_kupca = z.id_kupca		
left join 
	(
	select pe.id_kupca, pe.dat_eval,pe.eval_model,pe.tec_limite,pe.datum_bil,
	dbo.gfn_xchange(@id_tec, pe.limita, pe.tec_limite, getdate()) limita,
	pe.cust_ratin as rating1, 
	pe.coll_ratin as rating2, 
	pe.oall_ratin as uk_rating, 
	pe.asset_clas as kateg_b2,
	pe.kategorija1,
	gr.value as kateg1_opis,
	pe.kategorija2,
	gr2.value as kateg2_opis,
	pe.kategorija3,
	gr3.value as kateg3_opis
	
	from dbo.p_eval pe --NE DIRATI
	inner join 
	(select id_kupca, 
		max(dat_eval) dat_eval 
		from dbo.p_eval --NE DIRATI
		Where eval_type='E' 
		group by id_kupca
	) q on pe.id_kupca=q.id_kupca and pe.dat_eval=q.dat_eval
	left join dbo.general_register gr on pe.kategorija1 = gr.id_key and gr.id_register='P_EVAL_KATEG1'
	left join dbo.general_register gr2 on pe.kategorija2 = gr2.id_key and gr2.id_register='P_EVAL_KATEG2'
	left join dbo.general_register gr3 on pe.kategorija3 = gr3.id_key and gr3.id_register='P_EVAL_KATEG3'

	Where pe.eval_type = 'E'
	) c on a.id_kupca=c.id_kupca
left join (
	select pog.id_kupca, 
	sum(pp.saldo) odr
	from pogodba pog left join (
		select id_cont, sum(dbo.gfn_xchange(@id_tec,saldo, id_tec, getdate())) saldo
		from planp
		where saldo<>0 and dat_zap<=getdate() and evident='*'
		group by id_cont ) pp on pog.id_cont=pp.id_cont
	group by id_kupca) d on a.id_kupca=d.id_kupca
left join (
	select pog.id_kupca, 
	sum(case when status_akt='A' then pp.neto else 0 end) bud_gl,
	sum(case when status_akt ='D' then dbo.gfn_xchange(@id_tec, net_nal, id_tec, getdate()) else 0 end) pot_net_nal

	from pogodba pog left join (
		select id_cont, sum(dbo.gfn_xchange(@id_tec,neto, id_tec, getdate())) neto
		from planp
		where saldo<>0 
		and ((dat_zap>getdate() and (evident='' or evident='*')) or (evident='' and dat_zap<=getdate())) 
		and id_terj in ('21','23','00','20')
		group by id_cont ) pp on pog.id_cont=pp.id_cont
	group by id_kupca) e on a.id_kupca=e.id_kupca
left join dbo.p_bilanc pbil on a.id_kupca=pbil.id_kupca	and c.datum_bil=pbil.datum_bil
left join ( Select id_grupe, id_kupca 
			From 
			(Select id_grupe, id_kupca
			from dbo.pov_part
			group by id_grupe,id_kupca
			UNION ALL
			Select id_grupe, id_kupcab
			from dbo.pov_part
			group by id_grupe,id_kupcab
			) h
			Where id_grupe is not null
			group by id_grupe,id_kupca
) pov on a.id_kupca = pov.id_kupca
left join dbo.grupe_p gp on pov.id_grupe = gp.id_grupe
left join dbo.partner p1 on gp.id_kupca=p1.id_kupca
left join (Select fr.id_kupca, Sum(dbo.gfn_xchange(@id_tec,fr.znesek_val, fr.id_tec, getdate())) as znesek_val, 
		   Sum(dbo.gfn_xchange(@id_tec,fr.vr_val, fr.id_tec, getdate())) as vr_val, 
		   Sum(dbo.gfn_xchange(@id_tec,fr.razlika_val, fr.id_tec, getdate())) as razlika_val 
		   From #frames fr where charindex(fr.sif_frame_type, @okvir)>0 Group By id_kupca
) f on a.id_kupca = f.id_kupca 
LEFT  JOIN (Select a.id_kupca, a.dat_eval, a.oall_ratin
				From dbo.p_eval a
				inner join (Select id_kupca, max(dat_eval) dat_eval
							From dbo.p_eval
							Where eval_type = 'C'
							Group by id_kupca
				) b on a.id_kupca = b.id_kupca and a.dat_eval = b.dat_eval
				where a.eval_type = 'C'
)crs on a.id_kupca = crs.id_kupca 		   
where a.id_kupca not in ('XXXXXX','000000')--c.dat_eval is not null	
and a.id_kupca in ('023878','008526')
order by 1

DROP TABLE #frames