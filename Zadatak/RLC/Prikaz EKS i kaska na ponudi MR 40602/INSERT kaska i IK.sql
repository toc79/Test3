UPDATE CUSTOM_SETTINGS SET val = 'True' where code = 'Nova.LE.OfferCostsDatZap'

INSERT INTO dbo.vrst_ter_fikt(id_stroska,sifra,opis,rac_eom,davek) VALUES('IK','INTK','Interkalarna kamata',1,NULL)

UPDATE dbo.kalk_form_stros SET neaktiven = 1 WHERE id_stroska NOT IN ('KO','IK') OR id_stroska IS NULL

-- KASKO
--F1
INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = ''{kup}''
set @nacin_leas = ''{nl}''
set @fochar = ''{fo}''

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, ''null'') = ''null'' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = ''FO'' then 1 else 0 end
	from dbo.partner p
	inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = ''1'' then 1 else 0 end 

select @add = case when @nacin_leas = ''F1'' and isnull(@je_fo,0) = 1 then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,12,1,0)
--F2
INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = ''{kup}''
set @nacin_leas = ''{nl}''
set @fochar = ''{fo}''

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, ''null'') = ''null'' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = ''FO'' then 1 else 0 end
	from dbo.partner p
	inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = ''1'' then 1 else 0 end 

select @add = case when @nacin_leas = ''F2'' and isnull(@je_fo,0) = 1 then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,12,1,0)

--F3
INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = ''{kup}''
set @nacin_leas = ''{nl}''
set @fochar = ''{fo}''

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, ''null'') = ''null'' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = ''FO'' then 1 else 0 end
	from dbo.partner p
	inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = ''1'' then 1 else 0 end 

select @add = case when @nacin_leas = ''F3'' and isnull(@je_fo,0) = 1 then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,12,1,0)

--F4
INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = ''{kup}''
set @nacin_leas = ''{nl}''
set @fochar = ''{fo}''

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, ''null'') = ''null'' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = ''FO'' then 1 else 0 end
	from dbo.partner p
	inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = ''1'' then 1 else 0 end 

select @add = case when @nacin_leas = ''F4'' and isnull(@je_fo,0) = 1 then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,12,1,0)

--INTERKALARNA KAMATA
--F1
INSERT INTO kalk_form_stros (pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VAlues('declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = ''{kup}''
set @nacin_leas = ''{nl}''
set @fochar = ''{fo}''

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, ''null'') = ''null'' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = ''FO'' then 1 else 0 end
	from dbo.partner p
	inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = ''1'' then 1 else 0 end 

select @add = case when @nacin_leas = ''F1'' and isnull(@je_fo,0) = 1 then 1 else 0 end' 
, '#net_nal'
, 'round((1 + (GF_LOOKUP("dav_stop.davek", GF_ClaimTaxRateID2("SFIN", 0, ponudba.id_dav_st,  #nacin_leas), "dav_stop.id_dav_st")/100)) * lfInterest (#Str_financ_O, Date(), Date() + 30, #Obr_financ, ! GF_CustomSettingsAsBool("IntercalaryInt_UseLinearMethod")), 2)'
, '', 'IK', NULL, NULL, 1, 1, 13, 1, 0)
--F2
INSERT INTO kalk_form_stros (pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VAlues('declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = ''{kup}''
set @nacin_leas = ''{nl}''
set @fochar = ''{fo}''

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, ''null'') = ''null'' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = ''FO'' then 1 else 0 end
	from dbo.partner p
	inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = ''1'' then 1 else 0 end 

select @add = case when @nacin_leas = ''F2'' and isnull(@je_fo,0) = 1 then 1 else 0 end' 
, '#net_nal'
, 'round((1 + (GF_LOOKUP("dav_stop.davek", GF_ClaimTaxRateID2("SFIN", 0, ponudba.id_dav_st,  #nacin_leas), "dav_stop.id_dav_st")/100)) * lfInterest (#Str_financ_O, Date(), Date() + 30, #Obr_financ, ! GF_CustomSettingsAsBool("IntercalaryInt_UseLinearMethod")), 2)'
, '', 'IK', NULL, NULL, 1, 1, 13, 1, 0)
--F3
INSERT INTO kalk_form_stros (pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VAlues('declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = ''{kup}''
set @nacin_leas = ''{nl}''
set @fochar = ''{fo}''

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, ''null'') = ''null'' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = ''FO'' then 1 else 0 end
	from dbo.partner p
	inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = ''1'' then 1 else 0 end 

select @add = case when @nacin_leas = ''F3'' and isnull(@je_fo,0) = 1 then 1 else 0 end' 
, '#net_nal'
, 'round((1 + (GF_LOOKUP("dav_stop.davek", GF_ClaimTaxRateID2("SFIN", 0, ponudba.id_dav_st,  #nacin_leas), "dav_stop.id_dav_st")/100)) * lfInterest (#Str_financ_O, Date(), Date() + 30, #Obr_financ, ! GF_CustomSettingsAsBool("IntercalaryInt_UseLinearMethod")), 2)'
, '', 'IK', NULL, NULL, 1, 1, 13, 1, 0)
--F4
INSERT INTO kalk_form_stros (pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VAlues('declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = ''{kup}''
set @nacin_leas = ''{nl}''
set @fochar = ''{fo}''

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, ''null'') = ''null'' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = ''FO'' then 1 else 0 end
	from dbo.partner p
	inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = ''1'' then 1 else 0 end 

select @add = case when @nacin_leas = ''F4'' and isnull(@je_fo,0) = 1 then 1 else 0 end' 
, '#net_nal'
, 'round((1 + (GF_LOOKUP("dav_stop.davek", GF_ClaimTaxRateID2("SFIN", 0, ponudba.id_dav_st,  #nacin_leas), "dav_stop.id_dav_st")/100)) * lfInterest (#Str_financ_O, Date(), Date() + 30, #Obr_financ, ! GF_CustomSettingsAsBool("IntercalaryInt_UseLinearMethod")), 2)'
, '', 'IK', NULL, NULL, 1, 1, 13, 1, 0)