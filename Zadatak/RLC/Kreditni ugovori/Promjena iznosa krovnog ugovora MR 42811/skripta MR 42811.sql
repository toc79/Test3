-- NOVA_PROD
select  * from KRED_POG WHERE ID_KREDPOG = '0208 18'
/* VAL_ZNES	ID_TEC	TECAJ	SIT_ZNES
20000000.00	5	74.179.890.000	148359780.00
 */

DECLARE @id_kredpog varchar(10)--, @id_tec_new char(3) 
SET @id_kredpog = '0208 18' 

SELECT val_znes, id_tec, tecaj, sit_znes, crpan_znes 
	,  * 
FROM dbo.kred_pog 
WHERE id_kredpog = @id_kredpog 

--SELECT * FROM dbo.kred_planp WHERE id_kredpog = @id_kredpog 

begin tran 
--1. 
UPDATE dbo.kred_pog set val_znes = 20000000.00 WHERE id_kredpog = @id_kredpog 
--2. 
UPDATE kred_pog set sit_znes = tecaj * val_znes WHERE id_kredpog = @id_kredpog 
--commit 
--rollback 
SELECT val_znes, id_tec, tecaj, sit_znes, crpan_znes -- STARO, 7.4828170000*val_znes as sit_znes_new
	,  * 
FROM dbo.kred_pog 
WHERE id_kredpog = @id_kredpog 






--NOVA_TEST
select  * from KRED_POG WHERE ID_KREDPOG = '0184 17'
/* VAL_ZNES	ID_TEC	TECAJ	SIT_ZNES
20000000.00	5	74.179.890.000	148359780.00
 */

DECLARE @id_kredpog varchar(10)--, @id_tec_new char(3) 
SET @id_kredpog = '0184 17' 

SELECT val_znes, id_tec, tecaj, sit_znes, crpan_znes 
	,  * 
FROM dbo.kred_pog 
WHERE id_kredpog = @id_kredpog 

--SELECT * FROM dbo.kred_planp WHERE id_kredpog = @id_kredpog 

begin tran 
--1. 
UPDATE dbo.kred_pog set val_znes = 30000000.00 WHERE id_kredpog = @id_kredpog 
--2. 
UPDATE kred_pog set sit_znes = tecaj * val_znes WHERE id_kredpog = @id_kredpog 
--commit 
--rollback 
SELECT val_znes, id_tec, tecaj, sit_znes, crpan_znes -- STARO, 7.4828170000*val_znes as sit_znes_new
	,  * 
FROM dbo.kred_pog 
WHERE id_kredpog = @id_kredpog 




--Testiranje

select  * from KRED_POG WHERE ID_KREDPOG = '0179 19'
select  * from KRED_POG WHERE ID_KREDPOG = '0180 19'
select  * from KRED_POG WHERE ID_KREDPOG = '0181 19'

DECLARE @id_kredpog varchar(10)--, @id_tec_new char(3) 
SET @id_kredpog = '0180 19' 
--SET @id_tec_new = '024'

SELECT val_znes, id_tec, tecaj, sit_znes, crpan_znes -- STARO, 7.4828170000*val_znes as sit_znes_new
	--, dbo.gfn_VrednostTecaja(@id_tec_new, dat_sklen) AS tecaj_na_dan_sklapanja_za_id_tec_new
	--, dbo.gfn_VrednostTecaja(@id_tec_new, dat_sklen) * val_znes as sit_znes_new
	,  * 
FROM dbo.kred_pog 
WHERE id_kredpog = @id_kredpog 

SELECT * FROM dbo.kred_planp WHERE id_kredpog = @id_kredpog 

begin tran 
--1. 
--UPDATE kred_pog set id_tec = @id_tec_new, tecaj = dbo.gfn_VrednostTecaja(@id_tec_new, dat_sklen) WHERE id_kredpog = @id_kredpog 
UPDATE dbo.kred_pog set val_znes = 2000000.00 WHERE id_kredpog = @id_kredpog 
--2. 
UPDATE kred_pog set sit_znes = tecaj * val_znes WHERE id_kredpog = @id_kredpog 
--3. 
--UPDATE dbo.KRED_PLANP SET id_tec = @id_tec_new WHERE id_kredpog = @id_kredpog 
--commit 
--rollback 
SELECT val_znes, id_tec, tecaj, sit_znes, crpan_znes -- STARO, 7.4828170000*val_znes as sit_znes_new
	,  * 
FROM dbo.kred_pog 
WHERE id_kredpog = @id_kredpog 
select  * from KRED_POG WHERE ID_KREDPOG = '0180 19'
