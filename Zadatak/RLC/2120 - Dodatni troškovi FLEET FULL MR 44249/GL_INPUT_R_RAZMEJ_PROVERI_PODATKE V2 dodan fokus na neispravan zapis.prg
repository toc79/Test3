loForm = GF_GetFormObject("frmgl_input_r_razmej")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

* 15.05.2020 Tomislav MID 44249 - izrada;
* 08.06.2020 Tomislav MID 44249 - dodavanje fukusa na zadnji neispravan zapis

local lcPoruka
lcPoruka = ""

select rk_razmej
scan for !GF_NULLOREMPTY(id_cont) and is_razmej and veza_le

	TEXT TO lcSql NOSHOW
		--Riječ je isključivo o ugovorima OL s mjesečnim najamninama. Provjera na produkciji select * from dbo.pogodba where dbo.gfn_Nacin_leas_HR(nacin_leas) = 'OL' and ID_OBD != '001'
		select count(*) as br_bud_rata 
		from dbo.gv_planpx 
		where id_cont = {0}
		and sif_terj = 'LOBR'
		and datum_dok >= '{1}'  
	ENDTEXT
	lcSql = strtran(lcSql, "{0}", trans(rk_razmej.id_cont))
	lcSql = strtran(lcSql, "{1}", DTOS(rk_razmej.raz_datum))
	
	lnBr_bud_rata = NVL(GF_SQLEXECScalarNull(lcSql), 0)
	
	IF rk_razmej.raz_st_obr > lnBr_bud_rata
		lcPoruka = lcPoruka +allt(rk_razmej.id_pog) +": " + trans(rk_razmej.raz_st_obr) +" > " +trans(lnBr_bud_rata) +gce
		lcId_gl_input_rk = RECNO()
	ENDIF
endscan

IF !empty(lcPoruka)
	IF !POTRJENO("Za sljedeće ugovore je unesen broj rata veći od broja preostalih rata na ugovoru od datuma nastanka troška:" + gce + lcPoruka + "Da li želite nastaviti?")
		*select rk_razmej	
		*LOCATE FOR rk_razmej.id_gl_input_rk = lcId_gl_input_rk 
		GOTO RECORD lcId_gl_input_rk IN rk_razmej	
		loForm.grdPostavke.SetFocus
		loForm.spiRaz_st_obr.SetFocus
		return .f. 
	ENDIF
ENDIF
*** KRAJ 44249