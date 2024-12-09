
** 17.09.2020. g_tomislav MR 45384
* 1.
lcId_tiprep = lookup(rtip.id_tiprep, ponudba.id_rtip, rtip.id_rtip) && 0 označava fiksnu stopu

IF ponudba.id_tec == "000" and lcId_tiprep != 0 && za fizičke i pravne to znači da ovo vrijedi za sve!? Kontrola ne može ići KALK_L_BTNDODAJ_RETURN zato što SPEC_CENE nije obavezna za sve tipove leasinga
	POZOR ("Ponuda nije ispravna: financiranje u "+allt(GOBJ_Settings.GetVal("dom_valuta"))+" i promjenjiva kamatna stopa!")
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
* 2.
lcId_rtip_base = lookup (rtip.id_rtip_base , ponudba.id_rtip, rtip.id_rtip) && not null označava izvedeni indeks

IF ponudba.je_foseba and rf_tip_pog(ponudba.nacin_leas) == "F1" and !gf_nullorempty(lcId_rtip_base)
	POZOR ("Ponuda nije ispravna: financiranje fizičkih osoba na financijski leasing i promjenjiva kamatna stopa s izvedenim indeksom!")
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
