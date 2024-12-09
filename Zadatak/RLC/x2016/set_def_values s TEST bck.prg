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
if (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and LEFT(lcNacin_leas,1) == 'F'
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