loform = GF_GETFORMOBJECT("opc_fakt_maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF
* Kursori
*select * from opc_fakt_vnos
*select * from planp

****************************************************************************
* 02.03.2018. g_tomislav MR 39782 - brisanje zakomentirane provjere PPMVa  
**Provjera da li ugovor uopće ima PPMV. Ako nema ne radi se spremanje.
****************************************************************************

****************************************************************************
* 02.03.2018 g_tomislav MR 39782 - izrada

IF GF_NULLOREMPTY(opc_fakt_vnos.ddv_id) && ako je račun izdan da se ne prikazuje poruka

	LOCAL lcId_pog, liId_cont
	lcId_pog = loForm.txtId_pog.value && kod unosa novog zapisa opc_fakt_vnos.id_cont je prazan
	liId_cont =  NVL(GF_SQLEXECScalarNull("SELECT dbo.gfn_id_cont4id_pog("+gf_quotedstr(lcId_pog)+")"), 0)

	IF ALLT(GF_LOOKUP("pogodba.nacin_leas", liId_cont, "pogodba.id_cont")) = "OR"  && nema nacin_leas u kursoru 

		LOCAL lnBroj_otkupaORUgovora 
		lnBroj_otkupaORUgovora = NVL(GF_SQLEXECScalarNull("SELECT count(*) as br_otkupa FROM dbo.planp WHERE id_terj = '23' AND id_cont = "+gf_quotedstr(liId_cont)), 0)
		
		IF lnBroj_otkupaORUgovora > 1 AND ! POTRJENO("Da li ste napravili RPG?")
			POZOR("Promjene nisu spremljene!")
			RETURN .F.
		ENDIF
	ENDIF

ENDIF
****************************************************************************