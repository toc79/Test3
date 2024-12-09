'zaključen je dana '+Gstr(dat_prev) +'. između'

'zaključen je dana '+IIF(GF_NULLOREMPTY(dat_prev), ".........................", Gstr(dat_prev)) +'. između'

"........................."
"_________________________"

DAT_PREV

zaključen je dana {Zap_reg.DAT_PREV.Trim()}. između

zaključen je dana {IIF(String.IsNullOrEmpty(Zap_reg.DAT_PREV), ".........................", Zap_reg.DAT_PREV.Trim())}. između


'zaključen je dana '+IIF(GF_NULLOREMPTY(zap_ner.dat_prev), ".........................", Gstr(zap_ner.dat_prev)) +'. između'


dtoc(_pog.dat_sklen)

IIF(GF_NULLOREMPTY(_pog.dat_sklen), ".........................", dtoc(_pog.dat_sklen))+"."



ZAP_REG
"zaključen je dana "+"........................."+". između"

..........................


