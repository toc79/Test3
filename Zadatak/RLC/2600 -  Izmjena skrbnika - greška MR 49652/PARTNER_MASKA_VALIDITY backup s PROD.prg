** MR 48002, 21.02.2022, g_vuradin - create validation
** MR 48002, 28.04.2022, g_vuradin - validation set on 1st day of month
TEXT TO lcSQL NOSHOW
declare @FirstDOM datetime, @LastDOM datetime, @StartDate datetime,@WORKDAYS INT

set @FirstDOM = (select dateadd(d,-1,dateadd(mm,datediff(m,0,getdate()),1 )))
set @LastDOM = (select dateadd(s,-1,dateadd(mm,datediff(m,0,getdate())+1,0))) 
set @StartDate=@FirstDOM

 
 SELECT @WORKDAYS = (DATEDIFF(dd, @StartDate, GETDATE())+1 )
					 -(DATEDIFF(wk, @StartDate,  GETDATE()) * 2)
           -(CASE WHEN DATENAME(dw, @StartDate) = 'Sunday' THEN 1 ELSE 0 END)
           -(CASE WHEN DATENAME(dw, @StartDate) = 'Saturday' THEN 1 ELSE 0 END) 
		
select @WORKDAYS dan from nastavit
ENDTEXT


GF_SQLEXEC(lcSql, "RADNI_DAN")

IF RADNI_DAN.DAN<=1 and _PARTNER_COPY.SKRBNIK_1 <> PARTNER.SKRBNIK_1 and loForm.tip_vnosne_maske <> 1 && Novi zapis 
Obvesti("Promijena polja SKRBNIK_1 moguća je tek nakon prvog radnog dana u mjesecu!")
RETURN .F.
ENDIF

IF RADNI_DAN.DAN<=1 and _PARTNER_COPY.KATEGORIJA4 <> PARTNER.KATEGORIJA4 and loForm.tip_vnosne_maske <> 1 && Novi zapis 
Obvesti("Promijena polja MJESTO TROŠKA moguća je tek nakon prvog radnog dana u mjesecu!")
RETURN .F.
ENDIF