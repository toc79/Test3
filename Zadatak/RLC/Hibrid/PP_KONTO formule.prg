rezultat.leas_kred='L' and rezultat.tip_knjizenja='2'
i
rezultat.tip_knjizenja='2'

*NOVO
rezultat.leas_kred='L' and rezultat.tip_knjizenja='2'
*zamijeniti s 
RF_TIP_POG(rezultat.nacin_leas) == "F1"

IIF(GF_NULLOREMPTY(rezultat.nacin_leas), .F., RF_TIP_POG(rezultat.nacin_leas) == "F1")

IIF(GF_NULLOREMPTY(rezultat.nacin_leas), .F., RF_TIP_POG(rezultat.nacin_leas) == "F1") AND !rlPredujam

rezultat.tip_knjizenja='2'
*zamijeniti s 
RF_TIP_POG(rezultat.nacin_leas) == "F1" OR (rezultat.tip_knjizenja == "2" AND rezultat.leas_kred == "K")

(RF_TIP_POG(rezultat.nacin_leas) == "F1" OR (rezultat.tip_knjizenja == "2" AND rezultat.leas_kred == "K")) AND !rlPredujam

Imaju još uvijek aktivni zajam ZP
Predujam u tabeli nema nacin_leas

IIF(GF_NULLOREMPTY(rezultat.nacin_leas), .F., RF_TIP_POG(rezultat.nacin_leas) == "F1") OR (rezultat.tip_knjizenja == "2" AND rezultat.leas_kred == "K")

IIF(GF_NULLOREMPTY(rezultat.nacin_leas), .F., RF_TIP_POG(rezultat.nacin_leas) == "F1") OR (rezultat.tip_knjizenja == "2" AND rezultat.leas_kred == "K") AND !rlPredujam


Imaju još uvijek aktivni zajam ZP
Predujam u tabeli nema nacin_leas


'Tip financiranja: '+allt(rezultat.nacin_leas)

if !used("cursor_tecajnic") then 
      select * from tecajnic into cursor cursor_tecajnic 
endif

local lcSql, lcId_rep, lcId_tec, lcId_kupca, llIncludeClosed, lcBaza, lcAnd, llContract_id_tec

lcId_rep = STR(cursor_report.id_oc_report)

if cursor_sys.is_snapshot then
	lcId_tec1 = lookup(_PCDPARAMETER.PARVALUE,"TECAJNICA",_PCDPARAMETER.PARNAME) 
	select cursor_tecajnic
	locate for id_tec = iif(len(alltrim(lcId_tec1))=3, alltrim(lcId_tec1), "000")
endif
lcId_tec = QuotedStr(cursor_tecajnic.id_tec)

lcId_kupca = ""
lcBaza = iif(cursor_sys.is_snapshot,"dbo.oc_customers","dbo.partner")
lcAnd = iif(cursor_sys.is_snapshot,"and id_oc_report = " + lcId_rep,"")

if cursor_sys.is_snapshot then
   lcId_kupca = GF_GET_STRING("Unesite šifru partnera:", NVL(cursor_claims.id_kupca, ""))
        if isnull(lcId_kupca) or empty(lcId_kupca) then
        	return = .f.
        endif
else
    lcId_kupca = cursor_claims.id_kupca
endif

lcId_kupca = QuotedStr(lcId_kupca)

GF_SqlExec("select * from "+lcBaza+" where id_kupca=" + lcId_kupca + lcAnd, "rez_part", ALLTRIM(cursor_sys.con_name))

llIncludeClosed = potrjeno("Želite li uključiti i zaključene ugovore?")
llContract_id_tec = potrjeno("Želite li podatke po ugovornom tečaju?")
lcSql = ""
lcSql = lcSql + "exec dbo.grp_iop_cro " + lcId_rep + ", " + lcId_kupca + ", " + lcId_tec

if llIncludeClosed then
   lcSql = lcSql + ", 1"
else
    lcSql = lcSql + ", 0"
endif
    
if llContract_id_tec then
   lcSql = lcSql + ", 1"
else
    lcSql = lcSql + ", 0"
endif

GF_SqlExec(lcSql, "rezultat", ALLTRIM(cursor_sys.con_name))