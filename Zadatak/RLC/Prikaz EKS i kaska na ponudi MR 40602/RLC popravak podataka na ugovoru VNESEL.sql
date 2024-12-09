select a.status_akt, cast(sys_ts as bigint) as sys_ts_bigint, a.sys_ts, ISNULL(b.id_frame, 0) as id_frame, dat_podpisa, CAST('20190131' AS datetime) AS dat_podpisa_new, a.opcija_tren, vnesel,* from dbo.pogodba a
LEFT join dbo.frame_pogodba b ON a.id_cont = b.id_cont
where --a.id_cont = 61998

a.id_pog = '58369/19' --62946

select  status_akt, a.sys_ts, dat_podpisa, CAST('20190131' AS datetime) AS dat_podpisa_new, a.opcija_tren, vnesel, * from dbo.arh_pogodba a where id_cont = 62946 order by time 
begin tran
UPDATE dbo.pogodba SET vnesel = 'ksenijat' where id_cont = 62946
--commit