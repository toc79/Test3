declare @id_kupca varchar(6), @nacin_leas char(2), @fochar varchar(4)
set @id_kupca = '{kup}'
set @nacin_leas = '{nl}'
set @fochar = '{fo}'

declare @je_fo bit

-- ako parametar za FO nije poslan (na ugovoru) ili ako je id_kupca poslan
-- onda se uvijek provjerava vrsta osebe na partneru
if isnull(@fochar, 'null') = 'null' or len(@id_kupca) > 0
    select @je_fo = case when vo.sifra = 'FO' then 1 else 0 end
    from dbo.partner p
    inner join dbo.vrst_ose vo on p.vr_osebe = vo.vr_osebe
    where p.id_kupca = @id_kupca 
else
    set @je_fo = case when @fochar = '1' then 1 else 0 end 

select @add = case when @nacin_leas = 'F1' and isnull(@je_fo,0) = 1 then 1 else 0 end