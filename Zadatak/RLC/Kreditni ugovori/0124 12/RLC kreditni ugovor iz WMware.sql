--PROMJENA KREDITNOG U KREDITNI, VEZANI NA KROVNI
begin tran
UPDATE kred_pog set tip_pog='2', sit_znes=tecaj*crpan_znes,krov_pog_val_znes=crpan_znes, id_krov_pog='0126 12', val_znes=crpan_znes
where id_kredpog='0124 12' 

--select sit_znes/val_znes*crpan_znes as sit_znes1, tecaj*crpan_znes as sit_znes2 from kred_pog where id_kredpog='0124 12' 

select krov_pog_val_znes,val_znes,crpan_znes,sit_znes,tip_pog,* from kred_pog where id_kredpog in ('0126 12','0124 12')

begin tran
UPDATE gl SET interna_veza='0126 12' where interna_veza='0124 12'
select * from gl where interna_veza='0124 12'

--rollback	
--commit

--krov_pog_val_znes='7884164.00' --> = crpan_znes=
--id_krov_pog='0126 12'
--sit_znes=sit_znes/val_znes*crpan_znes
--58466074.62
--tecaj='7.4156340000'2012-05-08
