*MŠ 2.8.2012 potpisnik iz šifranta
*MŠ 14.9.2017 dorada RF-a
FUNCTION RF_POTPIS(lcid_rep)
	RETURN NVL(GF_SQLExecScalarNull("SELECT Value FROM general_register WHERE id_register = 'REPORT_SIGNATORY' AND neaktiven = 0 AND id_key = "+GF_QUOTEDSTR(lcid_rep)), '')
ENDFUNC

*NOVO
*MŠ 2.8.2012 potpisnik iz šifranta
*MŠ 14.9.2017 dorada RF-a
* 21.11.2017 g_tomislav	- MR 39330 dodavanje 100 character-a
FUNCTION RF_POTPIS(lcid_rep)
	RETURN NVL(GF_SQLExecScalarNull("SELECT Value FROM general_register WHERE id_register = 'REPORT_SIGNATORY' AND neaktiven = 0 AND id_key = "+GF_QUOTEDSTR(lcid_rep)), '                                                                                                  ') && 100 character-a u slučaju da prvi zapis vrati NVL, onda se u kursoru podesi C(1) što za sljedeće zapise nije dobro
ENDFUNC



SELECT id_opom, RF_POTPIS('OPOMIN') as gr, RF_POTPIS('OPOMINV') as grV, RF_POTPIS(NVL(Ro_izdal, '')) as grPrim FROM za_opom ;
WHERE !ISNULL(Ro_izdal) AND oznacen = .T. AND !GF_NULLOREMPTY(ddv_id) AND IIF(EMPTY(lcFilter), .t., lcFilter) ORDER BY 1 INTO CURSOR _Potpis

lcPotpis
IIF(GF_NULLOREMPTY(_Potpis.gr), ALLT(GOBJ_Comm.GetUserDesc()), ALLT(_Potpis.gr))

lcPotpis2
ALLT(IIF(GF_NULLOREMPTY(_Potpis.grPrim), _Potpis.grV, _Potpis.grPrim))
PW:
!GF_NULLOREMPTY(_Potpis.grprim) OR !GF_NULLOREMPTY(_Potpis.grv)

*za usporedbu
lookup(_nacinil.leas_kred,za_opom.nacin_leas,_nacinil.nacin_leas)

*NOVO
*21.11.2017 g_tomislav MR 39330
CREATE CURSOR _cb_Potpis (id_za_opom I, gr C(100), grV C(100), grPrim C(100)) && 100 character-a u slučaju da prvi zapis vrati NVL, onda se u kursoru podesi C(1) što za sljedeće zapise nije dobro. U RF_POTPIS nisam napravio da vrati 100 praznih karaktera (umjesto kursora) zato što bi to možda utjecalo na ostale ispise.

SELECT id_opom, RF_POTPIS('OPOMIN') as gr, RF_POTPIS('OPOMINV') as grV, RF_POTPIS(Ro_izdal) as grPrim FROM za_opom ;
WHERE oznacen = .T. AND !GF_NULLOREMPTY(ddv_id) AND IIF(EMPTY(lcFilter), .t., lcFilter) ORDER BY 1 INTO CURSOR _cb_Potpis


lcPotpisGR
LOOK(_cb_Potpis.gr, za_opom.id_opom, _cb_Potpis.id_opom)

lcPotpis
IIF(GF_NULLOREMPTY(lcPotpisGR), ALLT(GOBJ_Comm.GetUserDesc()), ALLT(lcPotpisGR))


lcPotpisGRPrim
LOOK(_cb_Potpis.grPrim, za_opom.id_opom, _cb_Potpis.id_opom)

lcPotpisgrV
LOOK(_cb_Potpis.grV, za_opom.id_opom, _cb_Potpis.id_opom)

lcPotpis2
ALLT(IIF(GF_NULLOREMPTY(lcPotpisGRPrim), lcPotpisgrV, lcPotpisGRPrim))

PW: 
!GF_NULLOREMPTY(lcPotpisGRPrim) OR !GF_NULLOREMPTY(lcPotpisgrV)




