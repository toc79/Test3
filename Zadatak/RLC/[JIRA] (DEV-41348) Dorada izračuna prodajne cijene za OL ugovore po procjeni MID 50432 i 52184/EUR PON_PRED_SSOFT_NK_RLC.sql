DECLARE @ukupno_bez_ppmv decimal(18,2), @ukupno_ppmv decimal(18,2)

SET @ukupno_bez_ppmv = (@NEZAPADLO_VOPC_DISK_VRED_SUM-@future_robresti+@varscina2+@str_odv+@str_man+@dodatne_ter+((@NEZAPADLO_VOPC_DISK_VRED_SUM+@varscina2) * (@str_proc/100)))*(@id_dav_st/100)+(@NEZAPADLO_VOPC_DISK_VRED_SUM - @future_robresti+@varscina2+@str_odv+@str_man+@dodatne_ter+((@NEZAPADLO_VOPC_DISK_VRED_SUM+@varscina2) * (@str_proc/100)))

SET @ukupno_ppmv = (@NEZAPADLO_VOPC_DISK_VRED_SUM - @future_robresti+@varscina2+@str_odv+@str_man+@dodatne_ter+((@NEZAPADLO_VOPC_DISK_VRED_SUM+@varscina2) * (@str_proc/100)))*(@id_dav_st/100)+(@NEZAPADLO_VOPC_DISK_VRED_SUM +@varscina2+@str_odv+@str_man+@dodatne_ter+((@NEZAPADLO_VOPC_DISK_VRED_SUM+@varscina2) * (@str_proc/100)))	
	
SELECT
	UKUPNO_BEZ_PPMV_EUR_MIG.res_print as UKUPNO_BEZ_PPMV_RES_PRINT,
	UKUPNO_BEZ_PPMV_EUR_MIG.res_amount as UKUPNO_BEZ_PPMV_RES_AMOUNT,
	UKUPNO_BEZ_PPMV_EUR_MIG.res_exch as UKUPNO_BEZ_PPMV_RES_EXCH,
	UKUPNO_BEZ_PPMV_EUR_MIG.res_id_val as UKUPNO_BEZ_PPMV_ID_VAL,
	UKUPNO_PPMV_EUR_MIG.res_print as UKUPNO_PPMV_RES_PRINT,
	UKUPNO_PPMV_EUR_MIG.res_amount as UKUPNO_PPMV_RES_AMOUNT,
	UKUPNO_PPMV_EUR_MIG.res_exch as UKUPNO_PPMV_RES_EXCH,
	UKUPNO_PPMV_EUR_MIG.res_id_val as UKUPNO_PPMV_ID_VAL
FROM dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_bez_ppmv, @datum_ponudbe, 'FO',@id_cont) as UKUPNO_BEZ_PPMV_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_ppmv, @datum_ponudbe, 'FO',@id_cont) as UKUPNO_PPMV_EUR_MIG

--novo
DECLARE @ukupno_bez_ppmv decimal(18,2), @ukupno_ppmv decimal(18,2)

SET @ukupno_bez_ppmv = (@NEZAPADLO_VOPC_DISK_VRED_SUM-@future_robresti+@varscina2+@str_odv+@str_man+((@NEZAPADLO_VOPC_DISK_VRED_SUM+@varscina2) * (@str_proc/100)))*(@id_dav_st/100)+(@NEZAPADLO_VOPC_DISK_VRED_SUM - @future_robresti+@varscina2+@str_odv+@str_man+((@NEZAPADLO_VOPC_DISK_VRED_SUM+@varscina2) * (@str_proc/100)))

SET @ukupno_ppmv = (@NEZAPADLO_VOPC_DISK_VRED_SUM - @future_robresti+@varscina2+@str_odv+@str_man+((@NEZAPADLO_VOPC_DISK_VRED_SUM+@varscina2) * (@str_proc/100)))*(@id_dav_st/100)+(@NEZAPADLO_VOPC_DISK_VRED_SUM +@varscina2+@str_odv+@str_man+((@NEZAPADLO_VOPC_DISK_VRED_SUM+@varscina2) * (@str_proc/100)))	
	
SELECT
	UKUPNO_BEZ_PPMV_EUR_MIG.res_print as UKUPNO_BEZ_PPMV_RES_PRINT,
	UKUPNO_BEZ_PPMV_EUR_MIG.res_amount as UKUPNO_BEZ_PPMV_RES_AMOUNT,
	UKUPNO_BEZ_PPMV_EUR_MIG.res_exch as UKUPNO_BEZ_PPMV_RES_EXCH,
	UKUPNO_BEZ_PPMV_EUR_MIG.res_id_val as UKUPNO_BEZ_PPMV_ID_VAL,
	UKUPNO_PPMV_EUR_MIG.res_print as UKUPNO_PPMV_RES_PRINT,
	UKUPNO_PPMV_EUR_MIG.res_amount as UKUPNO_PPMV_RES_AMOUNT,
	UKUPNO_PPMV_EUR_MIG.res_exch as UKUPNO_PPMV_RES_EXCH,
	UKUPNO_PPMV_EUR_MIG.res_id_val as UKUPNO_PPMV_ID_VAL
FROM dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_bez_ppmv, @datum_ponudbe, 'FO',@id_cont) as UKUPNO_BEZ_PPMV_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_ppmv, @datum_ponudbe, 'FO',@id_cont) as UKUPNO_PPMV_EUR_MIG