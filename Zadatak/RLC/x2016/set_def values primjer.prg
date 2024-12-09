*********************************************
* 16.05.2016 g_tomislav - MR 35121 
local lcId_odobrit 
lcId_odobrit = pogodba.id_odobrit

IF ! gf_nullorempty(lcId_odobrit) 
	GF_SQLEXEC("SELECT a.id_cont, a.id_odobrit FROM dbo.Odobrit a JOIN dbo.pogodba b ON a.id_odobrit=b.ID_ODOBRIT WHERE a.ID_ODOBRIT ="+gf_quotedstr(lcId_odobrit),"_ef_odobrit")
	select _ef_odobrit
	IF RECCOUNT() > 0
		pozor ('Za ovo odobrenje već postoji ugovor. Molim provjeru podataka!')
	ENDIF
	use in _ef_odobrit
ENDIF
*******END MR 35121**************************************








llVecPostojiOdobrenje = .t.


IF ! gf_nullorempty(loForm.Pageframe1.Page1.txtId_doc.value) AND loForm.Pageframe1.Page1.txtId_doc.value =  '0000007' AND llVecPostojiOdobrenje THEN  && ako je uneseno odobrenje i već je korišteno odobrenje
	pozor ('Za ovo odobrenje već postoji ugovor. Unesite novo !')
	
	loForm.Pageframe1.Page1.txtId_doc.value = ''
	
	loForm.Pageframe1.Page1.txtId_pon.Enabled = .T.
	loForm.Pageframe1.Page1.txtId_pon.Value = ''
	
	*loForm.Pageframe1.Page1.txtId_pon.Valid()
	*loForm.Pageframe1.Page1.txtId_doc.Valid()
	*loForm.INIT()
ENDIF



*obvesti (trans(loForm.Pageframe1.Page1.txtId_doc.value))

loForm.Pageframe1.Page1.txtId_doc.Obvezen = .f.

llVecPostojiOdobrenje = .t.




IF ! gf_nullorempty(loForm.Pageframe1.Page1.txtId_doc.value) AND pogodba.id_odobrit = 7 THEN  &&  AND llVecPostojiOdobrenje  ako je uneseno odobrenje i već je korišteno odobrenje
	pozor ('Za ovo odobrenje već postoji ugovor. Unesite novo !')
	
	loForm.Pageframe1.Page1.txtId_doc.value = ''
	
	loForm.Pageframe1.Page1.txtId_pon.Enabled = .T.
	loForm.Pageframe1.Page1.txtId_pon.Value = '0021883'

	loForm.Pageframe1.Page1.txtId_doc.Obvezen = .t.
	
	REPLACE id_odobrit WITH .NULL. IN pogodba

	*select * from odobrit
	*DELETE FROM odobrit
	*loForm.Pageframe1.Page1.txtId_pon.Valid()
	*loForm.Pageframe1.Page1.txtId_doc.Valid()
	*loForm.INIT()
ENDIF

IF ! gf_nullorempty(loForm.Pageframe1.Page1.txtId_doc.value) AND pogodba.id_odobrit = 7 THEN  &&  AND llVecPostojiOdobrenje  ako je uneseno odobrenje i već je korišteno odobrenje
	pozor ('Za ovo odobrenje već postoji ugovor. Unesite novo !')
	
	loForm.Release
	
	
ENDIF

