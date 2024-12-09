--RLC
select ROUND(pogodba.man_str * @procent / (100 * (select KOR_FAK_MS from loc_nast)) , 2) from dbo.pogodba where id_cont = @id_cont

select ROUND(100 * (select KOR_FAK_MS from loc_nast) * @val / pogodba.man_str , 2) from dbo.pogodba where id_cont = @id_cont





--------
-- OTP


select ROUND(pogodba.man_str * @procent / (100 * (select KOR_FAK_MS from loc_nast)) , 2) from dbo.pogodba where id_cont = @id_cont 

select ROUND(pogodba.man_str * 50 / (100 * (select KOR_FAK_MS from loc_nast)) , 2) from dbo.pogodba where id_cont = 23925 
select ROUND(pogodba.man_str * 50 / 100, 2) from dbo.pogodba where id_cont = 23925 

select ROUND(pogodba.man_str * 50 / 100 * CASE WHEN dbo.gfn_Nacin_leas_HR(pogodba.nacin_leas) = 'OL' THEN (select KOR_FAK_MS from loc_nast) ELSE 1 END, 2) from dbo.pogodba where id_cont = 23925 

select dbo.gfn_Nacin_leas_HR(nacin_leas) RF_TIP_POG, * from nacini_l 

select ROUND(pogodba.man_str * 50 / (100 * 1.25) , 2) from dbo.pogodba where id_cont = 23611 
select ROUND(pogodba.man_str * 50 / (100 * CASE WHEN dbo.gfn_Nacin_leas_HR(pogodba.nacin_leas) = 'OL' THEN (select KOR_FAK_MS from loc_nast) ELSE 1 END), 2) from dbo.pogodba where id_cont = 23611 

select ROUND(100 * (select KOR_FAK_MS from loc_nast) * @val / pogodba.man_str , 2) from dbo.pogodba where id_cont = @id_cont


ZAVRŠNI SELECT ZA TIP PROVIZIJE 
select ROUND(pogodba.man_str * @procent / (100 * CASE WHEN dbo.gfn_Nacin_leas_HR(pogodba.nacin_leas) = 'OL' THEN (select KOR_FAK_MS from loc_nast) ELSE 1 END), 2) from dbo.pogodba where id_cont = @id_cont


select ROUND(100 * CASE WHEN dbo.gfn_Nacin_leas_HR(pogodba.nacin_leas) = 'OL' THEN (select KOR_FAK_MS from loc_nast) ELSE 1 END * @val / pogodba.man_str , 2) from dbo.pogodba where id_cont = @id_cont


begin tran
UPDATE dbo.tipi_prov SET izrac_val = 'select ROUND(pogodba.man_str * @procent / (100 * CASE WHEN dbo.gfn_Nacin_leas_HR(pogodba.nacin_leas) = ''OL'' THEN (select KOR_FAK_MS from loc_nast) ELSE 1 END), 2) from dbo.pogodba where id_cont = @id_cont' where id_tip_prov=3

UPDATE dbo.tipi_prov SET izrac_proc = 'select ROUND(100 * CASE WHEN dbo.gfn_Nacin_leas_HR(pogodba.nacin_leas) = ''OL'' THEN (select KOR_FAK_MS from loc_nast) ELSE 1 END * @val / pogodba.man_str , 2) from dbo.pogodba where id_cont = @id_cont' where id_tip_prov=3
select * from tipi_prov where id_tip_prov=3

--commit