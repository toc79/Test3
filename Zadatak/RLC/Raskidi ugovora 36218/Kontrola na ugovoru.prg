* 02.09.2016 g_tomislav MR 36218 ticket 1609
local liPromjena_statusa_na_ODP, liNePostoji_snimka

liPromjena_statusa_na_ODP = GF_LOOKUP("pogodba.status",pogodba.id_cont,"pogodba.id_cont") != pogodba.status AND  "RA" == pogodba.status && GF_LOOKUP("statusi.status","ODP","statusi.sif_status")

*obvesti (trans(liPromjena_statusa_na_ODP))

IF liPromjena_statusa_na_ODP  
	liNePostoji_snimka = GF_NULLOREMPTY(GF_SQLExecScalarNull("SELECT * FROM dbo.planp_clone_content WHERE id_cont = "+GF_Quotedstr(pogodba.id_cont)+" AND CONVERT(date,dat_posn,101) = CONVERT(date,getdate(),101)"))
	IF liNePostoji_snimka 
		POZOR("Za ugovor nije napravljeno spremanje trenutnog plana otplate na današnji dan. Status ugovora na raskinuti se ne može promijeniti!")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF
	
	
	liPostoji_snimka = !GF_NULLOREMPTY(GF_SQLExecScalarNull("SELECT * FROM planp_clone_content WHERE id_cont = 8042 AND CONVERT(date,dat_posn,101) = '20160829'"))

IF liPostoji_snimka THEN 
obvesti ("DA")
ELSE 
obvesti ("NE")
	
	? GF_SQLExecScalarNull("SELECT * FROM planp_clone_content WHERE id_cont = 8042 AND CONVERT(date,dat_posn,101) = '20160830'")