select * 
into dbo._MR45063_pogodba_kp_npm_ALL
from dbo.pogodba_kp_npm

select * 
into dbo._MR45063_pogodba_kp_npm
from dbo.pogodba_kp_npm  pkpn
where  exists (
select * from fakture a 
where DDV_ID is null and DATUM_DOK > '20200628'
and exists (select * from dbo.POGODBA where nacin_leas in (select nacin_leas from NACINI_L where eom_npm_zero = 1) and ID_CONT = a.id_cont )
and id_cont = pkpn.id_cont) 

select a.* 
into dbo._MR45063_fakture
from fakture a 
join dbo.POGODBA p on a.ID_CONT= p.id_cont
where a.DDV_ID is null and a.DATUM_DOK > '20200628'
and nacin_leas in (select nacin_leas from NACINI_L where eom_npm_zero = 1)
--and exists (select * from dbo.POGODBA where nacin_leas in (select nacin_leas from NACINI_L where eom_npm_zero = 1) and ID_CONT = a.id_cont )
--and id_cont = pkpn.id_cont


select * from dbo.pogodba_kp_npm  pkpn
where  exists (
select * from fakture a 
where DDV_ID is null and DATUM_DOK > '20200628'
and exists (select * from dbo.POGODBA where nacin_leas in (select nacin_leas from NACINI_L where eom_npm_zero = 1) and ID_CONT = a.id_cont )
and id_cont = pkpn.id_cont) 


promjena u logu se desila na 
 update dbo.pogodba_kp_npm set  npm = -0.9044 ,  ef_obrm_npm = 0.8385 ,  passive_interest_rate_npm = 1.7429   where  id_pogodba_kp_npm = 8278 

INSERT INTO dbo.reprogram (id_rep_type, [time], [user], id_cont, old_sys_ts, comment, id_kupca, id_rep_category, id_dokum, id_odobrit)                   
VALUES ('UPD', '2020-06-30T12:36:50', 'g_tomislav', 48240, '444160037', 'Promjena trenutne EKS', '029115', '999', NULL, NULL)

update dbo.reprogram set   auto_desc = 'Stara trenutna NPM: -1,7429 -> Nova trenutna NPM: -0,9044 @ 18.06.2014; Stara trenutna EKS za NPM: 0,0000 -> Nova trenutna EKS za NPM: 0,8385;' where  id_reprogram = 1664327

 
 
 
 --string nacini_l_eom_neto = session.DBHelper.GetCustomSetting("Nova.CContracts.CalcEOM4NPM.FinTypeEOMNetoOverride").EmptyIfNull();
 --           string vrst_ter_eom_exclude = session.DBHelper.GetCustomSetting("Nova.CContracts.CalcEOM4NPM.ExcludeClaims").EmptyIfNull();

select * from dbo.CUSTOM_SETTINGS where code = 'Nova.CContracts.CalcEOM4NPM.FinTypeEOMNetoOverride' --OA,OG,OJ

update dbo.CUSTOM_SETTINGS set val = 'OA,OG,OJ' where code = 'Nova.CContracts.CalcEOM4NPM.FinTypeEOMNetoOverride'

select * from dbo.CUSTOM_SETTINGS where code = 'Nova.CContracts.CalcEOM4NPM.ExcludeClaims'

select eom_npm_zero, * from NACINI_L

update dbo.NACINI_L set eom_npm_zero= 0  where nacin_leas = 'NF' --bilo je 1

vratio na 1
update dbo.NACINI_L set eom_npm_zero= 1  where nacin_leas = 'NF' --bilo je 1


Stara trenutna NPM: -1,7429 -> Nova trenutna NPM: -0,9044 @ 18.06.2014; Stara trenutna EKS za NPM: 0,0000 -> Nova trenutna EKS za NPM: 0,8385;                                                                                                  


select * from dbo.pogodba_kp_npm  where  id_cont = 48240
select * from dbo.kred_pog_pogodba_allocation  where  id_pogodba_kp_npm = 8278  and  is_canceled = 0 
select * from dbo.kred_pog where id_kredpog = '0142 14'
select p.dat_pol, p.*, par.vr_osebe                             
from dbo.pogodba p                             
inner join dbo.partner par on par.id_kupca = p.ID_KUPCA                             
where p.id_cont = 48240


select eom_neto, * from dbo.kalk_form 



select * from dbo.pogodba_kp_npm  where  id_cont = 48240
select * from dbo.kred_pog_pogodba_allocation  where  id_pogodba_kp_npm = 8278  and  is_canceled = 0 
select * from dbo.kred_pog where id_kredpog = '0142 14'
select p.dat_pol, p.*, par.vr_osebe                             
from dbo.pogodba p                             
inner join dbo.partner par on par.id_kupca = p.ID_KUPCA                             
where p.id_cont = 48240


select * from dbo.pogodba_kp_npm  where  id_cont = 68767 
select * from dbo.kred_pog_pogodba_allocation  where  id_pogodba_kp_npm = 24584  and  is_canceled = 0 
select * from dbo.kred_pog where id_kredpog = '0236 20'
select p.dat_pol, p.*, par.vr_osebe                             
from dbo.pogodba p                             
inner join dbo.partner par on par.id_kupca = p.ID_KUPCA                             where p.id_cont = 68767
select eom_neto, * from dbo.kalk_form where nacin_leas = 'OF'


select * from dbo.CUSTOM_SETTINGS where code = 'GeneralInvoice.UpdateVnesel'

select eom_neto, * from dbo.kalk_form where nacin_leas = 'OF'
select eom_npm_zero, * from NACINI_L

exec dbo.tsp_generate_inserts 'NACINI_L', 'dbo', 'FALSE', '##inserts', 'where 1=''1'''
select * from ##inserts
--drop table ##inserts

select nacin_leas,* from dbo.pogodba where  id_cont = 49022