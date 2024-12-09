Declare
@ukupno_sa_pdv_ne_u_rati decimal(18,2), 
@ukupno_sa_pdv_u_rati decimal(18,2),
@dospjeli_dug_ne_u_rati decimal(18,2),
@dospjeli_dug_u_rati decimal(18,2),
@ukupno_ol_ne_u_rati decimal(18,2),
@ukupno_ol_u_rati decimal(18,2),
@ukupno_fl_ne_u_rati decimal(18,2),
@ukupno_fl_u_rati decimal(18,2)

SET @ukupno_sa_pdv_ne_u_rati = (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))-@robresti_sum)+(@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))-@robresti_sum)*(@id_dav_st/100)

SET @ukupno_sa_pdv_u_rati = (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100)*(@id_dav_st/100))-@robresti_sum)+ (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100)*(@id_dav_st/100))-@robresti_sum)*(@id_dav_st/100)

SET @dospjeli_dug_ne_u_rati = @zam_obr_sum+@ze_zapadlo_net_val_sum

SET @dospjeli_dug_u_rati = (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100)*(@id_dav_st/100))-@robresti_sum)+ (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100)*(@id_dav_st/100))-@robresti_sum)*(@id_dav_st/100)+@zam_obr_sum+@ze_zapadlo_net_val_sum	

SET @ukupno_ol_ne_u_rati = (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))-@robresti_sum)+(@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))-@robresti_sum)*(@id_dav_st/100)+@robresti_sum

SET @ukupno_ol_u_rati = (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100)*(@id_dav_st/100))-@robresti_sum)+ (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100)*(@id_dav_st/100))-@robresti_sum)*(@id_dav_st/100)+@robresti_sum

SET @ukupno_fl_ne_u_rati = @zam_obr_sum+@ze_zapadlo_net_val_sum

SET @ukupno_fl_u_rati = (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100)*(@id_dav_st/100)))+ (@vopc_disk_vred_sum+@varscina2_sum+@str_odv_s_pdv+@str_sod+@str_man_s_pdv+@dodatne_ter+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100))+((@varscina2_sum + @vopc_disk_vred_sum) * (@str_proc/100)*(@id_dav_st/100)))*(@id_dav_st/100)+@zam_obr_sum+@ze_zapadlo_net_val_sum

SELECT
	UKUPNO_SA_PDV_NE_U_RATI_EUR_MIG.res_print as UKUPNO_SA_PDV_NE_U_RATI_RES_PRINT,
	UKUPNO_SA_PDV_NE_U_RATI_EUR_MIG.res_amount as UKUPNO_SA_PDV_NE_U_RATI_RES_AMOUNT,
	UKUPNO_SA_PDV_NE_U_RATI_EUR_MIG.res_exch as UKUPNO_SA_PDV_NE_U_RATI_RES_EXCH,
	UKUPNO_SA_PDV_NE_U_RATI_EUR_MIG.res_id_val as UKUPNO_SA_PDV_NE_U_RATI_ID_VAL,
	UKUPNO_SA_PDV_U_RATI_EUR_MIG.res_print as UKUPNO_SA_PDV_U_RATI_RES_PRINT,
	UKUPNO_SA_PDV_U_RATI_EUR_MIG.res_amount as UKUPNO_SA_PDV_U_RATI_RES_AMOUNT,
	UKUPNO_SA_PDV_U_RATI_EUR_MIG.res_exch as UKUPNO_SA_PDV_U_RATI_RES_EXCH,
	UKUPNO_SA_PDV_U_RATI_EUR_MIG.res_id_val as UKUPNO_SA_PDV_U_RATI_ID_VAL,
	DOSPJELI_DUG_NE_U_RATI_EUR_MIG.res_print as DOSPJELI_DUG_NE_U_RATI_RES_PRINT,
	DOSPJELI_DUG_NE_U_RATI_EUR_MIG.res_amount as DOSPJELI_DUG_NE_U_RATI_RES_AMOUNT,
	DOSPJELI_DUG_NE_U_RATI_EUR_MIG.res_exch as DOSPJELI_DUG_NE_U_RATI_RES_EXCH,
	DOSPJELI_DUG_NE_U_RATI_EUR_MIG.res_id_val as DOSPJELI_DUG_NE_U_RATI_ID_VAL,
	DOSPJELI_DUG_U_RATI_EUR_MIG.res_print as DOSPJELI_DUG_U_RATI_RES_PRINT,
	DOSPJELI_DUG_U_RATI_EUR_MIG.res_amount as DOSPJELI_DUG_U_RATI_RES_AMOUNT,
	DOSPJELI_DUG_U_RATI_EUR_MIG.res_exch as DOSPJELI_DUG_U_RATI_RES_EXCH,
	DOSPJELI_DUG_U_RATI_EUR_MIG.res_id_val as DOSPJELI_DUG_U_RATI_ID_VAL,
	UKUPNO_OL_NE_U_RATI_EUR_MIG.res_print as UKUPNO_OL_NE_U_RATI_RES_PRINT,
	UKUPNO_OL_NE_U_RATI_EUR_MIG.res_amount as UKUPNO_OL_NE_U_RATI_RES_AMOUNT,
	UKUPNO_OL_NE_U_RATI_EUR_MIG.res_exch as UKUPNO_OL_NE_U_RATI_RES_EXCH,
	UKUPNO_OL_NE_U_RATI_EUR_MIG.res_id_val as UKUPNO_OL_NE_U_RATI_ID_VAL,
	UKUPNO_FL_NE_U_RATI_EUR_MIG.res_print as UKUPNO_FL_NE_U_RATI_RES_PRINT,
	UKUPNO_FL_NE_U_RATI_EUR_MIG.res_amount as UKUPNO_FL_NE_U_RATI_RES_AMOUNT,
	UKUPNO_FL_NE_U_RATI_EUR_MIG.res_exch as UKUPNO_FL_NE_U_RATI_RES_EXCH,
	UKUPNO_FL_NE_U_RATI_EUR_MIG.res_id_val as UKUPNO_FL_NE_U_RATI_ID_VAL,
	UKUPNO_OL_U_RATI_EUR_MIG.res_print as UKUPNO_OL_U_RATI_RES_PRINT,
	UKUPNO_OL_U_RATI_EUR_MIG.res_amount as UKUPNO_OL_U_RATI_RES_AMOUNT,
	UKUPNO_OL_U_RATI_EUR_MIG.res_exch as UKUPNO_OL_U_RATI_RES_EXCH,
	UKUPNO_OL_U_RATI_EUR_MIG.res_id_val as UKUPNO_OL_U_RATI_ID_VAL,
	UKUPNO_FL_U_RATI_EUR_MIG.res_print as UKUPNO_FL_U_RATI_RES_PRINT,
	UKUPNO_FL_U_RATI_EUR_MIG.res_amount as UKUPNO_FL_U_RATI_RES_AMOUNT,
	UKUPNO_FL_U_RATI_EUR_MIG.res_exch as UKUPNO_FL_U_RATI_RES_EXCH,
	UKUPNO_FL_U_RATI_EUR_MIG.res_id_val as UKUPNO_FL_U_RATI_ID_VAL
	/*SELECT
	1 as UKUPNO_SA_PDV_NE_U_RATI_RES_PRINT,
	1.00 as UKUPNO_SA_PDV_NE_U_RATI_RES_AMOUNT,
	7.5345 as UKUPNO_SA_PDV_NE_U_RATI_RES_EXCH,
	'EUR' as UKUPNO_SA_PDV_NE_U_RATI_ID_VAL,
	1 as UKUPNO_SA_PDV_U_RATI_RES_PRINT,
	1.00 as UKUPNO_SA_PDV_U_RATI_RES_AMOUNT,
	7.5345 as UKUPNO_SA_PDV_U_RATI_RES_EXCH,
	'EUR' as UKUPNO_SA_PDV_U_RATI_ID_VAL,
	1 as DOSPJELI_DUG_NE_U_RATI_RES_PRINT,
	1.00 as DOSPJELI_DUG_NE_U_RATI_RES_AMOUNT,
	7.5345 as DOSPJELI_DUG_NE_U_RATI_RES_EXCH,
	'EUR' as DOSPJELI_DUG_NE_U_RATI_ID_VAL,
	1 as DOSPJELI_DUG_U_RATI_RES_PRINT,
	1.00 as DOSPJELI_DUG_U_RATI_RES_AMOUNT,
	7.5345 as DOSPJELI_DUG_U_RATI_RES_EXCH,
	'EUR' as DOSPJELI_DUG_U_RATI_ID_VAL,
	1 as UKUPNO_OL_NE_U_RATI_RES_PRINT,
	1.00 as UKUPNO_OL_NE_U_RATI_RES_AMOUNT,
	7.5345 as UKUPNO_OL_NE_U_RATI_RES_EXCH,
	'EUR' as UKUPNO_OL_NE_U_RATI_ID_VAL,
	1 as UKUPNO_FL_NE_U_RATI_RES_PRINT,
	1.00 as UKUPNO_FL_NE_U_RATI_RES_AMOUNT,
	7.5345 as UKUPNO_FL_NE_U_RATI_RES_EXCH,
	'EUR' as UKUPNO_FL_NE_U_RATI_ID_VAL,
	1 as UKUPNO_OL_U_RATI_RES_PRINT,
	1.00 as UKUPNO_OL_U_RATI_RES_AMOUNT,
	7.5345 as UKUPNO_OL_U_RATI_RES_EXCH,
	'EUR' as UKUPNO_OL_U_RATI_ID_VAL,
	1 as UKUPNO_FL_U_RATI_RES_PRINT,
	1.00 as UKUPNO_FL_U_RATI_RES_AMOUNT,
	7.5345 as UKUPNO_FL_U_RATI_RES_EXCH,
	'EUR' as UKUPNO_FL_U_RATI_ID_VAL*/
FROM dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_sa_pdv_ne_u_rati, @datum_ponudbe, @vr_osebe,@id_cont) as UKUPNO_SA_PDV_NE_U_RATI_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_sa_pdv_u_rati, @datum_ponudbe, @vr_osebe,@id_cont) as UKUPNO_SA_PDV_U_RATI_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @dospjeli_dug_ne_u_rati, @datum_ponudbe, @vr_osebe,@id_cont) as DOSPJELI_DUG_NE_U_RATI_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @dospjeli_dug_u_rati, @datum_ponudbe, @vr_osebe,@id_cont) as DOSPJELI_DUG_U_RATI_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_ol_ne_u_rati, @datum_ponudbe, @vr_osebe,@id_cont) as UKUPNO_OL_NE_U_RATI_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_ol_u_rati, @datum_ponudbe, @vr_osebe,@id_cont) as UKUPNO_OL_U_RATI_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_fl_ne_u_rati, @datum_ponudbe, @vr_osebe,@id_cont) as UKUPNO_FL_NE_U_RATI_EUR_MIG
OUTER APPLY dbo.pfn_gmc_xchangeEurMigrationPrintouts2(@id_tec, @ukupno_fl_u_rati, @datum_ponudbe, @vr_osebe,@id_cont) as UKUPNO_FL_U_RATI_EUR_MIG
