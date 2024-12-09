select id_cont, st_dok, datum_dok, dat_zap, cast('20190821' as datetime) AS dat_zap_new 
FROM dbo.planp 
where datum_dok = '20190801' 
AND EXISTS (select * from dbo._tmp_ugovori where id_cont = planp.id_cont)
AND dat_zap = '20190809'
AND evident != '*'
order by id_cont

SELECT a.id_cont, dni_zap, 20 as dni_zap_new, a.id_pog FROM dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_pog = b.id_pog --129 na prod
WHERE a.id_cont not in (
	select id_cont /*, st_dok, datum_dok, dat_zap, cast('20190821' as datetime) AS dat_zap_new */
	FROM dbo.planp 
	where datum_dok = '20190801' 
	AND EXISTS (select * from dbo._tmp_ugovori where id_cont = planp.id_cont)
	AND dat_zap = '20190809'
	AND evident != '*'
	AND id_terj = '21'
)

order by id_cont



SELECT a.id_cont, dni_zap, 20 as dni_zap_new FROM nova_prod.dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_pog = b.id_pog --129 na prod
WHERE a.id_cont not in (

select id_cont , st_dok, datum_dok, dat_zap, cast('20190821' as datetime) AS dat_zap_new 
FROM nova_prod.dbo.planp 
where datum_dok = '20190801' 
AND EXISTS (select * from dbo._tmp_ugovori where id_cont = planp.id_cont)
AND dat_zap = '20190809'
AND evident != '*'
AND id_terj = '21'
)
order by id_cont

SELECT * FROM dbo._tmp_ugovori --129
SELECT a.id_cont, dni_zap, 20 as dni_zap_new FROM dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_cont = b.id_cont --85 na testu
SELECT a.id_cont, dni_zap, 20 as dni_zap_new FROM nova_prod.dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_pog = b.id_pog --129 na prod

SELECT a.id_cont, a.dni_zap, 20 as dni_zap_new,  dbo.gfn_GetContractDataHash(a.id_cont) as pogodba_hash FROM dbo.pogodba a
JOIN dbo._tmp_ugovori b ON a.id_cont = b.id_cont