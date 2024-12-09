
begin tran
UPDATE gl_raz_plan SET id_strm='1000' where id_gl_razmej='18242'
select * from gl_razmej where id_gl_razmej='18242'
--commit
select * from gl_razmej where id_strm not in (select id_strm from strm1)
0000

select * from gl_raz_plan where id_strm not in (select id_strm from strm1)

select id_strm, count(*) from gl_razmej where id_strm in (select id_strm from strm1)
group by id_strm

exec sp_helptext grp_gl_deffereditemsvalidate
exec sp_helptext gsp_gl_deferreditemsbooking
exec sp_helptext gfn_GL_ValidateEntry
exec sp_helptext gsp_GL_K_DNEV_2Entries
exec sp_helptext gsp_GL_K_DNEVPI  

SELECT zac_knj FROM dbo.gl_nastavit