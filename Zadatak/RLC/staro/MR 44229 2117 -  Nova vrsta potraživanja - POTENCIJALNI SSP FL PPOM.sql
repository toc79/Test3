select * from dbo.vrst_ter where id_terj = '75' 
select * from dbo.fakture where id_terj = '75' order by ID_CONT desc
exec dbo.tsp_generate_inserts 'vrst_ter', 'dbo', 'FALSE', '##inserts', 'where id_terj=''75'''
select * from ##inserts
--drop table ##inserts
select * from dbo.RAC_OUT where tip_knjige = 'imar' --DDV_ID = 'N2019010413'
select * from dbo.DAV_STOP where id_dav_st = 'NM'

--INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim,closing_nacin_leas_type,closing_nacin_leas_list) VALUES('75','POTENCIJALNI SSP FL ovj. PPO',9,'120812','121999','PSOF','00',0,'00',0,'','','','','N','N','N','N','N',0,0,0,1,0,0,0,1,0,0,NULL,0,1,0,0,0,0,NULL,NULL,0,NULL,NULL)

--INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim,closing_nacin_leas_type,closing_nacin_leas_list) VALUES('78','POTENCIJALNI SSP FL PPOM',9,'120812','121999','','NM',0,'NM',0,'','','','','N','N','N','N','N',0,0,0,1,0,0,0,1,0,0,NULL,0,1,0,0,0,0,NULL,NULL,0,NULL,NULL)
TREBA PROMJENITI 
dav_N,dav_O,dav_M,dav_R,dav_B
S N NA O 

Declare @tip_knjige varchar(20), @period_enabled bit, @datum_od datetime, @datum_do datetime, @redbr int

Set @tip_knjige = 'IMAR'
Set @period_enabled = 1
Set @datum_od = '20200226'
Set @datum_do = '20200226'

set @redbr = 0

if @period_enabled = 1 
begin
	SET @redbr = (Select count(*) From dbo.rac_out where ddv_date between DATEADD(yyyy, DATEDIFF(yyyy, 0, @datum_od), 0) and dateadd(dd, -1, @datum_od) and tip_knjige = @tip_knjige)
end

Select r.ddv_id, r.ddv_date, r.opiskup, r.dav_stev, r.opisdok, case when sif_rac = 'AKT' and charindex('aktiviranje',opisdok) != 0 then ri.nab_cijena else 0 end as nab_cijena, r.debit as prod_cijena, 
	r.debit_neto+r.debit_davek as marza, r.debit_neto as marza_neto, r.debit_davek as pdv, dbo.gfn_TransformDDV_ID_HR(r.ddv_id, r.ddv_date) As BrojRacFiskal, p.id_pog, p.pred_naj, r.neobdav
	from dbo.rac_out r
		left join dbo.pogodba p on r.id_cont = p.id_cont
		left join (select id_cont, sum(kredit - neobdav) as nab_cijena from dbo.rac_in where tip_knjige = 'VMAR' group by id_cont) ri on r.id_cont = ri.id_cont
	where r.ddv_date between @datum_od and @datum_do and r.tip_knjige = @tip_knjige
Order by r.ddv_id
Select @datum_od as datum_od, @datum_do as datum_do, @tip_knjige as tip_knjige, @redbr as redbr


select top 10 * from dbo.RAC_OUT where id_dav_st = 'NM' --DDV_ID = 'M2020000010' order by 1 desc
--select * from dbo.RAC_OUT where id_dav_st = 'NM' --DDV_ID = 'M2020000005'

select top 100 * from dbo.RAC_OUT where ddv_date >= '20200226' --id_dav_st = 'NM' --DDV_ID = 'M2020000010' order by 1 desc
select top 10 * from dbo.fakture where ID_TERJ = '78'


SELECT * FROM dbo.konti_nl WHERE id_konta IN ('#KRAT7H', '#PRIH7H')
SELECT * FROM dbo.konti_nl WHERE konto IN ('120803', '121999')

INSERT INTO dbo.konti_nl (id_konta, konto)
VALUES ('#KRAT7H', '120803')

INSERT INTO dbo.konti_nl (id_konta, konto)
VALUES ('#PRIH7H', '121999')


--NOVO
--#KRAT78 120812
--#PRIH78N 121999
SELECT * FROM dbo.konti_nl WHERE id_konta IN ('#KRAT78', '#PRIH78N')
SELECT * FROM dbo.konti_nl WHERE konto IN ('120812', '121999')

INSERT INTO dbo.konti_nl (id_konta, konto)
VALUES ('#KRAT78', '120812')

INSERT INTO dbo.konti_nl (id_konta, konto)
VALUES ('#PRIH78N', '121999')