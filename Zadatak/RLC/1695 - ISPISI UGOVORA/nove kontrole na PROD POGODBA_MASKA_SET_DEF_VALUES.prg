REPLACE pogodba.rind_tgor WITH 0 IN pogodba 
REPLACE pogodba.rind_zahte WITH .F. IN pogodba 
REPLACE pogodba.opc_datzad WITH 0 IN pogodba

*MID 20056 kad mjenjaju opće uvjete treba se zamijeniti i ext func PREVERI_PODATKE

local lcSpl_pog, lcid_kupca, lcVr_osebe, lcNacin_leas
lcid_kupca = ponudba.id_kupca
lcNacin_leas = RF_TIP_POG(ponudba.nacin_leas)
GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QuotedStr(lcid_kupca),"_vr_osebe")

GF_SQLEXEC("select nacin_leas,tip_knjizenja from dbo.nacini_l where nacin_leas = "+GF_QuotedStr(lcNacin_leas),"_nacinil")

lcVr_osebe = _vr_osebe.vr_osebe
if (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcNacin_leas = 'F1'
	lcSpl_pog = 'F0216'
else
	lcSpl_pog = '0216'
endif

REPLACE pogodba.spl_pog WITH lcSpl_pog IN pogodba 
use in _vr_osebe

******* DOZVOLJENI BROJ KM ************
* 16.03.2017 g_tomislav - dorada MR 37674, da se povlače s ponude
LOCAL lnDovol_km, lnCena_dkm

lnDovol_km = ponudba.Dovol_km
lnCena_dkm = ponudba.Cena_dkm

REPLACE pogodba.dovol_km WITH lndovol_km IN pogodba
REPLACE pogodba.cena_dkm WITH lncena_dkm IN pogodba
* KRAJ DOZVOLJENI BROJ KM 
*********************

*********************************************
* 16.05.2016 g_tomislav - MR 35121 
local lcId_odobrit 
lcId_odobrit = pogodba.id_odobrit

IF ! gf_nullorempty(lcId_odobrit) 
	GF_SQLEXEC("SELECT a.id_cont, a.id_odobrit FROM dbo.Odobrit a JOIN dbo.pogodba b ON a.id_odobrit=b.ID_ODOBRIT WHERE a.ID_ODOBRIT ="+gf_quotedstr(lcId_odobrit),"_ef_odobrit")
	select _ef_odobrit
	IF RECCOUNT() > 0
		pozor ('Za ovo odobrenje već postoji ugovor. Molim provjeru podataka!')
	ENDIF
	use in _ef_odobrit
ENDIF
*******END MR 35121**************************************