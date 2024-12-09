uk_brez_davek
osnova+rnvarscina+ostalo+trosak-osnova*cont4prov.popust_proc/100

OSNOVA
IIF(Z_DAVKOM='*',0,DISK_VRED)

rnvarscina
_offerresultsum.varscina

ostalo
str_odv+cont4prov.str_sod+cont4prov.str_inkaso-cont4prov.str_vrac_kas+dodatne_ter_bez_pdv+cont4prov.str_man-cont4prov.str_odob_lj

str_odv
iif(akoF or AkoZ, str_odv_pdv+str_odv_bez_pdv,str_odv_bez_pdv)
cont4prov.str_odv

dodatne_ter_bez_pdv
cont4prov.dodatne_ter/(1+(xdavek/100))

str_man
iif(akoZ or akoF,strm_bez_pdv+strm_pdv,strm_bez_pdv)
cont4prov.str_man
cont4prov.str_man*(xdavek1/100)

trosak
IIF(akoZ or akoF,trosak_bez_pdv+trosak_pdv,trosak_bez_pdv)
(rnvarscina+osnova)*(cont4prov.str_proc/100)
trosak_bez_pdv*(xdavek1/100)


xdavek
lookup(_dav_stop1.davek,cont4prov.id_dav_st,_dav_stop1.id_dav_st)

xdavek1
iif(isnull(cont4prov.id_dav_st) or empty(cont4prov.id_dav_st),lookup(_dav_stop1.davek,_pogodba1.id_dav_st,_dav_stop1.id_dav_st),lookup(_dav_stop1.davek,cont4prov.id_dav_st,_dav_stop1.id_dav_st))
