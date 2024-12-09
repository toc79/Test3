select * from dbo.KRED_POG where ID_KREDPOG = '0252 21'

select * from dbo.KRED_PLANP where ID_KREDPOG = '0252 21' and dat_zap = '20220930' and  ZNES_O > 0

begin tran
update dbo.KRED_PLANP set ANUITETA = 4615.98, ZNES_O = 4615.98 where ID_KREDPOG = '0252 21' and dat_zap = '20220930' and  ZNES_O > 0
select * from dbo.KRED_PLANP where ID_KREDPOG = '0252 21' and dat_zap = '20220930' and  ZNES_O > 0
--rollback commit

SELECT ISNULL(MAX(dat_zap), CAST('19000101' as DATETIME)) 
			  FROM dbo.kred_planp 
			 WHERE (evident = '*' or evident_obr = '*')
			   AND id_kredpog = '0252 21'