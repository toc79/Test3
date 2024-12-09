-- u Candidates èak i ne treba zapisati id-jeve (doc_id) jer bi trebao biti kompozitni kljuè 
select zo.id_opom, pogp.id_poroka, pogp.oznaka
	, convert(varchar(30), zo.id_opom) + ';' + pogp.id_poroka as id_ispis
from dbo.za_opom zo
	inner join dbo.pog_poro pogp on zo.id_cont = pogp.id_cont
where zo.st_opomina in (1,2,3)
	and isnull(zo.dok_opom, '') != ''
	and pogp.neaktiven = 0
	and pogp.oznaka in ('0', '1')

union all

select zo.id_opom, pogp.id_poroka, pogp.oznaka
	, convert(varchar(30), zo.id_opom) + ';' + pogp.id_poroka as id_ispis
from dbo.za_opom zo
	inner join dbo.pog_poro pogp on zo.id_cont = pogp.id_cont
where zo.st_opomina in (1,2,3)
	and isnull(zo.dok_opom, '') != ''
	and pogp.neaktiven = 0
	and pogp.oznaka in ('A')