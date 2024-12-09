Diana, 

molim te da pošalješ zahtjev u Gemicro vezano za izmjenu izračuna Naknade za prijevremeni raskid, a vezano na izmjenu Općih uvjeta. 

Po novome, naknada se računa na preostalu vrijednost sa PPMV-om ( buduće rate neto+PPMV+stavka otkupa+ostatak vrijednosti/jamčevina sve neto), trenutno se računa na iznos nedospijelih mjesečnih obroka neto. 

I dalje bi koristili polje u opciji ponuda za prijevremeni zaključak Naknada prij. s tim da bi se kod ispisa to polje trebalo uvećati za iznos PDV-a i polje Naknada (gdje se upisuje fiksni iznos naknade) kod ispisa treba podesiti da se na upisanu vrijednost dodaje PDV . I dalje ostaje isto da se ta dva navedena polja ispisuju na ispisu Informativni izračun prodajne cijene . 

Ako ima nekih nejasnoća vezano na navedeno, stojim na raspolaganju . 

Hvala, 
Marija 


Naknada zbog prijevremenog raskida ugovora
Round((SUM_NET_VAL*cont4prov.popust_proc/100) + cont4prov.str_izplac_zav,2) 

SUM_NET_VAL
IIF(Z_DAVKOM='*' or rcOPC='OPC' or rcVOPC='VOPC',0,net_val+regist) 
&& net_val sadrži robresti i obresti

rcOPC
allt(lookup(_vrst_ter.sif_terj,_offerresultdetail.id_terj,_vrst_ter.id_terj))

rcVOPC
allt(lookup(_vrst_ter.sif_terj,_offerresultdetail.id_terj,_vrst_ter.id_terj))

* NOVO
Naknada zbog prijevremenog raskida ugovora
Round(((SUM_NET_VAL*cont4prov.popust_proc/100) + cont4prov.str_izplac_zav) * (1+xdavek1/100),2)

Round(((SUM_NET_VAL*cont4prov.popust_proc/100) + cont4prov.str_izplac_zav) * IIF(akoF, 1, 1.25), 2)  


SUM_NET_VAL
IIF(Z_DAVKOM='*', 0, net_val+regist)

IIF(Z_DAVKOM='*', 0, neto+regist+robresti)

*** NOVO 2
SUM_NET_VAL_FL
IIF(Z_DAVKOM='*' or rcVOPC='VOPC', 0, net_val+regist) 

SUM_NET_VAL_OL
IIF(Z_DAVKOM='*', 0, neto+robresti)

nakn_zatv
Round((( IIF(akoF, SUM_NET_VAL_FL, SUM_NET_VAL_OL + rnvarscina) * cont4prov.popust_proc/100) + cont4prov.str_izplac_zav) * IIF(akoF, 1, 1.25), 2) 

Round((( IIF(akoF, SUM_NET_VAL_FL, SUM_NET_VAL_OL + IIF(_pogodba1.nacin_leas="OR", 0, rnvarscina)) * cont4prov.popust_proc/100) + cont4prov.str_izplac_zav) * IIF(akoF, 1, 1.25), 2) 


*Jamčevina iz SED_VRP_OL rnvarscina
_offerresultsum.varscina

*DODATNO

uk_brez_davek
osnova+IIF(lookup(_nacini_l.odstej_var,cont4prov.nacin_leas,_nacini_l.nacin_leas)=.F.,0,rnvarscina)+ostalo+trosak-PPMV

osnova
IIF(Z_DAVKOM='*', 0, IIF(lookup(_vrst_ter.sif_terj,_offerresultdetail.id_terj,_vrst_ter.id_terj)='VOPC',_offerresultdetail.neto,_offerresultdetail.disk_vred))


xdavek
lookup(_dav_stop1.davek,cont4prov.id_dav_st,_dav_stop1.id_dav_st)
xdavek1
iif(isnull(cont4prov.id_dav_st) or empty(cont4prov.id_dav_st),lookup(_dav_stop1.davek,_pogodba1.id_dav_st,_dav_stop1.id_dav_st),lookup(_dav_stop1.davek,cont4prov.id_dav_st,_dav_stop1.id_dav_st))


* CODE_BEFORE 
local lcid_pog, lnOdg, lnId_pon_pred_odkup  
lcid_pog=cont4prov.id_pog
local lcvnesel
lcvnesel=cont4prov.vnesel
GF_SQLEXEC("Select * From pogodba LEFT JOIN zap_reg on pogodba.id_cont = zap_reg.id_cont Where id_pog="+GF_QuotedStr(lcid_pog),"_pogodba1")
GF_SQLEXEC("Select user_desc From users Where username="+GF_QuotedStr(lcvnesel),"_unio1")

local lcid_kupca
lcid_kupca=cont4prov.id_kupca

GF_SQLEXEC("Select * From partner Where id_kupca="+GF_QuotedStr(lcid_kupca),"_partner1")
GF_SQLEXEC("Select * From dav_stop","_dav_stop1")
GF_SQLEXEC("Select id_terj, sif_terj from vrst_ter","_vrst_ter")
GF_SQLEXEC("Select nacin_leas, odstej_var from nacini_l","_nacini_l")

public PuOdg 

PuOdg = ""
lnOdg = rf_msgbox("Pitanje","Da li ponuda važeća za plaćanje zaključno do 25. dana u tek. mj.?","Ne","Da","Poništi")

DO case
	CASE lnOdg = 2	&& DA
		PuOdg = "2"
	CASE lnOdg = 1	&& NE
		PuOdg = "1"
	OTHERWISE
		RETURN .F.
ENDCASE

GF_SQLExec("select user_desc,phone,email,fax,department from users where user_desc="+GF_QuotedStr(ALLT(CONT4PROV.VNESEL)),"_tempvar")


**Dio koda za ispis PPMV-a izračunatog i spremljenog u ODS pomoću PPMV kalkulatora
lnId_pon_pred_odkup =  trans(cont4prov.id_pon_pred_odkup)

TEXT TO lcSqlx NOSHOW
	DECLARE @values varchar(500)
	SET @values = 'identifikator={1}'

	EXEC dbo.grp_Ods_QueryDocumentsTable 'KALK_PREOSTALI_PPMV_PON_PRED_ODK_QUERY', '', @values
ENDTEXT

lcSqlx = STRTRAN(lcSQLx,"{1}", trans(lnId_pon_pred_odkup))

GF_SQLExec(lcSqlx,"print_ppmv_kalk")