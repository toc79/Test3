begin tran
--brisanje djelatnosti
DELETE FROM dejavnos WHERE LEN(LTRIM(RTRIM(sif_dej)))=5
select * from dejavnos where LEN(LTRIM(RTRIM(sif_dej)))=5 
--brisanje grupa
DELETE FROM dej_grp where dej_grupa in ('IPG','JSS','KGR','OSTO','POT','ZSS')
select * from dej_grp
--commit
--rollback
