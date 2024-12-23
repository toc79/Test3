--BEGIN TRAN
select id_cont, min(id_ss_postopek) as id_ss_postopek_min, count(*)  as br
into #_ss_tpogodba_2
from ss_tpogodba group by id_cont
--select * from #_ss_tpogodba_2

UPDATE _ss_tdogodki_tmp SET id_ss_postopek=b.id_ss_postopek_min
FROM _ss_tdogodki_tmp a
inner join #_ss_tpogodba_2 b on a.id_cont=b.id_cont
--select id_cont, max(id_ss_postopek) as id_ss_postopek_max, count(*)  as br from _ss_tdogodki_tmp group by id_cont

INSERT INTO ss_tdogodki (ID_CONT,OPRAVIL_ST,DATUM,VNESEL,DEBIT,ID_OPIS,OPIS,ST_DOK,ID_PLAC,OBDELAL,KREDIT,TIP_DOGOD,VRS_PLAC,DAT_PLAC,AVTOM,rok,status,id_ss_postopek)
SELECT ID_CONT,OPRAVIL_ST,DATUM,VNESEL,DEBIT,ID_OPIS,OPIS,ST_DOK,ID_PLAC,OBDELAL,KREDIT,TIP_DOGOD,VRS_PLAC,DAT_PLAC,AVTOM,rok,status,id_ss_postopek 
FROM _ss_tdogodki_tmp where id_cont in (select id_cont from #_ss_tpogodba_2)

--rollback
--commit
--drop table #_ss_tpogodba_2
/*
DROP TABLE #_ss_tpogodba_tmp
DROP TABLE #_ss_tplanp_tmp
DROP TABLE _ss_tdogodki_tmp
*/
--DELETE FROM ss_postopek where id_ss_postopek>298
--DBCC CHECKIDENT ( 'ss_postopek', RESEED, 298)
--DBCC CHECKIDENT ( 'ss_postopek', NORESEED )

select * from ss_postopek
select * from ss_tpogodba
select * from ss_tplanp
select * from ss_tdogodki
select * from ss_dogodek where id_ss_postopek!=''