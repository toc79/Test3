begin tran
update dbo.KRED_POG set krov_pog_val_znes = val_znes where ID_KREDPOG = '0270 22'
--rollback commit

declare @id_krov_pog varchar(100) = '0249 21'

select krov_pog_val_znes, val_znes, * from dbo.KRED_POG where id_krov_pog = @id_krov_pog or ID_KREDPOG = @id_krov_pog

SELECT   
     A.id_krov_pog, a.ID_KREDPOG, A.crpan_znes, A.krov_pog_val_znes, A.val_znes, dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes) AS exchange
		, A.crpan_znes * dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes) crpan_znes_ex
    FROM   
     dbo.kred_pog as A  
    WHERE   
     tip_pog = 2  
and id_krov_pog = @id_krov_pog

SELECT   
     A.id_krov_pog,  
     SUM(A.crpan_znes * dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes)) AS crpan_znes  
    FROM   
     dbo.kred_pog as A  
    WHERE   
     tip_pog = 2  
and id_krov_pog = @id_krov_pog
    GROUP BY   
     id_krov_pog

begin tran
update dbo.KRED_POG set krov_pog_val_znes = kpp.sum_crpanje
from dbo.KRED_POG kp 
outer apply (select sum(crpanje) as sum_crpanje from dbo.KRED_PLANP where ID_KREDPOG = kp.ID_KREDPOG and crpanje != 0) kpp
where kp.ID_KREDPOG = '0270 22'

select krov_pog_val_znes, val_znes, * from dbo.KRED_POG where id_krov_pog = @id_krov_pog or ID_KREDPOG = @id_krov_pog

SELECT   
     A.id_krov_pog, a.ID_KREDPOG, A.crpan_znes, A.krov_pog_val_znes, A.val_znes, dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes) AS exchange
		, A.crpan_znes * dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes) crpan_znes_ex
    FROM   
     dbo.kred_pog as A  
    WHERE   
     tip_pog = 2  
and id_krov_pog = @id_krov_pog

SELECT   
     A.id_krov_pog,  
     SUM(A.crpan_znes * dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes)) AS crpan_znes  
    FROM   
     dbo.kred_pog as A  
    WHERE   
     tip_pog = 2  
and id_krov_pog = @id_krov_pog
    GROUP BY   
     id_krov_pog

rollback


<?xml version='1.0' encoding='utf-8' ?>
<ccontract_update_credit_amount xmlns="urn:gmi:nova:credit-contracts">
<id_kredpog>TEST_KVNK</id_kredpog>
<new_amount>600000</new_amount>
<activation_date>2023-05-16T00:00:00.000</activation_date>
</ccontract_update_credit_amount>

use nova_hac_new

declare @id_krov_pog varchar(100) = 'TS10470'

select krov_pog_val_znes, val_znes, * from dbo.KRED_POG where id_krov_pog = @id_krov_pog or ID_KREDPOG = @id_krov_pog

SELECT   
     A.id_krov_pog, a.ID_KREDPOG, A.crpan_znes, A.krov_pog_val_znes, A.val_znes, dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes) AS exchange
		, A.crpan_znes * dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes) crpan_znes_ex
    FROM   
     dbo.kred_pog as A  
    WHERE   
     tip_pog = 2  
and id_krov_pog = @id_krov_pog

SELECT   
     A.id_krov_pog,  
     SUM(A.crpan_znes * dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes)) AS crpan_znes  
    FROM   
     dbo.kred_pog as A  
    WHERE   
     tip_pog = 2  
and id_krov_pog = @id_krov_pog
    GROUP BY   
     id_krov_pog