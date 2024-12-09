-- 09.03.2021 g_tomislav MID 46433

select cast(0 as bit) as Ozn
	, kpp.id_kredpog as Ugovor_kreditni
	, kpp.dat_zap as Datum
	, kpp.anuiteta as Rata
	, kpp.znes_r as Glavnica
	, kpp.znes_o as Kamate
	, kpp.stanje as Stanje 
	, kpp.evident as Knjizeno
	, kpp.placano as Placeno 
	--zbog dodatne rutine
	, kpp.id_kredpog
	, kpp.dat_zap
from dbo.kred_planp kpp
where kpp.znes_r > 0 AND kpp.dat_zap < getdate() AND kpp.evident = '*' AND kpp.placano = 0 AND kpp.is_event = 0
order by kpp.id_kredpog, kpp.dat_zap 