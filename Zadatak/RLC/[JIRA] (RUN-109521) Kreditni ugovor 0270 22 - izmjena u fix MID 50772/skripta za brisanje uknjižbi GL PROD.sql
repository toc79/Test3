select id_dnevnik,  * from dbo.gl where konto = '000001'

select * from dbo.gl where id_dnevnik = 'GL_102241'

select sum(DEBIT_DOM) as sum_debit_dom, sum(kredit_dom) as sum_kredit_dom from dbo.gl where id_dnevnik = 'GL_102241'

select * from dbo.GL_PREN_V_GK where st_dnev = 102241

--Generički select 

select id_dnevnik,  * from dbo.gl where konto = '000001'

select * from dbo.gl where id_dnevnik in (select id_dnevnik from dbo.gl where konto = '000001')

select id_dnevnik, sum(DEBIT_DOM) as sum_debit_dom, sum(kredit_dom) as sum_kredit_dom from dbo.gl where id_dnevnik in (select id_dnevnik from dbo.gl where konto = '000001') group by id_dnevnik

select * from dbo.GL_PREN_V_GK where st_dnev in (select convert(int, substring(id_dnevnik,4,999)) as st_dnev from dbo.gl where konto = '000001')

select g.*, r.*
from dbo.oc_gl g
join dbo.oc_reports r on g.id_oc_report = r.id_oc_report
where konto = '000001'

select g.*, r.* 
from rea_prod.dbo.oc_gl g
join rea_prod.dbo.oc_reports r on g.id_oc_report = r.id_oc_report
where konto = '000001' 

-- Skripta za brisanje i popravak
begin tran
select id_dnevnik, convert(int, substring(id_dnevnik,4,999)) as st_dnev, sum(DEBIT_DOM) as sum_debit_dom, sum(kredit_dom) as sum_kredit_dom 
into #lista_dnevnika
from dbo.gl 
where id_dnevnik in (select id_dnevnik from dbo.gl where konto = '000001') group by id_dnevnik
select * from #lista_dnevnika

-- GL delete
delete from dbo.gl where konto = '000001'
select * from dbo.gl where konto = '000001'


-- GL_PREN_V_GK update
select id_dnevnik, convert(int, substring(id_dnevnik,4,999)) as st_dnev, sum(DEBIT_DOM) as sum_debit_dom, sum(kredit_dom) as sum_kredit_dom 
into #suma_po_dnevniku
from dbo.gl 
where id_dnevnik in (select id_dnevnik from #lista_dnevnika) group by id_dnevnik
select * from #suma_po_dnevniku

-- Ako nem adrugih uknjižbi, update se neće napraviti jer više nema tog dnevnika u GL pa treba doraditi update da je 0
update dbo.GL_PREN_V_GK set DEBET = isnull(b.sum_debit_dom, 0), KREDIT = isnull(b.sum_kredit_dom, 0)
from dbo.GL_PREN_V_GK a 
left join #suma_po_dnevniku b on a.ST_DNEV = b.st_dnev
where a.st_dnev in (select st_dnev from #lista_dnevnika)

select * from dbo.GL_PREN_V_GK where st_dnev in (select st_dnev from #lista_dnevnika)
drop table #suma_po_dnevniku
drop table #lista_dnevnika

-- OC_GL delete
delete from dbo.oc_gl where konto = '000001'
delete from rea_prod.dbo.oc_gl where konto = '000001'

select g.*, r.*
from dbo.oc_gl g
join dbo.oc_reports r on g.id_oc_report = r.id_oc_report
where konto = '000001'
select g.*, r.* 
from rea_prod.dbo.oc_gl g
join rea_prod.dbo.oc_reports r on g.id_oc_report = r.id_oc_report
where konto = '000001' 

rollback 							 
