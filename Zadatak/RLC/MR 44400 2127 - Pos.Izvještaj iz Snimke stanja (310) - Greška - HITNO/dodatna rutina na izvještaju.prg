LOCAL repname
LOCAL pathname

if !potrjeno("Create XLS files as well?") 
	RETURN
ENDIF

**LOCAL lcSQL
**lcSQL = "select * from dbo.io_channels where channel_code = " + GF_QuotedStr("RAIF_ODR")

**GF_SQLEXEC(lcSQL, "_channel")

**IF Reccount() < 1 THEN
**	Pozor("Missing setting for export path (i/o channel with code RAIF_ODR)! Process canceled!") 
**	RETURN
**ENDIF

pathname = "c:\TEMP\" &&ALLTRIM(TRANSFORM(_channel.channel_path))  

select REZULTAT
repname=dtos(date())
 
GO TOP

**--rezultat
**select * from #odr_tmp4
**lcfile= pathname + "B2_facility_check_all" + repname + ".xls"
**copy all to &lcfile type xl5

**--rezultat1 - B2_facility_list
select REZULTAT1
if reccount()<16300
  lcfile= pathname + "B2_facility_list_" + repname  + ".xls"
  copy all to &lcfile type xl5
else
  lcfile= pathname + "B2_facility_list_" + repname  + ".dbf"
  copy all to &lcfile type fox2x
endif


** --rezultat2 - B2_facility list grouped by
select REZULTAT2
lcfile= pathname + "B2_facility_grouped_" + repname  + ".xls"
copy all to &lcfile type xl5

** --rezultat3 - B2_facility KI_LIGHT_NR_ACCOUNT
select REZULTAT3
lcfile= pathname + "B2_KI_LIGHT_ACCOUNT_" + repname  + ".xls"
copy all to &lcfile type xl5

** --rezultat4 - B2_facility KI_LIGHT_NR_LOAN
select REZULTAT4
lcfile= pathname + "B2_KI_LIGHT_LOAN_" + repname  + ".xls"
copy all to &lcfile type xl5

** --rezultat5 - B2_facility KI_LIGHT_NR_LEASING
select REZULTAT5
lcfile= pathname + "B2_KI_LIGHT_LEASING_" + repname  + ".xls"
copy all to &lcfile type xl5

** --rezultat6 - B2_facility KI_LIGHT_CR_SA_RETAIL
select REZULTAT6
lcfile= pathname + "B2_KI_LIGHT_CR_SA_RETAIL_" + repname  + ".xls"
copy all to &lcfile type xl5

** --rezultat7 - B2_facility KI_LIGHT_CR_SA_MOR
select REZULTAT7
lcfile= pathname + "B2_KI_LIGHT_CR_SA_MOR_" + repname  + ".xls"
copy all to &lcfile type xl5

** --rezultat8 - B2_facility KI_LIGHT_CR_SU_P_DUE
select REZULTAT8
lcfile= pathname + "B2_KI_LIGHT_CR_SU_P_DUE_" + repname  + ".xls"
copy all to &lcfile type xl5

** --rezultat9 - B2_facility KI_LIGHT_COLLATERAL
select REZULTAT9
lcfile= pathname + "B2_KI_LIGHT_COLLATERAL_" + repname  + ".xls"
copy all to &lcfile type xl5

Pozor("XLS files has been prepared on " + pathname)