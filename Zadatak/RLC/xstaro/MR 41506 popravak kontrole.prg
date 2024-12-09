**********************************************************************************
**** g_dejank; MR 41269 - provjera da li je partner na ugovoru FO,F1*********
**** 13.11.2018. g_tomislav MR 41506; dorada
**** 30.11.2018. g_tomislav MR 41506; added condition for id_rtip_base 
**********************************************************************************
llIzvedeniIndeks = ! GF_NULLOREMPTY(LOOKUP(rtip.id_rtip_base, pogodba.id_rtip, rtip.id_rtip))

IF llIzvedeniIndeks AND INLIST(GF_LOOKUP("partner.vr_osebe", pogodba.id_kupca,"partner.id_kupca"), "FO","F1") AND !potrjeno('Ugovor se sklapa s fizičkom osobom i izvedenim indeksom - da li ste provjerili kamatnu stopu?') THEN
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
************************** KRAJ 41269**********************************************




*STARO
**********************************************************************************
**** g_dejank; MR 41269 - provjera da li je partner na ugovoru FO,F1*********
**** 13.11.2018. g_tomislav MR 41506; dorada 
**********************************************************************************
IF INLIST(GF_LOOKUP("partner.vr_osebe", pogodba.id_kupca,"partner.id_kupca"), "FO","F1") AND !potrjeno('Ugovor se sklapa s fizičkom osobom i izvedenim indeksom - da li ste provjerili kamatnu stopu?') THEN
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
************************** KRAJ 41269**********************************************