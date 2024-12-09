--skripte za produkciju
INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim,closing_nacin_leas_type,closing_nacin_leas_list,used_as_interests,discont_early_buyout) VALUES('2P','NAKNADA PO KONAČNOM OBRAČUNU',9,'#KRATTER','!!!!!!!!','','25',0,'00',0,'','','','','D','D','D','D','D',0,0,0,1,0,0,0,0,1,0,NULL,0,1,0,0,0,0,NULL,NULL,0,NULL,NULL,0,NULL)
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F1','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F2','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F3','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F4','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F5','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OA','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OJ','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OR','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OF','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OG','#PRIH2PN','752403')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F1','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F2','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F3','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F4','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F5','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OA','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OJ','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OR','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OF','#PRIH2PM','750102')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OG','#PRIH2PM','750102')

begin tran
declare @IDTerj char(2), @konto_vrst_ter char(8), @protikonto_vrst_ter char(8),
@protikonto_NORB char(8), @protikonto_M char(8)

set @IDTerj = '2P' --OBAVEZNO POPRAVITI VRSTU POTRAŽIVANJA KAD KORISTIŠ SKRIPTU!!!!!!!!
print @IDTerj

Select protikonto from dbo.vrst_ter where id_terj = @IDTerj
Select * from dbo.konti_nl where id_konta = '#PRIH2PN'
Select * from dbo.konti_nl where id_konta = '#PRIH2PM' or id_konta = 'PRIH2PN'
set @konto_vrst_ter = (select top 1 konto from dbo.vrst_ter where id_terj=@IDTerj) print @konto_vrst_ter
set @protikonto_vrst_ter = (select top 1 protikonto from dbo.vrst_ter where id_terj=@IDTerj) print @protikonto_vrst_ter
set @protikonto_NORB = '#PRIH2PN'
print @protikonto_NORB
set @protikonto_M = '#PRIH2PM'
print @protikonto_M

insert into dbo.plan_knj (nacin_leas, id_terj, akt_storno, id_dogodka, deli_terjatve, konto, stran_k, protikonto, stran_p, opis, vrsta_dok) (select nacin_leas, @IDTerj, akt_storno, id_dogodka, 'NORB', @konto_vrst_ter, stran_k, @protikonto_NORB, stran_p, opis, vrsta_dok from dbo.plan_knj where id_dogodka='ZAPADE_OST' and deli_terjatve='NOMRB' and id_terj is null)
insert into dbo.plan_knj (nacin_leas, id_terj, akt_storno, id_dogodka, deli_terjatve, konto, stran_k, protikonto, stran_p, opis, vrsta_dok) (select nacin_leas, @IDTerj, akt_storno, id_dogodka, 'M', @konto_vrst_ter, stran_k, @protikonto_M, stran_p, opis, vrsta_dok from dbo.plan_knj where id_dogodka='ZAPADE_OST' and deli_terjatve='NOMRB' and id_terj is null)
insert into dbo.plan_knj (nacin_leas, id_terj, akt_storno, id_dogodka, deli_terjatve, konto, stran_k, protikonto, stran_p, opis, vrsta_dok) (select nacin_leas, @IDTerj, akt_storno, id_dogodka, deli_terjatve, @konto_vrst_ter, stran_k, protikonto, stran_p, opis, vrsta_dok from dbo.plan_knj where id_dogodka='ZAPADE_OST' and deli_terjatve='D' and id_terj is null)

select * from dbo.plan_knj where ID_TERJ = @IDTerj
--rollback
--commit

--kraj skripte za produkciju



exec dbo.Tsp_generate_inserts @t_name = 'vrst_ter', @where_stmt = 'where id_terj = ''53''', @append = 0
exec dbo.Tsp_generate_inserts @t_name = 'konti_nl', @where_stmt = 'where id_konta = ''#PRIH53M'' or id_konta = ''#PRIH53N''', @append = 0
select * from ##inserts

--potraživanje 53


INSERT INTO dbo.vrst_ter(id_terj,naziv,prioriteta,konto,protikonto,sif_terj,id_dav_st,vez_na_pog,dav_izvoz,vrstni_red,opombe,naziv_tuj1,naziv_tuj2,naziv_tuj3,dav_N,dav_O,dav_M,dav_R,dav_B,fakt_aktiv,vnajem_fa,ali_v_rpg,ali_v_splf,placilo,dd_included,id_dav_st_pog,rac_eom,requires_full_activation,exclude_from_zobr,dav_x_pog,use_vr_prom_b,include_in_index_paym_indisc,neaktiven,ne_zobr_obresti,ignore_close_on_datum_dok,ima_robresti,closing_claims_type,closing_claims_list,split_initial_claim,closing_nacin_leas_type,closing_nacin_leas_list,used_as_interests,discont_early_buyout) VALUES('53','DODATNI TROŠKOVI-FLEET',9,'#KRATTER','!!!!!!!!','','25',0,'00',0,'','','','','D','D','D','D','D',0,0,0,1,0,0,0,0,1,0,NULL,0,1,0,0,0,0,NULL,NULL,0,NULL,NULL,0,NULL)

INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F1','#PRIH53N','762007')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F2','#PRIH53N','762007')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F3','#PRIH53N','762007')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F4','#PRIH53N','762007')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F5','#PRIH53N','762007')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OA','#PRIH53N','752005')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OJ','#PRIH53N','752005')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OR','#PRIH53N','762013')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OF','#PRIH53N','762013')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OG','#PRIH53N','752005')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F1','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F2','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F3','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F4','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('F5','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OA','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OJ','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OR','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OF','#PRIH53M','771208')
INSERT INTO dbo.konti_nl(NACIN_LEAS,ID_KONTA,KONTO) VALUES('OG','#PRIH53M','771208')