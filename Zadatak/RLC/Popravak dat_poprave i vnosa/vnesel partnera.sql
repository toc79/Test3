select id_kupca, naz_kr_kup, dat_vnosa,vnesel, dat_poprave 
from dbo.partner 
where ltrim(rtrim(vnesel)) = '' OR vnesel is null
order by id_kupca

-- DROP TABLE #_tmp_partner_vnesel
CREATE TABLE #_tmp_partner_vnesel (
id_kupca varchar(6) NOT NULL, 
vnesel varchar(10) NOT NULL)
INSERT INTO #_tmp_partner_vnesel VALUES ('000772', 'andreas')
INSERT INTO #_tmp_partner_vnesel VALUES ('004866', 'ksenijat')
INSERT INTO #_tmp_partner_vnesel VALUES ('011889', 'elvirap ')

begin tran 
UPDATE dbo.PARTNER SET vnesel = b.vnesel
--Select b.*, a.vnesel, * 
FROM dbo.partner a
JOIN #_tmp_partner_vnesel b ON a.id_kupca = b.id_kupca
--rollback
--commit