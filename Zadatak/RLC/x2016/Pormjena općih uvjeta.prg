
POštovani 

molimo staviti na PROD u ponedjeljak odmah ujutro (ako je moguće do 9,00) nove oznake za Opće uvjete 
kako slijedi: 

0116 za Operativni leasing za pravne i fizičke osobe 
0116 za Financijski leasing za pravne osobe, isto i za novi produkt F4 - FL-PPOM 
F0116 za Financijski leasing za fizičke osobe, isto i za novi produkt F4 - FL-PPOM 
H01_16 - za HBOR, financijski leasing - Ispis imamo samo u wordu 

Hvala, lp, 

Dunja i DIana 
*SET_DEF_VALUES

REPLACE pogodba.rind_tgor WITH 0 IN pogodba 
REPLACE pogodba.rind_zahte WITH .F. IN pogodba 
REPLACE pogodba.opc_datzad WITH 0 IN pogodba

*MID 20056 kad mjenjaju opće uvjete treba se zamijeniti i ext func PREVERI_PODATKE

local lsSpl_pog, lcid_kupca, lcVr_osebe, lcNacin_leas, lcTip_knjizenja, lnDovol_km,lnCena_dkm
lcid_kupca = ponudba.id_kupca
lcNacin_leas = ponudba.nacin_leas
GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QuotedStr(lcid_kupca),"_vr_osebe")

GF_SQLEXEC("select nacin_leas,tip_knjizenja from dbo.nacini_l where nacin_leas = "+GF_QuotedStr(lcNacin_leas),"_nacinil")

lcVr_osebe = _vr_osebe.vr_osebe
if (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcNacin_leas = 'F1'
	lcSpl_pog = 'F0415'
else
	lcSpl_pog = '0415'
endif

lcTip_knjizenja = _nacinil.tip_knjizenja
if  lcTip_knjizenja == '1'
	lnDovol_km=35000
    lnCena_dkm=0.15
else
	lnDovol_km=0
    lnCena_dkm=0.00
endif

REPLACE pogodba.dovol_km WITH lndovol_km IN pogodba
REPLACE pogodba.cena_dkm WITH lncena_dkm IN pogodba

REPLACE pogodba.spl_pog WITH lcSpl_pog IN pogodba 
use in _vr_osebe

*PREVERI_PODATKE

***********************************************************************************
***Popravak općih uvjeta prije provjere RLC prijava 1038 **************************
***********************************************************************************
local lcVr_osebe, lcNacin_leas

lcNacin_leas = RF_TIP_POG(pogodba.nacin_leas)
lcVr_osebe = GF_LOOKUP("partner.vr_osebe",pogodba.id_kupca,"partner.id_kupca")

if (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcNacin_leas = 'F1'
	if pogodba.spl_pog != 'F0415' then
		REPLACE pogodba.spl_pog WITH 'F0415' IN pogodba 
	endif
else
	if pogodba.spl_pog != '0415' and pogodba.nacin_leas != 'OP' then
		REPLACE pogodba.spl_pog WITH '0415' IN pogodba 
	endif
endif
***********************************************************************************
*** provjera općih uvjeta MID 20434, kada se mjenjaju opći uvjeti treba zamijeniti i default values
local lcPogoj1
if used('_partner_list') then
	return
endif

TEXT TO lcPogoj1 NOSHOW
	select * from partner p
		where p.id_kupca = '{0}'
ENDTEXT
lcPogoj1 = STRTRAN(lcPogoj1, '{0}', pogodba.id_kupca)
gf_sqlexec(lcPogoj1,"_partner_list")
if ((_partner_list.vr_osebe  == 'FO' or _partner_list.vr_osebe == 'F1') and pogodba.nacin_leas == 'F1') 
	if pogodba.spl_pog !='F0415'
		if !potrjeno('Nije unešena odgovarajuća vrijednost općih uvjeta! Za tip financiranja F1 i fizičke osobe opći uvjeti trebaju biti F0415, a za sve druge 0415. Želite li spremiti takav ugovor?')
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
			if used("_partner_list")
				use in _partner_list
			endif
		endif
	endif
else
	if pogodba.spl_pog !='0415'
		if !potrjeno('Nije unešena odgovarajuća vrijednost općih uvjeta! Za tip financiranja F1 i fizičke osobe opći uvjeti trebaju biti F0415, a za sve druge 0415. Želite li spremiti takav ugovor?')
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
			if used("_partner_list")
				use in _partner_list
			endif
		endif
	endif
endif
