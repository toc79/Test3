*obvesti ("GL_INPUT_R_RAZMEJ_PREVERI_PODATKE")
*return .f.
*select raz_st_obr , * from rk_razmej
*Update rk_razmej set raz_st_obr = 11 where id_rk = 175929
*select raz_st_obr , * from rk_razmej
* LcList_condition = "!GF_NULLOREMPTY(id_cont)"  && Mora biti 
* lcList = GF_CreateDelimitedList("rk_razmej", "id_cont", LcList_condition, ",", .f.) &&bez navodnika 

* 15.05.2020 Tomislav MID 44249 - izrada - provjerava označene zapise za razgraničenja (zelena kvačica), koji imaju ugovor i označeno "Veza na leasing". Od "Datuma nastanka troška" bi se provjeravalo broj rata na ugovoru za svaki zapis razgraničenja
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
	ENDIF
endscan

IF !empty(lcPoruka)
	IF !POTRJENO("Za sljedeće ugovore je unesen broj rata veći od broja preostalih rata na ugovoru od datuma nastanka troška:" + gce + lcPoruka + "Da li želite nastaviti?")
		return .f.
	ENDIF
ENDIF
*** KRAJ 44249