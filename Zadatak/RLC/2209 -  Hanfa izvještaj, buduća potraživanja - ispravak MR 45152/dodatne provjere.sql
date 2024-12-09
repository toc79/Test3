select ID_CONT, * from dbo.oc_contracts 
where id_oc_report = 2750
--and ID_POG in ('62772/20', '54888/17') 
and id_cont in (59151)

select ID_CONT, * from dbo.oc_claims
where id_oc_report = 2750
--and ID_POG in ('62772/20', '54888/17') 
and id_cont in (59151)

select ID_CONT, * from dbo.oc_contracts 
where id_oc_report = 2750
--and ID_POG in ('62772/20', '54888/17') 
and id_cont in (69455)

select ID_CONT, * from dbo.oc_claims
where id_oc_report = 2750
--and ID_POG in ('62772/20', '54888/17') 
and id_cont in (69455)

select * from dbo.oc_reports
where id_oc_report = 2750


select * from dbo.ARH_PLANP where ST_DOK ='62772/20-21-005R01' order by TIME 

select * from dbo.custom_settings where code like '%close%' 

select  * from nastavit
select close_on_datum_dok, * from LOC_NAST