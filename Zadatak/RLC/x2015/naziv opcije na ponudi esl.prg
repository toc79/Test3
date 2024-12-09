
* na ispisu je podešeno da se PuEOM ne ispisuje, tako da bi to mogli izbaciti, kako i funkciju RF_CALC_EOM_ESL
Public PuEOM
IF at(RF_TIp_POG(ponudba.nacin_leas),'FF,F1,ZP')>0
	PuEOM = RF_CALC_EOM_ESL(ponudba.id_pon)
ENDIF

Select sum(debit) as debit, sum(anuiteta+marza) as anuiteta, sum(neto) as neto, sum(obresti) as obresti, sum(davek) as davek, max(zap_obr) as max_zap_obr from planp into cursor _planp_tmp


rlOpcija
_planp_tmp.max_zap_obr = planp.zap_obr and ponudba.opcija > 0

allt(iif(planp.id_terj='20','UČEŠĆE', iif(planp.id_terj='21',iif(rlOpcija,'OTKUPNA RATA',allt(trans(planp.zap_obr))+'. RATA'),lookup(vrst_ter.naziv,planp.id_terj,vrst_ter.id_terj))))


***** RLC allt(planp.vrst_ter_naziv)

allt(iif(rlOpcija AND rctip_leas != 'OL','Otkupna vrijednost objekta leasinga',planp.vrst_ter_naziv))


***UGOVOR

local lcPPMV, lcRecNo
lcPPMV = "0"

sele planplacil
go top

lcRecNo = RECCOUNT("planplacil")

scan for id_terj = '34'
  lcPPMV = "1"
endscan

GF_SQLEXEC("select dbo.gfn_GetOpcSt_dok("+gf_quotedstr(pogodba.id_cont)+","+gf_quotedstr(pogodba.nacin_leas)+") as st_dok ","_cb_opcija")


Select sum(debit) as debit, sum(neto+obresti+robresti+marza+regist) as anuiteta, sum(neto) as neto, sum(obresti) as obresti, sum(davek) as davek, sum(robresti) as robresti, lcPPMV as PPMV, lcRecNo as RecNo from planplacil into cursor _planp_tmp


rlOpcija
allt(_cb_opcija.st_dok) = allt(planplacil.st_dok) and RF_TIP_POG(pogodba.nacin_leas) != 'OL'

allt(iif(planplacil.sif_terj#'LOBR',iif(planplacil.sif_terj='POLO' AND (rctip_leas='FF' or rctip_leas='F1'),'UČEŠĆE',planplacil.naziv),iif(rlOpcija,'OTKUPNA RATA',allt(trans(planplacil.zap_obr))+'. '+IIF(rctip_leas='OL',"LEASING OBROK","RATA"))))


** RLC
* iif(planplacil.sif_terj#'LOBR',iif(planplacil.sif_terj='POLO',iif(left(lcnacin,1)='F','UČEŠĆE','POSEBNA NAJAMNINA'),planplacil.vrst_ter_naziv),iif(lookup(nacini_l.tip_knjizenja,planplacil.nacin_leas,nacini_l.nacin_leas)='1','OBROK','RATA'))

iif(planplacil.sif_terj#'LOBR',iif(planplacil.sif_terj='POLO',iif(left(lcnacin,1)='F','UČEŠĆE','POSEBNA NAJAMNINA'),planplacil.vrst_ter_naziv),iif(rcTip_knj='1','OBROK',iif(rlOpcija,'Otkupna vrijednost objekta leasinga','RATA')))

**RLB
rcOpcija_st_dok
GF_SQLEXECScalar("select dbo.gfn_GetOpcSt_dok("+gf_quotedstr(pogodba.id_cont)+","+gf_quotedstr(pogodba.nacin_leas)+") as st_dok ")

rnOpcija
look(planplacil.debit,rcOpcija_st_dok,planplacil.st_dok)