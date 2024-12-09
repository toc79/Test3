begin transaction

DELETE FROM poste WHERE 
((LEFT(id_poste,2)='HR' and LEN(id_poste)<=7) or left(id_poste,4)='HR-0' and not(id_poste='HR-00000')--and LEN(id_poste)<=7)
or naziv='DUMMY' or naziv='' or naziv IS NULL or id_reg IS NULL)


select * from poste where
((LEFT(id_poste,2)='HR' and LEN(id_poste)<=7) or left(id_poste,4)='HR-0' and not(id_poste='HR-00000')--and LEN(id_poste)<=7)
or naziv='DUMMY' or naziv='' or naziv IS NULL or id_reg IS NULL)
ORDER BY id_poste

select * from poste