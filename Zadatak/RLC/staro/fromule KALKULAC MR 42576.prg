"- Iznosi su u "+LOOKUP(tecajnic.id_val, dod_str.id_tec, tecajnic.id_tec)+", vrijednost dodatnih troškova je procijenjena i sklona je promjenama."

rcDod_str_Id_tec
GF_LOOKUP("dod_str.id_tec", ponudba.id_pon, "dod_str.id_pon")

rcDod_str_Id_val
GF_LOOKUP("tecajnic.id_val", rcDod_str_Id_tec, "tecajnic.id_tec")

rcId_valTros
IIF(GF_NULLOREMPTY(rcDod_str_Id_val), ALLT(GOBJ_Settings.GetVal("dom_valuta")), rcDod_str_Id_val)


rnDod_strUkupno
ROUND(ponudba.obvezno+(ponudba.kasko*ponudba.kasko_let)+ponudba.servisi+ponudba.gume+ponudba.ost_stor,2)


rlukupno DOM VAL
ROUND(ponudba.bruto+ponudba.obvezno+(ponudba.kasko*ponudba.kasko_let)+ponudba.servisi+ponudba.gume+ponudba.ost_stor,2)
* NOVO
rnUkupno
ponudba.bruto + ROUND(gf_xchange("000", rnDod_strUkupno, rcDod_str_Id_tec, ponudba.dat_izr),2)

Dodatni troškovi
ROUND(ponudba.obvezno+(ponudba.kasko*ponudba.kasko_let)+ponudba.servisi+ponudba.gume+ponudba.ost_stor,2)
*NOVO
rnDod_strUkupno

Ukupna vrijednost
ROUND(ponudba.bruto+ponudba.obvezno+(ponudba.kasko*ponudba.kasko_let)+ponudba.servisi+ponudba.gume+ponudba.ost_stor,2)
* NOVO
rnUkupno


Iznos
ROUND(gf_xchange(ponudba.id_tecvr, rnUkupno, '000', ponudba.dat_izr),2)
* NOVO
ROUND(gf_xchange(ponudba.id_tecvr, rnUkupno, "000", ponudba.dat_izr), 2)


