declare @id_kredpog varchar(100) = '0270 22'

-- Provjera podataka
select * from dbo.kred_pog where ID_KREDPOG = @id_kredpog -- nema zapisa u pogodbi 
select * from dbo.KRED_POG_POGODBA_ALLOCATION where id_kredpog = @id_kredpog -- ima 162 zapisa alokacije
select * from dbo.gl where INTERNA_VEZA = @id_kredpog --or st_dok = '' -- 64 zapisa s interna_veza => to može RLC sam internu vezu, i Njihov broj, dok Br. dok ne mogu, ali bi mogli storno i prijenos možda 
select * from dbo.pogodba where ID_KREDPOG = @id_kredpog -- nema zapisa u pogodbi 

select sum(allocated_amount) as sum_alloceted_amount from dbo.KRED_POG_POGODBA_ALLOCATION where id_kredpog = @id_kredpog -- ima 162 zapisa alokacije
 