--mesto
select a.[id_kupca]
,a.[naz_kr_kup]
,a.[id_poste],a.[mesto],b.[id_poste] 'poste_id_poste',b.naziv 'poste_naziv',b.id_reg 'poste_id_reg'      
FROM [dbo].[PARTNER] a 
inner join poste b
on a.id_poste=b.id_poste where --a.mesto!=b.naziv and
((LEFT(a.id_poste,2)='HR' and LEN(a.id_poste)<=7) or left(a.id_poste,4)='HR-0' 
or b.naziv='DUMMY' or b.naziv='' or b.naziv IS NULL or b.id_reg IS NULL)
ORDER BY a.id_poste
