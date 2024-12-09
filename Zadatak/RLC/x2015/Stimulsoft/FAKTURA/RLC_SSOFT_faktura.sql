NETO
iif(planplacil.sif_terj='VARS',planplacil.debit,planplacil.ro_debit_neto+planplacil.ro_brez_davka+planplacil.ro_neobdav)

DAVEK
iif(empty(planplacil.ro_debit_davek) or isnull(planplacil.ro_debit_davek),0,planplacil.ro_debit_davek)


UKUPNO
iif(planplacil.sif_terj='VARS', 	GF_XCHANGE("000",planplacil.debit,planplacil.id_tec,planplacil.datum_dok),planplacil.ro_debit)

rctxt1
'Molimo da gore navedeni iznos uplatite u roku od 7 dana u kunskoj protuvrijednosti koristeći '+allt(look(_tecajnic.naziv,planplacil.id_tec,_tecajnic.id_tec))+' na dan uplate u korist žiro računa broj '

rctxt2
', kako bismo mogli pristupiti narudžbi objekta leasinga.'

rctxt1+allt(gObj_Settings.getval('p_zrac'))+', s pozivom na broj 01 '+allt(pogodba.sklic)+rctxt2

planplacil.id_terj#'12' and ((pogodba.nacin_leas#'OA' or pogodba.nacin_leas#'OJ') and planplacil.id_terj#'20')

planplacil.sif_terj == "VARS" && (planplacil.nacin_leas != "OA" || planplacil.nacin_leas != "OJ")



Dat. obav. usluge
print when
(!empty(planplacil.ddv_id) or !isnull(planplacil.ddv_id)) and planplacil.sif_terj!='POLO'


iif(nacini_l.tip_knjizenja='1' and planplacil.sif_terj='POLO','UNAPRIJED PLAĆENI OBROK',alltrim(planplacil.naziv))

allt('PDV')+' %'
planplacil.sif_terj#'VARS'


