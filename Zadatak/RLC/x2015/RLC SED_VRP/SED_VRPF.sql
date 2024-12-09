uk_brez_davek
osnova+rnvarscina+ostalo+trosak-osnova*cont4prov.popust_proc/100

OSNOVA
IIF(Z_DAVKOM='*',0,DISK_VRED)

rnvarscina
_offerresultsum.varscina

ostalo
str_odv+cont4prov.str_sod+cont4prov.str_inkaso-cont4prov.str_vrac_kas+lnDodstr+str_man-cont4prov.str_odob_lj

str_odv
iif(akoZ or akoF,str_odv_bez_pdv+str_odv_pdv,str_odv_bez_pdv)
cont4prov.str_odv

lnDodstr
cont4prov.dodatne_ter






trosak
IIF(akoZ or akoF,trosak_bez_pdv+trosak_pdv,trosak_bez_pdv)
(rnvarscina+osnova)*(cont4prov.str_proc/100)
trosak_bez_pdv*(manstr_davek/100)


xdavek
lookup(_dav_stop1.davek,cont4prov.id_dav_st,_dav_stop1.id_dav_st)

xdavek1
look(_dav_stop1.davek,'DDV',_dav_stop1.sif_dav)

manstr_davek
lookup(_dav_stop1.davek,RF_POG_STRO_DAV(cont4prov.id_cont),_dav_stop1.id_dav_st)/100